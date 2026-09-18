;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler, UDBL
;;; $RCSfile: numarray.lsp,v $
;;; $Revision: 1.23 $ $Date: 2013/04/15 16:58:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Binary represented numerical arrays
;;; =============================================================
;;; $Log: numarray.lsp,v $
;;; Revision 1.23  2013/04/15 16:58:58  torer
;;; Single precision flotaing point numarrays introduced
;;;
;;; =============================================================

(defglobal _numarray_
  (CREATELITERALTYPE 'numarray (list _collection_) 'numarray
		     nil #'type-of-numarray))
(defglobal _darray_
  (CREATELITERALTYPE 'darray (list _numarray_) 'numarray
		     nil #'type-of-numarray))
(defglobal _carray_
  (CREATELITERALTYPE 'carray (list _numarray_) 'numarray
		     nil #'type-of-numarray))
(defglobal _iarray_
  (CREATELITERALTYPE 'iarray (list _numarray_) 'numarray
		     nil #'type-of-numarray))

(defglobal _farray_
  (CREATELITERALTYPE 'farray (list _numarray_) 'numarray
		     nil #'type-of-numarray))

; <TODO: Parameterize numarray types (numarray=root type)>
;(defglobal _darray_
;  (CREATELITERALTYPE 'darray (list _numarray_) 'numarray
;		     #'print-numarray #'type-of-numarray))
;(defglobal _carray_
;  (CREATELITERALTYPE 'carray (list _numarray_) 'numarray
;		     #'print-numarray #'type-of-numarray))
;(defglobal _iarray_
;  (CREATELITERALTYPE 'iarray (list _numarray_) 'numarray
;		     #'print-numarray #'type-of-numarray))
;(putobject _darray_ 'root-type _numarray_)
;(putobject _carray_ 'root-type _numarray_)
;(putobject _iarray_ 'root-type _numarray_)
;(set-type-parameters _darray_ (list _real_))
;(set-type-parameters _carray_ (list (gettypenamed 'complex)))
;(set-type-parameters _iarray_ (list _integer_))
; </TODO>

(defun make-numarray (size tp)
  (cond ((eq tp _carray_) (make-carray size))
	((eq tp _darray_) (make-darray size))
	((eq tp _iarray_) (make-iarray size))
        ((eq tp _farray_) (make-farray size))
	(t nil)))

(defun iarray (fno size res)
  (osql-result size (make-iarray size)))
(osql "create function iarray(integer)->iarray as foreign 'iarray';")

(defun initialize-iarray (fno init res)
  (osql-result init (init-iarray init)))
(osql "create function iarray(Vector of Integer)->Iarray 
  as foreign 'initialize-iarray';")

(defun darray (fno size res)
  (osql-result size (make-darray size)))
(osql "create function darray(integer)->darray as foreign 'darray';")

(defun initialize-darray (fno init res)
  (osql-result init (init-darray init)))
(osql "create function darray(Vector of Number)->Darray 
  as foreign 'initialize-darray';")

(defun farray (fno size res)
  (osql-result size (make-farray size)))
(osql "create function farray(integer)->Farray as foreign 'farray';")

(defun initialize-farray (fno init res)
  (osql-result init (init-farray init)))
(osql "create function farray(Vector of Number)->Farray 
  as foreign 'initialize-farray';")

(defun carray (fno size res)
  (osql-result size (make-carray size)))
(osql "create function carray(integer)->carray as foreign 'carray';")

(defun initialize-carray (fno init-re init-im res)
  (osql-result init-re init-im (init-carray init-re init-im)))
(osql "create function carray(Vector of Real, Vector of Real)->Carray 
  as foreign 'initialize-carray';")

(defun initialize-ccarray (fno init res)
  (osql-result init (init-ccarray init)))
(osql "create function carray(Carray)->Carray 
  as foreign 'initialize-ccarray';")

(defun dim-narray (fno arr res)
  (osql-result arr (dim-numarray arr)))
(osql "create function dim(numarray)->integer as foreign 'dim-narray';")

(set-resulttypesfn 
 (osql 
  "create function vref(Numarray v, Integer i)->Number e
as multidirectional
  ('bbf' foreign 'numvrefbbf' cost {0.8,0.99})
  ('bbb' foreign 'numvrefbbf' cost {0.8,0.1})
  ('bff' foreign 'numvrefbff' cost {40,50});")
 'numvref-resulttypes)

(defglobal _complex_ (gettypenamed 'complex)) 

(defun numvref-resulttypes (fno args)
  "The result type is the element type of the argument"
  (let ((tp (arg-type (car args))))
    (cond ((eq tp _carray_) (list _complex_))
	  ((eq tp _darray_) (list _real_))
	  ((eq tp _iarray_) (list _integer_))
          ((eq tp _farray_) (list _real_))
	  (t nil))))

(defun na2vec (na)
  (let* ((d (dim-numarray na))
	 (r (make-array d)))
    (dotimes (i d)
      (seta r i (na-elt na i)))
    r))

(defun na2vecbf (fno na res)
  (osql-result na (na2vec na)))
(osql "create function na2vec(numarray)->vector of number
       as foreign 'na2vecbf';")

(defun timestamp-iarray (fno ia startpos)
  (let ((time (gettimeofday)))
    (na-seta ia startpos (timeval-sec time))
    (na-seta ia (+ startpos 1) (timeval-usec time))
    (osql-result ia startpos ia)))
(osql "create function ts_iarray(iarray, integer startpos)->iarray
       as foreign 'timestamp-iarray';")

(defun get-iarray-ts (fno ia startpos)
  (let ((ret (+
	      (na-elt ia startpos)
	      (/ (na-elt ia (+ startpos 1)) 1000000.0))))
    (osql-result ia startpos ret)))

(osql "create function get_iarray_ts(iarray, integer startpos)->real
       as foreign 'get-iarray-ts';")

(defun enum_na--+ (fno na i res)
  (osql-result na i (na-enum na i)))

(osql "create function enum_na(numarray, integer ind)->numarray
       as foreign 'enum_na--+';")
