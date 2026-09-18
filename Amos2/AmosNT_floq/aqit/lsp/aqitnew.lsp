(defvar *visited-variables* "visited variables" nil)
(defvar *aqit-solution* 
  "Stored transformed predicated by AQIT. It is also used
   to loop" nil)
(defvar *indexed-variables* "Stored indexed variables" nil)
(defvar *aqit-gcp* "Allow group common predicate" nil)
(defstruct node 
  pred
  arc)
(defun path-to-predicate (path)
  "Return predicate of path"
  (mapcar (f/l (n) (node-pred n)) path))
;;==============================================================================
(defun aqit-rewrite1 (pred)
 "Unitl no change do aqit rewrite" 
  (let ((oldpred pred) newpred change)
    (setq newpred (aqit-rewrite-pred oldpred))
    (while (not (setq change (equal-lists newpred oldpred)))
      (setq oldpred newpred)
      (setq newpred (aqit-rewrite-pred newpred)))
    ;; retain the original pred
    (if (not change) pred newpred)))

; replace definition of aqit-rewrite by aqit-rewrite1
(movd 'aqit-rewrite1 'aqit-fixpoint)
;;==============================================================================
(defun aqit-rewrite-pred (pred) 
  "AQIT rewrite a generic predicate"
  (cond ((atom pred) pred)
	((conjunctionp pred)
	 (aqit-andify (aqit-rewrite-pred (cdr pred))))	   
	((disjunctionp pred)   ;; apply on branches and return the orified results
	 (orify (mapcar (f/l (b) (aqit-rewrite-pred b))
			(cdr pred))))		
	((listp pred) (aqit-rewrite-conjunction pred))))  
;;==============================================================================           
(defun aqit-rewrite-conjunction (conj)
  "AQIT runs on a conjunction of predicates"
  (let* ((allIndxPreds    (find-indexed-preds conj))
	 (allIneqPreds    (find-inequal-preds conj))
	 (*indexed-variables* (find-indexed-variables allIndxPreds))
	 (nexPreds      (not-exposed-indexes allIndxPreds allIneqPreds))
	 (rest (subtract-list conj allIndxPreds))
	 (*visited-variables* (make-hash-table))
	 *aqit-solution*
	 idxpred resl node)
    ;;(help 'me)
    (while (and (not *aqit-solution*)
		*indexed-variables*
		(setq idxpred (pop nexPreds)))      
      (setq node (makenode idxpred))
      (setf (gethash (node-arc node) *visited-variables*) t) ;; visited !
      (phase1_chain (list node) rest))
    ;;(help 'me)
    (cond (*aqit-solution* ;; transformed IIP +  the according rest 
	   ;;(help 'solution)
	   (distribute-pred  (remove idxpred allIndxPreds) *aqit-solution*))
	  (t conj))))
;;==============================================================================
(defun sort-by-length2 (x y)
  (< (length (second x)) (length (second y))))

(defun phase1_chain (path rest)
  "Phase1: By backtracking, phase1_chain tries to chain connecting predicates
   into the path to form iip. When such path is a legal iip, phase2_expose is invoked"
  (cond ((legal-iip? path)
	 ;;(help 'LLL)
	 ;;(setq *aqit-solution* (append (path-to-predicate path) rest))
	 (setq  *aqit-solution* (phase2_expose path rest)))
	(t 
	 (let* ((dt (simplify-division-tester rest)) ;; division test
		(sdrest (if dt (simplify-division-writer dt rest) ;; simplify division
			  rest))
		;; Separate compound predicates and non-compound predicates
		(lorcomp (subset sdrest (f/l (p) (compound-type p 'OR))))
		(landcomp (subset sdrest (f/l (p) (compound-type p 'AND))))
		(lnotcomp (subset sdrest (f/l (p) (not (compound-p p))))))
	   ;; Let path grow in notcomp. If not success, then continue
	   (grow-path path lnotcomp)	   
	   (if *aqit-solution* 
	       (setq *aqit-solution* (append *aqit-solution* lorcomp landcomp))
	     (progn 
	       (grow-path-with-andcomp path landcomp)
	       (if *aqit-solution* 
		   (setq *aqit-solution* (append *aqit-solution* lorcomp lnotcomp))
		 (progn 
		   (grow-path-with-orcomp path lorcomp)
		   ;;(help 'KKK)
		   (if *aqit-solution* 
		       (setq *aqit-solution* (append *aqit-solution* landcomp lnotcomp)))))))))))
;;==============================================================================    
(defun grow-path-with-andcomp (path landcomp)
  (let (gcp) ;; compound predicate which joins with path
    (dolist (acp landcomp)
      (cond ((not *aqit-solution*)
	     (phase1_chain path (cdr acp))
	     (if *aqit-solution* (setq gcp acp)))))
    (if gcp (setq *aqit-solution*
		  (append *aqit-solution* (remove-el gcp landcomp))))))
;;==============================================================================    
(defun distribute-pred (lp l &optional br)
  "Distribute a list lp into each branch of l exculding br"
  (cond ((null l) nil)
	((disjunctionp l)  ;;evenly distribute iip
	 (apply-branches (f/l (b) 
			      (if (not (equal-lists b br))
				  (distribute-pred lp b)
				b))
			 l))
	((conjunctionp l)
	 (unique (aqit-andify (append lp (cdr l)))))		  
	((listp l) 
	 (unique (append lp l)))))

(defun grow-path-with-orcomp (path lorcomp)
  (dolist (orcomp lorcomp)
    (dolist (b (cdr orcomp))
      (cond ((not *aqit-solution*)
	     (phase1_chain path (list b))
	     (cond (*aqit-solution* 
		    (let (nlorp)
		      ;;distribute path into other OR predicates
		      (dolist (orp lorcomp)
			(if (not (equal-lists orp orcomp))
			    (push (distribute-pred (path-to-predicate path) orp) nlorp)
			  (push (replace-branch b 
						(aqit-andify *aqit-solution*) 
						(distribute-pred (path-to-predicate path) orp b))
				nlorp)))
		      ;(help 'him)
		      (setq *aqit-solution* nlorp)))))))))
;;==============================================================================    
(defun grow-path (path ncomp)
  (let* ((lpred ncomp)
	 (n (first path))
	 (lastp (node-pred n))
	 (v (node-arc n)) 
	 p nv l cv)
    ;; Choose connected predicates and weight them
    (while (and (setq p (pop lpred))
		(not *aqit-solution*))
      (cond ((connected? lastp v p)
	     ;; next vars which are not visited
	     (setq nv (subset (set-difference (cdr p) (cdr lastp))
			      (f/l (v) 
				   (and (not (osql-constantp v))
					(not (gethash v *visited-variables*))))))
	     ;; keep track all candidates to be judged
	     (setq l (nconc1 l (list p nv))))))
    ;;(help 'LLL)
    ;;HEURISTIC : Weight predicates by common variables, iteratively take the light one
    ;; to avoid explosive Depth First Search
    (setq l (sort l #'sort-by-length2))    
    (dolist (pcv l) ;; (p cv)
      (cond ((not *aqit-solution*)
	     ;; iteratively try outgoing variables until one succedeeded !!
	     (setq p (first pcv))
	     (setq nv (second pcv));; list connected vars
	     (if nv
		 (while (and (setq cv (pop nv))
			     (not *aqit-solution*))
		   (phase1_chain (cons (make-node :pred p :arc cv) path)
				 (remove p ncomp)))
	       (phase1_chain (cons (make-node :pred p :arc nil) path)
			     (remove p ncomp))))))))      
;;==============================================================================
(defun update-iip (iip resl)
  "Return new iip"
  ;; Update iip: - remove inequality node, arithmetic node
  ;;             - add    new inequality node 
  (cons (make-node :pred (first resl) :arc nil) (cdr (cdr iip))))

(defun update-rest (iip rest resl)
  "Return new rest"
  (let (newrest (arithnode (second iip)))
    ;; Update rest
    (setq newrest (append rest (cdr resl)))
    ;; If the arithmetic predicate is a shared predicate, clone it !!
    (if (common-predicate (node-pred arithnode)  (node-arc arithnode) rest)
	(setq newrest (cons (node-pred arithnode) newrest)))
    newrest))
;;==============================================================================
(defun phase2_expose (iip rest)
  "Phase2: Expose the index by interactively applying transformation rule on
   the first two nodes of iip"
  (if (exposed-iip? iip) (append (path-to-predicate iip) rest)
    (let* (resl (compnode (first iip))
		(arithnode (second iip))
		(prevnode (third iip)) newiip newrest)
      (setq resl (apply_transformation arithnode compnode  prevnode rest)) 
      ;(help 'you)
      (cond ((null resl)  nil)
	    ((disjunctionp resl) ;; it introduces OR !! Continue transformation on each branch
	     (orify (mapcar (f/l (b) 
				 (setq newiip (update-iip iip b))
				 (setq newrest (update-rest iip rest b))
				 (phase2_expose newiip newrest))
			    (cdr resl))))
	    (t (setq newiip (update-iip iip resl))
	       (setq newrest (update-rest iip rest resl))
	       ;; Continute exposing
	       (phase2_expose newiip  newrest))))))

;;===================================================================
(defun apply_transformation (arithnode compnode prevnode ref)
  (let* ((comppred (node-pred compnode))
	 (arithpred (node-pred arithnode))
	 (arithop (predicate-operator arithpred))
	 (compop (predicate-operator comppred))
	 (var (node-arc arithnode))
	 (prevvar (node-arc prevnode))
	 (A (car (remove var (remove prevvar (rest arithpred)))))
	 (B (car (remove var (rest comppred))))
	 (nv (dt_genvar (type_of_var var *bindings*)))
	 nv1
	 (arithvars (cdr arithpred)))
    ;;---PLUS and MINUS---
    ;; a1.(var = A - prevvar) AND (var theta B) ==> (A-B) theta prevvar
    ;; a2.(var = A - prevvar) AND (B  theta var) ==> prevvar theta (A - B)
    ;; Replace var by nv, replace B by prevvar
    (cond ((and (eq arithop _number-plus_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A))))
	   (list (subst prevvar B (subst nv var comppred))
		 (make-predicate _number-plus_ nv B A)))
	  ;; b1.(var =  prevvar - A) AND (var  theta B)==> prevvar  theta (A + B)
	  ;; b2.(var =  prevvar - A) AND (B  theta var)==> B+A theta prevvar
	  ((and (eq arithop _number-plus_)
		(or (equal arithvars (list A var prevvar))
		    (equal arithvars (list var A prevvar))))
	   (list (subst prevvar var (subst nv B comppred))
		 (make-predicate _number-plus_ A B nv)))
	  ;; c1. (var = prevvar + A) AND (var theta B) ==> prevvar theta B - A    
	  ;; c2. (var = prevvar + A) AND (B theta var) ==> B-A theta prevvar
	  ((and (eq arithop _number-plus_)
		(or (equal arithvars (list A prevvar var))
		    (equal arithvars (list prevvar A var))))
	   (list (subst prevvar var (subst nv B comppred))
		 (make-predicate _number-plus_ nv A B)))
	  ;; ---TIMES (prevvar * A) AND A > 0
	  ;; d1a.(prevvar* A) AND (var theta B) AND A >0
	  ;; ==> (prevvar theta B/A)
	  ;; d1b.(prevvar* A) AND (B theta var) AND A >0
	  ;; ==> (B/A theta prevvar)
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list prevvar A var))
		    (equal arithvars (list A prevvar var)))
		(is-positive? A ref))	   
	   (list (subst prevvar var (subst nv B comppred))            
		 (make-predicate _number-times_ nv A B)))	  
	  ;; d2.a(prevvar* A) AND (var theta B) AND A <0
	  ;; ==> (prevvar theta' B/A)
	  ;; d2.a(prevvar* A) AND (B theta var) AND A <0
	  ;; ==> (B/A theta' prevvar)
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list prevvar A var))
		    (equal arithvars (list A prevvar var)))
		(is-negative? A ref))	   
	   (list (subst (inverse-comp compop) compop 
			(subst prevvar var (subst nv B comppred)))
		 (make-predicate _number-times_ nv A B)))
	  ;; d3.a(prevvar* A) AND (var theta B)
	  ;; ==> [OR (prevvar theta B/A) AND A > 0
	  ;;         (prevvar theta' B/A) AND A < 0] 
	  ;; d3.a (prevvar* A) AND (B theta var)
	  ;; ==> [OR (B/A theta prevvar) AND A > 0
	  ;;         (B/A theta' prevvar) AND A < 0] 
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list prevvar A var))
		    (equal arithvars (list A prevvar var))))   
	   (orify (list (list (subst prevvar var (subst nv B comppred))
			      (make-predicate _number-times_ nv A B)
			      (make-predicate _>_ A 0))			
			(list (subst (inverse-comp compop) compop 
				     (subst prevvar var (subst nv B comppred)))
			      (make-predicate _number-times_ nv A B)
			      (make-predicate _<_ A 0)))))
	  ;; ---DIV A is divisor (prevvar / A) A is positive
	  ;; d4a.(prevvar/ A) AND (var theta B) AND A >0
	  ;; ==> (prevvar theta B*A)
	  ;; d4b.(prevvar/ A) AND (B theta var) AND A >0
	  ;; ==> (B*A theta prevvar)
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var A prevvar))
		    (equal arithvars (list A var prevvar)))
		(is-positive? A ref))	   
	   (list (subst prevvar var (subst nv B comppred))
		 (make-predicate _number-times_ A B nv)))
	  ;; ---DIV A is divisor (prevvar / A) A is negative
	  ;; d4c.(prevvar/ A) AND (var theta B) AND A <0
	  ;; ==> (prevvar theta' B/A)
	  ;; d4d.(prevvar/ A) AND (B theta var) AND A <0
	  ;; ==> (B*A theta' prevvar)
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var A prevvar))
		    (equal arithvars (list A var prevvar)))
		(is-negative? A ref))
	   (list (subst (inverse-comp compop) compop 
			(subst prevvar var (subst nv B comppred)))
		 (make-predicate _number-times_ A B nv)))
	  ;; ---DIV A is divisor (prevvar / A) A is not known
	  ;; d4e.(prevvar/ A) AND (var theta B) 
	  ;; ==> [OR (prevvar theta B*A A > 0)
	  ;;         (prevvar theta' B*A A < 0)]
	  ;; d4f.(prevvar/ A) AND (B theta var) 
	  ;; ==> [OR (B*A theta prevvar  A > 0)
	  ;;         (B*A theta' prevvar A < 0)]
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var A prevvar))
		    (equal arithvars (list A var prevvar))))
	   (orify (list (list (subst prevvar var (subst nv B comppred))
			      (make-predicate _number-times_ A B nv)
			      (make-predicate _>_ A 0))			
			(list (subst (inverse-comp compop) compop 
				     (subst prevvar var (subst nv B comppred)))
			      (make-predicate _number-times_ A B nv)
			      (make-predicate _<_ A 0)))))
	  ;;===================================================================
	  ;;--- DIV A is dividen (A / prevvar) AND B = 0
	  ;; d5.a (var= A/prevvar) AND (var theta 0) AND A is positive
	  ;;==> (prevvar theta 0) 
	  ;; d5.b (var= A/prevvar) AND (0 theta var) AND A is positive
	  ;;==> (0 theta prevvar) 
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A)))
		(eq B 0)
		(is-positive? A ref))
	   (list (subst prevvar var (subst nv B comppred))))
	  ;; d5.c (var= A/prevvar) AND (var theta 0) AND A is negative
	  ;;==> (prevvar theta' 0) 
	  ;; d5.d (var= A/prevvar) AND (0 theta var) AND A is negative
	  ;;==> (0 theta' prevvar) 
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A)))
		(eq B 0)
		(is-negative? A ref))   	   
	   (list (subst (inverse-comp compop) compop 
			(subst prevvar var (subst nv B comppred)))))	  
 	  ;; d5.e (var= A/prevvar) AND (var theta 0) 
	  ;;==> [OR (prevvar theta 0 AND A is positive)
	  ;;        (prevvar theta' 0 AND A is negative)]
	  ;; d5.f (var= A/prevvar) AND (0 theta var) 
	  ;;==> [OR (0 theta prevvar AND A is positive)
	  ;;        (0 theta' prevvar AND A is negative)]
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A)))
		(eq B 0))
	   (orify (list 
		   (list (subst prevvar var (subst nv B comppred))
			 (make-predicate _>_ A 0))
		   (list (subst (inverse-comp compop) compop 
				(subst prevvar var (subst nv B comppred)))
			 (make-predicate _<_ A 0)))))
	  ;;--- DIV A is dividen (A / prevvar) AND B != 0
	  ;; d6.a (var=A/prevvar) AND (var theta B)
	  ;;==> or - A theta  B* prevvar , prevvar > 0
	  ;;       - A theta' B* prevvar , prevvar < 0
	  ;;==> or -  A/B theta  prevvar , prevvar > 0, B > 0
	  ;;       -  A/B theta'  prevvar , prevvar > 0, B < 0
	  ;;       -  A/B theta' prevvar , prevvar < 0, B > 0
	  ;;       -  A/B theta prevvar , prevvar < 0, B < 0
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A)))
		(not (eq B 0))
		(eq B (third comppred)))
	   (orify (list 
		   (list (make-predicate compop nv  prevvar)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _>_ prevvar 0)
			 (make-predicate _>_ B 0))
		   (list (make-predicate (inverse-comp compop) nv  prevvar)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _>_ prevvar 0)
			 (make-predicate _<_ B 0))
		   (list (make-predicate (inverse-comp compop) nv  prevvar)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _<_ prevvar 0)
			 (make-predicate _>_ B 0))
		   (list (make-predicate compop nv  prevvar)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _<_ prevvar 0)
			 (make-predicate _<_ B 0)))))
	  ;; d6.b (var=A/prevvar) AND (B theta var)
	  ;;==> or -  B* prevvar theta  A , prevvar > 0
	  ;;       -  B* prevvar theta' A, prevvar < 0		   
	  ;;==> or -  prevvar theta  A/B , prevvar > 0, B > 0
	  ;;       -  prevvar theta' A/B , prevvar > 0, B < 0
	  ;;       -  prevvar theta' A/B , prevvar < 0, B > 0
	  ;;       -  prevvar theta  A/B , prevvar < 0, B < 0
	  ((and (eq arithop _number-times_)
		(or (equal arithvars (list var prevvar A))
		    (equal arithvars (list prevvar var A)))
		(not (eq B 0))
		(eq B (second comppred)))
	   (orify (list 
		   (list (make-predicate compop  prevvar nv)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _>_ prevvar 0)
			 (make-predicate _>_ B 0))
		   (list (make-predicate (inverse-comp compop) prevvar nv)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _>_ prevvar 0)
			 (make-predicate _<_ B 0))
		   (list (make-predicate (inverse-comp compop) prevvar nv)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _<_ prevvar 0)
			 (make-predicate _>_ B 0))
		   (list (make-predicate compop  prevvar nv)
			 (make-predicate _number-times_ nv B A)
			 (make-predicate _<_ prevvar 0)
			 (make-predicate _<_ B 0)))))
	  ;; ---  SQRT ---
	  ((eq arithop _number-sqrt_)
	   ;; SQRT(prevvar)  theta B ==> prevvar  theta (power B 2)
	   (list (make-predicate compop prevvar nv)
		 (make-predicate _number-power_ B 2 nv)))
	  ;; ---  POWER ---
	  ((eq arithop _number-power_)
	   ;; Power(prevvar, A)  theta B ==> prevvar  theta (power B 1/A)
	   (setq nv1 (dt_genvar (type_of_var var *bindings*)))
	   (list (make-predicate compop prevvar nv)
		 (make-predicate _number-times_ nv1 A 1)
		 (make-predicate _number-power_ B nv1 nv)))	
	  ;; ---  ABS ---
	  ((eq arithop _number-abs_)
	   (cond ((or (eq compop _<_) (eq compop _<=_))
		  ;; ABS (prevvar) < B ==> prevvar > - B and prevvar < B
		  (list (make-predicate compop prevvar B)
			(make-predicate _number-plus_ nv B 0)
			(make-predicate (inverse-comp compop) prevvar nv)))
		 ((or (eq compop _>_) (eq compop _>=_))		  
		  ;; ABS (prevvar) > B ==> prevvar > B or prevvar < - B
		  (orify (list
			  (list (make-predicate compop prevvar B))
			  (list (make-predicate (inverse-comp compop) 
						prevvar nv)
				(make-predicate _number-plus_ nv B 0)
			  ))))
		  )))))	
