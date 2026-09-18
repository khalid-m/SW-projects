;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Tore Risch, EDSLAB
;;; $RCSfile: franzinit.lsp,v $
;;; $Revision: 1.14 $ $Date: 2004/01/22 20:06:19 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions needed to make it possible to load Amos into Franz
;;; =============================================================


(defvar _deep-print_ t)

(defmacro bp (msg) nil)

(defun pack (&rest args)
   "Pack atoms" 
   (packlist args))
(defun packlist (l)
   (mkatom (apply (function concat) l)))
(defmacro f/l (&rest args)(list 'function (cons 'lambda args)))
(defmacro q/l (&rest args)(list 'function (cons 'lambda args)))
(defun movd (x y) 'nil) ; dummy
 
(defun /defc (fn def)(eval (list* '/defun fn (argsof 'lambda def))))
(defconstant -t- t)
(defmacro defglobal (var &rest val)
 (if val (list 'defvar var (car val))
    (list 'defvar var)))
(defmacro prog-let (&rest bdy)(cons 'prog bdy))
(defun kwoted (x)
   (cond ((atom x)(not (symbolp x)))
         ((eq (car x) 'quote))))
(defun kwote (x)
   (if (kwoted x) x (list 'quote x)))
(defun arraytolist (a)
   (let (res)
      (do ((i (1-(array-total-size a))(1- i)))
          ((< i 0) res)
         (setq res (cons (aref a i) res)))))
(defmacro dolists (bnds &rest body)
  "Like dolist except it carries out parallel traversal of several 
   lists. Stops at the end of the shortest and returns t if all lists
   ended at the same time."
  (let* ((i 0) 
	 (vll (mapcar (f/l (bnd)
			(list (car bnd) 
			      (pack '_ (setq i (1+ i)))
			      (cadr bnd))) 
		      bnds)
	      ))
      `(prog-let (,@ (mapcar (function car) vll)
		     ,@ (mapcar (function rest) vll))
         (int-while (and ,@ (mapcar (f/l (a) `(consp , (second a))) 
				    vll))
		    ,@ (mapcar (f/l (a)
			         `(setq ,(car a) (pop , (cadr a)))) 
			       vll)
		    ,@ body)
	 (and ,@ (mapcar (f/l (a) `(eq nil , (cadr a))) vll)))))
(defun listtoarray (l)(apply (function vector) l))
(movd 'function 'equote)
(defun putprop (a i v)
   (setf (get a i) v))
(defun getprop (a i)(get a i))
(defmacro selectq (pred &rest body)
   (list* 'case pred (nconc (butlast body) (list (list 'otherwise (car (last body)))))))
(defun randominit (x)(setq *random-state* (make-random-state)))
(defun memq (x l)(member x l :test (function eq)))
(defun memqual (x l)(member x l :test (function equal)))
(defun natom (x)(not (atom x)))
(defun mkstring (x)(princ-to-string x))
(defun mkatom (x)(read-from-string (princ-to-string x)))
(defmacro isome (l f)
   `(do ((-l- ,l (cdr -l-)))
        ((null -l-) nil)
        (if (funcall ,f (car -l-))(return -l-))))
(defun neq (x y)(not (equal x y)))
(defun concat (&rest args)
	(let ((s (opentextstream)))
		(while (natom args)(princ (pop args) s))
		(textstreamstring s)))
(defun opentextstream ()(make-string-output-stream))
(defun textstreamstring (s)(get-output-stream-string s))
(defun nconc2 (x y)(nconc x y))
(defun append2 (x y)(append x y))
(defun applyarray (fn a)
   (apply fn (arraytolist a)))
(movd 'pairlis 'pair)
(defun assq (x l)(assoc x l :test (function eq)))
(defun nconc1 (l x)(nconc l (list x)))
(defun subpair (old new tree)(sublis (pair old new) tree))
(defun quotient (x y)
   (if (and (integerp x)(integerp y))(floor (/ x y)) (/ x y)))
(defmacro pp (&rest fns)(dolist (fn fns)(pprint(getprop fn 'virginfn))))
(defun keyword-to-atom (x)(mkatom x))
(defun thecar (x)(if (atom x) x (car x)))
(setq *top-print-level* 40)
(defun printl (&rest args)(print args))
(defun unfunction (x)
   (cond ((atom x) nil)
         ((eq (car x) 'function)(cadr x))
         ((eq (car x) 'f/l)(cons 'lambda (cdr x)))))
(defun prognify (l)(funify 'progn l))

(defstruct (oid (:print-function proid))
  (idno 0 :type fixnum) types propl)
(defun mapfilter (filt lst &optional op) ;additional arg op added, a fn
   (cond ((null lst)  nil)
         ((funcall filt (car lst))
          (if op (cons (funcall op (car lst))
                   (mapfilter filt (cdr lst) op))
             (cons (car lst) (mapfilter filt (cdr lst) op))))
         (t (mapfilter filt (cdr lst) op))))
(defmacro resetvar (var val &rest form)
   "Reset VAR globally to VAL and evaluate FORM"
   `(let ((___resetvar , var))
       (unwind-protect 
            (progn (setq , var , val) ,@ form)
          (setq , var ___resetvar) ;Restore value of VAR.
          )))
(defun mklist (x)(if (listp x) x (list x)))
(defun in (x l)
  (cond ((eq x l))
	((atom l) nil)
	(t (isome l (q/l (y)(in x y))))))
(defun unique (l)
  (cond ((null l) nil)
	((memqual (car l) (cdr l))(unique (cdr l)))
	(t (cons (car l)(unique (cdr l))))))

;;; Franz dummies 


(defun new-event (x y z) nil)
(defun thecar (x)(if (atom x) x (car x)))
(defun allcars (l) (mapcar (function thecar) l))
(defun parsekeywordparams (args params)
   (do ((a args (cddr a)))
       ((null a))
      (if (dolist (p params)
             (if (eq (thecar p) (car a))
                (return t)))
         nil
         (error "Illegal keyword" a)))
   (mapcar (f/l (p)
             (cond((getf args (thecar p)))
                   ((listp p)(cadr p))))
     params))

(defun parse(x) x)
(defvar _type_ nil)
(defvar _boolean_ nil)
(defvar exportto)
(defvar importfrom)
(defvar _history_)

(defun getobjectnamed (o &optional x y) nil)

(defun getbinding(x y) nil)
(defvar *trace-file*)
(defmacro with-output-file (str file form)
   `(let ((, str (if , file (openstream , file "w"))))
       (unwind-protect
            , form
          (if , str (closestream , str)))))
(defvar **symbolhashtab**)

 
(defmacro with-current-directory (dir &rest forms)
   `(let ((*olddir* (current-directory))
          (*default-pathname-defaults* (progn (set-current-directory , dir)
                                         (current-directory))))
       (unwind-protect 
            (progn ,@ forms)
          (set-current-directory *olddir*)
          )))

(defmacro with-string (s form)
  "Create a temporary text stream to be used by 'form', which will
   print to it. When form is done return the string.
   Use with any pp-xxx function to get back a string without defining globals."
  `(let ((, s (maketextstream)))
     , form
       (textstreamstring , s)))

(defun /createobject (x y) x)


(defmacro defc (f def)(list* 'defun (cadr f) (cdadr def)))

(defun advise-around (x y))