;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler, UDBL
;;; $RCSfile: clock.lsp,v $
;;; $Revision: 1.3 $ $Date: 2007/09/05 16:14:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Simulated clock time
;;; =============================================================

(foreign-lispfn
 simclock ((timeval start)(timeval end)(real stride))
 ((left_closed_timeinterval))
 (let ((current start))
   (while (timeval-less current end)
     (foreign-result
      (mktimeinterval current
		      (TIMEVAL-ADD-DURATION current stride) 'left-closed))
     (setq current (TIMEVAL-ADD-DURATION current stride)))))

; select s,contains(s, now()) from TIMEINTERVAL s where s = simclock(:x1, :x2, 0.1);

(foreign-lispfn
 mktv ((integer v))
 ((timeval))
   (foreign-result (mktimeval v 0)))
