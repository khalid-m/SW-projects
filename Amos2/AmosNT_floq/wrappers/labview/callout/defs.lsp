
(set-resulttypesfn
 (osql "create function stopafter(bag, integer) -> bag of object as foreign 'stopafter--+';")
 'transparent-collection-resulttypes)

(defun print-vi (x str)
  (princ "#vi#" str))

(createliteraltype 'vi '(object) 'vi 'print-vi)

(defun set-fixstream-types (fno args)
  (let ((arr (string-explode (car (last args)) ","))
	lst
	typ)
    (dolist (l arr)
      (if (string-find l "[")
	  (setq typ (gettypenamed 'numarray))
	(cond ((= l "i2")
	       (setq typ (gettypenamed 'integer)))
	      ((= l "i4")
	       (setq typ (gettypenamed 'integer)))
	      ((= l "d")
	       (setq typ (gettypenamed 'real)))
	      (t
	       (amos-error "Type " l " not defined"))))
      (setq lst (cons typ lst)))
    (reverse lst)))

(set-resulttypesfn
 (osql "create function fixstream(vi, charstring) ->
bag of object as foreign 'fixstream-labview--+';")
 'set-fixstream-types)

(defun fixstream-labview--+ (fno vi str)
  (do ((f (fixstream-create vi str)))
      ()
    (apply 'osql-result (cons vi (cons str (arraytolist (fixstream-call f)))))))

(defun visualize-labview-- (fno vi_array s)
  (let ((v (visualize-create vi_array)))
    (mapbag s
	    (f/l (x)
		 (osql-result vi_array s (visualize-call v x))))))

(defun extract-+ (fno vs)
  (let* ((size (array-total-size vs))
	 (cov (make-array size)))
    (dotimes (i size)
      (seta cov i (coroutine 'mapbag
			     (list (aref vs i) 'co-yield))))
    (do ()
	((co-anyterminatedv cov))
      (osql-result vs (co-vresumev cov)))))
