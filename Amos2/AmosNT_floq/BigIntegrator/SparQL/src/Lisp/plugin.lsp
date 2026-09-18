;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> 2012 <author>Minpeng Zhu, UDBL
;;; $RCSfile: plugin.lsp,v $
;;; $Revision: 1.11 $ $Date: 2012/08/08 08:34:44 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: define absorber and finalizer for sparql wrapper.
;;; =============================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;SparQL absorber;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun absorb-sparql (pred preds ds env)
  "Do fixed point iteration to absorb the source predicates,e.g equal join
   or thetha join source predicate, and absorb the non-source predicates."
  (let* ((change t)
	 (joinvarlist (mapfilter (f/l (arg) (osql-variablep arg))  
				 (predicate-arguments pred)))
	 (newrest preds)
	 (unabsorbedpreds (tconc))
	 (absorbedSPs (tconc))
	 (absorbedNSPs (tconc))
	 (abslist (mapcar (f/l (l) (list (getobject (car l) 'name)))
			  (get-absorbability ds)));;absorbability list of a ds
	 )
    (update-environment pred env);;update pred into env
    (while change
      (setq unabsorbedpreds (tconc))
      (setq change nil)
      (dolist (opred preds)
	(cond ((compound-p opred))
	      (t 
	       (update-environment opred env)   
	       (cond ((sourcepred? (predicate-operator opred))
		      (cond ((absorbSPp ds joinvarlist opred env 
					(append (car absorbedSPs)
						(car absorbedNSPs)))
			     (setq joinvarlist (append joinvarlist
						      (remove '* (cdr opred))))
			     (tconc absorbedSPs opred);;absorb equal join SP
			     ;;remove absorbed source predicate
			     (setq newrest (remove opred newrest))
			     (setq change t))
			    (t (tconc unabsorbedpreds opred))))
		     (t;;non source predicates
		      (let* ((op (predicate-operator opred))	     
			     (opname (getobject op 'name)))
			(if (member (list opname) abslist);;op in absorbability
			    (cond ((nonnuminferable-p opred joinvarlist
						      (append (car absorbedSPs)
							      (car absorbedNSPs))) 
				   ;;pred has varlist (< V8 30000)
				   (tconc _absorbedPreds_ opred)
				   (tconc absorbedNSPs opred)
				   (setq change t))
				  (t (tconc unabsorbedpreds opred)))
			  (tconc unabsorbedpreds opred))))))))
      (setq preds (car unabsorbedpreds))) 
    (setf (gethash 'accessfiltervarlist env) (unique joinvarlist)) 
    (list (append (list pred)(car absorbedSPs)(car absorbedNSPs)) newrest)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;SparQL finalizer;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun translate-sparql (ds queryinfo filtervarlist)  
  "Each wrapper has a finalizer, which is a plug-in that translates 
   each access filter in the plan to an algebra operator called an 
   interface function, specific for each kind of source. The interface 
   function sends a query to the data source (i.e. a SparQL query)."
  (let (sparql-algebra-op sparqlquery queryfn
			  )
    (setq sparqlquery (create-query-string queryinfo))
    (setq queryfn (create-amos-query-function ds sparqlquery queryinfo))
    (when (sq-outvars queryinfo)
      (declarecosts queryfn '*any* 'sparql_cost)
      (setq sparql-algebra-op 
	    `((,_apply_pred_ ,queryfn ,@(sq-invars queryinfo)
			     ,@(sq-outvars queryinfo)))))
    ))

