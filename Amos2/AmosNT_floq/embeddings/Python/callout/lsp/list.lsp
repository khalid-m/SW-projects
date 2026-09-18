;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Robert Kajic, UDBL
;;; $RCSfile: list.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/02/01 18:45:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: General list functions.
;;; =============================================================
;;; $Log: list.lsp,v $
;;; Revision 1.1  2011/02/01 18:45:00  roka4241
;;; Added regression tests for much of the current callout functionality.
;;;
;;;
;;; =============================================================

(defun zip (&rest args)
  (apply #'mapcar (cons 
		   (f/l (&rest x) 
			x)
		   args)))

(defun tuplelist-to-record (l)
  (let ((r (make-record #())))
    (mapc (f/l (x) 
	       (record-put r (car x) (cadr x)))
	  l)
    r))

