;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_constructor.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/04/09 10:20:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp and derived osql definitions of functions 
;;; for stream constructors 1s(size) and 0s(size) of time integer
;;; and real.
;;; =============================================================
;;; $Log: stream_constructor.lsp,v $
;;; Revision 1.1  2009/04/09 10:20:10  gyogi445
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

; Fns to generate a stream of 1s of type integer and real 

; lisp fn that generates size-number of integer 1s 
(defun int1s0-+ (fno size r)
  (rptq size (osql-result size 1)))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function int1s0(Integer size)->Bag of Integer
  as foreign 'int1s0-+';")

;osql fn to convert the size-number of integer 1s to a stream of integer 1s 
(osql "
create function int1s(Integer size)->Stream of Integer
  as streamof(int1s0(size));")

; lisp fn that generates size-number of real 1s 
(defun real1s0-+ (fno size r)
  (rptq size (osql-result size 1.0)))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function real1s0(Integer size)->Bag of Real
  as foreign 'real1s0-+';")

;osql fn to convert the size-number of real 1s to a stream of real 1s 
(osql "
create function real1s(Integer size)->Stream of Real
  as streamof(real1s0(size));")

; Fns to generate a stream of 0s of type integer and real 

; lisp fn that generates size-number of integer 1s 
(defun int0s0-+ (fno size r)
  (rptq size (osql-result size 0)))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function int0s0(Integer size)->Bag of Integer
  as foreign 'int0s0-+';")

;osql fn to convert the size-number of integer 0s to a stream of integer 0s 
(osql "
create function int0s(Integer size)->Stream of Integer
  as streamof(int0s0(size));")

; lisp fn that generates size-number of real 0s 
(defun real0s0-+ (fno size r)
  (rptq size (osql-result size 0.0)))

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function real0s0(Integer size)->Bag of Real
  as foreign 'real0s0-+';")

;osql fn to convert the size-number of real 0s to a stream of real 0s 
(osql "
create function real0s(Integer size)->Stream of Real
  as streamof(real0s0(size));")

;lisp fn that repeats the stream s n times 
(defun srep--+ (obj s n r) 
  (rptq n 
	(mapbag s ;for all elements of the stream
		(f/l (row)
		     (osql-result s n row))))) ;emit fn(row) 

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function srep0(Stream s, Integer n)-> Bag of Object
  as foreign 'srep--+';")

;osql fn to convert n-times repeated sequence of stream elements to a stream
(osql "
create function srep(Stream s, Integer n)->Stream of Object
  as streamof(srep0(s, n));")

; Problem: Type of stream is not inferred dynamically.    

