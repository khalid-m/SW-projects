
(defglobal _aqit-supported-indexes_
  (list nil) "List of AQIT supported indexes")

(defstruct node 
  pred         ; predicate p
  var           
)

(defstruct squeue ;; simple queue
  elements              
)

(defun squeue-push (queue val)
  (setf (squeue-elements queue) (cons val (squeue-elements queue))))

(defun squeue-peek (queue)
  (car (squeue-elements queue)))

(defun squeue-pop (queue)
  (let ((e (squeue-peek queue)))
      (setf (squeue-elements queue) (cdr (squeue-elements queue)))
      e))


(defun indexes-of-kind (fno kind &optional noerror)
  "Return a list of the indexes of a given kind associated with FNO"
  (cond ((relationp fno);; FNO must be a relation
	 (subset (relation-indexes fno);; All indexes of relation FNO
		 (f/l (i)(eq (index-type i)
			     ;; INDEX-TYPE is kind of an index
			     kind))))
        (noerror nil);; return NIL if NOERROR flag true and no index found
        (t (amos-error fno " has no " kind " index"))))

(defun indexed-nodes (conj)
  "Get indexed nodes from given conjunction"
  (let (idxpredl res)    
    (setq idxpredl
	  (subset conj
		  (f/l (p)
		       (and (ilistp p)
			    (or (indexes-of-kind (car p) 'MBTREE t) 
				(indexes-of-kind (car p) 'XTREE t))))))
    
    (dolist (p idxpredl)
	(let* ((pos (index-pos (car (relation-indexes (car p)))))
	       (var (nth pos (cdr p))))	  
	  (setf res (cons (make-node :pred p :var var) res))))
    res))

(defun not-indexed-preds (conj)
  "Return other predicates not indexed ones"
  (let* (l (idxnodes (indexed-nodes conj)))
    (dolist (n idxnodes)
      (setf l (cons (node-pred n) l)))
    (set-difference conj l)))

(defun queue-startnodes (conj)
  "Build a queue of starting nodes (indexed nodes)"
  (let* ((startnodes (indexed-nodes conj))
	 (queue (make-squeue)))
    (dolist (s startnodes)
      (squeue-push queue s))
    queue))


(defun path-complete (path)
  "Return T if path is complete (ending with comparison node)"
  (let ((p (if (neq path nil) 
	       (node-pred (car path))))
	op)
    (and (eq (length p) 3)
	 (memq (setq op (generic-fnname (car p)))
	       '(< <= > >=)))))

(defun stop-moving (path)
  "Return T if path only consists of indexed node and comparison node"
  (and (= (length path) 2)
       (path-complete path)))

(defun path-moveable? (path)
  "Return T if path is moveable"
  (neq (length path) 2))



(defun arithmetic-pred? (pred)
  "Return T if pred is arithemtic predicate"
  (in (first pred) (list _number-plus_ _number-minus_ _number-times_
			 _number-div_ _number-power_ _number-sqrt_ _number-abs_)))


(defun connecting-nodes (path rest)
  "Find among rest, all possible connecting to path"
  (let* ((pred (node-pred (car path)))
	 (var  (node-var (car path)))
	 nextvars cnnnodes)    
    (dolist (p rest)
      (if (and (in var (cdr p))
	       (or (arithmetic-pred? p)
		   (in (car p) _gt-comparisons_)
		   (in (car p) _lt-comparisons_)))
	  (progn 
	    (setq nextvars (subset (set-difference (cdr p) (cdr pred))
				   (f/l (v) (not (osql-constantp v)))))
	    (cond ((neq nextvars nil)
		   (dolist (v nextvars)
		     (setq cnnnodes (cons (make-node :pred p :var v) 
					  cnnnodes))))
		  (t 
		   (setq cnnnodes (cons (make-node :pred p :var nil) cnnnodes)))))))  
    cnnnodes))

;; Accept any number of arguments and bind them into a list vars
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

(defun is-used? (node conj)
  (let ((var (node-var node)))
    (cond ((and (ilistp conj) (neq var nil))
	   (subset conj
		   (f/l (p) (and (ilistp p) (in var (cdr p)))))))))

(defun compound-type (cmp op)
  (and (compound-p cmp) (eq (first cmp) op)))

(defun predicate-plus-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-plus_)))

(defun predicate-times-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-times_)))

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


(defun simplify-division-writer (dv conj)
  (let* ((pos+ (first dv)) (pos/ (second  dv)) (p (third dv)) (q (fourth dv))
	 (cm-vars (intersection-args p q))
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
    ;; New conj = Conj[0, ..., pos+ - 1] + newtimes + newplus
    ;;            Conj[pos/ + 1, length - 1]
    (append (sublist 0 (- pos+ 1) conj)
	    (list newtimes newplus)
	    (sublist (+ pos/ 1) (- (length conj) 1) conj))))