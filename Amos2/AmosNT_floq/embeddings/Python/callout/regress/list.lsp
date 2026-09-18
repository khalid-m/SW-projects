;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Robert Kajic, UDBL
;;; $RCSfile: list.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/02/01 18:45:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Regressions tests of general list functions.
;;; =============================================================
;;; $Log: list.lsp,v $
;;; Revision 1.1  2011/02/01 18:45:03  roka4241
;;; Added regression tests for much of the current callout functionality.
;;;
;;;
;;; =============================================================


(checkequal "(ZIP L...)"
	    ((zip)
	     nil)
	    ((zip '(1 2 3))
	     '((1) (2) (3)))
	    ((zip '(1 2 3) '(4 5 6))
	     '((1 4) (2 5) (3 6)))
	    ((zip '(1 2 3) '(4 5 6) '(7 8 9))
	     '((1 4 7) (2 5 8) (3 6 9))))

(checkequal "(TUPLELIST-TO-RECORD L)"
	    ((record-fields 
	      (tuplelist-to-record
	       (zip '(1 2 3) '(4 5 6))))
	     (record-fields 
	      (make-record 
	       (listtoarray 
		(flatten
		 (zip '(1 2 3) '(4 5 6))))))))

