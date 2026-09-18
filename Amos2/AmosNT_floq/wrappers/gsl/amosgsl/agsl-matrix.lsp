;;; ============================================================
;;; AmosGSL
;;; 
;;; Description: GSL matrix data type and functionality
;;;   mapping from AmoSQL to ALisp to foreign functions
;;;   written in C and making use of the storage manager
;;;   AStorage.  Integrates the new AStorage and AmoSQL data
;;;   types together.
;;; 
;;; ============================================================

;; Global literal type matrix, a list of type `collection'
(defglobal _matrix_
 (createliteraltype 'matrix (list _collection_) 'matrix
  #'agsl-matrix-print #'agsl-matrix-type-of))

(defglobal _symmetricmatrix_
  (createliteraltype 'symmetric (list _matrix_) 'symmetric
                     #'agsl-matrix-print #'agsl-matrix-type-of))

(defglobal _lowertriangularmatrix_
  (createliteraltype 'lowertri (list _matrix_) 'lowertri
                     #'agsl-matrix-print #'agsl-matrix-type-of))

(defglobal _uppertriangularmatrix_
  (createliteraltype 'uppertri (list _matrix_) 'uppertri
                     #'agsl-matrix-print #'agsl-matrix-type-of))

;; Decomposed matrices
(defglobal _ludecomposedmatrix_
  (createliteraltype 'lumatrix (list _matrix_) 'lumatrix
                     #'agsl-matrix-print #'agsl-matrix-type-of))

(defglobal _choleskydecomposedmatrix_
  (createliteraltype 'cholesky (list _matrix_) 'cholesky
                     #'agsl-matrix-print #'agsl-matrix-type-of))

;; Create an empty matrix
(defun gsl-matrix (fno size1 size2 res)
  (osql-result size1 size2 (agsl-matrix-make size1 size2)))
(osql 
 "create function matrix (integer, integer)->matrix 
  as foreign 'gsl-matrix';")

(defun gsl-matrix-rows (fno m res)
  "Return number of rows of M"
  (osql-result m (agsl-matrix-rows m)))
(osql 
 "create function rows (matrix m)->integer 
  as foreign 'gsl-matrix-rows';")

(defun gsl-matrix-columns (fno m res)
  "Return number of columns of M"
  (osql-result m (agsl-matrix-columns m)))
(osql 
 "create function columns (matrix m)->integer 
  as foreign 'gsl-matrix-columns';")

(defun gsl-matrix-all (fno m res)
  "Returns TRUE when all entries of M are non-zero"
  (osql-result m (agsl-matrix-all m)))
(osql 
 "create function all (matrix m)->boolean
  as foreign 'gsl-matrix-all';")

(defun gsl-matrix-any (fno m res)
  "Returns TRUE when any entries of M are non-zero"
  (osql-result m (agsl-matrix-any m)))
(osql 
 "create function any (matrix m)->boolean
  as foreign 'gsl-matrix-any';")

(defun gsl-matrix-set-zeros (fno size1 size2 res)
  "Create M x N matrix with elements set to zero"
  (osql-result size1 size2 
               (agsl-matrix-set-all 
                (agsl-matrix-make size1 size2) 0.0)))
(osql 
 "create function zeros (integer, integer)->matrix
  as foreign 'gsl-matrix-set-zeros';
  create function zeros (integer x)->matrix
  as zeros (x, x);")

(defun gsl-matrix-set-ones (fno size1 size2 res)
  "Create M x N matrix with elements set to zero"
  (osql-result size1 size2 
               (agsl-matrix-set-all 
                (agsl-matrix-make size1 size2) 1.0)))
(osql
 "create function ones (integer, integer)->matrix
  as foreign 'gsl-matrix-set-ones';
  create function ones (integer size)->matrix
  as ones (size, size);")

(defun gsl-matrix-rand (fno size1 size2 res)
  (osql-result size1 size2 
               (agsl-matrix-rand size1 size2)))
(osql
 "create function rand (integer, integer)->matrix
  as foreign 'gsl-matrix-rand';")
(osql
 "create function rand (integer size)->matrix
  as rand (size, size);")

(defun gsl-matrix-eye (fno size1 size2 res)
  (osql-result size1 size2 
               (agsl-matrix-eye size1 size2)))
(osql
 "create function eye (integer, integer)->matrix
  as foreign 'gsl-matrix-eye';")
(osql
 "create function eye (integer size)->matrix
  as eye (size, size);")


;; Create gsl matrix with values from {{NUMBERS}}
(defun gsl-matrix-initialize (fno init res)
  (osql-result init (agsl-matrix-init init)))
(osql 
 "create function matrix (vector of vector of number)->matrix 
  as foreign 'gsl-matrix-initialize';")

;; Get e_ij from matrix A
(defun gsl-matrix-get (fno a i j res)
  "Get element e_ij of the matrix"
  (osql-result a (agsl-matrix-get a i j)))
(osql 
 "create function getelem (matrix m, integer i, integer j)->real x
  as foreign 'gsl-matrix-get';")

;; Set e_ij from matrix A
(defun gsl-matrix-set (fno a i j x res)
  "Set element e_ij of the matrix"
  (osql-result a (agsl-matrix-set a i j x)))
(osql 
 "create function setelem (matrix m, integer i, integer j, real x)->boolean
  as foreign 'gsl-matrix-set';")


;;;;
;; Operations
;;;;
(defun gsl-matrix-add (fno a b res)
  "Add two matrices element by element"
  (osql-result a b (agsl-matrix-add a b)))
(osql 
 "create function plus (matrix, matrix)->matrix
  as foreign 'gsl-matrix-add';")

(defun gsl-matrix-sub (fno a b res)
  "Subtract two matrices element by element"
  (osql-result a b (agsl-matrix-sub a b)))
(osql 
 "create function minus (matrix, matrix)->matrix
  as foreign 'gsl-matrix-sub';")

(defun gsl-matrix-mul-elements (fno a b res)
  "Multiply two matrices element by element"
  (osql-result a b (agsl-matrix-mul-elements a b)))
(osql 
 "create function mul_elements (matrix, matrix)->matrix
  as foreign 'gsl-matrix-mul-elements';")

(defun gsl-matrix-div-elements (fno a b res)
  "Divide two matrices element by element"
  (osql-result a b (agsl-matrix-div-elements a b)))
(osql 
 "create function divide (matrix, matrix)->matrix
  as foreign 'gsl-matrix-div-elements';")

(defun gsl-matrix-scale (fno a x res)
  "Scale matrix a by constant factor x"
  (osql-result a x (agsl-matrix-scale a x)))
(osql 
 "create function times (matrix, real)->matrix
  as foreign 'gsl-matrix-scale';")

(defun gsl-matrix-add-constant (fno a x res)
  "Add a constant value x to each element in matrix a"
  (osql-result a x (agsl-matrix-add-constant a x)))
(osql 
 "create function plus (matrix, real)->matrix
  as foreign 'gsl-matrix-add-constant';")

(defun gsl-matrix-transpose (fno a res)
  "Add a constant value x to each element in matrix a"
  (osql-result a (agsl-matrix-transpose a)))
(osql 
 "create function trans (matrix)->matrix
  as foreign 'gsl-matrix-transpose';")


;; negate every element in the matrix
(defun gsl-matrix-uminus (fno A res)
  "Multiply every element in matrix A by -1"
  (osql-result A (agsl-matrix-scale A -1.0)))
(osql 
 "create function uminus (matrix)->matrix
  as foreign 'gsl-matrix-uminus';")

(defun gsl-matrix-tril (fno A res)
  "Return lower-triangular matrix of A"
  (osql-result A (agsl-matrix-tril A)))
(osql 
 "create function tril (matrix A)->matrix L
  as foreign 'gsl-matrix-tril';")

(defun gsl-matrix-triu (fno A res)
  "Return upper-triangular matrix of A"
  (osql-result A (agsl-matrix-triu A)))
(osql 
 "create function triu (matrix A)->matrix U
  as foreign 'gsl-matrix-triu';")


(defun gsl-matrix-symm (fno A res)
  "Return symmetric matrix representation of A"
  (osql-result A (agsl-matrix-symm A)))
(osql 
 "create function symm (matrix A)->matrix B
  as foreign 'gsl-matrix-symm';")


(defun gsl-matrix-diag (fno A res)
  "Return diagonal matrix representation of A"
  (osql-result A (agsl-matrix-diag A)))
(osql 
 "create function diag (matrix A)->matrix B
  as foreign 'gsl-matrix-diag';")






