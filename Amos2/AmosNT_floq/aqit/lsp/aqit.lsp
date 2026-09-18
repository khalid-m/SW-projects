;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: aqit.lsp,v $
;;; $Revision: 1.20 $ $Date: 2013/03/01 08:02:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Algebaric Query Inequality Transformation
;;; It works on inequalities having B-tree or higher dimensional
;;; data with distance metric.
;;; =============================================================
;;; $Log: aqit.lsp,v $
;;; Revision 1.20  2013/03/01 08:02:26  torer
;;; Using THERESOLVENT to be type changes independent
;;;
;;; Revision 1.19  2012/11/14 12:15:10  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.18  2012/09/06 09:19:06  thatr500
;;; Added code to
;;; - simplify division
;;; - signal N/A when AQIT failed to transform the query.
;;;
;;; Revision 1.17  2012/06/12 07:36:11  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.16  2012/05/23 07:55:43  thatr500
;;; move some code to \amosnt\lsp\extract-sql.lsp
;;;
;;; Revision 1.15  2012/05/21 07:41:09  thatr500
;;; When a rewriter replaces predicate P by a disconjunction,
;;; the rewriter suspends the process (Partial Success). The disconjunction
;;; will be rewritten into an OR of conjunctions. The rewriter takes over
;;; from that. It will work on each new born conjunction.
;;;
;;; Revision 1.14  2012/04/27 14:30:50  thatr500
;;; better handling compound predicate with 'aqit-rewriter-compound'
;;;
;;; Revision 1.13  2012/04/18 07:55:38  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.12  2012/04/16 07:43:15  thatr500
;;; - print out debug information
;;; - handled 'inverse an inquality op' in case A is negative
;;; - added guard X is positive when neccessary.
;;; - do not propagate 'commom-fragment' upward. Each transformation,
;;;   'common-fragment' property is reset beforehand.
;;;
;;; Revision 1.11  2012/04/02 13:15:00  thatr500
;;; - fixed bug 'finding a common predicate'.
;;; - improve rule to transform ABS(x) < y
;;;
;;; Revision 1.10  2012/03/22 20:32:07  thatr500
;;; fixed wrong transformation rule for "abs(a) ineq b".
;;;
;;; Revision 1.9  2012/03/12 14:23:20  thatr500
;;; - it always needs two nodes (ineq-node + prevnode) to do transformation.
;;; - fixed inifinite loop
;;;
;;; Revision 1.8  2012/03/12 09:04:48  thatr500
;;; Fixed
;;;  - stopping condition for B-tree based index
;;;  - stopping condition for distance based index
;;; Attemped
;;;  - pushdown selection predicates on cc functions
;;;
;;; Revision 1.7  2012/02/24 14:03:52  thatr500
;;; added register-aqit-rewriter
;;;
;;; Revision 1.6  2012/01/20 17:36:35  thatr500
;;; simplified code + removed hard-wired stuffs
;;;
;;; Revision 1.5  2012/01/17 16:10:32  thatr500
;;; renamed variable _spatial-indexes_ to _aqit-supported-indexes_
;;;
;;; Revision 1.4  2012/01/13 20:34:15  thatr500
;;; ´removed code
;;;
;;; Revision 1.3  2011/12/13 15:34:15  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.2  2011/11/15 12:43:56  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.1  2011/11/15 09:55:57  thatr500
;;; AQIT algorithm
;;;
;;;
;;; =============================================================
;;-----------------------------------------------------------------------
;; Dynamic variables
;;------------------------------------------------------------------------
(defparameter *enable-aqit* nil)
(defparameter *print-aqit* nil)
;;When a rewriter replaces predicate P by a disconjunction, 
;;the rewriter suspends the process (Partial Success). The disconjunction 
;;will be rewritten into an OR of conjunctions. The rewriter takes over
;;from that. It will work on each new born conjunction.
(defparameter *partial-success* nil) 
;; During transformation, if the algorithm detects N/A it will terminal.
;; In that case, the input is kept intact. N/A only means that
;; AQIT cannot be applied but the query will be executed anyway
(defparameter *aqit-na* nil)

;;-----------------------------------------------------------------------
;; Global variables 
;;------------------------------------------------------------------------
(defglobal _aqit-supported-indexes_
  (list nil) "List of AQIT supported indexes")

;;------------------------------------------------------------------------
(defstruct node 
  pred         ; predicate p
  var          ; on the 'var', p connects with its successor along the path
)


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
  (theresolvent 'MINKOWSKI)
  "The resolvent minkowski(Vector, Vector, Number)->Real")


(defglobal _distance-predicates_ (list _euclid_ _euclid1D_ _manhattan_ _intersection_distance_
				        _minkowski_)
  "List of supported distance preidcates")


(defglobal _!=_ (getfunctionnamed 'OBJECT.OBJECT.!=->BOOLEAN))
(defglobal _<_ (getfunctionnamed  'OBJECT.OBJECT.<->BOOLEAN))
(defglobal _>_ (getfunctionnamed  'OBJECT.OBJECT.>->BOOLEAN))
(defglobal _>=_ (getfunctionnamed  'OBJECT.OBJECT.>=->BOOLEAN))
(defglobal _<=_ (getfunctionnamed  'OBJECT.OBJECT.<=->BOOLEAN))
  
(defglobal _gt-comparisons_
  (list _>_  _>=_) "The gt comparisons")

(defglobal _lt-comparisons_
  (list _<_  _<=_) "The lt comparisons")


;;-----------------------------------------------------------------------
;; Some common ultilities
;;------------------------------------------------------------------------
(defun insert-after (lst index newelt)
  (push newelt (cdr (nthcdr index lst))) 
  lst)

(defun first-inequal (lpreds)
  "Return the first inequality predicate found"
  (let* (lineq ;; list of inequality predicates
	 stop (pos 0) (len (length lpreds))
	 p)
    
    (while (and (null stop)
		(< pos len))
      (setq p (nth pos lpreds))       
      (cond ((in (generic-fnname (car p)) '(< <= > >=))
	     (setq stop t))
	    (t (setq pos (+ pos 1)))))
    ;; Return found pred
    (cond ((< pos len) p))))	  

(defun first-connected-pred (var lpreds)
  "Return the first found predicate connected to a given var"
  (let* ( stop (pos 0) (len (length lpreds)) p)
    (while (and (null stop) (< pos len))
      (setq p (nth pos lpreds))       
      (cond ((in var (cdr p))
	     (setq stop t))
	    (t (setq pos (+ pos 1)))))
    ;; Return found pred
    (cond ((< pos len) p))))

(defun inverse-ineq (ineq)
  "From GT/GE to LT/LE and vice versa."
  (cond ((eq ineq _>_)  _<_);; GT -->LT
	((eq ineq _>=_) _<=_);; GE -->LE
	((eq ineq _<_)  _>_);; LT -->GT
	((eq ineq _<=_) _>=_);; LE -->GE
	(t ineq))) ;; Otherwise leave as it is

(defglobal _CC-BTREE_ (mkstring "B-tree"))

;;------------------------------------------------------------------------
;; AQIT - Arithmetic ( monotonic) functions
;;------------------------------------------------------------------------
(defun monotonic-pred? (pred)
  (in (first pred) (list _number-plus_ _number-minus_ _number-times_
			 _number-div_)))
(defun supported-non-monotonic-pred? (pred)
  (in (first pred) (list _number-power_ _number-sqrt_ _number-abs_)))
			 
;;------------------------------------------------------------------------
;; AQIT - starting predicate ?
;;------------------------------------------------------------------------
(defun dist-starting-pred? (pred)
  (in (first pred) _distance-predicates_))
;;------------------------------------------------------------------------
;; AQIT - distance predicate ?
;;------------------------------------------------------------------------
(defun distance-preds? (conj)
  (subset conj 
	  (f/l (pred)
	       (and (ilistp pred)
		    (in (first pred) _distance-predicates_)))))
;;------------------------------------------------------------------------
;; List all possible starting distance preds
;;-----------------------------------------------------------------------
(defun list-starting-dist-preds (preds)
  (subset 
   preds
   (f/l (pred)
	(and (consp pred)
	     (dist-starting-pred?  pred)))))
;;------------------------------------------------------------------------
;; Sorting starting predicates
;;-----------------------------------------------------------------------
(defun sort-starting-preds (preds)
  ;; To be added 
  preds)

;;------------------------------------------------------------------------
;; If pred is ending predicate
;;-----------------------------------------------------------------------
(defun end-pred? (pred)
  (in (generic-fnname (car pred)) '(< <= > >=)))

;;------------------------------------------------------------------------
;; This is a dead end node
;;-----------------------------------------------------------------------
(defun dead-end-node? (currnode)
  (eq (node-var currnode) nil))

;;------------------------------------------------------------------------
;; Find list of candidates as next node on the path
;;-----------------------------------------------------------------------
(defun find-list-next-nodes (currnode conj)
  (let* ((pos 0) (len (length conj)) pred
	 (var (node-var currnode))
	 lnextnodes nextvars)
    (while (< pos len)
      (setq pred (nth pos conj))  
      (cond ((in var (cdr pred)) ;; currnode.pred connects with pred
	     (setq nextvars (subset 
			     (set-difference (cdr pred) (cdr (node-pred currnode)))
			     (f/l (v) (not (osql-constantp v)))))
	     (cond ((eq nextvars nil)
		    (setq lnextnodes 
			  (append lnextnodes 
				  (list (make-node :pred pred :var nil)))))
		   (t (dolist (nextvar nextvars)
			(setq lnextnodes 
			      (append lnextnodes 
				      (list (make-node :pred pred :var nextvar)))))))))
      (setq pos (+ pos 1)))      
    ;;return
    lnextnodes))

;;------------------------------------------------------------------------
;; Find list of predicates using var 
;;-----------------------------------------------------------------------
(defun list-predicates-using-var (var conj)
  (cond ((and (ilistp conj) (neq var nil))
	 (subset conj
		 (f/l (pred)
		      (and (ilistp pred)
			   (in var (cdr pred))))))))

;; Return a list of preds that has a common variable var
(defun find-list-predicates-using-var (var conj1 conj2)
  (let ((l (list-predicates-using-var var conj1)))
    (if l l (list-predicates-using-var var conj2))))

;;------------------------------------------------------------------------
;; AQIT- Stopping state
;;------------------------------------------------------------------------
(defun aqit-stopping-state (path conj removedpreds addedpreds)
  ;;*** Initialize some variables
  (let* ((ineq-node (car (last path))) ;; last node
	 (prevnode  (second (reverse path))) ;; second last node
	 (prev2node (third (reverse path))) ;; third last node
	 (pred (node-pred prevnode))
	 (ineq-pred (node-pred ineq-node))
	 new-ineq-node solution 
	 (ineq-sign (first ineq-pred))	 
	 (var (get-indexedvar pred)))

    (cond ((and 
	    ;; Btree index support both directions
	    (or (indexes-of-kind (car pred)'MBTREE t)
		(get-descr-index-cc (mkstring "B-tree") (car pred)))
	    (or (in ineq-sign _gt-comparisons_)
		(in ineq-sign _lt-comparisons_))
	    (or (eq var (second ineq-pred))
		(eq var (third ineq-pred))))
	   (setq solution t))
	  (t ;; Otherwise 'distance-based-index' has to be dist < something 
	   (cond  ((and (in ineq-sign _lt-comparisons_)
			(eq var (second ineq-pred)))
		   (setq solution t)))))  

    (cond (solution 
	   (dolist (p removedpreds)
	     (setq conj (remove p conj)))
	   (dolist (p addedpreds)
	     (setq conj (append conj (list p))))
	   (setq conj (adjoin ineq-pred conj))))
    
    (list solution conj removedpreds addedpreds new-ineq-node)))


(defun aqit-partial-success-state (path conj removedpreds addedpreds)
  (dolist (p removedpreds)
    (setq conj (remove p conj)))
  (dolist (p addedpreds)
    (setq conj (append conj (list p))))
  (list t conj removedpreds addedpreds nil))

;; v is positive ?
(defun is-positive? (v conj)
  (or (and (constantp v) (> v 0))   
      (some (f/l (p) (or 
		      (and 
		       ;; x >0, x >= 0
		       (eq v (second p))  
		       (eq (first p) _>_)    
		       (and (numberp (third p)) 
			    (>= (third p) 0)))
		      ;; 0 < X 
		      (and 
		       (eq v (third p))
		       (eq (first p) _<_)			      
		       (and (numberp (second p))
			    (>= (second p) 0)))))			      
	    conj)))

(defun is-negative? (v conj)
  (or (and (constantp v) (< v 0))   
      ;; c - exists a guard v < 0 or 0 > v
      (some (f/l (p) (or (and (eq (first p) _<_) ;; X < 0 or 0 > X
			      (eq v (second p))
			      (and (numberp (third p)) 
				   (<= (third p) 0)))
			 (and (eq v (third p))
			      (eq (first p) _>_)
			      (and (numberp (second p))
				   (>= (second p) 0)))))		      
	    conj)))

(defun exist-guard-positive? (v conj addedpreds orgpred)
  ;; v is possitive?
  (or (is-positive? v (append conj addedpreds))
      ;; or v is a result of ABS function
      (and orgpred (eq (car orgpred) _number-abs_))))


(defun exist-guard-negative? (v conj addedpreds orgpred)
  ;; v is negative?
  (is-negative? v (append conj addedpreds)))


;;------------------------------------------------------------------------
;; AQIT- Transforming monotonic/arithmetic functions + inequality 
;;       Generating new state
;;------------------------------------------------------------------------
(defun aqit-trans-monotonic-fun (path conj  removedpreds addedpreds)
  ;;*** Initialize some variables
  (let* ((ineq-node (car (last path))) ;; last node
	 (prevnode  (second (reverse path))) ;; second last node
	 (prev2node (third (reverse path))) ;; third last node
	 (var (node-var prevnode)) 
	 (prevvar (cond ((neq prev2node nil) (node-var prev2node))
			(t (node-var prevnode))))
	 (pred (node-pred prevnode))
	 (ineq-pred (node-pred ineq-node))
	 (A (car (remove var (remove prevvar (cdr pred)))))
	 ;;(B (third ineq-pred)) Thanh 2012-Mar-07
	 (B (car (subset (cdr ineq-pred) (f/l (v) (neq var v)))))
	 (posA (car (list-positions A pred)))	 
	 new-ineq-node mirror-var  mirror-var-sec
	 cm-preds ;; a list of predicates that has var as a common variable
	 ;; Thanh 2012-June-11
	 split-cases
	 ;; Thanh 2012-Sep-05. Secondary inequality pred
	 ineq-pred-sec
	 B-sec
	 pred-sec
	 )
    ;; A) Remove (pred, ineq-pred) which were added by AQIT
    (setq addedpreds (remove pred addedpreds))
    (setq addedpreds (remove ineq-pred addedpreds))
    ;; remove (pred, ineq-pred) which are original in conj
    (setq removedpreds (append removedpreds (list ineq-pred)))

    ;; B) Handle the common fragment.
    ;; If pred is a common fragment, replicate it before AQIT transform it
    ;; later. Otherwise, just remove it.
    (setq cm-preds 
	  (find-list-predicates-using-var var conj addedpreds))	

    ;; 2012-09-05--START------
    (setq ineq-pred-sec (first-inequal cm-preds))
    ;; 2012-09-05--END--------

    (cond ((and cm-preds 
		(null  ineq-pred-sec))
	   (setq addedpreds (append addedpreds (list pred))))
	  (t (setq removedpreds (append removedpreds (list pred)))))

      ;; 2012-09-05--START-----------
    (cond (ineq-pred-sec
	   ;;(help 'MMM)
	   (setq addedpreds (remove ineq-pred-sec addedpreds))
	   (setq removedpreds (append removedpreds (list ineq-pred-sec)))

	   (setq B-sec (car (subset (cdr ineq-pred-sec) (f/l (v) (neq var v)))))	 
	   (setq pred-sec pred)

	   (setq pred-sec (subst B-sec var pred-sec)) 
	   (setq pred-sec (subst var prevvar pred-sec)) 

	   (setq ineq-pred-sec (subst prevvar var ineq-pred-sec)) 
	   (setq ineq-pred-sec (subst var B-sec ineq-pred-sec))
	   
	   (setq mirror-var-sec (dt_genvar (type_of_var var *bindings*)))
	   (setq pred-sec (subst mirror-var-sec var pred-sec)) 
	   ;;(help 'M1)
	   (setq ineq-pred-sec (subst mirror-var-sec var ineq-pred-sec))

	   ))
    ;; 2012-09-05--END--------------

    ;; C) Transforming = swapping variables
    (setq pred (subst B var pred)) ;; At pred, B replaces var
    (setq pred (subst var prevvar pred)) ;; At pred, var replaces prevvar
    ;; At ineq-pred,prevvar replaces var
    (setq ineq-pred (subst prevvar var ineq-pred)) 
    (setq ineq-pred (subst var B ineq-pred)) ;; At ineq-pred, var replaces B

    ;; Inverse inequality sign. Two cases
    ;; TIMES
    (if (eq (car pred) _number-times_)
	(case posA
	  ;; When it is (A * prevvar = var), (prevvar * A = var), (prevvar / A = var)
	  ;; We flip the inequality sign if A is a constant and negative
	  ((1 2)
	   (cond ((and (constantp A)
		       (not (is-positive? A (append conj addedpreds))))
		  (setq ineq-pred (inverse-ineq-pred ineq-pred))
		  (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec)))))	   
	   ;; When it is (A / prevvar = var)
	  (3      
	   ;(help 'YYY)
	   (let ((ls (set-difference (cdr (node-pred prevnode))
				     (list prevvar var))))
	     ;; Case 1 prevvar is positive 
	     (cond ((exist-guard-positive? prevvar conj addedpreds 
					   (node-pred prev2node))
		    ;; How about B ?
		    ;; Case 1.1
		    (cond ((exist-guard-positive? B conj addedpreds 
						  (node-pred prev2node)) 
			   ;; Example 5 / x < 2 ==> X > 5/2
			   (setq ineq-pred (inverse-ineq-pred ineq-pred))
			   (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec))
			   )
			  ;; Case 1.2
			  ((exist-guard-negative? B conj addedpreds 
						  (node-pred prev2node))
			   ;; Example 5 / x < -2 ==> X < 5/ -2
			   ;; Ineq-pred was correctly constructed above 
			   )
			  ;; Case 1.3
			  ((and ls (exist-guard-positive? (first ls) conj addedpreds 
							  (node-pred prev2node)))   
			   ;; This is a last shot. We figure out that var
			   ;; is positive based on ls
			   ;;  (#[OID 172 "NUMBER.NUMBER.TIMES->NUMBER"] _V2 X 5)
			   (setq ineq-pred (inverse-ineq-pred ineq-pred))
			   (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec))
			   )
			  ;; Case 1.4
			  ((and ls (exist-guard-negative? (first ls) conj addedpreds 
							  (node-pred prev2node)))   
			   ;; This is a last shot. We figure out that var
			   ;; is negative based on ls
			   ;;  (#[OID 172 "NUMBER.NUMBER.TIMES->NUMBER"] _V2 X 5)
			   ;; See above. Ineq-pred was correctly constructed
			   )
			  ;; Case 1.5
			  (t ;; No idea ==> TRANSFORMATION SHOULD FAIL
			   (setq *aqit-na* t))))
		 		  
		   ;; prevvar is negative
		   ;; Case 2
		   ((exist-guard-negative? prevvar conj addedpreds 
					   (node-pred prev2node))		  
		    ;; How about var ?
		    ;; Case 2.1
		    (cond ((exist-guard-positive? B conj addedpreds 
						  (node-pred prev2node)) 
			   ;; Example 5 / x < 2 ==> X < 5/2
			   ;; Ineq-pred was correctly constructed above		 
			   )		  
			  ;; Case 2.2
			  ((exist-guard-negative? B conj addedpreds 
						  (node-pred prev2node))		 
			   ;; Example 5 / x < -2 ==> 5 > -2x ==> x > 5/-2
			   (setq ineq-pred (inverse-ineq-pred ineq-pred))
			   (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec))
			   )	 

			  ;; Case 2.3
			  ((and ls (exist-guard-positive? (first ls) conj addedpreds 
							  (node-pred prev2node)))   
			   ;; This is a last shot. We figure out that var
			   ;; is positive based on ls
			   ;;  (#[OID 172 "NUMBER.NUMBER.TIMES->NUMBER"] _V2 X 5)
			   ;; Ineq-pred was correctly constructed above		 
			   )

			  ;; Case 2.4
			  ((and ls (exist-guard-negative? (first ls) conj addedpreds 
							  (node-pred prev2node)))   
			   ;; This is a last shot. We figure out that var
			   ;; is negative based on ls
			   ;;  (#[OID 172 "NUMBER.NUMBER.TIMES->NUMBER"] _V2 X 5)
			   (setq ineq-pred (inverse-ineq-pred ineq-pred))	 
			   (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec))
			   )
			  ;; Case 2.5
			  (t ;; No idea ==> TRANSFORMATION SHOULD FAIL
			   (setq *aqit-na* t)
			   )))
		   ;; Case 3
		   (;;No knowledge about prevvar and var is positive
		    (or (exist-guard-positive? var conj addedpreds 
					       (node-pred prev2node)) 
			(and ls ;;(null (help 'QQQ)) 
			     (exist-guard-positive? (first ls) conj addedpreds 
						    (node-pred prev2node))))

		    ;; Split this situation into two cases with OR
		    (setq split-cases 
			  (append  split-cases 
				   (list 
				    (orify 
				     (list 
				      (andify (list (list _>_ prevvar 0)
						    (inverse-ineq-pred ineq-pred)
						    (inverse-ineq-pred ineq-pred-sec)
						    ))
				      (andify (list (list _<_ prevvar 0)
						    ineq-pred
						    ineq-pred-sec
						    )))))))
		    (setq *partial-success* t))
		   ;; Case 4
		   (;;No knowledge about prevvar and var is negative
		    (or (exist-guard-negative? B conj addedpreds 
					   (node-pred prev2node)) 
			(and ls (exist-guard-negative? (first ls) conj addedpreds 
						       (node-pred prev2node))))
		    ;; Split this situation into two cases with OR
		    (setq split-cases 
			(append  
			 split-cases 
			 (list 
			  (orify 
			   (list 
			    (andify (list (list _>_ prevvar 0)
					  ineq-pred
					  ineq-pred-sec
					  ))
			    (andify (list (list _<_ prevvar 0)
					  (inverse-ineq-pred ineq-pred)
					  (inverse-ineq-pred ineq-pred-sec)
					  )))))))
		    (setq *partial-success* t))
		   ;; Case 5
		   (t ;; No knowledge at all. ==> TRANSFORMATION SHOULD FAIL ???
		    ;; HACK : Assume var is positive		  
		    (setq split-cases 
			  (append  split-cases 
				 (list 
				  (orify 
				   (list 
				    (andify (list (list _>_ prevvar 0)
						  (inverse-ineq-pred ineq-pred)))
				    (andify (list (list _<_ prevvar 0)
						  ineq-pred)))))))
		  (setq *partial-success* t)
		  
		  )
		   )
	     )) ;; end of 3
	  )
      )

		 
    ;; Inverse inequality sign. Two cases
    ;; PLUS (var = A - prevvar)
    (cond ((and (eq (car pred) _number-plus_) (= 3 posA))
	   (setq ineq-pred (inverse-ineq-pred ineq-pred))
	   (setq ineq-pred-sec (inverse-ineq-pred ineq-pred-sec))))

	
    ;; D) Handle common fragment
    ;; AQIT has replicated 'old' pred but 'var' has changed because of the swapping.
    ;; AQIT then has to 'replicate' the 'var' by introducing 'mirror-var' 
    (cond ((and cm-preds (null  ineq-pred-sec)) 
	   (setq mirror-var (dt_genvar (type_of_var var *bindings*)))
	   (setq pred (subst mirror-var var pred)) 
	   (setq ineq-pred (subst mirror-var var ineq-pred))))

    ;;(help 'TTTT)
    ;; E) New predicates now are added 
    (cond ((null *partial-success*)
	   (setq addedpreds (append addedpreds (list pred ineq-pred pred-sec ineq-pred-sec))))
	  (t	   
	   (setq addedpreds (append addedpreds (list pred pred-sec) split-cases))))

    (setq addedpreds (mapfilter (f/l (p) (neq p nil)) addedpreds))

    (print-cnd "transform")
    (print-cnd (node-pred prevnode))
    (print-cnd (node-pred ineq-node))
    (print-cnd "...to...")
    (cond ((null *partial-success*)
	   (print-cnd pred)
	   (print-cnd ineq-pred))
 	  (t	   
	   (print-cnd split-cases)))
    

    (setq new-ineq-node (make-node :pred ineq-pred :var nil))
    ;;0:solution, 1:conj, 2:removedpreds, 3:addpreds,4:new-ineq-node
    (list nil conj removedpreds addedpreds new-ineq-node)))

;;------------------------------------------------------------------------
;; AQIT- Transforming supported nonmonotonic function + inequality 
;;       Generating new state
;;------------------------------------------------------------------------
(defun aqit-trans-suppored-fun (path conj removedpreds addedpreds) 
  ;;*** Initialize some variables
  (let* ((ineq-node (car (last path))) ;; last node
	 (prevnode  (second (reverse path))) ;; second last node
	 (prev2node (third (reverse path))) ;; third last node
	 (var (node-var prevnode)) 
	 (prevvar (cond ((neq prev2node nil) (node-var prev2node))
			(t (node-var prevnode))))
	 (pred (node-pred prevnode))
	 (ineq-pred (node-pred ineq-node))
	 (A (car (remove var (remove prevvar (cdr pred)))))
	 ;;(B (third ineq-pred)) Thanh 2012-Mar-07
	 (B (car (subset (cdr ineq-pred) (f/l (v) (neq var v)))))
	 (posA (car (list-positions A pred)))
	 new-ineq-node TMP mirror-var trans var-changed list-added-preds
	 common-fragment)
    ;; A) Remove (pred, ineq-pred) which were added by AQIT
    (setq addedpreds (remove pred addedpreds))
    (setq addedpreds (remove ineq-pred addedpreds))
    ;; remove (pred, ineq-pred) which are original in conj
    (setq removedpreds (append removedpreds (list ineq-pred)))

    ;; B) Handle the common fragment.
    ;; If pred is a common fragment, replicate it before AQIT transform it
    ;; later. Otherwise, just remove it.
    ;; This property propagates upward
    ;; TT /2012-04-12 ??????
    (setq common-fragment 
	  (find-list-predicates-using-var var conj addedpreds))	   

    (cond (common-fragment (setq addedpreds (append addedpreds (list pred))))
	  (t (setq removedpreds (append removedpreds (list pred)))))

    ;; If var is used else where in conjunction, make a replicate of var
    ;;(cond (common-fragment
    ;;(setq var (dt_genvar (type_of_var var *bindings*)))))
    (setq trans t)
    ;; POWER
    (cond ((eq (car pred) _number-power_)
	   ;; see paper V5
	   (setq TMP (dt_genvar (type_of_var B *bindings*)))
	   (setq list-added-preds (list (list _number-power_ B TMP var)
					(list _number-times_ TMP A 1)
					(list (car ineq-pred) prevvar var)))
	   (setq new-ineq-node (make-node :pred (list (car ineq-pred) prevvar var) :var nil)))

	  ((eq (car pred) _number-sqrt_)
	   ;; see paper V5
	   (setq list-added-preds (list (list _number-power_ B 2 var)
					(list (car ineq-pred) prevvar var)))
	   (setq new-ineq-node (make-node :pred (list (car ineq-pred) prevvar var)  :var nil))
	   (setq var-changed t))
	   
	  ((and (eq (car pred) _number-abs_)
		;; only transform < or <=
		(memq (generic-fnname (car ineq-pred)) '(< <= )))
	   ;; see paper V5	   
	   (setq list-added-preds (list (list _number-plus_ var B 0)
					(list (car ineq-pred) prevvar B)
					(list (inverse-ineq (car ineq-pred)) prevvar  var)))

	   (setq new-ineq-node (make-node :pred (list (car ineq-pred) prevvar B) :var nil))
	   (setq var-changed t))
	  ((and (eq (car pred) _number-abs_)
		;; only transform > >=
		(memq (generic-fnname (car ineq-pred)) '(> >= )))
	   (setq list-added-preds (list (list _number-plus_ var B 0)
					(orify (list 					
						(list (inverse-ineq (car ineq-pred)) prevvar  var)
						(list (car ineq-pred) prevvar B)))))					       
	   (setq *partial-success* t)
	   (setq new-ineq-node nil)
	   (setq var-changed t))
	  (t (setq trans nil)));;end cond

    ;; D) Handle common fragment
    ;; AQIT has replicated 'old' pred but 'var' has changed because of the swapping.
    ;; AQIT then has to 'replicate' the 'var' by introducing 'mirror-var' 
    (cond ((and common-fragment var-changed)
	   (setq mirror-var (dt_genvar (type_of_var var *bindings*)))
	   (setq addedpreds (mapcar  (f/l (p) (subst mirror-var var p)) addedpreds))
	   (setq conj (mapcar  (f/l (p) (subst mirror-var var p)) conj))))

    (if trans (setq addedpreds (append addedpreds list-added-preds)))
    (print-cnd "transform")
    (print-cnd pred)
    (print-cnd ineq-pred)
    (print-cnd "...to...")
    (print-cnd list-added-preds)
    (print-cnd "...while addedpreds ...")
    (print-cnd addedpreds)

    ;;0:solution, 1:conj, 2:removedpreds, 3:addpreds,4:new-ineq-node
    (list nil conj removedpreds addedpreds new-ineq-node)))

;;------------------------------------------------------------------------
;; AQIT-TransformingPath
;;------------------------------------------------------------------------
(defun aqit-transforming-path (path bkconj)
  (let* (ineq-node prevnode  new-ineq-node addedpreds removedpreds solution
		   (conj bkconj) (startnode (first path))  res)
    (print-cnd "AQUIT transforms the found inequality path")
    (print-cnd path)
    (while (and (neq path nil) (null *partial-success*) (null *aqit-na*))
      (setq ineq-node (car (last path))) ;; last node
      (setq prevnode (second (reverse path))) ;; second last node
      (cond ((neq prevnode nil)
	     ;; Case A - Hit the starting predicate (success) or patial success   !!!
	     (cond ((eq startnode prevnode)
		    (setq res (aqit-stopping-state path conj 
						   removedpreds addedpreds)))
		   ;; Case B - Monotonic predicate
		   ((monotonic-pred? (node-pred prevnode))
		    (setq res (aqit-trans-monotonic-fun
			       path conj removedpreds addedpreds)))

		   ;; Case C - Non monotonic functions
		   ((supported-non-monotonic-pred? (node-pred prevnode))
		    (setq res (aqit-trans-suppored-fun path conj 
						       removedpreds addedpreds)))
		   ;; Case D - Do nothing
		   (t ))
	     (if *partial-success*
		 (setq res (aqit-partial-success-state path 
						(nth  1 res) 
						(nth  2 res)
						(nth  3 res))))						   
	     (setq solution (and (nth 0 res)
				 (null *aqit-na*)))		   
	     (setq conj (nth 1 res))
	     (setq removedpreds (nth 2 res))
	     (setq addedpreds (nth 3 res))
	     (setq new-ineq-node (nth 4 res))))
	     ;; Throw out already processed nodes
	     (setq path (remove ineq-node path))
	     (setq path (remove prevnode path))
	     (if *partial-success* 
		 (dolist (node path)
		   (setq conj (adjoin (node-pred node) conj))))
	     ;; Add new born inequality node to the front
	     (if (neq new-ineq-node nil)
		 (setq path (append path (list new-ineq-node))))

	     );;end while

    (cond (solution 
	   (print-cnd "AQUIT transformation is SUCCESS")
	   (print-cnd conj))	   
	  (t (print-cnd "AQUIT transformation FAILS")))	     

    ;; Transformationing ends and return values
    (cond (solution (list solution conj))
	  (t  (list nil bkconj)))))

;;------------------------------------------------------------------------
;; AQIT-Groupping
;;------------------------------------------------------------------------
(defun aqit-groupping (currnode path conj)
  (let* (solution lnextnodes candnode resl)
    (cond ((end-pred? (node-pred currnode))
	   (print-cnd "Find an end predicate: inequality predicate")
	   ;; Path is now as an inequality path.We try to transform it
	   ;; in backward direction.
	   (setq resl (aqit-transforming-path path conj))
	   ;; Transformation is doneB
	   (list (first resl) (second resl)))
	  ((dead-end-node? currnode)
	   (print-cnd "This is a dead end. Go back!!!")
	   (list nil conj))
	  ;; Otherwise, find list of possible next nodes
	  (t 
	   (setq lnextnodes (find-list-next-nodes currnode conj))
	   ;; For each candidate node
	   (while (and (eq  solution nil)
		       (neq lnextnodes nil))
	     (setq candnode (first lnextnodes))
	     ;; recursive call
	     (setq resl (aqit-groupping candnode ;; currnode = candnode
					(append path (list candnode)) ;; Adop it into the path
					(remove (node-pred candnode) conj)))
	     (setq solution (first resl))
	     ;; It is a solution, then return the transformed conjunction. stop here
	     (if solution (setq conj (second resl)))
	     ;; throw out candnode
	     (setq lnextnodes (remove candnode lnextnodes)));;end while
	   ;; return values
	   (list solution conj)))));;end t
	  

(defun get-indexedvar (startpred)
  (let* (indexedpos indexedvar)
    (cond ((dist-starting-pred? startpred)
	   (setq indexedvar (car (last startpred))))
	  ((get-descr-index-cc _CC-BTREE_ (car startpred))
	   (setq indexedpos (get-descr-index-cc _CC-BTREE_ (car startpred)))
	   (setq indexedvar (nth indexedpos (cdr startpred))))
	  
	  ((indexes-of-kind (car startpred) 'MBTREE t)
	   (setq indexedpos (index-pos (car (indexes-of-kind 
					     (car startpred) 'MBTREE t))))
	   (setq indexedvar (nth indexedpos (cdr startpred))))	  
	  ((indexes-of-kind (car startpred) 'XTREE t)
	   (setq indexedpos (index-pos (car (indexes-of-kind (car startpred) 'XTREE t))))
	   (setq indexedvar (nth indexedpos (cdr startpred))))
	    
	  ((indexes-of-kind (car startpred) 'KDTREE t)
	   (setq indexedpos (index-pos (car (indexes-of-kind (car startpred) 'KDTREE t)))
	   (setq indexedvar (nth indexedpos (cdr startpred))))))    
    indexedvar))
    
;;------------------------------------------------------------------------
;; AQIT-Entry
;;------------------------------------------------------------------------
(defun aqit-entry (pred bkconj indxpreds)
  " Algebaric-query-inequality-transformation"
  (let* ((conj bkconj) indexedvar indexedpos
	 lstartpreds startpred  startnode resl)

    (print-cnd "Before AQUIT")
    (print-cnd  conj)
    (print-cnd "Find all starting candidates having indexes on them")

    (setq lstartpreds (list-starting-dist-preds conj))
    ;; Only consider either distance pred or indexed pred as starting point
    (if (eq lstartpreds nil)
	(setq lstartpreds (append lstartpreds indxpreds)))

    ;; Sorting starting candidates based on their size / selectivities
    (print-cnd "Sorting starting candidates based on their size / selectivities")
    (setq lstartpreds (sort-starting-preds lstartpreds))
    (while (and (neq  lstartpreds nil)
		(null *aqit-na*)
		(null *partial-success*)
		)
      (setq startpred (car lstartpreds))
      (setq indexedvar (get-indexedvar startpred))
      (setq startnode (make-node :pred startpred :var indexedvar))

      (print-cnd "Starting from node")
      (print-cnd  startnode)
      (print-cnd  "AQUIT (backtracking) groups  other predicates 
                      to form an inequality path")
      (print-cnd conj)

      (setq resl (aqit-groupping startnode ;; start-node                
				 (list startnode) ;; path has only start-node
				 (remove (node-pred startnode) conj)))

      (cond ((first resl) ;; a success transformation
	     (setq conj (second resl))
	     ;; re-add starting predicate
	     (setq conj (adjoin  (node-pred startnode) conj))))
		   
      (setq lstartpreds (cdr lstartpreds)));;end while 
    (print-cnd "After AQUIT")
    (print-cnd conj)
    conj))


;;-----------------------------------------------------------------------
(defun aqit-tester-b-c (p distpred)
  "Exists a relation predicate on which there is an AQIT supported index, and
   that index has its subsitute access method to be replaced"
  (some (f/l (idxtype) 
	     (and 
	      (indexes-of-kind (car p) idxtype t)
	      (neq (get-amfn idxtype (car distpred)) nil)))
	_aqit-supported-indexes_))

(defun aqit-tester (pred conjunction)
  "Rewrite this conjunction if these requirements hold
   AND a)  Exists an inequality predicate
       b)  Exists a stored function predicate on 
           which there is an AQIT supported index such as XTREE, KDTREE,...
       c)  There is a rewrite rule on (car pred): distance predicate 
       For example: 
       If (car pred) is EUCLID then there exists 
         add_index_rewrite_rule('XTREE', #'euclid', #'XTREE_DISTANCE_SEARCH_FN')
       If (car pred) is MINKOWSKI then there exists 
         add_index_rewrite_rule('XTREE', #'minkowski', #'XTREE_DISTANCE_SEARCH_FN')
  "
  (let* (indxpredl  distpred)
    (cond (*enable-aqit*  ; a is true because of pred
	   (setq distpred (car (distance-preds? conjunction)))
	   (setq indxpredl
		 (subset conjunction
			 (f/l (p)
			      (and (ilistp p)
				   ;; b and c
				   (or 
				    (get-descr-index-cc _CC-BTREE_ (car p))
				    (indexes-of-kind (car p) 'MBTREE t) 
				    (aqit-tester-b-c p distpred))))))))

    ;; If pred and indexpredl are connected, we skip AQIT
    (setq indxpredl
	  (mapfilter (f/l (idx) 
			  (null (intersection-args idx pred))) indxpredl))
	  
    (cond (*print-index-rewrite* 
	   (print "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	   (print "Aqit-Tester")
	   (pps indxpredl)))
    ;; Return indexed predicates
    (remove nil indxpredl)))

;;----------------------------------------------------------------------
(defun pushdown-selection-predicates-on-cc (preds)
  (let* (non-cc-fns ;; non ccc functions
	 cc-fns      ;; cc functions
	 eq-fns
	 ineq-fns)

    ;; categorize functions into two sets (cc and non-cc)
    (mapcar (f/l (p) 
		 (cond ((core-cluster-fn? (predicate-operator p))
			(setq cc-fns (adjoin p cc-fns)))
		       ((eq (predicate-operator p) _=_)
			(setq eq-fns (adjoin p eq-fns)))
		       ((in (predicate-operator p) (append _lt-comparisons_ _gt-comparisons_))
			(setq ineq-fns (adjoin p ineq-fns)))
		       (t 
			(setq non-cc-fns (adjoin p non-cc-fns)))))
	    preds)
    ;; pushdown core cluster fn on which _CC-BTREE_ is present
    (sort cc-fns 
	  (f/l (a b) (let* ((idxa (get-descr-index-cc _CC-BTREE_ (car a)))
			    (idxb (get-descr-index-cc _CC-BTREE_ (car b))))
		       (setq idxa (if (neq idxa nil) 1 0))
		       (setq idxb (if (neq idxb nil) 1 0))
		       (compare idxa idxb)))) 
    ;; equality predicate is down    
    ;; merge three sets
    (setq preds (append cc-fns eq-fns non-cc-fns ineq-fns))
    )  
  preds)  

(defun simplify-division-tester (conj) 
 "TRUE if it could simplify division (x +- a) / x <--> (1 +- a/x)"
 (let (pos+ pos/ res)
   (setq pos+ 0)
   (dolist (p conj)
     (cond ((predicate-plus-p p) ;; PLUS
	    (setq pos/ 0)
	    (dolist (q conj)
	      (cond ((and (predicate-times-p q) ;; TIMES
			  (= (length (intersection-args p q)) 2) ;; common vars
			  (in (car (last q))    ;; last var in q is a common var 
			      ;; implies --> DIVISION			      
			      (intersection-args p q)))
		     (setq res (list pos+ pos/ p q))))		     		     
	      (setq pos/ (+ pos/ 1)))))
     (setq pos+ (+ pos+ 1)))
   res))

(defun replace-at (pos x l)
  "Replace element at pos by x in list l"
  (append (sublist 0 (- pos 1) l)
	  (list x) 
	  (sublist (+ pos 1) (- (length l) 1) l)))


(defun simplify-division-writer (pos+ pos/ p q conj)
  (let* ((cm-vars (intersection-args p q))
	 (a  (car (set-difference (cdr p) cm-vars)))
	 (v2 (car (set-difference (cdr q) cm-vars)))
	 (v1 (car (last (cdr q))))
	 (x  (car (remove v1 cm-vars)))
	 newplus newtimes)
    (cond ( ;; (a + x) / x
	   (or (equal (list a x v1) (cdr p))
	       (equal (list x a v1) (cdr p)))
	   (setq newplus  (list _number-plus_  v1 1 v2))
	   (setq newtimes (list _number-times_ v1 x a)))
	  (;; (x - a) / x
	   (or (equal (list v1 a x) (cdr p))
	       (equal (list a v1 x) (cdr p)))
	   (setq newplus  (list _number-plus_  v1 v2 1))
	   (setq newtimes (list _number-times_ v1 x a)))
	  (;;(a-x)/x
	   (or (equal (list v1 x a) (cdr p))
	       (equal (list x v1 a) (cdr p)))
	   (setq newplus  (list _number-plus_  v2 1 v1))
	   (setq newtimes (list _number-times_ v1 x a))))

    (replace-at pos/ newtimes (replace-at pos+ newplus conj))))
	    
;;-----------------------------------------------------------------------
;;-----------------------------------------------------------------------
(defun aqit-rewriter-conjunction  (pred conj  ;; original conjunction
					indxpreds-inoutvars) 
  ;; indexed predicates and inoutvars
  (let* ((indxpreds (first indxpreds-inoutvars))
	 (inoutvars (second indxpreds-inoutvars))
	 (lcomp (subset conj (f/l (p) (compound-p p)))) ;; compounds
         sfd
	 tf1 
	 (lncomp (subset conj (f/l (p) (not (compound-p p))))) ;; not compounds
	 tf2)
    (setq *aqit-na* nil)
    (setq *partial-success* nil)
    ;; Pre-processing : Simplify division. TT (11-June-2012)
    ;; Simplify ( a +- x) /x
    (setq sfd (simplify-division-tester lncomp))
    (if sfd (progn (print-cnd "Simplify...") 
		   (print-cnd lncomp) (print-cnd "..to..")))
    (if (neq sfd nil)
	(setq lncomp (simplify-division-writer (first sfd) (second sfd) 
					       (third sfd) (fourth sfd) lncomp)))	
    (if sfd (progn (print-cnd lncomp)))

    ;; Transformation AQIT
    (setq tf1 (aqit-entry pred lncomp indxpreds))
    (cond ((and (null *partial-success*) (null *aqit-na*))
	   ;; Smart ordering on list of indexed predicates
	   (setq indxpreds (smart-ordering-preds indxpreds tf1 inoutvars))
	   ;; Pushdown selection predicates only on core cluster functions
	   (setq tf1 (pushdown-selection-predicates-on-cc  tf1))
	   (setq tf1 (rewrite-distance-based-index  tf1 indxpreds))
	   ;; AQIT rewrite compound
	   (dolist (cmp lcomp)
	     (setq tf2 (aqit-rewriter-compound pred cmp indxpreds-inoutvars))
	     (setq tf1 (append tf1 (list tf2))))))

    ;; 2012-08-30 Return the input if AQIT is N/A
    (if (null *aqit-na*) tf1     
      conj)))

  
(defun aqit-rewriter (pred conj  ;; original conjunction
			     indxpreds-inoutvars) 
                             ;; indexed predicates and inoutvars
			     
  "Distance rewriter consists of two major steps
   I)  Algebaric-query-inequality-transformation (AQIT)
       The AQIT will modified the conjunction
       to formulate Distance < something ( or <=) if possible.
       
       The AQIT is crucially needed for II

   II) Rewrite Distance predicate + inequality predicate ('distance search')
       by index search operation ( AM)
  "
  (aqit-rewriter-compound pred conj indxpreds-inoutvars))


(defun register-aqit-rewriter ()
  "Register AQIT rewriters"
  (dolist (ineqpred _lt-comparisons_)
    (define-late-tr-rewriter (externalize ineqpred) 'aqit-tester 'aqit-rewriter))
  (dolist (ineqpred _gt-comparisons_)
    (define-late-tr-rewriter (externalize ineqpred) 'aqit-tester 'aqit-rewriter)))

;; Register AQIT rewriter
(register-aqit-rewriter)


;; 2012-Mar-22nd
;;     |a| < b
;; <=> (a < b) AND (-a < b)
;; <=> (a < b) AND (a > b)
;; 2012-Mar-23rd
;; Do not transform  |a| > b 

;; Transformation
;; (abs prevvar var)
;; (< var b)
;; <=> AND (< prevvar b) 
;;         (plus var b 0) 
;;         (> prevar  var)



(defun aqit-rewriter-compound  (pred conj indxpreds-inoutvars) 
  (let* (tfconj comp bkconj)    
    (if (compound-p conj)
	(setq comp (first conj)))
    (setq bkconj (if comp (cdr conj) conj))
    (setq tfconj (aqit-rewriter-conjunction pred bkconj indxpreds-inoutvars))
    ;;(help 'KKK)
    ;;(setq tfconj (check-interval-in-conjunction 
    ;;(unify-key-preds (inferequals tfconj) nil)))    
    (if comp (cons comp tfconj) tfconj)))