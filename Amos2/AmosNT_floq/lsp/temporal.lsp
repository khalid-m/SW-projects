;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Martin Skold, Magnus Werner
;;; $RCSfile: temporal.lsp,v $
;;; $Revision: 1.14 $ $Date: 2014/01/16 00:38:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: temporal extensions
;;;
;;; =============================================================
;;; $Log: temporal.lsp,v $
;;; Revision 1.14  2014/01/16 00:38:58  andan342
;;; Added Amos functions timezone() and timevalz_to_date(),
;;; the latter returning date vector representing TIMEVAL projected to its own timezone
;;;
;;; =============================================================

(defglobal _right_closed_timeinterval_)
(defglobal _left_closed_timeinterval_)
(defglobal _both_closed_timeinterval_)
(defglobal _both_open_timeinterval_)

(defun print-timeval (tv &optional stream)
  (let ((dl (timeval-to-date tv)))
    (formatl stream 
	     "|"(aref dl 0)"-"
	     (add-zero (aref dl 1))"-"
	     (add-zero (aref dl 2))"/"
	     (add-zero (aref dl 3))":"
	     (add-zero (aref dl 4))":"
	     (add-zero (aref dl 5))"|"))
  t)

(if (not (gettypenamed 'timeval t))
    (defvar _timeval_ 
      (createliteraltype 'timeval '(literal) 'timeval #'print-timeval)))

(defun now+ (fno r) 
  (osql-result (gettimeofday)))

(osql "
create function now() -> Timeval 
  /* The current time as a timestamp */
  as foreign 'now+';

create function rnow()-> Real 
  /* The current time as number of seconds since epoc */
  as foreign 'rnow+';"
)

(foreign-lispfn year ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 0))))

(foreign-lispfn month ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 1))))

(foreign-lispfn day ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 2))))

(foreign-lispfn hour ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 3))))

(foreign-lispfn minute ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 4))))

(foreign-lispfn second ((timeval tv)) ((integer))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (aref dl 5))))

(foreign-lispfn timezone ((timeval tv)) ((integer)) ;AA: get timezone stored with TIMEVAL
		(foreign-result (timeval-timezone tv)))

(foreign-lispfn timevalz_to_date ((timeval tv)) ((vector of integer)) ;AA: return date vector corresponding to TIMEVAL's own timezone
		(foreign-result (timevalz-to-date tv t)))
				
(movd 'timeval-less 't<)
(movd 'timeval-greater 't>)

(defun t<= (x y)(<= (compare x y) 0))
(defun t>= (x y)(>= (compare x y) 0))

(foreign-lispfn timeval ((integer year) 
                      (integer month) 
                      (integer day) 
                      (integer hour)
                      (integer minute)
                      (integer second)) ((timeval))
	      (foreign-result (date-to-timeval 
                         (vector year month day hour minute second 0))))

(foreign-lispfn timeval () ((timeval))
		(foreign-result (gettimeofday)))

(if (not (gettypenamed 'timeinterval t))
    (defvar _timeinterval_ 
      (createtype 'timeinterval '(literal))))

(defun print-timeinterval(ti stream)
  (case (timeinterval-type ti)
    (both-closed
     (princ "|[" stream)
     (print-timeval (timeinterval-start ti))
     (princ "," stream)
     (print-timeval (timeinterval-stop ti))	     
     (princ "]|" stream))
    (left-closed
     (princ "|[" stream)
     (print-timeval (timeinterval-start ti))
     (princ "," stream)
     (print-timeval (timeinterval-stop ti))	     
     (princ ")|" stream))
    (right-closed
     (princ "|(" stream)
     (print-timeval (timeinterval-start ti))
     (princ "," stream)
     (print-timeval (timeinterval-stop ti))	     
     (princ "]|" stream))
    (both-open
     (princ "|(" stream)
     (print-timeval (timeinterval-start ti))
     (princ "," stream)
     (print-timeval (timeinterval-stop ti))	     
     (princ ")|" stream)))
  t)

(defun timeintervaltype(ti)
  (case (timeinterval-type ti)
    (both-closed
     _both_closed_timeinterval_)
    (left-closed
     _left_closed_timeinterval_)
    (right-closed
     _right_closed_timeinterval_)
    (both-open
     _both_open_timeinterval_)))

(if (not (gettypenamed 'both_closed_timeinterval t))
    (defvar _both_closed_timeinterval_ 
      (createliteraltype 'both_closed_timeinterval 
			 '(timeinterval)
			 'timeinterval
			 #'print-timeinterval
			 #'timeintervaltype)))

(if (not (gettypenamed 'left_closed_-timeinterval t))
    (defvar _left_closed_timeinterval_ 
      (createliteraltype 'left_closed_timeinterval 
			 '(timeinterval)
			 'timeinterval
			 #'print-timeinterval
			 #'timeintervaltype)))

(if (not (gettypenamed 'right_closed_timeinterval t))
    (defvar _right_closed_timeinterval_ 
      (createliteraltype 'right_closed_timeinterval 
			 '(timeinterval)
			 'timeinterval
			 #'print-timeinterval
			 #'timeintervaltype)))

(if (not (gettypenamed 'both_open_timeinterval t))
    (defvar _both_open_timeinterval_ 
      (createliteraltype 'both_open_timeinterval 
			 '(timeinterval)
			 'timeinterval
			 #'print-timeinterval
			 #'timeintervaltype)))

(foreign-lispfn timeinterval_both_closed ((timeval t1) (timeval t2)) 
		((both_closed_timeinterval))
		(foreign-result (mktimeinterval t1 t2 'both-closed)))
				 
(foreign-lispfn timeinterval_left_closed ((timeval t1) (timeval t2)) 
		((left_closed_timeinterval))
		(foreign-result (mktimeinterval t1 t2 'left-closed)))
				 
(foreign-lispfn timeinterval_right_closed ((timeval t1) (timeval t2)) 
		((right_closed_timeinterval))
		(foreign-result (mktimeinterval t1 t2 'right-closed)))
				 
(foreign-lispfn timeinterval_both_open ((timeval t1) (timeval t2)) 
		((both_open_timeinterval))
		(foreign-result (mktimeinterval t1 t2 'both-open)))
	
;; meets(x,y)   xxxx
;;                  yyy
(foreign-lispfn meets ((timeinterval t1) (timeinterval t2)) nil
		(if (= (timeinterval-stop t1) (timeinterval-start t2))
		    (foreign-result)))

;; overlaps(x,y)   xxxx
;;                   yyyy
(foreign-lispfn overlaps ((timeinterval t1) (timeinterval t2)) nil
		(if (and
		     (t< (timeinterval-start t1) (timeinterval-stop t2))
		     (t> (timeinterval-stop t1) (timeinterval-start t2))
		     (t< (timeinterval-stop t1) (timeinterval-stop t2)))
		    (foreign-result)))

;; contains(x,y)   xxxxxx
;;                   yyy
(foreign-lispfn contains ((timeinterval t1) (timeinterval t2)) nil
		(if (or
		     (and
		      (t<= (timeinterval-start t1) (timeinterval-start t2))
		      (t> (timeinterval-stop t1) (timeinterval-stop t2)))
		     (and
		      (t< (timeinterval-start t1) (timeinterval-start t2))
		      (t>= (timeinterval-stop t1) (timeinterval-stop t2))))
		    (foreign-result)))

(foreign-lispfn contains ((timeinterval t1) (timeval t2)) nil
                (if (and
                     (t<= (timeinterval-start t1) t2)
                     (t> (timeinterval-stop t1) t2))
                    (foreign-result)))

(foreign-lispfn add_duration ((timeval tv) (number d)) ((timeval))
		(foreign-result (timeval-add-duration tv d)))

(defun print-time (tm stream)
  (formatl stream 
	   "|"(add-zero (time-hour tm))":"
	   (add-zero (time-minute tm))":"
	   (add-zero (time-second tm))"|")
  t)

(if (not (gettypenamed 'time t))
    (defvar _time_ (createliteraltype 'time '(literal) 'time #'print-time))) 

(foreign-lispfn time () ((time))	; time today
		(let ((today (timeval-to-date (gettimeofday))))
		  (foreign-result (mktime 
				   (aref today 3) ; hours
				   (aref today 4) ; minutes
				   (aref today 5) ; seconds
				   ))))

(foreign-lispfn time ((integer hour)
                      (integer minute)
                      (integer second)) ((time))
		      (foreign-result (mktime hour minute second)))

(foreign-lispfn time ((timeval tv)) ((time))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (mktime (aref dl 3) (aref dl 4)
					  (aref dl 5)))))

(foreign-lispfn hour ((time tm)) ((integer))
		(foreign-result (time-hour tm)))

(foreign-lispfn minute ((time tm)) ((integer))
		(foreign-result (time-minute tm)))

(foreign-lispfn second ((time tm)) ((integer))
		(foreign-result (time-second tm)))

(defun print-date (dt stream)
  (formatl stream 
	   "|"(add-zero (date-year dt))"-"
	   (add-zero (date-month dt))"-"
	   (add-zero (date-day dt))"|")
  t)

(if (not (gettypenamed 'date t))
    (defvar _date_ (createliteraltype 'date '(literal) 'date #'print-date))) 

(foreign-lispfn date () ((date))	; date today
		(let ((today (timeval-to-date (gettimeofday))))
		  (foreign-result (mkdate 
				   (aref today 0) ; year 
				   (aref today 1) ; month 
				   (aref today 2) ; day
				   ))))

(foreign-lispfn date ((integer year)
                      (integer month)
                      (integer day)) ((date))
		      (foreign-result (mkdate year month day)))

(foreign-lispfn date ((timeval tv)) ((date))
		(let ((dl (timeval-to-date tv)))
		  (foreign-result (mkdate (aref dl 0) (aref dl 1)
					  (aref dl 2)))))

(foreign-lispfn year ((date dt)) ((integer))
		(foreign-result (date-year dt)))

(foreign-lispfn month ((date dt)) ((integer))
		(foreign-result (date-month dt)))

(foreign-lispfn day ((date dt)) ((integer))
		(foreign-result (date-day dt)))

(foreign-lispfn date_time_to_timeval ((date dt) (time tm)) ((timeval))
		(foreign-result (date-to-timeval 
				 (vector (date-year dt)
					 (date-month dt)
					 (date-day dt)
					 (time-hour tm)
					 (time-minute tm)
					 (time-second tm)
					 0))))

(foreign-lispfn timespan ((timeval tv1) (timeval tv2)) 
		((time tm) (integer usec))
		(let* ((s1 (timeval-sec tv1))
		       (u1 (timeval-usec tv1))
		       (s2 (timeval-sec tv2))
		       (u2 (timeval-usec tv2))
		       (du (- u1 u2))
		       (ds (- s1 s2))
		       (positive (if (t>= tv1 tv2) 
				     t
				   nil)))
		  (if positive
		      (if (< u1 u2)
			  (progn
			    (setq ds (1- ds)) ; borrow 1 sec
			    (setq du (+ du 1000000))))
		    (if (> u1 u2)
			(progn
			  (setq ds (1+ ds)) ; borrow 1 sec
			  (setq du (- du 1000000)))))
		  (setq tm (mktime 0 0 (if positive ds (minus ds))))
		  (setq usec (if positive du (minus du)))
		  (foreign-result tm usec)))

(defun timespan (tv1 tv2) 
  (let* ((s1 (timeval-sec tv1))
	 (u1 (timeval-usec tv1))
	 (s2 (timeval-sec tv2))
	 (u2 (timeval-usec tv2))
	 (du (- u1 u2))
	 (ds (- s1 s2))
	 (positive (if (t>= tv1 tv2) 
		       t
		     nil))
	 tm usec)
    (if positive
	(if (< u1 u2)
	    (progn
	      (setq ds (1- ds))		; borrow 1 sec
	      (setq du (+ du 1000000))))
      (if (> u1 u2)
	  (progn
	    (setq ds (1+ ds))		; borrow 1 sec
	    (setq du (- du 1000000)))))
    (setq tm (if positive ds (minus ds)))
    (setq usec (if positive du (minus du)))
    (mktimeval tm usec)))

(defun add-zero(x)
  (if (and (integerp x)
           (>= x 0)
           (< x 10))
      (concat (mkstring 0) (mkstring x))
    (mkstring x)))

;;; Temporal Lisp read functions for inter-Amos communication:

(defun read-date (tag lst str)
  (apply 'mkdate lst))

(type-reader 'date 'read-date)

(defun read-time (tag lst str)
  (apply 'mktime lst))

(type-reader 'time 'read-time)

(defun sec-+ (fno tv s)
  (osql-result tv (timeval-sec tv)))

(defun usec-+ (fno tv s)
  (osql-result tv (timeval-usec tv)))

(defun timeval.real+- (fno tv r)
  (osql-result (mktimeval (round r) 
			  (round (* (mod r 1) 1000000.0)))
               r))

(osql "
create function sec(Timeval tv)-> Integer s
  as foreign 'sec-+';

create function usec(Timeval tv)->Integer us
  as foreign 'usec-+';

create function real(Timeval tv)->Real r
  as multidirectional ('bf' key select sec(tv)+(usec(tv)/1000000.0))
                      ('fb' key foreign 'timeval.real+-');

create function timeval(Real r)->Timeval t
  as select t where real(t)=r;")

(commit)
