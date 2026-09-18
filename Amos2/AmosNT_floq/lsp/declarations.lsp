;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: declarations.lsp,v $
;;; $Revision: 1.4 $ $Date: 2003/09/29 09:38:02 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utility functions that prove useful if you declare a lot of
;;;              AmosQL functions from lisp 
;;;              
;;; ===========================================================================
(defvar *declarations-printing* nil)

(defun print-declaration (declaration)
  (if *declarations-printing* (print declaration) declaration))

(defun arginfo-make-expr-commalist (ais)
  (concatl
   (mapcar (f/l (ai) (concat (oid-name (arginfo-type ai))" "(arginfo-name ai)))
	   ais)
   ","))

(defun make-paramater-declarations (ais)
  "Takes a list of arginfo structs (see arginfo.lsp) and creates an AmosQL 
   parameter list, for example 'charstring name, int ssn ...'"
  (concatl
   (mapcar #'make-paramater-declaration ais)
   ","))

(defun make-paramater-declaration (ai)
  "Turns an of arginfo struct and concatenates the type and the parameter 
   name, inserting a space in between. If the argument is a key, the word 'key'
   is appended."
  (concat (oid-name (arginfo-type ai))" "
	  (arginfo-name ai)
	  (if (arginfo-isunique ai)" key" "")))

(defun declare-amosql (&rest args)
  "Takes a list of strings, symbols or lists, concatenates them and evaluates
   the whole thing in AmosQL. Useful for writing function declarations from
   templates."
  (amos-execute (print-declaration (apply (function concat) args))))

(defun make-amosql-function-applications (obj &rest fns)
  "Makes a string consisting of the application of functions f to the object
   o, for example (make-function-applications 'p 'name 'ssn) -> name(p),ssn(p)
   functions can be objects, symbols or strings."
  (concatl fns","(f/l (f)(concat(if(oid-p f)(generic-fnname f)f)"("obj")"))))

(defun make-amosql-vector-predicates (vector vars &optional startindex)
  "Makes a selection predicate from a vector using predicates consisting of the
   vector and variables.
   (m.a.v.p. 'vect '(a b c) 2)
   => 'a = vect[2] and b = vect[3] and b = vect[4]'"
  (let ((index (or startindex 0)))
    (concatl vars " and " (f/l (var) (concat var"="vector"["(++1 index)"]")))))
  
(defun make-amosql-vector-accesses (vector startindex length)
  "Makes a comma separated list of vector accesses.
   (m.a.v.a 'vect '2 2)
    => 'vect[2], vect[3], vect[4]'"   
  (let ((i startindex)
	(repeats (buildn (- length startindex) vector)))
    (concatl repeats "," (f/l (v) (concat v"["(++1 i)"]")))))

