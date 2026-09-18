;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: lispdef.lsp,v $
;;; $Revision: 1.78 $ $Date: 2014/01/01 14:45:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Master file for basic aLisp system
;;; =============================================================

(defglobal _system-version_);; set by kernel
(defglobal _release_  nil  "NIL means development version")
(defglobal _system-versions_
  '((default . "Release 16, v11"))
  "Legal system versions")

(cond ((equal _system-version_ (or (cdr (assoc (system-environment)
					   _system-versions_))
			       (cdr (assoc 'default _system-versions_)))))
      (t (princ "Wrong system version: ")
	 (princ _system-version_)(terpri)(exit)))

(defglobal _registered-errors_ nil "List of Lisp registered errors")
(defun reregister-errors ()
  (mapcar (function register-error) (reverse _registered-errors_)))
(defglobal after-rollin-forms '((reregister-errors))
  "Forms evaluated directly after rollin")

(load "advise.lsp")
(load "filepos.lsp")
(load "client.lsp")
(load "basic.lsp")
(load "sort.lsp")
(load "ppr.lsp")
(load "trace.lsp") 
(load "interrupts.lsp")
(load "error.lsp")
(load "socket.lsp")
(load "ref_lisp.lsp")
(document startup-dir "Directory where system was started")
(load "coro.lsp")
(load "buffer.lsp")
(load "strings.lsp")
(load "verify_code.lsp")

(setq _release_ (getenv "releasing"))

(document _system-version_ "System version")
(defglobal _alisp-dmp_ "alisp.dmp" "Name of ALisp image file")

(setq _debugging_ 'auto)

;(defglobal _mexima-enabled_ (getenv "mexi") "Enable MEXIMA")
(defglobal _mexima-enabled_ t "Enable MEXIMA")

(cond (_mexima-enabled_
       (with-directory "../system/C/mexima/lsp" 
		       (load "mex-basic.lsp"))
       (load-extension "bt" t)
       (with-directory "../system/C/mexima/lsp" 
		       (load "mex-lisp-interfaces.lsp")
		       (load "mex-transactional.lsp"))))       

(defglobal _toploop-help_ 
  "
You are in the ALisp top loop.

(debugging nil) Leave debug mode
(quit)          quit ALisp
"
  ":help in Lisp toploop")

(register-shutdown-form '(catch-error(close-all-sockets)))

(setq *verify-immediate* t)




