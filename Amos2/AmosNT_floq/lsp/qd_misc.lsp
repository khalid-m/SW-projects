;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_misc.lsp,v $
;;; $Revision: 1.32 $ $Date: 2010/03/13 14:38:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Miscanelous functions used in the query decomposition
;;; =============================================================
;;; $Log: qd_misc.lsp,v $
;;; Revision 1.32  2010/03/13 14:38:53  torer
;;; UNCACHE-COSTS did not clear TBR costs
;;;
;;; Revision 1.31  2009/12/30 19:38:47  torer
;;; APPENDL moved to misc.lsp and generalized
;;;
;;; Revision 1.30  2009/04/22 17:35:46  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.29  2008/12/25 19:24:56  torer
;;; Global variable _USE_DNF_ --> Special variable *use-dnf*
;;;
;;; Revision 1.28  2006/04/13 07:30:19  torer
;;; New function enable_mdb(); sets all necessary flags for using MDB
;;;
;;; =============================================================

(defglobal _osql_iter_bag_ nil)
; a function that implements the strategy to change the bulk size at exec time
(defglobal _bulk_strategy_ nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Miscanelous functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun map-dtree (root-tnode fn-pre-ord fn-post-ord)
  "Execute 'fn' for every node in the decomposition tree with root ROOT-TNODE.
   Depth first traversal of the tree."
  (cond ((null root-tnode))		; do nothing
	((listp root-tnode)
	 (let ((next (if (eq (car root-tnode) 'OR)
			 (cdr root-tnode)
		       root-tnode)))
	   (mapc (f/l (n) (map-dtree n fn-pre-ord fn-post-ord)) next)))
	(t
	 (if fn-pre-ord
	     (funcall fn-pre-ord root-tnode))
	 ;; recursive call to move down the tree
	 (mapc (f/l (n) (map-dtree n fn-pre-ord fn-post-ord)) 
	       (tnode-mbl root-tnode))
	 (if fn-post-ord
	     (funcall fn-post-ord root-tnode)))))

(defun fix_at_decl (quant &optional only_name) 
  "Changes types given in type@db notation to proxy types
   called from compileselect."
  (mapcar (f/l (tp_var) (cons
			 (let ((tp (car tp_var)))
			   (if (listp tp)
			       (let ((tpname
				      (proxy_type_name (car tp) (cadr tp))))
				 (if only_name 
				     tpname
				   (gettypenamed tpname))) 
			     tp))
			 (cdr tp_var)))
	  quant))

(defun proxytype? (tp) 
  "Test if type TP is a proxytype"
  (memq _proxytype_ (oid-types tp)))

(defun proxytype-origin (tp)
  "Returns the name of a proxy type's origin db or nil if local type"
  (assert (memq _proxytype_ (oid-types tp)) "Non-proxy type argument")
  (oid-name (getobject tp 'datasource)))

(defun proxytype-origname (tp)
  "Returns the original name of a proxy type as defined in it's database."
  (if (proxytype? tp)
      (oid-origname tp)
    (error "Not a proxy type" tp)))

(defun sourcetype? (source)
  (if (equal source 'LOCAL) 
      'proxy
    (let* ((ds_obj (get-datasource-named source))
	   (ds_type (arg-type ds_obj)))
      (cond ((eq ds_type _amos_)
	     'proxy)
	    ((eq (oid-name ds_type) 'odbc)
	     'odbc)
            ))))

(defun proxyfunc? (fo)
  "Test if function FO is a proxy function."
;  (memq _proxy_ (oid-types fo)))
  (and (oid-p fo) (getobject fo 'ProxyFunc)))

(defun proxyfunc-origin (fo)
  "Returns proxy function's origin db or nil if local function."
; TODO: remove the proxyfunc property, and replace by this call:
; (assert (proxy-p fo) "Not a proxy object")
; (proxy-database fo))
  (assert (proxyfunc? fo))
  (getobject fo 'ProxyFunc))

(defun oid-origname (o)
  "The original name of a proxy object as defined in it's database"
  (getobject o 'origname))

(defun proxyfunc-origname (fo)
  "The external name of a proxy function"
  (if
      (proxy-p fo)
      (oid-origname fo)
    (error "Not a proxy" fo)))

(defun unionL (l)
  "Union of more than 2 arguments (list of lists)"
  (if l (union (car l) (unionl (cdr l)))))

(defun filter_bnd (lst bpat tag)
  (mapfilter (f/l (x) x) 
	     (mapcar (f/l (el bind) 
			  (if (eq bind tag) el)) 
		     lst bpat)))

(defun pair_var_types (graph)
  "Extracts a list of pairs of vars and the typenames."
  (appendl 
   (mapcar (f/l (n) 
		(let ((db (gNode-db n)))
		  (mapcar (f/l (v tp) (cons v (get_orig_name tp db))) 
			  (gNode-vars n) (gNode-vartypes n))))
	   graph)))

(defun get_orig_name (tpn db)
  (if (neq db 'LOCAL)
      (list tpn db)
    (let ((tp (gettypenamed tpn T)))
      (if (and tp (proxytype? tp))
	  (list (proxytype-origname tp) (proxytype-origin tp))
	(list tpn db)))))

(defun tree_var_type (v &optional local_Flag)
  "Check a type of a var in the tree module."
  (let ((pl (mapfilter (f/l (v_t) 
			    (eq v (car v_t))) *var_types*)))
    (if pl
	(let ((rec (car pl)))
	  (if (or (not local_Flag) 
		  (eq (third rec) 'LOCAL) 
		  (is_system_type_name (second rec))) 
	      (second rec)
	    (proxy_type_name (second rec) (third rec)))))))

(defun setupbulk ()
  ;; sae
  (bind-foreign 'sae->integer '*any* 'sae)
  (create-function sae () ((integer)) as foreign "sae->integer")
  ;; bulken
  ;; is it any faster to call a function with bpat 'any'???
  (createfunction "bulken" '((bag)) '((bag)) 'FOREIGN '("bulken-+") NIL)
  ;; iter-bag
  (bind-foreign 'iter-bag->integer '*any* 'iter-bag)
  (setq _osql_iter_bag_ 
	(create-function iter-bag () ((integer)) 
			 as foreign "iter-bag->integer"))
  (setq _bulk_strategy_ 'bulk-constant))

(defun init-mdb-subsystem ()
  (cond ((not _enable_mdb_flag_)
	 (setupbulk)
	 (setq _ENABLE_MDB_FLAG_ T)
	 (setq _DISTRIBUTE-TREE_ nil);; Tree distribution dflt off
	 (foreign-lispfn atrue ((object o))((integer))
			 (foreign-result 1))
	 ;; register the funcs that can be moved among amoses
	 (register_as_displaceable)
	 )))

(defun enable-mdb ()
  "Enable mdb subsystem on all peers"
  (global-eval '(progn 	 (setq  _default-foreign-fanout_ 1)
                         (setq *USE-DNF* T) 
			 (setq _USE_DTR_ nil)
			 (setq *enable-parteval* nil))))
