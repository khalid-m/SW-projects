;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Tore Risch, Magnus Werner, EDSLAB
;;; $RCSfile: error.lsp,v $
;;; $Revision: 1.28 $ $Date: 2014/01/12 16:52:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Handling basic Lisp errors.
;;; =============================================================

(defglobal _batch_ nil 
  "Enable batch behavior of errors where backtraces are printed
   in debug mode, rather than entering the break loop")

(defglobal _error-condition_ nil "Latest error condition")

(defglobal _catch-errors_ nil "Is error reporting trapped?")

(defglobal _debugging_ nil "Is Lisp debug mode enabled?")

(defvar *within-lisp* t "This code is running in Lisp mode")

(defvar *object-printer* 'prin1 
  "Function to print object when not running in Lisp mode")

(defmacro on-error (form cleanup)
  "Evaluate FORM and evaluate CLEANUP if error occurred"
  `(let (__ok)(unwind-protect 
		  (prog1 ,form (setq __ok t))
		(or __ok ,cleanup))))

(defmacro catch-error (form &rest cleanup)
  "Evaluate FORM and catch all errors.
   Optional CLEANUP form called if error caught"
  `(catch 'error 
     (on-error (resetvar _catch-errors_ t ,form) ,(prognify cleanup))))

(defmacro undo-at-error (&rest forms)
  "Evaluate FORMS and undo database updates if error occurred"
  `(let ((savepoint _history_))
     (on-error ,(prognify forms) (history-rollback savepoint))))

(defun make-errcond (no msg obj)
  "Construct new error condition"
  (list :errcond (list no msg obj)))

(defun errcond-number (errcond)
  "Get number of error condition"
  (car (getf errcond :errcond)))

(defun errcond-msg (errcond)
  "Get message of error condition"
  (cadr (getf errcond :errcond)))

(defun errcond-arg (errcond)
  "get argument of error condition"
  (caddr (getf errcond :errcond)))

(defun errcond-raise-error (errcond form)
  "Explicitly raise the error specified by an error condition descriptor"
  (faulteval (first errcond)(second errcond)(third errcond) form nil))

(defun errcond-print-error (errcond &optional stream)
  "Print the error message of an error condition"
  (apply (f/l (no msg obj)
	      (cond (no
                     (cond
                      ((and (eq no 1)(getprop obj 'interfacevar))
		       ;; Nicer error message
                       (setq no -1)
                       (setq msg "Unbound interface variable")
                       (setq obj (getprop obj 'interfacevar))))
		     (cond 
                      ((not (eq no -1)) ; Error -1 => unnumbered error
		       (princ "Error " stream)
		       (princ no stream)
                       (princ ", " stream)))
		     (princ msg stream)
		     (cond ((or obj (neq no -1))
			    (princ ": " stream)
                            (if *within-lisp* (prin1 obj stream)
			      (funcall *object-printer* obj stream))))
		     (terpri stream)
		     )))
	 (error? errcond)))

(defmacro errstring (form)
  "Return the error message string if evaluation of FORM failed"
  (list 'errcond-msg (list 'catch-error form)))

(defc 'faulteval;; use DEFC to avoid REDEFINED warning
  '(lambda (_errno_ _errmsg_ _errobj_ _errform_ _env_)
     "This function is called by system whenever error detected"
     (setq _error-condition_ (make-errcond _errno_ _errmsg_ _errobj_))
     (indicate-error _errno_ _errmsg_ _errobj_);; Indicate to C error mgmt.
     (cond 
      ((and _catch-errors_ (not (equal _errmsg_ "Stack overflow")))
       	      (throw 'error _error-condition_))
      (t (errcond-print-error _error-condition_)
	 (cond (_debugging_
		(princ "When evaluating: " t)
		(print _errform_ t)))))
     (cond (_batch_ (backtrace nil _env_ t)
                    (c-backtrace)
                    (reset))
	   ((null _debugging_)(reset))
           (t
	    (open-breakloop 'faulteval _errform_ 
			    (list _errno_ _errmsg_ _errobj_ _errform_) _env_
			    '(_errno_ _errmsg_ _errobj_ _errform_ nil))))))
