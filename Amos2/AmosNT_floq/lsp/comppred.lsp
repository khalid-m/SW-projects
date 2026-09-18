;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Tore Risch, Staffan Flodin, Vanja Josifovski, EDSLAB
;;; $RCSfile: comppred.lsp,v $
;;; $Revision: 1.51 $ $Date: 2013/12/30 13:35:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Generate TR format of ObjectLog from flattened predicate
;;; =============================================================
;;; $Log: comppred.lsp,v $
;;; Revision 1.51  2013/12/30 13:35:53  torer
;;; Better support for tuples
;;;
;;; Revision 1.50  2013/07/22 18:48:14  thatr500
;;; renamed aqit-rewrite to aqit-fixpoint
;;;
;;; Revision 1.49  2013/06/05 11:37:38  torer
;;; Removed ABSORBER-REWRITE
;;;
;;; Revision 1.48  2013/05/01 15:22:44  minzh812
;;; add absorber-rewrite code
;;;
;;; Revision 1.47  2013/02/19 06:02:02  thatr500
;;; Added AQIT entry into compilephase2 and disabled it
;;;
;;; Revision 1.46  2013/02/07 21:24:41  torer
;;; Restored old MAP-OVER-PRED
;;;
;;; Revision 1.45  2013/02/07 12:45:43  torer
;;; Place holder for the absorber manager added
;;;
;;; Revision 1.44  2013/02/07 10:24:07  torer
;;; *** empty log message ***
;;;
;;; Revision 1.43  2012/08/14 18:54:12  torer
;;; Aliasing variables when expanding views
;;;
;;; Revision 1.42  2012/05/02 17:16:47  torer
;;; optional() aware optimization of conjunctions and
;;; order preserving generation of conjunctive predicate
;;;
;;; Revision 1.41  2012/04/26 12:49:37  torer
;;; optional(pred) now supported in AmosQL
;;;
;;; Revision 1.40  2012/04/22 19:17:41  torer
;;; Bug in view expansion with nil parameter
;;;
;;; Revision 1.39  2012/04/20 11:45:00  torer
;;; Incorrect handling of function argument lists
;;;
;;; Revision 1.38  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.37  2011/04/05 11:18:40  thatr500
;;; new special variable *after-view-expansion*
;;;
;;; Revision 1.36  2011/02/16 20:28:29  torer
;;; New Lisp form validation rule
;;;
;;; Revision 1.35  2011/01/03 16:32:25  minzh812
;;; Added and edited some comments
;;;
;;; Revision 1.34  2010/08/27 07:49:56  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.33  2010/05/26 15:30:17  torer
;;; PC now prints final TR with * variables
;;;
;;; Revision 1.32  2010/03/17 10:21:39  torer
;;; rewrite wrapper functions to simplify debugging and profiling
;;;
;;; Revision 1.31  2010/02/17 18:58:51  torer
;;; Better ranksort optimization
;;;
;;; Revision 1.30  2009/09/06 19:00:26  torer
;;; Tougher test for unused variables
;;;
;;; Revision 1.29  2009/09/04 18:55:09  torer
;;; Tougher declaration checking
;;;
;;; Revision 1.28  2009/09/04 15:41:39  torer
;;; Tougher unused variable test
;;;
;;; Revision 1.27  2009/04/22 17:35:45  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.26  2008/12/25 19:30:36  torer
;;; _use_dnf_ -> *use-dnf*
;;;
;;; Revision 1.25  2008/05/21 14:54:38  torer
;;; Bug fixed in maintaining local variables for multidirectional derived functions
;;;
;;; Revision 1.24  2008/05/21 08:08:34  torer
;;; Bug in cost recomputation of TBRs
;;;
;;; Revision 1.23  2008/05/13 19:36:48  torer
;;; Multi-directional derived functions always in-lined
;;;
;;; Revision 1.22  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.21  2007/10/25 17:27:03  torer
;;; subplan transformation did not work for stored functions
;;;
;;; Revision 1.20  2006/11/17 08:04:04  torer
;;; 'Amos' removed from error messages
;;;
;;; Revision 1.19  2006/11/07 18:24:23  torer
;;; Bug fixed in ASSIGNTEMPORARIES
;;;
;;; Revision 1.18  2006/10/08 20:19:09  torer
;;; Missing argument
;;;
;;; Revision 1.17  2006/09/01 10:53:26  torer
;;; Non-recursive compileandargs
;;;
;;; Revision 1.16  2006/04/27 19:18:26  torer
;;; Removed unused functions
;;;
;;; Revision 1.15  2006/04/14 18:37:46  torer
;;; Minor change
;;;
;;; Revision 1.14  2006/04/12 20:59:08  torer
;;; Multi-database decomposition separated
;;;
;;; =============================================================


(defglobal _save-intermediates_ nil) ;; To save expanden and DNF predicates

(defvar *skip-optimization* nil)
;; To enable Algebraic Query Inequality Transformation
(defparameter *enable-aqit* nil)

(defglobal _makebag_)
;; To indicate that view is expanded?
(defparameter *after-view-expansion* nil)

;;; Rewrite wrapper functions to allow for profiling and debugging:

(defun rewrite-before-view-expansion (pred sb)
  (rewrite pred sb))

(defun rewrite-after-view-expansion (pred sb)
  (rewrite pred sb))

(defun rewrite-after-normalization (pred sb)
  (rewrite pred sb))

(defun rewrite-coerced-pred (pred sb)
  (rewrite pred sb))

(defun rewrite-typechecks (pred sb)
  (rewrite pred sb))

(defun aqit-rewrite (pred sb) pred)

;;; The main part of the optimization (except type checking) is done by
;;; COMPILE_PHASE2:

(defun compile_phase2 (pred resl argl quantl quantdecl fno sb)
  "Query simplification, view expansion, normalization, optimization"
  ;; The dynamicaly bound *bindings* and *locals* must be set before invoking
  ;; this function
  (let* (*coerced_input* 
	 *extendedResult* *extendedVars*
	 (*after-view-expansion* nil)
	 (bndl (append argl resl (union quantl *locals*)))
	 )
    (setq pred (andify (compilepredicate pred fno)));; Generate TR pred
    (check-unbound-var quantdecl pred nil)
    (if _save-intermediates_ (setf (selectbody-unoptimized sb) pred))

    (setq pred (rewrite-before-view-expansion pred sb))
    (setf (selectbody-orgpred sb) pred);; This version used by view expansion
    (update-locals sb quantl)
    (update-locals sb *locals*)

    (setq pred (expand-predicate pred nil));; View expansion
    (if _save-intermediates_ (setf (selectbody-expanded sb) pred))
    (setq *after-view-expansion* t)

    (setq pred (rewrite-after-view-expansion pred sb))
    (if _save-intermediates_ (setf (selectbody-expanded-simplified sb) pred))

    (cond (*enable-aqit*
	   (setq pred (aqit-fixpoint pred))
	   (if _save-intermediates_ (setf (selectbody-aqit sb) pred))))

    ;; Normalize to DNF
    (if *use-dnf* (setq pred (transformpredicate pred)))
    (if _save-intermediates_ (setf (selectbody-normalized sb) pred))

    (setq pred (rewrite-after-normalization pred sb))
    (setf (selectbody-pred sb) (if pred (copy-tree pred) 'TRUE))

    (update-locals sb *locals*)
    (cond (*skip-optimization* nil)
	  (t      
	   ;;To expand the templates of the input variables
	   ;;These are not expanded because 
	   ;;   they should be so in selectbody-pred
	   (setq pred (process_typechecks pred sb argl resl nil))

           ;;(setq pred (absorber-rewrite pred sb))
           ;;(if _save-intermediates_ (setf (selectbody-absorbed sb) pred))

	   (optimize-pred pred sb fno);; Coercion and cost-based optimization

	   (cond ((not (expand-views?))
		  (setf (selectbody-delpred sb);;Update template
			(create-delpred (selectbody-optpred sb)))
		  sb))))))

(defun predicate-binds-variable (var pred)
  "True if variable VAR gets bound by PRED"
  (and (in var pred)
       (let (ok) 
         (mappred pred (f/l (p)(if (memq var p) (setq ok t))))
         ok)))

(defun check-unbound-var (dcll pred simpletest)
  "Check that all variables declared in DCLL are bound by PRED"
  (dolist (dcl dcll)
    (let ((tpo (dcl-type dcl))
          (var (dcl-variable dcl)))
      (if (and (oid-p tpo)
               (neq tpo _boolean_)
	       (if _eca-enabled_ (not (surrogate-type? tpo)) t)
               (if simpletest (not (in var pred))
		 (not (predicate-binds-variable var pred))))
	  (error "Declared variable not bound anywhere" var)))))

(defun pred-variables (pred)
  (let (res)
   (mappred pred (f/l (p)
     (dolist (v (cond ((atom p) (list p))
                      ((eq (car p) 'call)(cddr p))
                      (t (cdr p))))
        (if (osql-variablep v)(setq res (adjoin v res))))))
   res))

(defun recompute-locals (sb)
  (let ((vars (union (pred-variables (selectbody-optpred sb))
                     (pred-variables (selectbody-pred sb)))))
    (setf (selectbody-locals sb)
	  (set-difference
	   (set-difference vars (selectbody-argl sb))
	   (selectbody-resl sb)))
    (setf (selectbody-loct sb)(arg-typel (selectbody-locals sb)))))

(defun update-locals (sb vars)
  "Add variables in VARS to local variables of selectbody SB"
  (let ((newvars (set-differencel vars (list 
					(selectbody-locals sb)
					(selectbody-argl sb)
					(selectbody-resl sb)))))
    (setq newvars (subset newvars 
			  (f/l (var)(or (in var (selectbody-orgpred sb))
					(in var (selectbody-pred sb))
					(in var (selectbody-coercedpred sb))
					(in var (selectbody-optpred sb))))))
    (cond (newvars 
	   (setf (selectbody-locals sb) 
		 (append (selectbody-locals sb) newvars))
	   (setf (selectbody-loct sb)
		 (append (selectbody-loct sb) 
			 (mapcar (f/l (v)(if (getbinding v t)(arg-type v)
					   _object_))
				 newvars)))))))

(defun process_typechecks (predl1 sb argl resl noExpandFlag)
  (let ((predl predl1)
	(*change_flag* t) 
	*change_l*)
    (while (and *change_flag* _ENABLE_DT_FLAG_)
      (setq predl (rewrite-typechecks predl sb))
      (setq *change_flag* nil)
      (setq *change_l*  nil)
      (if (and (listp predl) (not (eq (car predl) 'and))
	       (not (eq (car predl) 'or)))
	  (setq predl (list 'AND predl)))
      (setq predl (insert_templates predl argl resl nil noExpandFlag))
      (debug_do (if *change_flag*(debug_pt "AFTER TEMPLATE EXPANSION" predl))))
    predl))

;the query processing continues....
;applies coercion analsis, (the last) rewrite, query decomposition,
;

(defun optimize-pred (pred sb &optional fno)
  "Transform tr resolvent in selectbody-pred(sb) into optimized tbr
   resolvent in selectbody-optpred(sb)." 
  (let (opt-coerced-pred coerced-pred)
    (prog1 
	(setf 
	 (selectbody-optpred sb)    
	 (cond ((atom pred) pred)
	       (t (setq coerced-pred;; Only for Vanja's coersion
			(apply_to_pred pred sb (function coerce_expand)))
		  (setq opt-coerced-pred (rewrite-coerced-pred
					  coerced-pred sb ))
		  (cond ((mdb-optimization?)
                         ;; Only for Vanja's multi-database optimization
			 (setf (selectbody-coercedpred sb) opt-coerced-pred)

			 (distributed-decomposition fno sb opt-coerced-pred))
			(t;;single database optimization
			 (decompose-pred opt-coerced-pred sb)))))) 
					; cost based
      (update-locals sb *locals*))))

(defun mdb-optimization? ()
  "Multi-database decomposition is needed under these conditions"
  (not _use_dtr_))

(defun compilepredicate (xpr fno)
  (cond ((null xpr) nil)
	((or (osql-constantp xpr)(atom xpr))
	 (list xpr))
        ((compound-p xpr)
	 (selectq 
	  (car xpr)
	  (and (compileandargs (cdr xpr) fno))
	  (or (list (cons 'or (compileorargs (cdr xpr) fno))))
	  (optional (list (cons 'optional (compilepredicate 
					   (cadr xpr) fno))))
	  (error "Predicate compilation not implemented for" (car xpr))))
	((eq (car xpr) 'call)
	 (list (list* (car xpr)(cadr xpr)(caddr xpr)
		      (compileandargs (cdddr xpr) fno))))
	((dtr? (car xpr))
	 (list (cons (dtrpred-in-dtr xpr) 
		     (cons (fnlist-in-dtr xpr)
			   (cdr (compileandargs 
				 (first-function-in-dtr-with-args
				  xpr) fno
				 ))))))
	((eq (car xpr) _=_)
	 (let ((lhs (cadr xpr))
	       (rhs (caddr xpr)))
           (cond ((not (simpleexpr rhs))
                  (compilefuneq (car rhs)(cdr rhs)(makeresl lhs) fno))
                 ((not (simpleexpr lhs))
                  (compilefuneq (car lhs)(cdr lhs)(makeresl rhs) fno))
                 ((and (tuplep rhs)(osql-variablep lhs))
		  (list (list* _tuple-constructor_ lhs (cdr rhs))))
                 ((and (tuplep lhs)(osql-variablep rhs))
		  (list (list* _tuple-constructor_ rhs (cdr lhs))))
		 (t (list (list _=_ lhs rhs))))))
	((foreign-predicatep (car xpr)) 
	 (list (cons (car xpr)
		     (compileandargs (cdr xpr) fno))))
	(t (compilepredicatefncall  (car xpr)(cdr xpr) fno))))

(defun compilepredicatefncall (fn args fno)
  (let ((sb (getselectbody fn)))
    (cond ((null sb)
	   (error "Undefined function " fn))
	  ((dynconstructorfn fn) (cons fn args))
	  (t (list (cons fn (compileandargs args fno)))))))

(defun compilefuneq (fn argl1 resl fno)
  "Generate TR ObjectLog from FN(ARGL)=RESL. FNO is function being compiled"
  (let* ((sb (if (dtr? fn) (getobject (caar argl1) 'selectbody)
	       (getobject fn 'selectbody)))
	 (argl (if (dtr? fn) (cdr argl1) argl1)))
    (cond
     ((and (null (function-resulttypes (cons fn argl1)))
	   resl
	   (null (cdr resl)))
					;Boolean equality test
      (cons (list _=_ (car resl) 'true)
	    (compilefuneq fn argl1 nil fno)))
     ((eq fn fno)
      (amos-error "Recursive calls not allowed in derived functions: " fn))
     ((getobject fn 'ismakebag)
      (list (cons _makebag_ (append argl resl))))
     ((dynconstructorfn fn)
      (list (cons fn (append resl argl))))
     ((and (null (function-resulttypesfn fn))
           (not (= (length resl)
                   (length (selectbody-resl sb)))))
      (amos-error "Width mismatch in function call to "
                  (mkfunsig fn '= argl resl)))
     ((dtr? fn) (list (cons fn (append argl1 resl))))
     (t (list (cons fn (append argl resl)))))))

(defun expandfn (parameters fn sb)
  "Expand function FN subtituting PARAMETERS for the arguments
   and results in the function definition in SB"
  (if (null sb) (cons fn parameters)	; no definition
    (let* ((argres (selectbody-argresl sb))
	   (xvars (addxvars argres parameters)) ; for FFs with dynamic width
	   (substl			; new substitution list
	    (nconc
	     (pair (append argres xvars)
		   parameters)
	     (pair (selectbody-locals sb)
		   (genvars (selectbody-loct sb))))))
      (if (> (length argres)(length parameters))
	  (error "Too few arguments in predicate" (cons fn parameters)))
      (expand-predicate (append (or (selectbody-orgpred sb)
				    (selectbody-pred sb))
				xvars)
			substl))))

(defun expand-predicate (pr substl)
  "Beta-expand all simple predicates in PR using substitution list SUBSTL"
  (let (nsubstl equivalences expanded)
    (mapl (f/l (root)
	       (let ((other-binding (assq (caar root) (cdr root))))
		 (cond (other-binding
			(push (list _=_ (cdar root)(cdr other-binding))
			      equivalences))
		       (t (push (car root) nsubstl)))))
	  substl)
    (setq expanded (map-over-pred pr (f/l (x) (expand-simple-pred x nsubstl)) 
				  (function id)))
    (if equivalences (andify (cons expanded equivalences))
      expanded)))

(defun subst-simple-predicate (pr substl)
  "Substitute variables in simple predicate PR using substitution list SUBSTL"
  (cond ((dtr? (car pr))(list* (car pr)(cadr pr)
			       (subst-args (cddr pr) substl)))
	(t (cons (car pr)(subst-args (cdr pr) substl)))))

(defun subst-predicate (pr substl)
  "Substitute variables in predicate PR using substution list SUBSTL"
  (map-over-pred pr 
		 (f/l (x) (subst-simple-predicate x substl))
		 (function id)))

(defun subst-args (l substl)
  "Substitute top level of L using substitution list SUBSTL"
  (mapcar (f/l (x)(let ((s (assq x substl)))
                    (if s (cdr s) x)))
	  l))

(defun expand-simple-pred (pr substl)
  "Expand simple predicate PR using substitution list SUBSTL"
  (cond ((osql-constantp pr) pr)
	((atom pr)(sublis substl pr))
	(t (let ((fn (getfunctionnamed (car pr))))
	     (cond ((or (dynconstructorfn fn)(relationp fn)
			(foreign-predicatep fn))
		    (subst-simple-predicate pr substl))
		   (t (expandfn (cdr (subst-predicate pr substl))
				fn (getselectbody fn))))))))

(defun addxvars (l params)
  "L is formal arguments of dynamic width predicate 
   and PARAMS actual parameters. 
   Generate new parameters for those required by PARAMS but missing in L"
  (cond ((>= (length l)(length params)) nil)
        (t  (genvars (mapcar (function arg-type)
			     (nthcdr (length l) params))))))

(defun compileandargs (predl fno)
  (cond
   ((null predl)
    nil)
   ((atom predl)
    (amos-error "Not an argument list: " predl))
   (t (let (res)
	(dolist (pred predl)
	  (dolist (p (compilepredicate pred fno))
	    (push p res)))
	(nreverse res)))))

(defun compileorargs (predl fno)
   (cond
         ((null predl)
          nil)
         ((atom predl)
          (amos-error "not an osql argument list: " predl))
         (t(mapcar
             (function
               (lambda (x)
                 (andify
                   (compileandargs
                     (list x)
                     fno))))
             predl))))

(defun simpleexpr (x)(or (atom x)(aggregatep x)))

(defun makeresl (x)
  (cond ((atom x) (list x))
	((eq (car x) _tupletag_) (cdr x))
	(t (amos-error "Illegal value " x))))

(defun assigntemporaries (predl pos &optional before)
  "Add predicates to assign new variables in *BINDINGS* to their 
   initializations up to just before POS in *BINDINGS*"
  (let (new (tl *bindings*) b val)
    (while tl
      (if (eq tl pos)(return nil))
      (setq b (pop tl))	 
      (cond ((null (setq val (binding-val b))))	; No initialization
	    ((binding-var b)
	     (push (list _=_  (binding-var b) val) new)
             (setf (binding-val b) nil));; Clear binding initialization
	    (t (push val new);; Boolean assertion
               (setf (binding-val b) nil))))
    ;; The new predicates are in reverse order since they were pushed on stack 
    (if before (nconc new predl)
      (append predl new))))
