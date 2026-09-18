;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_transducer_silent.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/03 13:26:47 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of a stream transducer
;;; according to D.S. Parker et al. SVP - a Model Capturing Sets
;;; Streams, and Parallelism. This version of the function
;;; is SIELENT, i.e., no output functions is executed in every 
;;; but rahter an end function is executed once at the end of the 
;;; stream. 
;;; 
;;; "A stream transducer f is defined in tems of two function
;;; parameters d and h, and an iterative control structure F:
;;;
;;; f(S) = F(q0, S)
;;; F(q, []) = h(q, [])
;;; F(q, x.S) = h(q,x).F(d(q,x),S)" 
;;;
;;; Note: The version of the function additionally executes and
;;; exit function e(q) when x is [], i.e., NIL.        
;;;
;;; =============================================================
;;; $Log: stream_transducer_silent.lsp,v $
;;; Revision 1.1  2009/08/03 13:26:47  gyogi445
;;; Novelty detection via independently trained "compression" neural networks
;;;
;;; Revision 1.1  2009/04/07 20:01:09  gyogi445
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

; lisp debugging function to print nested list of variable-value pairs 
(defun printvars (vl) 
  (mapc (function print) vl))

; lisp foreigh function that implements the above defined stream 
; transducers iterative control structure 
(defun strans3----+ (obj s q0 d e r)
  (let (r nt;; null-tulerance is false 
	  q);; initial state unset
    (mapbag s;; for all elements of the stream s
	    (f/l (row)
		 (let ((x (car row)));; x is the head of the stream 		   
		   (if (or x nt) 
		       (setq q (getfunction1 d (list (if r q q0) x)))))));; update state q
    (osql-result s q0 d e (getfunction1 e (list q)))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function strans03(Stream s, Object q0, Function d, Function e)-> Bag of Object
  as foreign 'strans3----+';")

;osql fn to convert the transduced bag to a stream
(osql "
create function strans3(Stream s, Object q0, Function d, Function e)->Stream of Object
  as streamof(strans03(s, q0, d, e));")

  
