;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_transducer_exitfn.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/03 13:26:46 $
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
;;; Note: The version of the function additionally executes and
;;; exit function e(q) when x is [], i.e., NIL.        
;;;
;;; =============================================================
;;; $Log: stream_transducer_exitfn.lsp,v $
;;; Revision 1.1  2009/08/03 13:26:46  gyogi445
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
(defun strans2-----+ (obj s q0 d h e r)
  (let (r nt;; null-tulerance is false 
	  q);; initial state unset
    (mapbag s;; for all elements of the stream s
	    (f/l (row)
		 (let ((x (car row)));; x is the head of the stream 		   
		   (if (or x nt) 
		       (setq q (getfunction1 d (list (if r q q0) x))));; update state q
		   ;; calculate the result (with the next state!!!)
		   ;;(setq r (getfunction1 h (list q x))) 
		   ;;(if (r) (osql-result s q0 d h e r))
		   )));; if not nil then emit the result
    (if (and (null r) nt)
	(osql-result s q0 d h e (getfunction1 h (list q0 nil))))
    (osql-result s q0 d h e (getfunction1 e (list q)))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function strans02(Stream s, Object q0, Function d, Function h, Function e)-> Bag of Object
  as foreign 'strans2-----+';")

;osql fn to convert the transduced bag to a stream
(osql "
create function strans2(Stream s, Object q0, Function d, Function h, Function e)->Stream of Object
  as streamof(strans02(s, q0, d, h, e));")

  
