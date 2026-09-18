;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2010 Silvia Stefanova, UDBL
;;; $RCSfile: purge1.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:24:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Get-singleton-variable for an OR predicate
;;;;;; ===========================================================================



(defun get-singleton-variables (predicate)
  (cond 
   ((atom predicate) (get-singleton-variables1 predicate));;if predicate is an atom 
   ((neq (car predicate) 'or) (get-singleton-variables1 predicate));;if predicate is not a disjunction
   ((null (cddr predicate)) (get-singleton-variables1 (cadr predicate )));;if it is only one disjunct
   (t 
    (let ( (res nil)
	   (res1 nil))
      (dolist (con (cdr predicate) res)
	(setf res1 (get-singleton-variables1 con))
	(setf res (mergel res1 res (function =))))))))
	


(defun get-singleton-variables1 (predicate)
  "Get all singleton variables out of a conjunctive predicate"
  (let ((vars (make-hash-table)) res)
    (mappred predicate 
	     (f/l (x)
		  (cond ((osql-variablep x)(inc-ht-cnt vars x))
                        ((consp x)(dolist (v (cdr x))
				    (if (osql-variablep v)
					(inc-ht-cnt vars v)))))))
    (maphash (f/l (var cnt)(if (= cnt 1)(push var res))) vars)
    res))


(defun purge-variables-org (predicate sb)
  "The original purge-value"
  "remove unnecesary variables from the coerced predicate
   of the select body.

   A necessary and sufficient (for the purpose of the core
   cluster rewriter) criterion for a varible to be deemed 
   unnecessary is: The variable v is unnecessary if

     a) It is not an output variable (v does not appear
        unbound in the goal of the predicate.

     b) It is not an input variable (v does not appear
        bound in the goal of the predicate.

     c) v is a singleton variable.
   The algorithm computes the singleton variables and then
   removes output and input variables."
  (let* ((protected-vars (selectbody-argresl sb))
	 (unneeded-vars (set-difference 
			 (get-singleton-variables predicate)
			 protected-vars)))
    (cond ((= _verbose-purge_ 2)
	   (print "Variables are about to be purged")
	   (print "before:")
	   (print predicate)
	   (print "after:")
	   (print (replace-by-dummies unneeded-vars predicate))
	   (print "unneeded variables")
	   (print unneeded-vars))
	  ((= _verbose-purge_ 1)
	   (print "purge invoked")))
    (replace-by-dummies unneeded-vars predicate)))


(defun purge-variables (predicate sb)
 "Purge-value for an OR predicate, calling the
  original purge-value for each disjunct"
  (let* ((protected-vars (selectbody-argresl sb))
	 (res nil))
    (cond 
     ((atom predicate) (purge-variables-org predicate sb))
     ((neq (car predicate) 'or) (purge-variables-org predicate sb));;if predicate is not a disjunction
     ((null (cddr predicate)) (purge-variables-org (cadr predicate ) sb));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((unneeded-vars (set-difference 
				 (get-singleton-variables1 con)
				 	 protected-vars))
	      (res1 nil))
	  (setf res1 (replace-by-dummies unneeded-vars con))
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


