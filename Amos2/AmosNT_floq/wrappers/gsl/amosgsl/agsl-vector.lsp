;;; ============================================================
;;; AMOS2 with BLAS
;;; 
;;; Author: 
;;; $RCSfile: agsl-vector.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/07/14 13:45:45 $
;;; $State: Exp $
;;;
;;; Description: GSL vector data type and functions.
;;;              Integrates new AStorage (C) and AmoSQL
;;;              (Lisp) data types together.
;;; 
;;; ============================================================

;; Global literal type gslvector, a list of type `collection'
;; (defglobal _gslvector_ (gettypenamed 'gslvector)) 

;; Had trouble with this?
(defglobal _gslvector_
 (createliteraltype 'gslvector (list _collection_) 'gslvector
  #'agsl-vector-print #'agsl-vector-type-of))

(defun gsl-vector (fno size res)
  (osql-result size (agsl-vector-make size)))
(osql 
 "create function gslvector (integer)->gslvector 
  as foreign 'gsl-vector';")

(defun gsl-vector-initialize (fno vector res)
  (osql-result vector (agsl-vector-init vector)))
(osql 
 "create function gslvector (vector of number)->gslvector 
  as foreign 'gsl-vector-initialize';")


(defun gsl-vector-get-element (fno gslvector index res)
  (osql-result gslvector (agsl-vector-get gslvector index)))
(osql 
 "create function get (gslvector, integer)->real
  as foreign 'gsl-vector-get-element';")

;;;;
;; Operations
;;;;
(defun gsl-vector-add (fno u v res)
  "Add two vectors element by element"
  (osql-result u v (agsl-vector-add u v)))
(osql 
 "create function plus (gslvector, gslvector)->gslvector
  as foreign 'gsl-vector-add';")

(defun gsl-vector-sub (fno u v res)
  "Subtract two vectors element by element"
  (osql-result u v (agsl-vector-sub u v)))
(osql 
 "create function minus (gslvector, gslvector)->gslvector
  as foreign 'gsl-vector-sub';")

(defun gsl-vector-mul (fno u v res)
  "Multiply two vectors element by element"
  (osql-result u v (agsl-vector-mul u v)))
(osql 
 "create function mul (gslvector, gslvector)->gslvector
  as foreign 'gsl-vector-mul-elements';")

(defun gsl-vector-div (fno u v res)
  "Divide two vectors element by element"
  (osql-result u v (agsl-vector-div u v)))
(osql 
 "create function div (gslvector, gslvector)->gslvector
  as foreign 'gsl-vector-div';")

(defun gsl-vector-scale (fno u x res)
  "Scale vector a by constant factor x"
  (osql-result u x (agsl-vector-scale u x)))
(osql 
 "create function scale (gslvector, real)->gslvector
  as foreign 'gsl-vector-scale';")
(osql 
 "create function times (gslvector v, real x)->gslvector
  as select scale (v, x);")

(defun gsl-vector-add-constant (fno u x res)
  "Add a constant value x to each element in vector u"
  (osql-result u x (agsl-vector-add-constant u x)))
(osql 
 "
  create function vadd (gslvector, real)->gslvector
  as foreign 'gsl-vector-add-constant';
  
  create function plus (gslvector v, real x)->gslvector
  as select vadd (v, x);
 ")

;; Swap arguments before sending to foreign C function
(defun gsl-vector-scale-swap-arguments (fno x u res)
  "Scale vector u by constant factor x"
  (osql-result x u (agsl-vector-scale u x)))
(osql 
 "create function times (real, gslvector)->gslvector
  as foreign 'gsl-vector-scale-swap-arguments';")

(defun gsl-vector-add-constant-swap-arguments (fno x u res)
  "Add a constant value x to each element in vector u"
  (osql-result u x (agsl-vector-add-constant u x)))
(osql 
 "create function plus (real, gslvector)->gslvector
  as foreign 'gsl-vector-add-constant-swap-arguments';")

(defun gsl-vector-uminus (fno u res)
  "Multiply every element in vector u by -1"
  (osql-result u (agsl-vector-scale u -1.0)))
(osql 
 "create function uminus (gslvector)->gslvector
  as foreign 'gsl-vector-uminus';")

;; (defglobal _dvector_
;;   (CREATELITERALTYPE 'dvector (list _gslvector_) 'gslvector
;; 		     #'gslvector-print #'type-of-gslvector))
;; (defglobal _cvector_
;;   (CREATELITERALTYPE 'cvector (list _gslvector_) 'gslvector
;; 		     #'gslvector-print #'type-of-gslvector))
;; (defglobal _ivector_
;;   (CREATELITERALTYPE 'ivector (list _gslvector_) 'gslvector
;; 		     #'gslvector-print #'type-of-gslvector))


;; (defun ivector (fno size res)
;;   (osql-result size (make-ivector size)))
;; (osql "create function ivector (integer)->ivector as foreign 'ivector';")

;; (defun initialize-ivector (fno init res)
;;   (osql-result init (init-ivector init)))
;; (osql "create function ivector (Vector of Integer)->Ivector 
;;   as foreign 'initialize-ivector';")

;; (defun dvector (fno size res)
;;   (osql-result size (make-dvector size)))
;; (osql "create function dvector (integer)->dvector as foreign 'dvector';")

;; (defun initialize-dvector (fno init res)
;;   (osql-result init (init-dvector init)))
;; (osql "create function dvector (Vector of Real)->Dvector 
;;   as foreign 'initialize-dvector';")

;; (defun cvector (fno size res)
;;   (osql-result size (make-cvector size)))
;; (osql "create function cvector (integer)->cvector as foreign 'cvector';")

;; (defun initialize-cvector (fno init-re init-im res)
;;   (osql-result init-re init-im (init-cvector init-re init-im)))
;; (osql "create function cvector (Vector of Real, Vector of Real)->Cvector 
;;   as foreign 'initialize-cvector';")

;; (defun initialize-ccvector (fno init res)
;;   (osql-result init (init-ccvector init)))
;; (osql "create function cvector (Cvector)->Cvector 
;;   as foreign 'initialize-ccvector';")

;; (defun dim-nvector (fno arr res)
;;   (osql-result arr (agsl-vector-dim arr)))
;; (osql "create function dim (gslvector)->integer as foreign 'dim-nvector';")

;; (set-resulttypesfn 
;;  (osql 
;;   "create function vref (Gslvector v, Integer i)->Object e
;; as multidirectional
;;   ('bbf' foreign 'numvrefbbf' cost {0.8,1})
;;   ('bff' foreign 'numvrefbff' cost {40,50});")
;;  'numvref-resulttypes)


;; (defun numvref-resulttypes (fno args)
;;   "The result type is the element type of the argument"
;;   (type-parameters (arg-type (car args))))
