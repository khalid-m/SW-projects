;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: aggregations.lsp,v $
;;; $Revision: 1.1 $ $Date: 2006/06/08 07:27:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Wrapped implementation of aggregates. Statistics is collected if flag is
;;; set.
;;; ===========================================================================
;;; $Log: aggregations.lsp,v $
;;; Revision 1.1  2006/06/08 07:27:14  ruslan
;;; Dynamic cost model based on probing for aggregations is added to the repository
;;;
;;; ===========================================================================

(defglobal _cost-multiply_ 100000.0)
(defglobal _rpt-quantity_ 100)
; the key is transients. The value is list 
;(time-called-sum called-count time-passed-sum passed-count)
(defstruct agg-statistic operation variable exec-time-sum quantity 
  time-passed-sum passed-quantity exec-time-square)
(defglobal *agg-statistics* (make-hash-table))
(defglobal *agg-tocollect* nil)
(defglobal _default-rpt_ 1)

(defun print-agg-stats (obj res)
  (let
      ((lres nil))
    (maphash 
     (f/l (k v)
	  (let*
	      ((time (agg-statistic-exec-time-sum v))
	       (card (agg-statistic-quantity v))
	       (out-card (agg-statistic-passed-quantity v))
	       (time-square (agg-statistic-exec-time-square v))
	       (cost (/ (* time _cost-multiply_) 
			(if (= card 0) 1 card)))
	       (fanout (/ (+ out-card 0.0) 
			  (if (= card 0) 1 card)))
	       (mean (/ time 
			(if (= card 0) 1 card)))
	       (dev (sqrt (- (/ time-square 
				(if (= card 0) 1 card)) (* mean mean)))))
	    (setq lres (cons (list (agg-statistic-operation v) 
				   (agg-statistic-variable v)
				   cost fanout card out-card time
				   mean dev)
			     lres))))
     *agg-statistics*)
    (mapc (function osql-result)
	  (cons (list "aggregate" "variable" "cost" "fanout" 
		      "input cardinality" "output cardinality" "total time" 
		      "time mean" "time deviation")
		(sort lres (f/l (e1 e2) (> (fifth e1) (fifth e2))))))))


(create-function print_aggstat()((bag)) as foreign (print-agg-stats))

(defun trans-popup (trans)
  (setf (gethash trans *agg-statistics*)  
	(make-agg-statistic :operation 'BAG.W-NOTANY- :exec-time-sum 0.0 
			    :quantity 0 :time-passed-sum 0.0 
			    :passed-quantity 0 :exec-time-square 0.0)))

(defun update-agg-statistic (trans op execution-time passed)
  (let ((cur-value (gethash trans *agg-statistics*)))
    (if (null cur-value)
	(setq cur-value (make-agg-statistic :operation op
					    :exec-time-sum 0.0 :quantity 0
					    :time-passed-sum 0.0 
					    :passed-quantity 0
					    :exec-time-square 0.0)))
    (let
	((exec-time (agg-statistic-exec-time-sum cur-value))
	 (quantity (agg-statistic-quantity cur-value))
	 (exec-time-passed (agg-statistic-time-passed-sum cur-value))
	 (exec-time-square (agg-statistic-exec-time-square cur-value))
	 (quantity-passed (agg-statistic-passed-quantity cur-value)))
      (setf (agg-statistic-exec-time-sum cur-value) 
	    (+ exec-time execution-time))
      (setf (agg-statistic-quantity cur-value)
	    (+ quantity 1))
      (setf (agg-statistic-passed-quantity  cur-value)
	    (+ quantity-passed passed))
      (setf (agg-statistic-exec-time-square cur-value)
	    (+ exec-time-square (* execution-time execution-time)))
      (if (> passed 0)
	  (setf (agg-statistic-time-passed-sum cur-value)
		(+ exec-time-passed execution-time)))
      (setf (gethash trans *agg-statistics*) cur-value))))

(defun add-name (trans var)
  (let ((v (gethash trans *agg-statistics*)))
    (setf (agg-statistic-variable v) var)))

(foreign-lispfn aggstat ((boolean flg))()
		"To toggle collecting statistics aggregates execution"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*agg-tocollect* flg)
		(if flg (foreign-result)))

(foreign-lispfn clr_aggstat ()()
		(clrhash *agg-statistics*))

(defun rpt-clock (started func &optional rpt)
  (if (null rpt) (setq rpt _default-rpt_))
  (let
      ((i 0))
    (* rpt (loop
	     (rptq rpt (funcall func))
	     (1++ i)
	     (if (> (- (clock) started) 0)
		 (return i))))))

(defun bag.w-some- (obj bag)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (transient-func (generator-function bag))
	   (rptd (rpt-clock start-time
			    (f/l ()
				 (catch 'bag.w-some- 
				   (mapbag bag 
					   (q/l (x) 
						(throw 'bag.w-some- t))))))))
	(cond ((catch 'bag.w-some- 
		 (mapbag bag (q/l (x) (throw 'bag.w-some- t))))
	       (update-agg-statistic transient-func 'bag.w-some- 
				     (/ (- (clock) start-time) (1+ rptd)) 1)
	       (osql-result bag))
	      (t (update-agg-statistic transient-func 'bag.w-some- 
				       (/ (- (clock) start-time) 
					  (1+ rptd)) 0))))
    (cond ((catch 'bag.w-some- (mapbag bag (q/l (x) (throw 'bag.w-some- t))))
	   (osql-result bag)))))

(create-function w_some ((bag))((boolean)) as foreign (bag.w-some-))

(defun bag.w-notany- (obj bag)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (transient-func (generator-function bag))
	   (rptd
	    (rpt-clock start-time
		       (f/l ()
			    (catch 'bag.w-notany- 
			      (mapbag bag 
				      (q/l (x) (throw 'bag.w-notany- t))))))))
	(cond ((catch 'bag.w-notany- 
		 (mapbag bag (q/l (x) (throw 'bag.w-notany- t))))
	       (update-agg-statistic transient-func 'bag.w-notany- 
				     (/ (- (clock) start-time) (1+ rptd)) 0))
	      (t (update-agg-statistic transient-func 'bag.w-notany- 
				       (/ (- (clock) start-time) (1+ rptd)) 1)
		 (osql-result bag))))
    (cond ((catch 'bag.w-notany- 
	     (mapbag bag (q/l (x) (throw 'bag.w-notany- t))))
	   nil)
	  (t (osql-result bag)))))


(create-function w_notany ((bag))((boolean)) as foreign (bag.w-notany-))

(defun bag.w-countbf (obj bag c)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (counter 0)
	   (transient-func (generator-function bag))
	   (rptd
	    (rpt-clock start-time
		       (f/l ()
			    (let ((counter 0))
			      (mapbag bag (f/l (x) (1++ counter))))))))
	(mapbag bag (f/l (x) (1++ counter)))
	(update-agg-statistic transient-func 'bag.w-countbf 
			      (/ (- (clock) start-time) (1+ rptd)) 1)
	(osql-result bag counter))
    (let
	((counter 0))
      (mapbag bag (f/l (x) (1++ counter)))
      (osql-result bag counter))))

(defun bag.w-countbb (obj bag c)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (counter 0)
	   (transient-func (generator-function bag))
	   (rptd
	    (rpt-clock 
	     start-time
	     (f/l ()
		  (let ((counter 0))
		    (catch 'bag.w-countbb 
		      (mapbag bag 
			      (f/l (x) (1++ counter) 
				   (if (> counter c) 
				       (throw 'bag.w-countbb t))))))))))
	(cond ((catch 'bag.w-countbb 
		 (mapbag bag (f/l (x) (1++ counter) 
				  (if (> counter c) 
				      (throw 'bag.w-countbb t)))))
	       (update-agg-statistic transient-func 'bag.w-countbb 
				     (/ (- (clock) start-time) (1+ rptd)) 0))
	      ((= counter c)
	       (update-agg-statistic transient-func 'bag.w-countbb 
				     (/ (- (clock) start-time) (1+ rptd)) 1)
	       (osql-result bag c))
	      (t
	       (update-agg-statistic transient-func 'bag.w-countbb 
				     (/ (- (clock) start-time) (1+ rptd)) 0))))
    (let
	((counter 0))
      (cond ((catch 'bag.w-countbb 
	       (mapbag bag (f/l (x) (1++ counter) 
				(if (> counter c) (throw 'bag.w-countbb t)))))
	     nil)
	    ((= counter c)
	     (osql-result bag c))))))

(set-type-container 
 (osql "
create function w_count(Bag b)->Integer 
as multidirectional ('bf' key foreign 'bag.w-countbf')
                    ('bb' key foreign 'bag.w-countbb');"))

(defun bag.w-atleast (obj n bag)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (cnt 0)
	   (transient-func (generator-function bag))
	   (rptd
	    (rpt-clock 
	     start-time
	     (f/l ()
		  (let ((cnt 0))
		    (catch 'bag.w-atleast
		      (mapbag bag 
			      (f/l (row)
				   (1++ cnt)
				   (if (= cnt n)
				       (throw 'bag.w-atleast t))))))))))
	(cond ((> cnt n) nil)
	      ((catch 'bag.w-atleast
		 (mapbag bag (f/l (row)
				  (1++ cnt)
				  (if (= cnt n)(throw 'bag.w-atleast t)))))
	       (update-agg-statistic transient-func 'bag.w-atleast 
				     (/ (- (clock) start-time) (1+ rptd)) 1)
	       (osql-result n bag))
	      ((>= cnt n) 
	       (update-agg-statistic transient-func 'bag.w-atleast 
				     (/ (- (clock) start-time) (1+ rptd)) 1)
	       (osql-result n bag))
	      (t
	       (update-agg-statistic transient-func 'bag.w-atleast 
				     (/ (- (clock) start-time) (1+ rptd)) 0))))
    (let
	((cnt 0))
      (cond ((> cnt n) nil)
	    ((catch 'bag.w-atleast
	       (mapbag bag (f/l (row)
				(1++ cnt)
				(if (= cnt n)(throw 'bag.w-atleast t)))))
	     (osql-result n bag))
	    ((>= cnt n) 
	     (osql-result n bag))))))

(create-function w_atleast ((number n)(bag b))((boolean)) as foreign 
		 (bag.w-atleast))

(defun bag.w-sumbf (obj bag s)
  (if *agg-tocollect*
      (let*
	  ((start-time (clock))
	   (sum 0)
	   (transient-func (generator-function bag))
	   (rptd
	    (rpt-clock
	     start-time
	     (f/l ()
		  (let ((sum 0))
		    (catch 'bag.w-sumbf 
		      (mapbag bag (f/l (row) 
				       (let 
					   ((x (car row)))
					 (if (numberp x) 
					     (setq sum (+ sum x))
					   (throw 'bag.w-sumbf)))))))))))
	(cond
	 ((catch 'bag.w-sumbf (mapbag bag (f/l (row) 
					       (let 
						   ((x (car row)))
						 (if (numberp x) 
						     (setq sum (+ sum x))
						   (throw 'bag.w-sumbf))))))
	  nil)
	 (t
	  (update-agg-statistic transient-func 'bag.w-sumbf 
				(/ (- (clock) start-time) (1+ rptd)) 1)
	  (osql-result bag sum))))
    (let
	((sum 0))
      ((catch 'bag.w-sumbf (mapbag bag (f/l (row) 
					    (let 
						((x (car row)))
					      (if (numberp x) 
						  (setq sum (+ sum x))
						(throw 'bag.w-sumbf))))))
       nil)
      (t
       (osql-result bag sum)))))


(set-type-container
 (osql "create function w_sum(Bag of Number)->Number as foreign 'bag.w-sumbf';"))
