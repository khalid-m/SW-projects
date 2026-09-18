;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Tore Risch, UDBL
;;; $RCSfile: verify_code.lsp,v $
;;; $Revision: 1.27 $ $Date: 2012/02/22 09:25:12 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Verification of correctnes of Lisp code
;;; ===========================================================================

(defvar *verify-fndefined* nil "Verify that called functions are defined")
(defvar *verify-immediate* nil "Verify new defined functions immediately")

;;;; Entries:

(defun verify-fndef (fn &optional errorfn)
  "Entry to VERIFY: Verify that a Lisp function has correct definition"
  (let ((errfn (or errorfn (function verify-print-message))))
    (if (getprop fn 'redefined)
	(funcall errfn "WARNING! Redefined function: " fn))
    (if (debugging-enabled) (verify-function (getd fn) errfn fn))))

(defun verify-all (&optional errorfn)
  "Entry to VERIFY: Verify that all Lisp functions in image correct"
  (let ((*verify-fndefined* t) problem 
        (errfn (or errorfn (function verify-print-message))))
    (cond ((debugging-enabled)
	   (mapfunctions 
	    (f/l (fn) 
		 (verify-fndef fn 
			       (f/l (&rest l) 
				    (setq problem t)
				    (apply errfn l)))))
	   (not problem))
          (t t))))


;;;; Verification rules

(defglobal _form-validation-rules_
  '(
    ( (append (list *) *)
      "Use (cons x y) instead of (append (list x) y)")
    ( (intfuncall (quote . *) . *) 
      "Suspicious use of QUOTE rather than FUNCTION: " (cadr form))
    ( (quote (lambda . *) . *)
      "Suspicious use of QUOTE rather than FUNCTION: " form)
    ( (lambda . *) 
      "Suspicious use of LAMBDA as function: " form)
    ( (setq * (f/l . *))
      "Circular closure. Memory leak: " form)
    ( (setq * (function (lambda . *)))
      "Circular closure. Memory leak: " form)
    ) 
  "Rules for verifying Lisp forms")

;;;; Internal functions:

(defun verify-print-message (&rest l) (formatl t (apply 'concat l) t))

(defun fndef-eq (def fn)
  "Is DEF call to FN?"
  (or (eq def fn)
      (eq def (getd fn))
      (eq def (virginfn fn))))

(defun verify-form (form errorfn tag &optional bound)
  "Verify Lisp form"
  (let ((next form))			; for recursion removal
    (while next
      (setq form next)
      (setq next nil)
      (if (atom form)
	  (or (not (symbolp form))
	      (keywordp form)
	      (kwoted form)
	      (special-variable-p form)
	      (global-variable-p form)
	      (memq form bound)
	      (funcall errorfn "Undeclared free variable " form 
		       " in " tag))
	(let* ((fn (car form))
	       (def (get-fnindicator fn)))
          (dolist (rule _form-validation-rules_)
	    (cond ((and (symbolp fn);; for speed
                        (string-like (caar rule) fn);; for speed
                        (match-form (car rule) form))
		   (apply errorfn 
			  (nconc (mapcar (function eval) (cdr rule))
				 (list " in " tag))))))
	  (cond ((fndef-eq def 'cond)
		 (mapc (f/l(x)
			   (cond ((and (atom x) x)
				  (funcall errorfn "Malformed COND in " tag))
				 (t (verify-forms x errorfn tag bound))))
		       (cdr form)))
		((fndef-eq def 'function)
		 (verify-function (cadr form) errorfn tag bound))
                ((fndef-eq def 'quote) nil)               
		((or (fndef-eq def 'defun)
		     (fndef-eq def 'defmacro))
		 (verify-function (cons 'lambda (cddr form))
				  errorfn (cadr form) nil))    
                ((fndef-eq def 'resetvar)
		 (verify-form (caddr form) errorfn tag bound)
		 (verify-form (cadddr form) errorfn tag (cons (cadr form)
							      bound)))
		((fndef-eq def 'selectq)
		 (verify-form (cadr form) errorfn tag bound)
		 (mapl (f/l (tl)
			    (if (cdr tl) 
				(verify-forms (cdar tl) 
					      errorfn tag bound)
			      (verify-form (car tl) errorfn tag bound)))
		       (cddr form)))
                ((fndef-eq def 'checkequal)
                 (dolist (p (cddr form))
                   (verify-form (car p) errorfn tag bound)
                   (verify-form (cadr p) errorfn tag bound)))
                (t (let ((r (catch-error 
			     (macroexpand form))))
		     (cond ((error? r) 
			    (funcall errorfn "Macro expansion fails for" 
				     form " with error '" (errcond-msg r) 
                                     ": " (errcond-arg r)
				     "' in " tag))
			   ((eq r form)
			    (verify-function fn errorfn tag bound)
			    (verify-call fn (cdr form) errorfn tag)
                            (setq next (cdr form))
                            (while (consp(cdr next))
			      (verify-form (pop next) errorfn tag bound))
                            (setq next (car next))) ; tail form in call
			   (t (setq next r)))))))))))

(defun verify-function (fn errorfn tag &optional bound)
  "Verify called function"
  (cond ((atom fn) fn)
	((lambdap fn)
         (let ((locals (delete nil (listoffnargs (cadr fn)))))
           (verify-locals locals errorfn tag)
	   (verify-forms
	    (cddr fn)
	    errorfn tag
	    (union locals bound))))
	(t (funcall errorfn "Malformed function in " tag " : "fn))))

(defun special-variable-name (var)
  (let* ((vs (mkstring var))
         (vl (length vs)))
    (and (eq (string-pos vs "*")0)
	 (equal (substring (1- vl) vl vs) "*"))))
  
(defun verify-locals (vars errorfn tag)
  (dolist (v vars)
    (cond ((and (special-variable-name v)
		(not (special-variable-p v)))
	   (funcall errorfn "Local variable should be declared DEFVAR: " v 
		    " in " tag))
	  ((or (memq v '(t nil))(not (symbolp v)))
           (funcall errorfn "Illegal local variable: " v " in " tag)))))

(defun verify-forms (argl errorfn tag &optional bound)
  "Verify list of forms"
  (mapc (f/l (f)(verify-form f errorfn tag bound)) argl))

(defun get-fnindicator (fn)
  "Get function definition in function call"
  (cond ((lambdap fn) fn)
	((extfnp fn) fn)
	((symbolp fn)(getd fn))))

(defun verify-call (fn args errorfn tag)
  "Verify function call arguments"
  (let ((def (get-fnindicator fn))) 
    (cond ((lambdap def)
	   (verify-actargs fn (cadr def) args errorfn tag))
	  ((and *verify-fndefined* (null def))
	   (funcall errorfn "Call to undefined function " fn 
		    " in " tag ".")))))

(defun verify-actargs (fn formargs actargs errorfn tag)
  "Verify that actual arguments match function arglist"
  (cond ((null (or formargs actargs)))
	((null formargs) (funcall errorfn 
				  "Too many arguments when calling " fn
				  " in " tag "."))
	((memq (car formargs) '(&optional &rest)))
	((null actargs) (funcall errorfn 
				 "Too few arguments when calling " fn
				 " in " tag "."))
        (t (verify-actargs fn (cdr formargs)
			   (cdr actargs) errorfn tag))))

(defun match-form (pat form)
  "Does pattern PAT match FORM?"
  (cond ((eq pat '*) t)
        ((and (symbolp form) (symbolp pat)) (string-like form pat))
        ((and (stringp form) (stringp pat)) (string-like form pat))
	((atom pat)(equal pat form))
	((not (consp pat)) nil)
	((consp form)(and (match-form (car pat)(car form))
			  (match-form (cdr pat)(cdr form))))))

(defun match-somewhere (pat l)
  "Does pattern PAT match some form in L?"
  (cond ((match-form pat l) t)
	((consp l) (or (match-somewhere pat (car l))
		       (match-somewhere pat (cdr l))))))

;;; Incremental code verification in debug mode when *verify-immediate* is true

(defun verify-fndef-conditionally (fn)
  "DEFMACRO and DEFUN are verified immediately if 
   *VERIFY-IMMEDIATE* if true and DEBUGGING is turned on"
  (and *verify-immediate* 
       _debugging_ 
       (debugging-enabled) 
       (verify-fndef fn)) 
  (if _release_ (remove-master-comment fn))
  fn)

(advise-around 'defun
	       '(list 'verify-fndef-conditionally *))
(advise-around 'defmacro
	       '(list 'verify-fndef-conditionally *))


