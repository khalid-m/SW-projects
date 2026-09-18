;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998, 2011 Tore Risch, UDBL
;;; $RCSfile: interrupts.lsp,v $
;;; $Revision: 1.4 $ $Date: 2011/12/21 20:59:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Interrupt handling and statistical profiler
;;; =============================================================

(defglobal _profiler-frequency_ 0.001 "How often to sample stack per sec")

(defvar *in-critical-section* nil "Interrupts delayed when T")

(defvar *interrupt-happened* nil "T if interrupt happened in critical section")

(defglobal _stat-enabled_ t "NIL when statistical profiling disabled")

(defglobal _profile-stats_ (make-hash-table) "Table with profiling statistics")

(defglobal _current-ologpred_ nil "Latest ObjectLog pred called")

(defglobal _exclude-profile_		
  (union '(eq and or maphash
	      maprelation0 car memq rplacd null isome not cons 
	      getobject list *bottom* stat-function profile
              osql-result) 
	 *exclude-bt*)
  "Lisp functions NOT profiled with statistical profiler")

(defun stat-function (&optional olog)
  "Sampler called in timer interrupts"
  (and _stat-enabled_
       ((lambda (x)
	  (if x (setf (gethash x _profile-stats_) 
		      (1+ (or(gethash x _profile-stats_)0 )))))
	(if olog (ologtopcall _exclude-profile_)
	  (topcall _exclude-profile_)))))

(defun catchinterrupt ()
  "Called when interrupt happened"
  (cond 
   (*in-critical-section* (setq *interrupt-happened* t))
   (_debugging_ (help interrupt))
   (t (print 'Interrupt!)(reset))))
 
(defmacro douninterrupted (form)
  "Delay interrupt until after form evaluated"
  `(let (*interrupt-happened*) 
     (prog1 (let ((*in-critical-section* t)) , form)
       (if *interrupt-happened* (catchinterrupt)))))

(defun profile(&optional threshold)
  "Print top list of most called functions and their sampling percentage"
  (resetvar _stat-enabled_ nil
	    (let(res (sum 0))
	      (maphash (function(lambda(x y)
				  (setq sum (+ sum y))
				  (setq res (cons (cons x y) res))))
		       _profile-stats_)
	      (setq res (sort res (function(lambda (x y)(> (cdr x)(cdr y))))))
	      (dolist (x res)(rplacd x (* 0.1 (/ (* (cdr x) 1000) sum))))
	      (cons sum (subset res (f/l (x)(>= (cdr x) 
						(or threshold 0.5))))))))

(defun start-profile(&optional olog)
  "Start statistical profiler"
  (set-timer (if olog (q/l ()(stat-function t))
	       'stat-function)
	     _profiler-frequency_))

(defun stop-profile() 
  "Stop statistical profiler and clear statistics"
  (set-timer nil)
  (clrhash _profile-stats_))
