;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: profiling.lsp,v $
;;; $Revision: 1.25 $ $Date: 2008/12/25 19:35:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;; ===========================================================================
;;; $Log: profiling.lsp,v $
;;; Revision 1.25  2008/12/25 19:35:13  torer
;;; (setq *old-decompose* t) since ALEH depends on old code that cannot handle non-DNF predicates
;;;
;;; Revision 1.24  2008/06/03 12:00:54  ruslan
;;; cleaning selectbody from results of grouping algorithm
;;;
;;; Revision 1.23  2008/06/02 13:43:35  ruslan
;;; *** empty log message ***
;;;
;;; Revision 1.21  2008/04/12 13:07:42  ruslan
;;; bug fixing
;;;
;;; Revision 1.20  2008/01/19 09:53:36  ruslan
;;; abitlity to measure time of monitoring phase
;;;
;;; Revision 1.19  2007/12/17 15:54:33  ruslan
;;; types are used to store in structs. dynamic statistics collection. bug with types for structs is fixed
;;;
;;; Revision 1.18  2007/11/07 12:13:19  ruslan
;;; grouping algorithm is separated and improved
;;;
;;; Revision 1.17  2007/10/16 11:52:54  ruslan
;;; optimization of analysis query separately from retrieving query
;;;
;;; Revision 1.16  2007/10/15 09:18:39  ruslan
;;; default opt method for optimizing wrapper access predicates. comments on sortandpred0.
;;;
;;; Revision 1.15  2007/10/06 09:49:26  ruslan
;;; bug fix
;;;
;;; Revision 1.14  2007/10/06 09:41:16  ruslan
;;; reoptimize2 reoptimizes top with top optimization method and its subqueries with group optimization method
;;;
;;; Revision 1.13  2007/09/14 11:58:22  ruslan
;;; profile controller uses invoke plan. performance was improved noticably
;;;
;;; Revision 1.12  2007/09/14 11:07:29  ruslan
;;; profiler is simplified, but withou invoke-plan
;;;
;;; Revision 1.11  2007/09/14 08:38:13  ruslan
;;; invoke-plan is used. some minor changes.
;;;
;;; Revision 1.10  2007/09/14 08:12:23  ruslan
;;; correction of profiler
;;;
;;; Revision 1.9  2007/09/12 12:23:17  ruslan
;;; commented code removed
;;;
;;; Revision 1.8  2007/09/12 12:21:41  ruslan
;;; unnecessary type checks are removed from groups
;;;
;;; Revision 1.7  2007/09/11 13:23:11  ruslan
;;; missing functions
;;;
;;; Revision 1.6  2007/09/11 13:11:46  ruslan
;;; function to remove wrappers
;;;
;;; Revision 1.5  2007/09/11 08:16:30  ruslan
;;; minor change
;;;
;;; Revision 1.4  2007/09/11 08:12:39  ruslan
;;; setting current optimization method is done by functions. comments are added
;;;
;;; Revision 1.3  2007/08/08 12:52:20  ruslan
;;; infrastructure for auto-profiling together with few profiling aproaches
;;;
;;; Revision 1.2  2007/08/02 14:23:04  ruslan
;;; profiling infrastructure is implemented. using optimization methods on different levels has to be tested
;;;
;;; Revision 1.1  2007/07/31 06:30:33  ruslan
;;; infrastucture for auto-profiling. not ready yet.
;;;
;;; ===========================================================================

(setq *old-decompose* t)

(defstruct selectbody
  ;;; A SELECTBODY is a structure containing a compiled AMOSQL 
  ;;; function for a given binding pattern. 
  argl;; Argument symbols
  resl;; Result symbols
  pred;; Re-written predicate
  optpred;; Optimized selection predicate
  delpred;; Expression used when updating function. 
  ;;NIL if not updatable definition.
  locals;; Local symbols in predicates.
  orgpred;; Original predicate after simplification
   ;;; DO NOT CHANGE THE ORDER OF THE ABOVE FIELDS!
  argt;; Types of arguments.
  rest;; Types of results.
  loct;; Types of local variables.
  unoptimized;; original predicate before simplification
  expanded;; after view expansion
  expanded-simplified;; after view expansion and simplification
  normalized;; after normalization 
  normalized-simplified;; after normalization and simplification
  coercedpred;; Coerced predicate (if different).
  decomptree;; Decomposition tree.
  groups;; generated groups, which is list of 2 lists, where 
  ;; list 1 contains wrapper access, list 2 contains analyses.
  groups-fns;; generated transient fucntions, which is a list of 2 elements
  ;; element 1 contains profiler functions, element 2 contains list of 
  ;; transient functions generated for groups doing analyses.
  groupedpred);; Plan in terms of groups

(load "../lsp/grouping.algorithm.stream.lsp")


(defglobal *profiling* nil)
(defglobal *ungroup* nil)

(foreign-lispfn profiling ((boolean flg))()
		"To toggle to do auto-profiling for profiled grouping approach"
		(if (eq flg 'false)(setq flg nil)(init-profilers))
		(/setglobal '*profiling* flg)
		(/setglobal '*agg-tocollect* flg)
;		(/setglobal '*struct-stat* flg)
		(if flg (foreign-result)))

(foreign-lispfn ungroup ((boolean flg))()
		"To toggle to use profiler without grouping"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*ungroup* flg)
		(if flg (foreign-result)))

(osql "create function profile_controller(Function gfn, integer i, Object e)->
Boolean as foreign 'profile-controller';")

(defun simplestop (gfn args argl)
"Simple stop rule, which immediately stops profiling."
  t)

(defun simpletrue (gfn args argl)
  "Simple rule to stop profiling, which is called, when condition for it is 
satisfied"
  (and
   (setq *profiling* nil)
   (setq *agg-tocollect* nil)
   (setq *stop-monitor* clock)))


(defglobal *stop-profiling* 'simplestop) ; default stop profiler

(defglobal *stop-true* 'simpletrue) ; default

(defun profile-controller (fno gfn arity &rest args)
  "Controls profiling. First it executes the input function, which is usually
join order of groups. then it calls stop profiler from *stop-profiling* to
check if profiling should be stopped. For different impelementations of stop
profiler see stopprofiling.lsp"
  (invoke-plan fno gfn arity (car args))
  (if (and *profiling*
	   (apply *stop-profiling* (list gfn args)))
      (apply *stop-true* (list gfn args))))

(defun profiled-pred (wrap-pred pred argl sb groups-fns)
  "Put wrap-pred at the beginning of the result predicate, then add wrapping of pred, which contains groups"
  (set-top-opt)
  (let* 
      ((fno (createfunction '*TRANSIENT* argl
			    '((BOOLEAN)) nil nil
			    (cons 'FLATTENED (cons 'AND pred))))
       (new-pred (list 
		  (getfunctionnamed 
		   'FUNCTION.INTEGER.OBJECT.PROFILE_CONTROLLER->BOOLEAN)
		  fno 1 (second (first argl)))))
    (setf (selectbody-groups-fns sb) (cons fno (list groups-fns)))
    (setf (selectbody-groups-fns (getselectbody fno)) groups-fns)
    (append2 wrap-pred (list new-pred))))

(defun grouped-pred (sb)
  "Creates new predicate for the given groups without doing profiling.
It assumes that optimization for optimizing inside groups is set."
  (let ((pred nil)(wrap-pred nil)(wrap-arg nil)
	(groups (second (selectbody-groups sb)))
	(groups-fns nil)
	(wrapper-access (first (selectbody-groups sb))))
;    (setq *agg-tocollect* t)
    (dolist (g wrapper-access)
      (setq wrap-pred (append2 wrap-pred (group-pred g)))
      (setq wrap-arg (group-groupv g)))
    (dolist (g groups)
      (cond
       (*ungroup* 
	(setq pred (append2 (group-pred g) pred)))
       (t
	(let*
	    ((arglist (group-argv g))
	     (reslist (group-resv g))
	     (counter 0)
	     group fno)
	  (setq 
	   fno 
	   (createfunction '*TRANSIENT* arglist
			   '((BOOLEAN)) nil nil
			   (cons 'FLATTENED (cons 'AND (group-pred g)))))
	  (setq group 
		(cond
		 ((and (equal 1 (length reslist))(equal 0 (length arglist))
		       (equal 1 (length (group-groupv g))))
		  (list (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
			fno (second (first reslist))))
		 ((and (equal 1 (length arglist))(equal 0 (length reslist))
		       (equal 1 (length (group-groupv g))))
		  (list (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
			fno (second (first arglist))))
		 (t (error "Dyngroups undefined for groups with more than one
input or output variable and the only one variable should be grouped 
variable."))))
	  (setq groups-fns (cons fno groups-fns))
	  (setq pred (cons group pred))))))
    (setq pred (profiled-pred wrap-pred pred wrap-arg sb groups-fns))
    pred))

(defun update-sb (groups sb)
  "Sets the corresponding fields of the given selectbody with sets of groups 
containing predicates for accessing wrapper and sets of groups containing 
analyses of data retreived by the first set."
  (let ((groups-wo-wrapper nil)
	(wrapper-access nil))
    (dolist (g groups)
      (if (group-iswrap g)
	  (setq wrapper-access (cons g wrapper-access))
	(setq groups-wo-wrapper (cons g groups-wo-wrapper))))
    (setf (selectbody-groups sb) (cons wrapper-access 
				       (list groups-wo-wrapper)))
    groups-wo-wrapper))

(defun reopt-groupedpred (sb)
  "Calls reoptimizer for every group, which are inside profile functions, and 
for profile function itself. It assumes that optimization for optimizing 
inside groups is set"
  (cond
   (*ungroup*)
   (t
    (dolist (sq (second (selectbody-groups-fns sb)))
      (reoptimize sq))))
  (set-top-opt)
  (reoptimize (first (selectbody-groups-fns sb)))
  (selectbody-groupedpred sb))

(defun sortandpred0 (remaining sb)
 "if grouping true then groups are found for the input predicate. The wrapper
access group is put first in the plan then put a profile controller, which 
contains predicate of groups. Top level of groups is optimized with group 
method, order of groups (predicate of profile controller) optimized with top
method, and the wrapper predicates are optimized with default opt. method."
  (cond 
   ((atom remaining) remaining)
   ;; Applies grouping algorithm to the given predicate if the flag is true
   (*grouping* 
    (let ((groups (or (second (selectbody-groups sb))
		      (update-sb (grouping-algorithm remaining sb) sb)))
	  (old_ii _iino_) (old_sh _shno_)
	  mainoptmethod respred)
      (cond 
       ((> (length groups) 1)
	(unwind-protect
	    (progn
	      (setq mainoptmethod (set-group-opt))
	      (setq *grouping* nil)
	      (setq remaining
		    (if (selectbody-groupedpred sb)
			(reopt-groupedpred sb)
		      (grouped-pred sb)))
	      (setf (selectbody-groupedpred sb) remaining)
	      (set-opt-back mainoptmethod old_ii old_sh) ; default method
	      (setq respred (psort (purge remaining sb)
				   (selectbody-argl sb))))
	  (progn
	    (set-opt-back mainoptmethod old_ii old_sh)
	    (setq *grouping* t)))
	respred)
       (t
	(psort (purge remaining sb)
	       (selectbody-argl sb))))))
   (t
    (psort (purge remaining sb)
	   (selectbody-argl sb)))))

(defun set-group-opt ()
"Sets current optimization method to optimization inside groups."
  (/setglobal '_iino_ (first *group-optlevel*))
  (/setglobal '_shno_ (second *group-optlevel*))
  (aref (first (callfunction (getfunctionnamed 'optmethod)
			     (list *group-optimization-method*))) 0))

(defun set-top-opt ()
"Sets current optimization method to optimization of join order of groups."
  (/setglobal '_iino_ (first *top-optlevel*))
  (/setglobal '_shno_ (second *top-optlevel*))
  (aref (first (callfunction (getfunctionnamed 'optmethod) 
			     (list *top-optimization-method*))) 0))

(defun set-opt-back (mainoptmethod old_ii old_sh)
"Sets current optimization methods back to the given method."
  (/setglobal '_iino_ old_ii)
  (/setglobal '_shno_ old_sh)
  (aref (first (callfunction (getfunctionnamed 'optmethod) 
		(list mainoptmethod))) 0))

(defun reoptimize2 (f)
  "Reoptimize resolvent f with top method and all subqueires of f with group
method"
  (dolist (r (resolvents1 f))
    (let* ((sb (getselectbody r))
	   (pred (selectbody-pred sb))
	   (old_ii _iino_) 
	   (old_sh _shno_)
	   (mainoptmethod (set-group-opt)))
      (dolist (sq (pred-subqueries pred))
	(reoptimize sq t))
      (set-top-opt)
      (exec-cost-of-fn f t)
      (set-opt-back mainoptmethod old_ii old_sh))))

(defun reoptimize2-+(fno f r)
  (dolist (r (resolvents1 f))
    (reoptimize2 r t) ; include transient subqueries
    (osql-result f r)))

(osql "create function reoptimize2(Function f) -> Function
   as foreign 'reoptimize2-+';")

(osql "create function reoptimize2(Charstring fn) -> Function
   as select reoptimize2(theresolvent(fn));")

; Cost of profile controller is the cost of executing the given funciton,
; which is usually join order of predicates.
(setq *costfn*
      (foreign-lispfn 
       profile_controller_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((gfn (aref argl 0))
	    (grouping *grouping*)
	    (old_ii _iino_) (old_sh _shno_)
	    (mainoptmethod (set-top-opt))
	    val)
	 (setq *grouping* nil)
	 (cond
	  ((not (function_p gfn));; if the function is not known
	   (osql-result f bpat argl 10.0 1.0))
	  ((setq val (exec-cost-of-tbr gfn (cddr (arraytolist bpat))))
	   (osql-result f bpat argl (first val)
			(second val))))
	 (set-opt-back mainoptmethod old_ii old_sh)
	 (setq *grouping* grouping))))

(declarecosts 'FUNCTION.INTEGER.OBJECT.PROFILE_CONTROLLER->BOOLEAN '(- - -) *costfn*)

(defun wrapped-control-pred (pred)
  "Checks if the given predicate is wrapped by profile-controller"
  (eq (second pred) 'PROFILE-CONTROLLER))

(defun remove-controller-wrap (controlled-pred)
"Remove controller profiler"
  (cond
   ((null controlled-pred) '())
   ((conjunctionp controlled-pred)
    (cons 'and (remove-controller-wrap (cdr controlled-pred))))
   ((disjunctionp controlled-pred)
    (cons 'or (remove-controller-wrap (cdr controlled-pred))))
   ((wrapped-control-pred (car controlled-pred))
    (append2 (get-preds (fourth (car controlled-pred)))
	     (remove-controller-wrap (cdr controlled-pred))))
   (t (cons (car controlled-pred) (remove-controller-wrap 
				   (cdr controlled-pred))))))

(foreign-lispfn unprofileall ((charstring fn))()
		"Remove profiling controller and group wrappers from
the given function"
		(let* 
		    ((mainsb (getselectbody 
			      (getfunctionnamed (mksymbol fn))))
		     (tfn 
		      (first (selectbody-groups-fns mainsb)))
		     (sb (getselectbody tfn)))
		  (let ((ungrouped (remove-group-wrap 
				    (selectbody-optpred sb))))
		    (if ungrouped 
			(setf (selectbody-optpred sb) ungrouped)))
		  (let ((ungrouped (remove-controller-wrap
				    (selectbody-optpred mainsb))))
		    (if ungrouped
			(setf (selectbody-optpred mainsb) ungrouped)))))

(foreign-lispfn unprofile ((charstring fn))()
		"Remove profiling controller"
		(let* 
		    ((mainsb (getselectbody 
			      (getfunctionnamed (mksymbol fn)))))
		  (let ((ungrouped (remove-controller-wrap
				    (selectbody-optpred mainsb))))
		    (if ungrouped
			(setf (selectbody-optpred mainsb) ungrouped)))))

(foreign-lispfn cleansb ((charstring fn))()
		"Remove results of grouping algorithm from selectbody"
		(let* 
		    ((mainsb (getselectbody 
			      (getfunctionnamed (mksymbol fn)))))
		  (setf (selectbody-groups mainsb) nil)
		  (setf (selectbody-groups-fns mainsb) nil)
		  (setf (selectbody-groupedpred mainsb) nil)))

(foreign-lispfn ungroup ((charstring fn))()
		"Remove group wrappers from the given function"
		(let* 
		    ((mainsb (getselectbody 
			      (getfunctionnamed (mksymbol fn))))
		     (tfn 
		      (first (selectbody-groups-fns mainsb)))
		     (sb (getselectbody tfn)))
		  (let ((ungrouped (remove-group-wrap 
				    (selectbody-optpred sb))))
		    (if ungrouped 
			(setf (selectbody-optpred sb) ungrouped)))))
