;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Koparanova, UDBL
;;; $RCSfile: lispbox.lsp,v $
;;; $Revision: 1.26 $ $Date: 2005/09/08 16:16:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Special operations in Lisp
;;;      Timestamped join and merge 
;;;              
;;; ===========================================================================


;; 12.04.2005 descr-get now returns mytuple: (cons tag vectordata)
;; all calls replaced with (cdr (apply (descr-get...))) to extract vector data
;; algos work with vector data 

;; TIMESTAMP Generation
(defglobal _last-timeofday_ (gettimeofday))
(defglobal _last-usec_ 0)

(defun timeval-eq (tv1 tv2)
(and (equal (timeval-sec tv1) (timeval-sec tv2))
     (equal (timeval-usec tv1) (timeval-usec tv2))))

(defun getts ()
  (let ((tm (gettimeofday)))
    (if (timeval-eq tm _last-timeofday_)
	(progn (setq _last-usec_ (1+ _last-usec_))
	       (setq tm (mktimeval (timeval-sec tm)
				   (+ (timeval-usec tm) _last-usec_))))
      (progn (setq _last-usec_ 0)
	     (setq _last-timeofday_ tm)))
    tm
))

(foreign-lispfn getts () ((timeval))
		(foreign-result (getts)))
     
     


;;; TSMERGE

(defglobal _last-ts_ nil)
(defglobal _time-out_ 0.1)

(defun init-tsmerge (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))

    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) insl)
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) outl) 
    (setq _last-ts_ (mktimeval 0 0))     ;; last ts merged
    (setq _time-out_ (car (box-paraml b))) ;; time-out is a parameter
    (setf (box-rep b) 1) ;; always schedule once indep. on stream current data
))


(defun cleanup-tsmerge (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) insl)
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) outl)
))


(defun find-min-ts (l)
  "Find the element with minimal timestamp (a. #(tsa ...)).
 l is assoc list of kind ((a. #(tsa ...)) (b . #(tsb ..)) ..).
Return the cons with min timestamp"
  (let (l1 sm mts)
    (setq l1 (mapcar (f/l (s) (if (cdr s) s nil)) l))
    (setq l1 (remove nil l1))
    (if l1 
	(let ((mts (aref (cdar l1) 0)))
	  (setq sm (car l1))
	  (dolist (s (cdr l1))
	    (if (timeval-less (aref (cdr s) 0) mts)
		(let () (setq mts (aref (cdr s) 0))
		     (setq sm s))))))
    sm
))


(defun tsmerge (timeout)
"Merge sort of N streams sorted on timestamp. Timestamp always at pos 0 in the stream elements -vectors"
  (let* ((b _curbox_) startpush
	 (insl (mapcar 'car (box-inputstreaml b))) 
	 (outl (box-outputstreaml b))
	  emptyexist s sm el)

     ;;read an element from all input streams  and put them into the 
     ;; local buffers for the operation
    
     (mapc (f/l (s) 
	  ;; s is strobj
	(let (el eofstr)
	  (cond ((null (cdr (assoc s (box-inputstreaml b))))
	      ;; empty buffer - read new element
		(while (and (null el) (null eofstr))
		     (setq el (cdr
			   (apply (descr-get (getobject s 'descr)) (list s))))
		     (if el
			 ;; if el is timed-out - drop it
			 (if (not (timeval-greater (aref el 0) _last-ts_))
			     (setq el nil))
		       (setq eofstr t)))
		(if eofstr (setq emptyexist t)
		  (setf (box-inputstreaml b)
			(putassoc s el (box-inputstreaml b))))))))
	   insl)
  
    ;;; execute operation
     (cond ((and emptyexist (null (stat-last (box-stat b)))) nil)
	   ;; no executions before, wait for all streams- emptyexist=nil

	   ((and emptyexist (stat-last (box-stat b)))
		 ;; special treatment if some of the streams stoped
	    (if (> (wallclocktime (gettimeofday) (stat-last (box-stat b)))
		   _time-out_)
	    ;; time-out, don't wait for empty streams
		;; merge elements from nonempty streams
		(let ()
		  (setq sm (find-min-ts (box-inputstreaml b)))
		  (if sm (let ()
			  ;;  (print "Emptyexist") (print emptyexist)
			   (setq s (car sm))
			   ;; put it to the output
			   (setq startpush (gettimeofday))
			   (mapc (f/l (out)
			     (apply (descr-put (getobject out 'descr))
			      (list out (cons (getobject out 'tag)(cdr sm)))))
				 outl)
			   (setq _push-time-sched_ (+ _push-time-sched_ 
			       (wallclocktime startpush (gettimeofday))))
		;;	   (print "cnt:") (print (stat-cnt (box-stat b))) 
		;;	   (print s) (print sm)
			   (update-bstat (box-stat b) 1)
	;;		   (update-exec-stat (box-id b) (stat-cnt (box-stat b)))
			   (setq _last-ts_ (aref (cdr sm) 0))
			   ;;clean the local buffer from the consumed element
			   (setf (box-inputstreaml b)
				 (putassoc s nil (box-inputstreaml b)))
		  )))))

	   ((while (null emptyexist)  ;; regular case all streams have data
	     ;;  (print "Emptyexist - while") (print emptyexist)
	      ;; find min ts elements
	      (setq sm (find-min-ts (box-inputstreaml b)))
;;	      (print "Chosen min")(print sm)

	      (setq s (car sm))
	      ;; put it to the output
	      (setq startpush (gettimeofday))
	      (mapc (f/l (out)
			 (apply (descr-put (getobject out 'descr))
 			    (list out (cons (getobject out 'tag)(cdr sm)))))
		    outl)
	      (setq _push-time-sched_ (+ _push-time-sched_ 
			       (wallclocktime startpush (gettimeofday))))
;;	      (print "cnt:") (print (stat-cnt (box-stat b))) (print s) 
	      (update-bstat (box-stat b) 1)
;;	      (update-exec-stat (box-id b) (stat-cnt (box-stat b)))
	      (setq _last-ts_ (aref (cdr sm) 0))
	      ;;clean the local buffer from the consumed element
	      (setf (box-inputstreaml b)
		    (putassoc s nil (box-inputstreaml b)))

	      ;; read next element from the stream with the min ts
	      (setq el (cdr (apply (descr-get (getobject s 'descr)) (list s))))
	    ;;  (print "read from ") (print el)
	      (if (and el  
		  (t> (aref el 0) _last-ts_))
		  (setf (box-inputstreaml b)
			(putassoc s el (box-inputstreaml b)))
		(setq el nil)) ;; if el is timed-out - drop it
	      (if (null el) (setq emptyexist t))))
	   )
     nil ; returns res nil to not update box stat of lisp box
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TSJOIN

(defun htname (src)
"Given an atom- source name, return the name of the corresponding hash table for the operation"
(mkatom (concat "_ht-" src "_"))
)

(defmacro defhashtable (src)
`(defglobal , (htname src) , (make-hash-table :test (function equal))))

(defun init-tsjoin (b)
"Initialize timestamp join operation. Streams to be joined are in box-inputstreaml."
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    ;; open input streams
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) insl)
    ;; open result streams
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) outl)
    ;;create initially hash-tables for all stream sources
    (dolist (s insl)
      (eval (list 'defhashtable (getobject s 'name))))
    ;; added for scheduling purposes
    ;; for 2 input streams: 2 CD for 1 tsjoin
;;    (if (< (box-rep _cd_) (length insl))
;;	(progn (setf (box-rep _cd_) (length insl))
;;	       (formatl t "CD repeats " (box-rep _cd_) t)))
))

(defun cleanup-tsjoin (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) insl)
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) outl)
))


(defun combinevectors (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and concatenated vectors in pos i"
  (let* ((n (length l)) ;; number of streams to be joined
       (k (length (car l))); number of data fields
       (a (make-array k)) j0)  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the common timestamp
    (dotimes (i (1- k)) ;for each vector datafield - combine pieces
      (let* (ai (ii (1+ i)) sa
	       (ki (length (aref (car l) ii))))  ;; length of 1 piece
	(setq ai (make-array (* n ki)))
	(setq j0 0)
	(dolist (s l)
	  (setq sa (aref s ii))
	  (dotimes (j ki)
	    (seta ai (+ j0 j) (aref sa j)))
	  (setq j0 (+ j0 ki)))
	(seta a ii ai)
	))
    a
))


(defun combinefields (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and concatenate all other fields of all vectors as ordered in the list"
  (let* ((n (length l)) ;; number of streams to be joined
       (k (1+ (- (apply '+ (mapcar 'array-total-size l))
	     (length l)))); number of data fields
       (a (make-array k)) jj f)  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the common timestamp
    (setq jj 1)
    (dolist (s l) ; for each source vector
      (dotimes (j (1- (array-total-size s))) ;for each field j
	(setq f (aref s (1+ j)))
	(seta a jj 
	      (cond ((atom f) f)
		    ((arrayp f) (copy-array f))))
	(setq jj (1+ jj))
	)
    )
    a
))

(defun tsjoin (comb restp)
"Timestamped join of stream sources.
 Timestamp always at pos 0 in the stream elements -vectors"
  (let* ((b _curbox_) startpush
	 (insl (mapcar 'car (box-inputstreaml b))) 
	 (outl (box-outputstreaml b))
	 (ps (car insl)) (slist (cdr insl))
    ;;choose probing source ps - now first in the list
	 el ht psht pslist htlist (n (length insl)))

    (setq htlist (mapcar (f/l (s) (htname (getobject s 'name)))
			 slist))
    ;; list of hash table names

     ;;read data and put in hash tables for all sources except ps
    (dolist (s slist)
      (setq ht (htname (getobject s 'name)))
      (setq el t)
      (while el
	(setq el (cdr (apply (descr-get (getobject s 'descr)) (list s))))
	(if el (puthash (aref el 0) (eval ht) el)))
      )

    ;; get data from the probing source hash table and sort them
    (setq psht (htname (getobject ps 'name)))
    (maphash (f/l (k v) (setq pslist (cons v pslist))) (eval psht))
    ;; cleanup the ps hash table
    (mapc (f/l (el) (remhash (aref el 0) (eval psht))) pslist)
    ;; sort tuples on timestamp - read from hash probably unordered
    (setq pslist (sort pslist (f/l (x y) 
				 (timeval-less (aref x 0) (aref y 0)))))
    ;; read newcoming data
    (setq el t)
    (while el
      (setq el (cdr (apply (descr-get (getobject ps 'descr)) (list ps))))
      (if el (setq pslist (append2 pslist (list el)))))

   ;;iterate on tuples from the probing source
   (dolist (tpl pslist)
     (let (arglist)
       (setq arglist (mapcar (f/l (ht) 
				  (gethash (aref tpl 0) (eval ht))) htlist))
       (setq arglist (cons tpl (delete nil arglist)))
        ;; if probing successful - combine data
       (if (equal (length arglist) n) 
	   (let ((res (apply comb (list arglist))))
	     ;; combine and put result to the outputs
	     (setq startpush (gettimeofday))
	     (mapc (f/l (out)
			 (apply (descr-put (getobject out 'descr))
				(list out (cons (getobject out 'tag) res))))
		    outl)
	     (setq _push-time-sched_ (+ _push-time-sched_ 
			       (wallclocktime startpush (gettimeofday))))
	     (update-bstat (box-stat b) 1)
;;	     (update-exec-stat (box-id b) (stat-cnt (box-stat b)))
	   ;;and drop processed data from all hash tables
	   (mapc (f/l (ht) (remhash (aref tpl 0) (eval ht))) htlist))

	 ;;if probing not successful add the probing tuple to its hash table
	 (puthash (aref tpl 0) (eval psht) tpl))
     ))
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FFT partitioning and combine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; OBS! Old lisp implementation
(defun fftpart_vector (x n pno)
"Creates a FFT subarray from x, n is the number of partitions, pno is the partition number to be created. E.g. n=2,pno=0 - extracts the elements with even indices"
  (let* ((sz (array-total-size x))
	 (psz (/ sz n))
	 (a (make-array psz)))

    (dotimes (i psz)
	     (seta a i (aref x (+ (* n i) pno))))
    a)
)


(defun fftpartbbbf_old (fnobj x n pno)
  (osql-result x n pno (fftpart_vector x n pno))
)


;; new partitioning foreign C function fft-part
(defun fftpartbbbf (fnobj x n pno)
  (osql-result x n pno (fft-part x n pno))
)

(osql "create function fftpart (vector of complex x,
                              integer n, integer pno)->
			      vector of complex y		
as foreign 'fftpartbbbf';")


(defun fftcombine (x y)
"From 2 vectors of complex x and y with size n create a vector with size 2n computed according fft formula"
  (let* ((n2 (array-total-size x))
	 (n (* 2 n2))
	 (a (make-array n)))  ;; new vector

    (dotimes (i n)  
      (seta a i 
	    (trunccomplex 
	     (sumcomplex 
	      (aref x (mod i n2))
	      (multcomplex (ncomplex_root_pow n i) (aref y (mod i n2)))) 
	    1)))
    a
))


;; uses Lisp fftcombine
(defun fftcombinetuples_old (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and fft- combined vectors in all other positions"
  (let* ((n (length l)) ;; number of tuples to be combined
       (k (length (car l))); number of data fields
       (a (make-array k)))  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the common timestamp
    (dotimes (i (1- k)) ;for each vector datafield - combine pieces
      (let ((ii (1+ i)))
	(seta a ii (apply 'fftcombine 
			  (mapcar (f/l (tpl) (aref tpl ii)) l)
	))))
    a
))

;; new version - foreign C fft-combine
(defun fftcombinetuples (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and fft- combined vectors in all other positions"
  (let* ((n (length l)) ;; number of tuples to be combined
       (k (length (car l))); number of data fields
       (a (make-array k)))  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the common timestamp
    (dotimes (i (1- k)) ;for each vector datafield - combine pieces
      (let ((ii (1+ i)))
	(seta a ii (trunc-complex-array (apply 'fft-combine 
			  (mapcar (f/l (tpl) (aref tpl ii)) l)
	)))))
     a
))

(defun fft4combinetuples (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and fft- combined vectors in all other positions"
  (let* ((n (length l)) ;; number of tuples to be combined
       (k (length (car l))); number of data fields
       (a (make-array k)))  ;; new tuple as vector

    (if (eq n 4)
	(progn
	  (seta a 0 (aref (car l) 0)) ;; set the common timestamp
	  (dotimes (i (1- k)) ;for each vector datafield - combine pieces
	    (let* ((ii (1+ i))
		   (a1 (aref (first l) ii))
		   (a2 (aref (second l) ii))
		   (a3 (aref (third l) ii))
		   (a4 (aref (fourth l) ii)))

	      (seta a ii (trunc-complex-array
			  (fft-combine 
			   (fft-combine a1 a3)
			   (fft-combine a2 a4))))
	      ))))
    a
    ))

(defun fft8combinetuples (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and fft- combined vectors in all other positions"
  (let* ((n (length l)) ;; number of tuples to be combined
       (k (length (car l))); number of data fields
       (a (make-array k)))  ;; new tuple as vector

    (if (eq n 8)
	(progn
	  (seta a 0 (aref (car l) 0)) ;; set the common timestamp
	  (dotimes (i (1- k)) ;for each vector datafield - combine pieces
	    (let* ((ii (1+ i))
		   (a1 (fft-combine (aref (first l) ii) (aref (fifth l) ii)))
		   (a2 (fft-combine (aref (second l) ii) (aref (sixth l) ii)))
		   (a3 (fft-combine (aref (third l) ii) (aref (seventh l) ii)))
		   (a4 (fft-combine (aref (fourth l) ii) (aref (eighth l) ii))))

	      (seta a ii (trunc-complex-array
			  (fft-combine 
			   (fft-combine a1 a3)
			   (fft-combine a2 a4))))
	      ))))
    a
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; New version
(defun fft3combine (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and fft- combined vectors in all other positions"
  (let ((n (length l))) ;; number of tuples to be combined
      
    (cond ((equal n 2)
	   (let* ((k (length (car l))); number of data fields
		 (a (make-array k)))  ;; new tuple as vector
	   (seta a 0 (aref (car l) 0)) ;; set the common timestamp
	   (dotimes (i (1- k)) ;for each vector datafield - combine pieces
	     (let ((ii (1+ i)))
	       (seta a ii (trunc-complex-array (apply 'fft-combine 
				      (mapcar (f/l (tpl) (aref tpl ii)) l)
;; no trunc?	       (seta a ii (apply 'fft-combine 
;;			      (mapcar (f/l (tpl) (aref tpl ii)) l)
	)))))
	   a
	   ))
	  ((equal (mod n 2) 0) ;; recursive call
	   (let ((n2 (round (/ n 2)))
		 rl)              ;; list of combined tuples in pairs
	     (dotimes (i n2)
	       (setq rl (append2 rl 
		 (list (fft3combine (list (nth i l) (nth (+ i n2) l)))))))
	     (fft3combine rl)))

	   (t nil) ;; function does not work for odd number of elements
	   )
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;

;;(defun dft+- (fnobj x sz pno y)
;;"Computes partial sum of DFT for the partition pno. Result has sz elements"
;; (osql-result x sz pno (trunc-complex-array(dft x sz pno))))
 
(defun dft+- (fnobj x ptot pno y)
"Computes partial sum of DFT for the partition pno. Result has sz elements"
 (osql-result x ptot pno (trunc-complex-array 
			  (dft x (* ptot (array-total-size x)) pno))))
 
	   
;;(osql "create function dft(vector of complex x, integer sz, integer pno)
;; -> vector of complex y as foreign 'dft+-';")
(osql "create function dft(vector of complex x, integer ptot, integer pno)
 -> vector of complex y as foreign 'dft+-';")

(osql "create function dft(vector of complex x)  -> vector of complex y 
as select dft(x,1,0);")

(defun dft3combine (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and sum of the vectors in all other positions by dft-combine"
  (let ((n (length l))) ;; number of tuples to be combined
      
    (cond ((equal n 2)
	   (let* ((k (length (car l))); number of data fields
		 (a (make-array k)))  ;; new tuple as vector
	   (seta a 0 (aref (car l) 0)) ;; set the common timestamp
	   (dotimes (i (1- k)) ;for each vector datafield - combine pieces
	     (let ((ii (1+ i)))
	       (seta a ii (apply 'dft-combine 
				      (mapcar (f/l (tpl) (aref tpl ii)) l)
				      ))))
	   a
	   ))
	  ((equal (mod n 2) 0) ;; recursive call
	   (let ((n2 (round (/ n 2)))
		 rl)              ;; list of combined tuples in pairs
	     (dotimes (i n2)
	       (setq rl (append2 rl 
		 (list (dft-combine (list (nth (* i 2) l) 
					   (nth (+ (* i 2) 1) l)))))))
	     (dft-combine rl)))

	   (t nil) ;; function does not work for odd number of elements
	   )
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;! OBS new C implementation vector-concat

(defun tuple-concat (l)
"l is list of vectors - untagged tuples. Create a vector with the same ts at pos 0 and concatenated vectors in all other positions"
  (let ((n (length l))) ;; number of tuples to be combined
      
    (cond ((equal n 2)
	   (let* ((k (length (car l))); number of data fields
		 (a (make-array k)))  ;; new tuple as vector
	   (seta a 0 (aref (car l) 0)) ;; set the common timestamp
	   (dotimes (i (1- k)) ;for each vector datafield - combine pieces
	     (let ((ii (1+ i)))
	       (seta a ii (apply 'vector-concat 
				      (mapcar (f/l (tpl) (aref tpl ii)) l)
				      ))))
	   a
	   ))
	  ((equal (mod n 2) 0) ;; recursive call
	   (let ((n2 (round (/ n 2)))
		 rl)              ;; list of combined tuples in pairs
	     (dotimes (i n2)
	       (setq rl (append2 rl 
		 (list (tuple-concat (list (nth (* i 2) l) 
					   (nth (+ (* i 2) 1) l)))))))
	     (tuple-concat rl)))

	   (t nil) ;; function does not work for odd number of elements
	   )
))

(defun vector-partbbbf (fnobj x n pno)
  (osql-result x n pno (vector-part x n pno))
)

(osql "create function vector_part (vector of complex x,
                              integer n, integer pno)->
			      vector of complex y		
as foreign 'vector-partbbbf';")



(defun vectorconcat (l)
"List of k vectors of size n are concated into a vector of size k*n"
   (let* ((k (length l)) ;; number of vectors
       (n (length (car l))); size of a vector
       (a (make-array (* n k))) j0 )  ;; new  vector

	(setq j0 0)
	(dolist (x l)  ;for each vector 
	  (dotimes (i n)    ;; transfer its elements into the new
 	    (seta a (+ j0 i)  (aref x i)))
	  (setq j0 (+ j0 n)))
	a
))


(defun aggregate-window-old (w)
"vector of tuples w is aggregated into 1 tuple by concatenating the correspondent fields"
  (let* ((l (mapcar 'cdr (arraytolist w)))
	 (n (length l)) ;; number of elements in the window to be aggr
	 (k (length (car l))); number of data fields
	 (a (make-array k)))  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the first timestamp in the window
    (dotimes (i (1- k)) ;for each vector datafield - combine pieces by concat
      (let ((ii (1+ i)))
	(seta a ii (apply 'vectorconcat 
			 (list (mapcar (f/l (tpl) (aref tpl ii)) l))
	))))
    a
))
(defun aggregate-window (w)
"vector of tuples w is aggregated into 1 tuple by concatenating the correspondent fields"
  (let* ((l (mapcar 'cdr (arraytolist w)))
	 (n (length l)) ;; number of elements in the window to be aggr
	 (k (length (car l))); number of data fields
	 (a (make-array k)))  ;; new tuple as vector

    (seta a 0 (aref (car l) 0)) ;; set the first timestamp in the window
    (dotimes (i (1- k)) ;for each vector datafield - combine pieces by concat
      (let ((ii (1+ i)))

	(if (eq n 2)
	(seta a ii (vector-concat (aref (car l) ii) (aref (cadr l) ii)))
	(seta a ii (vector-concatn 
		    (listtoarray (mapcar (f/l (tpl) (aref tpl ii)) l)))))))
    a
))

(defun aggregate-windowbf (fnobj w res)
  (osql-result w (aggregate-window w))
)

(osql "create function aggregate_window(vector w)->
          vector res as foreign 'aggregate-windowbf';")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Chop/Unchop Functionality

(defun chop-array (x n ni)
  (let* ((k (array-total-size x))
	(chop_sz (/ k n))
	(l (* ni chop_sz))
	(h (- (+ l chop_sz) 1)))
(subarray x l h)
))

(defun chop-tuple (tpl n ni)
"Creates chop ni out of n for the tuple tpl by choping all the vector fields inside"
  (let* ((k (array-total-size tpl)); number of data fields
       (a (make-array k)) f fni)  ;; new tuple as vector

    (seta a 0 (aref tpl 0)) ;; set the same timestamp
    ;; to do: consider differenet timestamp or an extra field : chop number
    (dotimes (j (1- k)) ;for each field j
      (cond ((arrayp (aref tpl (1+ j))) 
	   ;  (seta a (1+ j)(vector-part (aref tpl (1+ j)) n ni)))
	     (seta a (1+ j)(chop-array (aref tpl (1+ j)) n ni)))
	    ((atom (aref tpl (1+ j))) 
	     (seta a (1+ j) (aref tpl (1+ j))))
	    )
	)
    a
))

;;; Iterative chop on stream

(defun init-chop (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))

    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) insl)
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) outl) 
    (setf (box-rep b) (car (box-paraml b)))
    (setf (box-conseq_exec b) nil)
    ;; always schedule repetitions = number of chops
))


(defun cleanup-chop (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) insl)
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) outl)
))



(defun chop (n)
"Iteratively takes the next chop of the current stream tuple. n is the total number of chops. The stream parameter is defined in inputstreaml"
  (let* ((b _curbox_) startpush
	 (insl (mapcar 'car (box-inputstreaml b))) 
	 (outl (box-outputstreaml b)) el ni outtpl
	 (s (car insl))  ;; input stream object
	 (sb (assoc s (box-inputstreaml b)))) ;; s buffer (#oid ni tpl)

     ;;if the local buffer is empty read an element from the input stream 
    ;; and put it into the local buffer for the operation
    (cond ((null (cdr sb))
	      ;; empty buffer - read new element
	   (setq el (cdr
		 (apply (descr-get (getobject s 'descr)) (list s))))
	   (if el
	       (setf (box-inputstreaml b)
			(putassoc s (list 0 el) (box-inputstreaml b))))
	  (setq sb (assoc s (box-inputstreaml b)))))

 
    (cond ((null (cdr sb)) );; no input data - do nothing
	  ;; extract chop ni
	  (t (setq ni (second sb))
	   (setq outtpl (chop-tuple (third sb) n ni))
	     ;; put it to the output
	   (setq startpush (gettimeofday))
	     (mapc (f/l (out)
			(apply (descr-put (getobject out 'descr))
			       (list out (cons (getobject out 'tag) outtpl))))
		   outl)
	     (setq _push-time-sched_ (+ _push-time-sched_ 
			       (wallclocktime startpush (gettimeofday))))
	     (update-bstat (box-stat b) 1)
;;	     (update-exec-stat (box-id b) (stat-cnt (box-stat b)))

	     ;;increase ni by 1
	     (setq ni (1+ ni))
	     (if (eq ni n)
	 ;; all chops created -> empty local buffer from the consumed tuple
		 (setf (box-inputstreaml b)
		       (putassoc s nil (box-inputstreaml b)))
	   ;; increase the state var ni
	       (setf (box-inputstreaml b)
		     (putassoc s (list ni (third sb)) (box-inputstreaml b))))
	     ))
))
