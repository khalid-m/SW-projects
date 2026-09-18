;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Vanja Josifovski, Timour Katchaounov, UDBL
;;; $RCSfile: qd_dsve.lsp,v $
;;; $Revision: 1.6 $ $Date: 2006/04/12 08:21:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Distributed Selective View Expansion (DSVE)
;;; =============================================================
;;; $Log: qd_dsve.lsp,v $
;;; Revision 1.6  2006/04/12 08:21:15  torer
;;; Correct reconstruction of variable *BINDINGS* for cost-based optimization
;;;
;;; Revision 1.5  2006/02/24 20:20:58  torer
;;; Replaced QUOTE with FUNCTION
;;;
;;; ===========================================================================


; a list with head external_marker denotes an object (type or function) that
; cannot be interpreted locally (not imported). This is reversed when the 
; predicates come back for compilation.
(defglobal external_marker '<-->)

(defvar *view_types* nil)

(defun process-distr-views (final_grouping sb)
  "Entry function for DSVE.
   - 'final_grouping' - a list of gNode.
   - returns either:
     1. graph when a query is compiled for execution
     2. when views are opened:
        - a list (predicates ((var.type) ...)) if a group was expanded
        - or NIL if no views were expanded"
  ; try to expand each proxy group
  (let ((expanded-groups (expand-sif-groups final_grouping))
	predl-vars)
    ; even if no group is expanded, if we are expanding views, and
    ; there are external subqueries, the expanded should be returned
    (if (and (expand-views?)
	     (not expanded-groups)
	     (some (f/l (n) (neq (gNode-db n) 'LOCAL)) final_grouping))
	(setq predl-vars (re_join_preds final_grouping))
        (setq predl-vars (re_join_preds expanded-groups)))
    ; two cases:
    ; 1) when views are opened return new predicate or nil for no-change
    ; 2) when a query is compiled for execution return a regrouped graph
    (if (expand-views?)
	predl-vars
        (if expanded-groups
	    ; if at least one group expanded new predicates were added.
	    ; Then do the grouping again.
	    (let* ((predl (car predl-vars))
		   (var-types (cdr predl-vars))
		   (locpredl (un_mark_external predl _amosid_)))
	      (mapc (f/l (vt)
			 (if (not (type_of_var (car vt) *bindings*))
			     (addbinding (car vt) nil 
					 (or (gettypenamed (cdr vt) t) (cdr vt)))))
		    var-types)
	      ; TODO is it the right place to call rewrite here?
	      ; Currently it will not do any good because the functions are replaced
	      ; by their externalized form. If instead of externalizing we import
	      ; remote functions as proxy functions (non-exec.) they will have
	      ; their key information and this will allow for the rewrite to work.
	      ;(setq locpredl (rewriteand locpredl sb))
	      (generate_subqueries (cons 'AND locpredl)))
	  ; else return the input
	  final_grouping))))

(defun expand-views? ()
  "Return TRUE if we are expanding views, NIL if we are compiling"
  (and _enable_mdb_flag_ *DSVE-BUDGET*
       (>= *DSVE-BUDGET* 0)))

(defun nested-subqueries? (predl)
  (mapfilter (f/l (p) (memq _makebag_ p)) predl))

(defun initial-dsve-budget (graph)
  "Return the initial budget for the DSVE process."
  (let (budget)
    (cond ((eq *DSVE-BUDGET* 'dsve-top)
	   ; if this is the initiating mediator, use heuristics 
	   ; to calculate the initial DSVE budget
	   (case *DSVE-STRATEGY*
	     (dsve-full (error "Not supposed to ask for initial budget for full DSVE."))
	     (dsve-none (setq budget 0))
	     (dsve-tnsm (setq budget 3)) ; just a fix for the experiments
             ; manual budget distributions - used only for experimental purposes
	     (dsve-manual (setq budget (get-manual-budget-distr)))
	     ; placeholders - not implemented yet
	     (dsve-csm (error "This DSVE strategy is not implemented: dsve-csm"))
	     (dsve-depth (error "This DSVE strategy is not implemented: dsve-depth"))
	     ; default
	     (amos-error "Illegal DSVE strategy: " *DSVE-STRATEGY*))
	   ;(formatl t "Setting initial budget to: " budget t)
	   )
	   ((> *DSVE-BUDGET* 0)
	    ; we are in the middle of DSVE and *DSVE-BUDGET* came from another mediator
	    ; then subtract '1' to reflect that this call consumed one expansion unit
	    (setq budget (- *DSVE-BUDGET* 1)))
	   ((= *DSVE-BUDGET* 0)
	    (setq budget 0))
	   (t
	    (amos-error "Illegal DSVE budget: " *DSVE-BUDGET*)))
    budget))

(defun expand-sif-groups (graph)
  "View expansion of SIF groups (the nodes in 'graph'). This is the top of the chain 
   where *DSVE-BUDGET* is set. Iterate over all nodes in 'graph' and set 'change_flag' 
   if any node represents a group that has been expanded. 
   - 'graph' - a list of gNode.
   Return: - graph with some nodes expanded
           - if no expanisions, NIL"
  (let* ((*DSVE-BUDGET* (cond ((null *DSVE-BUDGET*) 'dsve-top) ; this is the top-most call to DSVE
			      (t *DSVE-BUDGET*))) ; use the one set before
	 (budgeted-graph (funcall *DSVE-STRATEGY* graph))
	 change_flag expanded-graph)
    (setq expanded-graph
	  (mapcar
	   (f/l (node-budget)
		(let* ((node   (first node-budget))
		       (budget (second node-budget))
		       (db (gnode-db node)))
		  (if (and (> budget 0)
			   (not (nested-subqueries? (gNode-predl node))))
		      (let* ((*DSVE-BUDGET* budget)
			     (view-def (gnode-view_def (def_tmp_func node graph *query_resl*))))
			(assert (and (eq (sourcetype? db) 'proxy) (neq db 'LOCAL))
				"Trying to expand a LOCAL or ODBC subquery.")
			(assert (>= *DSVE-BUDGET* 0) "Expanding with negative budget")
			;(formatl t t "Expand request to: " db " budget: " budget t "View def: " t)
			;(pps (car view-def))
		        ; view definitions are lists of preds (possibly marked as external)
			(cond (view-def
			       ; copy the node, because the original is used in def_tmp_func
			       (let ((new-node (copy-array node)))
				 (setq change_flag t)
				 (setf (gNode-predl new-node) (car view-def))
				 (setf (gNode-vars new-node) (cdr view-def))
				 (setf (gNode-db new-node) 'UNKN)
				 new-node))
			      (t
			       node)))
		      node)))
	   budgeted-graph))
    (if change_flag expanded-graph NIL)))

(defun re_join_preds (graph)
  "Adds together all the predicates in a list of graph nodes (gNode), marks the unknown 
   types and functions as 'external' and collects the types of variables.
   - 'graph' - list of gNode
   - return - (predl (v1 . t1) ...), where predl is a list of
     possibly marked predicates."
  (let* (*view_types* predl)
    (setq predl
	  (mapcan (f/l (node)
		       (cond ((neq (gNode-db node) 'UNKN)
			      (let* ((odb (gNode-db node))
				     (pdb (if (eq odb 'LOCAL) _amosid_ odb)))
				(mark_external (gNode-predl node) pdb)))
			     (t
			      (setq *view_types* (append (gNode-vars node) *view_types*))
			      (gNode-predl node))))
		  graph))
    (cons predl *view_types*)))

(defun mark_external (l pdb)
  "Marks the objects as external and saves the types of the symbols instead of
   an object it puts in the list a structure (<---> obj_name amos_server)"
  (cond ((not l) nil)
	((listp l)
	 (mapcar (f/l (x) (mark_external x pdb)) l))
	((oid-p l)
	 (if (> (oid-idno l) _system-watermark_)
	     (list external_marker 
		   (or (oid-origname l) (oid-name l))
		   pdb)
	   l))
	((symbolp l)
	 (if (not (some (f/l (x) (eq l (car x))) *view_types*))
	     (let* ((v_type (type_of_var l *bindings*))
		    (e_type (or (proxytype-origname v_type)
				(oid-name v_type))))
	       (setq *view_types* (cons (cons l e_type) *view_types*))))
	 l)
	(t l)))

(defun un_mark_external (l &optional local_server)
  "1. Translates object that are marked as external in the accepted 
   predicate to local objects, based on the name
   this is used when code is shipped up to the mediator and the types and
   the functions are not imported there.
   They are marked as external, and unmarked here, when the code is back."
  (cond ((not l) nil)
	((listp l) 
	 (if (eq (car l) external_marker)
	     (if (or (not local_server)   ; no server given, do not check it
		     (eq local_server (third l))) ;server given check if the same
		 (or (gettypenamed (second l) t)
		     (getfunctionnamed (second l) t)
		     (getobjectnamed (second l)))
	         l)
	   (mapcar (f/l (x) (un_mark_external x local_server)) l)))
	(t l)))

(defun correct_extf (p)
  "2. When a type is exported, the importing mediator does not know if it is 
   a derived type or an ordinary type in the exporting mediator.
   Therefore it generates a code with typesof. If in turn this is a 
   derived type, when the code comes back to the exporting mediator,
   the extent function should be changed to (extent_dtName v)."
  (mapcar (f/l (p1)
	       (if (and (listp p1) (eq (car p1) _typesof_) (dt_p (third p1)))
		   (list (getobject (third p1) 'extentfn) (second p1))
		 p1))
	  p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DSVE strategies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dsve-full (graph)
  "Full DSVE - every node receives budget 1.
   Return a list: ((gnode 1) ...)"
  (mapcar (f/l (node)
	       (let ((db (gnode-db node)))
	         ; view expansion only for subqueries in other amos systems
		 (if (and (eq (sourcetype? db) 'proxy)
			  (neq db 'LOCAL))
		     (list node _MAXINT_)
		     (list node 0))))
	  graph))

(defun dsve-tnsm (graph)
  "Total number of sub-mediators"
  ; TODO: there is a logical bug in the prop. distr.
  ;(budget-distr-proportional (initial-dsve-budget graph) graph #'gnode-num-sub-med)
  (budget-distr-even (initial-dsve-budget graph) graph #'gnode-num-sub-med))

; current DSVE budget distribution strategy
(defglobal _DSVE-MANUAL-DISTR_ NIL)
; table of budget per server for each strategy ((strategy (db budget)) ...)
(defglobal _DSVE-MANUAL-DISTR-TABLE_ NIL)

(defun get-manual-budget-distr ()
  "Get a manual budget distribution"
  (let (distr)
    (setq distr (assoc _DSVE-MANUAL-DISTR_ _DSVE-MANUAL-DISTR-TABLE_))
    (if distr
	(second distr)
        (error "NIL manual budget distribution"))))

(defun dsve-manual (graph)
  "Use a predefined distribution
   - 'budget' is a list of budgets per nodes: ((db1 b1) (db2 b2) ...)"
  (let ((budget (initial-dsve-budget graph)))
    (cond ((null budget)
	   (error "Illegal NIL budget"))
	  ((listp budget)
	   (mapcar (f/l (n)
			(let* ((db (gnode-db n))
			       (b (second (assoc db budget))))
			  (if (null b) (setq b 0))
			  (list n b)))
		   graph))
	  ((integerp budget)
	   (budget-distr-even budget graph #'gnode-num-sub-med))
	  (t (error "Illegal budget")))))


(defun dsve-csm (graph)
  "Number of common sub-mediators"
)

(defun dsve-depth (graph)
  "Maximum data integration depth"
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to collect MDB statistics of OSQL functions and predicate lists.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mdb-preds (predl)
  "Return a list of the predicates in 'predl' defined in external data sources."
  (let ((head (if (listp predl) (car predl)))
	ext-preds)
    ; normalize 'predl' to the format: ((pred v1 v2 ...) ...)
    (cond ((or (eq head 'OR) (eq head 'AND))
	   (setq predl (cdr predl)))
	  ((oid-p head)
	   (setq predl (list predl)))
	  ((listp head)) ; pass through - it is in the right form
	  (t
	   (amos-error "Don't know how to handle predl head: " head)))
    ; filter the MDB predicates
    (mapfilter (f/l (pred)
		    (let ((fno (car pred)))
		      (or (proxy-p fno) ; allow for 'opaque_proxy'
			  (and (proxyfunc? fno)
			       (eq (sourcetype? (proxyfunc-origin fno)) 'proxy)))))
	       predl
	       #'car)))

(defun mdb-preds-deep (fno recursion-depth)
  "Extract the maximum depth of the OSQL function 'fno', and all predicates that
   are called directly or indirectly from 'fno'.
   Return a list: (max-depth (fno1 fno2 ...))"
  (let* ((dtree (selectbody-decomptree (getselectbody fno)))
	 ext-preds)
    ; collect all MDB  predicates in all SAE nodes of this function's decomp. tree
    (map-dtree dtree
	       NIL ; pre-order
	       (f/l (tn) ; post-order
		    (let ((sae-gnode (tnode-sae tn))
			  db predl)
		      (cond (sae-gnode
			     (setq db (gnode-db sae-gnode))
			     (setq predl (gnode-predl sae-gnode))
			     (setq predl (remote-eval `(un_mark_external , (kwote predl)) db))
			     (setq ext-preds (nconc (mdb-preds predl) ext-preds)))))))

    ; if this function is called in db A it checks if some predicates defined in db B
    ; (used in A) are by themseleves defined in a third db C
    (if (and (> recursion-depth 0) ext-preds)
	(let (ext-preds-info ext-ext-preds max-depth)
	  (setq ext-preds-info
		(mapcar (f/l (p)
			     (remote-eval `(mdb-preds-deep , p , (- recursion-depth 1))
					  (proxy-database p)))
			ext-preds))
	  ; get the maximum depth
	  (setq max-depth (maxl (mapcar #'first ext-preds-info)))
	  (setq ext-ext-preds (append ext-preds (mapcan #'second ext-preds-info)))
	  ; increase max-depth to account for the remote-recursive call and return
	  (if ext-ext-preds
	      (list (1+ max-depth) ext-ext-preds)
	      (list max-depth NIL)))
        ; this is the bottom of the recursion
        (list 1 ext-preds))))

(defun gnode-num-sub-med (gnode &optional depth)
  "Gnode statistics function.
   Return the total number of MDB sub-mediators (NSM) in 'gnode' by exploring
   all MDB subqueries up to a maximum 'depth'. If 'depth' is NIL, then all
   sub-mediators at any depth will be explored."
  (let* ((predl (gnode-predl gnode))
	 (ext-preds (mdb-preds predl))
	 (ext-db (gnode-db gnode))
	 num-submed-lst)
    (if (null depth)
	(setq depth _MAXINT_))
    ; get the number of MDB predicates (in ext-db) for each MDB predicate in 'gnode'.
    (setq num-submed-lst (mapcar
			  (f/l (fno)
			       (let ((db (proxy-database fno)))
				 (assert (eq db ext-db) "Predicate in gnode from a diferent db")
				 (length
				  (remote-eval `(mdb-preds-deep , fno , depth) db))))
			  ext-preds))
    ; return the total number of MDB predicates in ext-db used by this 'gnode'
    (apply #'+ num-submed-lst)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DSVE budget distribution policy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun budget-distr-proportional (budget graph gnode-statfn)
  "Distribute 'budget' between the nodes in 'graph' proportionally to 
   their weight.
   The weight of nodes is calculated by the function 'gnode-statfn'.
   If: - Bi is the budget of node 'i'
       - Wi is the weight of node 'i'
       - n is the number of nodes in the graph
   Then: Bi = budget * (Wi / sum(Wi,1,n))
   Return a list: ((gnode node-budget) ...)"
  (let* ((total-weight 0.0)
	 weights distr)
    (setq weights (mapcar (f/l (node)
			       (let ((weight (funcall gnode-statfn node)))
				 (setq total-weight (+ weight total-weight))
				 weight))
			  graph))
    (setq distr
	  (mapcar (f/l (gnode weight)
		       (let (node-budget)
			 (if (> total-weight 0)
			     (setq node-budget (round (/ (* budget weight) 
							 total-weight)))
			   (setq node-budget 0))
			 (list gnode node-budget)))
		  graph weights))
    (assert (= (apply '+ (mapcar (function second) distr)) budget) 
	    "Incorrect budget distribution")
    ;;(formatl t "dsve-tnsm: init-budget = " budget " 
    ;; total weight = " total-weight
    ;;     t "weights: " weights
    ;;    t "distrib: " (mapcar 'second distr) t)
    distr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(quote
;dsve-tnsm: 
(setq budget 3)
(setq total-weight 44.0)
(setq weights '(4 6 6 6 16 6))
;distrib = (0 1 1 1 1)

(defun distribute-prop (budget weights)
  (mapcar (f/l (weight)
	       (let (node-budget)
		 (if (> total-weight 0)
		     (setq node-budget (roundto (/ (* budget weight) total-weight) 2))
		     (setq node-budget 0))
		 node-budget))
	  weights))
(distribute-prop budget weights)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun budget-distr-even (budget graph gnode-statfn)
  "Distribute 'budget' as evenely as possible between all the nodes in 'graph'.
   Return:
   - if expandable-nodes > 0: ((gnode node-budget node-index) ...)
   - o/w: NIL"
  (let* ((total-nodes 0)
	 (expandable-nodes 0)		; nodes with weight > 0
	 weighted-graph sorted-by-weight budget-lst 
	 budgeted-graph sorted-by-index)

    ;; generate triples (gnode weight index).
    ;; 'index' is needed to preserve the ordering of the nodes.
    (setq weighted-graph 
	  (mapcar (f/l (node)
		       (let ((weight (funcall gnode-statfn node)))
			 (1++ total-nodes)
			 (if (> weight 0)
			     (1++ expandable-nodes))
			 (list node weight total-nodes)))
		  graph))
    ;; if no nodes are to be expanded return NIL, 
    ;; otherwise generate a node distribution
    (cond ((= expandable-nodes 0) NIL)
	  (t
	   (assert (> expandable-nodes 0) 
		   "Negative number of expandable nodes")
	   ;; sort the indexed nodes by decreasing weight
	   (setq sorted-by-weight 
		 (sort weighted-graph
		       (f/l (n1 n2) (> (second n1) (second n2)))))
	   (setq budget-lst (distribute-evenly budget expandable-nodes))
	   ;; pad the budget list with 0s, to contain 
           ;; same number of elements as graph
	   (setq budget-lst 
		 (append budget-lst 
			 (buildn (- total-nodes expandable-nodes) 0)))

	   (setq budgeted-graph (mapcar (f/l (n b) 
					     (list (first n) b (third n)))
					sorted-by-weight budget-lst))
           ;; restore the original order of the nodes using their indeces
           ;; I don't know if order of the nodes is important at this point, 
           ;; so restore it
	   (setq sorted-by-index 
		 (sort budgeted-graph
		       (f/l (n1 n2) (< (third n1) (third n2)))))

	   (assert (= (apply '+ (mapcar (function second) sorted-by-index)) 
		      budget)
		   "Incorrect budget distribution")
	   ;;(formatl t "budget-distr-even: init-budget = " budget
	   ;;    t "distrib: " (mapcar 'second sorted-by-index) t)

	   sorted-by-index))))

(defun distribute-evenly (m n)
  "Distribute M elements in N buckets, so that the number of elements in each
   bucket differs by no more than 1. It holds true that: 
      m = k1*(a + 1) + k2*a
      n = k1 + k2
   Returns a list containig the distribution."
  (assert (and (integerp m) (integerp n)) "Non-integer input.")
  (let* ((a (/ m n))
	 (k1 (- m (* n a)))
	 (k2 (- (* n (+ 1 a)) m))
	 (big (buildn k1 (+ a 1)))
	 (small (buildn k2 a)))
    (append big small)))
