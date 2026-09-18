;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_dynprog.lsp,v $
;;; $Revision: 1.15 $ $Date: 2006/04/12 19:17:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: cost based phase of the query decomposition
;;; =============================================================
;;; $Log: qd_dynprog.lsp,v $
;;; Revision 1.15  2006/04/12 19:17:45  torer
;;; Cost profile of predicate now always on format (COST FANOUT [pred])
;;;
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decomposition tree generation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun cost_based_decomposition (graph)
  (let* ((*var_types* (pair_var_types graph))
	 sn)
    (setq sn (mdb_dynprogsort graph))
    (fix_func_bodies sn)
    (fix_ppl_bpats  sn)			; uses tnode-rem
    ;; free all the 'rem' lists
    ;; TODO: does this make a difference?
    (map-dtree sn (f/l (tn) (setf (tnode-rem tn) nil)) nil)
    sn))

(defun mdb_dynprogsort (l)
  "Exaustive generation of decomposition trees."
  (if l
      (let ((plan-table (maketbl))
	    (iteration 1)
	    (empty-plan (make-tNode :rem l :cost 0))
	    lowest-cost bestplans res)
	 (printopt t "MDB predicates to optimize: "
		     (with-string str (gnpl l str))
		     "Number of preds: " (length l) t t)
	(puttbl plan-table 0 empty-plan)
	(while t 
	  ; do not use plan pruning - very inefficient, see comment at EOF
	  ; (setq plan-table (prune_plans plan-table))
	  (if (empty-tbl-p plan-table)
	      (non-exec-error l ))      
	  (printopt "MDB iter " iteration ": " (tbl-stat plan-table 3) t)
	  (setq lowest-cost (get-lowest-cost plan-table)) ; lowest cost so far - O(1)
	  (setq bestplans (pop-cheapest-plans plan-table)) ; corresponding plans - O(lg n)
	  ; find the first complete plan with lowest cost
	  (setq res (isome bestplans (f/l (plan) (null (tNode-rem plan))))) ; - O(n)
	  (cond (res
		 (setq res (car res)) ; the first elem of 'res' is a complete plan
		 (printopt t "MDB Optimal plan: " t (with-string str (tnp res str)) 
			     "cost: " lowest-cost t)
		 (printopt "MDB stats: " (tbl-stat plan-table 4) t t)
		 (return res)))
	  ; for each of the partial plans with the best cost
	  (dolist (partial-plan bestplans)
	    ; for each remaining group of predicates
	    (dolist (group (tNode-rem partial-plan))
	      ; generate a new plan
	      (if (is-useful-group group partial-plan)
		  (let ((new-rem (removeeq group (tNode-rem partial-plan)))
			new-plan)
		    ; Generate a new plan by adding one more node to it.
		    ; Because only single nodes are added to the plan tree we get only
		    ; left-deep plans. Other strategies may be used here, e.g. combine
		    ; sub-plans, possibly in several ways to produce more than one new plan.
		    (setq new-plan
			  (if (is-local-group group)
			      ; dyn. prog. -  O(2^num_ppl_groups_max)
			      (add-ppn group partial-plan new-rem)
			      ; ranksort   -  O(num_preds_group_max^2)
			      (add-sae group partial-plan new-rem)))
		    (if new-plan ; add each new plan to the plan table
			(puttbl plan-table (tNode-cost new-plan) new-plan)))))) ; O(lg n)
	  (1++ iteration)
	  ))))

(defglobal _MDB_PRUNE_CROSS_PRODUCTS_ nil) ; if 'T' regression test fails
; because this pruning rules out cases when a cross-product is the only
; executable plan

(defun is-useful-group (group tree)
  "Pruning heuristic, e.g. cross-product avoidance"
  (if _MDB_PRUNE_CROSS_PRODUCTS_   ; Filter cross-products
      (or (null (tNode-res tree)) ; tree root
	  (intersection (gNode-vars group) (tNode-res tree)) ; common vars
	  (intersection (gNode-params group) ; common parameters
			(tNode-params tree))
	  ; TODO: the case when the only possible plan must have 
	  ; a cross-product is not handled
	  )
      T  ; by default every group is useful
      ))

(defun is-local-group (group)
  (or (eq (gNode-db group) 'LOCAL)
      (eq (sourcetype? (gNode-db group)) 'odbc)))

(defun add-ppn (group tree rem)
  "Add a single PP group to the PPL of 'tree' root node. The PPL always
   consists of exactly one group. The reason to keep PPLs is for compatibility
   with other optimizer phases (code gen., and tree rebalancing). Rules:
   - if the plan tree is empty, create a new plan node with 'group' as PPL
   - if the root plan node has an SAE, then add 'group' to the same plan node"
  (let ((root-sae (tnode-sae tree))
	(root-sae-vars NIL)
	pp-node children-list)
    (cond ((tnode-ppl tree)
	   (setq children-list (list tree)))
	  (root-sae
	   (setq root-sae-vars (gNode-vars root-sae))
	   (setq children-list (tnode-mbl tree)))
	  (t
	   (setq children-list NIL)))
    ; create an executable node out of 'group'
    (setq pp-node (make-executable-node group
					root-sae-vars
					children-list))
    (if pp-node
	(new-root-node children-list
		       root-sae
		       (list pp-node)
		       (gnode-cost pp-node)
		       rem))))

(defun add-sae (group tree rem)
  "Add a new sae group."
  (let (sae-node children-list)
    (if (or (tNode-ppl tree) (tNode-sae tree))
	(setq children-list (list tree))
        (setq children-list NIL)) ; nil (empty) tree
    ; create an executable node out of 'group'
    (setq sae-node (make-executable-node group
					 NIL
					 children-list))
    (if sae-node
	(new-root-node children-list
		       sae-node
		       NIL ; no PPL
		       NIL ; no PPL
		       rem))))

(defun make-executable-node (group root-sae-vars root-mbl)
  "Create a new node that is executable when added at the top of the plan-tree.
   O(num_preds_group^2) - when using ranksort for cost estimates."
  (let* ((gVars (gNode-vars group))
	 (db    (gNode-db group))
	 (fno   (gNode-fno group))
         ; true if pp group?:
	 ;(gVars (reorder_sae_vars gVars1 (tNode-mbl tree) saeOrpp))
	 ;(gVartypes (mapcar (f/l (v) (tree_var_type v  is_ppn)) gVars))
	 (pinVars (unionl 
		   (list (gNode-params group)
			 root-sae-vars
			 (unionl (mapcar #'tNode-res root-mbl)))))
	 (bpat-vars (mapcar (f/l (v) (if (memq v pinVars) '- '+)) gvars))
	 (bpat (padd bpat-vars (length (gNode-params group)) '-))
	 ; TODO: this call can be saved by caching the cost_fanout on the proxy
	 ; func. obj. instead on the original function object as it is now
	 ; recompile fno (using ranksort) with this bpat
	 (cost_fanout (get_cost fno bpat db))) ; O(num_preds_group^2)
    (if cost_fanout
	(make-gNode :db db
		    :fno fno 
		    :predl (gNode-predl group)
		    :vars gVars
		    :vartypes (gNode-vartypes group)
		    :params (gNode-params group)
		    :paramtypes (gNode-paramtypes group)
		    :bpat bpat
		    :cost (first cost_fanout)
		    :fanout (second cost_fanout)))))

(defun new-root-node (new-mbl Nsae Nppl NpplCost rem)
  "Create a new root plan tree node and add an SAE or PPL to it.
   One of 'sae' or 'ppl' must be NIL.
   O(x^2) - contains only polynomial algorithms."
  (let ((newTreeNode (make-tNode
		      :mbl new-mbl
		      :sae Nsae  
		      :ppl Nppl
		      :pplCost NpplCost
		      :db 'LOCAL ; currently each plan node can be computed
		                 ; only in the local db
		      :rem rem)))
    (setf (tNode-fanout newTreeNode) (get_tNode_fanout newTreeNode))
    (setf (tNode-cost   newTreeNode) (get_tNode_cost   newTreeNode))
    (setf (tNode-res    newTreeNode) (get_tNode_res    newTreeNode)) ; uses tnode-rem
    (setf (tNode-params newTreeNode) 
	  (union 
	   (union
	    (unionl (mapcar #'tNode-params (tNode-mbl NewTreeNode)))
	    (and Nsae (gNode-params Nsae)))
	   (unionl (mapcar #'gNode-params Nppl))))
    (setf (tNode-paramtypes newTreeNode)
	  (mapcar (f/l (v) (type_of_var v *bindings*))
		  (tNode-params newTreeNode)))
    (setf (tNode-restypes newTreeNode) 
	  (mapcar (f/l (v) (tree_var_type v T))
		  (tNode-res newTreeNode))) 
    newTreeNode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Manual generation of MDB plans. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Does not work (TR)
(quote
(defun mdb-manual-sort (grp-lst)
  "Generate an MDB plan where all plan nodes are ordered according to their
   order in 'grp-lst'."
  (if grp-lst
      (let* ((empty-plan (make-tNode :rem grp-lst :db 'LOCAL :cost 0))
	     (curr-plan (add_to_tree (first grp-lst) empty-plan)))
	(setq grp-lst (cdr grp-lst))
	(while (grp-lst)
	  (setq curr-plan
		(if (is-local-group (car grp-lst))
		    (add-ppn (car grp-lst) curr-plan (cdr grp-lst))
		  (add-sae (car grp-lst) curr-plan (cdr grp-lst))))
	  (setq grp-lst (cdr grp-lst)))
	curr-plan)))

(defun get-fn-db (grp-lst)
  (mapcar (f/l (n) (list (gnode-fno n) (gnode-db n))) grp-lst))

(defun reorder (keys lst)
  (let ((pairs (mapcar (f/l (key el) (list key el))
		       keys lst)))
    (setq pairs
	  (sort pairs (f/l (x y) (< (car x) (car y)))))
    (mapcar 'second pairs)))
)
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disabled code that may still be used in the future
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(quote 
; This optimization procedure is not used because the default plan generation
; strategy is changed not to generate lists of PP nodes. See the comment below
; for function 'add-ppn'.
(defun ppl_dynprogsort (l)
  "Dynamic programing for optimal order of the post processing functions
   in the ppl list. These funcs do not have common in/out vars.
   'plan-table' is priority queue of execution plans where:
    key = cost, value = list of plans with this cost."
  (if l
      (let ((plan-table (maketbl 'pcost-stat))
	    (iteration 1)
	    lowest-cost bestplans res)
	(printopt t "PPL groups to optimize: " t
		  (with-string str (gnpl l str))
		  "Number of groups: " (length l) t)

	(puttbl plan-table 0 (make-pcost :fanout 1 :plan nil :rem l))
	(while t
	  (if (empty-tbl-p plan-table) ;this can never happen here,
	      (amos-error "This should not occure:(not executable. in ppl)" l))
	  (printopt "PPL iter " iteration ": " (tbl-stat plan-table 3) t)
	  (setq lowest-cost (get-lowest-cost plan-table)) ; lowest cost so far - O(1)
	  (setq bestplans (pop-cheapest-plans plan-table)) ; corresponding plans - O(lg n)
	  (setq res (isome bestplans (f/l (plan) (null (pcost-rem plan))))) ; - O(n)
	  (cond (res ; A complete plan with lowest cost was found.
		 (setq res (pcost-plan (car res)))
		 (printopt "PPL optimal plan: " t (with-string str (gnpl res str)) 
			   "cost: " lowest-cost t)
		 (printopt "PPL stats: " (tbl-stat plan-table 4) t t)
		 (return (list lowest-cost res))))
	  (dolist (pc bestplans) ; pc is a partial plan with lowest cost
	    (let ((oldfanout (pcost-fanout pc))
		  (oldrem (pcost-rem pc))
		  (oldplan (pcost-plan pc)))
	      ; 'group' is bound to each PPL group not-yet selected in plan
	      (dolist (group oldrem)
		(let* ((cost (gNode-cost group))
		       (fanout (gNode-fanout group))
		       (new-plan ; new plan entry 
			(make-pcost 
			 :fanout (* fanout oldfanout)
			 :plan (append oldplan (list group))
			 :rem (removeeq group oldrem)))
		       (new-key (+ 0.0 lowest-cost (* oldfanout cost))))
		       ; put extended plan into queue
		  (puttbl plan-table new-key new-plan)))))
	  (1++ iteration)
	  ))))

; This version of add-ppn will create a list of PP nodes and then use the
; dynamic programming algorithm above 'ppl_dynprogsort' to optimize the
; PPL list. This approach the way it is implemented now leads to many
; redundant calls to ppl_dynprogsort because the same PPLs occur more
; than once due to the way the outer dynamic programming generates new
; partial solutions. If we consider two PP nodes, mdb_dynprogsort may
; try to add them twice in different order, which results in the same
; PPL list with different initial order being optimized twice.
(defun add-ppn (group tree rem)
  "Add a PP group to the PPL of 'tree' root node. Rules:
   - if the plan tree is either empty or contains an SAE node
     create a new node with one PP node
   - if the plan tree already has a PPL
     - if the new group is scheduled in the same DB as the nodes in
       the PPL add it to the current PPL
     - if they are from different DBs then create a new plan node
   Comment: this strategy is based on the fact that only groups from
            the same DB are guaranteed to be disconnected. This is
            how the current grouper operates as it treats ODBC and
            other 'local' sources as different databases when it
            comes to grouping."
  (let (new-tree pp-node root-sae root-ppl root-sae-vars children-list)
    (cond ((tNode-ppl tree)
	   ; if this group is scheduled in the same DB as the rest in the PPL
	   (if (equal (gnode-db (car (tnode-ppl tree)))
		      (gnode-db group))
	       ; add to the same root node
	       (setq new-tree tree)
	       ; create a new root node above this one
	       (setq new-tree (make-tNode :mbl (list tree)))
	       ))
	  (t ; nil (empty) tree or root has SAE node
	   ; add to the same node if SAE or create a brand new root without children
	   (setq new-tree tree)))
    (setq children-list (tnode-mbl new-tree))
    (setq root-ppl (tNode-ppl new-tree))
    (setq root-sae (tnode-sae new-tree))
    (setq root-sae-vars (if root-sae (gNode-vars root-sae)))
    ; create an executable node out of 'group'
    (setq pp-node (make-executable-node group
					root-sae-vars
					children-list))
    (if pp-node
	(let* ((new-ppl (cons pp-node root-ppl))
	       (new-ppl-opt (ppl_dynprogsort new-ppl)))
	  (new-root-node children-list
			 root-sae
			 (second new-ppl-opt)
			 (first new-ppl-opt)
			 rem)))))

(defun compare-trees (t1 t2)
  "Compute if two decomposition trees are similiar.
   Used to 'prune' the plan space.
   Note: currently not used, as it is not clear if (and when) there is any
   benefit from this rather expensive pruning."
  (if (equal (tnode-cost t1) (tNode-cost t2)) ;to avoid most of the rest
      (let* ((pt1 (tNode-ppl t1))
	     (pt2 (tNode-ppl t2))
	     (lpt1 (length pt1))
	     (mt1 (tNode-mbl t1))
	     (mt2 (tNode-mbl t2)))
	(and  ;any order is the same
	 (equal (tNode-sae t1) (tNode-sae t2))
	 (eq (length mt1) (length mt2))
	 (eq lpt1 (length pt2))
	 (eq lpt1 (length (mapfilter (f/l (e) (member e pt2)) pt1)))
	 (or (and  (null mt1) (null mt2))
	     (apply (function and) 
		    (mapfilter (f/l (n1) (some (f/l (n2) (comp_trees n1 n2))
					       mt2))
			       mt1)))))))
)
