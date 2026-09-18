;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2009 Silvia Stefanova, UDBL
;;; $RCSfile: pushCoreCluster.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/04/25 20:24:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for pushing the common cluster fns out of a predicate
;;;;;; ===========================================================================

(defun filterout-commonpred (pred)
"Picks up only the core cluster fn from the predicate if there is such"
   (cond ((atom pred) (if (leaf-predicate-p pred) 
			  (if (core-cluster-fn? (predicate-operator pred)) (list pred)
			    NIL)
			NIL))
	 (t (if (leaf-predicate-p (car pred))
		(if (core-cluster-fn? (predicate-operator (car pred)))(list (car pred))
		  (filterout-commonpred (cdr pred)))
	      (filterout-commonpred (cdr pred))))))



(defun transform-OR-outclust (pred)
" ( (AND ...) (AND ...) ....) with common cluster functionss"
  (let (  (restbutcommon '())
          (left pred)
	  (res nil)
          (reslocal nil)
          (commonpred nil))
        (while (null (eq left NIL))
	   (setq commonpred (filterout-commonpred (car left))) ;1st
	   (if (eq NIL commonpred) 
               (progn
		 (setq reslocal (car left))
		 (setq left (cdr left)))
               (progn 
		 (setq restbutcommon (subst nil '(AND) (return-localdiff  (remove 'AND commonpred) left)))
		 (setq left (return-diff commonpred left))   
		 (setq reslocal (nconc1 (cons 'AND commonpred)(orify restbutcommon)))
                ))

	   (setq res (nconc1 res reslocal)))      
	(if (= (length (cdr res)) 1)
            (cadr res)
	    res)))




(defun polland-simplep-new (pred)
"Transform OR over a simple predicate"
   (cond ((atom pred)  pred)
         ((eq 'OR (car pred))		;if pred is an OR predicate
           (if (in 'AND (cdr pred)) ;if pred is (OR (AND ..)(AND.. .)  )
               (transform-OR-outclust pred)
               pred))				; if pred is a simple OR (OR a b c)
         ((and (eq 'AND (car pred)) (listp (car (last pred))))	;(AND ..) predicate
           (if (eq 'OR (caar (last pred)))	;if pred is (AND...(OR (AND ..) (AND ..)))
	      (transform-and-of-and (nconc1 (ldiff pred (last pred))(transform-OR-outclust (car (last pred)))))
              pred))
         (t pred)))		; if a simple (AND ...)



(defun polland-once-new (pred)
"Apply polland once"
   (map-over-pred pred (function identity) (function polland-simplep-new)))


(defun compile_phase2 (pred resl argl quantl fno sb)
  "Query simplification, view expansion, normalization, optimization"
  (let* (*coerced_input* 
	 *extendedResult* *extendedVars*
	 (bndl (append argl resl (union quantl *locals*)))
	 )
    (setq pred (andify (compilepredicate pred fno)))
    (if _save-intermediates_ (setf (selectbody-unoptimized sb) pred))

    (setq pred (rewrite pred sb))
    (setf (selectbody-orgpred sb) pred);; This version used by view expansion
    (update-locals sb quantl)
    (update-locals sb *locals*)

    (setq pred (expand-predicate pred nil))
    (if _save-intermediates_ (setf (selectbody-expanded sb) pred))

    (setq pred (rewrite pred sb))
    (if _save-intermediates_ (setf (selectbody-expanded-simplified sb) pred))

    ;; Normalize to DNF
    (if *use-dnf* (setq pred (transformpredicate pred)))
    (if _save-intermediates_ (setf (selectbody-normalized sb) pred))
    (if _polland_ 
	 (setq pred (polland-once-new pred))) ;Use polland 
    (setq pred (rewrite pred sb))
    (setf (selectbody-pred sb) (if pred (copy-tree pred) 'TRUE))
   
    (update-locals sb *locals*)
    (cond (*skip-optimization* nil)
	  (t      
	   ;;To expand the templates of the input variables
	   ;;These are not expanded because 
	   ;;   they should be so in selectbody-pred
	   (setq pred (process_typechecks pred sb argl resl nil))

	   (optimize-pred pred sb fno);; Coercion and cost-based optimization

	   (cond ((not (expand-views?))
		  (setf (selectbody-delpred sb);;Update template
			(create-delpred (selectbody-optpred sb)))
		  sb))))))


(defun comp_costpred (fno)
 (setq _polland_ t) 
 (defun compute-exec-cost-pred (optpreds bnd)
  (catch 'predcost;;An exception can be raised in andpredcost
    (let* ((disjs (if (eq 'or (car optpreds)) (cdr optpreds) nil))
	   (ands (cond ((eq (car optpreds) 'and) (cdr optpreds))
		       ((atom optpreds) nil)
		       (t (list optpreds))))
	   (cost (list 0 0)))
      (if (null disjs) 
	  (setq cost (andpredcost ands bnd))
	
        ;;Cost of a disjunction is the sum of the cost of its elements
	(dolist (branch disjs)    
	  (let* ((branch_cost (compute-exec-cost-pred (if (compound-p branch) 
							  (optimize-compound-predicate branch bnd)
							branch) bnd)))
	    (if branch_cost
		(setq cost (list (+ (first cost) (first branch_cost))
				 (+ (second cost) (second branch_cost))))
	      (amos-error "OR branch cannot be executed in the 
                                 given context:" branch)))))
      cost)))
)


(defun back_comp_costpred (fno)
 (setq _polland_ NIL) 
 (defun compute-exec-cost-pred (optpreds bnd)
  (catch 'predcost;;An exception can be raised in andpredcost
    (let* ((disjs (if (eq 'or (car optpreds)) (cdr optpreds) nil))
	   (ands (cond ((eq (car optpreds) 'and) (cdr optpreds))
		       ((atom optpreds) nil)
		       (t (list optpreds))))
	   (cost (list 0 0)))
      (if (null disjs) 
	  (setq cost (andpredcost ands bnd))
	
        ;;Cost of a disjunction is the sum of the cost of its elements
	(dolist (branch disjs)    
	  (let* ((branch_cost (compute-exec-cost-pred branch bnd)))
	    (if branch_cost
		(setq cost (list (+ (first cost) (first branch_cost))
				 (+ (second cost) (second branch_cost))))
	      (amos-error "OR branch cannot be executed in the 
                                 given context:" branch)))))
      cost)))
)