;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: random.lsp,v $
;;; $Revision: 1.4 $ $Date: 2009/08/03 13:26:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp and derived osql definitions of functions 
;;; for generating normal N~(0,1) and uniform U~(0,1) random 
;;; samples.    
;;; =============================================================
;;; $Log: random.lsp,v $
;;; Revision 1.4  2009/08/03 13:26:46  gyogi445
;;; Novelty detection via independently trained "compression" neural networks
;;;
;;; Revision 1.3  2009/05/12 13:33:49  gyogi445
;;; Feed-forward Neural Network implementation via recursive stored procedure
;;;
;;; Revision 1.2  2009/04/09 10:20:10  gyogi445
;;; Basic stream operators
;;;
;;; Revision 1.1  2009/03/05 18:18:49  guestgyg
;;; Initial SDM checkin with install, run and test commands
;;; Initial winpred.lps and random.lsp checkin
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

; randinit
(defun randinit-+(fno seed)
  (randominit seed)
  (osql-result seed (eq 1 1)))

(osql "
create function randinit(Integer seed)->Boolean
  as foreign 'randinit-+';")

; nrand - Lisp implementation of the foreign fn to calculate N~(0,1)  
(defun nrand ()
  (let (v1 v2 s (BN 100000000))
    (setq v2 (- (* 2 (/ (rand 0 BN) (+ BN 0.1))) 1))
    (do ((v1 (setq v1 v2) (setq v1 v2))
	 (v2 (setq v2 (- (* 2 (/ (rand 0 BN) (+ BN 0.1))) 1)) (setq v2 (- (* 2 (/ (rand 0 BN) (+ BN 0.1))) 1)))
	 (s (setq s (+ (* v1 v1) (* v2 v2))) (setq s (+ (* v1 v1) (* v2 v2)))))
	((and (> s 0.0) (< s 1.0)) (* v1 (sqrt (* -2.0 (/ (log s) s) )))))))	
  
(defun nrandf (fno r)
  (osql-result(nrand)))

;osql definition of nrand() N~(0,1) 
(osql "  
create function nrand()->number 
as foreign 'nrandf';")

;osql definition of urand() U~(0,1)
(osql "
create function urand()->number 
as select rand(10000000)/10000000.0;")

;osql definition of function that generates k uniform random numbers
(osql "
create function urands(Integer k)->Real 
as for each Integer i where i=iota(1,k) result urand();")

;osql definition of function that generates k normal random numbers
(osql "
create function nrands(Integer k)->Number 
as for each Integer i where i=iota(1,k) result nrand();")

; osql definitions of functions for generating random vectors / matrices 
(osql "

create function randvec(Integer i, Charstring rfname)-> Vector of Number 
/* Function to generate a vector of i random numbers using the random 
   function named rfname */  
  as vselect in(apply(theresolvent(rfname), {i}));

create function urandvec(Integer i)-> Vector of Number
/* Function to generate a vector of i uniform real random numbers */ 
  as vselect urands(i);

create function nrandvec(Integer i)-> Vector of Number 
/* Function to generate a vector of i normal real random numbers */ 
  as vselect nrands(i);

create function randvecs(Integer i, Integer j, Charstring rfname)
                         -> Bag of Vector of Number
/* Function to generate a j vectors of i random numbers using the random 
   function named rfname */  
  as for each Integer k where k=iota(1,j) result randvec(i, rfname);

create function urandvecs(Integer i, Integer j)-> Bag of Vector of Number 
/* Function to generate a j vectors of i uniform real random numbers */ 
  as for each integer k where k=iota(1,j) result urandvec(i);

create function nrandvecs(Integer i, Integer j)-> Bag of Vector of Number 
/* Function to generate a vector of i normal real random numbers */ 
  as for each Integer k where k=iota(1,j) result nrandvec(i);

create function randmat(Integer i, Integer j, Charstring rfname)
                        -> Vector of Vector of Number 
/* Function to generate a j by i matrix of random numbers using the random
   function names rfname */
  as vselect randvecs(i,j,rfname);

create function urandmat(Integer i, Integer j)-> Vector of Vector of Number 
/* Function to generate a j by i matrix of uniform real random numbers */
  as vselect urandvecs(i,j);

create function urandmat(Integer i, Integer j)-> Vector of Vector of Number 
/* Function to generate a j by i matrix of uniform real random numbers */
  as vselect urandvecs(i,j);

create function nrandmat(Integer i, Integer j)-> Vector of Vector of Number 
/* Function to generate a j by i matrix of uniform real random numbers */
  as vselect nrandvecs(i,j);

")

; random stream fn definitions 

; lisp fn that generates size-number of ~U(0,limit) integers 
(defun uirandstream0--+ (fno limit size r)
  (rptq size (osql-result limit size (random limit))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function uirandstream0(Integer limit, Integer size)->Bag of Integer
  as foreign 'uirandstream0--+';")

;osql fn to convert the size-number of ~U(0,limit) integers to a stream of integers 
(osql "
create function uirandstream(Integer limit, Integer size)->Stream of Integer
  as streamof(uirandstream0(limit,size));")

; lisp fn that generates size-number of ~U(0,1) reals 
(defun urrandstream0-+ (fno size r)
  (rptq size (osql-result size (/ (random 1000000) 1000000.0))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function urrandstream0(Integer size)->Bag of Real
  as foreign 'urrandstream0-+';")

;osql fn to convert the size-number of ~U(0,1) reals to a stream of reals 
(osql "
create function urrandstream(Integer size)->Stream of Real
  as streamof(urrandstream0(size));")

; lisp fn that generates size-number of ~N(0,1) reals  
(defun nrrandstream0-+ (fno size r)
  (rptq size (osql-result size (nrand))))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function nrrandstream0(Integer size)->Bag of Real
  as foreign 'nrrandstream0-+';")

;osql fn to convert the size-number of ~N(0,1) reals to a stream of reals
(osql "
create function nrrandstream(Integer size)->Stream of Real
  as streamof(nrrandstream0(size));")

(osql "
create function randbag(Integer limit, Integer k)-> Bag of Integer
as 
begin
   randinit(integer(clock()*1000));
   for each Integer i where i in iota(1,k) result integer((rand(limit)*10000)/10000);
end;

create function randstream(Integer limit, Integer k) -> Stream of Integer
  as streamof(randbag(limit, k));")










