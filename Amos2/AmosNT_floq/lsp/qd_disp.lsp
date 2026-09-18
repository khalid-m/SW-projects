;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_disp.lsp,v $
;;; $Revision: 1.14 $ $Date: 2008/04/03 15:00:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: displaceable predicate detection, definition and placing
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Displacable function registration 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;lots of work lay in imoroving this!!!!!
(defglobal _odbc_rank_ 1)
(defglobal _proxy_rank_ 2)
(defglobal _displaceable-fns_ nil) ; list of pairs: ((fno . rank) ...)


(defun source_type_rank (s)
  (cond ((equal s 'odbc) _odbc_rank_)
	((equal s 'proxy) _proxy_rank_)
	(t 0)))

(defun displaceable? (fn) 
  (if (not (listp fn))
      (cdr (assoc (generic-function-of fn) _displaceable-fns_))))

(defun make_displaceable (fname  rank)
  (setq _displaceable-fns_ (cons (cons (getfunctionnamed fname) rank)
				 _displaceable-fns_)))

(defun register_as_displaceable ()
  "Registers all the displaceable functions."
  ; TODO: to add arithmetic and other functions the OSQL to SQL
  ; translator must be extended to generate the correct SQL
  (let ((odbc_dsp_fns '(< > = >= <=))
	(proxy_dsp_fns '(atrue notany count sum in plus minus times)))
    (mapcar (f/l (f) (make_displaceable f _odbc_rank_))  odbc_dsp_fns)
    (mapcar (f/l (f) (make_displaceable f _proxy_rank_)) proxy_dsp_fns)))

(defun unregister_as_displaceable (fnname)
  (let* ((fno (generic-function-of (getfunctionnamed fnname t)))
	 (disp (assoc fno _displaceable-fns_)))
    (delete disp _displaceable-fns_)))

(defun prune_sources (rank sourcel)
  (mapfilter (f/l (db) (not (< (source_type_rank (sourcetype? db)) rank)))
	     sourcel))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displaceable predicate groups  move around
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun place_disp_groups (graph predl)
  "Assign a db for each displaceable graph nodes. Cost-based because it calls
   'get_cost' through:
   collect_disp_vars -> producer_dbs_var -> freeVarPosition -> get_cost"
  (let* ((v_db (collect_disp_vars predl))
	 (disp_groups (mapfilter (f/l (n) (eq (gNode-db n) 'DISP)) graph))
	 (Ndisp_groups (set-difference graph disp_groups))
	 (ndg_vars (unionl (mapcar (function gNode-vars) Ndisp_groups)))
	 (ndg_dbs  (union (mapcar (function gNode-db) Ndisp_groups)))
	 new_groups)
					;(bp DAG)
    (dolist (Dg disp_groups)
      (setq new_groups (append (place_single_group Dg v_db ndg_vars ndg_dbs) 
			       new_groups)))
    (group_graph (append new_groups Ndisp_groups))))

(defun place_single_group (DgNode v_db ndgVars ndgDBs)
  "Place a displaceable group (node) at one or more dbs."
  (let* ((locals (set-difference (gNode-vars DgNode) ndgVars))
	 (nonLocals (set-difference (gNode-vars DGNode) locals))
	 (nVars (gNode-vars DgNode))
	 (params (gNode-params DgNode))
	 (paramtypes (gNode-paramTypes DgNode))
	 (groupRank (car (sort
			  (mapcar (f/l (pr) (displaceable? (car pr))) 
				  (gNode-predl DgNode))
			  (function >))))
 	;node_vars: non-local vars from this node
	 (node_vars  (mapfilter (f/l (vdbe) 
				     (memq (car vdbe) nVars))
				v_db))
	 (common_dbs0 (intersectionL (mapfilter 
				      (function second) 
				      node_vars
				      (function second))))

	 ;The group can be sent only to sources of equal or greater rank
	 ;this are the sources with capabilities to handle this group
	 (common_dbs1 (prune_sources groupRank common_dbs0))
	 ;put 'LOCAL first if it is the list
	 (common_dbs (if (memq 'LOCAL common_dbs1)
			 (cons 'LOCAL (remove 'LOCAL common_dbs1))
		       common_dbs1))
	 (union_of_dbs0 (unionL (getvars node_vars)))
	 (union_of_dbs (prune_sources groupRank union_of_dbs0))
	 (predl (gNode-predl DgNode)))
    (if (not union_of_dbs) ;(amos-error "unconnected query subgraph"))
	(setq union_of_dbs  
	      (if (or (not  ndgDBs) 
		      (memq 'LOCAL ndgDBs)
		      (subsetp (heads node_vars)
			       (append *query_argl* *query_resl*))
		      (every (f/l (s) (not (equal 'proxy (sourcetype? s)))) 
			     ndgDBs))
		  '(LOCAL)
		(list (car (mapfilter (f/l (s) (equal 'proxy (sourcetype? s)))
					   ndgDBs))))))
    ;(bp place_DG)

    ;if there is one or more dbs that produce all non-local vars in
    ;the group then this group goes to each of them 
    (if common_dbs
	(cons
	;one of the replicas will keep the  the original variables
	;for the case when they are in the query result.
	;If 'LOCAL is in the list of dbs than this replica is at 'LOCAL
	;otherwise the first db in the list
	 (make-gNode :db (car common_dbs)
		     :predl (gNode-predl DgNode) 
		     :vars (gNode-vars DgNode) 
		     :params params
		     :paramtypes paramTypes)
	 (mapcar (f/l (db) 
		      (replicate_disp_group predl db locals 
					    nonLocals params paramtypes))
		 (cdr common_dbs)))

      ;no common database: pick the first one
      ;this needs to be changed temporary and possibly generates bad plans. 
      ;If the group vars contain one of the input variables
      ;than the optimizer avoids executing this group at the local db
      ;because it is cheap to ship only single input value (the if below).
      (let ((tdb (if (and (eq (car union_of_dbs) 'LOCAL)
			  (cdr union_of_dbs);more than one db 
			  (intersection nvars *query_argl*))
		     (second union_of_dbs)
		   (first  union_of_dbs))))
	(list (make-gNode :db tdb
			  :predl (gNode-predl DgNode) 
			  :vars (gNode-vars DgNode)
			  :params params
			  :paramtypes paramTypes))))))


(defun replicate_disp_group (predl db locals nonLocals params paramtypes)
  "Create a copy of a diplaceable group and generate new locals"
  (let* ((newLocals (mapcar (f/l (v) (dt_genvar (type_of_var v *bindings*))) 
			    locals))
	 (substl (append (pair locals newLocals) 
			 (pair nonLocals nonLocals))))
    (make-gNode :db db
		:vars (append nonLocals newLocals)
		:predl (expand-predicate (andify predl) substl)
		:params params
		:paramtypes paramtypes)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displaceable predicates move around (2): 
; for each var in which dbs can it be produced
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun collect_disp_vars (predl)
  "Returns a list of all variables used in the displaceable predicates
   and for each a database list in which this variables can be given
   values (appear on a non-bound position in a predicate)
   This will  need to be changed to work for the non DNF from and use
   the functions for extracting vars from predicates."
  (let* ((vars (unionl 
		(mapfilter
		 (f/l (p) (displaceable? (car p)))
		 predl
		 (f/l (p) (mapfilter (function symbolp) p)))))
	 (nd_predl (mapfilter (f/l (p) (not (displaceable? (car p)))) predl)))
    (mapcar (f/l (v) (let ((vpredl (mapfilter (f/l (p) (memq v p)) nd_predl)))
		       (list v (producer_dbs_var v vpredl)))) 
	    vars)))

(defun producer_dbs_var (v predl)
  "For a single variable finds the databases where this variable can appear
   free in a predicate."
  (let (dbs)
    (dolist (p predl)
	    (let ((p_db (db_pred p)))
	      (if (and (not (memq p_db dbs))
		       (some (f/l (pos) 
				  (freeVarPosition pos 
						   (car p)
						   p_db
						   (1- (length p))))
			     (positions v (cdr p))))
		  (setq dbs (cons p_db dbs)))))
    dbs))

(defun freeVarPosition (pos fn db nargs)
  "Cost of a function wih bpat which has all bonud except the one at position pos."
  (let* ((bpat (append (buildn (1- pos) '-)
		       (cons '+ (buildn (- nargs pos) '-)))))
    (if (get_cost fn bpat db) t)))

(defun positions (v pred)
  "Given an element and a list returns the postions at which
   this el appears in the list."
  (positions1 v pred 1 nil))

(defun positions1 (v pred n res)
  (if pred
      (if (eq v (car pred)) 
	  (positions1 v (cdr pred) (+ n 1) (cons n res))
	(positions1 v (cdr pred) (+ n 1) res))
    res))

