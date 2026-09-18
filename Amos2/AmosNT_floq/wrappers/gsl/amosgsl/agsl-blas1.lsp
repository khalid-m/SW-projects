;;;;
;; BLAS Level 1 operations
;;;;

;;;;
;; Level 1
;;;;
(defun gsl-blas-dot (fno u v res)
  "dot product"
  (osql-result u v (agsl-blas-ddot u v)))
(osql
 "create function dot (gslvector, gslvector)->real
  as foreign 'gsl-blas-dot';")

(defun gsl-blas-norm (fno u res)
  "norm of a vector"
  (osql-result u (agsl-blas-dnorm u)))
(osql 
  "create function norm (gslvector)->real
  as foreign 'gsl-blas-norm';")

(defun gsl-blas-asum (fno u res)
  "asum"
  (osql-result u (agsl-blas-dasum u)))
(osql 
  "create function asum (gslvector)->real
  as foreign 'gsl-blas-asum';")


