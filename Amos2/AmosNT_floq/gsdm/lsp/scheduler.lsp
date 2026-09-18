; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: scheduler.lsp,v $
;;; $Revision: 1.35 $ $Date: 2005/12/19 13:45:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Scheduler at working nodes
;;;              
;;; ==========================================================================

(defglobal _start_ nil)  ;; to store start moment of a period
(defglobal _turn-around_ nil)
(defglobal _last-sysman_ nil)
(defglobal _sysman-period_ 0.5)
(defglobal _sysman-time_ 0.0)
(defglobal _push-time_ 0.0)
(defglobal _stat-period-start_ nil)
(defglobal _sysman-time-old_ nil)
(defglobal _push-time-old_ nil)
;;(defglobal _comm-in-old_ nil)
(defglobal _proc-time_ nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; check-descriptor box
(defglobal _cd_ (make-lisp-box 'CD 'check-descriptors))
(setf (box-paraml _cd_) (list 0.0))

;; as init operation find number of input streams and set the number of rep
(defun prepare-check-descr ()
  (let ((nis 0) ;; number of input TCP streams
	(l (mapcar 'car (osql "select s from stream s;"))))

    (mapc (f/l (s) (if (input-TCP-strp s)
		       (setq nis (1+ nis)))) 
	  l)

    (if (> nis 1) (print (setf (box-rep _cd_) nis)))
))

(setf (box-rep _cd_) 1)
(register-box _cd_)
(add-active-box  _cd_) ;; just add it to the list, no init 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun mintime (l)
"Minimum time among list of time values"
(let ((ll (delete nil l)))
  (cond ((null ll) nil)
	((eq 1 (length ll)) (car ll))
	(t (let ((m (car ll)))
	     (dolist (el (cdr ll))
	       (setq m (if (t< m el) m el))
	       )
	     m)))
))

(defun maxtime (l)
"Minimum time among list of time values"
(let ((ll (delete nil l)))
  (cond ((null ll) nil)
	((eq 1 (length ll)) (car ll))
	(t (let ((m (car ll)))
	     (dolist (el (cdr ll))
	       (setq m (if (t> m el) m el))
	       )
	     m)))
))

(defun first-data ()
  (let ((sl (osql "select s from stream s;"))
	     start_times )

    (setq start_times 
	  (mapcar (f/l (s)
	       (let* ((str (car s))
		      (st (getobject str 'stat)))

		   (if st (stat-t0 st))))
	  sl))
    (mintime start_times)
))


(defun first-operation ()
  (let ( start_times )

    (maphash (f/l (k b)
		  (let ((st (box-stat b)))
		    (if (not (eq (box-id b) 'CD))
		    (setq start_times (cons (stat-t0 st) start_times)))))
	     _installed-boxes_)

    (mintime start_times)
))

(defun last-operation ()
  (let ( last_times )

    (maphash (f/l (k b)
		  (let ((st (box-stat b)))
		    (if (not (eq (box-id b) 'CD))
		    (setq last_times (cons (stat-last st) last_times)))))
	     _installed-boxes_)
  ;;  (setq last_times  (cons _last-sysman_ last_times)) 
;; will be called after query finishes and increase the time
    (maxtime last_times)
))

(defun mymax (l)
"Maximum element among list of elements"
  (cond ((null l) nil)
	((eq 1 (length l)) (car l))
	(t (let ((m (car l)))
	     (dolist (el (cdr l))
	       (setq m (max m el))
	       )
	     m))
))

(defun sleep-until ()
  (if (t>= (gettimeofday)_start_)
      (while (< (wallclocktime (gettimeofday) _start_) _turn-around_) )
))

(defun check-box-data (b)
"Check how many times the box can be scheduled depending on data
available in the input streams"
(let ((istrl (box-inputstreaml b))
      (bid (box-id b))
      schl (schno 0))
  (cond ((amosql-box-p b)
	 (setq schl 
	       (mapcar (f/l (scons)
		    (let* ((s (car scons))
			   (bufsz (buf-size-for-cursor (get-buf s) bid))
			   (winsz (lb-winsz (cdr scons))))
		      (cond ((null winsz) bufsz)
			    (t (floor (/ bufsz winsz))))
		      ))
		  istrl))
;; TO DO timebased windows
	 (setq schno (eval (list (box-sched b) 'schl))))
	;; for lisp boxes assume 1
	((lisp-box-p b) (setq schno 1)))
  (if schno schno 0)
))


(defun check-box-stop (b)
"Check if the box stop condition is true."
(let ((bs (box-stop b))
      (st (box-stat b))
      )

 (cond ((null bs) nil) 
       ((eq (car bs) 'UNC) t)  ;; unconditional stop from coordinator 
       ((eq (car bs) 'CNT) 
	(<= (cdr bs) (stat-cnt st)))

       ((eq (car bs) 'TIME) 
	(cond ((eq (stat-cnt st) 0) nil)   ;; box was not called
	    	;;stop condition in min, time measurement in sec.
	      ((<= (* (cdr bs) 60) 
		   (wallclocktime (stat-t0 st) (gettimeofday))))
	)))
))


(defun check-box-org (b)
"Check if the box can be executed and how many times.
 Returns cnt or 0.
"
(let ((cnt 0)
      (max-poss-cnt (- _max-exec-cnt_ (stat-cnt (box-stat b)))))

  (if (and (null (eq (box-id b) 'CD))
	   (>= (stat-cnt (box-stat b)) _max-exec-cnt_))
      (deactivate-box b)

      (cond  ;; Check-descr always executed
       ((eq (box-id b) 'CD) (setq cnt (box-rep b)))
       ;; if box-rep is set- use it
       ((box-rep b) 
	(setq cnt (min (box-rep b) max-poss-cnt)))
       
       (t ;; check the number repetitions according to the input streams
	(setq cnt (min (check-box-sch b) max-poss-cnt))))
       )
  cnt
))

(defun max-cnt-box (b)
  (if (and (box-stop b) (eq (car (box-stop b)) 'CNT))
      (cdr (box-stop b))
    nil)
)

(defun check-box (b)
"Check if the box can be executed and how many times.
 Returns cnt or 0.
"
(let* ((cnt 0)
      (mx (max-cnt-box b))  ;; max cnt in stop condition
      max-poss-cnt 
      data-cnt)   ;; cnt acc to data available

      (setq max-poss-cnt (if mx (- mx (stat-cnt (box-stat b))) nil))

      (cond  ;; Check-descr always executed
       ((eq (box-id b) 'CD) (setq cnt (box-rep b)))
       ((check-box-stop b) (setq cnt 0)) ;; no exec, stop cond=T
       ;; if box-rep is set- use it
       ((box-rep b) 
	(setq cnt (if max-poss-cnt (min (box-rep b) max-poss-cnt)
		    (box-rep b))))
       
       (t ;; check the number repetitions according to the input streams
	(setq data-cnt (check-box-data b))
	(setq cnt (if max-poss-cnt (min data-cnt max-poss-cnt)
		    data-cnt)))
       )
  cnt
))


(defun check-for-sysman ()
  (let ((tm (gettimeofday))
	(flag nil))

    (if (null _last-sysman_) (setq _last-sysman_ (first-operation)))
    (cond ((null _last-sysman_)) ;; haven't started yet

	  ((> (wallclocktime tm _last-sysman_)
	     (* 2 _sysman-period_))
	   (setq flag t)) ;; execute unconditionaly

;;	  ((and (> (wallclocktime tm _last-sysman_) _sysman-period_)
;;	   (< _proc-time_ 0.001))
;;	      (setq flag t)) ;; execute if the period is idle
	 ;; otherwise do not execute
	   )
    (if flag
	(progn
	  (sys-man)
	  (setq _last-sysman_ tm)
	  (if _cq-server_    ;;to not accumulate last sysman after last op.
	  (setq _sysman-time_ (+ _sysman-time_ 
				 (wallclocktime tm (gettimeofday)))))
      ))
))


(defun process-active-boxes ()
"Scan the active box list and execute all the boxes if possible"
(let (r boxtime)

  (dolist (b _activeboxes_)
    (setq r (check-box b))
    (if (> r 0)  ;; exec box b r times
	(let ((oldcnt (stat-cnt (box-stat b))))

	  (setq _bstart_ (gettimeofday))
	  (setq _push-time-sched_ 0.0)
	  (resetvar _curbox_ b 
		   (dotimes (i r) (execbox b)))
	  ;; accumulate execution time
	  (setq boxtime (wallclocktime _bstart_ (gettimeofday)))
	  (cond ((< oldcnt (stat-cnt (box-stat b)))
		 (setf (box-time b) (+ (box-time b) 
				       (- boxtime _push-time-sched_)))
		 (setq _push-time_ (+ _push-time_ _push-time-sched_)))
	  )
    ))
)))


(defun process-active-boxes-intermixed ()
"Scan the active box list and execute all the boxes if possible"
(let (r boxtime to_exec)

  (dolist (b _activeboxes_)
    (setq r (check-box b))
    (if (> r 0)  ;; exec box b r times
	(let ((oldcnt (stat-cnt (box-stat b)))
	      (remain 0))

	  (cond ((and (> r 1) (null (box-conseq_exec b)))
		 (setq remain (- r 1))
		 (setq r 1)))

	  (setq _bstart_ (gettimeofday))
	  (resetvar _curbox_ b 
		   (dotimes (i r) (execbox b)))
	  ;; accumulate execution time
	  (setq boxtime (wallclocktime _bstart_ (gettimeofday)))
	  (if (< oldcnt (stat-cnt (box-stat b)))
	      (setf (box-time b) (+ (box-time b) boxtime)))
	  ;; if more executions remain to be sceduled add b to list to_exec
	  (if (> remain 0) (setq to_exec (nconc1 to_exec (list b remain))))
	  ))
    )
  (while to_exec
    (let (to_exec1 oldcnt b)
      
      (dolist (bl to_exec)
	(setq r (cadr bl)) ;; how many rep remain
	(setq b (car bl))
	(setq oldcnt (stat-cnt (box-stat b)))
	;; execute once
	(setq _bstart_ (gettimeofday))
	(resetvar _curbox_ b 
		  (dotimes (i 1) (execbox b)))
	;; accumulate execution time
	(setq boxtime (wallclocktime _bstart_ (gettimeofday)))
	(if (< oldcnt (stat-cnt (box-stat b)))
	    (setf (box-time b) (+ (box-time b) boxtime)))
	
	;; if more executions remain to be sceduled add it again to_exec1
	;; with reduced counter
	(if (> r 1) (setq to_exec1 (nconc1 to_exec1 (list b (- r 1)))))
	)
      (setq to_exec to_exec1))
    )
))

(defun init-proc-time ()
  "Save valus of operators processing times in associative list _proc-time_
((q1 1.23 10) (q2 0.5 10))"
(maphash 
   (f/l (k b) 
	(setq _proc-time_ 
	      (putassoc  (box-id b)
			 (list (box-time b) (stat-cnt (box-stat b)))
			 _proc-time_))
	 )
   _installed-boxes_)
)


(defun init-stat-period (tm)
"Save snap-shot of statistical values"
  (let ()
    (setq _stat-period-start_ tm)
    (setq _period-no_ (1+ _period-no_))
    (setq _sysman-time-old_ _sysman-time_)
    (setq _push-time-old_ _push-time_)
  ;;  (setq _comm-in-old_ (box-time _cd_))
    (init-proc-time)
))

(defun init-stat-period0 ()
(init-stat-period (gettimeofday)))

(defun started-at ()
"When the real execution started"
(mintime (list (first-data) (first-operation))))

(defun report-period-stat ()
(let* ((ts (gettimeofday))
      (start_exec (mintime (list (first-data) (first-operation))))
      (end_exec (if (last-operation) (last-operation) start_exec))
      (total_exec_time (wallclocktime start_exec end_exec)) ;; total exec
      plen  ;; current period length
      (st (- _sysman-time_ _sysman-time-old_))
      (cin (- (box-time _cd_) (second (assoc  'CD _proc-time_))))
      (cout (- _push-time_ _push-time-old_))
      )

  (if start_exec ;; execution started -> report
      (progn 
	(setq plen (wallclocktime ts _stat-period-start_)) ; period len
	(send-message 
	 (list 'osql (concat 
		"period_stat('" _amosid_ "'," _period-no_ ", " 
		plen ", " st ", " cin  ", "
		cout ");"))
	 'STATSRV)
	(send-message  ;; total exec time
	 (list 'osql (concat 
		"set_time('" _amosid_ "'," total_exec_time ");"))
	 'STATSRV)

	;; statistics for each operator
	(maphash 
	 (f/l (k b) 
	      (let* ((old (cdr (assoc  (box-id b) _proc-time_)))
		     (c (- (stat-cnt (box-stat b))
			   (second old)))
		     (t (- (box-time b) (car old))))
		
		(if (not (eq (box-id b) 'CD))
		    (send-message 
		     (list 'osql (concat "stat('" _amosid_ "'," _period-no_ ", '" 
					 (box-id b)"', " c ", " t ");"))
		     'STATSRV)))) 
	 _installed-boxes_)

	;; Report latency so far from latency stream
	(mapc (f/l (s)
		   (if (equal (getobject s 'kind) 'LATENCY)
		      (let ((c (getobject s 'cnt)) lat)
			(if (and c (> c 0))
			    (setq lat (/ (getobject s 'val) c))
			  (setq lat 9.999))
			(send-message  
			 (list 'osql (concat "set_latency('" 
				     (getobject s 'source) "'," lat ");"))
			 'STATSRV)
			)))
	 (mapcar 'car (osql "select s from stream s;")))

	;; Report input stream statistics
	(mapc (f/l (s)
		   (if (input-TCP-strp s)
		      (let ((l (get-statistics (getobject s 'stat))))
			(send-message  
			 (list 'osql 
			       (concat "set_mstream_data('" 
				       (getobject s 'name) "'," 
				       (car l) "," (second l)
				       "," (third l) "," (fourth l) ");"))
			 'STATSRV)
			)))
	 (mapcar 'car (osql "select s from stream s;")))

	))
;; init next period
  (init-stat-period ts)
))

(defun check-for-report-stat ()
    (if (and (started-at)
	     (> (wallclocktime _stat-period-start_ (gettimeofday)) 0.5))
	(report-period-stat))
)


(defun run-period ()
"Run one period of the scheduler. Executes active operators, calls sys-man if its period expires, and sleeps at the end when turn-around is set and there is still time to the end of the period"
  (let ()
    (setq _start_ (gettimeofday))
 
    (process-active-boxes)
   
    (check-for-sysman)
   
;;    (if _turn-around_ (sleep-until))
    (if _turn-around_ 
	(let* ((exp (wallclocktime (gettimeofday) _start_))
	      (sl (- (- _turn-around_ exp) 0.01)))
	  (if (>  sl 0.0) (sleep sl))))
    (check-for-report-stat)

    (check-and-deact) ;; check stop condition of queries
))


(defun set-turn-around (n)
;;(maphash (f/l (k b) (setf (box-rep b) 1)) _installed-boxes_)
(setq _turn-around_ n))

(defun set-rep (n)
(maphash (f/l (k b) (setf (box-rep b) n)) _installed-boxes_)
;;(setq _turn-around_ n)
)


(defun server-eval (descr)
  "Server side evaluation of message sent on socket DESCR"
  (let* ((port (server-port descr))	; This not needed???
	 (*client-port* port)
	 res form noresult dbid)
    (cond ((null (port-socket port)) nil) ; port closed
	  (t (setq form (readfrom descr (setq dbid (port-dbid port))))
	     (setq res			; the result of the evaluation
		   (traperrors		; rolls back if error, otherwise commit
		    (let ((*suppress-error* (null _debugging_)))
		      (cond
		       ((setq noresult (get-form-annotation form :noresult))
			(eval (get-form form)))
		       (t (eval form ))))))
	     (cond ((integerp noresult)
		    (setq _result-log_ (cons (list dbid noresult res) 
					     _result-log_)))
		   (noresult nil)
		   (t (printto res descr (or dbid 0))))
	     (cond ( _cq-server_ (update-bstat (box-stat _cd_) 1)))
	     ))))


(defun print-exec-statistics-screen ()
(let (start_exec 
      (total_time 0.0) 
      (proc_time 0.0)
      )

  (setq start_exec (mintime (list (first-data) (first-operation))))
  (setq total_time (wallclocktime start_exec (last-operation)))

  (maphash 
   (f/l (k b) (setq proc_time (+ proc_time (box-time b)))) 
   _installed-boxes_)

  (formatl t "Total time " total_time t)
  (formatl t "Total processing time " proc_time t)
  (formatl t "Total system time " _sysman-time_ t)
  (formatl t "Total sched and stat " 
	   (- (- total_time proc_time) _sysman-time_) t)
))

(defun report-stat0 ()
(let (start_exec 
      (total_time 0.0) 
      pno
      )

  (setq start_exec (mintime (list (first-data) (first-operation))))
  (setq total_time (wallclocktime start_exec (last-operation)))

  (setq pno 1)
  (send-message 
   (list 'osql (concat 
		"period_stat('" _amosid_ "'," pno ", " 
		total_time ", " _sysman-time_ ", " (box-time _cd_) ", "
		_push-time_ ");"))
   'STATSRV)
  
  (maphash 
   (f/l (k b) 
	(if (not (eq (box-id b) 'CD))
	(send-message 
	 (list 'osql (concat "stat('" _amosid_ "'," pno ", '" 
			     (box-id b)"', " (stat-cnt (box-stat b))
			     ", " (box-time b) ");"))
	 'STATSRV))) 
   _installed-boxes_)

))

(defun print-exec-statistics (file)
 (with-file
  str file
  (let (start_exec 
	(total_time 0.0) 
	(proc_time 0.0)
	)

    (setq start_exec (mintime (list (first-data) (first-operation))))
    (setq total_time (wallclocktime start_exec (last-operation)))
    
    (maphash 
     (f/l (k b) (setq proc_time (+ proc_time (box-time b)))) 
     _installed-boxes_)
    
    (formatl str t "Total time " total_time t)
    (formatl str "Total processing time " proc_time t)
    (formatl str "Pushing time " _push-time_ t)
    (formatl str "Total system time " _sysman-time_ t)
    (formatl str "Total sched and stat " 
	   (- (- (- total_time proc_time) _sysman-time_) _push-time_) t)
    (if _turn-around_
	(formatl str "Turn-around " _turn-around_ t))
    )

    "a"))


(defun print-exec-stat-all ()
(dump-hash-table _exec-stat_))

(defun print-exec-stat (&optional k)
"Print info for the first k nonempty periods"
(let ((i 0) (j 0) ;; i iterates on periods, j on nonempty periods
      (n (if k k 20)) p) 
  (while (and (<= i _period-no_) (< j n))
    (setq p (gethash i _exec-stat_))
    (if p (progn (formatl t i ":" p t) (setq j (1+ j))))
    (setq i (1+ i)))
))



(defun set-stop-condition (qid condkind condval)
  "Set stop condition of qid"
  (let ((b (get-registered-box qid)))
  (setf (box-stop b) (cons condkind condval))
))


(defun stop-stream (sname)
(putobject (get-str-named sname) 'stop t))

(defun stop-remote-stream (s) 
" Send a message to the destination node to switch the stop flag ON"
  (let ((remstr (mkatom (getobject s 'name)))
	msg)
   (setq msg `(stop-stream  (quote , remstr)))
   (send-message msg (getobject s 'dest))
))


(defun stop-box (b)
"Deactivate box b and send stop-stream messages to all the consumers"
(let ((outl (box-outputstreaml b)))
   (mapc (f/l (outs)
	     (if (output-TCP-strp outs)
		 (stop-remote-stream outs))
	     (if (eq (getobject outs 'kind) 'MATR) 
		 (putobject outs 'stop t)))
	outl)
 (deactivate-box b)
;; TO DO Stop other kinds of streams if needed
))

(defun check-and-deact ()
"Check active boxes for stop: a) if all input streams have flag stop=T;
b) if stop-condition is T"
(mapc (f/l (b)
	   (let (( insl (mapcar 'car (box-inputstreaml b))) dt)
	     (setq dt (apply '+                  ;; unprocessed data
		         (mapcar (f/l (s)
			     (if (get-buf s)
				 (buf-size-for-cursor (get-buf s) (box-id b)) 0))
				 insl)))
	     (if (and (eq dt 0)
		     (apply 'and (mapcar (f/l (s) (getobject s 'stop)) insl)))
		 (stop-box b))
	     (if (check-box-stop b) (stop-box b)) ;; explicit
	   ))
   _activeboxes_)
) 

