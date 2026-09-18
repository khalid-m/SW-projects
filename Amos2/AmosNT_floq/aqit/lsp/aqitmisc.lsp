(defun indexes-of-kind (fno kind &optional noerror)
  "Return a list of the indexes of a given kind associated with FNO"
  (cond ((relationp fno);; FNO must be a relation
	 (subset (relation-indexes fno);; All indexes of relation FNO
		 (f/l (i)(eq (index-type i)
			     ;; INDEX-TYPE is kind of an index
			     kind))))
        (noerror nil);; return NIL if NOERROR flag true and no index found
        (t (amos-error fno " has no " kind " index"))))

(defun find-indexed-variables (lpreds)
  "Return list of all indexed variables in a conjunction"
    (if (and (ilistp lpreds) 
	     (not (predicate-p lpreds)))
	(let (res idx idxvars v)
	  (mapcar (f/l (p)
		       (cond ((relationp (car p))
			      (dolist (type (cons 'MBTREE _aqit-supported-indexes_))
				(setq idx (indexes-of-kind (car p) type t))
				(dolist (i idx)
				  (setq v (predicate-argument (+ (index-pos i) 1) p))
				  (setq idxvars (adjoin v idxvars)))))
			     ((core-cluster-fn? (car p))
			      (setq idx (get-ccindex (car p)))
			      (setq v (nth (+ (ccindex-pos idx) 1) p))
			      (setq idxvars (adjoin v idxvars)))))
		  lpreds)
	  ;; remove nil and duplicate
	  (unique (remove_nil idxvars)))))

(defun find-indexed-preds (conj)
  "Get list of indexed pred from given conjunction"
  (let ((instances (make-hash-table));; self join makes several instances of the same relations    
	lidxpreds) 
    (mapcar (f/l (p)
		 (if (and (ilistp p)
			  (or (get-ccindex (car p))
			      (some (f/l (type) 
					 (and (neq type nil) (indexes-of-kind (car p) type t)))
				    (cons 'MBTREE _aqit-supported-indexes_))))		      
		     ;; only if not exists
		     (if (null (gethash (car p) instances))
			 (setf (gethash (car p) instances) p))))
	    conj)
    (maphash (f/l (inst p)
		  (setq lidxpreds (cons p lidxpreds)))
	     instances)
    lidxpreds))

(defun find-inequal-preds (conj)
  "Find inequality (comparison) predicates"
  (subset conj (f/l (p) 
		    (and (predicate-p p)
			 (or (in (car p) _gt-comparisons_)
			     (in (car p) _lt-comparisons_))))))

(defun not-exposed-indexes (idxpreds ineqpreds)
  "Find not exposed indexed predicates"
  (subset idxpreds
	  (f/l (p)
	       ;; if some inequality preds directly define 
	       ;; over any indexed variables.
	       (let ((iv (intersection (cdr p) *indexed-variables*)))
		   (and iv (notany (f/l (q) 
					(intersection iv (cdr q)))
				   ineqpreds))))))

(defun makenode-from-indexed-predicate (p)
  "Make node from indexed predicate"
  (let* ((idx (get-ccindex (car p)))
	 pos var) 
    (if (null idx) 
	(progn 
	  (setq idx (car (relation-indexes (car p))))
	  (setq pos (index-pos idx))
	  (setq var (nth pos (cdr p))))
      (progn
	(setq pos (ccindex-pos idx))
	(setq var (nth pos (cdr p)))))
    (make-node :pred p :arc var)))

(defun makenode (p)
  "Make the first node of a path"
  (if (some (f/l (type) 
		 (and (neq type nil) (indexes-of-kind (car p) type t)))
	    _aqit-supported-indexes_)
      (make-node :pred p :arc (car (last p)))
    (makenode-from-indexed-predicate p)))

(defun subtract-list (x y)
  "list subtractation x - y"
  (subset x (f/l (e) (not (member e y)))))

(defun iip-to-predicate (iip)
  "Return predicate of iip"
  (mapcar (f/l (n) (node-pred n)) iip))

(defun legal-iip? (iip)
  "Return T if iip ends with inequality comparison node"
  (let ((p (if (neq iip nil) 
	       (node-pred (car iip))))
	op)
    (and (eq (length p) 3)
	 (memq (setq op (generic-fnname (car p)))
	       '(< <= > >=)))))

(defun exposed-iip? (iip)
  "Return T if the index is already exposed"
  (or (and (legal-iip? iip)
	   (= (length iip) 2))
      (and (legal-iip? iip)
	   (= (length iip) 3)
	   (let* ((node (second iip))
		  (p (node-pred node)))
	     (in (predicate-operator p) _distance-predicates_)))))

(defun arithmetic-pred? (pred)
  "Return T if pred is arithemtic predicate"
  (in (first pred) (list _number-plus_ _number-minus_ _number-times_
			 _number-div_ _number-power_ _number-sqrt_ _number-abs_)))

(defun connected? (p var q)
  "If p and q is connected via var, return next candidate variables"
  (and 
   (in var (cdr q))
   (or (arithmetic-pred? q)    
       (in (car q) _distance-predicates_)
       (and (or (in (car q) _gt-comparisons_)
		(in (car q) _lt-comparisons_))
	    (not (in (car (remove var (cdr q))) *indexed-variables*))))))

(defun outgoing-arc (p q)
  "Outgoing arc (variables)"
  (subset (set-difference (cdr q) (cdr p))
	  (f/l (v) (not (osql-constantp v)))))


(defun compound-type (cmp op)
  (and (compound-p cmp) (eq (first cmp) op)))

(defun remove_nil (l)
  "Remove NIL in list l"
  (mapfilter (f/l (i) (neq i nil)) l))

(defun make-predicate (op &rest vars)
  "Make a predicate from given op and list of vars"
  (cons op vars))

(defun inverse-comp (ineq)
  "From GT/GE to LT/LE and vice versa."
  (cond ((eq ineq _>_)  _<_);; GT -->LT
	((eq ineq _>=_) _<=_);; GE -->LE
	((eq ineq _<_)  _>_);; LT -->GT
	((eq ineq _<=_) _>=_);; LE -->GE
	(t ineq))) ;; Otherwise leave as it is

(defun common-predicate (p v l)
  "p is common predicate in l if its variable v is used
   in some predicates in l"
  (and (ilistp l) 
       (neq v nil)
       (subset l (f/l (q) (and (ilistp q) (in v (cdr q)))))))

(defun apply-branches (fn disjunc)
  "Apply fn on all branches and orify the results"
  (orify (mapcar (f/l (b)
		      (apply fn (list b)))
		 (cdr disjunc))))

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
			      (intersection-args p q))
			  ;; should not be constant
			  ;; since it is the result of PLUS 
			  (not (constantp (car (last q))))			  
			  )
		     (setq res (list pos+ pos/))))		     		     
	      (setq pos/ (+ pos/ 1)))))
     (setq pos+ (+ pos+ 1)))
   res))


(defun simplify-division-writer (dv conj)
  (let* ((pos+ (first dv)) 
	 (pos/ (second  dv)) 
	 (oplus (nth pos+ conj))
	 (otimes (nth pos/ conj))
	 (cm-vars (intersection-args oplus otimes))
	 (a  (car (set-difference (cdr oplus) cm-vars)))
	 (v2 (car (set-difference (cdr otimes) cm-vars)))
	 (v1 (car (last (cdr otimes))))
	 (x  (car (remove v1 cm-vars)))
	 newplus newtimes newconj)
    ;;(help 'OOO)
    (cond ( ;; (a + x) / x
	   (and (or (equal (list a x v1) (cdr oplus))
		    (equal (list x a v1) (cdr oplus)))
		(or (equal (list v2 x v1) (cdr otimes))
		    (equal (list x v2 v1) (cdr otimes))))
		 
	   (setq newplus  (list _number-plus_  v1 1 v2))
	   (setq newtimes (list _number-times_ v1 x a)))
	  (;; (x - a) / x
	   (and (or (equal (list v1 a x) (cdr oplus))
		    (equal (list a v1 x) (cdr oplus)))
		(or (equal (list v2 x v1) (cdr otimes))
		    (equal (list x v2 v1) (cdr otimes))))
	   (setq newplus  (list _number-plus_  v1 v2 1))
	   (setq newtimes (list _number-times_ v1 x a)))
	  (;;(a-x)/x
	   (and (or (equal (list v1 x a) (cdr oplus))
		    (equal (list x v1 a) (cdr oplus)))
		(or (equal (list v2 x v1) (cdr otimes))
		    (equal (list x v2 v1) (cdr otimes))))
	   (setq newplus  (list _number-plus_  v2 1 v1))
	   (setq newtimes (list _number-times_ v1 x a)))
	  (t 
	   (setq newplus  oplus)
	   (setq newtimes otimes)))
    ;; Use newtimes, newplus instead of the odd ones
    (setq newconj (subst newtimes otimes conj))
    (subst newplus  oplus newconj)))


(defun member-of-list (x l)
  "x is member of list l"
  (some (f/l (e) 
	     (equal-lists x e)) l))
   
(defun equal-lists (l1 l2)
  "Compare two lists regardless ordering"
  ;; disjunctions ?
  (cond ((and (compound-type l1 'OR)
	      (compound-type l2 'OR))
	 (equal-lists (cdr l1) (cdr l2)))
	;; conjunctions
	((and (compound-type l1 'AND)
	      (compound-type l2 'AND))
	 (equal-lists (cdr l1) (cdr l2)))
	;; lists ?
	((and (listp l1)
	      (listp l2)
	      (= (length l1) (length l2)))
	 (every (f/l (i)
		     (member-of-list i l2))
		l1))
	;; basic types
	(t (equal l1 l2))))
;;====================================================
(movd 'find-indexed-preds 'aqit-find-indexed-preds)
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
			    (>= (second p) 0)))
		      		      ;; result of ABS
		      (and (eq (car p) _number-abs_)
			   (eq v (car (last p))))
		      ;; result of distance computation
		      (and (in (predicate-operator p) _distance-predicates_)
			   (eq v (car (last p))))
		      ))			      
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
       
(defun aqit-gcp (pred)
  "Pull up common predicates"
  (cond ((atom pred) pred)
	((conjunctionp pred) pred)
	((disjunctionp pred) 
	 (let* ((cpreds (intersectionl (cdr pred)));; common predicates
		newb newpred)
	   (setq cpreds (remove 'AND cpreds))
	   ;; remove common preds in all branches
	   (setq newpred
		 (orify (mapcar (f/l (b) 
				      ;; conjunction / disjunction/list of predicates
				     (if (or (disjunctionp b)
					     (conjunctionp b)
					     (and (listp b)
						  (predicate-p (first b))))
					 (set-difference b cpreds)
				       b))
				(cdr pred))))
	   (andify (append cpreds (list newpred)))))))			   

(defun aqit-andify (pred)
  "andify a list of predicates"
  (cond ((and (not (atom pred))
	      (not (disjunctionp pred))
	      (not (conjunctionp pred))
	      (listp pred))
	 (andify pred))
	(t pred)))
		     
(defun get-ql (fname)
  "Get query plan of fname"
  (if (neq fname nil)
      (let* ((fn (getfunctionnamed fname t)) ;; no error if not exists
	    (rslv (car (resolvents fn))))    ;; the first resolvent by default
	(if rslv 
	    (selectbody-optpred (getselectbody  rslv))))))


(defun query-contain (ql fc)
  "True if query plan ql contains function call fc"  
  (let (lpreds)
    (setq lpreds 
	  (cond ((atom ql))
		((conjunctionp ql) (cdr ql))
		((disjunctionp ql) (cdr ql))
		((listp ql) ql)))
    (some (f/l (p)
	       (if (conjunctionp p)
		   (query-contain (cdr p) fc)
		 (member-of-list fc p))) lpreds)))

(defun remove-branch (b orpred)
  "Remove branch b in orpred"
  (if (compound-type orpred 'OR)
      (orify (remove_nil (mapcar (f/l (br)
				      (if (equal-lists b br) nil br))
				 (cdr orpred))))))

(defun replace-branch (b nb orpred)
  "Remove branch b in orpred by nb"
  (if (compound-type orpred 'OR)
      (orify (mapcar (f/l (br)
			  (if (equal-lists b br) nb br))
		     (cdr orpred)))))

(defun remove-el (x l &optional fn)
  "Remove x from list l using fn as comparison function"
  (if (null fn) (setq fn 'equal-lists))
  (if (ilistp l)
      (mapfilter (f/l (e)
		      (not (apply fn (list x e))))
		 l)))

(defun replace-el (x y l &optional fn)
  "Replace x by y from list l using fn as comparison function"
  (if (null fn) (setq fn 'equal-lists))
  (if (ilistp l)
      (mapcar (f/l (e)
		   (if (apply fn (list x e)) y e))
	      l)))