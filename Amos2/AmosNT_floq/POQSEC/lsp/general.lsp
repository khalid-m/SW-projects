;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: general.lsp,v $
;;; $Revision: 1.5 $ $Date: 2005/04/01 10:42:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Neccassary lisp implementation for POQSEC prototype. Reading, printing
;;; and executing bash commands
;;;              
;;; ===========================================================================

(defglobal _i-xrsl_ 0)

; prints to opened file (if any) without end of line that NG/ARC-client can
; parse it.
(foreign-lispfn prinx((object o))() 
		(princ o *mystream*) (foreign-result))

; sends command to bash for executing
(foreign-lispfn tosystem((charstring command))()
				(system command) (foreign-result))

; unregisters this peer
(foreign-lispfn unregister((charstring peer)) ()
				(unregister-amos peer)(foreign-result))

; help function to provide unique names for query and xrsl files
(foreign-lispfn getIxrsl() ((integer))
				(foreign-result (1++ _i-xrsl_)))

; returns id number of an object
(foreign-lispfn getidno ((object o)) ((integer))
				(foreign-result (oid-idno o)))

;;; functions to read ldap file

(defvar *ldapfile* nil)

(defun open-ldapfile (fno file res)
  (setq *ldapfile* (openstream (mkstring file) "r")))

(defun read-ldapfile (fno res)
  (osql-result (mkstring (read *ldapfile*))))

(defun close-ldapfile (fno res)
  (closestream *ldapfile*))

(defun stream-ldapfile (fno file res)
  (setq *ldapfile* (openstream (mkstring file) "r"))
  (let (curread)
	(loop
	  (setq curread (read *ldapfile*))
	  (osql-result (mkstring curread))
	  (if curread nil (return *ldapfile*))))
  (closestream *ldapfile*))


;;; functions to read a file

(defvar *readfile* nil)

(defun open-readfile (fno file res)
  (setq *readfile* (openstream (mkstring file) "r")))

(defun open-read-file (file)
  (setq *readfile* (openstream (mkstring file) "r")))

(defun read-readfile (fno res)
  (osql-result (mkstring (read *readfile*))))

(defun read-read-file ()
  (read *readfile*))

(defun close-readfile (fno res)
  (closestream *readfile*))
