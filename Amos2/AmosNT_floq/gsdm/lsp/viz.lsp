;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GSDM 
;; Milena Koparanova, 07.10.2003
;; Teletype visualization of vector of complex numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun discr_value (x min max dl)
"Given a real number x, the min and max values possible and the number of discrete levels, compute the discrete level for x"
;; min=0.0, max =100.0, dl = 5, x=24.0 -> 2
(let ((lsz (/ (- max min) dl))
      (i 1))
  (while (> x (+ min (* i lsz))) (1++ i))
  i))

 
(defun compute_histogram (x nb min max dl) 
"Compute an approximation of the array x of real. nb is number of
buckets, dl number of discrete values, min and max define the interval
of values"

(let* ((n (array-total-size x))
      (bsize (/ n nb)) ;size of 1 bucket, assuming n mod nb=0
      (avg (make-array nb))
      (davg (make-array nb))
      cb) ;current bucket

  (dotimes (i nb) (seta avg i 0.0))

  (dotimes (i n) 
    (setq cb (/ i bsize))
    (seta avg cb (+ (aref avg cb) (aref x i)))
  )

  (dotimes (i nb) 
    (seta avg i (/ (aref avg i) bsize)))

  (dotimes (i nb) 
    (seta davg i (discr_value (aref avg i) min max dl)))
  ;; return an array of discrete values for nb buckets
  davg))


(defun tty_viz (x nb symb min max dl)
"Compute an approximation of the array x of real. Form a string with symbols: for each bucket its symbol is printed a number of times equal to the discrete value for the bucket"

(let ( bsymb                ;;stores a vis symbol for each bucket
      (davg (make-array nb)) ;; discrete value per bucket
      (row (maketextstream (* nb dl))))
;; to do: check if the size of the array is devided by nb without remainder

;; set visualization symbols
  (setq bsymb (listtoarray (explode symb))) 

;; check if nb * dl fits into a row
  (if (> (* nb dl) 80) 
      (setq dl (/ 80 nb)))

;; compute bucket values 
  (setq davg (compute_histogram x nb min max dl))

;;  (dotimes (i nb) 
;;    (print (aref davg i) ))

  (dotimes (i nb) 
    (dotimes (k (aref davg i))
      (princ (aref bsymb i) row)))

  (print (mkatom (textstreamstring row)))
))

;;;;;;;;foreign lisp function for tty visualization
(defun tty_viz+++ (fnobj x nb dl)
  (let ((symb "+.*-#=%&abcdefg")
	(min -11.0)  ;;min value for a particular generator
	(max 11.0))

    (tty_viz x nb symb min max dl)

;;    (osql-result x nb dl)
))

(osql "create function tty_viz(vector of real x, integer nbuckets, integer dlevels) -> boolean as foreign 'tty_viz+++';")

(defun tty_vizc+++ (fnobj x nb dl)
"Vector of complex - get the real part only"
  (let* ((symb "+.*-#=%&abcdefg")
	(min -11.0)  ;;min value for a particular generator
	(max 11.0)
	(n (array-total-size x))
	(xr (make-array n )))
    
    (dotimes (i n) 
      (seta xr i (getreal (aref x i))))

    (tty_viz xr nb symb min max dl)

    (osql-result x nb dl)))

(osql "create function tty_viz(vector of complex x, integer nbuckets, integer dlevels) -> boolean as foreign 'tty_vizc+++';")

(osql "create function tty_viz(vector x, integer nbuckets, integer dlevels) -> boolean as foreign 'tty_vizc+++';")

(defun tty_viz_row (x nb symb min max dl)
"Compute an approximation of the array x of real. Form a string with symbols: for each bucket its symbol is printed a number of times equal to the discrete value for the bucket"

(let ( bsymb                ;;stores a vis symbol for each bucket
      (davg (make-array nb)) ;; discrete value per bucket
      (row (maketextstream (* nb dl))))
;; to do: check if the size of the array is devided by nb without remainder

;; set visualization symbols
  (setq bsymb (listtoarray (explode symb))) 

;; check if nb * dl fits into a row
  (if (> (* nb dl) 80) 
      (setq dl (/ 80 nb)))

;; compute bucket values 
  (setq davg (compute_histogram x nb min max dl))

;;  (dotimes (i nb) 
;;    (print (aref davg i) ))

  (dotimes (i nb) 
    (dotimes (k (aref davg i))
      (princ (aref bsymb i) row)))

  (mkatom (textstreamstring row))
))


(defun tty_viz_rowc+++ (fnobj x nb dl row)
"Vector of complex - get the real part only"
  (let* ((symb "+.*-#=%&abcdefg")
	(min -11.0)  ;;min value for a particular generator
	(max 11.0)
	(n (array-total-size x))
	(xr (make-array n )))
    
    (dotimes (i n) 
      (seta xr i (getreal (aref x i))))

   (print (tty_viz_row xr nb symb min max dl))
  
))

(osql "create function tty_viz_row(vector x, integer nbuckets, integer dlevels) ->boolean as foreign 'tty_viz_rowc+++';")

(defun tty_viz_rowc+++- (fnobj x nb dl row)
"Vector of complex - get the real part only"
  (let* ((symb "+.*-#=%&abcdefg")
	(min -11.0)  ;;min value for a particular generator
	(max 11.0)
	(n (array-total-size x))
	(xr (make-array n )))
    
    (dotimes (i n) 
      (seta xr i (getreal (aref x i))))

   (setq row (tty_viz_row xr nb symb min max dl))
   (osql-result x nb dl row)
  
))

(osql "create function tty_encode(vector x, integer nbuckets, integer dlevels) ->charstring row as foreign 'tty_viz_rowc+++-';")
