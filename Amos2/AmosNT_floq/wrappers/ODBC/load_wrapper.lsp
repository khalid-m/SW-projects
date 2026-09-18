;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.6 $ $Date: 2007/11/07 14:37:47 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the ODBC wrapper
;;; =============================================================
;;; $Log: load_wrapper.lsp,v $
;;; Revision 1.6  2007/11/07 14:37:47  torer
;;; ODBC.DLL can be loaded only from Borland version!
;;;
;;; =============================================================

(defun enable-odbc ()
  (if (equal (system-environment) "Borland")(load-dll "odbc.dll")
    (formatl t "WARNING: ODBC not enabled!" t)))
(defun disable-odbc ()
  (if (equal (system-environment) "Borland")(odbc-shutdown)))
(register-init-form '(enable-odbc)) ; for running with ODBC on
(register-shutdown-form '(disable-odbc))
(load "../wrappers/ODBC/odbc.lsp")
(load-amosql "../wrappers/ODBC/odbc.osql")

