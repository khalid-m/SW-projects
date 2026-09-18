;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: updates.lsp,v $
;;; $Revision: 1.1 $ $Date: 2003/03/04 15:18:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Layer between the Amos frontend functions for user-defined
;;; update functions and the internal update system.
;;;              
;;; ===========================================================================

(defun set_addfunction-- (fno sfn addfn) (set-addfunction sfn addfn))
(defun set_remfunction-- (fno sfn remfn) (set-remfunction sfn remfn))
(defun set_setfunction-- (fno sfn setfn) (set-setfunction sfn setfn))

(defun get_addfunction-- (fno sfn addfn) (osql-result sfn (get-addfunction sfn)))
(defun get_remfunction-- (fno sfn remfn) (osql-result sfn (get-remfunction sfn)))
(defun get_setfunction-- (fno sfn setfn) (osql-result sfn (get-setfunction sfn)))

(defvar _addfn_ (getfunctionnamed 'FUNCTION.ADD_FUNCTION->FUNCTION))
(defvar _remfn_ (getfunctionnamed 'FUNCTION.REMOVE_FUNCTION->FUNCTION))
(defvar _setfn_ (getfunctionnamed 'FUNCTION.SET_FUNCTION->FUNCTION))

(defvar _set_addfn_  
  (getfunctionnamed 'FUNCTION.FUNCTION.SET_ADDFUNCTION->BOOLEAN))

(defvar _set_remfn_
  (getfunctionnamed 'FUNCTION.FUNCTION.SET_REMFUNCTION->BOOLEAN))

(defvar _set_setfn_
  (getfunctionnamed 'FUNCTION.FUNCTION.SET_SETFUNCTION->BOOLEAN))

(set-setfunction _addfn_ _set_addfn_ )
(set-setfunction _remfn_ _set_remfn_ )
(set-setfunction _setfn_ _set_setfn_ )


