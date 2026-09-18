;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Tore Risch, Gustav Fahl, Vanja Josifovski, UDBL
;;; $RCSfile: optimizer.lsp,v $
;;; $Revision: 1.169 $ $Date: 2013/06/05 11:36:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; =============================================================
;;; $Log: optimizer.lsp,v $
;;; Revision 1.169  2013/06/05 11:36:34  torer
;;; Remove sb parameter in call to ABSORBER-REWRITE
;;;
;;; Revision 1.168  2013/05/31 09:18:24  torer
;;; Introduced accessfilter predicates
;;;
;;; Revision 1.167  2013/05/01 15:24:25  minzh812
;;; hook up absorber and finalizer manager.
;;;
;;; Revision 1.166  2013/02/19 06:02:02  thatr500
;;; Added AQIT entry into compilephase2 and disabled it
;;;
;;; Revision 1.165  2013/02/17 17:10:57  torer
;;; Now estimates selectivity independent of index kind
;;;
;;; Revision 1.164  2013/02/07 19:01:55  torer
;;; Variable name change
;;;
;;; Revision 1.163  2013/02/07 18:45:48  torer
;;; Added placeholder for FINALIZER
;;;
;;; Revision 1.162  2012/10/20 14:12:52  torer
;;; New flag to disallow source code to be stored in image:
;;;   _INCLUDE-SOURCE_
;;;
;;; Revision 1.161  2012/10/12 07:44:16  torer
;;; Rewrites over OPTIONAL eliminated
;;;
;;; Revision 1.160  2012/09/06 20:51:53  torer
;;; (PC x) now prints all subplans too
;;;
;;; Revision 1.159  2012/08/15 18:23:13  torer
;;; New function
;;; (CREATE-TRANSIENT-FOREIGN-FUNCTION ARGTYPES RESTYPES DEF &OPTIONAL COST)
;;; to create transient foreign function which is garbage collected when
;;; no longer referenced
;;;
;;; Revision 1.158  2012/05/22 17:44:01  torer
;;; Could not handle TRUE in AND blocks
;;;
;;; Revision 1.157  2012/05/21 20:26:02  torer
;;; cost-rank now handles compound predicates too
;;;
;;; Revision 1.156  2012/05/15 13:51:22  torer
;;; More robust optimization
;;;
;;; Revision 1.154  2012/05/08 16:12:30  torer
;;; left-outer-join -> optional
;;;
;;; Revision 1.153  2012/05/02 17:16:48  torer
;;; optional() aware optimization of conjunctions and
;;; order preserving generation of conjunctive predicate
;;;
;;; Revision 1.152  2012/04/27 20:13:41  torer
;;; Better type checking
;;;
;;; Revision 1.151  2012/04/26 12:49:38  torer
;;; optional(pred) now supported in AmosQL
;;;
;;; Revision 1.150  2012/04/25 18:42:17  torer
;;; More generic handling of compound predicates
;;;
;;; Revision 1.149  2012/04/24 14:59:52  torer
;;; Using COMPOUND-P
;;;
;;; Revision 1.148  2012/04/24 14:07:13  torer
;;; ANDORP -> COMPOUND-P for more generality
;;;
;;; Revision 1.147  2012/03/13 15:03:48  torer
;;; (IS-QUERY Q) returns t if Q legal AMOSQL query
;;; PREPARE-QUERY bug fixed
;;;
;;; Revision 1.146  2012/02/11 14:59:36  torer
;;; Simpler AmosQL pc()
;;;
;;; Revision 1.145  2012/01/16 10:05:28  torer
;;; Now possible to have image without Lisp source code
;;;
;;; Revision 1.144  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.143  2011/12/17 17:53:32  torer
;;; memory leak in PREPARE-QUERY
;;;
;;; Revision 1.142  2011/01/09 16:29:56  torer
;;; New function (ppt fn) to prettyprint the 'plan trail' of a function,
;;; which is the overall structure of the execution plan and its subplans.
;;; The plan trail of a resolvent is obtained by (plan-trail fno)
;;;
;;; Revision 1.141  2011/01/04 07:41:05  torer
;;; PC indicates invalid TBR form
;;;
;;; Revision 1.140  2011/01/03 16:51:16  minzh812
;;; modified comment
;;;
;;; Revision 1.139  2011/01/03 16:32:24  minzh812
;;; Added and edited some comments
;;;
;;; Revision 1.138  2010/09/02 15:01:12  torer
;;; Caching failed compilations
;;;
;;; Revision 1.137  2010/06/08 14:09:05  torer
;;; PC prints original form of TBR too
;;;
;;; Revision 1.136  2010/06/07 19:53:05  torer
;;; PC now pretty-prints exact TBR form
;;;
;;; Revision 1.135  2010/05/26 15:30:17  torer
;;; PC now prints final TR with * variables
;;;
;;; Revision 1.134  2010/05/19 19:53:32  zeitler
;;; Reverting to 1.132
;;;
;;; Revision 1.132  2010/04/29 11:33:01  larme597
;;; Change to "predify-simple" by Tore. Rolling back execution plan to predicate
;;; list works better now.
;;;
;;; Revision 1.131  2010/04/20 19:17:00  torer
;;; fanout of non-key table close to 1 => _default-key-fanout_
;;;
;;; Revision 1.130  2010/03/16 14:58:30  torer
;;; _DEFAULT-FOREIGN-FANOUT_ set to 0.99
;;;
;;; Revision 1.128  2010/03/13 14:38:53  torer
;;; UNCACHE-COSTS did not clear TBR costs
;;;
;;; Revision 1.127  2010/02/17 18:56:24  torer
;;; Nicer PC
;;;
;;; Revision 1.126  2010/01/20 14:08:47  torer
;;; Turned off annoying message
;;;
;;; Revision 1.125  2009/12/28 13:38:43  torer
;;; Removed dead code
;;;
;;; Revision 1.124  2009/12/14 21:08:02  torer
;;; Occurs check
;;;
;;; Revision 1.123  2009/11/27 08:47:50  torer
;;; Fully commented
;;;
;;; Revision 1.122  2009/11/26 07:32:25  torer
;;; Join method printed with PC
;;;
;;; Revision 1.121  2009/11/25 21:43:37  torer
;;; Bug in index scan type printing of PC
;;;
;;; Revision 1.120  2009/11/25 20:35:56  torer
;;; More informative PC for TBR
;;;
;;; Revision 1.119  2009/11/21 14:45:02  torer
;;; Modified trace message
;;;
;;; Revision 1.118  2009/11/16 20:00:11  torer
;;; (setq *optimizing-message* nil) turns of optimizing message
;;;
;;; Revision 1.117  2009/11/13 19:02:02  torer
;;; New function (check-optimized fno) to reoptimized fno is needed
;;;
;;; Revision 1.116  2009/11/13 07:39:15  torer
;;; Nicer optimization message
;;;
;;; Revision 1.115  2009/11/12 22:08:50  torer
;;; Smarter cost uncaching
;;;
;;; Revision 1.114  2009/11/12 20:18:36  torer
;;; Improved cost caching
;;;
;;; Revision 1.113  2009/10/03 11:14:52  torer
;;; Default cost model for bagged results
;;;
;;; Revision 1.112  2009/05/05 19:56:03  torer
;;; Better documentation
;;;
;;; Revision 1.111  2008/12/28 15:51:44  torer
;;; Test for non-executable TBR by BPAT-OPTIMIZE-FUNCTION 'worked' by
;;; catching indefinite recursion error, a very slow, unclean, and difficult to debug method!
;;; Now it is based on catch and throw on CATCH-EXEC-ERROR instead.
;;; In general, catching all errors is ugly.
;;;
;;; Revision 1.110  2008/12/27 21:06:03  torer
;;; Non-DNF plans allowed with dynamic programming
;;;
;;; Revision 1.109  2008/12/25 19:33:34  torer
;;; Ranksort can now optimize non-normalized predicates
;;; *use-dnf* = nil => No normalization to DNF
;;;
;;; Revision 1.108  2008/11/23 15:00:27  torer
;;; Stricter type checking
;;;
;;; Revision 1.107  2008/11/21 15:19:07  torer
;;; Printing file where resolvent error occurs
;;;
;;; Revision 1.106  2008/11/19 07:54:13  torer
;;; Code verified
;;;
;;; Revision 1.105  2008/11/13 08:39:35  torer
;;; #'foo' now evaluated by parser.
;;; Enables computed result types for tclose(function,object)->object
;;;
;;; Revision 1.104  2008/11/11 07:44:37  torer
;;; More informative error message for non-executable plans
;;;
;;; Revision 1.103  2008/11/07 19:59:46  torer
;;; More readable error message when query is not executable
;;;
;;; Revision 1.102  2008/05/25 14:03:50  torer
;;; Large multi-directional TBRs not in-lined.
;;; Controlled by *max-substitutable-size*
;;;
;;; Revision 1.101  2008/05/21 14:54:38  torer
;;; Bug fixed in maintaining local variables for multidirectional derived functions
;;;
;;; Revision 1.100  2008/05/21 10:32:29  torer
;;; Variable *catcherror* can be set to nil if you don't want system to internally
;;; catch optimization errors
;;;
;;; Revision 1.99  2008/05/19 13:13:59  torer
;;; Bug fixed that prohibited computing costs of non-DNF TBR predicates
;;;
;;; Revision 1.98  2008/05/13 19:36:48  torer
;;; Multi-directional derived functions always in-lined
;;;
;;; Revision 1.97  2008/05/12 21:09:08  torer
;;; Correct cost model for complex multidirectional derived functions
;;;
;;; Revision 1.96  2008/04/04 14:15:07  silvias
;;; prepare-query works with DISTINCT
;;;
;;; Revision 1.95  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.94  2008/04/02 13:26:37  torer
;;; Fixed bug in covering binding patterns for multidirectional derived functions
;;;
;;; Revision 1.93  2007/12/18 16:25:08  torer
;;; Bugs when sending transients with constructor forms over sockets
;;;
;;; Revision 1.92  2007/12/18 11:36:24  torer
;;; Named subplans
;;;
;;; Revision 1.91  2007/12/18 07:36:58  torer
;;; Constructor forms on transient objects
;;;
;;; Revision 1.90  2007/12/01 14:05:09  torer
;;; Restored original selectivity computations for stored functions
;;;
;;; Revision 1.88  2007/11/16 13:44:25  torer
;;; Degenerate case
;;;
;;; Revision 1.87  2007/10/18 12:22:54  torer
;;; Added code to split TBRs into transportable subplans
;;;
;;; Revision 1.86  2007/10/11 12:18:29  torer
;;; No binding adornments on wildcards
;;;
;;; Revision 1.85  2007/10/09 05:26:46  torer
;;; Recursion removed for scalability over size of execution plan
;;;
;;; Revision 1.84  2007/10/08 19:06:44  torer
;;; PC now shows binding adornments on variables in TBR predicates
;;;
;;; Revision 1.83  2007/09/27 07:56:16  torer
;;; Added code to continue optimizing TBR plans
;;;
;;; Revision 1.82  2007/05/31 14:24:32  torer
;;; Cost of *invoke-plan* = cost of invoked plan
;;;
;;; Revision 1.81  2007/02/22 16:31:51  torer
;;; Reentrant RANDOM-OPT
;;;
;;; Revision 1.80  2006/12/14 18:20:28  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; Revision 1.79  2006/12/06 22:31:49  torer
;;; Strict typing of vector constructors in queries
;;;
;;; Revision 1.78  2006/11/17 08:04:05  torer
;;; 'Amos' removed from error messages
;;;
;;; Revision 1.77  2006/11/15 14:22:10  torer
;;; Short function names in PC
;;;
;;; Revision 1.76  2006/11/07 15:51:09  torer
;;; Moved code from optimizer.lsp to rewrite.lsp
;;;
;;; Revision 1.75  2006/07/25 13:20:37  torer
;;; Optimized reoptimize
;;;
;;; Revision 1.74  2006/07/24 21:32:18  torer
;;; Not called Lisp function APPLYFUNCTION removed
;;;
;;; Revision 1.73  2006/06/29 09:21:29  ruslan
;;; fixing a bug that after reoptimization plan_cost didn't calculate new cost instead it used the cost of the old plan
;;;
;;; Revision 1.72  2006/06/22 09:44:32  ruslan
;;; bug is fixed that reoptimization goes right it produces good plan, while as result of the bug very bad plan was produced by any optimization method.
;;;
;;; Revision 1.71  2006/06/08 21:25:57  torer
;;; Possibility to choose between optimizing top level or including transients
;;;
;;; Revision 1.70  2006/06/07 18:51:09  torer
;;; Faster getcaledpred for faster randomized optimization
;;;
;;; Revision 1.69  2006/05/22 14:28:11  torer
;;; Complex multidirectional derived functions now OK
;;;
;;; Revision 1.68  2006/05/17 18:52:31  torer
;;; Removed or_branches_vars as it is not used in any regression test
;;;
;;; Revision 1.67  2006/05/05 09:45:09  ruslan
;;; bug fixed in fanout of disjunction. it is a sum of fanout of each branch now, while it was sum + 1
;;;
;;; Revision 1.66  2006/04/28 08:40:26  ruslan
;;; reoptimize handles transient functions again
;;;
;;; Revision 1.65  2006/04/28 04:40:55  torer
;;; Reoptimie resored. It should not recache cost. That is done by exec-cost-of-fn.
;;;
;;; Revision 1.64  2006/04/27 19:15:18  torer
;;; Uncached costs
;;;
;;; Revision 1.63  2006/04/25 14:16:38  torer
;;; Eliminated double reoptimization
;;;
;;; Revision 1.62  2006/04/24 12:02:18  torer
;;; Cacheing cost computation
;;;
;;; Revision 1.60  2006/04/19 14:37:48  ruslan
;;; default key fanout is set to 0.99
;;;
;;; Revision 1.58  2006/04/14 09:03:19  ruslan
;;; reoptimize now handels transient functions too
;;;
;;; Revision 1.57  2006/04/13 10:39:54  ruslan
;;; reoptimize is accessable from lisp and function cost in lisp is added
;;;
;;; Revision 1.56  2006/04/13 07:49:07  ruslan
;;; default cost model of stored functions is restored
;;;
;;; Revision 1.55  2006/04/12 20:59:08  torer
;;; Multi-database decomposition separated
;;;
;;; Revision 1.54  2006/04/12 19:17:45  torer
;;; Cost profile of predicate now always on format (COST FANOUT [pred])
;;;
;;; Revision 1.53  2006/04/12 15:46:02  ruslan
;;; default cost model for stored indexed functions is improved that fanout of them is multiplied by 0.99
;;;
;;; Revision 1.52  2006/04/12 08:21:14  torer
;;; Correct reconstruction of variable *BINDINGS* for cost-based optimization
;;;
;;; Revision 1.51  2006/04/08 14:19:39  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.50  2006/03/28 11:58:13  torer
;;; One more stage printed by PC
;;;
;;; Revision 1.49  2006/03/12 19:45:42  torer
;;; Nicer printing of intermediate query representations
;;;
;;; Revision 1.48  2006/03/09 17:37:02  petrini
;;; More rewrites and better printouts.
;;;
;;; Revision 1.47  2006/03/08 17:08:20  petrini
;;; Smarter optimization.
;;; Optionally saving more intermediate results on selectbody.
;;;
;;; Revision 1.46  2006/03/02 08:23:48  torer
;;; Saves view exanded and DNF versions of predicate on selectbody if
;;; _save-intermediates_ true.
;;;
;;; =============================================================

; seconds to wait for dynamic programming
(defglobal  _DYNPROG_MAX_TIME_ 5 
  "Seconds to run dynamic programming before switching to FALLBACKFN")
(defglobal _varsubstitutions_ (make-hash-table)
  "Table of variable substitutions for predicate unification")
(defglobal _select_)
(document _select_ "The latest ad hoc query plan")

;;; Default cost model constants:
(defglobal _default-foreign-fanout_ 0.99
  "Default fanout of single valued foreign functions")
(defglobal _default-foreign-cost_ 0.5
  "Default cost of single valued foreign function")
(defglobal _default-bagres-fanout_ 100
  "Default fanout of bag valued function")
(defglobal _default-bagres-cost_ 100
  "Default fanout of bag valued function")
(defglobal _default-aggregate-fanout_ 0.99
  "Default fanout of aggregate functions")
(defglobal _default-aggregate-cost_ 100.0
  "Default cost of aggregate functions")
(defglobal _default-combiner-cost_ (* 10 _default-aggregate-cost_)
  "Default cost of bag valued aggregate functions (combiners)")
(defglobal _default-combiner-fanout_ _default-bagres-fanout_
  "Default fanout of bag valued aggregate functions (combiners)")
(defglobal _default-relation-cardinality_ _default-bagres-fanout_
  "Used cardinality of empty stored function")
(defglobal _default-index-fanout_ 2.0
  "Used fanout on empty index")
(defglobal _default-key-fanout_ 0.99
  "Used fanout of unique index")
(defglobal _default-constructor-fanout_ 0.99
  "Fanout of constructors")

(defglobal _max-sampled-tuples_ 1000
  "Max number of tuples to scan to compute selectivity")
(defglobal _default-selectivity_ 0.4
  "Default selectivity of predicate with all params bound")
(defglobal _lowest-priority_ '(0 0.99)
  "Cost an fanout of boolean value") 
;;; End default cost model constants

(defglobal _selectivity-hashtable_ 
  (make-hash-table :test (function equal))
  "Hash table used for computing selectivity of attribute")

;;; Optimization method used: ranksort or exhaustive 

(defvar *optlog* nil "File where optimizer tracing is printed")
(defvar *printopt* nil "Trace cost-based optimization")
(defvar *catcherror* t 
  "Set to nil if system should not catch optimization errors")

(defvar *old-decompose* nil "Old style decompoistion without nested OR")

(defstruct rewrite;; to hold results of predicate rewriters
  this;; The current predicate being translated
  bpat;; The binding pattern in call to THIS
  bnd;; The variables bound after the call to THIS
  rest;; The remaining TR predicates
  translated;; The TBR predicate THIS is translated into
  )

(defvar *catch-exec-error* nil "Ignore unsafe plans")
(defvar *runtime-executability-check* nil "Delay executability until run time")

(defvar *max-substitutable-size* 10
  "Largest execution plan (in # of primitive predicates) to in-line")

(defvar *optimizing-message* nil "Print message when re-optimizing TBR")

(defglobal _invoke-plan_ nil "OID of function holding INVOKE-PLAN operator")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Entry functions to cost-based optimization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun check-optimized (fno)
   "Reoptimize function FNO is needed"
   (exec-cost-of-fn fno))

(defun exec-cost-of-fn (fno &optional recompute)
  "Compute execution cost of FNO in forward direction"
  (cond ((and (not recompute)
              (getobject fno 'cost)))
        (t (/putobject fno 'cost
		       (exec-cost-of-tbr fno (forward-bpat fno) recompute)))))

(defun exec-cost-of-tbr (fn bpat &optional recompute)
  "Computes (cost fanout) for given function FN and BPAT. 
   NIL means that the predicate is not executable with that BPAT"
  (let* ((fnobj (un_pred_fn (getfunctionnamed fn)))
	 bpatfn)
    (and (not (transientp fn)) 
	 *optimizing-message*
	 (formatl t "Optimizing " fn 
		  " for '" (listbpat bpat) "'" t))
    (setq bpatfn (bpat-optimize-function fnobj bpat *catcherror* recompute t))
    (cond ((tbr-p bpatfn) 
	   (let ((cst (tbr-cost bpatfn))
		 (sb (tbr-selbody bpatfn)))
	     (cond ((and cst (not (oid-p cst))) 
		    (selectq cst(fail nil)cst)) ; explicit cost
		   ((null sb) bpatfn)	; no selectbody -> punt
		   (t (compute-exec-cost-pred
		       (selectbody-optpred sb)
		       (selectbody-argl sb))))))
	  ((null bpatfn) nil);; nil means the predicate is not executable
	  ((and (not recompute) (getobject fnobj 'cost)))
	  (t (/putobject bpatfn 'cost 
			 (compute-exec-cost (getselectbody bpatfn)))))))

(defun decompose-pred (pred sb)
  "Do cost-based local optimization of PRED with selectbody SB"
  (if *old-decompose* (old-decompose-pred pred sb);; obsoltete code
    (let ((*bindings* (selectbody-bindings sb))
	  (pred0 (purge-void-preds pred sb));; Insert * for unused variables
	  (argl (selectbody-argl sb))
	  pred1)
      (setf (selectbody-coercedpred sb) pred0)
      ;;after purge, it removes decode function and replace unused var by *
      (setq pred1 (absorber-rewrite pred0))
      (setf (selectbody-absorbed sb) pred1)
      (finalize (optimize-compound-predicate pred1 argl)
                sb))));; cost-based optimization 

(defun optimize-compound-predicate (pred argl)
  "Do cost-based optimization of arbitrary PRED when variables in 
   ARGL are bound"
  (cond ((osql-constantp pred) pred)
        ((osql-variablep pred) pred)
        ((compound-p pred)
	 (selectq (car pred)
		  (and (optimize-conjunction (cdr pred) argl))
		  (or (optimize-disjunction (cdr pred) argl))
		  (optional (optimize-optional (cdr pred) argl))
		  (error "Optimization not implemented for" (car pred))))
	(t  (optimize-conjunction (list pred) argl))))

(defun optimize-conjunction (predl argl)
  "Optimize a conjuction of predicates in list PREDL when
   variables in ARGL are bound"
  ;; The positions of compound predicates in a conjunction are retained
  (let ((blocks (and-blocks (unandify predl))) (bnd argl) newbnd res)
    (dolist (b blocks)
      (setq newbnd (binds-variables b bnd))
      (selectq (car b)
	       (or (setq res (nconc1 res (optimize-disjunction (cdr b) bnd))))
	       (optional (setq res (nconc1 res (list 'optional
						     (optimize-conjunction
						      (cdr b) bnd)))))
	       (and (setq res (nconc res (psort (cdr b) bnd))))
	       (error "Cannot optimize AND block" (car b)))
      (setq bnd newbnd))
    (andify res)))

(defun optimize-disjunction (predl argl)
  "Optimize a disjunction of predicates in list PREL when
   variables in ARGL are bound" 
  (orify (mapcar (f/l (p)(optimize-compound-predicate p argl))
		 predl)))

(defun optimize-optional (predl argl)
  "Cost based optimization of OPTIONAL compound predicates"
  (list 'optional (optimize-conjunction predl argl)))

(defun uncache-costs (fno)
  "Clear cost caches for FNO and all functions dependent on FNO"
  (cond ((oid-p fno)
	 (/putobject fno 'cost nil)
	 (mapbpats fno (f/l (tbr) (uncache-costs (tbr-impl tbr))))
	 (dolist (d (getobject fno 'usedbyfunction))
	   (if (getobject d 'cost)(uncache-costs d))))))

(defun reoptimize (f &optional subplanstoo)
  "Reoptimize resolvent f or all resolvents of generic function f"
  (dolist (r (resolvents1 f))
    (let* ((sb (getselectbody r))
	   (pred (selectbody-pred sb)))
      (if subplanstoo 
	  (dolist (sq (pred-subqueries pred))
	    (reoptimize sq t)))
      (uncache-costs f)
      (exec-cost-of-fn f t))))

(defun function-subqueries (fno)
  "List all subqueries referenced in selectbody of FNO"
  (let ((sb (getselectbody fno)))
    (and sb (pred-subqueries (selectbody-pred (getselectbody fno))))))

(defun pred-subqueries (pred)
  "List all subqueries referenced in PRED"
  (let (res)
    (mappred pred (f/l (x)
		       (dolist (v x)(and (oid-p v) 
					 (getselectbody v)
                                         (transientp v)
					 (setq res (adjoin v res))))))
    res))

(defun genqvars (n &optional res)
  "Generate N parameters for PREPARE-QUERY and add to RES"
  (let (res (i n))
    (while (> i 0)
      (setq res (cons (pack '? i) res))
      (setq i (1- i)))
    res))

(defun objlog (query)
  "Print the execution plans of query string QUERY"
  (pc (compile-query query)))

(defun qplan (query)
  "Return the optimized ObjectLog predicate for query string QUERY"
  (selectbody-optpred (getselectbody (compile-query query))))

(defun ppt (fn)
  "Prettyprint the plan trail of FN"
  (pps (plan-trail (theresolvent fn))))

(defun plan-trail (fno)
   "Compute the plan trail of FNO"
   (let ((op (selectbody-optpred (getselectbody fno))))
     (map-over-pred op 
        (f/l (sp)
          (cond ((or (osql-constantp sp) 
                     (osql-variablep sp)) sp)
                ((oid-p (car sp))
                 (if (transientp (car sp)) '*transient*
                      (oid-name (car sp))))
                ((not (call-p sp)) (list 'error (car sp)))
                ((eq (oid-name (third sp)) 'function.makebag->bag)
                 (list 'makebag (plan-trail (fourth sp))))
                (t (externalize (third sp) t))))
         (f/l (cp) cp))))

(defun ppff (fno)
  "Prettyprint first foreign Lisp function called in FNO"
  (ppf (get-foreign-lispfn fno)))

(defun bff  (fno)
  "Break first foreign Lisp function called in FNO"
  (putbreak (get-foreign-lispfn fno)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pretty print transformed predicates and execution plans
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun printed-execution-plan (sb &optional externalize)
  "Construct the execution plan presented by pc();"
  (let ((res (bind-adorn-pred (selectbody-argl sb)
	           (selectbody-optpred sb))))
    (if externalize (externalize res t) res)))

(defun pc (osqlfn &optional file planonly)
  "Print execution plans for function OSQLFN on FILE"
  (let ((stream (if file (openstream file "w") *standard-output*))
        (*no-constructor-print* t))
    (or _include-source_ (setq planonly t))
    (unwind-protect
	(dolist (fno (or (resolvents (getfunctionnamed osqlfn))
			 (list (getfunctionnamed osqlfn))))
	  (let ((sb (getobject fno 'selectbody))
		(oc (get-oc fno))
		nm head)
            (if (not (listp (oid-name fno)))
		(setq nm (oid-name fno))
	      (setq nm fno))
            (formatl stream "----------------------------" t
		     (function-signature fno) t)
	    (cond
             ((relationp osqlfn)
	      (formatl stream "  is stored relation" t))
	     (sb 
	      (setq head (pc-head nm
				  (selectbody-argl sb)
				  (selectbody-resl sb)))
	      (cond ((not planonly)
		     (cond (oc (formatl stream t "Original definition:")
			       (pprint (get-orgcode fno) stream)))
		     (print-stage nil
				  (selectbody-unoptimized sb)
				  head
				  "Unoptimized"
				  stream t)
		     (print-stage (selectbody-unoptimized sb)
				  (selectbody-orgpred sb)
				  head
				  "Simplified"
				  stream t)
		     (print-stage (selectbody-orgpred sb)
				  (selectbody-expanded sb)
				  head
				  "View expanded"
				  stream t)
		     (print-stage (selectbody-expanded sb)
				  (selectbody-expanded-simplified sb)
				  head
				  "View expanded and simplified"
				  stream t)
		     (if *enable-aqit*
			 (print-stage nil
				      (selectbody-aqit sb)
				      head
				      "AQIT"
				      stream t))
		     (print-stage (selectbody-expanded-simplified sb)
				  (selectbody-normalized sb)
				  head
				  "Normalized"
				  stream t)
		     (print-stage (or (selectbody-normalized sb)
				      (selectbody-orgpred sb))
				  (selectbody-pred sb)
				  head
				  "Normalized and simplified"
				  stream t)
		     (print-stage (selectbody-pred sb)
				  (selectbody-coercedpred sb)
				  head
				  "Final TR"
				  stream t)
		     (print-stage (selectbody-coercedpred sb)
				  (selectbody-absorbed sb)
				  head
				  "Absorbed"
				  stream t)
		     (if (selectbody-decomptree sb)
			 (progn 
			   (formatl stream "Decomposition tree:")
			   (formatl stream t head " <-" t)
			   (tnp (selectbody-decomptree sb))
			   (terpri stream)))
		     (print-stage (selectbody-coercedpred sb)
				  (selectbody-optpred sb)
				  head "TBR" stream t)))
	      (print-stage (selectbody-coercedpred sb)
			   (printed-execution-plan sb)
			   head
			   "Execution plan"
			   stream t)))
	    (if file (closestream stream))))
      nil)))

(defun print-stage (prevstage stage head tag stream short)
  "Help function to print intemediate query representation"
  (cond ((null stage) nil)
        ((equal stage prevstage)
          (formatl stream t tag ": same" t))
        (t (formatl stream t tag ":" t head " <-" "~PP" 
                    (externalize-pred stage short)))))

(defun bind-adorn-pred (bound pred)
  "Add binding adornments on variables in PRED when BOUND are bound variables:
    - (bound) and + (unbound) on variables"
  (cond ((osql-variablep pred) pred)
        ((osql-constantp pred) pred)
	((compound-p pred)
	 (selectq (car pred)
		  (and (cons 'nested-loop-join
			     (bind-adorn-and bound (cdr pred))))
		  (or  (cons 'union-all
			     (mapcar (f/l (p)(bind-adorn-pred bound p))
				     (cdr pred))))
                  (optional (cons 'optional
				  (bind-adorn-and bound (cdr pred))))
		  (list 'not-valid-tbr: pred)))
        ((call-p pred)(list* 'call (second pred)
			     (bind-adorn-args bound (cddr pred))))
        (t (bind-adorn-stored bound pred))))

(defun pplans (fn)
  "Print the plan of function named FN and all its subplans"
  (pplans1 (theresolvent fn)))

(defun pplans1 (fno)
  (pc fno nil t)
  (mapc (function pplans1)(function-subqueries fno)))

(defun getbestindex-bpat (ro bpat)
  "Choose best index, given table RO and binding pattern BPAT"
  (let (chosen 
        (indexes (relation-indexes ro)))
    (or (dolist (indx indexes)
	  (let ((ip (index-pos indx)))
	    (cond ((not(eq '- (nth ip bpat))) nil)
		  ((index-unique indx)(return indx))
		  (chosen (return chosen))
		  (t (setq chosen indx)))))
	(or chosen (car indexes)))))

(defun bind-adorn-stored (bound pred)
  "Printed execution plan for call to stored function, given BOUND variables"
  (if (not (relationp (car pred)))
      (list 'not-valid-tbr: pred)
    (let* ((bpat (argsbpat (cdr pred) bound))
	   (index (getbestindex-bpat (car pred) bpat))
	   (res (bind-adorn-args bound pred))
	   (type (index-type index)))
      (cond ((null index) (cons 'table-has-no-index res))
	    ((eq (nth (index-pos index) bpat) '-) 
	     (if (index-unique index)(cons (pack type '-index-get) res)
	       (cons (pack type '-index-scan) res)))
	    (t (cons (pack type '-full-scan) res))))))

(defun bind-adorn-and (bound andl)
  "Add binding adornments for arguments of AND" 
  (let ((bnd bound))
    (mapcar (f/l (pred)
		 (prog1 (bind-adorn-pred bnd pred)
		   (setq bnd (binds-variables pred bnd))))
	    andl)))

(defun bind-adorn-args (bound pred)
  "Add binding adornments for arguments of simple predicate"
  (list* (un_pred_fn (car pred))
	 (mapcar (f/l (v)
		      (cond ((or (osql-constantp v)(eq v '*)) v)
                            ((memq v bound)
			     (pack v '-))
			    ((symbolp v) (pack v '+))
                            (t v)))
		 (cdr pred))))

(defun binds-variables (pred bound)
  "Compute the variables always bound after PRED called
   given that the vaiables BOUND are called beforehand"
  (if (atom pred) bound 
    (selectq (car pred)
	     ((and optional) (dolist (arg (cdr pred))
		    (setq bound (binds-variables arg bound)))
		  bound)
	     (or (or-binds-variables (cdr pred) bound))
	     (call (pred_binds (cddr pred) bound))
	     (pred_binds pred bound))))

(defun or-binds-variables (orl bound)
   "Compute variables always bound by OR predicate"
   (let (bl)
     (dolist (pred orl)
        (if bl (setq bl (intersection bl (binds-variables pred nil)))
            (setq bl (binds-variables pred nil))))
     (union bl bound)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Other optimizer functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun compute-exec-cost (sb)
  "Given a selectbody SB compute (cost fanout) of its optimized version"
  (let ((opred (selectbody-optpred sb))
	(dtree (selectbody-decomptree sb))
        )
    (if (atom opred) 
	_lowest-priority_
      (if dtree 
	  (list (tnode-cost dtree) (tnode-fanout dtree))
	(let ((*bindings* (selectbody-bindings sb)))
	  (compute-exec-cost-pred opred (selectbody-argl sb)))))))

(defun compute-exec-cost-pred (pred bnd)
  "Compute the cost of executing ptredicate given variables bound in BND"
  (cond ((compound-p pred)
         (selectq (car pred)
		  (and (andpredcost (cdr pred) bnd))
		  (or (orpredcost (cdr pred) bnd))
		  (optional (andpredcost (cdr pred) bnd))
		  (error "Cannot compute exeution cost of" (car pred))))
	((osql-constantp pred) '(1 0));; No cost to access constant
	((osql-variablep pred) '(1 0.01));; Small cost to access variable
	(t (simple-pred-cost-bnd (getcalledpred pred) bnd))))

(defun non-exec-error (pred &optional bnd)
  "Called when unsafe execution plan detected"
  (cond (*catch-exec-error*
	 (throw 'catch-exec-error nil))
        (t (let* ((p (first-pred pred))
		  (uv (pred_binds p bnd)))
	     (amos-error "Query not executable." _CR_
			 "    Detected "
			 (when-calling (car p))
			 (if uv
			     (concat _CR_ "    Unbound variables: "  uv)
			   ""))))))

(defun when-calling (fno)
   (cond ((eq fno _makebag_) "when forming bag")
         ((transientp fno) "when calling local function")
         (t (concat "when calling " (externalize fno t)))))

(defun first-pred (pred)
  "Get the first primitive predicate in PRED"
  (catch 'first-pred (mappred pred 
			      (f/l (p)(or (symbolp p)(osql-constantp p)
					  (throw 'first-pred p))))))

(defmacro catch-exec-error (form)
  "Catch unsafe execution plans compiled in FORM"
  (list 'let '((*catch-exec-error* t))
	(list 'catch ''catch-exec-error form)))

(defmacro printopt (&rest args)
  "Macro for printing optimizer tracing. Allows concurrent logging by
   several AMOS-es"
  `(cond (*printopt*
	  (with-file opt-stream *optlog* 
		     (formatl opt-stream ,@ args)
		     "a"))))

(defun bestmodefunction (pred bpat)
  "Given a foreign predicate call, pred, and a binding pattern, bpat,
   retrieve the cheapest TBR resolvent of car(pred).
   The one which binds the most variables is considered cheapest
   since we assume that the cost for some
   TBR resolvent is correlated to the number of bound variables."
  (let ((ffn (car pred))
	min-cost
	min-fanout
	min-coverage
	best-impl
        best-bpat)
    (cond
     ((dtr? ffn)
      '(dtr--+))
     (t
      (mapbpats
       ffn
       (f/l 
	(tbr)
	(let* ((tbr_bpat (tbr-bpat tbr))
	       (tbr_impl (tbr-impl tbr))
	       (coverage (covers-dyn ffn tbr_bpat bpat))
	       cf tbr_cost tbr_fanout)
	  (cond ((null coverage));; incompatible
		(t
		 (setq cf (get-pred-cost-fo pred tbr_bpat))
		 (setq tbr_cost (first cf))
		 (setq tbr_fanout (second cf))
		 (cond ((and 
			 tbr_impl
			 (or 
			  (null min-cost)
			  ;; first time
			  ;; TODO: why cost has precedence over fanout?
			  ;; it may happen that fanout is more important
			  ;; than cost because of later expensive predicates
			  (if (= tbr_cost min-cost)
			      ;; equal cost => compare fanouts
			      (if (= tbr_fanout min-fanout)
				  ;; equal fanout => compare binding coverage
				  (< coverage min-coverage)
				(< tbr_fanout min-fanout))
			    (< tbr_cost min-cost))))
			(setq min-cost tbr_cost)
			(setq min-fanout tbr_fanout)
			(setq min-coverage coverage)
                        (setq best-bpat tbr_bpat)
			(setq best-impl tbr_impl))))))))
      (cons best-impl best-bpat)))))

(defun covers-dyn (fno fbpat abpat)
  "Check if binding pattern FBPAT covers actual binding pattern ABPAT.
   If dynamic result type specified for FNO 
   then ABPAT is truccated to same length as FBAT"
  (if (function-resulttypesfn fno)
      (covers fbpat (firstn (length fbpat) abpat))
    (covers fbpat abpat)))

(defun get-pred-cost-fo (pred bpat)
  "Estimate the cost to execute foreign predicate call pred with
   binding pattern bpat."
  (let ((pcost (getdeclaredcosts pred bpat)))
    (if (eq pcost 'default)
	(list (localcost pred bpat) (fanout pred bpat))
      pcost)))

(defun cost-rank (pred bnd)
  "Compute cost rank according to formula on pp 15 in lith-ida-r-92-24."
  
  (let* ((orp (orp (car pred)))
         (pc (compute-exec-cost-pred pred bnd))
	 (lc (first pc))
	 (fo (second pc))
	 (pr (third pc))
	 rank)
    (and fo lc
	 (setq rank
	       (/ (+ -1.0 fo) (max 0.0001 lc))))
    (and rank (printopt "Pred:" "~PP" pred (if orp " Bound:" " Bpat: ") 
			(if orp  bnd
                          (listbpat (argsbpat (cdr pred) bnd)))
			" Fanout: " fo " Cost: " lc 
			" Rank: " rank t))
    (cons pr rank)))

(defun simple-pred-cost-bnd (pred bnd)
  "Compute cost and fanout of simple predicate PRED,
   given list of bound variables BND "
  (if (orp (car pred)) 
      (append (compute-exec-cost-pred pred bnd) (list pred))
    (catch-exec-error
     (cond
      ;; DTR cost
      ((or (and (call-p pred)
		(dtr? (caddr pred)))
	   (dtr? (car pred)))
       (let ((bpat (bindadornpat pred  bnd))) 
	 (dtr-simple-pred-cost pred bpat)))
      (t 
       (let* ((bpat (bindadornpat pred bnd))
	      (cpred (getcalledpred pred))
	      (pcost (getdeclaredcosts cpred bpat))
	      fo lc)
	 (cond ((eq pcost 'default)
		(let ((sp (bestmodefunction cpred bpat)))
		  (cond ((oid-p (car sp)) ; precompiled TBR subplan
			 (exec-cost-of-fn (car sp)))
			((and (transientp (car cpred))
                              (not;; Not transiend foreign function 
			       (foreign-predicatep (car cpred))))
			 ;; invoked subplan
			 (exec-cost-of-fn (car cpred)))
			((setq fo (fanout cpred bpat))
			 (list (localcost cpred bpat) fo 
			       (predify-tbr pred))))))
	       ((setq fo (second pcost))
		(list (first pcost) fo (predify-tbr pred)))
	       (t nil)))))
     ;; costhint = NIL => illegal binding pattern
     nil)))

(defun get-best-rank (preds bnd)
  "Get pair of i) the TBR translated predicate in PREDS with lowest rank
   and ii) the remaining predicates in PREDS, given variables bound in BND"
  (let* (minRank 
	 minRankPred
         (pl preds)
	 temp
         )
    (while pl
      (setq temp (rewrite-preds (car pl) (remove (car pl) preds) bnd)) 
      (cond ((null temp);; rewrite failed => try next
             (pop pl))
            ((rewrite-translated temp);; Rule generated TBR => rank it
	     (let* ((pred_rankP (cost-rank (rewrite-translated temp) bnd))
		    (pred  (car pred_rankP))
		    (rankP (cdr pred_rankP)))
	       (cond ((and rankP 
			   (or (null minRank) (< rankP minRank)))
		      (setq minRank rankP)
		      (setq minRankPred temp)
		      )))
             (pop pl))
            (t;; Rewrote to other predicate(s) => replace predicate list
             (printopt "Rewrote " 
                       "~PP" pl "to" 
                       "~PP" (rewrite-rest temp) t)
             (setq pl (rewrite-rest temp));; reset pl
             (setq preds pl);; reset preds to rewritten predicates
             )))
    minRankPred))

(defun rewrite-preds (this rest bnd)
  "TBR rewriter"
  (cond ((atom this) nil);; TRUE, NIL, FALSE
        ((orp (car this))
         (rewrite-or this rest bnd))
	((symbolp (car this)) nil);; AND, CALL, constant
	(t (let((rw (make-rewrite :this (copy-predicate this)
				  :rest (copy-predicate rest)
				  :bnd  (pred_binds this bnd)
				  :bpat (bindadornpat this bnd)))
		rwfns match punt)
	     (cond ((setq rwfns (get-rewriters (car this)
					       (rewrite-bpat rw)))
		    (or
		     (dolist (rwfn rwfns)
		       (setq match (funcall rwfn rw))
		       (selectq match
				(substitute 
				 (setq punt t));; Rule not applied => 
				;; check next rule
				(nil nil);; failure=> check next rule
				(success (return rw));; rule applied
					;=> don't check 
				;; more rules
				(error
				 "Illegal result from function rewriter" 
				 match)))
		     (cond (punt;; Some rule punted => substitute
			    (setf (rewrite-translated rw)
				  (substbindadorned (rewrite-this rw) 
						    (rewrite-bpat rw))) 
			    rw)
			   (t nil))));; Not rule applied or punted => failure
		   ((moderesolvable this (rewrite-bpat rw));; (FNO A1 ...)
		    (setf (rewrite-translated rw)
			  (substbindadorned this (rewrite-bpat rw)))
		    rw)
		   (t nil))))))

(defun rewrite-or (this rest bnd)
  "TBR rewriting of OR"
  (let ((rw (make-rewrite :this this
                          :rest (copy-predicate rest)
			  :bnd (binds-variables this bnd)))
        (*catch-exec-error* t)
        plan)
    (cond ((catch 'catch-exec-error 
	     (setq plan (optimize-disjunction (cdr this) bnd)))
	   (setf (rewrite-translated rw) plan)
	   rw)
          (t nil))))

(defun andpredcost (l bnd)
  "Estimate the cost and fanout to evaluate a conjunction L with 
   variables BND bound"
  (catch 'andpredcost
    (let ((sum 0)(mult 1) cst)
      (while (not (null l))
        (setq cst (compute-exec-cost-pred (car l) bnd))
	(let ((lc (first cst))(fo (second cst)))
	  (if (null fo)(throw 'andpredcost nil))
	  (setq sum (+ (* lc mult) sum))
	  (setq mult (* fo mult))
	  (setq bnd (binds-variables (car l) bnd))
	  (setq l (cdr l))))
      (list sum mult))))

(defun orpredcost (l bnd)
  "Estimate the cost and fanout to evaluate a conjunction L with
   variables BND bound"
  ;; The costs and fanouts of a disjunction is the sum of the 
  ;; the costs and fanouts of its elements
  (catch 'orpredcost 
    (let ((cost 0)(fanout 0)) 
      (dolist (pred l)    
	(let* ((lcst (compute-exec-cost-pred pred bnd)))
	  (cond (lcst (setq cost (+ (first lcst) cost))
		      (setq fanout (+ (second lcst) fanout)))
		(t (throw 'orpredcost nil)))))
      (list cost fanout))))

(defun fanout (pred bpat)
  "compute default fanout for predicate pred with binding pattern bpat"
  (cond
   ((not (relationp (car pred)))
    (fanout-foreign pred bpat))
   (t (fanout-relation pred 
		       (relation-indexes (car pred)nil)
		       bpat))))

(defun fanout-foreign (pred bpat)
  "compute default fanout for foreign function"
  (cond 
   ((null (moderesolvable pred bpat));; not executable here
    nil)
   ((every (f/l(x)(eq x '-)) bpat);; predicate
    _default-selectivity_)
   ((aggregatefunctionp (car pred)) 
    (if (has-bagged-result (car pred)) _default-combiner-fanout_
      _default-aggregate-fanout_))
   ((has-bagged-result (car pred)) _default-bagres-fanout_)
   (t _default-foreign-fanout_)))

(defun index-fanout (indx rcard)
  "Compute fanout in index give size RCARD of table"
  (let (cnt)
    (cond ((index-unique indx) _default-key-fanout_)
	  ((= 0 (setq cnt (index-cardinality indx)))
	   ;; unpopulated database
	   _default-index-fanout_)
	  (t (/ (float rcard) cnt)))))

(defun getcolindex (pos r)
  "Get the index of position pos of stored relation r if any"
  (dolist (index r) (if (eq pos (index-pos index)) (return index))))

(defun foreign-name (fno)
  "The name to use when looking up a foreign implementation."
  (or (getobject fno 'foreignimpl) (oid-name fno)))

(defun predify-simple (pred)
  "Make a TR predicate out of a TBR operator"
  (cond ((call-p pred) (list* (third pred)(cdddr pred)))
        (t pred)))

(defun getcalledpred (pred)
  "translate (call xxx f x y ...) into (f x y ...)"
  (selectq (car pred) 
	   (call
            (let ((fno (getfunctionnamed (third pred))))
              (if (eq fno _invoke-plan_) (cdddr pred)
		(cons fno (cdddr pred)))))
	   pred))

(defun getdeclaredcosts (pred bpat)
  "Get costs declared by cost hint function for pred, 
   given binding pattern."
  (let ((fno (car pred))
        costs)
    (cond
     ((symbolp fno) 'default)
     ((null (setq costs (getcosthint fno bpat)))
      ;; No cost hint function for bpat
      'default)
     ((oid-p costs)
      ;; cost hint function found
      (getfunction-firsttuple costs 
			      (list fno 
				    (apply 'vector bpat)
				    (apply 'vector (cdr pred)))
			      ))
     (t;; cost hint was constant list: [fanout,cost]
      costs))))

(defun indexed (pred bpat)
  "Is predicate indexed for given binding pattern?"
  (if (relationp (car pred))
      (let ((i -1)
	    (r (relation-indexes (car pred) nil))
	    index)
	(dolist (bp bpat)
	  (setq i (1+ i))
	  (case bp
	    (- (if (setq index (getcolindex i r))
		   (return index))))))))

(defun localcost (pred bpat)
  "Compute local cost to execute predicate, given binding pattern."
  (let (index)
    (cond 
     ((relationp (car pred))
      ;; stored table
      (cond 
       ((setq index (indexed pred bpat))
	(* 2 (index-fanout index (relation-cardinality (car pred)))))
       (t (* 2 (relation-cardinality (car pred))))))
     ((aggregatefunctionp (car pred)) 
      (if (has-bagged-result (car pred)) _default-combiner-cost_ 
	_default-aggregate-cost_))
     ((has-bagged-result (car pred)) _default-bagres-cost_)
     (t _default-foreign-cost_))))

(defun moderesolvable (pred bpat) 
  "Is predicate car(pred) implemented for bpat 
   and the argument list cdr(pred)?"
  (let ((fno (car pred)))
    (if (foreign-predicatep fno)
	(if (dtr? fno)
	    t
	  (isome (getobject fno 'bindings)
		 (f/l (tbr) (and (neq (tbr-cost tbr) 'fail)
                                 (covers-dyn fno (tbr-bpat tbr) bpat)))))
      t)))

(defun psort (l bnd)
  "Optimize AND predicate using strategy of 'nested loop'"
  (cond ((atom l) l)
        ((and (osql-constantp (car l))(null (cdr l))) l)
        (t (selectq  *optmethod*  
		     (exhaustive (dynprogsort l bnd _DYNPROG_MAX_TIME_))
		     (randomopt  (random-opt l bnd))
		     (prog2 (printopt ">>>>>>>>>>>>>>>>>>>>>>>>>>" t
				      "TR predicate to Ranksort into TBR:"
				      "~PP" (andify l)
				      "Bound variables: " bnd t "----" t)
			 (ranksort l bnd)
		       (printopt "<<<<<<<<<<<<<<<<<<<<<<<<<<" t))))))

(defun ranksort (l bnd)
  "Greedy cost based optimization of conjunction L with variables BND bound"
  (let (temp minRankPred respart)
    (while (not (atom l))
      (setq temp (get-best-rank l bnd));; predicated rewriting done here
      (cond 
       (temp
	(setq minRankPred (rewrite-translated temp))
	(printopt "Chosen: " 
		  minRankPred t "----" t);; *Jorn*
	(setq l (rewrite-rest temp));; *Jorn*
	(setq bnd (rewrite-bnd temp))
	(setq respart (cons minRankPred respart)))
       ((and (cdr l) (every (f/l (x) (and (listp x) (eq (car x) 'or))) 
			    l))
	(setq l
	      (list (cons 'OR
			  (mapcar (f/l (orBranch) 
				       (if (eq (car orBranch) 'AND)
					   (append orBranch (cdr l))
					 (cons 'AND (cons orBranch (cdr l)))))
				  (cdr (car l)))))))
       (t 
	(non-exec-error (andify l) bnd)
	(return nil))))
    (cond
     ((null l) (nreverse respart))
     (t (nreverse (cons l respart))))))

(defun foreign-predicatep (x)
  "If X the OID of a foreign predicate?"
  (if (oid-p x)
      (getobject x 'foreignimpl)))

(defun substbindadorned (pred bpat)
  "Substitute primitive TR predicate with corresponding TBR"
  (cond ((has-duplicate-param pred)
         (add-duplicate-param-test pred bpat))
        (t (substbindadorned0 pred bpat))))

(defun has-duplicate-param (pred)
  "Is some parameter of pred used twice?"
  (isome (cdr pred)(f/l (v tail)(memq v (cdr tail)))))

(defun add-duplicate-param-test (pred bpat)
  "Add equalities of unbound duplicate argument variables"
  (let ((p (append pred nil)) alias)
    (do ((pv (cdr p) (cdr pv))
	 (bp bpat (cdr bp)))
	((null pv) 
         (cond (alias 
		(andify 
		 (cons (substbindadorned0 p bpat)
		       (mapcar 
			(f/l (a)
			     (substbindadorned0 (list _=_ (car a)(cdr a))
						'(- -)))
			alias))))
               (t (substbindadorned0 pred bpat))))
      (cond ((and (eq (car bp) '+)
		  (osql-variablep (car pv))
		  (memq (car pv)(cdr pv)))
	     (let ((v (dt_genvar (arg-type (car pv)))))
	       (push (cons (car pv) v) alias)
               (rplaca pv v)))))))

(defun substbindadorned0 (pred bpat)
  "In case pred is a call to a foreign predicate, substitute pred
   for a call to the cheapest TBR resolvent."
  (cond ((foreign-predicatep (car pred))
	 (let ((rfn (bestmodefunction pred bpat)) sb)
	   (cond ((null rfn)
		  (amos-error 
		   "Unable to execute foreign function" pred))
                 ((oid-p (car rfn))	; substitute TBR subplan
                  (pre-optimized-plan 
		   (car rfn) 
		   (nconc (bound-vars (cdr rfn) (cdr pred))
			  (unbound-vars (cdr rfn) (cdr pred)))))
		 (t (let ((foreign-implementation 
			   (or (getprop (car rfn) 'extpred) ; FF in C
			       (car rfn))))	; FF in Lisp
                       (or foreign-implementation
                           (error "No foreign implementation" rfn))
		      `(call , foreign-implementation
			       ,  (car pred)
			       ,@ (cdr pred)))))))
	(t pred)))


(defun pre-optimized-plan (rfn vars)
  "Get pre-optimized plan for RFN applied on VARS"
  (let ((sb (getselectbody rfn)))
    (cond ((substitutable-plan? sb);; Substitute simple plan 
	   (let* ((op (selectbody-optpred sb))
		  (params (selectbody-argresl sb))
		  (ptypes (append (selectbody-argt sb)(selectbody-rest sb)))
		  (freevt (mapcan (f/l (v tp)(if (in v op)(list (cons v tp))))
				  (selectbody-locals sb)
				  (selectbody-loct sb))))
	     ;; substitute subplan plan
	     (subst-predicate 
	      op
	      (pair (append params (mapcar (function car) freevt)) 
		    (append (mapcar (f/l (v tp)
					 (if (eq v '*)(dt_genvar tp) 
					   v))
				    vars ptypes)
			    (mapcar (f/l (p)(dt_genvar (cdr p))) 
				    freevt))))))
	  (t;; call complex plan 
	   (list* 'call 'invoke-plan _invoke-plan_ rfn 
		  (getarity rfn)
		  vars)))))

(defun substitutable-plan? (sb)
   "Is the optimized plan of SB simple enough to be substituted?"
   (< (pred-size (selectbody-optpred sb)) *max-substitutable-size*))

(defun fanout-relation (pred r bpat)
  "Compute default fanout for relation R called by
   predicate function PRED with binding pattern BPAT"
  (let (index 
        (i -1)
        (rcard (relation-cardinality (car pred)))
        (fo 1))
    (dolist (bp bpat)
      (setq i (1+ i))
      (cond 
       ((not (eq bp '-))nil)
       ((setq index (getcolindex i r));; Index position
	(setq fo (* fo (/ (float (index-fanout index rcard))
			  rcard))))
       (t (setq fo (* fo 
		      (estimate-pos-selectivity (car r) i 
						_max-sampled-tuples_))))))
    (fudge-key-fanout (* fo rcard))))

(defun fudge-key-fanout (x)
  "To avoid making fanout = 1.0"
  (cond ((< x _default-key-fanout_) x)
        ((> x 1.0) x)
        (t _default-key-fanout_)))

(defun estimate-pos-selectivity (index pos stopafter)
  "Estimate the selectivity of the attribute at postion POS of a collection
   by scanning max STOPAFTER tuples in INDEX"
  (let ((cnt 0))
    (clrhash _selectivity-hashtable_)
    (catch 'index-selectivity
      (mapindex 
       index '* 
       (f/l (x)
	    (1++ cnt)
	    (if (>= cnt stopafter)(throw 'index-selectivity) 
	      (setf (gethash (aref x pos) _selectivity-hashtable_) 1)))))
    (if (= (hash-table-count _selectivity-hashtable_) 0)  
	_default-selectivity_;;we have only found nil in the relation
      (/ 1.0 (hash-table-count _selectivity-hashtable_)))))

(defun unnest_list (l &optional exclude_or)
  "Given unnests (flattens) a list."
  (if (eq l exclude_or)
      nil
    (let ((res nil))
      (dolist (elem l)
	(setq res
	      (if (listp elem)
		  (nconc (unnest_list elem exclude_or) res)
		(cons elem res))))
      res)))

(defun variable-is-bound (var bnd)
  "Is variable VAR bound, given list of bound variables BND?"
  (or (osql-constantp var)
      (and (neq var '*)(memq var bnd))))

(defun get-foreign-lispfn (fno &optional noerror)
  "Get first foreign Lisp function called in FNO"
  (let* ((r (getuniqueresolvent fno))
	 (sb (and r (getselectbody r)))
	 (def (and sb (selectbody-optpred sb))))
    (or (dolist (p (argsof 'and def))
	  (if (and (call-p p)
		   (function-definedp (cadr p)))
	      (return (cadr p))))
	(if noerror nil 
	  (amos-error "No foreign Lisp function found in " fno)))))

(defun externalize-pred (p &optional short)
  "Translate predicate before printing by PC"
  (cond ((expression-p p)
	 (list 'expression 
	       :filter (externalize-pred (andify (expression-filter p)) short)
               :source (expression-source p)
	       :finalizer (expression-finalizer p)))
	((atom p) p)
	((call-p p) p)
	(t (cons(externalize(car p) short)
		(mapcar(f/l (p) (externalize-pred p short))
		       (cdr p)))))) 

(defun pc-head (name argl resl)
  "Head of function printed by PC"
  (cons name(nconc(mapcar(f/l (x)(pack x '-))argl)
		  (mapcar(f/l (x)(pack x '+))resl))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TBR optimization utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun predify-tbr (tbr)
  "Translate an (ordered) TBR plan into an (ordered) TR expression"
 (map-over-pred tbr (function predify-simple) (function id)))

(defun continue-optimize (fno)
  "Continue to optimize TBR of FNO with current optimization method"
  (let ((sb (getselectbody fno)))
    (setf (selectbody-coercedpred sb)(predify-tbr (selectbody-optpred sb)))
    (setf (selectbody-optpred sb) 
	  (decompose-pred (selectbody-coercedpred sb) sb))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TBR rewrite utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _compare-inverses_ 
  '((< . >=)(<= . >)(> . <=)(>= . <)) "Inverses of comparison operators")
(defglobal _compare-ends_ '((< <=)(> >=)) "Strict vs non-strict comparisons")

(defun rewrite-assert (pred rw)
  "Assert new fact among remaining predicates in TBR rewriter"
  (setf (rewrite-rest rw)
	(append (rewrite-rest rw) (list pred))))

(defun rewrite-assertl (predl rw)
  "Assert conjuction of predicates PREDL in TBR rewriter"
  (setf (rewrite-rest rw)
	(append (rewrite-rest rw) predl)))

(defun rewrite-retract (pred rw)
  "Retract fact from remaining predicates in TBR rewriter"
  (setf (rewrite-rest rw) 
	(remove pred (rewrite-rest rw))))

(defun compare-inverse (p)
  "Compute comparison inverse of predicate P. Inverse of > is <= etc"
  (let* ((gp (generic-function-of p))
         (at (get-resolvent-argtypes p))
         (inv (cdr (assq (oid-name gp) _compare-inverses_))))
    (resolvename inv at)))

(defun strict-comparison (p)
  "Is P a strict comparison predicate?"
  (assq (generic-function-of p) _compare-ends_))

(defun vector-pred-arg (var rw)
  "Make a vector argument in TBR call"
  (cond ((null var) (vector));; nil => empty vector
	((kwoted var) (vector var));; Constant vector
	(t (let ((nv (genvar)));; Add temporary variable referencing vector
	     (rewrite-assert (list '_vector-constructor_ nv var) rw)
	     nv))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Obsolete code for backward compatability:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun old-decompose-pred (pred sb)
  "OBSOLETE cost-based optimization of PRED with selectbody SB"
  (let ((*bindings* (selectbody-bindings sb)))
    (cond ((atom pred) pred)
	  (t (andify (list (apply_to_pred pred sb 
					  (function sortandpred))))))))

(defun sortandpred0 (remaining sb)
  "OSOLETE left for backward compatablity of SQISLE"
  (cond 
   ((atom remaining) remaining)
   (t
	   ;;; Changed by Martin Hansson. used to be
	   ;;; (psort remaining (selectbody-argl sb)))))
    (psort (purge remaining sb)
	   (selectbody-argl sb)))))

(defun sortandpred (andargs sb)
  "OBSOLETE entry function to cost based optimzation"
  (let (res)
    (cond ((not *runtime-executability-check*)
	   (sortandpred0 andargs sb))
	  ((null (setq res (catch-exec-error 
			    (sortandpred0 andargs sb)))) ;failed
	   (list (list 'call 'print-amos-error _print-amos-error_ 
                       "Function not executable"
		       (car *current-compile-fn*))))
          (t res))))

(defun apply_to_pred (l sb func) 
  "OBOLETE: Applies function to the predicate used to apply first the 
   calculus optimization and then apply the cost based opt."
  (cond 
   ((atom l) l)
   ((and (listp l) (eq (car l) 'or)) 
    (orify (mapcar (f/l (x)
			(apply_to_pred x sb func))
                   (cdr l))))
   ((and (listp l) (eq (car l) 'and))	; optimize conjunction
    (let ((l1 (mapcar (f/l (pr) 
			   (if (and (listp pr)
				    (or (eq (car pr) 'and) 
					(eq (car pr) 'or)))
			       (apply_to_pred pr sb func)
			     pr))
		      (cdr l))))
      (funify 'and (apply func (list l1 sb)))))
   ;; simple predidate treated as degenerate conjunction.
   (t (funify 'and (apply func (list  (list l) sb))))))
