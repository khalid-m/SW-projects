;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Ruslan Fomkin, UDBL
;;; $RCSfile: stream.naive.lsp,v $
;;; $Revision: 1.6 $ $Date: 2008/05/22 11:10:59 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Version for naive query optimization strategy. Code is moved from 
;;; stream.lsp.
;;; ===========================================================================
;;; $Log: stream.naive.lsp,v $
;;; Revision 1.6  2008/05/22 11:10:59  ruslan
;;; delay is set to 0. it works fine on Mei (it will not work well on my desktop)
;;;
;;; Revision 1.5  2008/05/22 09:55:18  ruslan
;;; increasing delay between experiments
;;;
;;; Revision 1.4  2008/05/22 09:13:16  ruslan
;;; duration of sleeping during executing experiments in global variable
;;;
;;; Revision 1.3  2008/04/11 10:09:25  ruslan
;;; execute of function with three arguments
;;;
;;; Revision 1.2  2008/04/07 14:23:25  ruslan
;;; unnecessary execute script is commented
;;;
;;; Revision 1.1  2008/03/25 14:50:21  ruslan
;;; reorganization: split experiments, which run without safisticated query optimization, and experiments on advanced system. experiment to tune zAplah and delta are added
;;;
;;; ===========================================================================

(defglobal *execute-delay* 0)
;(foreign-lispfn 
; execute 
; ((charstring fn)(charstring lf)(integer rptbest)
;  (integer rptavg)) 
; ((real avgtime)(real sqsum)(real stdev)(integer cr))
; (setq cr 0)
; (let* 
;     ((fno (getfunctionnamed (mksymbol fn)))
;      (s (timer2 (mapfunction fno (list lf) (f/l (x) (1++ cr)))))
;      (sq (* s s)))
;   (dotimes (iavg (1- rptavg))
;     (let* (mintime
;	    (curtime
;	     (dotimes (ibest rptbest)
;	       (sleep *execute-delay*)
;	       (let ((ext (timer2 (proccall fno (list lf)))))
;		 (setq mintime
;		       (cond 
;			(mintime (min ext mintime))
;			(t ext)))))))
;       (setq s (+ s curtime))
;       (setq sq (+ sq (* curtime curtime)))))
;   (setq avgtime (/ s rptavg))
;   (setq stdev (sqrt (- (/ sq rptavg) (* avgtime avgtime))))
;   (foreign-result avgtime sq stdev cr)))

;(foreign-lispfn expcuts_bkg ((integer n)) ((real ext))
;		(let ((bestt))
;		  (dotimes (i n)
;		  (sleep *execute-delay*)
;		    (let ((curt (timer2 (osql "expcuts();"))))
;		      (cond
;		       (bestt (setq bestt (min bestt curt)))
;		       (t (setq bestt curt)))))
;		  (foreign-result bestt)))

(foreign-lispfn 
 execute ((charstring fn)(object o)(integer rptavg))
 ((real avgtime)(real sqsum)(real stdev)(integer passed))
 (setq passed 0)
 (let* 
     ((fno (getfunctionnamed (mksymbol fn)))
      (s (timer2 (mapfunction fno (list o) (f/l (x) (1++ passed)))))
      (sq (* s s)))
   (dotimes (iavg (1- rptavg))
     (sleep *execute-delay*)
     (let
	 ((curtime (timer2 (proccall fno (list o)))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptavg))
   (setq stdev (sqrt (- (/ sq rptavg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev passed)))

(foreign-lispfn 
 execute ((charstring fn)(object o1)(object o2)(object o3)(integer rptavg))
 ((real avgtime)(real sqsum)(real stdev)(integer passed))
 (setq passed 0)
 (let* 
     ((fno (getfunctionnamed (mksymbol fn)))
      (s (timer2 (mapfunction fno (list o1 o2 o3) (f/l (x) (1++ passed)))))
      (sq (* s s)))
   (dotimes (iavg (1- rptavg))
     (sleep *execute-delay*)
     (let
	 ((curtime (timer2 (proccall fno (list o1 o2 o3)))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptavg))
   (setq stdev (sqrt (- (/ sq rptavg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev passed)))

(foreign-lispfn 
 execute ((charstring fn)(integer rptavg))
 ((real avgtime)(real sqsum)(real stdev)(integer passed))
 (setq passed 0)
 (let* 
     ((fno (getfunctionnamed (mksymbol fn)))
      (s (timer2 (mapfunction fno '() (f/l (x) (1++ passed)))))
      (sq (* s s)))
   (dotimes (iavg (1- rptavg))
     (sleep *execute-delay*)
     (let
	 ((curtime (timer2 (proccall fno '()))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptavg))
   (setq stdev (sqrt (- (/ sq rptavg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev passed)))

(foreign-lispfn
 reoptfn ((charstring fn)) ((real opttime))
 (setq opttime (timer2 (callfunction 'charstring.reoptimize->function
				     (list fn))))
 (foreign-result opttime))

(foreign-lispfn
 reoptfn ((charstring fn)(integer rptForAvg)) 
 ((real avgtime)(real sqsum)(real stdev))
 (let ((s 0) (sq 0))
   (dotimes (i rptForAvg)
     (sleep *execute-delay*)
     (let 
	 ((curtime (timer2 (callfunction 'charstring.reoptimize->function
					 (list fn)))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptForAvg))
   (setq stdev (sqrt (- (/ sq rptForAvg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev)))

(foreign-lispfn
 reoptfn0 ((charstring fn)) ((real opttime))
 (setq opttime (timer2 (callfunction 'charstring.reoptimize0->function
				     (list fn))))
 (foreign-result opttime))

(foreign-lispfn
 reoptfn0 ((charstring fn)(integer rptForAvg)) 
 ((real avgtime)(real sqsum)(real stdev))
 (let ((s 0) (sq 0))
   (dotimes (i rptForAvg)
     (sleep *execute-delay*)
     (let 
	 ((curtime (timer2 (callfunction 'charstring.reoptimize0->function
					 (list fn)))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq avgtime (/ s rptForAvg))
   (setq stdev (sqrt (- (/ sq rptForAvg) (* avgtime avgtime))))
   (foreign-result avgtime sq stdev)))

(foreign-lispfn
 getstats ((charstring file)(real z)(real d)(integer step))
 ((real stattime)(integer statcount))
 (setq stattime 
       (timer2 
	(setq statcount 
	      (callfunction 
	       'CHARSTRING.REAL.REAL.INTEGER.GETSTRUCTSTAT->INTEGER
	       (list file z d step)))))
 (foreign-result stattime (aref (first statcount) 0)))

(foreign-lispfn
 reopt2 ((charstring fn)(integer rptavg)) 
 ((real opttime)(real sqsum)(real stdev))
 (let ((s 0)(sq 0))
   (dotimes (iavg rptavg)
     (sleep *execute-delay*)
     (let
	 ((curtime (timer2 (callfunction 'charstring.reoptimize2->function
					 (list fn)))))
       (setq s (+ s curtime))
       (setq sq (+ sq (* curtime curtime)))))
   (setq opttime (/ s rptavg))
   (setq stdev (sqrt (- (/ sq rptavg) (* opttime opttime))))
   (foreign-result opttime sq stdev)))

; sends command to bash for executing
(foreign-lispfn tosystem((charstring command))()
				(system command) (foreign-result))
