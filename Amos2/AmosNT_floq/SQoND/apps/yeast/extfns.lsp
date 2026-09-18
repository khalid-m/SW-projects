;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: extfns.lsp,v $
;;; $Revision: 1.5 $ $Date: 2012/11/19 23:58:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SciSparql foreign founctions for YeastPolarization
;;; =============================================================
;;; $Log: extfns.lsp,v $
;;; Revision 1.5  2012/11/19 23:58:09  andan342
;;; - using resolve-nma inside all array-processing functions as part of proxy-allowing polymorphic behavior,
;;; - moved _nma_proxy_threshold_ to core SSDM, setting this value in regression test return NMAs from queries,
;;; - added _nma_limit_ for a max NMA size to be retrieved, printing a warning if exceeded
;;;
;;; Revision 1.4  2012/11/05 23:13:25  andan342
;;; Updated the examples with new LOAD() syntax and C implementation of array aggregates
;;;
;;; Revision 1.3  2012/02/10 15:35:02  andan342
;;; Now using rdf: namespace
;;;
;;; Revision 1.2  2012/02/02 22:53:51  andan342
;;; Updated aggregate function names to conform with the publication
;;;
;;; Revision 1.1  2011/08/11 10:36:26  andan342
;;; Added YeastPolarization app
;;; Now allowing extentions to register new aggregate functions
;;;
;;;
;;; =============================================================

;; Define array-to-scalar statistical functions

(defun nma-variance (x mean)
  "calculate variance of 1d NMA - internal"
  (let ((sum2 0))
     (dotimes (i (nma-dim x 0))
      (setq sum2 (+ sum2 (expt (- (nma-elt x (list i)) mean) 2))))
    (/ sum2 (nma-dim x 0))))

(defun variance--+ (fno x mean res) 
  "calculate variance of 1d NMA, mean value supplied"
  (let ((xr (resolve-nma x)))
    (when (and xr (= (nma-ndims xr) 1)
	       (numberp mean))
      (osql-result x mean (nma-variance xr mean)))))

(defun variance-+ (fno x res)
  "calculate variance of 1d NMA"
  (let ((xr (resolve-nma x)))    
    (when (and xr (= (nma-ndims xr) 1))
      (osql-result x (nma-variance xr (/ (* 1.0 (nma-sum xr)) (nma-count xr)))))))

(osql "
create function rdf:variance(Literal x, Literal mean) -> Literal as foreign 'variance--+';

create function rdf:variance(Literal x) -> Literal as foreign 'variance-+';
")
      
;;; Define aggregates over arrays

(defun aa_variance (xs amean)
  (when (and (eq (typename amean) 'nma) (= (nma-ndims amean) 1))
    (let* ((xdim (nma-dim amean 0))
	   (ares (make-dnma (list xdim))) ;create result array after mean array
	   (cnt 0) xr)
      (mapbag xs (f/l (x) (when (and (setq xr (resolve-nma (car x))) (= (nma-ndims xr) 1) 
				     (= (nma-dim xr 0) xdim)) 
			    (dotimes (i xdim)
			      (nma-set ares (list i) (+ (nma-elt ares (list i))
							(expt (- (nma-elt xr (list i)) 
								 (nma-elt amean (list i))) 2))))
			    (incf cnt))))
      (when (> cnt 0) 
	(dotimes (i xdim) ; divide each element by the number of aggregated arrays
	  (nma-set ares (list i) (/ (nma-elt ares (list i)) cnt)))
	ares))))

(defun aa_variance-+ (fno xs res) 
  "calculate variance NMA of a bag of 1d NMAs"
  (let ((ares (aa_variance xs (aa_mean xs))))
    (when ares (osql-result xs ares))))

(osql "
create function rdf:varianceAgg(Bag of Literal xs) -> Literal as foreign 'aa_variance-+';
")

;; Funciton names should always be lowercase, w/o 'rdf:' prefix
;(push "varianceagg" _sq_aggregate_fns_)