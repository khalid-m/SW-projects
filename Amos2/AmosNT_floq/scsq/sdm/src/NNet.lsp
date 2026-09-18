;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: NNet.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/03 13:26:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementations of a feed-forward back-
;;; propagation neural net.  
;;;
;;; =============================================================
;;; $Log: NNet.lsp,v $
;;; Revision 1.1  2009/08/03 13:26:45  gyogi445
;;; Novelty detection via independently trained "compression" neural networks
;;;
;;; Revision 1.1  2009/05/12 20:01:09  gyogi445
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

; Lisp function to perfrom recursive arraytolist
(defun arraytolistrec (ar)
  (let ((res ()))
    ;;if the argument is an array make it into a list 
    ;;and call the function resursively on each element
    (if (arrayp ar) (dolist (e (arraytolist ar) res) 
		      ;;accumulate results from recursive calls 
		      ;;into a reverse-ordered list
		      (setq res (cons (arraytolistrec e) res)))
      (setq res ar));;if the argument is not a list...
    (nreverse res)));;reverse and return the result

; Lisp function to perform recursive listtoarray
(defun listtoarrayrec (ls)
  (let ((res ()))
    (cond ((listp ls);; if the argument is a list 
	   (dolist (e ls res);;for each element 
	     ;;call the function recursively and accumulate
	     ;;the results in reverse order
	     (setq res (cons (listtoarrayrec e) res)))
	   ;;reverse the result, make it into an array and return
	   (listtoarray (nreverse res)))
	  ((not (listp ls));;if the argument is not a list
	   (setq res ls)))));;then return the argument

; Lisp x-to-the-power-of-y function
(defun x2y (x y)
  (exp (* y (ln x))))

; Lisp e-function
(defun e ()
  (exp 1))

; Lisp sigmoid transfer function
(defun sigmoid (x)
   (/ 1 (+ 1 (x2y (e) (* -1 x)))))

; Lisp function to calculate the dot product of two lists
; !!!Assumes same length lists!!! 
(defun dotprod (v1 v2)
  (let ((r 0))
    (dolist (e1 v1 r);;iterate through the first list
      (setq r (+ r (* e1 (car v2))));;accumulate dot product
      (setq v2 (cdr v2)))));;"consume" the second list

; Lisp function to calculate the output of, i.e., evaluate 
; a neuron function takes care of the bias term by adding 
; a constant 1 to the head of i 
(defun eval_neuron (i w tfn)
  ;;impl that allows the use of Lisp activation fn
  ;;(getfunction1 tfn (list (dotprod w (cons 1 i)))))
  ;;impl that allows the use of AmosQL activation fn
  (apply tfn (list (dotprod w (cons 1 i))))) 

; Lisp function to calcuate the output of, i.e., evalaute 
; a layer of neurons. Bias is taken care of as above.
(defun eval_layer (i lw tfn)
  (let (res ())
    (dolist (w lw res) 
      (setq res (cons (eval_neuron i w tfn) res)))
    (nreverse res)))

; (Recursive) Lisp function to calculate the output of, 
; i.e., evaluate a feed-forward neural network, 
; represented by a list of list of list of weigths. 
; Bias is taken care of as above.  
(defun eval_nnrec (i lnn ltfn)
  ;;if there is a neuron layer to evaluate
  (if (car lnn)
      ;;evaluate it and call the fn recursively 
      ;;with the evaluated output and the rest of the nn
      (eval_nnrec (eval_layer i (car lnn) (car ltfn))
		  (cdr lnn)  
		  (cdr ltfn))
    ;;else output the "input" as that was the result of
    ;;the evaluation of the last layer
    i))

; (Iterative) Lisp function to calculate the output of, 
; i.e., evaluate a feed-forward neural network, 
; represented by a list of list of list of weigths. 
; Bias is taken care of as above.  
(defun eval_nniter (i t lnn ltfn ld)
  (let ((res (list i)))
    ;;for all layers in order
    (dolist (lw lnn res) 
      ;;evaluate the layer and on the last result 
      (setq res (cons (eval_layer (car res) lw (car ltfn)) res))
      (setq ltfn (cdr ltfn)))))

;;(eval_nniter '(1 2) '(((1 2 3) (1 1 1)) ((1 2 3)) ((1 2))) '(sigmoid sigmoid sigmoid))  

; Foreign function interface for eval_nn
(defun eval_nnrec---+ (obj vi vnn vtfn)
  (osql-result vi vnn vtfn 
	       (listtoarrayrec(eval_nnrec (arraytolistrec vi)
					  (arraytolistrec vnn)	
					  (arraytolistrec vtfn)))))

(osql "
create function eval_nnrec(Vector of Number si,
                           Vector of Vector of Vector of Number ws,
                           Vector of Function tfs)
                           -> Vector of Vector of Vector of Number
  as foreign 'eval_nnrec---+';")

; Foreign function interface for eval_nn
(defun eval_nniter---+ (obj vi vnn vtfn)
  (osql-result vi vnn vtfn 
	       (listtoarrayrec(eval_nniter (arraytolistrec vi)
					   (arraytolistrec vnn)	
					   (arraytolistrec vtfn)))))

(osql "
create function eval_nniter(Vector of Number si,
                            Vector of Vector of Vector of Number ws,
                            Vector of Function tfs)
                            -> Vector of Vector of Vector of Number
  as foreign 'eval_nniter---+';")

