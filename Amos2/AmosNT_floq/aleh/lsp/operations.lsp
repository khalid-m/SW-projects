;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Ruslan Fomkin, UDBL
;;; $RCSfile: operations.lsp,v $
;;; $Revision: 1.14 $ $Date: 2007/11/11 09:48:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Implementation of some vector arithmethics and defining of foreign 
;;;  functions for amosql.
;;;              
;;; ===========================================================================
;;; $Log: operations.lsp,v $
;;; Revision 1.14  2007/11/11 09:48:53  ruslan
;;; correct types for aggregates
;;;
;;; Revision 1.13  2007/09/19 09:39:58  ruslan
;;; minagg2 is implemented. it runs on bag of tuples with 2 elements. returns a tuple with smallest first element in the bag
;;;
;;; Revision 1.12  2007/07/19 11:26:21  ruslan
;;; bag.function.minagg->object is added for efficiency
;;;
;;; Revision 1.11  2007/06/18 09:46:27  ruslan
;;; atleast(n,sq) returns TRUE if n<=0
;;;
;;; Revision 1.10  2007/03/01 14:55:07  ruslan
;;; system sqrt makes problems in stream aproach
;;;
;;; Revision 1.8  2007/01/26 10:22:26  ruslan
;;; function for comparing reals in regression tests are added
;;;
;;; Revision 1.7  2006/08/28 13:21:33  ruslan
;;; a function to count time of executing a form is added. it is based on timer macro
;;;
;;; Revision 1.6  2006/05/03 10:42:17  ruslan
;;; sqrt_pos that returns only one value is implemented and used instead of sqrt, which returns 2 values
;;;
;;; Revision 1.5  2006/04/28 09:46:31  ruslan
;;; scalar product is removed, because it is already implemented in kernel
;;;
;;; Revision 1.4  2006/03/20 07:52:43  ruslan
;;; reorganization of files: thereare is moved into lsp/operations.lsp
;;;
;;; Revision 1.3  2006/02/16 09:00:30  ruslan
;;; Functions Eta, Pt, and Magnitude (often called) are rewritten in Lisp
;;;
;;; ===========================================================================

(defun sqrt-pos (obj x y)
  (cond ((= x 0) (osql-result x x))
	((> x 0) (osql-result x (sqrt x)))))

(defun plus-vec(fno v1 v2 res)
  "Sum up two vectors of same size"
  (cond ((= (array-total-size v1) (array-total-size v2))
		 (let ((v (copy-array v1)))
		   (dotimes (i (array-total-size v))
			 (seta v i (+ (elt v1 i) (elt v2 i))))
		   (osql-result v1 v2 v)))
		(t (amos-error "Sizes of input vectors are different"))))

(defun null-vec(fno v res)
  "Creates null vector with size of given vector"
  (let ((v0 (copy-array v)))
	(dotimes (i (array-total-size v0))
	  (seta v0 i 0))
	(osql-result v v0)))

(defun logn(fno x res)
  "Natural logarithm as foreign function for osql"
  (cond ((> x 0) (osql-result x (ln x)))
		(t (osql-result x nil))))

(defun atan2f(fno x y res)
  "atan2 as foreign function for osql"
  (osql-result x y (atan2 x y)))

(defun ceilingf(fno x res)
  "Ceiling as foreign function for osql"
	(osql-result x (ceiling x)))

(defun cosf(fno x res)
  "Cosine as foreign function for osql"
	(osql-result x (cos x)))

(defun magnitude (fno v res)
  "Magnitude of a given 3D vector of numbers"
  (let* ((x (elt v 0))(y (elt v 1))(z (elt v 2))
	 (r (sqrt (+ (* x x)(+ (* y y) (* z z))))))
    (osql-result v r)))

(defun eta (fno v res)
  "Eta of a given 3D vector of numbers"
  (let* ((x (elt v 0))(y (elt v 1))(z (elt v 2))
	 (mag (sqrt (+ (* x x)(+ (* y y) (* z z)))))
	 (r (* 0.5 (ln (/ (+ mag z) (- mag z))))))
    (osql-result v r)))

(defun pt (fno v res)
  "PT of a given 3D vector of numbers"
  (let* ((x (elt v 0))(y (elt v 1))(r (sqrt (+ (* x x) (* y y)))))
    (osql-result v r)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Count with constant written efficiently by Tore
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn atleast ((integer n)(bag b))()
		(let ((cnt 0))
		  (cond ((>= 0 n) (osql-result n b))
			((catch 'atleast
			   (mapbag b (f/l (row)
                                          (1++ cnt)
					  (if (= cnt n)(throw 'atleast t)))))
			 (osql-result n b)))))

(set-resulttypesfn
 (foreign-lispfn minagg ((bag b)(function fn))((object r))
		 (let (minval minobj val)
		   (mapbag b 
			   (f/l (row)
				(setq val 
				      (aref (first (callfunction fn row))0))
				(cond 
				 ((null minval) 
				  (setq  minobj row)
				  (setq  minval val))
				 ((list< val minval)
				  (setq minobj row)
				  (setq minval val)))))
		   (and minobj (foreign-result (first minobj)))))
 'transparent-collection-resulttypes)

(foreign-lispfn minagg2 ((bag b)) ((number r)(object n))
		"Return a tuple with smallest first element from a bag
of tuples."
		(let (min)
		  (mapbag b
			  (f/l (row)
			       (cond ((null min)
				      (setq min row))
				     ((list< (car row) (car min))
				      (setq min row)))))
		  (and min (foreign-result (car min) (second min)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Timer function returning time, based on (timer form)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro timer2 (form)
  "Return time to evluate FORM"
  `(let ((__ (clock))(r , form))
     (- (clock) __)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Help functions for regression test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun r2i10n (x n)
  "Returns integer part of real x multiplied with 10 in power n"
  (floor (dotimes (i n)(setq x (* x 10)))))
  
(defun lr2i10n (lx n)
  "Returns list of integer parts of every real x from list lx multiplied with 10 in power n"
  (mapcar (f/l (x) (r2i10n x n)) lx))

(defun lr2i10nl (lx ln)
  "Returns list of integer parts of every real x from list lx multiplied with 10 in power n"
  (mapcar (f/l (x n) (r2i10n x n)) lx ln))
