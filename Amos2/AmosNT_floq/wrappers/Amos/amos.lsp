;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: amos.lsp,v $
;;; $Revision: 1.5 $ $Date: 2004/03/15 21:47:59 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The Amos datasource type.
;;;              
;;; ===========================================================================
;(defvar _imported_supertypes_ 
;  (getfunctionnamed 'AMOS.CHARSTRING.IMPORTED_SUPERTYPES->TYPE))

(putobject _amos_ 'initializer 'amos-initialize)
(putobject _amos_ 'finalizer 'amos-finalize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AMOS datasource type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _amos-named_)
(defglobal _local-amos-servers_)

(defun init-amos-ds ()
  ; Make Amos server NAME ready for type/function importation
  ; Returns Amos datasource object
   (foreign-lispfn import_db((charstring name))((datasource))
      (foreign-result (import-db (mkatom name))))
   
  ; Import type named NAME from Amos server name DB
  (foreign-lispfn import_type((charstring name)(charstring db))((type))
    (dolist (it (import-type name db))
       (foreign-result it)))

  ; Import named TYPES from Amos server name DB
  (foreign-lispfn import_types ((vector names)(charstring db))((type))
    (dolist (it (import-types (arraytolist names) db))
       (foreign-result it)))

  ; Import function named NAME from Amos server named DB
  (foreign-lispfn import_func((charstring name)(charstring db))((function))
    (import-db (mkatom db))
    (let ((imported_func (import_single_func (mkatom name) db NIL)))
      (if imported_func
	  (foreign-result imported_func))))
  NIL)

; Lisp functions

;; (defun get-local-supertypes (amosds remote-tp)
;;   "Returns the local types corresponding to the immediate supertypes of the 
;;    type name remote-tp at amos node amosds. If on is missing, an error is 
;;    thrown."
;;   (mapcar #'first
;; 	  (getfunction _imported_supertypes_ 
;; 	  (list amosds (mkstring remote-tp)))))