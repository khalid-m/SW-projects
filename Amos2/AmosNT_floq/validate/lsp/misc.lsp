;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Cheng Xu, UDBL
;;; $RCSfile: misc.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/11/22 17:22:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: misc
;;; =============================================================
;;; $Log: misc.lsp,v $
;;; Revision 1.6  2013/11/22 17:22:10  chexu484
;;; vector projection function
;;;
;;; Revision 1.5  2013/11/20 19:38:38  chexu484
;;; new function myaggv
;;;
;;; Revision 1.4  2013/04/09 17:28:07  torer
;;; *** empty log message ***
;;;
;;; Revision 1.3  2013/03/25 15:09:26  torer
;;; Correct CSV reader
;;;
;;; Revision 1.2  2012/11/26 12:08:05  chexu484
;;; is-functiontype
;;;
;;; Revision 1.1  2012/10/25 15:03:46  chexu484
;;; a little profile on validation
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(osql "load_lisp(getenv('AMOS_HOME')+'/lsp/json.lsp');")

(defglobal _log-ht_ (make-hash-table :test (function equal)))       

(foreign-lispfn
 openlog ((Charstring filename) (Charstring mode)) ((Boolean))
 (let (fh)
   (setq fh (openstream filename mode))
   (setf (gethash filename _log-ht_) fh)))     

(foreign-lispfn
 write2log ((Object o) (Charstring filename)) ((Boolean))
 (let ((fh (gethash filename _log-ht_)))
   (pf o fh)))    

(foreign-lispfn
 closelog ((Charstring filename)) ((Boolean))
 (let ((fh (gethash filename _log-ht_)))
   (if fh (progn (closestream fh)
		 (remhash filename _log-ht_)))))

(foreign-lispfn 
 write2file
 ((Charstring filename) (Bag b)) ((Real) (Real))
 (let (fh (start-time (rnow)) (rowc 0) proc-time (firsttime t))
   (mapbag b
	   (f/l (row)
		(cond (firsttime
		       (setq proc-time (rnow))
		       (setq firsttime nil)))
		(cond ((equal rowc 0)
		       (setq fh (openstream filename "w"))))
		(1++ rowc)
		(print (car row) fh)))
   (cond ((> rowc 0)
	  (closestream fh)
	  (foreign-result (- (rnow) start-time) (- proc-time start-time)))
	 (t
	  (foreign-result (- (rnow) start-time) 0.0)))))

(defun somea (array fn)
  (dotimes (i (array-total-size array))
    (if (funcall fn (aref array i) i) (return T))))

(defun everya (array fn)
  (let ((res T))
    (dotimes (i (array-total-size array) res)
      (if (not (funcall fn (aref array i) i)) (setq res nil)))))

(defun readlines--+ (fno file delim row)
  (with-input-file str file
		   (let (row)
		     (while (not (eq (setq row (read-line str delim)) '*eof*))
		       (osql-result file delim row)))))

(defun projectv (v ind)
  (catch 'project
    (let (res (dim (length v)))
      (maparray ind (f/l (vi i)
			 (cond ((and (numberp vi)
				     (>= vi 0)
				     (< vi dim)
				     (aref v vi))
				(push (aref v vi) res))
			       (t (throw 'project nil)))))
      (listtoarray (nreverse res))))) 

(defun precision (n pcn)
  (let ((scale (expt 10.0 pcn)))
    (/ (floor (* n scale)) scale))) 

(defun precision-equal (n1 n2 x)
  (= (precision n1 x) (precision n2 x)))   

;; check if e is in l
(defun list-in (e l &optional eqfn x)
  (if (listp l)
      (catch 'list-in
	(mapc (f/l (el) (if (if eqfn (apply eqfn `(,e ,el ,x))
			      (= e el))
			    (throw 'list-in T))) l)))) 

(defun gcd (n1 n2)
  (let (temp)
    (setq n1 (floor n1))
    (setq n2 (floor n2))
    (if (or (= 0 n1) (= 0 n2)) (setq n2 0)
      (while (neq 0 (setq temp (mod n1 n2)))
	(setq n1 n2)
	(setq n2 temp)))
    n2))

(defun lcm (n1 n2)
  (/ (* n1 n2) (gcd n1 n2)))

(defun is-functiontype (o)
  (= _function_ (arg-type o)))

(defun myaggv--+ (fno bv fn)
  (let (argl res)
    (mapbag bv (f/l (e)
		    (cond ((or (null argl) (null res))
			   (setq argl (make-array (length (car e))))
			   (setq res (make-array (length (car e))))))
		    (maparray argl (f/l (arg i)
					(if (null arg) (seta argl i (tconc)))
					(tconc (elt argl i) (list (elt (car e) i)))))))
    (maparray res (f/l (o i)
		       (let (r)
			 (assignfunction fn (list (cons 'aggr_bag (car (elt argl i)))) '(r))
			 (seta res i r))))
    (osql-result bv fn res)))

(osql "create function myaggv(Bag of Vector bv, Function fn) -> Vector as foreign 'myaggv--+';")


(defun projectsetnil--+ (fno v ind r)
  (let* ((dim (length v))
	 (res (make-array dim)))
    (maparray ind (f/l (vi i)
		       (cond ((and (numberp vi)
				   (>= vi 0)
				   (< vi dim))
			      (seta res vi (elt v vi))))))
    (osql-result v ind res)))
 
(osql "
  create function project_setnil(Vector v, Vector of Number indl) -> Vector
  /* Project vector v on indexes in indl and set all the others to nil */
  as foreign 'projectsetnil--+';")