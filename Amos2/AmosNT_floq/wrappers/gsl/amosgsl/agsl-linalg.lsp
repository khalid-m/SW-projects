;;; ============================================================
;;; AmosGSL Linear Algebra Module
;;; 
;;; GSL decomposing matrices, solving matrix-matrix and
;;; matrix-vector equations
;;;
;;; ============================================================

;;; Decomposing/Recomposing ;;;

(defun gsl-linalg-decomp-+ (fno A B)
  "Decompose A"
  (osql-result A (agsl-linalg-decomp A)))

(defun gsl-linalg-decomp+- (fno A B)
  "Recompose B: solve decomp (A) = B for A"
  (osql-result (agsl-linalg-recomp B) B))

(defun gsl-linalg-recomp-+ (fno A B)
  "B = A recomposed"
  (osql-result A (agsl-linalg-recomp A)))

(defun gsl-linalg-recomp+- (fno A B)
  "A = B decomposed"
  (osql-result (agsl-linalg-decomp B) B))

;;; LU decomposition/recomposition ;;;
(defun gsl-linalg-lu-decomp-+ (fno A B)
  "LU decomposition of A"
  (osql-result A (agsl-linalg-lu-decomp A)))

(defun gsl-linalg-lu-decomp+- (fno A B)
  "Recompose A: solve lu (A) = B for A"
  (osql-result (agsl-linalg-lu-recomp B) B))

(defun gsl-linalg-lu-recomp-+ (fno A B)
  "B = A recomposed"
  (osql-result A (agsl-linalg-lu-recomp A)))

(defun gsl-linalg-lu-recomp+- (fno A B)
  "A = lu (B)"
  (osql-result (agsl-linalg-lu-decomp B) B))


;;; Cholesky decomposition/recomposition ;;;
(defun gsl-linalg-cholesky-decomp-+ (fno A B)
  "Cholesky decomposition of A"
  (osql-result A (agsl-linalg-cholesky-decomp A)))

(defun gsl-linalg-cholesky-decomp+- (fno A B)
  "A = B recomposed"
  (osql-result (agsl-linalg-cholesky-recomp B) B))

(defun gsl-linalg-cholesky-recomp-+ (fno A B)
  "B = A recomposed"
  (osql-result A (agsl-linalg-cholesky-recomp A)))

(defun gsl-linalg-cholesky-recomp+- (fno A B)
  "A = B cholesky decomposed"
  (osql-result (agsl-linalg-cholesky-decomp B) B))


;;; QR decomposition/recomposition ;;;
(defun gsl-linalg-qr-decomp-+ (fno A B)
  "QR decomposition of A"
  (osql-result A (agsl-linalg-qr-decomp A)))

(defun gsl-linalg-qr-decomp+- (fno A B)
  "A = B recomposed"
  (osql-result (agsl-linalg-qr-recomp B) B))

(defun gsl-linalg-qr-recomp-+ (fno A B)
  "B = A recomposed"
  (osql-result A (agsl-linalg-qr-recomp A)))

(defun gsl-linalg-qr-recomp+- (fno A B)
  "A = B QR decomposed"
  (osql-result (agsl-linalg-qr-decomp B) B))


;;; Solving ;;;

(defun gsl-linalg-solve--+--- (fno alpha a b beta c d)
  "Solve \alpha A B + \beta C = D for B"
  (osql-result alpha a (agsl-linalg-solve alpha a beta c d) beta c d))

;;; yes its confusing, solve (A, C) = B means solve A * B = C for B ;;;

(defun gsl-linalg-solve-alpha-ab---+ (fno alpha A C B)
  "Solve \alpha A B = C for B"
  (osql-result alpha A C (agsl-linalg-solve-alpha-ab alpha A C)))
(defun gsl-linalg-solve-alpha-ab--+- (fno alpha A C B)
  "solve (\alpha, A, C) = B when C is free means compute C = \alpha A B"
  (osql-result alpha A (agsl-blas-dgemm-alpha-ab alpha A B) B))


;;; Solving with matrix A LU decomposed (P A = L U) ;;;

(defun gsl-linalg-lu-solve--+--- (fno alpha a b beta c d)
  "Solve \alpha A B + \beta C = D for B, where A is LU decomposed"
  (osql-result alpha a (agsl-linalg-lu-solve alpha a beta c d) beta c d))

(defun gsl-linalg-lu-solve-alpha-ab--+- (fno alpha a b c)
  "Solve \alpha A B = C for B, where A is LU decomposed"
  (osql-result alpha a (agsl-linalg-lu-solve-alpha-ab alpha a c) c))


;;; Solving with matrix A Cholesky decomposed (A = L L^T) ;;;

(defun gsl-linalg-cholesky-solve--+--- (fno alpha a b beta c d)
  "Solve \alpha A B + \beta C = D for B, where A is Cholesky decomposed"
  (osql-result alpha a (agsl-linalg-cholesky-solve alpha a beta c d) beta c d))

(defun gsl-linalg-cholesky-solve-alpha-ab---+ (fno alpha A C B)
  "Solve \alpha A B = C for B, where A is Cholesky decomposed"
  (osql-result alpha A C (agsl-linalg-cholesky-solve-alpha-ab alpha A C)))

(defun gsl-linalg-cholesky-solve-alpha-ab--+- (fno alpha A C B)
  "Solve (\alpha, A, C) = B when C is free means compute C = \alpha A B"
  (osql-result alpha A (agsl-blas-dsymm-alpha-ab alpha A C) B))

