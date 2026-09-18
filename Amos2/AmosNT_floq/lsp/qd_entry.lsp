;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_entry.lsp,v $
;;; $Revision: 1.33 $ $Date: 2007/10/21 15:00:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: query decomposition
;;; =============================================================
;;; $Log: qd_entry.lsp,v $
;;; Revision 1.33  2007/10/21 15:00:15  torer
;;; Not tested code for bag materialization removed
;;;
;;; Revision 1.32  2006/04/12 20:59:08  torer
;;; Multi-database decomposition separated
;;;
;;; =============================================================


; Graph node in the first stage of the decomposition
;org_<types> - some of the types in argtypes migh be changed to INTEGER
;              during mbl node distribution (merge of SAE nodes) and then
;              type information is lost.
;              Then we use origtypes to save the original types of data.
(defstruct gNode
  db        ; database
  predl     ; list of predicates
  fno       ; proxy function defined in DB, it is PREDL compiled in DB
  vars      ; all variables in the predicates in PREDL
  vartypes  ; the types of VARS
  org_vartypes ; original types of VARS. 
               ; Store real types when types are 'faked'
  bpat      ; binding pattern of VARS
  cost      ; the cost of execution of FNO (i.e. this node)
  fanout    ; the fanout of FNO (i.e. this node)
  params    ; parameters (inputs) supplied during the call to the function
  paramtypes ; types of PARAMS
  org_paramtypes ; original types of PARAMS
  view_def  ;used when expanding the distributed views. rets the expanded def
  shipInflag ;used to for ship-in execution of SAE
)

;decomposition tree node
(defstruct tNode
  db         ; the database of this exec. plan. Now it is always 'LOCAL
  mbl        ; list of tNode. Currently only one element is supported.
  sae        ; Ship-And-Execute node (of type gNode)
  ppl        ; list of Post-Processing nodes (of type gNode)
  pplCost    ; cost of PPL node
  cost       ; cost of this tNode
  fanout     ; fanout of this tNode
  rem        ; remaining predicate groups during dyn. prog. opt.
  res        ; result variables
  restypes   ; result variable types
  params     ; input parameters
  paramtypes ; types of the parameters
)


(defglobal _mdbfunc_ 0) 
  ;; used to generate unique names for the temporary functions

;dynmaicaly bound vars used in the decomposition

;contains the types of the vars used in the decomposition
;for some reason this was not the same with *bindings*
(defvar *var_types* nil)

;the query result and argument list, not changed in the decomp. needed all over
(defvar *query_argl* nil)
(defvar *query_resl* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;query decomposition entry functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun distributed-decomposition (fno sb opt-coerced-pred)               
  (let (decomposed-pred (decompRes (distributed-decompose opt-coerced-pred sb))
			optpred result)
    (setq decomposed-pred (car decompRes))
    (cond ((expand-views?)
	   (setf (selectbody-decomptree sb) decomposed-pred)
	   decomposed-pred)
	  (t
	   (if (and fno (third decompRes))
	       (/putobject fno 'cost 
			   (cond ((second decompRes)
				  (setf (selectbody-decomptree sb)
					(second decompRes))
				  (third decompRes)))))
           (setq result decomposed-pred)))
    result))

(defun distributed-decompose (predl sb)
  "Entry to the decomposition phase. Called from optimize-pred.
   'predl' is in DNF. Valid elements of the predicate list are:
   - AND, OR, <predicate>, FALSE
   It is assumed that all TRUE constants were removed by the previous phase.
   Returns a list with 3 elements:
   (decomp_tree algebra_tbr_predicates (cost . fanout))"
  (cond ((atom predl) predl)
	((and (expand-views?) (not (mdb_query? predl T)))
	 (list nil nil nil))		;local query
	((not (mdb_query? predl))
	 (if (expand-views?)
	     (list nil nil nil)
	   (list (apply_to_pred predl sb (function sortandpred)) nil nil)))
	(t
	 (let ((head (car predl))
	       (tail (cdr predl))
	       (*query_argl* (selectbody-argl sb))
	       (*query_resl* (selectbody-resl sb)))
	   (cond 
	    ;;disjunctive predicate
	    ;;apply recursively decompose_pred and add the costs/fanouts
	    ;;does not support opening views!!!
	    ((eq head 'OR)
	     (let ((res (mapcan 
			 (f/l (br) 
			      (cond
			       ((eq br 'FALSE) nil)
			       ((listp br) 
				(catch-exec-error
				 (list (distributed-decompose br sb))))
			       (t (assert NIL "illegal predicate list"))))
			 tail)))
	       (list
		(orify (heads res))
		(orify (getvars res))
		(cons 
		 (apply (function +) (mapcar (f/l (e) (or (car (third e)) 
							  0)) res))
		 (apply (function +) (mapcar (f/l (e) (or (cdr (third e))
							  0))
					     res))))))
	    ;;conjuntive predicate (or single predicate)
	    ((or (eq head 'AND) (function_p head))
	     (let ((dtree (catch-exec-error (decompose_and predl sb))))
	       ;;this returns a tree or predicate if (expand-views?) is T
	       (cond ((symbolp dtree)	; decomp failure
                      (list dtree nil nil))
                     ((expand-views?)
		      (list dtree nil nil))
		     (t
		      ;;run tree distribution
		      (setq dtree (distribute-tree dtree))
		      ;;generate the algebra code for the final decomp. tree
		      (list (funify 'and (gen_decomposed_pred dtree)) 
			    dtree 
			    (cons (tNode-cost   dtree)
				  (tNode-fanout dtree)))))))
	    (t (list predl nil nil)))))))

(defun decompose_and (Apredl sb)
  "Returns one of:
   1. if compiling - a decomposition tree for a list of predicates
   2. if views are opened, i.e. (expand-views?) is T
      - a list (predicates ((var.type) ...)) if a group was expanded
      - or NIL if no views were expanded"
  (if (atom Apredl)
      Apredl
    ;; generate a query graph - a list of gNode
    (catch 'decompose_and;; to allow failures to prune
      (let* ((grouped_graph (generate_subqueries Apredl))
	     ;; at this point gNode-fno can be NIL for grouped_graph members
	     open_view_grouping)
	;; call DSVE
	(if (neq *DSVE-STRATEGY* 'dsve-none)
	    (setq open_view_grouping (process-distr-views grouped_graph sb)))
	(if (expand-views?)
	    open_view_grouping
	  (let* ((final_grouping (or open_view_grouping grouped_graph))
		 ;;define a fuction (locally/in sources/in other meds.) 
                 ;;each grp.
		 (function_graph (mapcar 
				  (f/l (grp) (def_tmp_func grp 
					       final_grouping *query_resl*))
				  final_grouping)))
	    ;;it says it all
	    (cost_based_decomposition function_graph)))))))

(defun generate_subqueries (Apredl)
  "Apply the grouping heuristics to produce a query graph from the pred. list.
   'apredl' - list of list without the first AND."
  (let* ((predl (if (eq 'and (car Apredl)) (cdr Apredl) (list Apredl)))
	 (init_graph (mapcar (function mk_graph_p) predl))
	 (first_grouping (group_graph init_graph))
	 (final_grouping (place_disp_groups first_grouping predl)))
    final_grouping))

(defun mdb_query? (predl &optional only_proxy)
  "Checks if a query contains predicates to be evaluated outside 
   this amos server."
  (if _ENABLE_MDB_FLAG_
      (let ((head (if (listp predl) (car predl))))
	(cond ((or (eq head 'OR) (eq head 'AND))
	       (some (f/l (p)  (mdb_query? p only_proxy)) (cdr predl)))
	      ((and (eq head _typesof_)
		    (oid-p (third predl))
		    (proxytype? (third predl))
		    ;; this is to filter only proxies from other amos servers
		    (or (not only_proxy) 
			(equal (sourcetype? (proxytype-origin (third predl))) 
			       'proxy))
		    ;;(memq (second predl) *query_resl*)
		    )
	       t)
	      ((eq _makebag_ head)
	       (neq 'LOCAL (db_pred predl)))
	      ((oid-p head)
	       (and 
		(proxyfunc? head)
		;; this is to filter only proxies from other amos servers
		(or (not only_proxy) 
		    (equal (sourcetype? (proxyfunc-origin head)) 'proxy))))
	      (t NIL)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Post processing of the chosen tree
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fix_func_bodies (node)
  "Remote-or-local interface to to fix_func_body. Called over a tree node."
  (let ((mbl (tNode-mbl node))
	(sae (tNode-sae node))
	(ppl (tNode-ppl node)))
    (mapc #'fix_func_bodies mbl)
    (if sae
	(let* ((bpat_orig (gNode-bpat sae))
	       (db (mkatom (gNode-db sae)))
	       ;;this is a dirty fix, to ship-in or not should be determined
	       ;;by a cost calculation during the tree generation
	       ;;qd_cost.lsp should be changed
	       (do_shipin (and _ENABLE_SHIPIN_ 
			       (some (f/l (x) (eq x '-)) bpat_orig)))
	       ;;ship-in implies that all unbound is executed
	       (bpat (if  do_shipin 
			 (buildn (length bpat_orig) '+)
		       bpat_orig))

	       ;;if ship in keep the all unbound version of the query
	       (dummy (and do_shipin
			   (get_cost (gNode-fno sae) bpat db)))
	       (varl
		(remote-eval (list 'fix_func_body
				   (kwote (proxyfunc-origname 
					   (gNode-fno sae)))
				   (kwote bpat)
				   (kwote (if mbl (tNode-res (car mbl))))
				   do_shipin)
			     db)))
	  (fix_gnode_props varl sae do_shipin)))
    (mapcar (f/l (ppn)
		 (let ((ppn-varl (fix_func_body (oid-name (gNode-fno ppn)) 
						(gNode-bpat ppn) nil)))
		   (fix_gnode_props ppn-varl ppn)))
	    ppl)))

(defun fix_gnode_props (fvarl node &optional shipInFlag)
  (let* ((oldVars (gNode-vars node))
	 (oldOrigTypes (gNode-org_vartypes node))
	 (nvars (intersection fvarl OldVars))
	 (bpat (gNode-bpat node))
	 (vbpat (mapcar (f/l (a b) a) bpat oldVars))
	 (lrest (- (length bpat) (length vbpat)))
	 (nbpat (padd (sort vbpat (f/l (a b) (eq a '-))) lrest '-))
	 ;;sorts the bpat into (- - - - - - ... + + + + + )
	 (nargtypes (subpair oldVars (gNode-vartypes node)  nvars))
	 (norigtypes (if oldOrigTypes (subpair oldVars oldOrigTypes nvars))))
    (setf (gNode-shipInFlag node) shipInFlag)
    (setf (gNode-bpat node) nbpat)
    (setf (gNode-vars node) nvars)
    (setf (gNode-vartypes node) nargtypes)
    (setf (gNode-org_vartypes node) norigtypes)))

(defun fix_func_body (fnname bpatIn mblres)
  "Destructive changes the functions property list to use the selectbody for a
   particular binding. This selectbody is generated by bpat-optimize-func 
   during the tree generation. Called over a graph node
   Furthermore, the order of the variables in the function definition
   is changed so that the bound variables are in front, 
   followed by the unbound"
  (let* ((fno (getfunctionnamed fnname))
	 (p_sb_c  (getbpatfn fno bpatIn))
	 (flag (and p_sb_c (tbr-p p_sb_c)))
	 (sb   (if flag (tbr-selbody p_sb_c) (getobject fno 'selectbody)))
	 (bpat (if flag (tbr-bpat p_sb_c) bpatIn))
	 (argres (get-resolvent-argtypes fno))
	 (argtypes1 (filter_bnd argres bpat '-))
	 (restypes (filter_bnd argres bpat '+))
	 (argl1 (selectbody-argl sb))
	 (a_t (pair argl1 argtypes1))
	 (nord (append  (intersection mblres argl1)
			(set-difference argl1 mblres)))
	 (ntypeord (mapcar (f/l (v) (cdar
				     (mapfilter (f/l (vt) (eq (car vt) v))
						a_t)))
			   nord))
	 (argtypes (or ntypeord argtypes1))
	 (argl (or nord argl1))
	 (resl (append argl (selectbody-resl sb))))
					;(bp ffb)
    (/putobject fno 'argtypes argtypes)
    (/putobject fno 'restypes restypes)
    (/putobject fno 'selectbody sb)
    (setf (selectbody-argl sb) argl)
    (/putobject fno 'bindpat nil)	; deletes the rest of the selectbodies
    (/putobject fno 'origquant nil)
    resl))

(defun fix_ppl_bpats (tree)
  (set-ppl-bpat tree)
  (mapc #'fix_ppl_bpats (tNode-mbl tree)))

(defun set-ppl-bpat (tree)
  (let* ((mbl (tNode-mbl tree))
	 (sae (tNode-sae tree))
	 (ppl (tNode-ppl tree))
	 (rem (tNode-rem tree))
	 (mblRes (unionl (mapcar #'tNode-res mbl)))
	 (pplRes (unionl (mapcar #'gNode-vars ppl)))
	 (saeRes (if sae (gNode-vars sae)))
	 (input *query_argl*)
	 (pplInput (unionl (list input mblRes saeRes)))
	 (rest (union
		(unionl (mapcar #'gNode-vars rem))
		*query_resl*))
	 (outvars (intersection (set-difference pplRes pplInput)
				rest)))
    (mapc (f/l (ppn)
	       (setf (gNode-bpat ppn)
		     (append
		      (mapcar (f/l (v) (if (memq v outvars) '+ '-))
			      (gNode-vars ppn))
		      (buildn (length (gnode-params ppn)) '-))))
	  ppl)))
