;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Lars Melander, UDBL
;;; $RCSfile: scan_unbuffered.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/21 12:27:29 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for handling un-buffered scans
;;; =============================================================
;;; $Log: scan_unbuffered.lsp,v $
;;; Revision 1.1  2009/08/21 12:27:29  larme597
;;; Adding functions for unbuffered scan
;;;
;;; =============================================================

(defstruct scan r co)

(defun open-function-scan (fno args)
  "Return a new scan. The function fno with parameters args is set up
   to yield one value at a time."
  (let ((co (coroutine (f/l (fno args)
			    (catch 'closem
			      (mapfunction fno
					   args
					   (f/l (row)
						(let ((r (co-yield row)))
						  (selectq r
							   ('close (throw 'closem))
							   (nil nil)
							   (error "Invalid argument" r))))))
			    '*terminated*)
		       (list fno args))))
    (make-scan :co co :r (co-resume co))))

(defun scan-nextrow (s &optional arg)
  "Return the next row or tuple of the scan, or the string
   *terminated* if the scan has finished or closed. arg is
   for the moment only used internally"
  (if (co-terminated (scan-co s))
      (scan-r s)
    (prog1
	(scan-r s)
      (setf (scan-r s)
	    (co-resume (scan-co s) arg)))))

(defun scan-eos (s)
  "Have we retrieved the last available value from the scan?"
  (co-terminated (scan-co s)))

(defun scan-close (s)
  "Close the scan. Further calls to scan-nextrow return
   the string *terminated*"
  (scan-nextrow s 'close)
  t)
