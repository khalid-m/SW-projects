;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Erik Zeitler, UDBL
;;; $RCSfile: sumvectors.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/11/02 17:36:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Aggregate sum over a bag of vectors
;;; =============================================================
;;; $Log: sumvectors.lsp,v $
;;; Revision 1.1  2009/11/02 17:36:54  zeitler
;;; aggregation function
;;; sumvectors(bag of vector of number) -> vector of number
;;;
;;; =============================================================

(defun vadd (v w)
  (let ((r (make-array (array-total-size v))))
    (maparray v (f/l (x i)
		     (seta r i (+ x (aref w i)))))
	      r))

(defun sumvs (fno bv r)
  (let ((first t) (r))
    (mapbag bv (f/l (v)
		    (cond (first
			   (setq first nil)
			   (setq r (car v)))
			  (t
			   (setq r (vadd r (car v)))))))
    (osql-result bv r)))

(osql "create function sumvectors(bag of vector of number)
       -> vector of number as foreign 'sumvs';")
