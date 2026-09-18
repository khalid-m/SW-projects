;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: verify.lsp,v $
;;; $Revision: 1.11 $ $Date: 2005/01/03 15:08:27 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;;              
;;; ===========================================================================

(defvar *error-count*)
(defvar *warning-count*)
(defvar *max-line-length* 79)
(defvar *current-filename*)
(defvar *verify-output*)
(defglobal _charcode-newline_ 10)
(defglobal _charcode-semicolon_ 59)

(defun verify-file (filename)
  "Verifies the coding convention of the file named filename. It must end 
   with .lsp for the verifier to recognize it as Lisp."
  (let ((*current-filename* filename)
	(*error-count* 0)
	(*warning-count* 0))
    (verify-source filename)
    (cond ((string-like filename "*.lsp")
	   (verify-lisp-file filename)))
    (verify-summarize)))

(defun verify-summarize ()
  "Prints the summary of a completed verification, reading the variables 
   *error-count* and *warning-count*."
  (cond ((> *error-count* 1) (verify-println *error-count*" errors."))
	((= *error-count* 1) (verify-println *error-count*" error.")))
  (cond ((> *warning-count* 1) (verify-println *warning-count*" warnings."))
	((= *warning-count* 1) (verify-println *warning-count*" warning.")))
  (if (> *error-count* 1) (verify-println "Correct above errors before "
					    "adding to revision control.")))

;;; ---------------------------------------------------------------------------
;;; Generic verification (any text file)
;;; ---------------------------------------------------------------------------

(defun verify-source (filename)
  "Performs generic verification of coding conventions on file <filename>."
  (let ((str (openstream filename "r")))
    (verify-line-lengths str)
    (closestream str)))

(defun verify-line-lengths (str)
  "Verifies that all lines on the stream <str> are no longer than 
   <*max-line-length*> characters long."
  (let ((line 1))
    (while (verify-next-line-length str (++1 line) 0))))

(defun verify-next-line-length (str start-row start-column)
  "Verifies that the length in characters plus <start-column>, in the open 
   stream <str> until a newline character is no more than <*max-line-length*>
   characters in length. An error message is printed if not, assuming that the
   current line number in the stream is <start-row>. Then returns nil if EOF 
   is reached."
  (let ((current-charcode (read-charcode str))
	(current-column start-column)
	(current-row start-row))
    (while (and (neq current-charcode '*EOF*)
		(/= current-charcode _charcode-newline_))
      (setq current-charcode (read-charcode str))
      (1++ current-column))
    (if (> current-column *max-line-length*) 
	(verify-emit-error "line " current-row " is longer than "
		      *max-line-length*" characters ("
		      current-column")."))
    (neq current-charcode '*EOF*)))

;;; ---------------------------------------------------------------------------
;;; ALisp verification 
;;; ---------------------------------------------------------------------------

(defun verify-lisp-file (filename)
  "Verifies coding conventions in Lisp file <filename>." 
  (let ((str  (openstream filename "r"))
	tag
	sexp)
    (do ((sexp (read str) (read str)))
	((eq sexp '*EOF*))
	(if (eq (catch 'language-switch (verify-s-expression sexp)) ':osql)
	    (verify-skip-until-lisp str)))))

(defun verify-skip-until-lisp (str)
  "Reads a stream until it is either at the end of stream or past the 
   characters 'lisp;'"
  (do ((current-sexp (read str) (read str)))
      ((or (eq current-sexp '*EOF*) 
	   (and (equal current-sexp 'lisp)
		(eq (read-charcode str) _charcode-semicolon_ ))))))

(defun verify-s-expression (sexp)
  "Verifies the coding convention of symbolic expression <sexp> on the top 
   level."
  (if (listp sexp)
      (selectq (first sexp)
        (defun          (verify-defun sexp))
	(defmacro       (verify-defmacro sexp))
	(defstruct      t)
        (quote          t)
        (load           t)
        (provide        t)
        (in-system      (dolist (form (cddr sexp))
                          (verify-s-expression form)))
	(defglobal      (verify-defglobal sexp))
	(defvar         (verify-defvar sexp))
	(foreign-lispfn t)
	(movd           (verify-movd sexp))
	(osql           (verify-language-mix sexp))
        (advise-around  t)
	(putobject      t)
	(declarecosts   t)
	(setq           (verify-setq sexp))
	(verify-emit-debug "ignoring "sexp"!"))
    (selectq sexp
      (:osql (verify-language-mix sexp))
      (verify-emit-debug "ignoring "sexp"!"))
    (verify-emit-debug "can't verify symbol "sexp"!")))

;;; ---------------------------------------------------------------------------
;;; Verification of special constructs
;;; ---------------------------------------------------------------------------

(defun verify-foreign-lispfn (sexp)
  "Verifies use of the macro foreign-lispfn, i.e. prints an error."
  (let ((name (second sexp)))
    (verify-emit-error "Foreign function "name":"
		       "foreign-lispfn should not be used. "
		       "Declare foreign functions directly in AmosQL.")))


(defun verify-create-function (sexp)
  "Verifies use of the macro create-function on the top level, i.e. prints an 
   error."
  (let ((name (second sexp)))
    (verify-emit-error "Foreign function "name":"
		       "create-function should not be used. "
		       "Declare foreign functions directly in AmosQL.")))


(defun verify-language-mix (sexp)
  "Verifies mixing of AmosQL and Lisp in a .lsp file, where the programmer is 
   using the :osql command. Prints an error and throws the tag ':osql to the 
   catcher 'language-switch"
  (verify-emit-language-mix-error sexp)
  (if (eq sexp ':osql) (throw 'language-switch ':osql)))

(defun verify-movd (sexp)
  "Verifies use of movd on the top level, i.e. prints an error."
  (verify-emit-error "Use of MOVD is not approved programming style."))

(defun verify-setq (sexp) 
  "Does nothing."  
  )

;;; ---------------------------------------------------------------------------
;;; Verification of variable declarations
;;; ---------------------------------------------------------------------------

(defun verify-defglobal (sexp)
  "Verifies the use of defglobal, and that the correct naming convention is 
   observed."
  (let* ((name (second sexp)))
    (if (not (verify-defglobal-name? name))
	(verify-emit-declaration-error name 'defglobal
				       "name must begin and end with _"))))

(defun verify-defvar (sexp)
  "Verifies the use of defvar, and that the correct naming convention is 
   observed."
  (let* ((name (second sexp)))
    (if (not (verify-defvar-name? name))
	(verify-emit-declaration-error name 'defvar
				       "name must begin and end with *"))))

(defun verify-defglobal-name? (name)
  "True if <name> is a correct name (string or symbol) for use with defglobal."
  (string-like (mkstring name) "_*_"))

(defun verify-defvar-name? (name)
  "True if <name> is a correct name (string or symbol) for use with defvar."
  (let* ((namechars (explode name)))
     (and (eq (first namechars) '*) (eq (car (last namechars)) '*))))

;;; ---------------------------------------------------------------------------
;;; Verification of function/macro/struct definitions
;;; ---------------------------------------------------------------------------

(defun verify-defun    (sexp) 
  "Verifies a defun construct."
  (verify-definition sexp 'defun))

(defun verify-defmacro (sexp)
  "Verifies a defmacro construct."
  (verify-definition sexp 'defmacro))

(defun verify-defstruct(sexp)
  "Verifies a defstruct construct."
  (verify-definition sexp 'defstruct))
 
(defun verify-definition (sexp deftype)
  "Verifies a definition of type <deftype>."
  (let ((name (second sexp)))
    (verify-definition-name name deftype)
    (verify-definition-documentation sexp deftype)
    (verify-function (cons 'lambda (cddr sexp)) 'verify-emit-error name)))

(defun verify-definition-documentation (sexp deftype)
  "Verifies the documentation string of a definition of type <deftype>."
  (let ((name (string-downcase (second sexp))))
    (if (not (stringp (fourth sexp)))
	(verify-emit-definition-warning
	 name deftype "missing documentation string."))))

(defun verify-definition-name (name deftype)
  "Verifies that a definition's name, <name> is in accordance to coding 
   conventions regarding definition type <deftype>."
  (let ((namestr   (string-downcase name))
	(namechars (explode name)))
    (if (foreign-implementation? name)
	t
      (progn
	;;(if (memq '_ namechars) 
	;;    (verify-emit-definition-error name deftype
	;;		   "_ only allowed in function names which are "
	;;			   "implementations of foreign functions."))
	(if (memq '/ (rest namechars))
	    (verify-emit-definition-error name deftype
					  "/ only allowed as first character "
					  "in function name."))))))

(defun foreign-implementation? (fnname)
  "True if <fnname> appears to be the name of the implementation of a foreign 
   Lisp function."
  (string-like fnname "*[-+]"))

;;; ---------------------------------------------------------------------------
;;; Specialized emit functions
;;; ---------------------------------------------------------------------------

(defun verify-emit-definition-error (name deftype &rest args)
  "Issues an error to *verify-output* for the definition of a symbol named 
   <name>, where <deftype> is the type of the construct used, see 
   verify-get-deftype-name. <args> is the appended together and printed to the 
   stream."
  (let ((deftypename (verify-get-deftype-name deftype)))
    (apply #'verify-emit-error
	   (cons (concat deftypename" "(string-downcase name)":") args))))

(defun verify-emit-definition-warning (name deftype &rest args)
  "Issues a warning to *verify-output* for the definition of a symbol named 
   <name>, where <deftype> is the type of the construct used, see 
   verify-get-deftype-name. <args> is the appended together and printed to the 
   stream."
  (let ((deftypename (verify-get-deftype-name deftype)))
    (apply #'verify-emit-warning
	   (cons (concat deftypename" "(string-downcase name)":") args))))

(defun verify-emit-declaration-error (name dectype &rest args)
  "Issues an error to *verify-output* for the declaration of a symbol named 
   <name>, where <deftype> is the type of the construct used, see 
   verify-get-deftype-name. <args> is the appended together and printed to the 
   stream."
  (let ((dectypename (verify-get-dectype-name dectype)))
    (apply #'verify-emit-error
	   (cons (concat dectypename" "(string-downcase name)":") args))))

(defun verify-emit-language-mix-error (subject)
  "Issues the error that occurs if an attempt to mix osql and Lisp is detected.
   <subject> is the construct used."
  (let ((filename-stem (remove-filename-extension *current-filename*)))
    (verify-emit-error (or (concat subject":") "")
		       "AmosQL code should be placed in a file called "
		       filename-stem".osql. Skipping until 'lisp;'.")))

;;; ---------------------------------------------------------------------------
;;; Specialized emit functions
;;; ---------------------------------------------------------------------------
  
(defun verify-emit-error (&rest args)
  "Concatenates <args>, prints the result as an error to <*verify-output*>
   and increments <*error-count*>."
  (1++ *error-count*)
  (verify-println "error:" (apply #'concat args)))
  
(defun verify-emit-warning (&rest args)
  "Concatenates <args>, prints the result as an error to <*verify-output*>
   and increments <*error-count*>."
  (1++ *warning-count*)
  (verify-println "warning:" (apply #'concat args)))

(defun verify-emit-debug (&rest args)
  "Concatenates <args>, prints the result as a debugging message to 
   <*verify-output*> and increments <*error-count*>."
  (apply #'verify-println args))

;;; ---------------------------------------------------------------------------
;;; Functions that access stdout.
;;; ---------------------------------------------------------------------------

(defun verify-println (&rest args)
  "Concatenates <args> and prints the result to <*verify-output*>, finishing
   off with a newline."
  (princ (apply #'concat args))
  (terpri))

;;; ---------------------------------------------------------------------------
;;; utility functions.
;;; ---------------------------------------------------------------------------

(defun remove-filename-extension (filename)
  "Removes all characters from and including the last period in the string
   <filename>."
  (let ((chars (reverse (explode filename))))
    (while (not (equal (first chars) ".")) (pop chars))
    (apply #'concat (reverse (rest chars)))))

(defun verify-get-dectype-name (dectype)
  "Returns the printing name of a declaration construct <dectype>."
   (selectq dectype (defglobal "global constant")
		    (defvar "dynamic scope variable")
		    (error "unknown delaration type "dectype)))

(defun verify-get-deftype-name (deftype)
  "Returns the printing name of a definition construct <deftype>."
  (selectq deftype (defun "function")
		   (defmacro "macro") 
		   (defstruct "struct")
                   nil))

