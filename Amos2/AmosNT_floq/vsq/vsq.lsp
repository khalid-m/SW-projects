;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Lars Melander, UDBL
;;; $RCSfile: vsq.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/12/14 18:14:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Type definitions and functions for (LabView)
;;;              fixstreams and visualization, and VSQ-specific
;;;              stream functions.
;;; =============================================================
;;; $Log: vsq.lsp,v $
;;; Revision 1.3  2011/12/14 18:14:31  larme597
;;; *** empty log message ***
;;;
;;; Revision 1.2  2011/11/05 11:45:30  larme597
;;; Added headers.
;;;
;;; =============================================================

(foreign-lispfn notnull ((object o)) ((boolean r))
  (foreign-result (not (null o))))

(set-resulttypesfn
 (osql "create function stopafter(bag, integer) -> bag of object
  as foreign 'stopafter--+';")
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

(defun fixstream-labview--+ (fno vi str r)
  (do ((f (fixstream-create vi str)))
      ()
    (apply 'osql-result vi str (arraytolist (fixstream-call f)))))

(defmacro visualizeextract (x)
  `(osql-result vi_array s (visualize-call v ,x)))

(defun visualize-labview-- (fno vi_array s r)
  (let ((v (visualize-create vi_array)))
    (mapbag s 'visualizeextract)
    (sleep 5)))

(defun get-stream-arity (s)
  (length (type-parameters (arg-type s))))

(defun sink-stream (fno s r)
  (mapbag s (f/l (x) nil)))

(defun sink-vector (fno vs r)
  (let* ((size (array-total-size vs))
	 (cov (make-array size)))
    (dotimes (i size)
      (seta cov i (coroutine 'mapbag
			     (list (aref vs i) 'co-yield))))
	(do ()
	    ((co-anyterminatedv cov))
	  (co-vresumev cov))))
