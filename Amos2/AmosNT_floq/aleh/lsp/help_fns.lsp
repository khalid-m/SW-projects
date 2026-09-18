;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: help_fns.lsp,v $
;;; $Revision: 1.9 $ $Date: 2008/07/10 08:49:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Help functions for measuring execution time and for
;;; doing regression tests.
;;; ===========================================================================
;;; $Log: help_fns.lsp,v $
;;; Revision 1.9  2008/07/10 08:49:52  ruslan
;;; bug because of the precision problem is fixed
;;;
;;; Revision 1.8  2008/03/24 10:35:26  ruslan
;;; functions to calculate mean and stdev
;;;
;;; Revision 1.7  2008/03/01 10:07:55  ruslan
;;; dropping slot stat fucntion
;;;
;;; Revision 1.6  2008/01/19 09:53:36  ruslan
;;; abitlity to measure time of monitoring phase
;;;
;;; Revision 1.5  2008/01/18 08:37:49  ruslan
;;; moving myprint to correct file
;;;
;;; Revision 1.4  2007/11/16 12:51:39  ruslan
;;; printing list as comma-separated data, execution measurement can sleep between iterations.
;;;
;;; Revision 1.3  2007/11/14 09:12:12  ruslan
;;; lisp function to measure execution time of UDFs
;;;
;;; Revision 1.2  2007/11/12 08:27:54  ruslan
;;; function to measure execution time of arbitrary function on a given list of argument.
;;;
;;; Revision 1.1  2007/11/11 13:37:38  ruslan
;;; using C implementations of UDFs and aggregates
;;;
;;; ===========================================================================

(defglobal *start-monitor*) ;; used to calculate monitoring time
(defglobal *stop-monitor*) ;; used to calculate monitoring time

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Timer function returning time, based on (timer form)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro timer2 (form)
  "Return time to evluate FORM"
  `(let ((__ (clock))(r , form))
     (- (clock) __)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Help functions for regression test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun r2i10n (x n)
  "Returns integer part of real x multiplied with 10 in power n"
  (floor (dotimes (i n)(setq x (* x 10)))))
  
(defun lr2i10n (lx n)
  "Returns list of integer parts of every real x from list lx multiplied with 10 in power n"
  (mapcar (f/l (x) (r2i10n x n)) lx))

(defun lr2i10nl (lx ln)
  "Returns list of integer parts of every real x from list lx multiplied with 10 in power n"
  (mapcar (f/l (x n) (r2i10n x n)) lx ln))

(foreign-lispfn 
 execute 
 ((charstring fn)(vector lf)(integer rptbest)
  (integer rptavg)(integer tosleep)(real rptuntil)) 
 ((real avgtime)(real sqsum)(real stdev)(integer cr))
 (let ((s 0)(sq 0)(fno (getfunctionnamed (mksymbol fn))))
   (setq cr (length (callfunction fno lf)))
   (dotimes (iavg rptavg)
     (let* (mintime (ext 0) (rpt 0)
		    (curtime
		     (dotimes (ibest rptbest)
		       (sleep tosleep)
		       (do () ((> ext rptuntil))
			 (setq ext (+ ext (timer2 (callfunction fno lf))))
			 (1++ rpt))
		       (setq ext (/ ext rpt))
		       (setq mintime
			     (cond 
			      (mintime (min ext mintime))
			      (t ext))))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptavg))
   (setq stdev (sqrt (- (/ sq rptavg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev cr)))

(defun udf-exectime (name args rptavg rptuntil tosleep)
  (let ((fno (getfunctionnamed name)) (s 0) (sq 0) avgtime)
    (dotimes (iavg rptavg)
      (sleep tosleep)
      (let* 
	  ((ext 0)(rpt 0)
	   (curtime
	    (progn
	      (do () ((> ext rptuntil))
		(setq ext (+ ext (timer2 (proccall fno args))))
		(1++ rpt))
	      (/ ext rpt))))
	(setq s (+ s curtime))
	(setq sq (+ sq (* curtime curtime)))))
    (setq avgtime (/ s rptavg))
    (list avgtime sq (sqrt (- (/ sq rptavg) (* avgtime avgtime))))))

(defun print-list (l)
  (dolist (x l)
    (princ x *mystream*)
    (princ ", " *mystream*))
  (terpri *mystream*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Help functions for experiments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun myprint (fno &rest reals)
  (dolist (r reals) (princ r *mystream*)(princ ", " *mystream*))
  (terpri *mystream*))

(foreign-lispfn drop_sobjectstat () ()
		(dropfunction *sobject-stat-fn*))

(defun mean (sum rpt)
  (/ (+ sum 0.0) rpt))

(foreign-lispfn mean ((real sum)(integer rpt))((real avg))
		(foreign-result (mean sum rpt)))

(defun stdev (sum sqsum rpt)
  (let* ((avg (mean sum rpt))
	 (dif (- (/ (+ sqsum 0.0) rpt) (* avg avg)))
	 (epsilon (/ avg 100000)))
    (setq dif (cond ((and (< (- 0.0 epsilon) dif) (< dif epsilon)) 0.0) 
		    (t dif)))
    (sqrt dif)))

(foreign-lispfn stdev ((real sum)(real sqsum)(integer rpt))((real stdev))
		(foreign-result (stdev sum sqsum rpt)))
