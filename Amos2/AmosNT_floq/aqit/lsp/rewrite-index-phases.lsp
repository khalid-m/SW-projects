;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: rewrite-index-phases.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/01/17 16:10:32 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Multi-phases of rewriting distance-based-index
;;; =============================================================
;;; $Log: rewrite-index-phases.lsp,v $
;;; Revision 1.2  2012/01/17 16:10:32  thatr500
;;; renamed variable _spatial-indexes_ to _aqit-supported-indexes_
;;;
;;; Revision 1.1  2011/11/15 09:59:47  thatr500
;;; Multi-phases in rewritting with indexes
;;;
;;; Revision 1.2  2011/11/11 08:38:41  thatr500
;;; substitute dt in other predicates
;;;
;;; Revision 1.1  2011/11/09 11:12:18  thatr500
;;; Multi-phases of rewriting distance based index
;;;
;;;
;;; =============================================================

;;-------------------------------------------------------------------------------
;; Phase 1 : Filtering 
;;-------------------------------------------------------------------------------
(defun index-filtering (dpcall this xind compcall rest)
";; Replacing distance computation call (dpcall) and inequality call (compcall)
 ;; by the corresponding AccessMethod enhanced by indexing structure. By doing that 
 ;; a small set of object : candidate object are retrieved.
 ;;-------------------------------------------------------------------------------
  "
 (let* ((ca (dt_genvar _vector_)) ;; candidate index recodrds
	 (dt (dt_genvar _vector_)) ;; distance from candidate object to search obj
	 ;; list of candidate (indexed_point-object)
	 (indexed_point-objects (dt_genvar _vector_)) 
	 (given_point (find-given-point dpcall this))
	 candidate_point
	 ;; AM function
	 (amfn (get-amfn (index-type xind) (car dpcall)))
	 
	 rewpred    ;; rewritten predicate
	 (id-at-runtime (= (getarity amfn) 4))
	 (dist-bnd (= (getwidth amfn) 2)))
   (setq rest (remove  dpcall rest))
   (setq rest (remove  compcall rest))
   ;; Rewpred is one of the following cases
   ;; AMfn ( Index pos, Function, given object, distance)-> objects
   ;; AMfn ( Index pos, Function, given object, distance)-> <objects, distance to given objects>
   ;; AMfn ( Index identifier, given object, distance)-> <objects, distance to given objects>
   ;; AMfn ( Index identifier, given object, distance)-> objects
   (setq rewpred (list amfn))
   (setq rewpred 
	 (cond (id-at-runtime
		(append rewpred
			(list (index-pos xind) ;; Index position
			      (nth 0 this))))  ;; funtion
	       (t (append 
		   rewpred (list 	
			    (get-index-identifier0 
			     (index-pos xind)
			     (nth 0 this)))))))
   ;; Input : - given object
   ;;         - range distance
   (setq rewpred (append rewpred 
			 (list given_point
			       (third compcall))))
   ;; Output : Candidate index records
   (setq rewpred (append rewpred (list ca)))
   ;; Output : distance from candiate objects to given object.
   (setq rewpred (cond (dist-bnd 
			(append rewpred (list dt)))
		       (t rewpred)))
   
   (setq rest (append rest (list rewpred)))	
   ;; ca is candidate index records , dt is distance
   ;; - Unique index
   ;;    ca is an array #(object, point)
   ;;    ==> indexed_point-objects is list (object, point)
   ;; - Multiple  index
   ;;    ca is a list of #(object1, point1) #(object2, point2) #(object3, point3)
   ;;    ==> indexed_point-objects is a list of (object, point) ????
   (setq candidate_point (dt_genvar (type_of_var given_point *bindings*)))
   (setq rest (append rest 
		      (list 
		       (list _extract_keyvalue_fn_ ca
			     indexed_point-objects candidate_point))))
		    
   (setq rest (append rest (list 
			    (list* _vector-constructor_  indexed_point-objects	   
				   (cdr this)))))
   (list rest candidate_point dt dist-bnd)))

;;-----------------------------------------------------------------
;; Phase 2 : Refinement 
;;-----------------------------------------------------------------
(defun index-refinement (dpcall compcall given_point candidate_point dt dist-bnd rest)
"
;; Fully refine each candidate object
;; - 2.1 Its actual distance to the search object makes the inequality holds
;; - 2.2 Strictly inequality
;; AM always implies non-strictly inequality. 
;; Therefore a test 'NOT EQUAL' is added if the original inequalit is 
;; strictly inequality
;;       
;;--------------------------------------------------------------------
"
(let* (vardist refine-dpcall    ;; distance computation call for Refinement phase
	       r                ;; r parameter. It is a parameter of Minkowski
	       refine-compcall  ;; inequality call for Refinement phase
	       )
  ;; 2.1
  (setq vardist (dt_genvar _number_))
  ;; Refine-dpcall
  ;; 0 distance function 
  ;; 1 given point
  ;; 2 candidate point
  ;; 3 distance computation
  (setq refine-dpcall  (list (car dpcall)  given_point candidate_point  vardist))
  ;; r is parameter of Minkowski metric
  (setq r  (cond ((= 5 (length dpcall)) (nth 3 dpcall))))
  (if (neq r nil) (setq refine-dpcall (insert-after refine-dpcall 2 r)))
  (setq rest (append rest (list refine-dpcall)))
  ;; Refine-compcall
  ;; 0 comparision function 
  ;; 1 distance from given point to candidate point
  ;; 2 thresold distance 'epsilon'
  (setq refine-compcall (list (car compcall) vardist (third compcall)))
  (setq rest (append rest (list refine-compcall)))

  ;;2.2------------------------------------------------------------------
  (if (and dist-bnd (eq (generic-fnname (car compcall)) '<))
      (setq rest (append rest (list  
			       (list _notequal_ dt 
				     (third compcall))))))
  rest
  ))
;;------------------------------------------------------------------------
;; Phase 3 : Synchronization
;;-------------------------------------------------------------------------
(defun indexing-synchronization (distance-compcalls compcall list-other-compcall 
						    dpcall compcall dt dist-bnd rest)
 ";; Other predicates using distance are substitued by distance returned from 
  ;;  AM call 
  ;;---------------------------------------------------------------------------
 "
 (let* (tmp)
   (cond (dist-bnd
	  (setq distance-compcalls 
		(remove compcall distance-compcalls))
	  ;; Process two lists in the same fashion
	  (setq distance-compcalls 
		(append2 distance-compcalls list-other-compcall))
	  
	  ;; Retract all of them since they are no longer valid
	  ;; That is because of the replacement dpcall,compcall
	  ;; by AM
	  (dolist (comp distance-compcalls) 
	    (setq rest (remove comp rest)))
	  
	  (if (and (neq distance-compcalls nil) 
		   (listp distance-compcalls))
	      (setf distance-compcalls 
		    (subst dt (fourth dpcall) 
			   distance-compcalls)))

	  ;; Thanh Nov 10th 2011
	  ;; Applying synchronization on other predicate
	  (if (and (neq rest nil) 
		   (listp rest))
	      (setf rest (subst dt (fourth dpcall)  rest)))

	  ;;Adds new compcalls to maintain the same semantic
	  (if (neq distance-compcalls nil)
	      (dolist (comp distance-compcalls) 
		(setq rest (append rest (list comp)))))

	  ))
   rest))