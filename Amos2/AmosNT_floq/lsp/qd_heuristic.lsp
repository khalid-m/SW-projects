;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_heuristic.lsp,v $
;;; $Revision: 1.11 $ $Date: 2003/05/20 05:35:40 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: predicate grouping before the cost based decomposition
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graph generation and grouping of the predicates. Entry function: group_graph
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun group_graph (grph)
  "Produce grouped graph from the inital graph.
   Entry funcion for this stage."
  (let (result)
    (while grph
      (let* ((new_group (mk_group grph))
	     (ng_predl (gNode-predl new_group)))
	(setq grph (mapfilter (f/l (n) 
				   (not (memq (car (gNode-predl n)) ng_predl)))
			      grph))
	(setq result (cons new_group result))))
    result))

(defun mk_graph_p (pred)
  "Make a graph node of a single predicate."
  (let* ((vars (mapfilter (f/l (x) (and  (symbolp x) (not (equal x 'TRUE)))) (cdr pred)))
	 (params  (intersection vars *query_argl*)))
	 ;(OKpred (mapcar (function maptransientF) pred)))
  (make-gNode :db (db_pred pred)
	      :predl (list pred)
	      :vars vars
	      :params params
	      :paramtypes (mapcar (f/l (v) (type_of_var v *bindings*)) params)
	      )))

(defun maptransientF (e)
  (if (transientp e)
      (gnode-fno (tNode-sae (selectbody-decomptree (getobject e 'selectbody))))
      e))

(defun db_pred (p)
  "Given a predicate find the db of origin or 'DISP if it is displaceable"
  (cond ((eq (car p) _typesof_)
	 (if (extern_obj? (third p))
	     (third (third p))
	     (if (proxytype? (third p))
		 (proxytype-origin (third p))
	       'LOCAL)))
	((eq (car p) _makebag_)
	 (let* ((tfn (second p))
                (sb (getselectbody tfn))
		(dtree (and sb (selectbody-decomptree sb)))
	       ; TODO: is this a true assumption?
	       ; DTREE can be either a TNODE struct, or a disjuncion of TNODEs:
	       ; (OR tnode1 tdnode2 ...)
	       ; Is the OR because of late binding over derived types?
		(onlysae
		 (flet ((only-sae (dtree)
				  (and (not (tNode-mbl dtree))
				       (not (tNode-ppl dtree)))))
		   (and dtree
			(cond
			 ((tnode-p dtree) (only-sae dtree))
			 ((and (listp dtree) (eq (car dtree) 'OR))
			  (some #'only-sae (cdr dtree)))
			 (t
			  (assert NIL "illegal head in dtree list"))
			 )))))
	   (if onlysae 
	       (gNode-db (tNode-sae dtree))
	     'LOCAL)))

	((extern_obj? (car p))
         (third (car p)))
       
	(t (if (proxyfunc? (car p))
	       (proxyfunc-origin (car p))
	     (if (displaceable? (car p))
		 'DISP
	       'LOCAL)))))

(defun extern_obj? (h)
 (and (listp h) (eq external_marker (car h))))

(defun mk_group (grph)
  "Group the nodes connected to the first node in the graph."
  (let* ((node (car grph))
	 (db (gNode-db node))
	 (vars (gNode-vars node))
	 (predl (gNode-predl node))
	 (params (gNode-params node))
	 (notIn (mapfilter (f/l (x) (eq db (gNode-db x))) (cdr grph)))
	 (changeFlag t)
	 paramtypes)
    (while changeFlag
      (let ((toCheck notIn))
	(setq notIn nil)
	(setq changeFlag nil)
	(dolist (n toCheck)
	  (cond ((intersection (gNode-vars n) vars)
		 (setq vars (op_union vars (gNode-vars n)))
		 (setq predl (append predl (gNode-predl n)))
		 (setq changeFlag t)
		 (setq params (op_union params (gNode-params n))))
		(t
		 (setq notIn (cons n notIn)))))))
    (make-gNode :db db
		:predl predl
		:vars vars 
		:params params
		:paramtypes (mapcar (f/l (v) (type_of_var v *bindings*))
				    params)
		)))

(defun op_union (l1 l2)
  "Order preserving union"
  (unique (append l1 l2)))