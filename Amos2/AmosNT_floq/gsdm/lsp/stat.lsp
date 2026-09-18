;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Koparanova, UDBL
;;; $RCSfile: stat.lsp,v $
;;; $Revision: 1.11 $ $Date: 2005/07/27 21:31:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Statistics - structure and functions
;;;              Used for both input streams and box execution
;;; ===========================================================================

;;; structure for statistical info
(defglobal _statistics_ t)
(defglobal _psize_ 1000) ; size of a period for statistics
(defglobal _max-intersend_ 2) ; maximum length between 2 consecutive sendings
                   ;; if bigger -init period statistics


(defstruct stat
  t0 ; initial moment, used by statistics
  cnt ; number of data units(vectors) received
  last ;last receiving moment
  pt0 ; initial moment for a period
  pcnt ; number of data units(vectors) sent for a period
  rate ; list of tripples (pcnt tstart tend) for periods of _psize_ elements
  rate-hist ; historical agregated stat data (cnt time)
  lat  ; accumulated latency 
)

;; Statistics will be a property in the stream object prop list


(defun wallclocktime (tv1 tv2) 
    (let* ((s1 (timeval-sec tv1))
	   (u1 (timeval-usec tv1))
	   (s2 (timeval-sec tv2))
	   (u2 (timeval-usec tv2))
	   (du (- u1 u2))
	   (ds (- s1 s2))
	   (positive (if (t>= tv1 tv2) 
				 t
				 nil))
	   tm usec wctm)
      
      (if positive
	  (if (< u1 u2)
	      (progn
		(setq ds (1- ds)) ; borrow 1 sec
		(setq du (+ du 1000000))))
	(if (> u1 u2)
	    (progn
	      (setq ds (1+ ds)) ; borrow 1 sec
	      (setq du (- du 1000000)))))
      (setq tm (if positive ds (minus ds)))
      (setq usec (if positive du (minus du)))
      (setq wctm (+ tm (/ usec 1000000.0)))
      wctm
))

(foreign-lispfn wctime ((timeval tv1) (timeval tv2)) ((real tm))
(foreign-result (wallclocktime tv1 tv2)))


(defun get-stat (strname)
"Get the statistical info for a stream named strname"
     (getobject (get-str-named strname) 'stat)
)

(defun init-stat ()
"Create a stat structure with 0 counters and latency"
  (make-stat :cnt 0 :pcnt 0 :lat 0.0))
 ;; t0,pt0 will get new values during first receiving or exec



(defun get-period-rate (t)
"t is a tripple (cnt tstart tend). Calculates the rate or nil if time=0"
(let ((tm (wallclocktime (third t) (second t))))
  (if (> tm 0.0001) (/ (car t) tm) nil)))


(defun get-cur-rate (st)
"Calculate the rate from the last measured period in stat structure st"
  (let ((l (stat-rate st)))
    ;; number of elements sent for which the stat is collected
    (if l (get-period-rate (car (last l))))
))


(defun get-exp-avg-rate (st)
"Calculate the exponential average rate from the stat st"
  (let ((l (stat-rate st)) (rt (stat-rate-hist st)) rp )
     ;; no history yet

    (dolist (t l)
      ;; l is chronological - the old period will be aggregated first
      (if (timeval-less (second t) (stat-last st))
	  (let ((rp (get-period-rate t)))
	    (if rp 
		(if (null rt) (setq rt rp)
		  (setq rt (+ (* _exp-avg_  rp)
			      (* (- 1 _exp-avg_) rt))))
	      )))
)
    rt
))

(defun get-exp-avg-rate-org (st)
"Calculate the exponential average rate from the stat st"
  (let ((l (stat-rate st)) (rt (stat-rate-hist st)) rp )
     ;; no history yet

    (dolist (t l)
      ;; l is chronological - the old period will be aggregated first
  ;;    (if (timeval-less (second t) (stat-last st))
	  (let ((rp (get-period-rate t)))
	    (if rp 
		(if (null rt) (setq rt rp)
		  (setq rt (+ (* _exp-avg_  rp)
			      (* (- 1 _exp-avg_) rt))))
	      )))
;;)
    rt
))

(defun agg-stat (st)
"Aggregates exponentially the rate slot of the stat structure st and put the rate into rate-hist"
  (let ()
    (setf (stat-rate-hist st) (get-exp-avg-rate st))
    (setf (stat-rate st) nil)
))

(defun update-stat (st k &optional lt)
"Update stat structure st with k received data and optional latency"
(let* ((tnow (gettimeofday))
      (tprev (if (stat-last st) (stat-last st) tnow )))

   (if (eq (stat-cnt st) 0) ;; first call (for receiving/proc)
       (progn
	 (setf (stat-t0 st) tnow)
	 (setf (stat-pt0 st) tnow)
	))
   
   (setf (stat-last st) tnow)
   (setf (stat-cnt st) (+ (stat-cnt st) k))
   (setf (stat-pcnt st) (+ (stat-pcnt st) k))
   (if lt (setf (stat-lat st) (+ (stat-lat st) lt)))
   
   (if ( > (wallclocktime tnow tprev) _max-intersend_)
       (let ()   ;; unvalid period due to stopping 
	 ;;init period statistics
	 (setf (stat-pt0 st) tnow)
	 (setf (stat-pcnt st) 0)))
   
   (if (>= (stat-pcnt st) _psize_) ;; end of period : store triple in rate slot
       (let ()
	 (setf (stat-rate st)
	       (append2 (stat-rate st) 
			(list  (list (stat-pcnt st) (stat-pt0 st) tnow))))
	 ;; init next period statistics
	 (setf (stat-pt0 st) tnow)
	 (setf (stat-pcnt st) 0)
	 ;; accumulate last 10 periods in history to avoid too long list stat-rate
	 (if (> (length (stat-rate st)) 10) (agg-stat st))
	 ))
   st
))



(defun clean-stat (st)
"Cleans stat counters"
(let ()
  (setf (stat-cnt st) 0)
  (setf (stat-pcnt st) 0)
  (agg-stat st)
  (setf (stat-last st) nil)
  ;; t0,pt0 will get new values during first receiving
  st
))

(defun print-istat-stream (strname)
  "Print input statistics for the stream"
  (let ((st (get-stat strname)))
        (formatl t strname " Count " (stat-cnt st) t)
	(formatl t "Measured rate "  (get-total-rate st)
		 " History rate "  (get-hist-rate st) t)
))

(defun print-statistics (st)
  "Print statistics st"
  (let (wt)
        (formatl t "Count " (stat-cnt st) )
	(formatl t " Total elapsed time " 
	  (and (stat-t0 st) 
	       (setq wt (wallclocktime (stat-last st) (stat-t0 st))) wt)
	  " Avg rate " (if (or (null wt)(equal wt 0.0)) '- (/ (stat-cnt st) wt)) t)
	(formatl t  "Avg inter arrival interval "
		 (if (or (null wt)(equal (stat-cnt st) 0)) '-   (/ wt (stat-cnt st))))

	(formatl t  "Latency "
		 (if (null (stat-lat st)) '-   
		    (if (equal (stat-cnt st) 0) '-   
		      (/ (stat-lat st) (stat-cnt st)))))

))

(defun get-statistics (st)
  "Return cnt tm rate latency"
  (let (wt r lat)

    (if (stat-t0 st) 
	(setq wt (wallclocktime (stat-last st) (stat-t0 st))))

					;rate
    (setq r  (if (or (null wt)(equal wt 0.0)) 0
	       (/ (stat-cnt st) wt)))
    
    (setq lat (if (or (null (stat-lat st)) (equal (stat-cnt st) 0)) 0   
		      (/ (stat-lat st) (stat-cnt st))))
    (list (stat-cnt st) wt r lat)
))


;;;;;;;;;;;;; Miscellaneous ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Calculate utilization 

(defun util (bs)
"Calculate utilization factor ro based on the number of elements in the buffer.
bs = sqr(ro)/(1-ro)"
(let ((d (* bs (+ bs 4.0))))
  (/ (- (sqrt d) bs) 2)
))

