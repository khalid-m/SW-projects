;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: math.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/05/09 06:18:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Exposition of some basic Lisp trig/math function
;;; to Amos.  
;;;      
;;; =============================================================
;;; $Log: math.lsp,v $
;;; Revision 1.1  2009/05/09 06:18:37  gyogi445
;;; Updated stream_transducer code, vectorized stream aggregators, spectrum monitoring
;;;
;;; Revision 1.0  2009/05/04 10:20:10  gyogi445
;;; Basic stream operator updates (type inference, vectorization, etc)
;;;
;;; =============================================================


; x2y - Lisp impementation of the foreign function to 
; calculate x to the power of y
(defun x2ybbf (fno x y r)
  (osql-result x y (exp (* y (ln x)))))

;osql definition of x2y(x,y) 
(osql "  
create function x2y(Number x, Number y)->Number 
  as foreign 'x2ybbf';")

; e - Lisp implemnatation of the foreign "constant" 
; function e  
(defun ef (fno r)
  (osql-result (exp 1)))

;osql definition of e()
(osql "
create function e()->Number as foreign 'ef';
")

; logbx - Lisp implementation of the foreign function to 
; calculate b-based logarithm of x   
(defun logbxbbf (fno b x r)
  (osql-result b x (/ (ln x) (ln b))))  

;osql definition for logbx(b,x)
(osql "
create function logbx(Number b, Number x)->Number 
  as foreign 'logbxbbf';")

; Function to calculate the natural logarithm of x already 
; exists in Amos as ln(x)  

; logbf - Lisp implementation of the foreign function to 
; calculate base-2 logarithm of x   
(defun logbf (fno x r)
  (osql-result x (/ (ln x) (ln 2))))  

;osql definition for log(x)
(osql "
create function log(Number x)->Number 
  as foreign 'logbf';")

; lgbf - Lisp implementation of the foreign function to 
; calculate base-10 logarithm of x   
(defun lgbf (fno x r)
  (osql-result x (/ (ln x) (ln 10))))  

;osql definition for lg(x)
(osql "
create function lg(Number x)->Number 
  as foreign 'lgbf';")


