;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, Minpeng Zhu UDBL
;;; $RCSfile: numwrapper.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/05/01 15:35:27 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Numerical expression involving inequality should
;; be pushed to SQL string if possible
;;; =============================================================

(defun numericalp (pred)
  "TRUE if pred is in sqloperator table and has return value. e.g (plus, minus,
   times, div, sqrt, abs)"
  (cond ((leaf-predicate-p pred)
	 (let ((predname (oid-name (predicate-operator pred)))
	       (numpredlist (mapcar (f/l (l) (getobject (car l) 'name))
				    (getfunction 'sqlop_hasvalue (list)))))
	   (memq predname numpredlist)))))


(defun get-arithpred (arg sqlq)
  "get the numerical predicate containing arg"
  (let ((varpredassnlst (sqlquery-varpredassnlst sqlq)) 
	)
    (if varpredassnlst
	(lastelem (assq arg varpredassnlst));;the arithmetic pred binds arg
      (error "not arithmetic pred is matched for " arg))))


(defun constant-arrayp (a)
  "check every elements in array is constant"
  (and (arrayp a)
       (every (f/l (e) (constantp e)) (arraytolist a))))

(defun element-in-array-to-string (e last)  
  (concat (if (stringp e) "'" "")  e (if (stringp e) "'" "")  (if (not last) "," "")))

(defun constant-array-to-string (a)
  "transform array, e.g #('Robert' 'Bruce' 'Kim') to ('Robert','Bruce','Kim')"
  (let* ((l (arraytolist a))
	(end (car (last l))))
    (concat "("
	    ;; all elements but not last
	    (apply 'concat (mapcar (f/l (e)
					(element-in-array-to-string e nil))
				   (butlast l)))
	    (element-in-array-to-string end t)
	    ")")))

(defun reverse-args (pred reverse)
  "reverse the arguments in pred if reverse flag is true. 
   e.g, transform VECTOR.IN->OBJECT to object in vector"
  (if (is-true reverse)
      (cons (car pred) (reverse (cdr pred)))
    pred))
 
(defun sql-infer-call (arithpred op infix q but-not tablealiases)
  "Construct call to infix SQL function"
  (let ((pos (car (list-positions but-not arithpred)))
	args)
    ;;(+ salary 5000), (1 salary)
    (setq args (sql-literal-strings q (remove but-not arithpred) tablealiases))
 
    (cond ((is-true infix);;infix
	   (if (equal op "+")
	       (setq op (cond ((eq pos 3) "+") ((eq pos 2) "-") 
			      ((eq pos 1) "-"))))
	   (if (equal op "*")
	       (setq op (cond ((eq pos 3) "*") ((eq pos 2) "/") 
			      ((eq pos 1) "/"))))
	   (if (or (eq pos 2) (eq pos 1))
	       (setq args (reverse args)))
	   (concat "(" (concat (infix-string op args)) ")")) 
	  (t ;;e.g prefix this code seems belong to prefix-string
	   (prefix-string (predicate-operator arithpred) args)))
))
 
