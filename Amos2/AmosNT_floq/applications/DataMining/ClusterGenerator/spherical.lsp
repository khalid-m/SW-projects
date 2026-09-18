;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013, Andrej Andrejev, UDBL
;;; $RCSfile: spherical.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/06/21 21:00:12 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Spherical cluster generator
;;; =============================================================
;;; $Log: spherical.lsp,v $
;;; Revision 1.3  2013/06/21 21:00:12  andan342
;;; Added random_init_by_hash() function to initialize random number generator
;;;
;;; Revision 1.1  2013/05/27 12:58:20  andan342
;;; Spherical Cluster generator
;;;
;;;
;;; =============================================================

(defparameter pi 3.1415926)

(defparameter rnd-granularity 1000)

(defun rnd-01 () (/ (* 1.0 (random rnd-granularity)) rnd-granularity))

(defun rnd-11 () (* (- (rnd-01) 0.5) 2))

(defun norm-vector-d (v)
  (let ((sum 0))
    (dotimes (i (length v))
      (incf sum (aref v i)))
    (when (<= sum 0) (error "Sum should be positive"))
    (dotimes (i (length v))
      (setf (aref v i) (/ (* 1.0 (aref v i)) sum)))
    v))

; (defun uniform-inv-dist (r) r)

; (defstruct spherical-cluster center radius cardinality)

(defun gen-spherical-cluster-sample (center radius)
  (let ((r (* radius (rnd-01))) ; [0 .. r], density function can be used here for non-uniform clusters
	(phi (* 2 pi (rnd-01))) ; [0 .. 2*pi]	  
	(sample (make-array 2)))
    (setf (aref sample 0) (+ (aref center 0) (* r (cos phi))))
    (setf (aref sample 1) (+ (aref center 1) (* r (sin phi))))
    sample))

(defun gen-spherical-----+ (fno samples clusters r-min r-max card-rv res)
  (unless (and (> samples 0) (> clusters 0))
    (error "Numbers of samples and clusers should be positive"))
  (unless (and (<= r-min r-max) (<= r-max 0.5))
    (error "r-min <= r-max <= 0.5"))
  (when (or (< card-rv 0) (> card-rv 1))
    (error "Relative variance of cluster cardinality should be in [0..1]"))
;  (when (or (< outliers 0) (>= outliers 1))
;    (error "Fraction of outliers should be in [0..1)"))
  (let* ((card-shares (make-array clusters))
	 (radia (make-array clusters))
	 (card-sum 0))
    (dotimes (k clusters)
      (setf (aref radia k) (+ r-min (* (- r-max r-min) (rnd-01)))) ; r in [rMin .. rMax]
      (setf (aref card-shares k) (* (+ 1 (* card-rv (rnd-11))) (expt (aref radia k) 2)))) ; shares proportional to volumes
    (norm-vector-d card-shares)  
    (dotimes (k clusters) ; generate clusters
      (let ((center (make-array 2))
	    (card (if (< k (1- clusters)) (round (* samples (aref card-shares k)))
		    (- samples card-sum))) ; avoid getting less samples due to rounding
	    (r (aref radia k)))
	(incf card-sum card)
	(setf (aref center 0) (+ r (* (rnd-01) (- 1 (* 2 r))))) ; [r .. 1-r]
	(setf (aref center 1) (+ r (* (rnd-01) (- 1 (* 2 r))))) ; [r .. 1-r]
	(formatl nil "Cen=(" (aref center 0) ", " (aref center 1) "), R=" r " : " card " samples" t) 
	(dotimes (i card) ; generate samples in this cluster
	  (osql-result samples clusters r-min r-max card-rv
		       (gen-spherical-cluster-sample center r)))))))

(osql "create function GenSpherical(Integer samples, Integer clusters, Real rMin, Real rMax, Real cardRV) -> Bag of Vector of Real
  as foreign 'gen-spherical-----+';")

(foreign-lispfn random_init_by_hash ((Object x)) ()
   (randominit (sxhash x)))


	
	

