;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: time.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/02/09 09:55:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing temporal functions
;;; =============================================================
;;; $Log: time.lsp,v $
;;; Revision 1.2  2013/02/09 09:55:28  torer
;;; Changed error message
;;;
;;; Revision 1.1  2012/01/06 13:38:39  torer
;;; *** empty log message ***
;;;
;;; =============================================================

(defun t< (x y)(< (compare x y) 0))
(defun t> (x y)(> (compare x y) 0))
(defun t<= (x y)(<= (compare x y) 0))
(defun t>= (x y)(>= (compare x y) 0))

(checkequal "timeval"
	    ((timevalp(gettimeofday)) t)
	    ((timevalp(mktimeval 123 123)) t)
	    ((timevalp 1) nil)
	    ((timevalp 'a) nil)
	    ((eq (mktimeval 1 1) (mktimeval 1 1)) nil)
	    ((equal (mktimeval 1 1) (mktimeval 1 1)) t)
	    ((timeval-sec (mktimeval 1 2)) 1)
	    ((timeval-usec (mktimeval 1 2)) 2)

	    ((t< (mktimeval 1 1) (mktimeval 1 1)) nil)
	    ((t< (mktimeval 2 2) (mktimeval 2 3)) t)
	    ((t< (mktimeval 2 2) (mktimeval 3 2)) t)
	    ((t< (mktimeval 2 2) (mktimeval 1 2)) nil)
	    ((t< (mktimeval 2 2) (mktimeval 1 1)) nil)

	    ((t> (mktimeval 1 1) (mktimeval 1 1)) nil)
	    ((t> (mktimeval 2 2) (mktimeval 2 3)) nil)
	    ((t> (mktimeval 2 2) (mktimeval 3 2)) nil)
	    ((t> (mktimeval 2 2) (mktimeval 1 2)) t)
	    ((t> (mktimeval 2 2) (mktimeval 1 1)) t)

	    ((t<= (mktimeval 1 1) (mktimeval 1 1)) t)
	    ((t<= (mktimeval 2 2) (mktimeval 2 3)) t)
	    ((t<= (mktimeval 2 2) (mktimeval 3 2)) t)
	    ((t<= (mktimeval 2 2) (mktimeval 1 2)) nil)
	    ((t<= (mktimeval 2 2) (mktimeval 1 1)) nil)

	    ((t>= (mktimeval 1 1) (mktimeval 1 1)) t)
	    ((t>= (mktimeval 2 2) (mktimeval 2 3)) nil)
	    ((t>= (mktimeval 2 2) (mktimeval 3 2)) nil)
	    ((t>= (mktimeval 2 2) (mktimeval 1 2)) t)
	    ((t>= (mktimeval 2 2) (mktimeval 1 1)) t)

	    ((catch-error (mktimeval 'a 1))
	     '(:ERRCOND (36 "Not an integer" A)))
	    ((catch-error (mktimeval 1 'b))
	     '(:ERRCOND (36 "Not an integer" B)))
	    )

