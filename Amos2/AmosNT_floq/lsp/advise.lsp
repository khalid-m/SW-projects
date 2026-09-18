;;; =============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Tore Risch, UDBL
;;; $RCSfile: advise.lsp,v $
;;; $Revision: 1.9 $ $Date: 2011/12/21 20:59:36 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic aspect oriented programming hook (advise)
;;; =============================================================

;;; This is a rudementary but most general part of ADVISE in Interlisp,
;;; the origin of aspect oriented programming.
;;; This file can be loaded into a naked Amos II first in the boot process.
;;; This is required since several other basic system packages 
;;; depend on ADVISE.

(defglobal _not-wrappable_ 
  '(car cdr cons atom quote cond if apply int-while pop
	setq equal eq null and resetvar selectq unwind-protect progn
        princ terpri prin1 spaces rptq formatl catch
        trace-enter trace-return list* print-parameters
	consp or and)
  "Not wrappable functions")

(defun lambdap (l)
  "Is L lambda?"
  (and (listp l) (eq (car l) 'lambda)))

(defun extfnp (x)
  "Is X an external function identifier?"
  (eq (typename x) 'extfn))

(defun wrap-put (brf make-wrap &optional novirgin)
  "Wraps FN function using MAKE-WRAP function.
   Is to be used for trace and break functions.
   Stores old def under property 'virginfn unless NOVIRGIN not NIL."
  ((lambda (fn)	;;; let not defined yet so we use open lambdas instead
     (if (memq fn _not-wrappable_)
	 (error "Cannot wrap" brf)
       ((lambda (def virgin
		     islambda isspecial
		     body orgbody fnargs precond)
	  (or virgin (setq virgin def))
	  (setq islambda (cond ((lambdap def) t)
			       ((extfnp def) nil)
			       (t (error "Cannot wrap" fn))))
	  (setq orgbody (cond (islambda (prognify (cddr def)))
			      (isspecial (list 'cons def '!args))
			      (t (list 'apply virgin '!args))))
	  (if islambda (setq fnargs (listoffnargs (cadr def))))
	  (setq body (apply 
		      make-wrap		; should return forms
		      (list fn orgbody
			    (if islambda (cons 'list* fnargs)
			      '!args))))
	  (symbol-setfunction
	   fn
	   (nconc2 
	    (list 'lambda (if islambda (cadr def) '(&rest !args)))
	    (cond ((atom brf) body)
		  (t (setq precond (cadr brf)) ; conditional wrap
		     `((cond 
			(,@ (cons (cond ((null islambda)
					 (list 'apply (list 'function precond) 
					       '!args))
					((not (memq nil fnargs)) 
					; &rest lambda list
					 (list 'apply (list 'function precond)
					       (cons 'list* fnargs)))
					(t (cons precond
						 (butlast fnargs))))
                                   
				  body))
			(t , orgbody))))))
	   (or isspecial (macro-function fn)))
	  (or novirgin (putprop fn 'virginfn virgin))
	  fn)
	(symbol-function fn)
	(getprop fn 'virginfn)
	nil
	(special-operator-p fn)
	nil nil nil nil)))
   (car (mklist brf))))

(defun advise-around (fn code &optional novirginfn)
  "Wrap body of FN with CODE where each * is replaced with original body of FN"
  (wrap-put fn 
	    #'(lambda (fn body params)
		(list (subst body '* code))) 
	    novirginfn))

(defun listoffnargs (argl)
  "Make actual arguments constructing argument list of wrapped function"
  (cond ((atom argl) '(nil))
	((eq (car argl) '&optional) (listoffnargs (cdr argl)))
	((eq (car argl) '&rest) (list (cadr argl)))
	(t (cons (car argl)
		 (listoffnargs (cdr argl))))))

(defun arglist (fn)
  "Get the argument list of FN for wrapping it"
  (if (lambdap (getd fn))(remove nil (listoffnargs (cadr (getd fn))))
    '(!args)))

(defun unwrap-fn (fn)
  "Unwrap a wrapped function"
  ((lambda (ub)
     (cond (ub (remprop fn 'virginfn)
	       (symbol-setfunction fn ub (macro-function fn))
	       fn)
	   (t (list fn "not wrapped"))))
   (getprop fn 'virginfn)))
