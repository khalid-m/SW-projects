(defun fft (x)
  "Calculates fft on array of complex numbers "
  (cond ((not (arrayp x)) nil)
	((eq (array-total-size x) 1) x)
	((prog-let* ((n (array-total-size x))
		     (n2 (/ n 2)) (k nil)
		     (p (make-array n2))
		     (q (make-array n2))
		     (y (make-array n)))
           ;;; reorder odd and even complex numbers
		    (dotimes (k n2)
		      (seta p k (aref x (* 2 k)))
		      (seta q k (aref x (+ (* 2 k) 1))))
           ;;; fft on the subsequences
		    (setq p (fft p))
		    (setq q (fft q))
           ;;;compute the whole sequence
		    (dotimes (k n)
		      (seta y k (sumcomplex 
				 (aref p (mod k n2))
				 (multcomplex (ncomplex_root_pow n k) 
					      (aref q (mod k n2))))))
		    (return y)
		    ))))

(defun fft1 (x)
  "Calculates fft on array of complex numbers "
  (cond ((not (arrayp x)) nil)
	((eq (array-total-size x) 1) x)
	((prog-let* ((n (array-total-size x))
		     (n2 (/ n 2)) (k nil) p q y)

           ;;; reorder odd and even complex numbers
		    (setq p (fft-part x 2 0))
		    (setq q (fft-part x 2 1))
		    
           ;;; fft on the subsequences
		    (setq p (fft1 p))
		    (setq q (fft1 q))
           ;;;compute the whole sequence
		    (setq y (fft-combine p q))
		    (return y)))
	))



;;; eventually precompute the matrix w

(defun test_pow2 (x)
  "Test if x is a number = power of 2"
  (cond ((not (integerp x)) nil)
	((eq x 1) t)
	((and (eq (mod x 2) 0)
	      (test_pow2 (/ x 2))))
	))

;;;
;;;(defun test_fft (n)
;;;  (let ((w (ncomplex_root n))
;;;        (x (make-array n)))
;;;     (dotimes (k n)
;;;       (seta x k (make-complex 1.0 0.0)))
;;;     (fft x w)
;;;))

;;; FFT as Amos foreign function
;;; The size of the vector must be power of 2!

(defun trunc-complex-array (x)
  (let* ((n (array-total-size x))
	 (a (make-array n)))
    (dotimes (i n)
      (seta a i (trunccomplex (aref x i) 1)))
    a))


(defun fft+- (fnobj x y)
  (let* ((n (array-total-size x))
	 )
    (if (test_pow2 n)
	(osql-result x (trunc-complex-array (fft1 x)))
      (osql-result x x))
    ))
	   
(osql "create function fft(vector of complex x) -> vector of complex y
as foreign 'fft+-';")

;;; generates window for fft operation (sin curve)
(defun pi () 3.14159)

(defun fft_window+- (fnobj n x)
  (let* ( (x (make-array n))
	  (n1 (- n 1))
	  (delta (/ (pi) n1)))
    (seta x 0 0.0)
    (seta x n1 0.0)
    (dotimes (i n1)
      (seta x i (sin (* i delta))))

    (osql-result n x))
  )

(osql "create function fft_window(integer sz) -> vector of real v
as foreign 'fft_window+-';")
