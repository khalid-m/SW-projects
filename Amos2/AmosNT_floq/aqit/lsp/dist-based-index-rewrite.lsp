;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: dist-based-index-rewrite.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/02/19 05:56:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Distance based index rewrite
;;; =============================================================
;;; $Log: dist-based-index-rewrite.lsp,v $
;;; Revision 1.6  2013/02/19 05:56:51  thatr500
;;; Limited Search with simple Heuristics
;;;
;;; Revision 1.5  2012/02/24 13:55:39  thatr500
;;; removed a redundant argument 'inoutvars'
;;;
;;; Revision 1.4  2012/01/20 17:36:35  thatr500
;;; simplified code + removed hard-wired stuffs
;;;
;;; Revision 1.3  2012/01/17 16:10:32  thatr500
;;; renamed variable _spatial-indexes_ to _aqit-supported-indexes_
;;;
;;; Revision 1.2  2011/12/20 21:17:02  thatr500
;;; reorganized !
;;;
;;; Revision 1.1  2011/11/15 09:57:46  thatr500
;;; Rewrite for distance based indexing
;;;
;;; =============================================================
;;=======================================================================
;; Thanh 27th Nov 2012
;;=======================================================================

(defglobal _euclid_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER)
  "The resolvent euclid(Vector, Vector)->Number")

(defglobal _euclid1D_ 
  (getfunctionnamed 'NUMBER.NUMBER.EUCLID1->NUMBER)
  "The resolvent euclid(Number, Number)->Number")

(defglobal _manhattan_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.MANHATTAN->NUMBER)
  "The resolvent manhattan(Vector, Vector)->Number")

(defglobal _intersection_distance_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.INTERSECTION_DISTANCE->NUMBER)
  "The resolvent intersection distance(Vector, Vector)->Number")

(defglobal _minkowski_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.NUMBER.MINKOWSKI->REAL)
  "The resolvent minkowski(Vector, Vector, Number)->Real")


(defglobal _distance-predicates_ (list _euclid_ _euclid1D_ _manhattan_ _intersection_distance_
				        _minkowski_)
  "List of supported distance preidcates")

(defun dist-starting-pred? (pred)
  (in (first pred) _distance-predicates_))
;;=======================================================================
;; End 27th Nov 2012
;;=======================================================================


;; Debug 'sp-index-rewrite' printting
(defparameter *print-index-rewrite* nil)
;; Enable Algebraic Query Transformation on Inequality
;; Its default value is true

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General index rewriter utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;------------------------------------------------------------------------  
(defglobal _extract_keyvalue_fn_
  (getfunctionnamed 'OBJECT.EXTRACTKEYVALUE->OBJECT.OBJECT)
  "Extract the first vector from the list if possible")
;;-----------------------------------------------------------------------
(defun find-given-point (dpcall this)
  "Distance Predicate V1 V2 
  - case 1 : V1 is a constant, V2 from this --> V1
  - case 2 : V2 is a constant, V1 from this --> V2
  - case 3 : V1 from this, V2 is unknown YES --> V2
  - case 4 : V2 from this, V1 unknown YES -->V2
  - case 5 : V1, V2 not from this --> NIL
 "
  (let* ((v1 (second dpcall))
	 (v2 (third dpcall))
	 (lvars (cdr this))
	 )
    (cond ((and (osql-constantp v1) (in v2 lvars)) v1)
	  ((and (osql-constantp v2) (in v1 lvars)) v2)
	  ((and (in v1 lvars) (not (in v2 lvars))) v2)
	  ((and (in v2 lvars) (not (in v1 lvars))) v1)
	  (t nil))))
;;-----------------------------------------------------------------------
(defun define-index-rewriter (index-kind index-rewritefn)
  "Associate function (index-rewriter this indl rest rw) with all stored
   functions having an index of kind INDEX-KIND.
   THIS: The predicate having the index
   INDL: List if indexes of the kind for THIS
   REST: The other predicates in the conjunction where THIS appeared
   RW: The full rewriter record (see rewrite.txt)"
  (putprop 
   index-kind ;;; The system puts the rewrite rule on all stored functions
              ;;; having index of this kind
   'index-rewriter 
   `(lambda (rw);; put anonymous wrapper function in property 
                ;; INDEX-REWRITER
      (let* ((this (rewrite-this rw));; The called predicate having rule
             (rest (rewrite-rest rw));; The other predicates 
	                             ;; in conjunction 
	     (indl (indexes-of-kind (car this);; get list of index of kind
				    (quote , index-kind) t)))
	(if (and indl rest) (, index-rewritefn this indl
					       ;; call the rewriter
					       rest
					       rw)
	  'substitute)))));; default do nothing 

;;------------------------------------------------------------------------
(defglobal _distance-comparisons_
  (mapcar (function getfunctionnamed)
	  '(object.object.<->boolean object.object.<=->boolean))
  "The comparison pattern that can be rewritten using sp index")
;;------------------------------------------------------------------------
(defglobal _distance-other-comparisons_
  (mapcar (function getfunctionnamed)
	  '(object.object.>->boolean object.object.=->boolean 
				     object.object.>=->boolean  
				     object.object.!=->boolean))
  "The other comparison that cannot be rewritten using sp index")
;;-----------------------------------------------------------------------
(defglobal _notequal_)	; bound to AMOSQL function !=


;;------------------------------------------------------------------------  
(defun multi-phases-to-replace-distance-based-index 
  (this   ;; ?? 
   indxl  ;; list of indexes
   rest   ;; the rest of predicates 
   dpcall ;; distance computation (euclid, minkowski, manhattan)
   )
  (let* ((bnd (cdr this))       ;; list of variables
	 (xind (car indxl))	;;only one AQIT supported index per table supported
	 (pos (index-pos xind)) ;; Position of index in THIS
	 (var (nth pos (cdr this)));; Variable or constant at index position
	 (distance-compcalls ;;calls to comparison with returned value of distance 
	                     ;; predicate
	  (subset rest
		  (f/l (pred) 
		       (and (consp pred)
			    (memq (car pred) _distance-comparisons_)
			    ;;comparison connected to dpcall
			    (intersection (cdr dpcall) (cdr pred))))))
	 ;;pick one of distance-compcalls
         (compcall (car distance-compcalls))
	 (list-other-compcall;;get other comparisions  
	  (subset rest (f/l (pred)
			    (and (consp pred)
				 (memq (car pred) _distance-other-comparisons_)
				 (intersection (cdr dpcall) 
					       ;;comparison connected to dpcall
					       (cdr pred))))))
	 
	 );;end of let

    (cond ((and (not (null dpcall))
		(not (null compcall)))
           (let* (dt ;; xxdistance from candidate object to search ob
		   (given_point (find-given-point dpcall this))
		   candidate_point
		   ;; AM function
		   (amfn (get-amfn (index-type xind) (car dpcall)))
		   dist-bnd   ;; distance is returned ?		   
		   tmp)
	     (cond ((and (neq given_point nil) (neq amfn nil))
		    ;;------------------------------------------------------------------
		    ;; Phase 1 : Filtering (see rewrite-index-phases.lsp)
		    ;;------------------------------------------------------------------
		    (setq tmp (index-filtering dpcall this xind compcall rest))
		    (setq rest (first tmp))
		    (setq candidate_point (second tmp))
		    (setq dt (third tmp))
		    (setq dist-bnd (fourth tmp))
		    
		    ;;-----------------------------------------------------------------
		    ;; Phase 2 : Refinement  (see rewrite-index-phases.lsp) 
		    ;;-----------------------------------------------------------------
		    (setq rest (index-refinement dpcall compcall given_point 
						 candidate_point dt dist-bnd rest)) 
		    ;;-----------------------------------------------------------------
		    ;; Phase 3 : Synchronization  (see rewrite-index-phases.lsp)
		    ;;----------------------------------------------------------------
		    (setq rest (indexing-synchronization distance-compcalls compcall 
							 list-other-compcall 
							 dpcall compcall dt 
							 dist-bnd rest))
		    
		    )))))
    ;; return 'rewritten' conjunction
    rest))
;;--------------------------------------------------------------------------
;; Rewrite distance-based-index  by AM
(defun rewrite-distance-based-index-by-am (this indxl rest)
  (let* ((xind (car indxl)) ;; assume there is one index	      
	 (pos (index-pos xind))       ;; Position of index in THIS
	 (var (nth pos (cdr this)))   ;; Variable or constant at 
	                              ;; index position
         (distpredcalls               ;; calls to distance pred binding indexed 
	  ;; variable in REST 
	   (subset 
	    rest 
	    (f/l (pred)
		 (and (consp pred)    ;; Skip variables in REST
		      (dist-starting-pred? pred)))))

	 newconj ;; to stored rewritten conjunction
	 ;; If more distance computation call  were lately added in 2.1, either its 
	 ;; second param or its third param is computed by EXTRACTKEYVALUE funcall.
	 ;; This fact is used to skip unneccessary rewrite rounds
	 (extract-preds
	  (subset rest (f/l (pred) (eq _extract_keyvalue_fn_ (first pred)))))	 
	 )                       

    ;; Rewrite distance inequality to AM  of sp index
    ;; if possible
    (cond (*print-index-rewrite* (print "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
				    (print "rewrite-distance-based-index-by-am")
				    (pps this)))
    (dolist (dpcall distpredcalls)
      (cond ((and (in dpcall rest)
		  (notany 
		   (f/l (pred) (or (eq (second dpcall) (third dpcall))
				   (eq (third dpcall) (third dpcall))))
		   
		   extract-preds))
	     (cond (*print-index-rewrite* 
		    (print "Rewrite distance inequality to AM.Take ")
		    (pps dpcall) (print " in ")(pps rest)))
	     (setq newconj (multi-phases-to-replace-distance-based-index  
			    this indxl rest dpcall))
	     (setq rest newconj)
	     (cond (*print-index-rewrite* (print " rewrite to ") (pps rest))))))
    newconj;; return 'modified' conjunction or NULL
    ) ;; end let
  );; end fun

;;-----------------------------------------------------------------------
(defun rewrite-distance-based-index (conj indxpreds) 
  "Rewrite distance-based-index by index operation"
  (let* (this indxl rest (rwconj conj))
    (dolist (idxpred indxpreds);; For each indexed predicate
      (cond ((in idxpred rwconj) 
	     (setq this idxpred)
	     ;; Remove this
	     (setq rest (remove this rwconj))      
	     (dolist (idxtype _aqit-supported-indexes_);; For each supported index type
	       (setq indxl (indexes-of-kind (car this) idxtype t))
	       (cond ((neq indxl nil)
		      ;; Replace distance based index by index access method
		      (setq rwconj
			    (rewrite-distance-based-index-by-am 
			     this indxl rest))
		      
		      ;; If rewrite fails, undo the removing 'this' predicate
		      (cond ((eq rwconj rest)
			     (setq rwconj (adjoin this rwconj)))
			    ((null rwconj)
			     (setq rwconj (adjoin this rest)))
			    ;; When rewrite is done successfully.
			    (t nil)))))))) 
    ;; return rewritten conj
    rwconj))

;;-----------------------------------------------------------------------
(defun smart-ordering-preds (indexedpreds conj inoutvars)
  "Rules: 
   A returned list consists of preds in which preds are groupped locally.
   Moreover, each group is in order.
   - Cluster is all preds whose first element is the same.
   - Order of a pred is based on the position of its inout variable
     in the inoutvars. 
     p1(fn, . . ., inout1, ..)
     p2(fn, . . ., inout2, ..)
     p1 sits before p2 if pos(inout1) > pos(inout2)  
   "
  (let* (cluster seed pos  res)

    ;; Clustering indexed predicates into clusters 
    (dolist (seed indexedpreds)
      (setq cluster (subset indexedpreds 
			  (f/l (p) 
			       (eq (first seed) (first p)))))
      ;; Sorting each cluster
      (setq cluster 
	    (sort cluster 
		  (f/l (p1 p2)
		       (let* ((pos1 (car (list-positions 
					  (car (intersection p1 inoutvars))
					  inoutvars)))
			      (pos2 (car (list-positions 
					  (car (intersection p2 inoutvars))
					 inoutvars)))
			     (cnnpred (first-connected-pred 
				       (car (last inoutvars)) conj)))	     
			 (cond ((null pos1) 
				(cond ((and (neq cnnpred nil)
					    (intersection (cdr cnnpred)
							  (cdr p1)))
				       ;; Make it 100 to put it in front
				       (setq pos1 100))
				      (t (setq pos1 -1)))))
			 
			 (cond ((null pos2) 		
				(cond ((and (neq cnnpred nil)
					    (intersection (cdr cnnpred)
							  (cdr p2)))
				       (setq pos2 100))
				      (t (setq pos2 -1)))))
			 (> pos1 pos2)))))

       ;; accumulate
      (setq res (append cluster res))
      ;; remove entire cluster
      (dolist (p cluster)
	(setq indexedpreds (remove p indexedpreds))))
  res))
;;=======================================================================
;; Thanh 27th Nov 2012
;;=======================================================================
(defun am-rewrite-compatible (p distpred)
  "Exists a relation predicate on which there is an AQIT supported index, and
   that index has its subsitute access method to be replaced"
  (some (f/l (idxtype) 
	     (and (indexes-of-kind (car p) idxtype t)
		  (neq (get-amfn idxtype (car distpred)) nil)))
	_aqit-supported-indexes_))


(defun distance-rewrite-action
  (distpred      ;; triggered predicate
   conj          ;; original conjunction
   indxpreds     ;; indexed predicates
   freevars      
   )
  (rewrite-distance-based-index conj indxpreds))



(defun distance-rewrite-test (distpred conjunction) 
  "Return true if there is inequality comparision connects to distpred"
  (let (indxpredl)
    ;; get list of indexed predicates which connect to
    ;; given distance predicate
    (setq indxpredl
	  (subset conjunction
		  (f/l (p)
		       (and (predicate-p p)
			    (am-rewrite-compatible p distpred)
			    (intersection-args p distpred)))))			    
    indxpredl))



(defun register-distance-based-rewriter ()
  "Register AQIT rewriters"
  (dolist (ineqpred  _distance-predicates_)
    (define-late-tr-rewriter (externalize ineqpred) 
      'distance-rewrite-test 
      'distance-rewrite-action)))


;; Register AQIT rewriter
(register-distance-based-rewriter)

;;================================================================
(defun aqit-find-distance-preds (conj)
  "Get list of distance predicates from given conjunction"
  (subset conj
	  (f/l (p)
	       (and (predicate-p p)
		    (in (predicate-operator p) _distance-predicates_)))))



;;(setq _aqit-applications_ (cons 'aqit-find-distance-preds _aqit-applications_))