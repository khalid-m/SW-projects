;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: capability.lsp,v $
;;; $Revision: 1.2 $ $Date: 2003/10/20 09:56:36 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp interface to the capability database. See also 
;;;              capability.osql
;;;              
;;; ===========================================================================
(defvar _capability_ 
  (createtype 'capability (list _object_)))
;(defvar _capability_ (gettypenamed 'capability))
(defvar _generic_capability_ 
  (createtype 'generic_capability (list _capability_)))

(defvar _specific_capability_
  (createtype 'specific_capability (list _capability_)))

(defun instantiate_specific_capability-+ (fno name cap)
  (osql-result name (/createobject 'specific_capability name)))

(defun instantiate_generic_capability-+ (fno name cap)
  (osql-result name (/createobject 'generic_capability name)))