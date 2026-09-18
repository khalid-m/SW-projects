;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Tore Risch, Timour Katchaounov, UDBL
;;; $RCSfile: ref_lisp.lsp,v $
;;; $Revision: 1.50 $ $Date: 2012/03/21 19:38:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: ALISP cross-reference functions.
;;; ===========================================================================

(defun mksymbol1 (x) (if (equal x "") nil (mksymbol x)))

(defun map-symbols-in-list (s ht fn)
  (cond ((gethash s ht) nil)
        ((consp s)
	 (dolist (x s)
	   (map-symbols-in-list x ht fn)))
        ((symbolp s)
	 (setf (gethash s ht) t)
	 (funcall fn s))
        (t nil)))

(defun ppf-string (fns) 
  "Returns a pretty-printed string with the function definitions and 
   global variable values"
  (let (def
	(str (maketextstream)))
    (unwind-protect
	(dolist (fn (mklist fns))
	  (cond ((setq def (getd fn))
		 (if (atom def)
		     (pps (list 'defc (kwote fn) (kwote def)) str)
		   (pps (list* (if (macro-function fn) 'defmacro 'defun)
			       fn (cdr (virginfn fn))) str)))
		((special-variable-p fn)
		 (if (boundp fn)
		     (pps (list 'defvar fn (kwote (symbol-value fn))) str)
		   (pps (list 'defvar fn) str)))
		((or (global-variable-p fn) (boundp fn))
		 (if (boundp fn)
		     (pps (list 'defglobal fn (kwote (symbol-value fn))) str)
		   (pps (list 'defglobal fn) str)))
		(t (error "Undefined symbol" fn))))
      (closestream str))
    (textstreamstring str)))

(defun documentation (sym)
  "Return the documentation string of a lisp symbol"
  (let* ((symbol (mksymbol1 sym))
	 (symdef (virginfn symbol)))
    (or					; functions, macros
     (if (consp symdef)
	 (let ((doc (third symdef)))
	   (if (stringp doc) doc)))
     (getprop symbol 'documentation))))

(defmacro document (&rest docs)
  "Convenience macro for documenting Lisp symbols"
  (and (not _release_)
       (do ((d docs (cddr d)))
	   ((null d) nil)
	 (if (consp (car d))
	     (putprop (caar d) 'documentation (list (car d)(cadr d)))
	   (putprop (car d)'documentation (cadr d))))))

(defun grep-command (pat file)
  "What lines in what files have given string? Borland grep."
  (concat "grep -r -n -o -e \"" pat "\" " file))

(defun apropos (str)
  "If STR is symbol: Print documentation of symbols containing STR.
   If STR is string: Print documentation of symbols whose master
                     comments contain STR"
  (let ((pat (concat '* str '*))
        doc)
    (mapsymbols 
     (f/l (s)
          (if (if (symbolp str)(string-like s pat)
		(or (and (listp (setq doc (documentation s)))
			 (isome doc (f/l (d)(string-like-i (mkstring d) pat))))
		    (and (stringp doc)(string-like-i doc pat))))
	      (doc s))))))

(defun doc (s)
  "Print documentation associated with symbol S"
  (cond ((symbolp s)
	 (cond ((special-variable-p s)
		(formatl t t s " Special variable" t))
	       ((global-variable-p s)
		(formatl t t s " Global variable" t))
	       ((neq (symbol-value s) 'nobind)
		(formatl t t s " Undeclared global variable" t))
	       ((macro-function s)
		(terpri)
		(or (fp s)(print s))
		(formatl t "   (defmacro " s " " (cadr (getd s)) "...)" t))
	       ((lambdap (getd s))
		(terpri)
		(or (fp s)(print s))
		(formatl t "   (defun " s " " (cadr (getd s)) "...)" t))
	       ((special-operator-p s)
		(formatl t t s " Special operator" t))
	       ((getd s)
		(formatl t t s " EXTFN" t)))
	 (let ((doc (documentation s)))
	   (cond ((null doc) nil)
		 ((consp doc)(dolist (d doc)
			       (spaces 3)
			       (princ d) (terpri)))
		 (t (spaces 3)
		    (princ doc) (terpri))))))
  s)
   
(defun grep (string)
  "Find Amos II source files where STRING occurs"
  (dolist (f *loaded-files*)
    (system (grep-command string f))))

(defun fp (artefact &optional stream)
  "Print file position of definition of Alisp ARTEFACT"
  (let ((pos  (getprop artefact 'filepos)))
    (cond (pos (formatl stream artefact " " (car pos) " " (cdr pos) t) 
	       t)
          (t (formatl stream artefact " file position unknown" t) t))))

(defun calling (fn &optional depth file)
  "Print file positions of Lisp functions calling FN"
  (cond ((null (getd fn)) (error "Not a Lisp function" fn))
        ((or (null depth)(<= depth 1)) (using fn))
        (t (print-calling-structure fn depth 
				    (make-function-index t) 
				    "<- " file))))

(defun calls (fn &optional depth file)
  "Print file positions of Lisp functions called by FN"
  (cond ((or (null depth)(<= depth 1))
         (mapc (function fp) (functions-called-by fn)))
        (t (print-calling-structure fn depth 
				    (make-function-index nil) 
				    "-> " file))))
(defvar *lineno*)
(document *lineno* "Internal variable for cross reference printing")

(defun print-calling-structure (fn depth index indenter file)  
  "Helping function to to print function calling structure"
  (let ((*lineno* 0))
    (with-output-file stream file 
		      (calling-structure1 fn index (make-hash-table)
					  0 depth indenter stream))))

(defun calling-structure1 (fn calling been depth maxdepth indenter stream)
  "Helping function to to print function calling structure"
  (cond ((> depth maxdepth) nil)
        ((gethash fn been)
	 (fp-function fn depth indenter nil stream)
	 (formatl stream " :" (gethash fn been) t))
	((fp-function fn depth indenter t stream)
	 (setf (gethash fn been) *lineno*)
	 (dolist (fnc (gethash fn calling))
	   (calling-structure1 fnc calling been
			       (1+ depth) maxdepth indenter stream)))))

(defun fp-function (fn depth indenter fpflg stream)
  "Helping function to to print function calling structure"
  (cond ((null (lambdap (getd fn))) nil)
	(t (formatl stream ":" (1++ *lineno*))
	   (cond ((<= depth 0) (spaces 1))
		 (t (spaces (* 2 depth) stream)
		    (princ indenter stream)))
	   (unless (and fpflg (fp fn stream))
	     (formatl stream fn " " (lisp-function-type fn))
             (and fpflg (terpri stream))
	     t)
           t)))

(defun functions-called-by (fn)
  "Returns a list of functions called by FN"
  (if (null (getd fn)) (formatl t fn " is not a function" t)
    (let ((ht (make-hash-table)) 
	  res)
      (map-symbols-in-list (getd fn) ht
			   (f/l (fnc)(and (getd fnc)(push fnc res))))
      res)))

(defun make-function-index (upflg)
  "Builds a function call index or called-by index if UPFLG"
  (let ((ht (make-hash-table)))
    (mapfunctions 
     (f/l (fn)
	  (dolist (fnc (functions-called-by fn))
	    (if upflg (setf (gethash fnc ht)
			    (adjoin fn (gethash fnc ht)))
              (setf (gethash fn ht)
		    (adjoin fnc (gethash fn ht)))))))
    ht))

(defun lisp-function-type (fn)
  "The kind of function of FN"
  (let ((fnd (getd fn)))
    (cond ((null fnd) (error "Not a Lisp function" fn))
          ((macro-function fn) 'macro)
          ((lambdap fnd) 'lambda)
          ((special-operator-p fn) 'special)
          (t (typename fnd)))))
    
(defun using (symb)
  "Print file positions of Lisp functions using symbol SYMB 
   in their definitions"
  (let ((ht (make-hash-table)))
    (mapfunctions
     (f/l (atm)
	  (let (found)
	    (clrhash ht)
	    (map-symbols-in-list (getd atm)
				 ht
				 (f/l (x) (if (eq x symb)
					      (setq found t))))
	    (if found (fp atm)))))))

(defun matching (pat)
  "Find positions of functions whose definitions match PAT somwhere"
  (mapfunctions (f/l (fn)
		     (if (match-somewhere pat (getd fn)) (fp fn)))))

(defun loaded-files (pat)
  "Find the loaded files matching pat"
  (let (files f)
    (dolist (f *loaded-files*)
      (if (string-like f pat)(push f files)))
    files))

(defun functions-in (pat)
  "Find all functions in FILE"
  (let ((files (loaded-files pat)) res)
    (if (cdr files) (formatl t "Files: " files t)
      (formatl t "File: " (car files) t))
    (mapfunctions (f/l (fn)(let ((fp (getprop fn 'filepos)))
			     (if (member (car fp) files)
				 (push fn res)))))
    res))

(defun not-called (fns)
  "Return subset of funtions FNS that are not called by other functions"
  (let ((indx (make-function-index t)))
    (subset fns (f/l (fn)(null (gethash fn indx))))))