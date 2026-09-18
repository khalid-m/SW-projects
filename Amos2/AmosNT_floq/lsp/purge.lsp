;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson
;;; $RCSfile: purge.lsp,v $
;;; $Revision: 1.7 $ $Date: 
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The algorithm to purge unneccesary vaiables from
;;;              a coerced predicate
;;; =============================================================
;;; $Log: purge.lsp,v $
;;; Revision 1.7  2008/12/25 19:28:46  torer
;;; Generalized to handle disjunctions
;;;
;;; Revision 1.6  2007/11/16 13:47:59  torer
;;; Purging dummy constructors
;;;
;;; Revision 1.5  2007/02/19 11:05:05  torer
;;; Inverse of rfft defined
;;;
;;; Revision 1.4  2006/04/07 07:25:36  torer
;;; Derived multi-directional definitions supported
;;;
;;; =============================================================
(defglobal _verbose-purge_ nil)

(defun purge-void-preds (pred sb)
  "Performs a fix-point iteration of alternating removal of variables
   and removal of predicates. purge-variables replaces unneccesary
   variables by stars and purge-predicate removes those predicates
   that have no effect of some argument is a star. For example the
   function decode function, which always succeeds and therefore has no
   effect if one argument is a star"
  (do* ((old-pred pred new-pred)
	(new-pred (purge-predicates (purge-variables old-pred sb))
		  (purge-predicates (purge-variables old-pred sb))))
      ((equal new-pred old-pred) new-pred)))

(defun purge (predl sb)
  "Backward compatability"
  (argsof 'and (purge-void-preds (andify predl) sb)))

(defun purge-predicates (p)
  "Purges unneeded predicates from the predicate P"
  (map-over-pred p (f/l (sp)(if (redundant-predicate sp) 'true sp))
		 'id))

(defglobal _bijective-function_ nil)

(defun redundant-predicate (p)
  "True if this predicate is redundant-predicate wrt its  arguments."
  (and (listp p)
       (let ((genfn (generic-function-of (predicate-operator p))))
	 (or _bijective-function_ 
	     (setq _bijective-function_
		   (getfunctionnamed 'function.bijective_function->boolean t)))
	 (cond ((null genfn) nil)
	       ((dynconstructorfn genfn)(eq (second p) '*))
	       ((and _bijective-function_ (memq '* (predicate-arguments p)))
		(proccall _bijective-function_ (vector genfn)))))))

(defun purge-variables (predicate sb)
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
    
(defun replace-by-dummies (variables predicate)
  "Replace any occurance of the variables in the predicate with 
   dummy variables *."
  (map-over-pred predicate (f/l (p) (substl '* variables p))
		 'id))
			  
(defun get-singleton-variables (predicate)
  "Get all singleton variables out of a predicate"
  (let ((vars (make-hash-table)) res)
    (mappred predicate 
	     (f/l (x)
		  (cond ((osql-variablep x)(inc-ht-cnt vars x))
                        ((consp x)(dolist (v (cdr x))
				    (if (osql-variablep v)
					(inc-ht-cnt vars v)))))))
    (maphash (f/l (var cnt)(if (= cnt 1)(push var res))) vars)
    res))

(defun inc-ht-cnt (ht key)
  (setf (gethash key ht) (1+ (or (gethash key ht) 0))))