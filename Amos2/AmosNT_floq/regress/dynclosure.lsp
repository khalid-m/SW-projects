;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Tore Risch, UDBL
;;; $RCSfile: dynclosure.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/07/31 15:24:12 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing dynamic ALisp closures
;;; =============================================================
;;; $Log: dynclosure.lsp,v $
;;; Revision 1.2  2009/07/31 15:24:12  torer
;;; Added example of lazy evaluation with dynamic closures
;;;
;;; Revision 1.1  2009/07/31 09:41:51  torer
;;; Added to repository
;;;
;;; =============================================================

(defun three-closures (fn1 fn2 fn3)
  (+ (funcall fn1 1)(funcall fn2 2)(funcall fn3 3)))

(defun test-three-closures()
  (let (x) (three-closures (function(lambda(x)x))
			   (function(lambda(y)y))
			   (function (lambda(z)z)))));; 6

(defun simple-dynamic-closure (x)#'(lambda (y)(+ x y)))

(defun test-simple-dynamic-closure ()
  (let ((c1 (simple-dynamic-closure 1)))
    (funcall c1 20)));; 21

(defun assign-simple-dynamic-closure (x) 
  (prog1 #'(lambda (y)(+ x y)) 
    (setq x 2)))

(defun test-assign-simple-dynamic-closure ()
  (let ((c2 (assign-simple-dynamic-closure 3)))
    (funcall c2 2)));; 4

(defun connected-dynamic-closures (x)
  (cons #'(lambda (y)(setq x (+ x y)))
        #'(lambda (z)(+ z x))))

(defun test-connected-dynamic-closures ()
  (let ((c22 (connected-dynamic-closures 80)))
    (list
     (funcall (car c22) 10);; 90
     (funcall (cdr c22) 11);; 101
     )))

(defun local-connected-dynamic-closures (x)
  (let ((z 0))
    (cons #'(lambda (y)(setq z (+ y x z)))
	  #'(lambda (y)(+ x y z)))))

(defun test-local-connected-dynamic-closures ()
  (let ((c3 (local-connected-dynamic-closures 2)))
    (list
     (funcall (car c3) 10);; 12

     (funcall (cdr c3) 20);; 34

     (funcall (car c3) 11);; 25

     (funcall (cdr c3) 21);; 48
     )))

(defun linked-dynamic-closures (x)
  (let ((fn #'(lambda (z) (setq x (+ x z))))
        (a 2))
    (list #'(lambda (y)(setq x (+ y x 1)))
          fn
	  #'(lambda (y)(+ x y a)))))

(defun test-linked-dynamic-closures ()
  (let ((c33 (linked-dynamic-closures 99)))
    (list
     (funcall (car c33) 1);; 101

     (funcall (cadr c33) 2);; 103

     (funcall (caddr c33) 3);; 108

     (funcall (cadr c33) 3);; 106

     (funcall (caddr c33) 4);; 112
     )))

;;; Some examples of using dynamic closures for lazy evaluation

(defmacro delay (expr) `(function(lambda () , expr)))

(defun force (thunk) (if (delayed thunk) (funcall thunk) thunk))

(defun delayed (x)(eq (typename x) 'closure))

(defun l-car (l)(car (force l)))

(defun l-cdr (l)(cdr (force l)))

(defun natnum (i)
  "Lazy list of all numbers >= i"
  (cons i (delay (natnum (1+ i)))))

(defun l-first (n l)
   "Lazy list of first N elements of lazy list L"
   (cond ((< n 1) nil)
         ((= n 1) (list (l-car l)))
         (t (cons (l-car l) (delay (l-first (1- n) (l-cdr l)))))))

(defun l-nth (n l)
  "The N:th element of lazy list L"
  (cond ((< n 1) l)
        ((= n 1)(l-car l))
        (t (l-nth (1- n)(l-cdr l)))))

(checkequal "Dynamic closures"
	    ((test-three-closures) 6)
	    ((test-simple-dynamic-closure) 21)
	    ((test-assign-simple-dynamic-closure) 4)
	    ((test-connected-dynamic-closures) '(90 101))
            ((test-local-connected-dynamic-closures) '(12 34 25 48))
            ((test-linked-dynamic-closures) '(101 103 108 106 112))
	    ((l-nth 200 (l-first 2000 (natnum 1))) 200)
)

