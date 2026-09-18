;;; ============================================================
;;; AMOS2 ALisp/AmoSQL BLAS Level 3 
;;; 
;;; GSL matrix BLAS level 3 functions. AmoSQL/ALisp wrapper
;;; for AStorage/C BLAS routines.
;;; =============================================================

;;; DGEMM ;;;

(defun gsl-blas-dgemm-alpha-ab-beta-c-----+ (fno alpha a b beta c d)
 "Compute \alpha A B + \beta C for general matrices"
 (osql-result alpha a b beta c (agsl-blas-dgemm alpha a b beta c)))

(defun gsl-blas-dgemm-alpha-ab-beta-c--+--- (fno alpha a b beta c d)
 "Solve \alpha A B + \beta C for B for general matrices"
 (osql-result alpha a (agsl-linalg-solve alpha a beta c d) beta c d))
  
(defun gsl-blas-dgemm-alpha-ab---+ (fno alpha a b c)
 "Compute \alpha A B for general matrices"
 (osql-result alpha a b (agsl-blas-dgemm-alpha-ab alpha a b)))

(defun gsl-blas-dgemm-alpha-ab--+- (fno alpha a b c)
  "Solve \alpha A B = C for B for general matrices"
 (osql-result alpha a (agsl-linalg-solve-alpha-ab alpha a c) c))

(defun gsl-blas-dgemm-alpha-a--+ (fno alpha a b c)
 "Compute \alpha A for general matrices"
 (osql-result alpha a (agsl-blas-dgemm-alpha-a alpha a)))


;;; DSYMM ;;;

(defun gsl-blas-dsymm-alpha-ab-beta-c-----+ (fno alpha a b beta c res)
 "Compute \alpha A B + \beta C for symmetric matrix A"
 (osql-result alpha a b beta c (agsl-blas-dsymm alpha a b beta c)))

(defun gsl-blas-dsymm-alpha-ab-beta-c--+--- (fno alpha a b beta c res)
 "Solve \alpha A B + \beta C for B for symmetric matrix A"
 (osql-result alpha a (agsl-linalg-solve alpha a beta c res) beta c res))

(defun gsl-blas-dsymm-alpha-ab---+ (fno alpha a b res)
  "Compute \alpha A B for symmetric matrix A"
 (osql-result alpha a b (agsl-blas-dsymm-alpha-ab alpha a b)))

(defun gsl-blas-dsymm-alpha-ab--+- (fno alpha a b res)
  "Solve \alpha A B = C for B for general matrices"
 (osql-result alpha a (agsl-linalg-solve-alpha-ab alpha a res) res))

(defun gsl-blas-dsymm-alpha-a--+ (fno alpha a res)
 "Compute \alpha A for general matrices"
 (osql-result alpha a (agsl-blas-dsymm-alpha-a alpha a)))


;;; DTRMM ;;;

(defun gsl-blas-dtrmm---+ (fno alpha a b res)
  "Compute \alpha A B for triangular matrix A"
 (osql-result alpha a b (agsl-blas-dtrmm alpha a b)))
(defun gsl-blas-dtrmm-alpha-a--+ (fno alpha a res)
  "Compute \alpha A for triangular matrix A"
 (osql-result alpha a (agsl-blas-dtrmm-alpha-a alpha a)))

;;; DTRSM ;;;

(defun gsl-blas-dtrsm---+ (fno alpha a b res)
  "Solve A B = C for B"
 (osql-result alpha a b (agsl-blas-dtrsm alpha a b)))
