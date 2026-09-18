;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: cost_model.populated.lsp,v $
;;; $Revision: 1.27 $ $Date: 2012/05/21 20:29:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Cost model for ALEH. It works only if data are populated.
;;;  Optimizer produces good plans for executing all 
;;; cut queries together independently on provided order.
;;;  The execution time is still litle worse than manually provided best order.
;;;              
;;; ===========================================================================
;;; $Log: cost_model.populated.lsp,v $
;;; Revision 1.27  2012/05/21 20:29:30  torer
;;; Updated cost model
;;;
;;; Revision 1.26  2008/12/25 19:35:12  torer
;;; (setq *old-decompose* t) since ALEH depends on old code that cannot handle non-DNF predicates
;;;
;;; Revision 1.25  2008/11/18 21:02:40  torer
;;; OSQL-SUBTYPEP -> BAG-TYPE?
;;;
;;; Revision 1.24  2008/03/25 14:33:22  ruslan
;;; help functions. counting number of events used in collecting card. statistics.
;;;
;;; Revision 1.23  2008/03/19 13:18:03  ruslan
;;; cost models
;;;
;;; Revision 1.22  2008/03/14 13:56:55  ruslan
;;; cost for operators is 1 by default
;;;
;;; Revision 1.21  2008/03/10 15:59:00  ruslan
;;; type containers defined. this removes some type check, but not all of them, while they still can be removed somehow. missing cost models
;;;
;;; Revision 1.20  2008/02/16 10:52:38  ruslan
;;; bug with cost model is fixed that cost model for operators used only in streamed version is defined only for them
;;;
;;; Revision 1.19  2008/02/13 14:23:27  ruslan
;;; cost models for somec, notanyc, and minagg4 were missing.
;;;
;;; Revision 1.18  2007/12/12 08:58:14  ruslan
;;; cost model for aggregates is revisited. cases, when partial information for cost model is only known, are updated.
;;;
;;; Revision 1.17  2007/12/08 10:37:25  ruslan
;;; case of no bound bag generated included
;;;
;;; Revision 1.16  2007/11/23 11:08:08  ruslan
;;; bug in cost model of minagg2 is fixedcost_model.populated.lsp
;;;
;;; Revision 1.15  2007/11/11 09:48:53  ruslan
;;; correct types for aggregates
;;;
;;; Revision 1.14  2007/10/19 07:33:39  ruslan
;;; correct cost model for minagg2
;;;
;;; Revision 1.13  2007/09/14 07:57:13  ruslan
;;; minor change, which does not affect anything now
;;;
;;; Revision 1.12  2007/09/11 08:09:32  ruslan
;;; use variables for defining lower and upper values for selectivity
;;;
;;; Revision 1.11  2007/07/27 07:23:22  ruslan
;;; more consistent cost model for aggregates. and count eqaulity is with factor 1/10 (magic number) instead of 1/3
;;;
;;; Revision 1.10  2007/06/19 07:31:12  ruslan
;;; typo bug is fixed
;;;
;;; Revision 1.9  2007/06/18 13:08:46  ruslan
;;; new cost models are in comments
;;;
;;; Revision 1.8  2007/06/18 09:55:21  ruslan
;;; some comments are added
;;;
;;; Revision 1.7  2007/06/18 09:47:19  ruslan
;;; cost model for atleast and countbb takes in account cases when n is not positive
;;;
;;; Revision 1.6  2006/08/29 14:09:31  ruslan
;;; small bug fixed in calculating cost for countbb and atleas. clearing the formulas without changing result
;;;
;;; Revision 1.5  2006/08/29 13:23:42  ruslan
;;; new cost model for aggregates. previous version contains old cost model where execution time was 1.8 seconds
;;;
;;; Revision 1.4  2006/08/28 07:58:35  ruslan
;;; fixing static cost model for aggregates. changes are minor and don't affect execution time
;;;
;;; Revision 1.3  2006/06/08 07:25:14  ruslan
;;; cost model patch corresponds update made in original
;;;
;;; Revision 1.2  2006/04/28 12:13:38  ruslan
;;; a bug is fixed. the bug was in part of the code which never was called
;;;
;;; Revision 1.1  2006/04/28 10:07:50  ruslan
;;; cost model for cuts is added. it is applicable only when database is populated
;;;
;;; ===========================================================================

(setq *old-decompose* t)

(defglobal _in_ (getfunctionnamed  'in))
(defglobal _default-in-fanout_ 10.0)
(defglobal _default-count-fanout_ 0.3)
(defglobal _default-some-fanout_ 0.5)
(defglobal _default-iteration-cost_ 1.0)
(defglobal _default-foreign-fanout_ 1.0)
(defglobal _default-foreign-cost_ 1.0)
(setq _default-selectivity_ 0.4)
(defglobal _default-sq-iteration-cost_ 
  (+ _default-iteration-cost_ _default-foreign-cost_))
(defglobal _minimal-sq-cost_ (* _default-foreign-cost_ _default-in-fanout_))
(defglobal _minimal-aggregation-cost_  ; cost of execution subquery
  (* _default-sq-iteration-cost_ _default-in-fanout_))
(defglobal _default-aggregate-fanout_ 1.0)
(defglobal _default-key-fanout_ 1.0)
;(defglobal _lowest-priority_ '(0 1.0)) ; Cost to push predicate early
(defglobal _default-constructor-fanout_ 1.0)
(defglobal _lowest-fanout_ 0.001)
(defglobal _lowest-cost_ 0.0001)
(defglobal _fanout-equal-one_ 0.99)
(defglobal _default-makebag-cost_ 1.0)

(foreign-lispfn get_default_in_fanout ()((real in_fanout))
		 (foreign-result _default-in-fanout_))

;; Localcost treats aggregates differently then foreign functions
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
     ((aggregatefunctionp (car pred)) (aggregate-localcost pred))
     (t _default-foreign-cost_))))

;; calculating of fanout of aggregates is special case of foreigns fanout
(defun fanout-foreign (pred bpat)
  "compute default fanout for foreign function"
  (cond 
   ((null (moderesolvable pred bpat));; not executable here
    nil)
   ((every (f/l(x)(eq x '-)) bpat);; predicate
    _default-selectivity_)
   ((equal (generic-function-of (car pred)) _in_) _default-in-fanout_)
   ((aggregatefunctionp (car pred)) _default-aggregate-fanout_)
   (t _default-foreign-fanout_)))

(defun aggregate-localcost (pred)
  "compute default cost for aggregate functions, which is cost of transient
function that generates input bag"
  (let* ((argtypes (get-resolvent-argtypes (car pred)))
         (bagpos (length (ldiff argtypes ; position of bag argument 
				(isome argtypes (function bag-type?)))))
         (fno (binding-context (getbinding (nth bagpos (cdr pred)))))
	 (cst (if fno (exec-cost-of-fn fno)
					; context of bag not known:
		(list _minimal-sq-cost_ _default-in-fanout_))))
    (+ (first cst)(* (second cst) _default-iteration-cost_))))

;; rank sort change fanout 1.0 by 0.99 to provide ability to compare functions
;; that have fanout <= 1.0 between each other. It is necessary since fanout
;; of many functions that are not generators or filters is equal to 1.
(defun cost-rank (pred bnd)
  "Compute cost rank according to formula on pp 15 in lith-ida-r-92-24."
  (let* ((pc (compute-exec-cost-pred pred bnd))
	 (lc (first pc))
	 (fo (second pc))
	 (pr (third pc))
	 rank)
    (and fo lc
	 (setq rank
	       (/ (+ -1.0 (if (= fo 1.0) _fanout-equal-one_ fo)) 
		  (max _lowest-cost_ lc))))
    (and rank (printopt "Pred:" pred " Bpat: " 
			(listbpat(argsbpat(cdr pred) bnd))
			" Fanout: " fo " Cost: " lc 
			" Rank: " rank t))
    (cons pr rank)))

;; equality is doing assigning and thus it bounds variables and should
;; be done earlier. it usualy has fanout 1.
(declarecosts _=_ '(- +) 
	      (list _default-foreign-cost_ _default-foreign-fanout_))
(declarecosts _=_ '(+ -) 
	      (list _default-foreign-cost_ _default-foreign-fanout_))

;; makebag save context of a bag. the context is transient function associated
;; with bound variable. it is necessary for calculating costs of aggrefates.
(setq *costfn* 
      (foreign-lispfn makebag_costs ((function f)(vector bpat)(vector argl)) 
		      ((number cost)(number fanout))
		      (let* ((bvar (aref argl (1- (length argl))))
			     (bnd (getbinding bvar t)))
			(cond ((null bnd) 
			       (addbinding bvar nil _bag_)
                               (setq bnd (getbinding bvar))))
			(setf (binding-context bnd) (aref argl 0))
                        (osql-result f bpat argl _default-makebag-cost_ 
				     _default-foreign-fanout_))))


(declarecosts 'FUNCTION.MAKEBAG->BAG '(- +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - - - +) *costfn*)

;; cost of some is different from default cost of aggregates since it
;; stops when first element of a bag is received
(setq *costfn*
      (foreign-lispfn 
       some_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ;; Bag generator is not bound
	  ((null fno)
	   (osql-result f bpat argl _default-sq-iteration-cost_	
			_default-some-fanout_))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (osql-result f bpat argl 
			  (if (< (second cst) 1.0)
;					 (first cst)
					; the commented model below does 
					; not make much difference
			      (+ (first cst) 
				 (* (second cst) 
				    _default-iteration-cost_))
			    (+ (/ (first cst) (second cst))
			       _default-iteration-cost_))
			  (if (< (second cst) 1.0)
			      (/ (second cst) 2)
			    (- 1 (/ 1 (* 2 (second cst))))))))))))

(declarecosts 'BAG.SOME->BOOLEAN '(-) *costfn*)

;; cost of notany is different from default cost of aggregates since it
;; stops when first element of a bag is received
(setq *costfn*
      (foreign-lispfn 
       notany_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ;; Bag generator is not bound
	  ((null fno)
	   (osql-result f bpat argl _default-sq-iteration-cost_
			_default-some-fanout_))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (osql-result f bpat argl 
			  (if (< (second cst) 1.0)
;					 (first cst)
					; the commented model below does 
					; not make much difference
			      (+ (first cst)
				 (* (second cst)
				    _default-iteration-cost_))
			    (+ (/ (first cst) (second cst))
			       _default-iteration-cost_))
			  (if (< (second cst) 1.0)
			      (- 1 (/ (second cst) 2))
			    (/ 1 (* 2 (second cst)))))))))))

(declarecosts 'BAG.NOTANY->BOOLEAN '(-) *costfn*)

;; cost of count_bb is different from default cost since it stops when
;; number of received elements of a bag is equal to second argument
(setq *costfn*
      (foreign-lispfn 
       countbb_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ;; Bag generator is not bound
	  ((null fno)
	   (osql-result f bpat argl 
			(/ _minimal-aggregation-cost_ 2.0)
			_default-count-fanout_))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (cond
					; If N is negative
	      ((and (integerp (aref argl 1)) (< (aref argl 1) 0))
	       (osql-result f bpat argl _default-foreign_cost_ 0.0))
					; If N is equal to zero
	      ((and (integerp (aref argl 1)) (= (aref argl 1) 0))
	       (osql-result f bpat argl 
			    (+ (* (first cst)
				  (min 1.0 
				       (/ (1+ (aref argl 1)) (second cst))))
			       (* _default-iteration-cost_
				  (min (second cst)(1+ (aref argl 1)))))
			    (if (< (second cst) 1.0)
				(- 1 (/ (second cst) 2))
			      (/ 1 (* 2 (second cst))))))
					; If N is positive
	      ((integerp (aref argl 1))
	       (osql-result f bpat argl 
			    (+ (* (first cst)
				  (min 1.0 
				       (/ (1+ (aref argl 1)) (second cst))))
			       (* _default-iteration-cost_
				  (min (second cst)(1+ (aref argl 1)))))
			    (/ (min (/ (aref argl 1) (second cst)) 
				    ;; / by 10 can be used. almost no difference
					; / by 3 is published in the load paper
				    (/ (second cst) (aref argl 1))) 10)))
	      ;; If N is not known to be an integer values
	      (t 
;	   (print "count_BB: the number is unknown")
	       (osql-result f bpat argl 
			    (* (first cst) 0.5)
			    _default-count-fanout_)))))))))

(declarecosts 'BAG.COUNT->INTEGER '(- -) *costfn*)

;; cost of count_bb is different from default cost since it stops when
;; number of received elements of a bag is bigger then first argument
(setq *costfn*
      (foreign-lispfn 
       atleast_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (binding-context (getbinding (aref argl 1)))))
	 (cond
	  ;; Bag generator is not bound
	  ((null fno)
	   (osql-result f bpat argl 
			(/ _minimal-aggregation-cost_ 2.0)
			_default-some-fanout_))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (cond
					; If N is not positive
	      ((and (integerp (aref argl 0)) (<= (aref argl 0) 0))
	       (osql-result f bpat argl 1.0 1.0))
					; If N is positive
	      ((integerp (aref argl 0))
	       (osql-result f bpat argl 
			    (+ (* (first cst)
				  (min 1.0 
				       (/ (aref argl 0) (second cst))))
			       (* _default-iteration-cost_
				  (min (second cst)(aref argl 0))))
			    (if (< (second cst) (aref argl 0))
				(/ (second cst) ( * (aref argl 0) 2.0))
			      (- 1.0 (/ (aref argl 0) (* (second cst) 2.0))))))
	      ;; If N is not known to be an integer value
	      (t 
;	   (print "atleast: the number is not integer")
	       (osql-result f bpat argl 
			    (* (first cst) 0.5)
			    _default-some-fanout_)))))))))

(declarecosts 'INTEGER.BAG.ATLEAST->BOOLEAN '(- -) *costfn*)

(commit)
