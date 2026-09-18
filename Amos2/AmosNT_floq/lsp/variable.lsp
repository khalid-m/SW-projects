;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: variable.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/05/01 15:25:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: All functionality for storing and retrieving information about
;;;              variables. Most importantly binding and type information, but
;;;              some more subtle hints such as the predicate in which the
;;;              variable was first seen, and to which datasource it belongs,
;;;              if this happen to be a mapped type.
;;;
;;;              To do:
;;;              -  Move definition of struct varinfo here.
;;;              -   Chase down all functions that do the same as these 
;;;                  functions. There seems to be about a dozen laying around!
;;;              -  Change macro defstruct to include a copy constructor
;;;
;;; ===========================================================================
(defun copy-varinfo (vi)
  (make-varinfo :name       (varinfo-name       vi)
		:type       (varinfo-type       vi)
		:orgtype    (varinfo-orgtype    vi)
		:bind       (varinfo-bind       vi)
		:entity     (varinfo-entity     vi)
		:boundby    (varinfo-boundby     vi)
		:datasource (varinfo-datasource vi)))

(defun varsymbolp (v)
  (and (symbolp v)
       (not (numberp v))
       (not (stringp v))
       (neq v 'true)
       (neq v 'false)
       (neq v 'and)
       (neq v 'or)
       (neq v nil)))

(defun named-varsymbolp (v)
  (and (varsymbolp v)
       (neq '* v)))

(defun anonymous-varsymbolp (v)
  (eq '* v))

(defun constantsymbolp (a)
  (and (neq a '*)
       (osql-constantp a)))
