;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Tore Risch, Staffan Flodin, EDSLAB
;;; $RCSfile: flatten.lsp,v $
;;; $Revision: 1.78 $ $Date: 2013/12/30 13:35:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Flattener
;;; =============================================================
;;; $Log: flatten.lsp,v $
;;; Revision 1.78  2013/12/30 13:35:54  torer
;;; Better support for tuples
;;;
;;; Revision 1.77  2013/12/27 13:15:37  torer
;;; Simplified flattenoptional
;;;
;;; Revision 1.76  2013/04/08 08:45:12  torer
;;; Better error message
;;;
;;; Revision 1.75  2013/04/07 18:57:45  torer
;;; Error when nesting comparisons
;;;
;;; Revision 1.74  2012/05/08 16:06:55  torer
;;; Order preserving AND flattening
;;;
;;; Revision 1.73  2012/05/04 13:21:07  torer
;;; ) removed
;;;
;;; Revision 1.72  2012/05/02 17:16:47  torer
;;; optional() aware optimization of conjunctions and
;;; order preserving generation of conjunctive predicate
;;;
;;; Revision 1.71  2012/04/28 13:21:58  torer
;;; Stricter type checking of predicates
;;;
;;; Revision 1.70  2012/04/27 20:13:41  torer
;;; Better type checking
;;;
;;; Revision 1.69  2012/04/26 12:49:37  torer
;;; optional(pred) now supported in AmosQL
;;;
;;; Revision 1.68  2012/04/13 10:13:07  torer
;;; Stack overflow bug
;;;
;;; Revision 1.67  2012/03/19 18:37:29  torer
;;; Could not assign materialized bag to bag variable
;;;
;;; Revision 1.66  2012/02/15 14:01:05  torer
;;; (3,2)=(1+2,3); did not work
;;;
;;; Revision 1.65  2011/12/22 13:55:35  torer
;;; Removed duplicated code
;;;
;;; Revision 1.64  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.63  2011/01/21 07:05:21  torer
;;; New macro (AMOS-WARNING X Y ...) for warning messages
;;;
;;; Revision 1.62  2011/01/09 16:36:01  torer
;;; Generalized flattenfuncall to handle variables
;;;
;;; Revision 1.61  2010/12/29 19:57:48  torer
;;; Nicer warning message
;;;
;;; Revision 1.60  2010/11/08 16:27:54  torer
;;; <..f(x)..> = <.. p ..> failed
;;;
;;; Revision 1.59  2010/08/27 07:49:56  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.58  2010/06/18 16:00:16  torer
;;; false <=> cast(nil as Boolean)
;;;
;;; Revision 1.57  2009/12/30 19:42:53  torer
;;; More readable typing error messages
;;;
;;; Revision 1.56  2009/11/17 17:30:26  torer
;;; _strict-in_ default is now T
;;;
;;; Revision 1.55  2009/11/16 20:04:13  torer
;;; (setq _strict-in_ t) => System will warn when = is used where 'in' should have
;;;
;;; Revision 1.54  2009/11/02 07:58:02  torer
;;; Incremental recompilation of derived functions with transient subplans now works
;;;
;;; Revision 1.53  2008/11/23 15:00:26  torer
;;; Stricter type checking
;;;
;;; Revision 1.52  2008/11/20 19:29:45  torer
;;; Checking result types of aggregate functions
;;;
;;; Revision 1.51  2008/11/19 07:54:13  torer
;;; Code verified
;;;
;;; Revision 1.50  2008/11/18 21:01:43  torer
;;; OSQL-BAGTYPEP -> BAG-TYPE?
;;;
;;; Revision 1.49  2008/11/17 20:27:56  torer
;;; Boolean expressions in select result
;;;
;;; Revision 1.48  2008/08/13 07:58:07  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.47  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.46  2007/12/19 21:03:51  torer
;;; Wrong type on transient functions
;;;
;;; Revision 1.45  2007/12/19 19:28:42  torer
;;; Removed obsolete code
;;;
;;; Revision 1.44  2007/12/18 07:36:58  torer
;;; Constructor forms on transient objects
;;;
;;; Revision 1.43  2007/12/10 12:26:28  torer
;;; Generalized result type checking in late bound function call
;;;
;;; Revision 1.42  2007/09/15 20:38:54  torer
;;; Added CAST-TO-TYPE to compute type of cast expression
;;;
;;; Revision 1.41  2007/05/06 05:42:52  torer
;;; Restored correct version of typecontainer handling
;;;
;;; Revision 1.40  2007/05/04 14:01:56  zeitler
;;; flatten.lsp: improved readability
;;; iterate: attempt to bypass type checker
;;;
;;; Revision 1.39  2007/02/17 16:26:12  torer
;;; Introduced form static_type in AmosQL to obtain compile time type of expression
;;;
;;; Revision 1.38  2006/12/14 18:15:45  torer
;;; Cleanup of flattensubquery
;;;
;;; Revision 1.37  2006/12/05 20:47:42  torer
;;; Cosmetics
;;;
;;; Revision 1.36  2006/11/30 20:20:46  torer
;;; No bag coersion when function returns bag
;;;
;;; Revision 1.35  2006/11/30 19:42:23  torer
;;; Functions may return materialized bags
;;;
;;; =============================================================

(defglobal _comparisons_ '(< <= > >= !=) "Comparison operators")

(defglobal *_dtrfunction_*)
(defvar *no_lb* nil)

(defglobal _strict-in_ t "Warning on using = instead of in")

(defun bagof-to-select (xpr)
  "(bagof x) -> (select ((x))"
  (if (atom xpr) xpr
    (selectq (car xpr)
	     (bagof `(select (,(cadr xpr))))
	     xpr)))

(defvar *free-variables-in-predicate*)

(defun free-variables (pred lvars)
  "Compute list of free variable in predicate"
  (let ((*free-variables-in-predicate* (tconc)))
    (free-variables-pred pred lvars)
    (car *free-variables-in-predicate*)))

(defun getvars (dcll)
  "Get list of variables declared in declaration list DCLL"
  (mapcar (function dcl-variable) dcll))

(defun free-variables-pred (pred lvars)
  "Aux function to FREE-VARIABLES"
  (cond ((eq pred '*) nil)
        ((symbolp pred)
	 (cond ((osql-constantp pred))
               ((memq pred lvars))
               ((memq pred (car *free-variables-in-predicate*)))
	       (t (tconc *free-variables-in-predicate* pred))))
	((atom pred) nil)
	((memq (car pred) '(select osql-select));; subquery
	 (let ((lvars (union lvars 
			     (getvars (substdeclarations 
				       (select-get pred 'foreach))))))
	   (free-variables-predl (select-get pred 'result) lvars)
	   (free-variables-pred (select-get pred 'where) lvars)))
        ((eq (car pred) 'cast)
	 (free-variables-pred 
	  (second pred)
	  (union lvars (getvars 
			(substdeclarations (list (third pred)))))))
	(t (free-variables-predl (cdr pred) lvars))))

(defun free-variables-predl (predl lvars) 
  "Aux function too FREE-VARIBLES"
  (dolist (pred predl)
    (free-variables-pred pred lvars)))

(defun subquery-p (xpr)
  "Test is XPR is a bag forming expression"
  (and (listp xpr)(memq (car xpr) '(select bagof materialize))))

(defun flattensubquery (xpr &optional restype)
  "Flatten nested select expression. Generates closure"
  (let* ((xpr (if (second xpr) xpr
		;; treat select without result list as 'select TRUE ...'
		(cons (first xpr) (cons '(true) (cddr xpr)))))
         (resl (select-get xpr 'result))
         (distinct (select-get xpr 'distinct))
         (quant (substdeclarations (select-get xpr 'foreach)))
         (pred (select-get xpr 'where)))
    (if (and (null distinct)(null pred)(null quant)
	     (null (cdr resl))(subquery-p (car resl)))
        ;; bagof(bagof(x)) -> bagof(x) 
	(flattensubquery (bagof-to-select (car resl)) restype)
      (let* ((fvl (free-variables xpr nil))
	     (fv (mapcar (f/l (v) (list (binding-type (getbinding v)) v))
			 fvl))
	     (fno (createsimplederivedfunction 
		   (create-transient-object _function_) fv nil 
		   resl quant pred t))
	     (restypes (get-resolvent-restypes fno))
	     (to (make-bagtype restypes)))
	(addfunctionsusing *this-resolvent* fno)
	(set-orgcode fno fv (mapcar (function list) restypes) 
		     resl quant pred)
	(if distinct (putobject fno 'distinct t))
	(set-object-constructor fno (get-orgcode fno t))
	(list* (getobject to 'makebag) fno (getvars fv))))))

(defmacro add-parameter-assignments (andargs)
  "Flatten ANDARGS with its flat parameter assigments included"
  `(let ((pos *bindings*))
     (assigntemporaries , andargs pos t)))

(defun flattenandargs (xpr)
  "Flatten conjunction"
  (add-parameter-assignments
   (cond ((atom xpr) nil)
	 ((atom (car xpr)) (cons (car xpr) (flattenandargs (cdr xpr))))
	 ((compound-p (car xpr))
	  (selectq (caar xpr)
		   (and			; AND in AND 
		    (flattenandargs (append (cdar xpr) (cdr xpr))))
		   (or			; OR in AND
		    (cons (orify (flattenorargs (cdar xpr)))
			  (flattenandargs (cdr xpr))))
		   (optional		; OPTIONAL in AND
		    (cons (flattenoptional (car xpr))
			  (flattenandargs (cdr xpr))))
		   (error "Flattening in AND not implemented for" (caar xpr))))
	 (t (cons (flattenfuncall (car xpr) _boolean_)
		  (flattenandargs (cdr xpr)))))))

(defun flattenorargs (xpr)
  "Flatten disjunction"
  (cond ((atom xpr) nil)
	((atom (car xpr)) (cons (car xpr) (flattenorargs (cdr xpr))))
	((orp (caar xpr))
	 ;; OR in OR
	 (flattenorargs (append (cdar xpr) (cdr xpr))))
	(t (cons (andify
		  (let (new-bindings)	; New local bindings in OR clause
		    (prog1		; return flatted OR clause
			(let* ((*bindings* (copy-bindings *bindings*)) 
			       ;; new scope. POS is old environment
			       (pos *bindings*)
                               ;; PREDL is flattened body of OR clause
			       (predl (flattenpredicate (car xpr))))
			  (setq new-bindings 
				;; Newly introduced declarations in OR clause
                                (ldiff *bindings* pos))
			  ;; Initialize variables in OR clause
                          (assigntemporaries predl pos))
		      ;; Clear initializations by ASSIGNTEMPORARIES:
                      ;; Otherwise it will be doubly initialized
                      (dolist (b new-bindings)
                        (setf (binding-val b) nil))
                      ;; Add declarations of new local variables:
                      ;; Reason: IUT relies on global list of all 
		      ;; declared variables
		      (setq *bindings*;; nconc OK here since new-bindings copy
			    (nconc new-bindings *bindings*)))))
		 (flattenorargs (cdr xpr))))))

'(defun flattenoptional (xpr)
  "Flatten OPTIONAL predicates"
  (let ((pos *bindings*)(before (assigntemporaries '(true) nil nil)))
    (andify (nconc1 before 
		    (list 'optional
			  (andify (assigntemporaries 
				   (flattenandargs (cdr xpr)) pos t)))))))

(defun flattenoptional (xpr)
  "Flatten OPTIONAL predicates"
  (if (cddr xpr)(error "Only one argument allowed in optional(x)" nil)
    (let* ((pos *bindings*)
           (vars (flattenform (second xpr))))
      (list 'optional (andify (assigntemporaries  'true
						  pos t))))))

(defun copy-bindings (l)
  (mapcar
   (function
    (lambda (b)
      (make-binding
       :var (binding-var b)
       :val (binding-val b)
       :type (binding-type b)
       :notypecheck (binding-notypecheck b))))
   l))

(defun cast-to-type (casting)
  (car (internalize-nested-dcl (third casting))))

(defun cast-form? (form)
  "Test if form is parsed cast expression"
  (and (listp form)(eq (car form) 'cast)(eq (length form) 3)))

(defun osql-variablep(x)
  "If X an OSQL variable?"
  (and x (symbolp x)(not (booleanp x)) (neq x '*)))

(defun flattenform (form &optional restype)
  "Flatten query form (constant or functioncall)"
  (tuplify (flattenarglist (list form)(mklist restype))))

(defun flattencast (form casttype restype)
  "Flatten (CAST FORM TYPE)"
  (if (and (null form)(equal casttype '(boolean))) 'false
    (let* ((dcl (car (substdeclarations (list casttype))))
	   (ct (first dcl))		; cast to type OID
	   (cv (second dcl))		; cast to variable
	   (ff (flattenform form)))
      (cond ((tuplep ff)(error "Illegal cast to" casttype)))
      (addbinding cv ff ct)
      cv)))

(defun flattenfuncall (xpr &optional restype) 
  "Flatten nested function calls (f (g ..)) and typecheck"
  (if (or (osql-constantp xpr) (osql-variablep xpr)) xpr
    (let* ((fn (car xpr))
	   (args (cdr xpr)))
      (cond 
       ((not (atom fn)) (amos-error "Malformed function " fn)) ;err call
       ((eq fn 'cast)			
	;; explicit casting
	(flattencast (second xpr) (third xpr) restype))
       ((and (eq fn 'typeof) (cast-form? (second xpr)))
	;; Casting typeof
	(arg-type (flattenform (second xpr))))
       ((and (eq fn 'typesof)(cast-form? (second xpr)))
	;; casting typesof
	(flattenfuncall
	 (list 'allsupertypes (arg-type (flattenform (second xpr))))
	 restype))
       ((eq fn 'static_type) (arg-type (flattenform (second xpr))))
       ((eq fn 'bagof)			
	;; explicit bag coersion
	(flattenfuncall (list 'select args) restype))
       ((eq fn 'select)
	;;nested select stmt
	(flattensubquery xpr restype))	
       ((and (memq fn _comparisons_)
             (some (f/l(x)(and (listp x)(memq (car x) _comparisons_)))
                   args))
         (error "Nested comparisons disallowed. Use 'and' with" fn))
       ((and restype			; 1: is bag expeted result type?
	     (if (atom restype) (bag-type? restype)
	       (and (car restype)
		    (null (cdr restype))
		    (bag-type? (car restype))))
	     (not (bag-functionp fn)))	; 2: arg not bag
	;; 3: =>result needs to be coerced to bag 
	(flattenfuncall (list 'bagof xpr) restype)) 
       ((eq fn 'FLATTENED) 
	;; already flattened somewhere
	args)
       ((eq fn '=)
	;;(= attribute value)
	(flattenequality (second xpr)(third xpr)))	
       ((compound-p xpr)
	(selectq fn 
		 ;; nested AND moved to postponed expression
		 (and (addbinding nil (andify (flattenandargs args)) 
				  _boolean_) 
		      'true)
		 (or				
		  ;; nested OR is moved to postponed expression
		  (addbinding nil (orify (flattenorargs args)) _boolean_)
		  'true)
		 (optional (addbinding nil (flattenoptional xpr) _boolean_)
                           'true)
		 (error "Flattening of compound predicate not implemented" 
			fn)))
       ((dynconstructorfn fn) 
	;; constructor with variable number of arguments, e.g. VECTOR
	(flattendynconstructor fn args))
       (t (let* ((gfno (getfunctionnamed fn))
		 (cb (coerce-bag-arguments gfno args)))
	    (if cb 
		;;some argument was coerced to bag 
		(flattenfuncall cb restype)
	      (let* ((argt (all-possible-argtypes fn))
		     ;; One resolvent => list of arg types of FN
		     ;; > 1 resolvent => list of list of arg types 
		     ;; of possible resolvents of FN
		     (fargs;; assign formal arguments fargs
		      (if (eq fn 'dtr) args
			(flattenarglist args argt))))
		(cond ((and _USE_DTR_ (latebinding-reqd? gfno fargs))
		       ;;late binding by DTR required
		       (flattenlatebinding xpr fargs)) 
		      (t (let ((fno (resolveargs gfno fargs restype)))
			   ;;Not overloaded fno = most spec name
			   (if (needs-recomp? fno) 
			       ;; recompile fn and all dependents
			       (recompile_depend fno))
			   (if (not (listp fno)) 
			       (end-of-flattenfuncall fno fargs))
			   (cons (if (atom fno)
				     ;; one possible resolvent
				     (get-lbresolv-function fno fargs)
				   ;; many possible resolvents
				   (mapcar 
				    (f/l (f)
					 (get-lbresolv-function f fargs))
				    fno))
				 fargs))))))))))))

(defun bag-functionp (fn)
  "Does any resolvent of FN return a bag?"
  (isome (all-possible-resulttypes fn)
	 (f/l (rt)(and (oid-p rt)
		       (bag-type? rt)))))

(defun get-lbresolv-function (fno fargs)
  "Get the late binding resolution function for FNO with arguments FARGS"
  (let ((gfno (generic-function-of fno)))
    (if (and (not *no_lb*) 
	     (latebound? fno) 
	     (latebinding-reqd? (if _use_dtr_ fno gfno) fargs)) 
					; hack for IUT
	(get_lbex_func fno) 
      fno)))

(defun latebinding-reqd? (gfno fargs)
  "T if function GFNO applied on arguments FARGS requires late binding"
  (and (not (early-bound gfno))
       (let* ((arity (length fargs))
	      (argtypes (arglist-types fargs))
	      (rl (subset (resolvents gfno)
			  (f/l (r)
			       (let ((fnt (get-resolvent-argtypes r)))
				 (and (eq (length fnt)
					  arity)
				      (subtype-of fnt argtypes t)))))))
	 (cdr rl))))

(defun early-bound (gfno)
  "Is GFNO function which is never late bound?"
  (getobject gfno 'early-bound))

(defun set-early-bound (gfno)
  "Set flag to indicate function which is never late bound"
  (/putobject (getfunctionnamed gfno) 'early-bound t))

(defun end-of-flattenfuncall (fno fargs)
  (if (and (not (null (car *CURRENT-COMPILE-FN*))) 
	   (not (null fno))
	   (> (oid-idno fno) _system-watermark_))
      (addfunctionsusing (car *CURRENT-COMPILE-FN*) fno))
  (if _optimize-typechecking_		;Flag unnecessary type checks
      (check-typecontainer fno fargs nil)))

(defun flattenlatebinding (xpr arg)
  (let* ((argtypes (generate-argtype-list arg))
	 (rl (generate-resolvent-list 
	      (getfunctionnamed (car xpr)) argtypes))
	 (idi (addfunctionsusing (car *current-compile-fn*) 
				 (getfunctionnamed (car xpr))))
	 (srl (sort-resolvent-list rl))
	 (mg (car (last srl))))
    (if (subtype-of (get-resolvent-argtypes mg) argtypes)
        (amos-error "Function " (car xpr) " not defined for " 
		    argtypes)
      (cons *_dtrfunction_* (cons srl arg)))))

(defun generate-argtype-list (arg)
  (mapcar (function arg-type) arg))

(defun sort-resolvent-list (resl)
  (csort resl (f/l (x y) (subtype-of (get-resolvent-argtypes x)
				     (get-resolvent-argtypes y)))))

(defun generate-resolvent-list (genfn fargt)
  "Generates a list of all resolvents of genfn that is in the dynamic
   type set of the type fargt"
  ;;Type equality is set to true if any of the resolvents have the same type 
  ;;as argt. If not a resolvent that is a supertype of fargt must be added 
  ;;to the set since that resolvent applies to all instances of type fargt. 
  ;;Dyntypeset is achieved by taking all resolvents not in validresolvents 
  ;;and filter out all resolvents not supertypes of fargs. From that set 
  ;;the most specific resolvent is extracted and added to validresolvents
  (let* (type-equality
	 (resolvents (resolvents genfn))
	 (resolventargtypes (mapcar (f/l (x)(cons (get-resolvent-argtypes x) 
						  x)) 
				    resolvents))
	 (validresolvents (mapfilter 
			   (f/l (x) (if (equal  (car x) fargt) 
					(setq type-equality t)
				      (subtype-of (car x) fargt)))
			   resolventargtypes (function cdr)))
	 (resolventset 
	  (if type-equality validresolvents
	    (let ((additionals 
		   (mapfilter 
		    (f/l (x) (and (subtype-of 
				   fargt 
				   (get-resolvent-argtypes x)) 
				  x))
		    (set-difference resolvents validresolvents))))
	      (if (null additionals) validresolvents
		(cons (most-spec-resolvnt additionals) validresolvents))))))
    resolventset))

(defun unambigous-restypes (restypes)
  ;; RESTYPES is either list of expected result types OR list of list of 
  ;; possible result types
  (and (listp restypes)(not (listp (car restypes)))))

(defun flattenarglist (l restypes)
  (if (atom l) nil
    (do* ((args l (cdr args))
	  (rstys restypes
		 (if (unambigous-restypes rstys) (cdr rstys)
		   (mapcar (function cdr) rstys))) 
					;traverse the possible type lists
	  (rsty (cond ((null (cdr args)) rstys) ;no ambig
		      ((unambigous-restypes rstys) 
		       (list (car rstys)))
		      (t (mapcar (f/l (x) (list (car x))) rstys))) 
					;generate list of possible types
		(cond ((unambigous-restypes rstys) 
		       (list (car rstys)))
		      (t (mapcar (f/l (x) (list (car x))) rstys))))
	  (nf (if (no-fn args) nil (flattenfuncall (car args) rsty)) 
              (if (no-fn args) nil (flattenfuncall (car args) rsty)))
	  (rt (if (unique-fn nf)(function-resulttypes nf) 'non-unique)
              (if (unique-fn nf)(function-resulttypes nf) 'non-unique))
	  (flag (if (no-fn args) nil (eq rt 'non-unique))
		(or (if (no-fn args) nil (eq rt 'non-unique)) flag))
	  (rest (if rt (next-restype restypes nf) _boolean_)
		(if rt (next-restype rest nf) _boolean_))
	  (tpr (make-flat-arglist args nf rt)
               (make-flat-arglist args nf rt))
	  (result tpr
		  (append result tpr)))
	((null (cdr args)) 
	 (if flag (fix-flattenedarglist result rest) result)))))

(defun next-restype (restypes nf)
  (let* ((rest (cond ((not (unique-fn nf)) restypes)
		     ((null restypes) nil)
		     ((and (listp restypes) (cdr restypes))
		      (cdr restypes))
		     (t restypes)))
	 (t1 (if (and (listp rest)(atom (car rest)))
                 (gettypenamed (car rest) t) nil))
	 (t2 (if (unique-fn nf) (car (function-resulttypes nf)) nil))
	 (types? (and t1 t2))
	 (result (cond (types? (cond ((subtype-of t1 t2) t1)
				     ((subtype-of t2 t1) t2)
				     (t rest)))
		       ((and (not (unique-any rest)) nf)
			(intersection rest (all-possible-resulttypes nf)))
		       (t rest))))
    result))

(defun make-flat-arglist (l nf rt)
  (cond 
   ((or (atom (car l))
	(osql-constantp (car l)))
    (checkbinding (car l)) 
    (list (car l)))
   ((not (unique-fn nf)) 
    (if (no-fn l)(list (car l))
      (list nf)))
   ((atom nf) (list nf))
   (rt	
    (cond ((and (unique-fn nf)(cdr rt)) ;There can be several in nf
	   (if (cdr l)
	       (amos-error 
		"More than one tuple result function selected: " 
		(externalize-form (car l))))
	   (let ((v (cons _tupletag_ (mapcar (function dt_genvar) rt))))
	     (addbinding v nf (cons _tupletag_ rt)) 
	     (add-bindings-separately (cdr v) rt)
	     (cdr v)))
	  (t (list (addbinding (genvar) nf (car rt)) ))))
   (t					; Boolean fns have no result!
    (let ((v (genvar)))
      (addbinding v nf _boolean_) 
      (list v)))))

(defun fix-flattenedarglist (result rest)
  (if (null rest) result
    (let ((res (mapcar 
		(f/l (x)
                     (if (and (listp x) (listp (car x))) ;non unique function
			 (make-expr
                          (mapfilter 
			   (f/l (y) 
				(if (and (listp rest)(listp (car rest)))
                                             ;;;rest>1
				    (append (map-over-types y rest) (cdr x)) 
				  (let ((fnrest (function-resulttype y)))
                                    (or (equal fnrest (car rest))
                                        (subtype-of (car rest) fnrest))))) 
			   (car x)) 
                          (cdr x));;second arg to make-expr
		       x))		;return value if unique function
		result)))
      res)))

(defun coerce-eq-to-in (fnc xpr)
  "Warn that (= (IN X) Y) <-> (= X Y)"
  (if (and _strict-in_
           (consp xpr)
           (neq (car xpr) 'in)
           (consp fnc)
           (oid-p (car fnc))
           (has-bagged-result (car fnc)))
      (amos-warning "Equality on bag valued function " 
		    (generic-fnname (car fnc)) 
		    " treated as 'in' operator"))
  fnc)

(defun flattenequality (lhs rhs)
  "Flatten general AMOSQL expression LHS = RHS"
  (cond ((simpleexpr lhs)
	 (cond ((simpleexpr rhs) (flattensimpleeq lhs rhs)) ; v = u 
	       (t (flattensimpleeq 
		   lhs 
		   (coerce-eq-to-in
		    (flattenfuncall 
		     rhs		; v = f(...)
		     (mapcar (function arg-type) 
			     (argsof _tupletag_ lhs)))
		    rhs)))))
	((simpleexpr rhs)		; f(...)=v swap to v = f(...)
	 (flattenequality rhs lhs))
	(t (let* ((rhs (flattenfuncall rhs)) ; f(...) = g(...)       
		  (rt (all-possible-resulttypes rhs))
		  (eqtype (cond ((cdr rt) ; width of rhs > 1
				 (maketuple
				  (mapcar
				   (f/l (rte)
					(let ((v (genvar)))
					  (addbinding v nil rte) v))
				   rt)))
				(t (addbinding (genvar) nil (car rt))))))
	     (addbinding eqtype (flattenfuncall lhs) rt) 
					; bind EQTYPE to LHS
	     (flattensimpleeq eqtype rhs))))) ; flatten EQTYPE = RHS

(defun flattensimpleeq (x y)
  "Flattens U = V or <...> = <...>"
  (cond ((and (atom x)(atom y))
	 (cond  ((equal x y)  'true)
                (t (list _=_ x y))))
	((and (tuplep x) (tuplep y))
	 (cond  ((not (= (length x) (length y)))
		 (error "Width mismatch" (externalize-form x)))
                (t (flattenfuncall 
		    (andify (mapcar (function flattenequality)
				    (cdr x)(cdr y)))))))
        ((and (atom y)(tuplep x)) (flattensimpleeq y x))
        ((and (atom x)(tuplep y))
	 (cond ((osql-subtypep (arg-type x) _vector_);; coerce to vector
		(list* _vector-constructor_  x (flattenarglist (cdr y) nil)))
               ((osql-subtypep (arg-type x) _tuple_);; tuple construction
                (list* _tuple-constructor_ x (flattenarglist (cdr y) nil)))
	       (t  (error "Illegal tuple assignment" 
			  (externalize-form x)))))
	(t (let ((x (if (tuplep x)	
			;; flatten tuple arguments too
			(cons _tupletag_ 
			      (flattenarglist (argsof _tupletag_ x) nil))
		      x)))
	     (and _optimize-typechecking_ (consp y) 
		  (check-typecontainer (car y)(cdr y)   
				       (argsof _tupletag_ x)))
	     ;;Adjust the return of external application according 
             ;;to the result!
	     (cond ((not(simpleexpr y))
		    (let* ((rt (function-resulttypes y t))
			   (tup (maketuple 
				 (mapcar 
				  (function (lambda (rte)
					      (addbinding (genvar) nil rte)))
				  rt))))
		      (addbinding tup y rt)
		      (flattensimpleeq x tup)))
		   (t (list _=_ x y)))))))

(defun externalize-form (x)
  (cond ((osql-constantp x)(stringify-amos-object x))
        ((symbolp x)
         (let ((y (and (getbinding x)(binding-val (getbinding x))))) 
	   (if y (externalize-form y) x)))
        ((atom x) x)
        ((tuplep x)(stringify-amos-object x))
	(t (mkfunsig (car x) "," (cdr x) nil))))

; Gustav Fahl 930403
; The user can set the property TYPECONTAINER of a foreign predicate object
; to T. By doing this, he guarantees that the predicate can not return objects
; of the wrong type (i.e. the predicate is a 'typecontainer'). The system
; then treats the predicate in the same way as a stored predicate, and an
; unnecessary type check is avoided.
; The parser should be extended to accept, e.g.:
; create function foo(integer i)->real r as foreign 
;    typecontainer 'integer.foo;

(defun check-typecontainer (fno argl resl)
  (cond
   ((and (foreign-predicatep fno)	; CHANGED!
	 (not (typecontainer-p fno)))	; CHANGED!
    nil)
   ((dynconstructorfn fno)
    (check-typecontainer1 (list (gettypenamed (oid-name fno)))
			  resl))
   (t (if argl 
	  (check-typecontainer1 
	   (get-resolvent-argtypes fno)
	   argl))
      (if resl 
	  (check-typecontainer1 
	   (get-resolvent-restypes fno)
	   resl)))))

(defun check-typecontainer1 (types argl)
  (mapc (function (lambda (tpo a)
		    (and (osql-variablep a)
			 (let ((bnd (getbinding a)))
			   (and bnd (osql-subtypep tpo (binding-type bnd))
				(setf (binding-notypecheck bnd) t))))))
	types argl))

(defun typecontainer-p (fp)
  (or (getobject fp 'typecontainer)
      (dynconstructorfn fp)))

(defun set-type-container (fno)
  (dolist (f (resolvents (getfunctionnamed fno)))
    (/putobject f 'typecontainer t))
  fno)

(defun flattenpredicate (xpr)
  (cond ((null xpr) nil)
	((atom xpr) 
	 (checkbinding xpr)
	 (list xpr))
	(t (let ((temp (car xpr)))
	     (cond ((andp temp)
		    (flattenandargs (cdr xpr)))
		   ((orp temp)
		    (list (orify (flattenorargs (cdr xpr)))))
		   (t (list (flattenfuncall xpr _boolean_))))))))
