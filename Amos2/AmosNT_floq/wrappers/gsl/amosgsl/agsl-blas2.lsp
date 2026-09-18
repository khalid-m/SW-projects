;;;;
;; BLAS Level 2 operations
;;;;

;;;;
;; Au = B general matrix-vector multiply
;;;;
(defun gsl-blas-gemv (fno a u res)
  (osql-result a u (agsl-blas-dgemv a u)))
(osql
 "create function gemv (matrix, gslvector)->gslvector
  as foreign 'gsl-blas-gemv';

  /* `*' operator */
  create function times (matrix a, gslvector u)->gslvector
  as select gemv (a, u);")

;; Au = C where u is unknown?
;;  ('bfb' foreign 'gsl-blas-gausssolve' cost {2,2};")

;;;;
;; Au = B symmetric matrix-vector multiply
;;;;
(defun gsl-blas-symv (fno a u res)
  (osql-result a u (agsl-blas-dsymv a u)))
(osql
 "create function dsymv (matrix a, gslvector u)->gslvector x
  as foreign 'gsl-blas-symv';

  /* create function times (matrix a, gslvector u)->gslvector x
  as select dsymv (a, u) where symmetric (a); */")



;;;;
;; Au = B triangular matrix-vector multiply
;;;;
(defun gsl-blas-trmv (fno a u res)
  (osql-result a u (agsl-blas-dtrmv a u)))
(osql
 "create function trmv (matrix, gslvector)->gslvector
  as foreign 'gsl-blas-trmv';

  /* create function times (matrix a, gslvector u)->gslvector
  as select trmv (a, u) where triangular (a); */")


;;;;
;; Au = B tri/symmetric matrix-vector multiply
;;;;
;; (defun gsl-blas-trsv (fno a u res)
;;   (osql-result a u (agsl-blas-dtrsv a u)))
;; (osql
;;  "create function trsv (matrix, gslvector)->gslvector
;;   as foreign 'gsl-blas-trsv';

;;   create function times (matrix a, gslvector u)->gslvector
;;   as select trsv (a, u) where triangular (a);")



