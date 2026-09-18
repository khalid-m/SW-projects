;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) Milena Koparanova, Tore Risch 2003, UDBL
;;; Description: Complex type and operations in Amos2
;;; =============================================================

;; create Amos literal type COMPLEX based on the Lisp complex
(createliteraltype 'complex (list 'literal) 'complex #'prin1)

;;Foreign Lisp function constructor for Amos COMPLEX
(defun complexbbf (fno re im r)
  (osql-result re im (make-complex re im)))

(defun complexffb (fno re im r)
  (osql-result (getreal r)(getimag r) r))

(osql "create function complex(Number re, Number im)->complex key
   as multidirectional ('bbf' foreign 'complexbbf')
                       ('ffb' foreign 'complexffb');")

(osql "create function re(Complex c)->Real re
   as select re from Real im where complex(re,im)=c;")

(osql "create function im(Complex c)->Real im
   as select im from Real re where complex(re,im)=c;")

(defun amos_print_complex (c str)
  (formatl str "complex(" (getreal c) "," (getimag c) ")") 
  t)

(putprop 'complex 'aggfn 'make-complex) ; how to make constant complex

(set-printfn (gettypenamed 'complex) 'amos_print_complex)

(defun complexp (x)
  (eq (typename x) 'complex))

;;Additive operations over complex 
(defun plusc--+ (obj x y z)(osql-result x y (sumcomplex x y)))
(defun plusc-+- (obj x y z)(osql-result x (subcomplex z x) z))
(defun plusc+-- (obj x y z)(osql-result (subcomplex z y) y z))

(osql "create function plus(complex x, complex y) -> complex z
   as multidirectional
      ('bbf' foreign 'plusc--+')
      ('bfb' foreign 'plusc-+-')
      ('fbb' foreign 'plusc+--');")

(osql "create function plus(number x, complex y) -> complex z
   as select cast(x as complex) + y;")

(osql "create function plus(complex x, number y) -> complex z
   as select x + cast(y as complex);")

(osql "create function minus(complex x, complex y)-> complex z
   as select z where x = y+z;")

(osql "create function minus(complex x, number y)-> complex z
   as select x - cast(y as complex);")

(osql "create function minus(number x, complex y)-> complex z
   as select cast(x as complex) - y;")

;;Multiplicative operations over complex 

(defun timesc--+ (obj x y z)(osql-result x y (multcomplex x y)))
(defun timesc-+- (obj x y z)(osql-result x (divcomplex z x) z))
(defun timesc+-- (obj x y z)(osql-result (divcomplex z y) y z))

(osql "create function times(complex x, complex y) -> complex z
   as multidirectional
      ('bbf' foreign 'timesc--+')
      ('bfb' foreign 'timesc-+-')
      ('fbb' foreign 'timesc+--');")

(osql "create function times(complex x, number y) -> complex z
   as select x * cast(y as complex);")

(osql "create function times(number x, complex y) -> complex z
   as select cast(x as complex) * y;")

(osql "create function div(complex x, complex y)-> complex z
   as select z where x = y*z;")

(osql "create function div(complex x, number y)-> complex z
   as select x / cast(y as complex);")

(osql "create function div(number x, complex y)-> complex z
   as select cast(x as complex) / y;")

;;;N-th complex root of 1, needed for FFT

(defun n_root1-+ (fno n nr)
  (osql-result n (ncomplex_root n)))

(osql "create function n_root1(integer n) -> complex w
   as foreign 'n_root1-+';")

(defun n_root1---+ (fno n i j nr)
  (let ((k (mod (* i j) n)))
    (osql-result n i j (ncomplex_root_pow n k))))

(osql "create function n_root1(integer n, integer i, integer j) -> complex w
   as foreign 'n_root1---+';")


