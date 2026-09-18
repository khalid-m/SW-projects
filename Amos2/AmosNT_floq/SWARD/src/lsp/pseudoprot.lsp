(defun cntc (l)
  "Calculates the number of primitive predicates in expression"
  (cond ((or (equal (car l) 'AND) (equal (car l) 'OR))
	 (let ((s 0))
	   (dolist (x (cdr l))(setq s (+ s (cntc x)))) s))
	(t 1)))                       


(defun parteval (pred fv)
  "Top level function"
  (cond ((atom pred) pred)
        ((andp (car pred))(andify (parteval-and (cdr pred) fv)))
        ((orp (car pred))(orify (parteval-or (cdr pred) fv)))
        (t (andify (parteval-and (list pred) fv)))))

(defun parteval-and (andl fv)
  "Partial evaluate AND expression with free variables FV.
   Returns symbol true, false or possibly changed AND exp."
  (let ((chflg t);;set chflg true 
	pr npr)
    (while chflg;;while chflg
      (if (equal andl nil) (return (setq andl 'true)));;if AND exp empty return symbol true
      (setq chflg nil);;set chflg false
      (dolist (pr andl);;go through AND exp (both simple and OR exp pr)
	;;(help)
	(cond ((and (listp pr)(orp (car pr)));;if OR exp 
	       (setq npr (parteval pr (addfv andl fv)));;try to partial evaluate OR exp
	       (cond ((equal npr 'false)(return (setq andl 'false)));;return symbol false
		     ((not (equal npr pr))(progn (setq andl (append3 (remove pr andl) npr)) 
						 (setq chflg t)));;set chflg true
		     (t nil)))
	      (t (if (and (listp pr) (partial-evaluatable pr));;if simple pr and partial evaluatable
		     (cond ((equal (known-key-part-length (cdr pr))(length (cdr pr)));;if all args bound to constants
			    (if (probe-query pr);;if pr => true
				(setq andl (remove pr andl));;rem pr
				;;(progn (setq andl (remove pr andl))(setq chflg t));;rem pr, mark ch !!!är det nödvändigt att sätta chflg när predikat tas bort???
			      (return (setq andl 'false))));;set AND exp to symbol false
			   (t;;else if some free vars
			    (let* ((res (probe-query pr)) 
				   (count (if (equal res 'fail) 2 (length res)));;res != fail => probe-query succeeds 
				   vbind c v)    
			      (cond
			       ((< count 1) (return (setq andl 'false)));;res < 1 means fail
			       ((= count 1) (progn 
					      (if (setq vbind;;res = 1 means subst or infer
							(car (mapcar (f/l (r)
									  (mapcan (f/l (c v) 
										       (if (osql-constantp v) nil 
											 (list _=_ c v)))
										  r (subset (cdr pr) 
											    (function symbolp))))
								     res)))
						  (if (in (car (last vbind)) fv);;if v a free var
						      (setq andl (append3 (remove pr andl) vbind));;rem pr, add eq 
						    ;;else rem pr and substitute
						    (setq andl (subst (second vbind) (third vbind) (remove pr andl)))))
					      (setq chflg t)));;res = 1 => set chflg true
			       (t nil))))))))
	(if chflg (return nil)))
      ;;(help)
      )
    andl))

(defun parteval-or (orl fv)
  "Partial evaluate OR exp with free variables FV."
  (let (npr)
    (dolist (pr orl);;go through OR exp
      ;;(print orl)
      (setq npr (parteval pr fv));;we must add a list layer since parteval andify return expression e.g. ((x=4))->(x=4)
      (cond ((equal npr 'false) (setq orl (remove pr orl)));;rem pr
            ((equal npr 'true)(return (setq orl 'true)));;;if npr = true -> orl = true. This is set semantics!!
	    ((not(equal npr pr))(setq orl (append3 (remove pr orl) npr)));;substitute pr for changed pr
	    (t nil));;do nothing (e.g. pr eq true)
      (if (null orl) (return (setq orl 'false))));;if OR exp empty return symbol false
    orl))
	      
;;; Help functions
(defun addfv (andl fv)
 "Add to fv free variables from outmost level in andl that are not already in fv"
 (dolist (pr andl)
   (if (not (and (listp pr)(orp (car pr))))
       (dolist (e (cdr pr))
	 (if (symbolp e) (setq fv (cons e fv))))))
 fv)

(defun append3 (l pr)
  (append l (list pr)))

(defun andify2 (pred)
  (if (> (length pred) 1) (cons 'AND pred) pred))

(defun orify2 (pred)
  (if (> (length pred) 1) (cons 'OR pred) pred))

(defun known-key-part (argl)
  "Returns list of constants in predicate arguments"
  (remove nil (mapcar (f/l (x) (if (osql-constantp x) x)) argl)))

(defun known-key-part-length (argl)
  (let ((count 0))
    (dolist (arg (known-key-part argl))(setq count (+ count 1))) count))

(defun partial-evaluatable (pred)
  "Returns true if PRED declared partial evaluatable"
  (and (listp pred) 
       (oid-p (car pred))
       (ct_executablep (car pred))))

(defun probe-query (pred)
  (let* ((bpat (probe-bpat (cdr pred)))
         (fno (the-tbr-function (if (relationp (car pred))
                                    (getobject (car pred) 'predof)
				  (car pred)) 
				bpat t)))
    (cond ((null fno) 'fail);;no TBR fn applicable 
	  (t (getfunction 
	      fno 
              (known-key-part (cdr pred)))))))

(defun probe-bpat (argl)
  "Return binding pattern for probing arguments"
  (mapcar (f/l (x)(if (osql-constantp x) '- '+)) 
	  argl)
  )

(defun get-vars (l)
    (cond ((andp (car l))(get-and-vars (cdr l)))
	  ((orp (car l))(get-or-vars (cdr l)))
	  (t (get-and-vars (list l)))))

(defun get-and-vars (l)
  (let (fv)
    (dolist (e l)
      (if (listp e)
	  (cond ((orp (car e)) (setq fv (cons (get-vars e) fv)))
		(t (setq fv (append fv (remove nil (mapcar (f/l (x) (if (symbolp x) x)) (cdr e)))))))))
    fv))

(defun get-or-vars (l)
  (let (fv)
  (dolist (e l)
    (setq fv (append fv (get-vars e))))
  fv))

(defun flatten-var-list (l)
  (let (fl)
    (dolist (e l)
      (cond ((atom e) (setq fl (append (list e) fl)))
	    (t (setq fl (append e fl)))))
    fl))

(defun format-var-list (l)
  (let (tl)
    (dolist (e l)
      (if (atom e) (progn (setq tl (append (list e) tl)) (setq l (remove e l)))))
    (mapcar (f/l (x) (unique x))(cons tl l))))

(defun create-var-hash (l)
  (let (ht v)
    (setq ht (make-hash-table))
    (dolist (e l)
      (setq v (gethash e ht))
      ;;(print e)
      ;;(print v)
      (if v (puthash e ht (+ v 1))(puthash e ht 0)))
    ht))

(defun addfv (l fv)
 "Function takes a list of predicates and free variables and 
  check for every OR expression in an AND expression if any variables 
  should be added to list of free variables.

  Logic: If any variable in an OR-in-AND expression exists in some other 
         conjunct of the outer AND expression then do not substitute variable
         => add variable to list of free variables"
    (maphash (f/l (key val) (if (> val 0) (setq fv (cons key fv)))) 
	     (create-var-hash (flatten-var-list (format-var-list (get-vars l))))) fv)


