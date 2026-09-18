;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: optnull.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/12/30 19:53:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Nulls in results and correct 'set' functionality
;;; =============================================================
;;; $Log: optnull.lsp,v $
;;; Revision 1.1  2013/12/30 19:53:30  torer
;;; Extended function updates with 'set'
;;; optnull() option is select clauses
;;;
;;; =============================================================

(mapc 'defc '(compile-syscall-where flattenfuncall))

(defglobal _enable-optnull_ t "Enable notnull(x) in select clauses")

(defun compile-syscall-where (lfn fn argl rest enclfn &optional remflg group)
  "Compile general add/set/remove with from or where clause"
  (if (and (null (cdr rest))
           (every-simplep argl)
           (every-simplep (car rest)))
      (compile-syscall lfn fn argl (car rest))
    (apply 
     (function 
      (lambda (distinct resl into foreach where)
	(let ((where+ 
	       (cond ((or (not remflg)(null(cdr rest))) where)
					;no updates with quantified variables
		     ((null where) `(= ,(tuplify (car rest))
                                       (in (bagof,(cons fn argl)))
				       ))
		     (t `(and ,where 
			      (= ,(tuplify (car rest))
                                 (in (bagof ,(cons fn argl)))
				 ))))))
          (and group _enable-optnull_
              (setq resl (mapcar (f/l (x)(list 'optnull x)) resl)))
	  (if *within-proc* 
	      (let ((*vardeclarations* (append (substdeclarations foreach)
					       *vardeclarations*)))
		(list 'compiled-update-where lfn 
		      (resolve-callinproc 
		       (list (cons fn argl))
		       nil enclfn)
		      (length argl)
		      (append argl resl)
		      foreach where+
                      (if group (length argl) 'copy))) 
	    `(update-where 
	      (function ,(interpreted-updatefn lfn))
	      ,(kwote fn)
	      ,(length argl)
	      ,(compile-substosqlvars (append argl resl))
	      ,(kwote foreach)
	      ,(compile-substosqlvars where+))))))
     (parseselect rest '(foreach where)))))

(defun flatten-optnull (xpr restype)
  "Flatten optnull(x) expressions"
  (let* ((pos *bindings*)
	 (vars (flattenform (second xpr) restype))
         (opt (list 'optional
		    (andify (assigntemporaries nil pos t)))))
    (addbinding nil opt _boolean_)
    vars))

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
       ((eq fn 'optnull)(flatten-optnull xpr restype))
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


(foreign-lispfn enable_dt ((boolean flg))()
		"Enable derived types without optional"
		(cond ((is-true flg)
                       (/setglobal '_enable-optnull_ nil)
		       (osql-result flg))
		      (t (/setglobal '_enable-optnull_ t))))

(advise-around 
 'create-derived-type 
 '(if _enable-optnull_ 
      (error "Derived types not supported")
    *))