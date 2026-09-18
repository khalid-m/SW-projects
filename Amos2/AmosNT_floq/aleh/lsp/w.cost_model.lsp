;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: w.cost_model.lsp,v $
;;; $Revision: 1.1 $ $Date: 2006/06/08 07:27:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Cost model for wrapped aggregations, which uses statistics collected
;;; during probing.
;;;              
;;; ===========================================================================
;;; $Log: w.cost_model.lsp,v $
;;; Revision 1.1  2006/06/08 07:27:14  ruslan
;;; Dynamic cost model based on probing for aggregations is added to the repository
;;;
;;; ===========================================================================
(defglobal _in_ (getfunctionnamed  'in))
(defglobal _default-in-fanout_ 10.0)
(defglobal _default-count-fanout_ 0.5)
(defglobal _default-iteration-cost_ 1.0)
(defglobal _minimal-aggregation-cost_ 2.0)
(defglobal _default-foreign-fanout_ 1.0)
(defglobal _default-aggregate-fanout_ 1.0)
(defglobal _default-key-fanout_ 1.0)
(defglobal _lowest-priority_ '(0 1.0)) ; Cost to push predicate early
(defglobal _default-constructor-fanout_ 1.0)

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
				(isome argtypes (function osql-bagtypep)))))
         (fno (binding-context (getbinding (nth bagpos (cdr pred)))))
	 (val)
	 (cst (if fno 
		  (cond
		   ((setq val (gethash fno *agg-statistics*))
		    (let*
			((time (agg-statistic-exec-time-sum val))
			 (card (agg-statistic-quantity val))
			 (out-card (agg-statistic-passed-quantity val))
			 (cost (/ (* time _cost-multiply_) 
				  (if (= card 0) 1 card)))
			 (fanout (/ (+ out-card 0.0) 
				    (if (= card 0) 1 card))))
		      (add-name fno (nth bagpos (cdr pred)))
		      (list cost fanout)))
		   (t
		    (exec-cost-of-fn fno)))
					; context of bag not known:
		(list _default-aggregate-cost_ 0))))
    (+ (first cst)(* (second cst) _default-iteration-cost_))))

;; rank sort change fanout 1.0 by 0.99 to provide ability to compare functions
;; that have fanout <= 1.0 between each other. It is necessary since fanout
;; of many functions that are not generators or filters is equal to 1.
(defun cost-rank (pred bnd)
  "Compute cost rank according to formula on pp 15 in lith-ida-r-92-24."
  (let* ((pc (simple-pred-cost-bnd pred bnd))
	 (lc (first pc))
	 (fo (second pc))
	 (pr (third pc))
	 rank)
    (and fo lc
	 (setq rank
	       (/ (+ -1.0 (if (= fo 1.0) 0.99 fo)) (max 0.0001 lc))))
    (and rank (printopt "Pred:" pred " Bpat: " 
			(listbpat(argsbpat(cdr pred) bnd))
			" Fanout: " fo " Cost: " lc 
			" Rank: " rank t))
    (cons pr rank)))

;; equality is doing assigning and thus it bounds variables and should
;; be done earlier. it usualy has fanout 1.
(declarecosts _=_ '(- +) '(0.01 1.0))
(declarecosts _=_ '(+ -) '(0.01 1.0))

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
                        (osql-result f bpat argl 2.0 1.0))))


(declarecosts 'FUNCTION.MAKEBAG->BAG '(- +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - - +) *costfn*)
(declarecosts 'FUNCTION.MAKEBAG->BAG '(- - - - - +) *costfn*)

;; cost of some is different from default cost of aggregates since it
;; stops when first element of a bag is received
(setq *costfn*
      (foreign-lispfn w_some_costs ((function f)(vector bpat)(vector argl)) 
		      ((number cost)(number fanout))
		      (let
			  ((val)
			  (fno (binding-context (getbinding (aref argl 0)))))
			(cond
			 ((setq val (gethash fno *agg-statistics*))
			  (let*
			      ((time (agg-statistic-exec-time-sum val))
			       (card (agg-statistic-quantity val))
			       (out-card (agg-statistic-passed-quantity val))
			       (cost (/ (* time _cost-multiply_) 
					(if (= card 0) 1 card)))
			       (fanout (/ (+ out-card 0.0) 
					  (if (= card 0) 1 card))))
			    (add-name fno (aref argl 0))
			    (osql-result f bpat argl cost fanout)))
			 (t
			  (let
			      ((cst (exec-cost-of-fn fno)))
			    (osql-result 
			     f bpat argl 
			     (max (/ (first cst)
				     (max 1.0 
					  (* (second cst) 
					     _default-iteration-cost_)))
				  _minimal-aggregation-cost_)
			     (min _default-aggregate-fanout_
				  (second cst)))))))))

(declarecosts 'BAG.W_SOME->BOOLEAN '(-) *costfn*)

;; cost of notany is different from default cost of aggregates since it
;; stops when first element of a bag is received
(setq *costfn*
      (foreign-lispfn w_notany_costs ((function f)(vector bpat)(vector argl)) 
		      ((number cost)(number fanout))
		      (let
			  ((val)
			  (fno (binding-context (getbinding (aref argl 0)))))
			(cond
			 ((setq val (gethash fno *agg-statistics*))
			  (let*
			      ((time (agg-statistic-exec-time-sum val))
			       (card (agg-statistic-quantity val))
			       (out-card (agg-statistic-passed-quantity val))
			       (cost (/ (* time _cost-multiply_) 
					(if (= card 0) 1 card)))
			       (fanout (/ (+ out-card 0.0) 
					  (if (= card 0) 1 card))))
			    (add-name fno (aref argl 0))
			    (osql-result f bpat argl cost fanout)))
			 (t
			  (let
			      ((cst (exec-cost-of-fn fno)))
			    (osql-result 
			     f bpat argl 
			     (max (/ (first cst)
				     (max 1.0 
					  (* (second cst) 
					     _default-iteration-cost_)))
				  _minimal-aggregation-cost_)
			     (min _default-aggregate-fanout_
				  (/ 0.9 (second cst))))))))))

(declarecosts 'BAG.W_NOTANY->BOOLEAN '(-) *costfn*)

;; cost of count_bb is different from default cost since it stops when
;; number of received elements of a bag is equal to second argument
(setq *costfn*
      (foreign-lispfn 
       w_countbb_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((val)
	   (fno (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ((setq val (gethash fno *agg-statistics*))
	   (let*
	       ((time (agg-statistic-exec-time-sum val))
		(card (agg-statistic-quantity val))
		(out-card (agg-statistic-passed-quantity val))
		(cost (/ (* time _cost-multiply_) 
			 (if (= card 0) 1 card)))
		(fanout (/ (+ out-card 0.0) 
			   (if (= card 0) 1 card))))
	     (add-name fno (aref argl 0))
	     (osql-result f bpat argl cost fanout)))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (cond
	      ((integerp (aref argl 1))
	       (osql-result f bpat argl 
			    (max (/ (first cst)
				    (max 1.0 
					 (* (/ (second cst) (aref argl 1))
					    _default-iteration-cost_)))
				 _minimal-aggregation-cost_)
			    (min _default-aggregate-fanout_ 
				 (/ (second cst) (aref argl 1)))))
	      (t 
	       (osql-result f bpat argl 
			    (max (/ (first cst)
				    (max 1.0 
					 (* (second cst) 0.5 
					    _default-iteration-cost_)))
				 _minimal-aggregation-cost_)
			    _default-count-fanout_)))))))))

(declarecosts 'BAG.W_COUNT->INTEGER '(- -) *costfn*)

;; cost of count_bb is different from default cost since it stops when
;; number of received elements of a bag is bigger then first argument
(setq *costfn*
      (foreign-lispfn 
       w_atleast_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((val)
	   (fno (binding-context (getbinding (aref argl 1)))))
	 (cond
	  ((setq val (gethash fno *agg-statistics*))
	   (let*
	       ((time (agg-statistic-exec-time-sum val))
		(card (agg-statistic-quantity val))
		(out-card (agg-statistic-passed-quantity val))
		(cost (/ (* time _cost-multiply_) 
			 (if (= card 0) 1 card)))
		(fanout (/ (+ out-card 0.0) 
			   (if (= card 0) 1 card))))
	     (add-name fno (aref argl 1))
	     (osql-result f bpat argl cost fanout)))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (cond
	      ((integerp (aref argl 0))
	       (osql-result f bpat argl 
			    (max (/ (first cst)
				    (max 1.0 
					 (* (/ (second cst) (aref argl 0))
					    _default-iteration-cost_)))
				 _minimal-aggregation-cost_)
			    (min _default-aggregate-fanout_ 
				 (/ (second cst) (aref argl 0)))))
	      (t 
	       (osql-result f bpat argl 
			    (max (/ (first cst)
				    (max 1.0 
					 (* (second cst) 0.5 
					    _default-iteration-cost_)))
				 _minimal-aggregation-cost_)
			    _default-count-fanout_)))))))))

(declarecosts 'NUMBER.BAG.W_ATLEAST->BOOLEAN '(- -) *costfn*)

(commit)
