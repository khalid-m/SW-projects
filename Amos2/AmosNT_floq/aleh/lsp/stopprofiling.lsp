;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: stopprofiling.lsp,v $
;;; $Revision: 1.20 $ $Date: 2008/06/22 14:39:35 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Definitions of functions controlling profiling. All of them has input
;;; predicate, which is join of the query groups.
;;; ===========================================================================
;;; $Log: stopprofiling.lsp,v $
;;; Revision 1.20  2008/06/22 14:39:35  ruslan
;;; saving plan cost after dynamic reoptimization
;;;
;;; Revision 1.19  2008/06/12 14:34:44  ruslan
;;; bug is fixed in first collect then profile
;;;
;;; Revision 1.18  2008/06/03 13:36:50  ruslan
;;; bug fixed
;;;
;;; Revision 1.17  2008/06/03 12:01:41  ruslan
;;; stop rule to first to collect than do profiled grouping
;;;
;;; Revision 1.16  2008/06/03 10:47:43  ruslan
;;; two stopprofiling methods used in tuning profiling are improved
;;;
;;; Revision 1.15  2008/06/02 13:46:27  ruslan
;;; *** empty log message ***
;;;
;;; Revision 1.13  2008/05/30 15:48:35  ruslan
;;; tuning profiling
;;;
;;; Revision 1.12  2008/05/05 08:59:27  ruslan
;;; two level reoptimization
;;;
;;; Revision 1.11  2008/05/01 12:53:41  ruslan
;;; measuring reoptimization time
;;;
;;; Revision 1.10  2008/04/14 15:03:04  ruslan
;;; stop criteria for doing only reoptimization of an analysis subquery
;;;
;;; Revision 1.9  2008/03/25 14:37:22  ruslan
;;; typo
;;;
;;; Revision 1.8  2008/03/25 14:33:22  ruslan
;;; help functions. counting number of events used in collecting card. statistics.
;;;
;;; Revision 1.7  2008/03/01 15:59:43  ruslan
;;; collecting cardinality statistics on slots and using in query optimization
;;;
;;; Revision 1.6  2007/12/17 15:54:33  ruslan
;;; types are used to store in structs. dynamic statistics collection. bug with types for structs is fixed
;;;
;;; Revision 1.5  2007/09/14 08:38:13  ruslan
;;; invoke-plan is used. some minor changes.
;;;
;;; Revision 1.4  2007/09/14 08:12:23  ruslan
;;; correction of profiler
;;;
;;; Revision 1.3  2007/09/11 08:13:18  ruslan
;;; new profiling stop rules are implemented
;;;
;;; Revision 1.2  2007/08/09 08:08:26  ruslan
;;; test function is improved
;;;
;;; Revision 1.1  2007/08/08 12:52:20  ruslan
;;; infrastructure for auto-profiling together with few profiling aproaches
;;;
;;; ===========================================================================

(setq *stop-profiling* 'stopNoChanges) ; variable storing, which stop function
; to call

(defglobal _counter-of-calls_) ; current number of profiled events per group
(defglobal _counter-of-nochanges_) ; how many no changes were done in a row
(defglobal _stop-nochanges_ 1) ; how many no changes in a row should be 
(defglobal _stop-counter_ 200) ; how many events should be profiled before stop
(defglobal _cost-before-unwrap_) ; cost of calling controller before unwrap
(defglobal _new-pred-order_ nil) ; group order from most recent optimization
(defglobal _old-pred-order_ nil) ; group order before most recent optimization
(defglobal *stat-step* 10) ; check confident interval every 10 calls
(defglobal *stat-zAlpha* 1.645) ; probability >90%
(defglobal *stat-Delta* 0.1) ; not more than 10% from mean on each side
(defglobal *elslott* *elslotN*) 
(defglobal *muslott* *muslotN*)
(defglobal *jbslott* *jbslotN*)
(defglobal *profiled_events* 0)
(defglobal *reoptt-sum* 0.0)
(defglobal *reoptt-sqsum* 0.0)
(defglobal *reoptt-count* 0)

(foreign-lispfn set_stop_counter ((integer nrevents))()
		"To set stop counter for profiler"
		(setq _stop-counter_ nrevents))

(foreign-lispfn set_nochange_counter ((integer nrevents))()
		"To set counter of no changes for profiler"
		(setq _stop-nochanges_ nrevents))

(foreign-lispfn reset_reoptt ()
		((real reoptt_sum)(real reoptt_sqsum)(integer reoptt_count))
		(foreign-result *reoptt-sum* *reoptt-sqsum* *reoptt-count*)
		(setq *reoptt-sum* 0.0)
		(setq *reoptt-sqsum* 0.0)
		(setq *reoptt-count* 0))

(foreign-lispfn get_reoptt ()
		((real reoptt_sum)(real reoptt_sqsum)(integer reoptt_count))
		(foreign-result *reoptt-sum* *reoptt-sqsum* *reoptt-count*))


(defun init-profilers ()
  "Set initial values for stop profilers"
  (setq *grouping* nil)
  (setq _counter-of-calls_ (make-hash-table :test (function equal)))
  (setq _counter-of-nochanges_ 0)
  (setq *profiled_events* 0)
  (osql "clr_aggstat();"))

;;; For every event profile all groups. Thus it calls those groups, which
;;; were not profiled during execution due to selectivity of first groups.

(defun fullyprofileNfirstevents (tfn argl)
"Profile all groups, including not executed, for _stop-counter_ nrevents events. Saving new order of groups and cost before unwrapping."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun justprofileallNfirst (tfn argl)
  "Stop when groups profiled for stop-counter_ nrevents events. 
Profile all groups, including not executed."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun profileNfirstevents (tfn argl)
"Stop when _stop-counter_ events were profiled. Profiling is done only for 
executed groups."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun profileuntilallgroups (tfn argl)
"Stop profiling when no groups withou statistics left. Profiling only
executed groups."
  (let ((allgroups t))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((null (gethash group *agg-statistics*)) (setq allgroups nil))))
    (cond
     (allgroups
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))


(defun profileuntilallnozero (tfn argl)
"Stop profiling when no groups with zero fanout left."
  (let ((allgroups t))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (= 0.0 (agg-statistic-quantity (gethash group *agg-statistics*))))
	(setq allgroups nil))))
    (cond
     (allgroups
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defglobal _stat-file_ "../experiments/profilestat200exec.randomopt.txt")
; not used anywhere


(defun printprofileNfirstevents (tfn argl)
"Stop profiling when _stop-counter_ events were profiled. Profile all groups
including not executed. Print a lot of temporal information. Do reoptimization
every event."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (princ htc *mystream*)
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl))))
      (print-profile-stat group htc))
    (princ ", reoptimization," *mystream*)
    (reoptimize tfn)
    (princ (first (exec-cost-of-fn tfn)) *mystream*)
    (princ ", " *mystream*)
    (princ (second (exec-cost-of-fn tfn)) *mystream*)
    (princ ", " *mystream*)
    (princ (isorder (cdr (selectbody-optpred (getselectbody tfn)))
		    _old-pred-order_) *mystream*)
;    (princ ", " *mystream*)
;    (princ (order-dist (cdr (selectbody-optpred (getselectbody tfn)))
;		       _old-pred-order_) *mystream*)
;    (princ ", " *mystream*)
;    (/setglobal '*agg-tocollect* nil)
;    (princ (test) *mystream*)
;    (/setglobal '*agg-tocollect* t)
    (terpri *mystream*)
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun place (el old-order deep)
"Place of group el in the old order of groups."
  (cond
   ((null old-order) 0)
   ((equal el (car old-order))
    deep)
   (t
    (place el (cdr old-order) (1+ deep)))))

(defun order-dist (pred old-order)
"Calculate distance between new predicated and old order"
  (cond
   ((null pred)
    (setf _old-pred-order_ nil)
    0)
   (t
    (let ((dist (order-dist (cdr pred)(cdr old-order))))
      (setq dist
	    (cond
	     ((equal (fourth (car pred)) (car old-order))
	      dist)
	     (t
	      (+ (place (fourth (car pred)) (cdr old-order) 1) 
		 dist))))
      (setf _old-pred-order_ (cons (fourth (car pred)) _old-pred-order_))
      dist))))

(defun isorder (pred old-order)
"Return 0 if the order between predicate and old order or how many groups are
not in the same order."
  (cond
   ((null pred)
    (setf _old-pred-order_ nil)
    0)
   (t
    (let ((not-in-order (isorder (cdr pred) (cdr old-order))))
      (cond
       ((equal (fourth (car pred)) (car old-order))
	(setf _old-pred-order_ (cons (fourth (car pred)) _old-pred-order_))
	not-in-order)
       (t
	(setf _old-pred-order_ (cons (fourth (car pred)) _old-pred-order_))
	(1+ not-in-order)))))))

(defun print-profile-stat (group event_nr)
  "Prints profiling statistics in file _stat-file_ of executing every group 
on first _stop-counter_ events."
  (let*
      ((g-stat (gethash group *agg-statistics*))
       (cost-total (* (agg-statistic-exec-time-sum g-stat) _cost-multiply_))
       (total-calls (agg-statistic-calls g-stat))
       (cost-mean (/ cost-total total-calls))
       (passed-total (+ 0.0 (agg-statistic-quantity g-stat)))
       (selectivity (/ passed-total total-calls)))
    (princ ", " *mystream*)
    (cond
     ((equal event_nr total-calls)
      (princ group *mystream*)
      (princ ", " *mystream*)
      (princ cost-mean *mystream*)
      (princ ", " *mystream*)
      (princ cost-total *mystream*)
      (princ ", " *mystream*)
      (princ selectivity *mystream*)
      (princ ", " *mystream*)
      (princ passed-total *mystream*))
     (t 
      (princ group *mystream*)
      (princ " Error. Number of profiler calls: " *mystream*)
      (princ event_nr *mystream*)
      (princ ", " *mystream*)
      (princ total-calls *mystream*)))))

(defun test-exp () 
"Test function calling expcuts->event."
  (osql "expcuts();"))

(defun test ()
"Measuring perfromance of calling expcuts->event."
  (let (extnew ext)
    (test-exp)
    (sleep 40)
    (setq ext (timer2 (test-exp)))
    (sleep 20)
    (setq extnew (timer2 (test-exp)))
;    (setq ext (min ext extnew))
;    (sleep 20)
;    (setq extnew (timer2 (test-exp)))
    (min ext extnew)))


(defun profileAllNfirstPrintPlan (tfn argl)
"Stop profiling when _stop-counter_ events were profiled. Profile all groups
including not executed. Print final plan of group order."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (reoptimize tfn)
      (print-plan tfn)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun profileAllNfirstPrintAll (tfn argl)
"Stop profiling when _stop-counter_ events were profiled. Profile all groups
including not executed. Print final plan of group order. Save information
about new plan for calculating difference and cost of group order."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
;      (/setglobal '*struct-stat* nil)
      (reoptimize tfn)
      (print-plan tfn)
      (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun print-plan (tfn)
"Print plan of profiler function. Should be called before unwrap is done."
  (princ (first (exec-cost-of-fn tfn)) *mystream*)
  (princ ", " *mystream*)
  (princ (second (exec-cost-of-fn tfn)) *mystream*)
  (terpri *mystream*)
  (dolist (group (cdr (selectbody-optpred (getselectbody tfn))))
    (let* ((g (fourth group))
	   (gfn (getfunctionnamed 'group))
	   (costs (car (getfunction 'group_costs 
				    (list gfn #(- -) (vector g 'ev))))))
      (princ g *mystream*)
      (princ ", " *mystream*)
      (princ (first costs) *mystream*)
      (princ ", " *mystream*)
      (princ (second costs) *mystream*)
      (terpri *mystream*))))

(defun stopNoChanges (tfn argl)
"Profile until no changes in group order is done for _stop-nochanges_ events 
in a row."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (reoptimize tfn)
    (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
    (cond ((= 0 (isorder _new-pred-order_ _old-pred-order_))
	   (1++ _counter-of-nochanges_))
	  (t (setq _counter-of-nochanges_ 0)))
    (cond
     ((= _counter-of-nochanges_ _stop-nochanges_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun print-newplan ()
"Print saved new plan."
  (princ (first _cost-before-unwrap_) *mystream*)
  (princ ", " *mystream*)
  (princ (second _cost-before-unwrap_) *mystream*)
  (terpri *mystream*)
  (dolist (group _new-pred-order_)
    (let* ((g (fourth group))
	   (gfn (getfunctionnamed 'group))
	   (costs (car (getfunction 'group_costs 
				    (list gfn #(- -) (vector g 'ev))))))
      (princ g *mystream*)
      (princ ", " *mystream*)
      (princ (first costs) *mystream*)
      (princ ", " *mystream*)
      (princ (second costs) *mystream*)
      (terpri *mystream*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Collecting statistics over partilces per event
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun isConfident (zAlpha Delta)
  (let* ((el-stat (first (callfunction *sobject-stat-fn* (list *eventtype* 
							      *elslott*))))
	 (mu-stat (first (callfunction *sobject-stat-fn* (list *eventtype* 
							      *muslott*))))
	 (jb-stat (first (callfunction *sobject-stat-fn* (list *eventtype* 
							      *jbslott*))))
	 (el-n (+ (aref el-stat 0) 0.0))
	 (el-mean (/ (aref el-stat 1) el-n))
	 (el-stderr (sqrt (- (/ (aref el-stat 2) (* el-n el-n))
			     (/ (* el-mean el-mean) el-n))))
	 (mu-n (+ (aref mu-stat 0) 0.0))
	 (mu-mean (/ (aref mu-stat 1) mu-n))
	 (mu-stderr (sqrt (- (/ (aref mu-stat 2) (* mu-n mu-n))
			     (/ (* mu-mean mu-mean) mu-n))))
	 (jb-n (+ (aref jb-stat 0) 0.0))
	 (jb-mean (/ (aref jb-stat 1) jb-n))
	 (jb-stderr (sqrt (- (/ (aref jb-stat 2) (* jb-n jb-n))
			     (/ (* jb-mean jb-mean) jb-n)))))
    (and
     (>= (* Delta el-mean) (* zAlpha el-stderr))
     (>= (* Delta mu-mean) (* zAlpha mu-stderr))
     (>= (* Delta jb-mean) (* zAlpha jb-stderr)))))

(defun getstructstat_standard (fno filename zAlpha Delta step counter)
  "Stream data from file by using wrapper function aleh_stream starting from 
the beginning of file until confident interval is satisfied. zAlpha is 
confidence, Delta is variance for the difference of estimate and mean, 
step is number of events in a single sample before condition for confidence is
checked. 
It returns number of emitted tuples."
  (let ((counter 0)(structstat *struct-stat*))
    (setq *struct-stat* t)
    (catch 'getstructstat
      (mapfunction 
       (getfunctionnamed 'charstring.aleh_stream->event)
       (list filename) (f/l (x) (1++ counter)
			    (if (and (= 0 (mod counter step))
				     (isConfident zAlpha Delta))
				(throw 'getstructstat t)))))
    (setq *struct-stat* structstat)
    (osql-result filename zAlpha Delta step counter)))

(osql "create function getstructstat(charstring filename, real zAlpha, 
real Delta, integer step)->integer counted 
as foreign 'getstructstat_standard';")

(defun stopStatCollectStandard (tfn argl)
  (let
      ((calls (aref (first (callfunction 
			    *sobject-stat-fn* (list *eventtype* 
						    *elslott*)))
		    0)))
    (1++ *profiled_events*)
    (cond
     ((and (= (mod calls *stat-step*) 0) 
	   (isConfident *stat-zAlpha* *stat-Delta*))
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (reoptimize2 tfn t)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))))))

(defun stopStatCollectStandardMeasure (tfn argl)
  (let
      ((calls (aref (first (callfunction 
			    *sobject-stat-fn* (list *eventtype* 
						    *elslott*)))
		    0)) reoptt)
    (1++ *profiled_events*)
    (cond
     ((and (= (mod calls *stat-step*) 0) 
	   (isConfident *stat-zAlpha* *stat-Delta*))
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (setq reoptt (timer2 (reoptimize2 tfn t)))
      (setq *reoptt-sum* (+ *reoptt-sum* reoptt))
      (setq *reoptt-sqsum* (+ *reoptt-sqsum* (* reoptt reoptt)))
      (1++ *reoptt-count*)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))))))

(foreign-lispfn collectStat ()()
		(setq *elslott* *elslot*) 
		(setq *muslott* *muslot*)
		(setq *jbslott* *jbslot*)
		(setq *stop-profiling* 'stopStatCollectStandard))

(foreign-lispfn collectStatNaive ()()
		(setq *elslott* *elslotN*) 
		(setq *muslott* *muslotN*)
		(setq *jbslott* *jbslotN*)
		(setq *stop-profiling* 'stopStatCollectStandard))

(foreign-lispfn set_alpha_delta ((real zalpha)(real delta))()
		"To set stop counter for profiler"
		(setq *stat-zAlpha* zalpha)
		(setq *stat-Delta* delta))

(foreign-lispfn set_stat_step ((integer step))()
		"To set stop counter for profiler"
		(setq *stat-step* step))

(foreign-lispfn get_profiled_counter ()((integer counter))
		(foreign-result *profiled_events*))

(foreign-lispfn reset_profiled_counter ()((integer counter))
		(setq *profiled_events* 0)
		(foreign-result *profiled_events*))

(foreign-lispfn set_profiled_counter((integer new_counter))((integer counter))
		(setq *profiled_events* new_counter)
		(foreign-result *profiled_events*))

(defun stopReoptimize (tfn argl)
  (setq *profiling* nil)
  (setq *agg-tocollect* nil)
  (reoptimize2 tfn)
  (setq _cost-before-unwrap_ (exec-cost-of-fn tfn)))

(defun stopMeasureReoptimize (tfn argl)
  (setq *profiling* nil)
  (setq *agg-tocollect* nil)
  (let ((reoptt (timer2 (reoptimize2 tfn))))
    (setq *reoptt-sum* (+ *reoptt-sum* reoptt))
    (setq *reoptt-sqsum* (+ *reoptt-sqsum* (* reoptt reoptt)))
    (1++ *reoptt-count*)
    (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))))

(foreign-lispfn set_reoptimize_stop ()()
	       (setq *profiling* t)
	       (setq *stop-profiling* 'stopReoptimize))

(foreign-lispfn set_reoptimize_meas_stop ()()
	       (setq *profiling* t)
	       (setq *stop-profiling* 'stopMeasureReoptimize))

(foreign-lispfn cost_after_reoptimize () ((real cst)(real fnt))
		(foreign-result (first _cost-before-unwrap_)
				(second _cost-before-unwrap_)))

(defun stopCollectNoChangesReoptAll (tfn argl)
"Profile until no changes in group order is done for _stop-nochanges_ events 
in a row."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (reoptimize tfn)
    (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
    (cond ((= 0 (isorder _new-pred-order_ _old-pred-order_))
	   (1++ _counter-of-nochanges_))
	  (t (setq _counter-of-nochanges_ 0)))
    (cond
     ((= _counter-of-nochanges_ _stop-nochanges_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (setq reoptt (timer2 (reoptimize2 tfn t)))
      (setq *reoptt-sum* (+ *reoptt-sum* reoptt))
      (setq *reoptt-sqsum* (+ *reoptt-sqsum* (* reoptt reoptt)))
      (1++ *reoptt-count*)
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun stopCollectNoChanges (tfn argl)
"Profile until no changes in group order is done for _stop-nochanges_ events 
in a row."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
    (reoptimize tfn)
    (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
    (cond ((= 0 (isorder _new-pred-order_ _old-pred-order_))
	   (1++ _counter-of-nochanges_))
	  (t (setq _counter-of-nochanges_ 0)))
    (cond
     ((= _counter-of-nochanges_ _stop-nochanges_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(foreign-lispfn stopNoChanges ((integer toStop))()
		(setq _stop-nochanges_ toStop)
		(setq *stop-profiling* 'stopCollectNoChanges))

(foreign-lispfn stopNoChangesReopt ((integer toStop))()
		(setq _stop-nochanges_ toStop)
		(setq *stop-profiling* 'stopCollectNoChangesReoptAll))

(defun profileCollectNfirsteventsReopt0 (tfn argl)
"Stop when _stop-counter_ events were profiled. Profiling is done only for 
executed groups."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
;    (reoptimize tfn)
;    (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
;    (cond ((= 0 (isorder _new-pred-order_ _old-pred-order_))
;	   (1++ _counter-of-nochanges_))
;	  (t (setq _counter-of-nochanges_ 0)))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (reoptimize tfn)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(defun profileCollectNfirsteventsReopt2 (tfn argl)
"Stop when _stop-counter_ events were profiled. Profiling is done only for 
executed groups."
  (let ((htc (gethash tfn _counter-of-calls_)))
    (setq htc
	  (if htc (setf (gethash tfn _counter-of-calls_) (1+ htc))
	    (setf (gethash tfn _counter-of-calls_) 1)))
    (dolist (group (selectbody-groups-fns (getselectbody tfn)))
      (cond 
       ((or (null (gethash group *agg-statistics*))
	    (> htc (agg-statistic-calls (gethash group *agg-statistics*))))
	(wrap-group tfn group (first argl)))))
;    (reoptimize tfn)
;    (setq _new-pred-order_ (cdr (selectbody-optpred (getselectbody tfn))))
;    (cond ((= 0 (isorder _new-pred-order_ _old-pred-order_))
;	   (1++ _counter-of-nochanges_))
;	  (t (setq _counter-of-nochanges_ 0)))
    (cond
     ((= htc _stop-counter_)
      (setq *profiling* nil)
      (setq *agg-tocollect* nil)
      (osql "sobjectstat(FALSE);")
      (osql "slotstat(FALSE);")
      (reoptimize2 tfn t)
;      (setq reoptt (timer2 (reoptimize2 tfn t)))
;      (setq *reoptt-sum* (+ *reoptt-sum* reoptt))
;      (setq *reoptt-sqsum* (+ *reoptt-sqsum* (* reoptt reoptt)))
;      (1++ *reoptt-count*)
      (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
      (let* ((sb (getselectbody tfn))
	     (ungrouped (remove-group-wrap (selectbody-optpred sb))))
	(if ungrouped (setf (selectbody-optpred sb) ungrouped)))))))

(foreign-lispfn stopNfirstEventsReopt0 ((integer events))()
		(setq _stop-counter_ events)
		(setq *stop-profiling* 'profileCollectNfirsteventsReopt0))

(foreign-lispfn stopNfirstEventsReopt2 ((integer events))()
		(setq _stop-counter_ events)
		(setq *stop-profiling* 'profileCollectNfirsteventsReopt2))

(foreign-lispfn getEventCounter ()((integer htc))
		(maphash (f/l (k v) (foreign-result v)) _counter-of-calls_))

;;; Collect stat first than do profiling
(defun stopStandardCollectStatSwitchToPG (tfn argl)
  (let
      ((calls (aref (first (callfunction 
			    *sobject-stat-fn* (list *eventtype* 
						    *elslott*)))
		    0)))
    (1++ *profiled_events*)
    (cond
     ((and (= (mod calls *stat-step*) 0) 
	   (isConfident *stat-zAlpha* *stat-Delta*))
      t))))

(defun trueStopCollecSwitchToPG (tfn argl)
  (osql "sobjectstat(FALSE);")
  (osql "slotstat(FALSE);")
  (reoptimize2 tfn t)
  (setq *stop-profiling* 'stopCollectNoChanges)
  (setq *agg-tocollect* t)
  (setq *stop-true* 'simpletrue))

(foreign-lispfn stopCollectProfileNoChanges ((real zAlpha)(real delta)
					     (integer toStop))()
		(setq *stat-zAlpha* zAlpha)
		(setq *stat-Delta* delta)
		(setq _stop-nochanges_ toStop)
		(setq *agg-tocollect* nil)
		(setq *stop-profiling* 'stopStandardCollectStatSwitchToPG)
		(setq *stop-true* 'trueStopCollecSwitchToPG))
