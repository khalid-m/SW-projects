;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Lars Melander, UDBL
;;; $RCSfile: server.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/08/06 15:52:16 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions handling check-descriptors coroutine
;;;              plus server-side scan coroutines
;;; =============================================================
;;; $Log: server.lsp,v $
;;; Revision 1.6  2012/08/06 15:52:16  larme597
;;; Timeout removed from remote scans.
;;;
;;; Revision 1.5  2012/07/31 16:44:03  larme597
;;; *** empty log message ***
;;;
;;; Revision 1.4  2012/07/31 16:38:51  larme597
;;; *** empty log message ***
;;;
;;; Revision 1.3  2012/07/31 16:24:54  larme597
;;; Process functions.
;;;
;;; Revision 1.2  2012/07/26 20:14:06  torer
;;; Error handling in remote scans
;;;
;;; Revision 1.1  2012/06/27 08:45:00  larme597
;;; *** empty log message ***
;;;
;;; =============================================================

(defglobal _pending-coroutines_ ())

(defun run-server-coroutines ()
  (loop
    (let ((lst (mapcar #'evaluate-pending _pending-coroutines_)))
      (if (null _pending-coroutines_)
	  (return '*END*))
      (if (every (f/l (x) (equal x '*BUSY*))
		 lst)
	  (co-list-wait _pending-coroutines_ 1)))))

(defun evaluate-pending (co)
  (cond ((coroutinep co) (if (co-terminated co)
			     (proc-remove co)
			   (co-resume co)))
	(t (let ((result (co-resume (scan-coroutine co))))
	     (selectq result
		      (*BUSY* '*BUSY*)
		      (prog1
			  (scan-set-terminated co result)
			(proc-remove co)
			(printto (list (scan-buffer co) (scan-terminated co))
				 (socket-legal (scan-socket co))
				 (socket-destination (scan-socket co)))
			))
	     ))
	))

;;; Coroutine scheduling

(defun proc-start (fno &rest args)
  (proc-add (coroutine fno args)))

(defun proc-add (co)
  (setq _pending-coroutines_ (nconc1 _pending-coroutines_ co))
  co)

(defun proc-remove (co)
  (setq _pending-coroutines_ (delete co _pending-coroutines_))
  co)

(defun proc-purge (co)
  (proc-remove co)
  (cond ((coroutinep co) (co-kill co))
	(t (error "Cannot purge non-coroutine" co))))

(defun proc-clear ()
  (setq _pending-coroutines_))

(defun proc-stats ()
  (formatl t "--- PROC LIST START ---" t)
  (dolist (co _pending-coroutines_)
    (formatl t co t))
  (formatl t "---- PROC LIST END ----" t))
