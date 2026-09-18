;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997- Tore Risch et al, UDBL
;;; $RCSfile: basic.lsp,v $
;;; $Revision: 1.54 $ $Date: 2013/05/02 18:02:44 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Some basic utility functions
;;; =============================================================
;;; $Log: basic.lsp,v $
;;; Revision 1.54  2013/05/02 18:02:44  torer
;;; Changes to bigintegrator
;;;
;;; Revision 1.53  2013/03/13 17:59:44  torer
;;; (RELOAD-EXTENSIONS) did not use the correct startup directory
;;;
;;; Revision 1.52  2013/03/06 21:15:40  torer
;;; (LOAD-EXTENSION NAME PERSISTENT &OPTIONAL NOERROR FORCE)
;;; will not reload already loaded extension, unless FORCE in non-nil
;;;
;;; Revision 1.51  2013/03/01 07:50:18  torer
;;; Added log on header
;;;
;;; =============================================================

(defmacro declare) ;; For CommonLisp compatibility

(defmacro f/l (&rest body)
  "Shortcut for (function (lambda . body))"
  `(function (lambda ,@body)))

(movd 'quote 'equote)

(movd 'symbol-setfunction 'defc)

(defmacro q/l (&rest body) 
  "Shortcut for (quote (lambda . body))"
  `(equote (lambda ,@body)))

(movd 'null 'not)

(defun = (x y)(eq (compare x y) 0))

(defun /= (x y)(not (= x y)))

(defmacro 1- (x)(list '- x 1))

(defmacro 1+ (x)(list '+ x 1))

(defmacro 1++ (var) `(setq ,var (1+ ,var)))

(defmacro 1-- (var) `(setq ,var (1- ,var)))

(defun zerop (x)(= x 0))

(defun plusp (x)(> x 0))

(defun minusp (x) (< x 0))

(defun caaar (x)(car(caar x)))

(defun caadr (x)(car(cadr x)))

(defun cadar (x)(car(cdar x)))

(defun cdaar (x)(cdr(caar x)))

(defun cdadr (x)(cdr(cadr x)))

(defun cddar (x)(cdr(cdar x)))

(defmacro cddddr (x) `(cddr (cddr ,x)))

(defmacro cadddr (x) `(cadr (cddr ,x)))

(movd 'car 'first)

(movd 'cadr 'second)

(movd 'caddr 'third)

(defun fourth (l)
  (nth 3 l))

(defun fifth (l)
  (nth 4 l))

(defun sixth (l)
  (nth 5 l))

(defun seventh (l)
  (nth 6 l))

(defun eighth (l)
  (nth 7 l))

(defun ninth (l)
  (nth 8 l))

(defun tenth (l)
  (nth 9 l))

(movd 'cdr 'rest)

(defun prog2 (x y &optional rest) y)

(movd 'mksymbol 'mkatom)

(defmacro let (bindings &rest body)
  (cons (cons 'lambda (cons(let_vars bindings) body))
	(let_forms bindings)))

(defun let_vars (l)
  (cond ((atom l) nil)
	((atom (car l))(cons (car l)(let_vars (cdr l))))
	(t (cons (caar l)(let_vars (cdr l))))))

(defun let_forms (l)
  (cond ((atom l) nil)
	((atom (car l))(cons nil (let_forms (cdr l))))
	(t (cons (cadar l)(let_forms (cdr l))))))

(defun prognify (forms)
  (cond ((atom forms) forms)
	((cdr forms)(cons 'progn forms))
	(t (car forms))))

(defmacro let* (bindings &rest body)
  (prognify (expand-let* bindings body nil)))

(defun expand-let* (bindings body bndl)
  (cond ((null bindings)
	 (if bndl (list(list* 'let bndl body)) body))
	((atom (car bindings))
	 (expand-let* (cdr bindings) body
		      (nconc1 bndl (car bindings))))
	(bndl (list(list* 'let bndl
			  (expand-let* (cdr bindings) body
				       (list (car bindings))))))
	(t (expand-let* (cdr bindings) body
			(list (car bindings))))))

(defmacro resetvars (bindings &rest forms)
  "Like LET but temporarily resets global variables"
  (prognify (expand-resetvars bindings forms)))

(defun expand-resetvars (bindings forms)
  (cond ((null bindings) forms)
        ((consp (car bindings))
         (list (list* 'resetvar (caar bindings)
		      (prognify (cdar bindings))
		      (expand-resetvars (cdr bindings) forms))))
        (t (list (list* 'resetvar (car bindings) nil
			(expand-resetvars (cdr bindings) forms))))))

(defmacro push (x v)
  `(setf ,v (cons ,x ,v)))

(defun pack (&rest args)
  "Pack atoms" 
  (packlist args))

(defun packlist (l)
  (mksymbol (apply (function concat) l)))
  
(defvar *gensym* 0)

(defun gensym () (pack 'g: (setq *gensym* (1+ *gensym*))))

(movd 'syserror 'error)

(movd 'getprop 'get)

(movd 'pair 'pairlis)

(movd 'putprop 'put)

(defun list-length (x)
  (if (listp x)(length x)
    (error "Not a list" x)))

(defmacro append (x y &rest l)
  (cond ((null l)(list 'append2 x y))
	(t (list* 'append (list 'append2 x y) l))))

(defmacro nconc (x y &rest l)
  (cond ((null l)(list 'nconc2 x y))
	(t `(nconc (nconc2 ,x ,y) ,@l))))

(defmacro bquote (args)
  (expand-bquote args))

(defun dotendp (l)
  (cond ((null l) nil)
	((atom l))
	((eq (car l) (quote ,@)))
	(t (dotendp (cdr l)))))

(movd 'kwoted 'constantp)

(defun expand-bquote (args)
  (cond ((null args) nil)
	((atom args)(kwote args))
	((dotendp args)
	 (cons 'list* (expand-bquotel args t)))
	(t (cons 'list (expand-bquotel args nil)))))

(defun expand-bquotel (args de)
  (cond ((null args) (if de '(nil)))
	((eq (car args) (quote ,))
	 (list* (cadr args) (expand-bquotel (cddr args) de)))
	((eq (car args) (quote ,@))
	 (if (cddr args)
             (list(list 'append2 (cadr args)
			(expand-bquote (cddr args))))
	   (list (cadr args))))
	(t (cons (expand-bquote (car args))
		 (expand-bquotel (cdr args) de)))))

(defun unfunction (x)
  (cond ((atom x) nil)
	((eq (car x) 'function)(cadr x))
	((eq (car x) 'f/l)(cons 'lambda (cdr x)))))

(defmacro funcall (fn &rest args)
  (let ((uf (unfunction fn)))
    (if uf (cons uf args)
      (list* 'intfuncall fn args))))

(movd 'apply 'int-apply)
(defc 'apply nil);;no redefined warning
(defmacro apply (fn arg1 &rest args)
  (cond ((null args) `(int-apply ,fn ,arg1))
        ((null (car (last args))) `(funcall ,fn ,arg1 ,@(butlast args)))
        ((cdr args) `(int-apply ,fn (list* ,arg1 ,@args)))
        (t `(int-apply ,fn (cons ,arg1 ,(car args))))))

(defmacro prog-let (&rest body)
  `(catch 'prog-return (let ,@body)))

(defmacro prog-let* (&rest body)
  `(catch 'prog-return (let* ,@body)))

(defun return (value)(throw 'prog-return value))

(defmacro dolist (bnd &rest body)
  (let ((local '_0))
    `(prog-let (,(car bnd)(,local ,(cadr bnd)))
	       (int-while (consp ,local)
			  (setq ,(car bnd) (pop ,local))
			  ,@body)
	       ,(caddr bnd))))

(defun lsp_andify (l)
  (cond ((null l) t)
	((null (cdr l))(car l))
	((memq nil l) nil)
	(t (cons 'and l))))

(defun allpop (l)
  (if (atom l) nil
    (cons (list 'pop (car l))
	  (allpop (cdr l)))))

(defun buildargl (l i)
  (cond ((atom l) nil)
	(t (cons (mksymbol (concat "_" i))
		 (buildargl (cdr l)(1+ i))))))

(defun pairargs (x y)
  (cond ((atom x) nil)
	(t (cons (list (car x) (car y))
		 (pairargs (cdr x)(cdr y))))))

(defmacro mapc (fn &rest args)
  (let ((al (buildargl args 0)))
    `(let ,(pairargs al args)
       (int-while (consp ,(lsp_andify al))
		  (funcall ,fn  ,@(allpop al))
		  )) ))

(defmacro mapl (fn &rest args)
  (let ((al (buildargl args 0)))
    `(let ,(pairargs al args)
       (int-while
	(consp ,(lsp_andify al))
	(funcall ,fn  ,@al)
	,@(allpop al)
	))))

(defmacro mapcar (fn &rest args)
  (let ((al (buildargl args 0)))
    `(let ((_hd_ (cons)) _tl_ ,@(pairargs al args))
       (setq _tl_ _hd_)
       (int-while
	(consp ,(lsp_andify al))
	(rplacd _tl_ (list (funcall ,fn ,@(allpop al))))
	(pop _tl_)
	)
       (cdr _hd_)) ))

(defmacro loop (&rest body)
  `(catch 'prog-return (int-while t ,@ body)))

(defmacro mapcan (fn &rest args)
  (let ((al (buildargl args 0)))
    `(let* ((_hd_ (cons)) _tl_ ,@(pairargs al args))
       (setq _tl_ _hd_)
       (int-while (consp ,(lsp_andify al))
		  (rplacd _tl_ (funcall ,fn ,@(allpop al)))
		  (setq _tl_ (last _tl_))
		  )
       (cdr _hd_)) ))

(defmacro some (fn &rest args)
  (let ((al (buildargl args 0)))
    `(catch 'some (let ,(pairargs al args)
		    (int-while (consp ,(lsp_andify al))
			       (if (funcall ,fn ,@(allpop al))
				   (throw 'some t))
			       )) )))

(defmacro notany (&rest args)
  `(not (some ,@args)))

(defmacro every (fn &rest args)
  (let ((al (buildargl args 0)))
    `(null (catch 'every 
	     (let ,(pairargs al args)
	       (int-while (consp ,(lsp_andify al))
			  (if (funcall ,fn ,@(allpop al)) 
			      nil 
			    (throw 'every t))
			  ))) )))

(defmacro dotimes (bnd &rest body)
  `(prog-let ((,(first bnd) -1))
	     (rptq ,(second bnd)
		   (progn
		     (setq ,(first bnd) (1+ ,(first bnd)))
		     ,@body
		     ))
             ,@(if (third bnd)
		   (bquote ((setq ,(first bnd) (1+ ,(first bnd)))
			    ,(third bnd))))))

(defmacro do (init end &rest body)
  `(prog-let ,(mapcar (f/l (x) (list (car x)(cadr x))) init)
	     (int-while (not ,(car end))
			,@body
			,@(mapcan 
			   (f/l (x) 
				(if (and(cddr x)(neq (car x)(caddr x)))
				    (list(list 'setq (car x)(caddr x))))) 
			   init))
	     ,@(cdr end)))

(defmacro do* (inits endtest &rest body)
  (cond
   ((null
     (cdr inits))
    `(do ,inits ,endtest ,@body))
   (t
    `(let ((,(caar inits) ,(cadar inits)))
       (do* ,(cdr inits)
	   ,endtest
	 ,@(nconc body
		  (cond
		   ((car (cddar inits))
		    `((setq ,(caar inits)
			    ,(car (cddar inits))))
		    ))))))))

(defmacro case (test &rest body)
  (list* 'selectq test (expand-case body)))

(defun expand-case (body)
  (cond ((null body) (list nil))
	((memq (caar body) '(t otherwise))
	 (list (prognify (cdar body))))
	(t (cons (car body)
		 (expand-case (cdr body))))))

(defmacro make-array (size &rest keywords)
  (let ((kw (parsekeywordparams keywords '(:initial-element :adjustable))))
    (list 'mkarray size (first kw)(second kw))))

(defmacro maparray (array fn)
  `(dotimes (_index_ (array-total-size , array))
     (funcall , fn (aref , array _index_) _index_)))

(defmacro defstruct (name &rest slots)
  (setq name (thecar name))
  (let ((mmc (pack 'make- name))
	(mfn (pack 'makefn- name))
	(slotno 0)
	accessor)
    (putprop name 'accessors nil)
    (putprop name 'slots nil)
    `(progn
       (defun ,(pack name '-p) (x) 
	 (and (arrayp x)(eq (elt x 0)(quote ,name))))
       (defmacro ,mmc (&rest args)
	 (cons (quote ,mfn)
	       (parsekeywordparams 
		args
		(quote ,(mapcar (f/l (x)(pack ': (thecar x)))
				slots)))))
       (defun ,mfn ,(allcars slots)
	 (let ((o (make-array ,(1+ (length slots)))))
	   (seta o 0 (quote ,name))
	   ,@(mapcar
	      (f/l (slot)
		   (setq slotno (1+ slotno))
		   (setq accessor (pack name '- (thecar slot)))
		   (putprop 
		    accessor 'setfmethod
		    `(lambda (place val)
		       (list 'seta (cadr place) ,slotno val)))
		   (symbol-setfunction 
		    accessor
		    `(lambda (o)(elt o ,slotno)))
		   (addprop name 'accessors 
			    (cons (thecar slot) accessor) t)
		   (if (atom slot)
		       (list 'seta 'o slotno slot)
		     (list 'seta 'o slotno
			   (list 'if (thecar slot)
				 (list 'seta 'o slotno
				       (thecar slot))
				 (prognify (cdr slot))))))
	      slots)
	   o))
       (quote ,name))))

(defun struct-accessors (x)
  (and (arrayp x)(> (length x) 0)(symbolp (aref x 0))
       (getprop (aref x 0) 'accessors)))

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
;;; MACROEXPAND

(defun macroexpand-all (form)
  "Return form where all macros in FORM are macro expanded"
  (cond ((atom form) form)
        ((macro-function (car form)) 
         (macroexpand-all (macroexpand form)))
        (t (selectq 
	    (car form)
	    (quote form)
            (function 
	     (list (car form) (macroexpand-lambda (second form))))
	    (cond (cons (car form)
			(mapcar (f/l (cl)
				     (mapcar (function macroexpand-all) cl))
                                (cdr form))))
	    (selectq (list* (car form)
			    (macroexpand-all (second form))
			    (macroexpand-selectq-body (cddr form))))
	    (cons (macroexpand-lambda (car form))
		  (mapcar (function macroexpand-all) (cdr form)))))))

(defun macroexpand-lambda (lb)
  (if (lambdap lb)
      (list* (car lb)(second lb)
	     (mapcar (function macroexpand-all) (cddr lb)))
    lb))

(defun macroexpand-selectq-body (l)
  (if (cdr l)
      (cons (cons (caar l)
		  (mapcar (function macroexpand-all)(cdar l)))
	    (macroexpand-selectq-body (cdr l)))
    (list (macroexpand-all (car l)))))

(defun lastelem (l)(car (last l)))


;;; SETF and PSETQ

(defun propl-to-assl (pl)
  (let (pairs (pl pl))
    (while pl
      (setq pairs (cons (cons (pop pl)(pop pl)) pairs)))
    (nreverse pairs)))

(defmacro setf (&rest settings)
  "Setting multiple locations in serial: (setf v1 l1 v2 l2 ...)"
  (prognify 
   (mapcar (f/l (pair)
		(let ((place (car pair))(val (cdr pair)))
		  (if (symbolp place)(list 'setq place val)
		    (let (fn (pl (macroexpand place)))
		      (cond ((and (listp pl)
				  (setq fn (getprop (car pl) 'setfmethod)))
			     (funcall fn pl val))
			    (t (error "Illegal setf place:" place)))))))
	   (propl-to-assl settings))))

(defmacro incf (place &optional delta)
  `(setf ,place (+ ,place ,(or delta 1))))

(defmacro decf (place &optional delta)
  `(setf ,place (- ,place ,(or delta 1))))

(defmacro psetq (&rest settings)
  "Setting multiple location in parallell: (psetq l1 v1 l2 v2 ...)"
  (let ((ali (propl-to-assl settings)))
    (dolist (p ali)
      (if (consp (cdr p))
	  (rplacd p (macroexpand-all (cdr p)))))
    (prognify (psetq-assignments ali 0))))

(defun psetq-assignments (ali cnt)
  (cond ((null ali) nil)
	((in (caar ali)(cdr ali))
	 (let ((v (pack 'psetq# (1++ cnt))))
	   `((let ((,v ,(cdar ali)))
	       ,@(psetq-assignments (cdr ali) cnt)
	       (setq ,(caar ali) ,v))))) 
        ((equal (cdar ali) (list 'cdr (caar ali)))
         (cons (list 'pop (caar ali))
               (psetq-assignments (cdr ali) cnt)))
	((cdar ali)
	 (cons (list 'setq (caar ali)(cdar ali))
	       (psetq-assignments (cdr ali) cnt)))
        (t (cons (list 'setq (caar ali))
		 (psetq-assignments (cdr ali) cnt)))))

(defun delete-btree (k bt)
  "Delete key/value paur from BTREE index"
  (prog1 (get-btree k bt)
    (put-btree k bt nil)))

;;; SETF methods

(putprop 'elt 'setfmethod
	 (q/l(place val)
	     (list 'seta (cadr place)(caddr place) val)))

(defmacro aref (a i &rest xx)
  (if xx (error "Only 1-dimensional arrays supported" xx)
    (list 'elt a i)))

(putprop 'getf 'setfmethod
	 (q/l (place val)
	      (list 'putf (cadr place) (caddr place) val)))

(putprop 'get 'setfmethod
	 (q/l (place val)
	      (list 'put (cadr place) (caddr place) val)))

(putprop 'gethash 'setfmethod
	 (q/l (place val)
	      (list 'puthash (cadr place) (caddr place) val)))

(putprop 'get-btree 'setfmethod
	 (q/l (place val)
	      (list 'put-btree (cadr place) (caddr place) val)))

(defun list-setf-method (place val)
  (let* ((lsf (getprop (car place) 'list-setf-functions))
	 (repl (list (car lsf)
		     (if (second lsf) 
			 (list (second lsf)(second place))
		       (second place))
		     val)))
    (selectq (car lsf)
	     (rplaca (list 'car repl))
	     (rplacd (list 'cdr repl))
	     (error "System error. Should'nt happen"))))

(defun define-list-setf (fn lsf)
  (putprop fn 'setfmethod 'list-setf-method)
  (putprop fn 'list-setf-functions lsf))

(define-list-setf 'car '(rplaca))
(define-list-setf 'first '(rplaca))
(define-list-setf 'cdr '(rplacd))
(define-list-setf 'rest '(rplacd))
(define-list-setf 'caar '(rplaca car))
(define-list-setf 'cdar '(rplacd car))
(define-list-setf 'cadr '(rplaca cdr))
(define-list-setf 'second '(rplaca cdr))
(define-list-setf 'cddr '(rplacd cdr))
(define-list-setf 'caaar '(rplaca caar))
(define-list-setf 'caadr '(rplaca cadr))
(define-list-setf 'cadar '(rplaca cdar))
(define-list-setf 'caddr '(rplaca cddr))
(define-list-setf 'third '(rplaca cddr))
(define-list-setf 'cdaar '(rplacd caar))
(define-list-setf 'cdadr '(rplacd cadr))
(define-list-setf 'cddar '(rplacd cdar))
(define-list-setf 'cdddr '(rplacd cddr))
(define-list-setf 'fourth '(rplaca cdddr))
(define-list-setf 'fifth '(rplaca cddddr))
(define-list-setf 'sixth '(rplaca (lambda (x)(nthcdr 5 x))))
(define-list-setf 'seventh '(rplaca (lambda (x)(nthcdr 6 x))))
(define-list-setf 'eighth '(rplaca (lambda (x)(nthcdr 7 x))))
(define-list-setf 'ninth '(rplaca (lambda (x)(nthcdr 8 x))))
(define-list-setf 'tenth '(rplaca (lambda (x)(nthcdr 9 x))))

(movd 'pop 'pop-variable);; old definition
(defc 'pop nil);;no redefined warning
(defmacro pop (x)(if (symbolp x) (list 'pop-variable x)		   
		   `(prog1 (car ,x) 
		      (setf ,x (cdr ,x)))))

(putprop 'nth 'setfmethod 
	 '(lambda (place val)
	    `(car (rplaca (nthcdr ,(second place) ,(third place)) 
			  ,val))))

(defmacro make-hash-table (&rest args)
  (let ((x (parsekeywordparams args '(:size :test))))
    `(makehashtable ,(car x)
		    (eq ,(cadr x) 'equal))))

(defmacro while (&rest body)
  `(catch 'prog-return (int-while ,@body)))

(defmacro when (test &rest forms)
  `(cond (,test ,@forms)))

(defmacro unless (test &rest forms)
  `(cond (,test nil)(t ,@forms)))

(defun global-variable-p (var)
  "Is VAR a global variable?"
  (getprop var 'global))

(defun log10 (x)(log x 10))

(defun ln (x)(log x nil))

(defun roundto (num digits)
  "Round the real number 'num' to 'digits' digits after the 0."
  (if (< digits 0) (error "Negative digits to round" digits))
  (let* ((scale (expt 10.0 digits))
	 (rounded (round (* num scale))))
    (/ rounded scale)))

(defun evenp (num)
  (= (mod num 2) 0))

(defun oddp (num)
  (= (mod num 2) 1))

(movd 'member 'memqual)

(movd 'natom 'consp)			; The CommonLisp name

(movd '/ 'quotient)

(movd 'symbol-function 'getd)

(defun provide())

(defvar *standard-output* t)

(defmacro flet (fns &rest body)
  (prognify (subfnsinlist 
	     (mapcar (function (lambda (df)
				 (list* (car df) 'lambda (cdr df))))
		     fns)
	     body)))

(defun attach (x l) 
  "Destructively insert X first in list L"
  (cond ((atom l)(cons x l))
	(t (let ((tmp (car l)))
	     (rplaca l x)
	     (rplacd l (cons tmp (cdr l)))))))

(defun ldiff (l tl)
  "List difference between L and tail TL of L"
  (let (res)
    (while (natom l)
      (if (eq l tl)(return nil)
	(push (car l) res))
      (pop l))
    (nreverse res)))

(defun printl (&rest l)
  "Print list of arguments on standard output"
  (print l))

(defglobal _std-output-opened_ nil)

(defun open-stdout-window()
  "Open standard output window once (Windows only)"
  (cond(_std-output-opened_)
       ((not (equal (system-environment) "VisualC++")) 
	(setq _std-output-opened_ t))
       (t (system "cmd")
	  (setq _std-output-opened_ t))))

(defun formatl (str &rest args)
  "Poor man's FORMAT function"
  (let (ppflg)
    (dolist (a args)
      (cond ((eq a t) (terpri str))
	    ((equal a "~PP") 
	     (terpri str)
	     (setq ppflg t))
	    (ppflg (pps a str)
		   (setq ppflg nil))
	    (t (princ a str))))))

(defun format (&optional args)
  (error "Function FORMAT not implemented; use FORMATL instead!"))

(defmacro with-file (str file form opt)
  "Open stream STR to FILE with option OPT, 
   evaluate FORM, always close stream afterwards"
  `(let ((,str (if ,file (openstream ,file ,opt))))
     (unwind-protect
	 ,form
       (if ,str (closestream ,str)))))

(defmacro with-open-file (filespec &rest body)
  "CommonLisp file opener"
  (let* ((pl(parsekeywordparams (cddr filespec) '(:direction)))
	 (str (car filespec)) 
	 (file (cadr filespec)))
    (list 'with-file str file
	  (prognify body)
	  (cond ((memq (car pl) '(nil :input)) "rb")
		((eq (car pl) :output) "wb")
		((eq (car pl) :append) "ab")
		(t (error "Illegal :DIRECTION in WITH-OPEN-FILE" (car pl)))))))

(defmacro with-output-file (str file form)
  "Open write stream STR to FILE, evaluate FORM, close stream afterwards"
  (list 'with-file str file form "wb"))

(defmacro with-input-file (str file form)
  "Open read stream STR to FILE, evaluate FORM, close stream afterwards"
  (list 'with-file str file form "rb"))

(defun read-file (file)
  "Read entire FILE and return as string"
  (with-input-file str file
		   (let ((res (opentextstream)) temp)
		     (while (neq (setq temp (read-charcode str)) '*eof*)
		       (princ-charcode temp res))
		     (textstreamstring res))))

(defmacro mapstream (stream reader mapper)
  `(do ((row (funcall ,reader ,stream)
	     (funcall ,reader ,stream)))
       ((eq row '*EOF*) nil)
     (funcall ,mapper row)))

(defmacro with-textstream (stream string &rest forms)
  "Bind variable STREAM to stream over STRING and evaluate FORMS"
  `(let ((,stream (maketextstream)))
     (princ ,string ,stream)
     (textstreampos ,stream 0)
     ,@ forms))

(defun popen (command)
  "Execute shell COMMAND and open stream on result. Temporary version."
  (system (concat command " > popen.out"))
  (openstream "popen.out" "r"))

(defmacro with-popen (command str form )
  "Execute FORM with STR bound to result stream of shell COMMAND 
   and close STR afterwards"
  `(let ((,str (popen ,command)))
     (unwind-protect ,form (closestream ,str))))

(defmacro dolists (bnds &rest body)
  "Like dolist except it carries out parallel traversal of several 
   lists. Stops at the end of the shortest and evaluates to t if all lists
   ended at the same time."
  (let* ((i 0) 
	 (vll (mapcar (f/l (bnd)
			   (list (car bnd) 
				 (pack '_ (setq i (1+ i)))
				 (cadr bnd))) 
		      bnds)
	      bnds))
    `(prog-let (,@(mapcar (function car) vll)
		  ,@(mapcar (function rest) vll))
	       (int-while (and ,@(mapcar (f/l (a) `(consp ,(second a))) 
					 vll))
			  ,@(mapcar (f/l (a)
					 `(setq ,(car a) (pop ,(cadr a)))) 
				    vll)
			  ,@body)
	       (and ,@(mapcar (f/l (a) `(eq nil ,(cadr a))) vll)))))

(defmacro putlast (l x)
  "Destructively insert X last in the list L and return 
   the concatenated list. Works even if L is nil."
  `(if ,l
       (let ((ptr ,l))
	 (while (cdr ptr) (pop ptr))(rplacd ptr (cons  ,x)) ,l)
     (setq ,l (list ,x))))

;;; Regression testing

(defglobal _regression-failed_ nil "Set by CHECKEQUAL when regression failed")
(defglobal _regression_ nil 
  "Errors caught in top loop reported as regression error on exit")

(defun check-regressions ()
  (cond 
   (_regression-failed_
    (formatl 
     t 
     "****************************************************************" t
     "********************* REGRESSION FAILED ************************" t
     "****************************************************************" t
     ))))

;;; Hooks:

(defun register-hook (variable form where)
  "Add FORM to list of forms in VARIABLE"
  (if (member form (eval variable)) nil
    (selectq where
	     (first (set variable (cons form (eval variable))))
	     (set variable (nconc1 (eval variable) form)))))

(defun after-rollin-hook (image)
  "Called by system initlializer after image has been initialized"
  (mapc #'eval after-rollin-forms))

(defun register-init-form (form &optional where) 
  "Regisgter form to be evaluated just after system is initialized"
  (register-hook 'after-rollin-forms form where))
         
(defglobal connect-forms nil)

(defun register-connect-form (form &optional where)
  "Register form to be evaluated at first a_connect call"
  (register-hook 'connect-forms form where))

(defglobal before-rollout-forms nil "Forms evaluated before saving image")

(defun register-rollout-form (form &optional where)
  "Register form to be evaluated just before saving an image"
  (register-hook 'before-rollout-forms form where))

(advise-around 'saveimage '(progn (mapc #'eval before-rollout-forms) *))
(advise-around 'rollout '(progn (mapc #'eval before-rollout-forms) *))

(defglobal shutdown-forms nil "Forms evaluated during system shutdown (quit)")

(defun register-shutdown-form (form &optional where)
  "Register form to be evaluate just before system is shutting down"
  (register-hook 'shutdown-forms form where))

; redefine QUIT to print regression banner and execute all shutdown forms
(advise-around 'quit 
	       '(progn
		  (check-regressions)
		  (mapc #'eval shutdown-forms)
		  *))

;;; Lisp symbol table access 

(defglobal **symbolhashtab**) ;;; The table of Lisp symbols

(defun mapsymbols (fn)
  "Apply FN on every symbol in image" 
  (maphash (f/l (pn s)(funcall fn s)) **symbolhashtab**))

(defun mapfunctions (fn)
  "Apply FN on every function in image"
  (maphash (f/l (pn s)(and s (getd s)(funcall fn s))) **symbolhashtab**))

(defglobal _CR_ "
" "End of line")

(defun firstn (n l)
  "Build a list of the N first elements in list L"
  (cond ((< n 1) nil)
	(t (cons (car l)
		 (firstn (1- n) (cdr l))))))

(defun intersectionl (l) 
  "Intersection of a list of lists."
  (cond 
   ((null l) nil)
   ((null (cdr l)) (car l))
   (t (intersection (car l) (intersectionl (cdr l))))))

(defun identity (x) x)

(movd 'defvar 'defparameter);; equivalent for now

(defun closurep (x)(eq (typename x) 'closure))

;;;; Dynamic loading of C modules ;;;;

(defglobal _persistent-extensions_ nil 
  "List of persistent loaded C extensions")
(defglobal _transient-extensions_ nil "List of transient loaded C extensions")

(defun load-extension (name persistent &optional noerror force)
  "Dynamically load the C 'extension' named NAME if not loaded earlier.
   An extension is dynamically loaded C module. 
   It is a .dll in Windows and a .so file in Linux.
   The file suffix .dll or .so is NOT in parameter NAME to make extensions OS 
   independent.
   The .dll or .so module may contain an 'initialization function': 
       EXPORT void a_initialize_extension(void *)
   The initialization function is called after the extension is loaded.
   If parameter PERSISTENT is non-nil the extension is automatically reloaded
   when the image is initialized.
   Errors are NOT raised if parameter NOERROR is non-nil.
   An already loaded extension will not be reloaded, unless FORCE is non-nil"
  (let* ((already-loaded (cond ((not (extension-loaded name)) nil)
                               ((or noerror force) t)
                               (t (error "Extension already loaded" name))))
	 (loadit (or force (not already-loaded))))
    (if loadit
	(let ((res (load-extension0 name (startup-dir) noerror)))
	  (cond (already-loaded nil)
	        (persistent (setq _persistent-extensions_ 
				  (nconc1 _persistent-extensions_ name)))
		(t (setq _transient-extensions_ 
			 (nconc1 _transient-extensions_ name))))
	  res)
      t)))

(defc 'load-dll nil) ;;obsolete

(defun extension-loaded (ext)
  (or (member ext _transient-extensions_)(member ext _persistent-extensions_)))

(defun reload-extensions ()
  "Reload all C extensions when image is initialized"
  (setq _transient-extensions_ nil)
  (mapc (f/l(x)(cond ((load-extension x t t t))
		     (t (formatl t "WARNING: Extension " x 
				 " could not be loaded" t))))
	_persistent-extensions_))

(register-init-form '(reload-extensions))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Extensions by Andrej Andrejev:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;labels macro

; http://www.franz.com/support/documentation/8.1/ansicl/dictentr/fletlabe.htm
(defmacro labels (defs &rest forms)	; the macro 
  (append (list 'let (mapcar #'car defs)) ; list of local function names
	  (mapcar (f/l (def) (label-to-setq def defs)) defs) ; SETQ list
	  (subfnsinlist defs forms)))	; LABELS body

;; Expansion examples:
;; (labels ((f (x) (1+ x))) (f 5)) =>
;; (let (f) 
;;   (setq f (function (lambda (x) (+ x 1)))) 
;;   (funcall f 5))
;;
;; (labels ((f (x) (1+ x))) (g (function f) 2)) =>
;; (let (f) 
;;   (setq f (function (lambda (x) (+ x 1)))) 
;;   (g (f/l (x) (funcall f x)) 2))

(defun label-to-setq (def defs)
  (list 'setq (first def) 
	(list 'function 
	      (list* 'lambda (second def) 
		     (subfnsinlist defs (cddr def))))))

(defun subfnsinlist (defs l)
  (mapcar (f/l (form) (subfnsinform defs form)) l))

(defun subfnsinform (defs code)
  (let (def)
    (cond ((atom code) code)
	  ((eq (car code) 'resetvar)
	   (cons 'resetvar  (cons (cadr code)
				  (subfnsinlist defs (cddr code)))))
	  ((eq (car code) 'selectq)
	   (cons 'selectq 
		 (cons (subfnsinform defs (cadr code))
		       (append (mapcar (f/l (cv) 
					    (cons (car cv) 
						  (subfnsinlist defs 
								(cdr cv))))
				       (butlast (cddr code)))
			       (list (subfnsinform defs (car (last code))))))))
	  ((eq (car code) 'checkequal)
	   (cons 'checkequal (cons (subfnsinform defs (cadr code))
				   (mapcar (f/l (match) (subfnsinlist defs 
								      match))
					   (cddr code)))))
	  ((atom (setq code (macroexpand code))) code)
	  ((eq (car code) 'quote) code);; (QUOTE ...)
	  ((and (eq (car code) 'function);; (FUNCTION <name>)
		(setq def (assq (second code) defs)))
	   ;; lookup a definition for the referenced function
	   (cond ((eq (second def) 'lambda);;open lambda
                  (list 'function (cdr def)))
                 (t;;if it is locally-defined - 
		  ;; convert to 
		  ;; (F/L (<args>) (FUNCALL <name> <args>))
		  (list 'f/l (second def)
			(list* 'funcall (first def) (second def))))))
	  (t (nconc (subfnsinfn defs (car code))
		    (subfnsinlist defs (cdr code)))))))

(defun subfnsinfn (defs fn)
  (let ((def (assq fn defs)))
    (cond (def (if (eq (second def) 'lambda) (list (cdr def));;open lambda
		 (list 'funcall fn)))
	  ((atom fn) (list fn))
	  ((eq (car fn) 'lambda);; (LAMBDA ...)
	   (list (list* 
		  ;; don't substitute function names inside 
		  ;; the list of arguments
		  (car fn)
		  (cadr fn)
		  (subfnsinlist defs (cddr fn)))))
	  (t (list (subfnsinform defs fn))))))

;; ================= other additions

;; http://www.franz.com/support/documentation/8.1/ansicl/dictentr/findfind.htm
(defun find (item list) (car (member item list)))

;; http://www.franz.com/support/documentation/8.1/ansicl/dictentr/removere.htm
(defun remove-if-not (test sequence)
  (cond ((null sequence) nil)
	((funcall test (car sequence))
	 (cons (car sequence) (remove-if-not test (cdr sequence))))
	(t (remove-if-not test (cdr sequence)))))

(defun delete-if (test sequence);; destructive
  (do ((seq1 sequence (cdr seq1)) (prev nil))
      ((null seq1) sequence)
    (if (funcall test (car seq1))
	(if prev (setf (cdr prev) (cdr seq1))
	  (setf sequence (cdr seq1)))
      (setq prev seq1))))

;; http://www.franz.com/support/documentation/8.1/ansicl/dictentr/intern.htm
(defun intern (string) (pack string))

;; Poor man's (format nil ...) function
(defun formats (&rest forms) (with-string s (apply #'formatl (cons s forms))))

(defun formati (prefix values postfix)
  (do ((val values (cdr val))
       (res ""))
      ((null val) res)
    (setq res (concat res prefix (mkstring (car val)) postfix))))

;;; Temporal functions

(defmacro time-spent (form)
  "Return time to evaluate FORM"
  `(let ((cl (clock)))
     , form
     (- (clock) cl)))

(defmacro time (form &optional message)
  "Print time to evaluate FORM, return value of FORM"
  `(let (_c _r)
     ,(if message (list 'formatl t "[" message " .. ") '(princ "["))
     (setq _c (clock))
     (setq _r ,form)
     (setq _c (- (clock) _c))
     (formatl t _c " s")
     (formatl t "]" t)
     _r))

(defun t-diff (t1 t2)
  "The difference in seconds between T1 and T2"
  (+ (- (timeval-sec t1)(timeval-sec t2))
     (* (- (timeval-usec t1)(timeval-usec t2)) 1.0e-06)))

(defun confirm-prompt (txt)
  "YES/NO prompt for TXT"
  (princ txt)(princ " ")
  (let ((rd (if _batch_ (print 'yes) (read))))
    (cond ((memq rd '(yes y)))
	  ((memq rd '(no n)) nil)
	  (t (formatl t "Answer Y, YES, N, or NO! NO assumed" t) nil))))

