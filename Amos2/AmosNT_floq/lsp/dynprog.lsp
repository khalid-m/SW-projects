;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Tore Risch, EDSLAB
;;; $RCSfile: dynprog.lsp,v $
;;; $Revision: 1.26 $ $Date: 2012/04/24 14:59:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:
;;; Exhaustive dynamic programming algorithm to optimize AND predicates.
;;; C.f. Selinger et al.
;;; Assumes nested-loop method of execution.
;;; =============================================================
;;; $Log: dynprog.lsp,v $
;;; Revision 1.26  2012/04/24 14:59:52  torer
;;; Using COMPOUND-P
;;;
;;; Revision 1.25  2012/04/24 14:07:12  torer
;;; ANDORP -> COMPOUND-P for more generality
;;;
;;; Revision 1.24  2010/05/19 19:57:09  zeitler
;;; reverting to v 1.22
;;;
;;; Revision 1.22  2010/04/19 15:20:56  torer
;;; opttrace(true); prints # of iterations for optmethod("exhaustive");
;;;
;;; Revision 1.21  2009/11/26 21:44:06  torer
;;; Trace message for 2nd phase added
;;;
;;; Revision 1.20  2008/12/27 21:06:02  torer
;;; Non-DNF plans allowed with dynamic programming
;;;
;;; Revision 1.19  2006/05/22 14:24:03  torer
;;; Too few parameters in call to CHOOSE-FALLBACK-PLAN
;;;
;;; Revision 1.18  2006/05/05 13:08:54  ruslan
;;; prunning of equivalent plans during dynamic optmization is rewritten in iterative way
;;;
;;; Revision 1.17  2006/05/04 20:55:57  torer
;;; Pruned symmetric execution plans
;;;
;;; Revision 1.16  2006/05/04 17:30:21  torer
;;; Hook for hierarchical optimization
;;;
;;; Revision 1.15  2006/05/04 16:55:46  torer
;;; Using RANKSORT as fallback strategy when DYNPROG budget consumed
;;;
;;; =============================================================

;;; pcost holds information about each (incomplete) query execution plan
(defstruct pcost
  plan;; The (ev. incomplete) query plan built so far
  bound;; The variables bound in plan so far
  fanout;; The fanout of the last predicate in plan
  rem;; The predicates remaining to be reordered
  )

(defun pcost-stat (pcl)
  "Take a list of 'pcost' structures - 'pcl' and return a list that summarizes
   somehow this list. In this case get the min and max plan lengths."
  (let ((minl _MAXINT_)
	(maxl 0)
	plan-len)
    (dolist (pc pcl)
      (setq plan-len (length (pcost-plan pc)))
      (if (< plan-len minl)
	  (setq minl plan-len))
      (if (> plan-len maxl)
	  (setq maxl plan-len)))
    (list minl maxl)))

(defun dynprog (l bnd &optional stopfn fallbackfn)
  "Optimize list of predicates using dynamic programming and exhaustive search
   'plan-table' is priority queue of execution plans where:
   key = cost, value = list of plans with this cost
    (STOPFN BESTPLANS COST ITERATIONS) 
   should return TRUE if optimizer should give up and run 
    (FALLBACKFN BESTPLANS COST ITERATIONS) instead where
    BESTPLANS is a list of currently best partial plans
    COST is the cost of the BESTPLANS and
    ITERATIONS is the number optimizer iterations so far"
  (if l
      (let ((plan-table (maketbl 'pcost-stat))
	    lowest-cost bestplans newcost res oldrem
	    (iteration 0))
	(printopt t "DP: Predicates to optimize: " t
		  (with-string str (pps l str))
		  "Number of preds: " (length l) t)
	(puttbl plan-table
		0.0
		(make-pcost :bound bnd :fanout 1.0 :rem l))
	(while t
	  (cond ((empty-tbl-p plan-table)
		 (printopt "DP non-executable" t)
		 (non-exec-error (andify l) bnd)))
	  ;;(printopt "DP iter " iteration ": " (tbl-stat plan-table 3) t)
	  ;; lowest cost so far
	  (setq lowest-cost (get-lowest-cost plan-table))
	  ;; corresponding plans
	  (setq bestplans (different-plans (pop-cheapest-plans plan-table)))
	  ;; Check for cost overflow
	  ;; TODO: needs a better way of handling big costs
	  (if (< lowest-cost 0)
	      (amos-error "Cost overflow "
			  lowest-cost
			  " where the first plan is: " t
			  (with-string str
				       (pps (pcost-plan
					     (car bestplans)) str))))
	  ;; Check if there is a complete plan
	  (setq res (isome bestplans
			   (f/l (plan) (null (pcost-rem plan)))))
	  (cond (res;; A complete plan with lowest cost was found
		 (setq res (pcost-plan (car res)))
		 (printopt "DP optimal plan: " t
			   (with-string str (pps res str))
			   "cost: " lowest-cost t)
                 (printopt "Iterations: " iteration t)
		 (printopt "DP stats: " (tbl-stat plan-table 4) t t)
		 (return res))
		((funcall stopfn bestplans lowest-cost iteration)
		 ;; Run ranksort on best incomplete plan
                 (printopt "Resorting to fallback strategy after "
                           iteration " iterations" t)
                 (return (funcall fallbackfn 
				  bestplans lowest-cost iteration))))
	  ;; pc is a partial plan with lowest cost
	  (dolist (pc bestplans)
	    (let ((oldbound  (pcost-bound pc))
		  (oldfanout (pcost-fanout pc))
		  (oldrem    (pcost-rem pc))
		  (oldplan   (pcost-plan pc)))
	      ;; pred bound to each predicate not-yet selected in plan
	      (dolist (pred oldrem)
		(let ((cst (simple-pred-cost-bnd pred oldbound))
		      new-entry new-key)
		  ;;  'cst' = NIL - means illegal binding pattern
		  ;; extend the plan by picking each predicate from oldrem
		  (if cst
		      (let ((bpat (bindadornpat pred oldbound)))
			(setq new-entry
			      (make-pcost 
			       :bound (binds-variables pred oldbound)
			       :fanout (* (second cst) oldfanout)
			       :plan 
			       (append 
				oldplan
				(list (if (compound-p pred)
					  (optimize-compound-predicate 
					   pred oldbound)
					(substbindadorned 
					 pred (bindadornpat pred oldbound)))))
			       :rem (removeeq pred oldrem)))
			;; compute cost of extended plan
			;; cost = prev_cost + fanout * pred_cost
			(setq new-key (+ lowest-cost 
					 (* oldfanout (first cst))))
			;; put extended plan into queue
			(puttbl plan-table new-key new-entry)))))))
	  (1++ iteration)
	  ))))

;(defun different-plans (plans)
;  "Remove equivalent plans where both predicates as bound variables same"
;  (cond ((null plans) nil)
;        ((isome (cdr plans)
;		(f/l (p)(and (equal (pcost-rem p)
;				    (pcost-rem (car plans)))
;			     (equal-set (pcost-bound p)
;					(pcost-bound (car plans))))))
;         (different-plans (cdr plans)))
;        (t (cons (car plans)(different-plans (cdr plans))))))
(defun different-plans (plans)
  "Remove equivalent plans where both predicates as bound variables same"
  (let ((res nil))
    (do ((cur nil)(rest plans))((null rest))
      (setq cur (car rest))
      (setq rest (cdr rest))
      (cond ((isome rest
		    (f/l (p)(and (equal (pcost-rem p)
					(pcost-rem (car plans)))
				 (equal-set (pcost-bound p)
					    (pcost-bound (car plans))))))
	     res)
	    (t (setq res (cons cur res)))))
    (nreverse res)))

(defun equal-set (x y)
  (not (or (isome x (f/l (z)(not (memq z y))))
	   (isome y (f/l (z)(not (memq z x)))))))

(defun dynprogsort (l bnd max-time)
  "The strategy used when optmethod('exhaustive'); specified"
  (let ((start (clock)))
    (dynprog l bnd 
	     (f/l (bestplans cost iterations)
		  (> (- (clock) start) max-time))
	     (function dynprog-fallback-strategy))))

(defun dynprog-fallback-strategy (bestplans cost iterations)
  "Use RANKSORT on remaining plan for best DYNPROG partial plan"
  (printopt "Dynamic programming fallback strategy (ranksort) started after " 
	    iterations " iterations and cost " cost t)
  (let ((plan (choose-fallback-plan bestplans cost)))
    (append (pcost-plan plan)
	    (ranksort (pcost-rem plan)
		      (pcost-bound plan)))))

(defun choose-fallback-plan (bestplans cost)
  "Choose the plan to apply fallback strategy"
  (car bestplans))

(defun removeeq (x l)
  "Return a new list where the first occurence of 'x' in 'l' has been removed."
  (let (res)
   (while (and l (not (eq x (car l))))
     (push (pop l) res))
   (nconc (nreverse res)(cdr l))))
