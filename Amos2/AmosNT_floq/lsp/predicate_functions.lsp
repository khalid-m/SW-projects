;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson
;;; $RCSfile: predicate_functions.lsp,v $
;;; $Revision: 1.12 $ $Date: 
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Primitive and not-so-primitive functions 
;;;              operating on predicates.
;;; =============================================================
;;; $Log: predicate_functions.lsp,v $
;;; Revision 1.12  2012/04/24 14:59:53  torer
;;; Using COMPOUND-P
;;;
;;; Revision 1.11  2010/01/06 15:29:55  torer
;;; CommonLisp standard (append x nil) used for copying top levels of lists
;;;
;;; Revision 1.10  2008/12/25 19:27:54  torer
;;; Removed obsolete functions
;;;
;;; Revision 1.9  2007/11/16 13:46:32  torer
;;; Degenerate case
;;;
;;; Revision 1.8  2006/04/10 20:25:25  torer
;;; Removed PREDICATE-KEY-ARGUMENTS (not valid)
;;;
;;; Revision 1.7  2006/03/29 16:53:34  torer
;;; Minor performance improvement
;;;
;;; =============================================================

(defun fold-predicate (fn p)
  "Apply fn to each leaf predicate in p and append the results together."
  (visit-predicate (f/l (p) (appendl (rest p))) fn p))
			
(defun visit-predicate (visit-fn leaf-fn p)
  "Use MAP-OVER-PRED insstead!
   Apply leaf-fn to each leaf predicate in p and apply visit-fn to 
   each compound predicate. A compound predicate is a list of an 
   operator followed by a number of predicates.
   Use MAP-OVER-PREDICATE instead!!!"
  (cond ((atom p)
	 p)
	((leaf-predicate-p p)
	 (funcall leaf-fn p))
	((compound-p p)
	 (funcall visit-fn
		  (cons (predicate-operator p)
			(mapcar (f/l (p)
				     (visit-predicate visit-fn leaf-fn p))
				(rest p)))))
	(t
	 (error "not a predicate" p))))

(defun predicate-p (p)
  (or (leaf-predicate-p p)
      (compound-p p)))

(defun leaf-predicate-p (p)
  (and (listp p)
       (oid-p (first p))))

(defun conjunctionp (p)
  (and (listp p)
       (eq (first p) 'and)))

(defun disjunctionp (p)
  (and (listp p)
       (eq (first p) 'or)))

(defun predicate-arity (p)
  (1- (length p)))

(defun predicate-operator (p)
  "Returns the operator of a predicate. Handles both leaf and compound
   predicates."
  (if (or (leaf-predicate-p p)
	  (compound-p p))
      (first p)
    (error "not a predicate" p)))

(defun predicate-first (p)
  "Returns the first argument of a predicate."
  (if (predicate-p p)
      (second p)
    (error "not a predicate" p)))

(defun predicate-second (p)
  "Returns the second argument of a predicate."
   (if (predicate-p p)
      (third p)
    (error "not a predicate" p)))

(defun predicate-argument (n p)
  "Returns the n:th argument of predicate p."
  (if (predicate-p p)
      (nth n p)
    (error "not a predicate" p)))

(defun predicate-arguments (p)
  "Returns a list of the predicate's arguments."
  (if (predicate-p p)
      (rest p)
    (error "not a predicate" p)))

(defun predicate-variables (p)
  "Returns the named variables of a leaf predicate as a list."
  (if (leaf-predicate-p p)
      (mapfilter (function named-varsymbolp) (rest p))
    (error "not a leaf predicate" p)))

(defun binaryp (pred)
  "True if a predicate is binary"
  (= (predicate-arity pred) 2))

(defun copy-predicate (p)(append p nil))
