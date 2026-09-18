;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: dyngroups.lsp,v $
;;; $Revision: 1.14 $ $Date: 2008/12/28 15:27:24 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Generates groups for a predicate during optimization. It is called
;;; during optimization of the predicate. To generate a plan for a function
;;; with the dynamic group cost model the flag grouping() should be set to 
;;; true before optimization. The flag should be set to false before any 
;;; execution, otherwise if execution requires optimization the dynamic group
;;; cost model generation will be called.
;;; ===========================================================================
;;; $Log: dyngroups.lsp,v $
;;; Revision 1.14  2008/12/28 15:27:24  torer
;;; Cached TBR-function group-- to avoid circular recompilations during bootstapping
;;;
;;; Revision 1.13  2008/12/25 19:35:13  torer
;;; (setq *old-decompose* t) since ALEH depends on old code that cannot handle non-DNF predicates
;;;
;;; Revision 1.12  2007/06/21 09:33:36  ruslan
;;; functions to replace calls to group-wrap with their predicates are written. the call for replacing is commented because there is a problem with execution.
;;;
;;; Revision 1.11  2007/06/20 07:37:16  ruslan
;;; minor improvement of the codes
;;;
;;; Revision 1.10  2007/03/02 15:29:39  ruslan
;;; different levels for randomopt in profiled grouping on top and inside groups
;;;
;;; Revision 1.9  2007/03/01 10:01:51  ruslan
;;; since grouping algorithm reverses original order of input predicates, which is executable. the reverse back is added
;;;
;;; Revision 1.8  2007/02/28 13:32:54  ruslan
;;; minor change
;;;
;;; Revision 1.7  2007/02/28 12:48:18  ruslan
;;; grouping function to toggle grouping mode is moved to one place (grouping.lsp)
;;;
;;; Revision 1.6  2007/02/28 12:43:40  ruslan
;;; different optimization methods can be used for optimizing top predicate and for optimizing inside generated groups.
;;;
;;; Revision 1.5  2007/02/14 08:45:08  ruslan
;;; if result type of selectbody is nil then type boolean is returned
;;;
;;; Revision 1.4  2006/10/18 15:10:56  ruslan
;;; tbr resolvents for transient functions of groups are generated during optimization phase and cached. thus no optimization is performed during execution
;;;
;;; Revision 1.3  2006/10/17 07:35:50  ruslan
;;; generating dynamic group cost model plan is more robust. if the profiling is not possible static cost model is used.
;;;
;;; Revision 1.2  2006/10/16 14:04:23  ruslan
;;; dynamic group cost model generation is implemented. still needs to be improved
;;;
;;; Revision 1.1  2006/10/10 09:39:31  ruslan
;;; first impelementation of the grouping algorithm
;;;
;;; ===========================================================================

; Flag for doing grouping. It is definded in grouping.lsp
;(defglobal *grouping* nil)
; Variable for which joins between groups are allowed
(defglobal *group_variabletype* (gettypenamed 'EVENT))
(defglobal *group-sample-size* 50)
; The optmization method global variables are defined in grouping.lsp,
; since they are used there also. They used here for optimizing created
; transient functions for groups.
;(defglobal *top-optimization-method* "ranksort")
;(defglobal *group-optimization-method* "ranksort")

(setq *old-decompose* t) ;; so that sortandpred0 is called

(defun type-of-variable (var sb)
  "For the given variable findes its type in one of the variable lists of the
given selectbody"
  (let (type)
    (cond
     ((setq type (do ((vs (selectbody-argl sb))(ts (selectbody-argt sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (return (car ts)))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     ((setq type (do ((vs (selectbody-resl sb))(ts (selectbody-rest sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (if ts
			      (return (car ts))
			    (return (gettypenamed 'BOOLEAN))))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     ((setq type (do ((vs (selectbody-locals sb))(ts (selectbody-loct sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (return (car ts)))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     (t (error "Variable expected to be in some variable list of select body" 
	       var)))))
		  
; The structure to store all information about created group
(defstruct group pred groupv localv argv resv) 

(defun variablelist (variables var- sb group)
  "For the given list of arguments of a predicate finds, which of them are
variables and stores them in the given group together with their types."
  (let ((vs nil) (gr (make-group :pred (group-pred group) 
				 :groupv (group-groupv group)
				 :localv (group-localv group)
				 :argv (group-argv group)
				 :resv (group-resv group))))
    (mapc (f/l (v)
	       (cond
		((not (named-varsymbolp v)) nil)
		((equal (car variables) var-) nil)
		((equal (type-of-variable v sb) *group_variabletype*)
		 (setf (group-groupv gr)
		       (adjoin
			(list (oid-name *group_variabletype*) v) 
			(group-groupv group))))
		((member v (selectbody-argl sb))
		 (setf (group-argv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-argv group)))
		 (setq vs (adjoin v vs)))
		((member v (selectbody-resl sb))
		 (setf (group-resv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-resv group)))
		 (setq vs (adjoin v vs)))
		(t 
		 (setf (group-localv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-localv group)))
		 (setq vs (adjoin v vs))))) 
	  variables)
    (list vs gr)))

(defun variables (pred var- sb group)
  "variables of the given predicate from selectbody sb excluding variable of
type *group_variabletype* and variable var-"
  (cond
   ((equal (car pred) (getfunctionnamed 'FUNCTION.MAKEBAG->BAG))
    (variablelist (cddr pred) var- sb group))
   (t
    (variablelist (cdr pred) var- sb group))))

(defun grouping-algorithm (predl sb)
  "Implementation of the grouping algorithm, which generates groups for the 
given predicate in terms of the group structure"
  (let ((groups nil))
    (do ((S predl)) ((null S))
      (let (p (G nil) (vs nil) vars
	      (group (make-group :groupv nil :localv nil
				 :argv nil :resv nil)))
	(do ()((not (null vs)))
	  (setq p (car S))
	  (setq S (cdr S))
	  (setq G (cons p G))
	  (setq vars (variables p nil sb group))
	  (setq vs (first vars))
	  (setq group (second vars)))
	(do ((v nil)) ((null vs))
	  (setq v (car vs))
	  (setq vs (cdr vs))
	  (setq S 
		(mapfilter 
		 (f/l (q)
		      (setq vars (variables q nil sb group))
		      (cond 
		       ((null (first vars))
			(setq G (cons q G))
			(setq group (second vars))
			nil)
		       ((member v (first vars))
			(setq G (cons q G))
			(mapcar (f/l (qvar) 
				     (setq vs (adjoin qvar vs)))
				(remove v (first vars)))
			(setq group (second vars))
			nil)
		       (t q)))
		 S)))
	(setf (group-pred group) (reverse G))
	(setq groups (cons group groups))))
    groups))

(defglobal _group--_ 
  (the-tbr-function 
   (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
   '(- -)))

(defun grouped-pred (groups)
  "Creates new predicate for the given groups"
  (let ((pred nil))
    (setq *agg-tocollect* t)
    (dolist (g groups)
      (let*
	  ((arglist (append2 (group-groupv g) (append2 (group-argv g)
						       (group-resv g))
						    
			     ))
	   (reslist (group-resv g))
	   (mainoptmethod (aref (first 
				 (callfunction 
				  (getfunctionnamed 'optmethod)
				  (list *group-optimization-method*))) 0))
	   (counter 0) 
	   (old_ii _iino_) (old_sh _shno_)
	   fno group)
	(/setglobal '_iino_ (first *group-optlevel*))
	(/setglobal '_shno_ (second *group-optlevel*))
	(setq fno 
	      (createfunction '*TRANSIENT* arglist
			      '((BOOLEAN)) nil (group-localv g)
			      (cons 'FLATTENED (cons 'AND (group-pred g)))))
	(setq group 
	      (cond
	       ((equal 1 (length arglist))
		(if (null (group-argv g)) 
		    ;; profiling can be done only if the function doesn't
		    ;; have any other inputs except the group variable (event)
		    (catch 'PROFILED
		      (mapextent
		       *group_variabletype*
		       (f/l (ev)
			    (if (equal counter *group-sample-size*)
				(throw 'PROFILED T))
			    (1++ counter)
			    (mapfunction _group--_
			     (list fno ev) (f/l (x) x))))))
		(list (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
		      fno (second (first arglist))))
	       ((equal 2 (length arglist))
		(if (null (group-argv g))
		    ;; profiling can be done only if the function doesn't
		    ;; have any other inputs except the group variable (event)
		    (catch 'PROFILED
		      (mapextent
		       *group_variabletype*
		       (f/l (ev) 
			    (if (equal counter *group-sample-size*)
				(throw 'PROFILED T))
			    (1++ counter)
			    (mapfunction 
			     (the-tbr-function 
			      (getfunctionnamed 
			       'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN) 
			      '(- - +)) 
			     (list fno ev) (f/l (x) x))))))
		(list (getfunctionnamed 
		       'FUNCTION.OBJECT.OBJECT.GROUP->BOOLEAN)
		      fno (second (first arglist)) 
		      (second (second arglist))))
	       ((equal 3 (length arglist))
		(if (null (group-argv g))
		    ;; profiling can be done only if the function doesn't
		    ;; have any other inputs except the group variable (event)
		    (catch 'PROFILED
		      (mapextent
		       *group_variabletype*
		       (f/l (ev) 
			    (if (equal counter *group-sample-size*)
				(throw 'PROFILED T))
			    (1++ counter)
			    (mapfunction 
			     (the-tbr-function 
			      (getfunctionnamed 
			       'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN) 
			      '(- - + +)) 
			     (list fno ev) (f/l (x) x))))))
		(list (getfunctionnamed 
		       'FUNCTION.OBJECT.OBJECT.OBJECT.GROUP->BOOLEAN)
		      fno (second (first arglist)) 
		      (second (second arglist)) (second (third arglist))))))
	(callfunction (getfunctionnamed 'optmethod) (list mainoptmethod))
	(/setglobal '_iino_ old_ii)
	(/setglobal '_shno_ old_sh)
	(setq pred (cons group pred))))
    (setq *agg-tocollect* nil)
    pred))

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
	       
(defun sortandpred0 (remaining sb)
  (cond 
   ((atom remaining) remaining)
   ;; Applies grouping algorithm to the given predicate if the flag is true
   (*grouping* 
    (let ((groups (grouping-algorithm remaining sb))
	  (old_ii _iino_) (old_sh _shno_)
	  mainoptmethod respred)
      (cond 
       ((> (length groups) 1)
	(setq *grouping* nil)
	(setq remaining (grouped-pred groups))
	(setq mainoptmethod (aref (first 
				   (callfunction 
				    (getfunctionnamed 'optmethod)
				    (list *top-optimization-method*))) 0))
	(/setglobal '_iino_ (first *top-optlevel*))
	(/setglobal '_shno_ (second *top-optlevel*))
	(setq respred (psort (purge remaining sb)
			     (selectbody-argl sb)))
	(callfunction (getfunctionnamed 'optmethod) (list mainoptmethod))
	(/setglobal '_iino_ old_ii)
	(/setglobal '_shno_ old_sh)
	(setq *grouping* t)
	respred)
;	(remove-group-wrap respred))
       (t
	(psort (purge remaining sb)
	       (selectbody-argl sb))))))
   (t
    (psort (purge remaining sb)
	   (selectbody-argl sb)))))
