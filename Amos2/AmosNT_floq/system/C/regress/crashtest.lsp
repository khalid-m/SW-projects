;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Lars Melander, UDBL
;;; $RCSfile: crashtest.lsp,v $
;;; $Revision: 1.1 $ $Date: 2010/06/23 17:53:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing that a background coroutine will trigger
;;;              error when calling system.
;;; =============================================================
;;; $Log: crashtest.lsp,v $
;;; Revision 1.1  2010/06/23 17:53:28  larme597
;;; Testing coroutine background check for Linux.
;;;
;;; =============================================================

(let ((cr (coroutine (f/l ()
			  (coroutine-crash)))))
  (co-resume cr)
  (sleep 0.2)
  (co-resume cr)
  (formatl t "WARNING! Crash test failed!" t))
