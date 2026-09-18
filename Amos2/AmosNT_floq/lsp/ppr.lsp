;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, EDSLAB
;;; $RCSfile: ppr.lsp,v $
;;; $Revision: 1.19 $ $Date: 2014/01/09 16:47:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Pretty printer
;;; =============================================================
;;; $Log: ppr.lsp,v $
;;; Revision 1.19  2014/01/09 16:47:00  andan342
;;; PPS crashes no more on dotted pairs of STRUCT
;;;
;;; Revision 1.18  2012/09/06 20:42:30  torer
;;; Implicit progn in WITH-STRING
;;;
;;; Revision 1.17  2012/02/01 11:11:00  andan342
;;; Pretty-printer now correctly prints dotted pairs
;;;
;;; =============================================================


(defmacro pp (&rest fns)
  "Pretty prints function definitions"
  `(ppf (quote , fns)))

(defun ppf (fns &optional str) 
  "Print function, macro, and global variable definitions to a stream STR."
  (let (def)
    (unwind-protect
	(dolist (fn (mklist fns))
	  (cond ((setq def (getd fn))
		 (if (atom def) (pps (list 'defc (kwote fn) (kwote def)) str) 
		   (let ((vf (virginfn fn)))
		     (if (lambdap vf)
			 (pps (list* (if (macro-function fn) 
					 'defmacro 
				       'defun)
				     fn (cdr vf)) str)
		       (pps (list 'defc (kwote fn) (kwote vf)) str)))))
		((special-variable-p fn)
		 (if (boundp fn)
		     (pps (list 'defvar fn (kwote (symbol-value fn))) str)
		   (pps (list 'defvar fn) str)))
		((or(global-variable-p fn)(boundp fn))
		 (if (boundp fn)
		     (pps (list 'defglobal fn (kwote (symbol-value fn))) str)
		   (pps (list 'defglobal fn) str)))
		(t (pps (list fn 'undefined) str)))))
    fns))

(defun pprint (x &optional stream)
  "Pretty print S-expression"
  (terpri stream)
  (pps x stream))

(defmacro with-string (s &rest forms)
  "Create a temporary text stream to be used by 'forms', which will
   print to it. When form is done return the string.
   Use with any pp-xxx function to get back a string without defining globals."
  `(let ((, s (maketextstream)))
     ,@ forms
     (textstreamstring , s)))

;;; Internal functions:

(defun virginfn (fn)
  "Get the unwrapped version of function"
  (or (getprop fn 'virginfn)(getd fn)))

(defvar *ppsbuf* (maketextstream) "Line buffer used by pretty printer")

(defun pps (x &optional stream p00)
  "Prettyprint S-expression. P00 should normally be NIL"
  (pps1 x *ppsbuf* stream p00)
  (printbuf *ppsbuf* stream)
  nil)

(defun ppasatom (x)
  "Pretty print atom or quoted expression (internal PPS)"
  (if (atom x)(not (arrayp x))
    (and (eq (car x) 'quote)
	 (null (cddr x)))))

(defun ppatoms (x buf str &optional p0)
  "Prettyprint list of atoms (internal PPS)"
  (let* ((p01 (if p0 p0 0))
	 (pos (+ 2 (textstreampos buf) p01)))
    (or (while (consp x)
	  (cond ((not (ppasatom (car x))) (return x))
		((> (textstreampos buf) 70)(printbuf buf str pos)))
	  (cond ((not (atom (car x)))	; quote found!
		 (princ "'" buf)
		 (pps1 (cadar x) buf str))
		(t (prin1 (car x) buf)))
	  (setq x (cdr x))
	  (if x (princ " " buf))
	  x)
	(cond (x			; dotted pair
	       (princ ". " buf)
	       (prin1 x buf) ; changed from 'princ' by Andrej
	       nil)))))

(defun pps1 (x buf str &optional p00)
  "Prettyprint S-expression using line buffer BUF (internal PPS)"
  (cond ((and (atom x)(not (arrayp x)))(prin1 x buf))
	(t 
	 (let* ((p0c (if p00 p00 0))
                (cp (textstreampos buf))
		(p0 (+ cp p0c))
		pos 
		fn
		(root x))
	   (cond ((arrayp x)
		  (let ((acc (struct-accessors x)))
		    (cond (acc ; prettyprint struct
			   (setq p0 (+ cp 2))
			   (formatl buf "#(" (aref x 0))
			   (dolist (a acc)
			     (printbuf buf str p0) 
			     (formatl buf ";" (cdr a) ":")
			     (printbuf buf str p0)
			     (pps1 (funcall (cdr a) x) buf str))
			   (princ ")" buf))
			  (t (prin1 x buf))))) ; regular array
		 (t (setq fn (car x))
		    (princ "(" buf)
		    (setq x (ppatoms x buf str p0c))
		    (cond
		     ((null x)(princ ")" buf))
		     (t (setq pos (+ (textstreampos buf) p0c))
			(cond
			 ((memq fn '(defun defmacro))
			  (cond ((eq x (cddr root))
				 (pps1 (car x) buf str)
				 (setq x (cdr x))))
			  (setq pos (+ 2 p0))
			  (printbuf buf str pos))
			 ((memq fn '(cond))
			  (setq pos (+ 2 p0))
			  (printbuf buf str pos))
			 ((memq fn '(if let let* lambda prog))
			  (setq pos (+ 1 p0))
			  (if (atom (cadr root))(printbuf buf str pos)))
			 ((> pos (+ 5 p0))
			  (setq pos (+ 3 p0))
			  (printbuf buf str pos)))			
			(int-while x
				   (cond ((atom x) ;branch added by Andrej
					  (princ ". " buf)
					  (setq x (ppatoms (list x) buf str))
					  (if x (printbuf buf str pos)))
					 ((ppasatom(car x))
					  (setq x (ppatoms x buf str))
					  (if x (printbuf buf str pos))))
				   (cond ((consp x)  ;changed from 'x' by Andrej
					  (pps1 (car x) buf str)
					  (cond ((cdr x) 
						 (printbuf buf str pos)))
					  (setq x (cdr x)))))
			(princ ")" buf)))))))))

(defun printbuf (buf str &optional pos)
  "Print contents of prettyprint line buffer"
  (princ (textstreamstring buf) str)
  (terpri str)
  (closestream buf)
  (cond (pos (spaces pos buf))
	(t (princ " " buf)
	   (closestream buf))))

(defun spaces (x &optional str)
  "Print X spaces on stream STR"
  (rptq x (princ " " str)))
