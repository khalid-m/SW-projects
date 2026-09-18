(defun pi () 3.14159)

(defun make-array2dim (n m)
  (let (ar)
    (setq ar (make-array n))
    (dotimes (i n)
       (seta ar i (make-array m)))
  ar))

(defun seta2 (ar i j x)
  (seta (aref ar i) j x))
(defun aref2 (ar i j)
  (aref (aref ar i) j))


(defun polarize-vectors (ts b0 b1 b2)
"Compute polarization for 3 vectors of complex numbers. 
Returns list of 6 arrays of real numbers, one array for each parameter "
  (let* ((nn (array-total-size b0))
	 (phi (make-array nn))
	 (theta (make-array nn))
	 (I (make-array nn))
	 (Q (make-array nn)) 
	 (U (make-array nn))
	 (V (make-array nn)))

    (dotimes (n nn) 
      (let ( v0 v1 v2 d phi1 theta1
	    r s br u1)

      (setq v0 (* 2 (getimag (multcomplex (aref b2 n) (conj (aref b1 n))))))
      (setq v1 (* 2 (getimag (multcomplex (aref b0 n) (conj (aref b2 n))))))
      (setq v2 (* 2 (getimag (multcomplex (aref b1 n) (conj (aref b0 n))))))

;;    (print v0) (print v1)(print v2)

      (if (equal v0 0.0) (setq phi1 (/ (pi) 2))
	(setq phi1 (atan (/ v1 v0))))
      (setq d (sqrt (+ (* v0 v0) (+ (* v1 v1) (* v2 v2)))))
      (if (null (equal d 0.0))
	  (setq theta1 (acos (/ v2 d)))
	(setq theta1 0.0)
	)
;;    (print phi) (print theta)

    ;;;calculate rotation matrix
    (setq r (make-array2dim 3 3))
    (seta2 r 0 0 (* (cos theta1) (cos phi1)))
    (seta2 r 0 1 (* (cos theta1) (sin phi1)))
    (seta2 r 0 2 (minus (sin theta1)))
    (seta2 r 1 0 (minus (sin phi1)))
    (seta2 r 1 1 (cos phi1))
    (seta2 r 1 2 0.0)
    (seta2 r 2 0 (* (sin theta1) (cos phi1)))
    (seta2 r 2 1 (* (sin theta1) (sin phi1)))
    (seta2 r 2 2 (cos theta1))

;;    (print r)
    (setq br (make-array 3))
    ;; calculate the rotated vector br
    (dotimes (j 3)
      (setq s (sumcomplex (multcomplex (aref2 r j 0) (aref b0 n))
			  (multcomplex (aref2 r j 1) (aref b1 n))))
      (setq s (sumcomplex s
			  (multcomplex (aref2 r j 2) (aref b2 n))))
      (seta br j s))

;;    (print (aref br 0)) (print (aref br 1)) (print (aref br 2))

    (seta  phi n phi1)
    (seta theta n theta1) 
    (seta I n (getreal (sumcomplex (multcomplex (aref br 0) (conj (aref br 0)))
			(multcomplex (aref br 1) (conj (aref br 1))))))
    (seta Q n (getreal (subcomplex (multcomplex (aref br 0) (conj (aref br 0)))
			(multcomplex (aref br 1) (conj (aref br 1))))))

    (setq  u1 (multcomplex (aref br 0) (conj (aref br 1))))
    (seta  V n (* 2 (getimag u1)))
    (seta  U n (* 2 (getreal u1)))
    ;; (print I) (print Q)
    ;;(print U) (print V)
    ))
    (listtoarray (list ts phi theta I Q U V))
))

(defun polarizationbbbf (fnobj ts b0 b1 b2 res)
  (osql-result ts b0 b1 b2 (polarize-vectors ts b0 b1 b2))
)

(osql "create function polarization (timeval ts,
                                     vector of complex b0,
                                     vector of complex b1,
                                     vector of complex b2)->
          vector res as foreign 'polarizationbbbf';")

(defun subarray (x l h)
"Creates an array from elements of x at positions between l low and h high"
  (let ((n (array-total-size x)) a nn)
    (cond ((not (and (integerp l) (integerp h)
		     (< l n) (>= l 0) (< h n) (>= h 0)
		     (<= l h))) nil)
	  ((setq nn (1+ (- h l)))
	   (setq a (make-array nn))
	   (dotimes (k nn)
	     (seta a k (aref x (+ k l))))
	   a))
))

(defun vector-rangebbbf (fnobj x l h res)
  (osql-result x l h (subarray x l h))
)
