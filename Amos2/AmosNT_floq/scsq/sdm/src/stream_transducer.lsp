;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_transducer.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/05/09 06:18:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of a stream transducer
;;; according to D.S. Parker et al. SVP - a Model Capturing Sets
;;; Streams, and Parallelism. In Proc. of VLDB, 1992, with one 
;;; IMPORTANT DIFFERENCE: the initial state q0 is a function of
;;; the first element of the stream  
;;; 
;;; "A stream transducer f is defined in tems of two function
;;; parameters d and h, and an iterative control structure F:
;;;
;;; f(S) = F(q0, S)
;;; F(q, []) = h(q, [])
;;; F(q, x.S) = h(q,x).F(d(q,x),S)" 
;;;
;;; Note: Check logic of the operator wrt behaviour of q0(NIL),
;;; d(q,NIL) and h(q,NIL). What makes sense? For example the
;;; output of stream aggregator scount(nilstream) should be
;;; a stream of a single 0. Also, currently the sequenct of
;;; operations are as follows: calculate new state THEN calculate
;;; output based on new state. Maybe this is not intuitive and
;;; fully expressive.       
;;;
;;; =============================================================
;;; $Log: stream_transducer.lsp,v $
;;; Revision 1.2  2009/05/09 06:18:38  gyogi445
;;; Updated stream_transducer code, vectorized stream aggregators, spectrum monitoring
;;;
;;; Revision 1.1  2009/04/09 10:20:11  gyogi445
;;; Basic stream operators
;;;
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
(defun strans1----+ (obj s q0 d h r)
  (let (r nt;; null-tulerance is false 
	  q);; initial state unset
    (mapbag s;; for all elements of the stream s
	    (f/l (row)
		 (let ((x (car row)));; x is the head of the stream 
		   (if (or x nt) 
		       (setq q (getfunction1 d (list (if r q q0) x))));; update state q
		   ;; calculate the result (with the next state!!!)
		   (setq r (getfunction1 h (list q x))) 
		   (osql-result s q0 d h r))));; emit the result
    (if (and (null r) nt)
	(osql-result s q0 d h (getfunction1 h (list q0 nil))))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function strans01(Stream s, Object q0, Function d, Function h)-> Bag of Object
  as foreign 'strans1----+';")

;osql fn to convert the transduced bag to a stream
(osql "
create function strans1(Stream s, Object q0, Function d, Function h)->Stream of Object
  as streamof(strans01(s, q0, d, h));")

  
