;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: grouping.lsp,v $
;;; $Revision: 1.14 $ $Date: 2008/01/18 08:37:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Definition of group and its cost model and profiler. Profiling is a hash
;;; table where gorups are save execution time and cardinality per subquery.
;;; Cost model of groups is measured cost and fanout of its subquery or if no
;;; measurement are available it uses static cost of its subqeury.
;;; This implementation is used in the paper for fragmentation and dynamic cost
;;; modelling.
;;; ===========================================================================
;;; $Log: grouping.lsp,v $
;;; Revision 1.14  2008/01/18 08:37:48  ruslan
;;; moving myprint to correct file
;;;
;;; Revision 1.13  2007/11/07 12:13:19  ruslan
;;; grouping algorithm is separated and improved
;;;
;;; Revision 1.12  2007/09/11 08:11:13  ruslan
;;; group execution is repeated until constant _clock-profile_. Fanout 0 and 1 are replaced with lower and upper selectivity
;;;
;;; Revision 1.11  2007/08/08 12:50:59  ruslan
;;; wrap group returns measured execution time and fanout as result of the lisp function wrap-group
;;;
;;; Revision 1.10  2007/03/02 15:29:39  ruslan
;;; different levels for randomopt in profiled grouping on top and inside groups
;;;
;;; Revision 1.9  2007/03/01 08:49:53  ruslan
;;; dynprog max time is set to 200 to be able to do exhaustive on top and random inside groups.
;;;
;;; Revision 1.8  2007/02/28 12:48:18  ruslan
;;; grouping function to toggle grouping mode is moved to one place (grouping.lsp)
;;;
;;; Revision 1.7  2007/02/28 12:43:40  ruslan
;;; different optimization methods can be used for optimizing top predicate and for optimizing inside generated groups.
;;;
;;; Revision 1.6  2007/02/27 16:45:41  ruslan
;;; cost function for group does not return anything (does not call osql-result) if a given function is unexecutable for a given binding
;;;
;;; Revision 1.5  2007/02/09 10:57:00  ruslan
;;; group cost hint function is improved. dealing with grouping flag is improved. executability of tbr for the given transient function is checked.
;;;
;;; Revision 1.4  2006/12/10 11:12:44  ruslan
;;; dynamic group cost model and its regression test are updated to work under new changes of the AMOS
;;;
;;; Revision 1.3  2006/10/18 15:10:56  ruslan
;;; tbr resolvents for transient functions of groups are generated during optimization phase and cached. thus no optimization is performed during execution
;;;
;;; Revision 1.2  2006/10/16 14:06:19  ruslan
;;; cost function of group-wrap can handle calls from the-tbr-function
;;;
;;; Revision 1.1  2006/08/28 13:22:15  ruslan
;;; fragmentation code added
;;;
;;; ===========================================================================

(defglobal _clock-profile_ 0.0) ; time to stop rptq group execution
;;; From aggregations.lsp
(defglobal _cost-multiply_ 100000.0)
(defglobal _rpt-quantity_ 100)
; the key is function object or  list of function object and binging pattern. 
; The value is list: 
; bag variable name,
; sum of execution time, count of calls, count of produced tuples,
; sum of square of execution time.
(defstruct agg-statistic exec-time-sum calls quantity 
  exec-time-square)
(defglobal *agg-statistics* (make-hash-table :test (function equal)))
(defglobal *agg-tocollect* nil)
(defglobal _default-rpt_ 1)
; This is necessary to be able to have exhaustive on top and random inside
; groups.
(setq _DYNPROG_MAX_TIME_ 200)
; the optimization methods used during executing cost hint function for group
; they are also used in dyngroups for load and stream approaches
(defglobal *top-optimization-method* "ranksort")
(defglobal *group-optimization-method* "ranksort")

(foreign-lispfn group_optmethods ((charstring top)(charstring ingroup))
		((charstring oldtop)(charstring oldingroup))
		"To set optimization methods for optimizing top of the query 
and inside generated groups in dynamic group cost model"
		(foreign-result *top-optimization-method* 
				*group-optimization-method*)
		(/setglobal '*top-optimization-method* top)
		(/setglobal '*group-optimization-method* ingroup))

; Number of II and SH iterations for randomopt for top and inside groups
; used in dyngroups also
(defglobal *top-optlevel* (list 100 10))
(defglobal *group-optlevel* (list 100 100))

(foreign-lispfn group_optlevels ((integer top_ii)(integer top_sh)
				 (integer ingroup_ii)(integer ingroup_sh))
		((integer oldtop_ii)(integer oldtop_sh)
		 (integer oldingroup_ii)(integer oldgroup_sh))
		"To set optimization level for random optimization on the top 
of the query and inside generated groups in profiled grouping cost model"
		(foreign-result (first *top-optlevel*) (second *top-optlevel*)
				(first *group-optlevel*)
				(second *group-optlevel*))
		(/setglobal '*top-optlevel* (list top_ii top_sh))
		(/setglobal '*group-optlevel* (list ingroup_ii ingroup_sh)))

; flag for grouping, which can be used only after dyngroups is loaded.
(defglobal *grouping* nil)

(foreign-lispfn grouping ((boolean flg))()
		"To toggle generating plan with dynamic group cost model"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*grouping* flg)
		(if flg (foreign-result)))



(defun update-agg-statistic (key execution-time card)
  (let 
      ((cur-value (gethash key *agg-statistics*)))
    (if (null cur-value)
	(setq cur-value 
	      (make-agg-statistic 
	       :exec-time-sum 0.0 :calls 0
	       :quantity 0
	       :exec-time-square 0.0)))
    (let
	((exec-time (agg-statistic-exec-time-sum cur-value))
	 (calls (agg-statistic-calls cur-value))
	 (exec-time-square (agg-statistic-exec-time-square cur-value))
	 (quantity (agg-statistic-quantity cur-value)))
      (setf (agg-statistic-exec-time-sum cur-value) 
	    (+ exec-time execution-time))
      (setf (agg-statistic-calls cur-value)
	    (+ calls 1))
      (setf (agg-statistic-quantity  cur-value)
	    (+ quantity card))
      (setf (agg-statistic-exec-time-square cur-value)
	    (+ exec-time-square (* execution-time execution-time)))
      (setf (gethash key *agg-statistics*) cur-value))))

(foreign-lispfn aggstat ((boolean flg))()
		"To toggle collecting statistics aggregates execution"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*agg-tocollect* flg)
		(if flg (foreign-result)))

(foreign-lispfn clr_aggstat ()()
		(clrhash *agg-statistics*))

(defun print-agg-stats ()
  (let
      ((lres nil))
    (maphash 
     (f/l (k v)
	  (let*
	      ((time (agg-statistic-exec-time-sum v))
	       (card (agg-statistic-quantity v))
	       (calls (agg-statistic-calls v))
	       (cost (/ (* time _cost-multiply_) 
			(if (= calls 0) 1 calls)))
	       (fanout (/ (+ card 0.0) 
			  (if (= calls 0) 1 calls))))
	    (setq lres (cons (list k cost fanout)
			     lres))))
     *agg-statistics*)
    (cons (list "function" "cost" "fanout")
	  lres)))
;    (mapc (function osql-result)
;	  (cons (list "function" "cost" "fanout")
;		lres))))

;(create-function print_aggstat()((bag)) as foreign (print-agg-stats))
(defun print_aggstat(fno b)
  (mapc (function osql-result) (print-agg-stats)))
(osql "create function print_aggstat()->bag as foreign 'print_aggstat';")

(defun rpt-clock (started func &optional rpt)
  (if (null rpt) (setq rpt _default-rpt_))
  (let
      ((i 0))
    (* rpt (loop
	     (rptq rpt (funcall func))
	     (1++ i)
	     (if (> (- (clock) started) _clock-profile_)
		 (return i))))))


;;; new code. Grouping

;(osql "create function group(Function gfn, Object e, Object r) -> Boolean 
;  as foreign 'wrap-group';")

;(osql "create function group(Function gfn, Object e, Object r1, Object r2) 
;                       -> Boolean
;  as foreign 'wrap-group';")

(osql "create function group(Function gfn, Object e) -> Boolean 
  as multidirectional ('bf' foreign 'wrap-group');")
(osql "create function group(Function gfn, Object e, Object r) -> Boolean 
  as multidirectional ('bff' foreign 'wrap-group');")
(osql "create function group(Function gfn, Object e, Object r1, Object r2) 
                       -> Boolean
  as multidirectional ('bfff' foreign 'wrap-group');")

(defun wrap-group (fno gfn &rest args)
  (let*
      ((bpat (mapcan (f/l (x) (if (eq x '*) (list '+) (list '-))) args))
       (fntbr (the-tbr-function gfn bpat))
       (argl (subset args (f/l (x)(neq x '*)))))
    (if *agg-tocollect*
	(let* ((start-time (clock))
	       (rptd
		(rpt-clock start-time
			   (f/l ()
				(mapfunction fntbr argl (f/l (x))))))
	       (counter 0)
	       exec-time)
	  (mapfunction fntbr argl 
		       (f/l (row)
			    (1++ counter)
			    (apply 'osql-result
				   (cons gfn 
					 (mapcan 
					  (f/l (x)
					       (if (eq x '*)(list (pop row))
						 (list x)))
					  args)))))
	  (setq exec-time (- (clock) start-time))
	  (update-agg-statistic gfn
				(/ exec-time (1+ rptd)) counter)
	  (list exec-time counter))
      (mapfunction fntbr argl 
		   (f/l (row)
			(apply 'osql-result
			       (cons gfn 
				     (mapcan (f/l (x)
						  (if (eq x '*)(list (pop row))
						    (list x)))
					     args))))))))

(setq *costfn*
      (foreign-lispfn 
       group_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((gfn (aref argl 0))
	    (grouping *grouping*)
	    (mainoptmethod (aref (first 
				  (callfunction 
				   (getfunctionnamed 'optmethod)
				   (list *group-optimization-method*))) 0))
	    (old_ii _iino_) (old_sh _shno_)
	    val gc)
	 (setq *grouping* nil)
	 (/setglobal '_iino_ (first *group-optlevel*))
	 (/setglobal '_shno_ (second *group-optlevel*))
	 (cond
	  ((not (function_p gfn));; if the function is not known
	   (osql-result f bpat argl 10.0 1.0))
	  ((and (setq val 
		      (gethash gfn
			       *agg-statistics*))
		;; caching tbr resolvents to avoid their optimization 
		;; during execution and checking if the tbr exists
		(exec-cost-of-tbr gfn (cdr (arraytolist bpat))))
	   ;; calculating the cost based on profiled statistics
	   (let*
	       ((time (agg-statistic-exec-time-sum val))
		(calls (agg-statistic-calls val))
		(card (agg-statistic-quantity val))
		(cost (/ (* time _cost-multiply_) 
			 (if (= calls 0) 1 calls)))
		(fanoutH (/ (+ card 0.0) 
			   (if (= calls 0) 1 calls)))
		(fanout (if (equal fanoutH 0.0) _lowest-fanout_
			  (if (equal fanoutH 1.0) _fanout-equal-one_ 
			    fanoutH))))
	     (osql-result f bpat argl cost fanout)))
	  ((setq val (exec-cost-of-tbr gfn (cdr (arraytolist bpat))))
	   ;; if no profiling was done
	   (osql-result f bpat argl (first val)
			(second val))))
	 (callfunction (getfunctionnamed 'optmethod) (list mainoptmethod))
	 (/setglobal '_iino_ old_ii)
	 (/setglobal '_shno_ old_sh)
	 (setq *grouping* grouping))))

(declarecosts 'FUNCTION.OBJECT.GROUP->BOOLEAN '(- -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.GROUP->BOOLEAN '(- +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN '(- - -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN '(- - +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN '(- + +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN '(- + -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- - - -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- - - +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- - + +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- - + -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- + + +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- + + -) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- + - +) *costfn*)
(declarecosts 'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN '(- + - -) *costfn*)

(defun wrapped-pred (pred)
  "Checks if the given predicate is wrapped by wrap-group"
  (eq (second pred) 'WRAP-GROUP))

(defun get-preds (transient-func)
  "Returns predicate of the given transient function. It removes conjunct or disjunct predicate."
  (cdr (selectbody-optpred (getselectbody transient-func))))

(defun remove-group-wrap (grouped-pred)
  "Finds all predicates, which are wrapped by wrap-group, and replaces them by their predicates. Assumes that the input predicate is in DNF, but probably works and with unnormalized predicates"
  (cond
   ((null grouped-pred) '())
   ((conjunctionp grouped-pred)
    (cons 'and (remove-group-wrap (cdr grouped-pred))))
   ((disjunctionp grouped-pred)
    (cons 'or (remove-group-wrap (cdr grouped-pred))))
   ((wrapped-pred (car grouped-pred))
    (append2 (get-preds (fourth (car grouped-pred)))
	     (remove-group-wrap (cdr grouped-pred))))
   (t (cons (car grouped-pred) (remove-group-wrap (cdr grouped-pred))))))


;;; for printing experiments in AmosQL
(osql "create function myprint(real,real,real,real)->boolean as
foreign 'myprint';")

(osql "create function myprint(real,real,real,real,real)->boolean as
foreign 'myprint';")
