;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: streams.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/03 13:36:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of the stream cursor 
;;; abstraction via co-routines. Simultanious asynchronous stream 
;;; iterators. Derived stream constructors and generators. 
;;;  
;;; =============================================================
;;; $Log: streams.lsp,v $
;;; Revision 1.1  2009/08/03 13:36:04  gyogi445
;;; streams
;;;
;;; Revision 1.1  2009/06/02 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defun mapstream (g fn)
  "Apply Lisp function fn on generator g and return *TERMINATED* when finished"
  (mapbag g fn);; Both streams and bags are generators
  '*terminated*)

(defun open-stream-cursor (b)
  "Open a cursor over a bag b"
  (coroutine 'mapstream (list b 'co-yield)))

(defun cursor-next (bc)
  "Get next tuple list from a bag cursor"
  (if (co-terminated bc) '*terminated*
    (co-resume bc)))
    
(defun advance-cursors (cl)
  "Move cursor list forward one step"
  (catch 'advance-cursors
    (do ((resv (buildl cl '*busy*) 
	       (mapcar 
		(f/l (c val)
		     (if (eq val '*busy*)
			 (let ((nx (cursor-next c)))
			   (selectq nx
				    (*terminated* (throw 'advance-cursors 
							 '*terminated*))
				    nx))
		       val))
		cl resv)))
	((not (memq '*busy* resv)) resv)
      (co-sleep 0.0001))))

(defun mapstreams (fn l)
  "Apply Lisp function on tuples emitted from a list of streams in parallell"
  (let* ((cv (mapcar (function open-stream-cursor) l)))
    (loop
      (let ((resv (advance-cursors cv)))
	(if (eq resv '*terminated*) (return resv)
	  (apply fn resv))))))

;(defun vmergestreams-+ (fno vs r)
;	(mapstreams (f/l (ls)
;		(osql-result vs (listtoarray ls)))
;	(arraytolist vs)))
;NOTE: Did not work! Why?

(defun vmergestreams-+ (fno vs r)
  "Vector merge the tuples emitted from a vector of streams in parallell"
  (let* ((cv (mapcar (function open-stream-cursor) (arraytolist vs))))
    (loop
      (let ((resv (advance-cursors cv)))
	(if (eq resv '*terminated*) (return resv)
	  (osql-result vs (listtoarray resv)))))))

(osql "
create function vmergestreams0(Vector of Stream vs) 
                               -> Bag of Vector  
/* Internal function to represent stream as bag */
  as foreign 'vmergestreams-+';")

(osql "
create function vmergestreams(Vector of Stream vs)
                              -> Stream of Vector
/* Function to merge elements from a vector of anynchronous 
   streams into a stream of vector */ 
  as streamof(vmergestreams0(vs));")

(defun sums--+ (fno x y r)
  (mapstreams (f/l (r1 r2) 
		   (osql-result x y (+ (car r1)(car r2))))
	      (list x y)))

(osql "
create function sums0(Stream of Number x, Stream of Number y) 
                    -> Bag of Number 
  /* Internal function to implement stream as bag */ 
  as foreign 'sums--+';")

(osql "
create function sums(Stream of Number x, Stream of Number y) 
                     -> Stream of number
/* Function to element-wise add two anynchronous streams */
  as streamof(sums0(x,y));")

(defun sindsel--+ (fno s i r)
  (mapstreams (f/l (s1 i1)  
		   (if (eq (car i1) 1)
		       (osql-result s i (car s1))))
	      (list s i)))

(osql "
create function sindsel0(Stream s, Stream of Integer si)
                         -> Object  
/* Internal function to represent stream as bag */
  as foreign 'sindsel--+';")

(osql "
create function sindsel(Stream s, Stream of Integer si) 
                        -> Stream 
/* Function that selects elements from stream s based on 
   the index streams si */
  as streamof(sindsel0(s, si));") 

(defun bagify-+ (fno str r)
  (mapstream str (f/l (row)(apply 'osql-result str row))))

(osql "
create function bagify (Stream s)-> Object 
  as foreign 'bagify-+';")

(foreign-lispfn sliota0 ((number sl)(integer from)(integer to))((integer))
		"Slow or sleeping iota()"
		(let ((r from))
		  (while (<= r to)
		    (foreign-result r)
		    (co-sleep sl)
		    (1++ r))))

(osql "
create function sliota(Real sl, Integer f, Integer t)
                        -> Stream of Integer 
/* Function slow/sleeping siota() */
  as select streamof(sliota0(sl,f,t));")

(osql "
create function sliota2(Integer u)-> Stream of Vector 
  /* This is just a test function that generates sleeping streams of vectors */
  as streamof(select {i, i*i} from integer i where i in sliota(0.5,1,u));")

(foreign-lispfn srbeep0 ((integer nb))((real))
		"Sleeping tic-toc"
		(let ((b 0)
		      (s 0))
		  (while (<= b nb)
		    (setq s (abs (/ (nrand) 2)))
		    (foreign-result s)
		    (co-sleep s)
		    (1++ b))))

(osql "
create function srbeep(Integer nb)
                       -> Stream of Real 
/* Random beep-sleep function */
  as streamof(srbeep0(nb));")

(foreign-lispfn sclock0 ((real sl) (integer nb))((real))
		"Sleeping clock"
		(let ((b 0))
		  (while (<= b nb)
		    (foreign-result (clock))
		    (co-sleep sl)
		    (1++ b))))


(osql "
create function sclock(Real sl, Integer k)
                       -> Stream of Real
  as streamof(sclock0(sl,k));
")

(osql "
create function project(Stream of Vector s, Integer pos)-> Stream of Object
/* Project position POS for stream of vectors */ 
  as streamof(select v[pos] from Vector v where v in s);")

(osql "
create function streamvec(Stream s)->Stream of Vector
/* Encapsulate the elements of stream s into (a stream of) vectors */ 
  as streamof(select {in(s)});")

(osql "
create function split(Stream of Vector s, Integer n) -> Vector of Stream
/* Function that splits a stream vector n-ways into a vector of streams 
   by projecting on the first n positions of each vector element of the 
   input stream */    
  as vselect project(s,i) 
     from Integer i
     where i in iota(0,n-1);")

(osql "
create function split(Stream of Vector s, Vector of Integer pv) 
                      -> Vector of Stream
/* Function that splits a stream vector into a vector of streams 
   by projecting each vector element of the input stream on the 
   positions in pv*/    
  as vselect project(s,i) 
     from Integer i
     where i in pv;") 

(osql "
create function vrepfn(Integer n, Charstring fname)  
                       -> Function 
  as eval('create function '+fname+' (Vector v)-> Vector 
             as vrep(v,'+n+');');

parteval('vrepfn');   

create function vec(Object o) -> Vector 
  as vector(o);")

(osql "
create function duplicate(Stream s, Integer n)
                          -> Vector of Stream 
  as select split(sv, n)
     from Function fn, Stream of Vector sv
     where sv = sapply(sapply(s, #'vec'), fn)
       and fn = vrepfn(n, 'vfn01'); 


/*  Tore: Here is the example with the re-read.
    You might also want to look at vmergestreams.
    Note that the problem is not the Cartesian product
    or the sequential vs simultanious processing of 
    multiple streams of the streams but that the stream 
    generators are called multiple times  as opposed to 
    once. */

/*
    
create function randbag(Integer k, Integer t)-> Bag of Integer 
  as for each Integer i where i in iota(1,k) result integer(rand(100*t)/100);

create function randstream(Integer k, Integer t) -> Stream of Integer
  as streamof(randbag(k, t));


select bagify(vmergestreams({s,s}))
from Stream s
where s = randstream(10);

select bagify(vmergestreams({s,s}))
from Stream s
where s = srbeep(10);
*/
");



