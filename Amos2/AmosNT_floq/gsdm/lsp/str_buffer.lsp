;;; ============================================================
;;; AMOS2, GSDM
;;; 
;;; Author: (c) 2003 Milena Koparanova, UDBL
;;; $RCSfile: str_buffer.lsp,v $
;;; $Revision: 1.12 $ $Date: 2004/08/31 14:17:10 $
;;;
;;; Description:  Buffers for streamed operations
;;; A buffer is implemented as a cyclic queue over an adjustable array
;;;
;;; INTERFACE functions:
;;; (buf-init sz &optional growfactor) initialize buffer with size sz and 
;;;               optionally factor of growing for the adjustable heap
;;; (buf-put buf data)  put data at the end of buffer buf
;;; (buf-read buf q n) read n elements for query q without deleting data
;;; 
;;; (buf-clean buf)  deletes data that all queries have already consumed
;;;                  used by BUF-MAN system box
;;; (buf-size-for-cursor buf c) number of elements for cursor
;;;                  used in monitoring and collecting stat
;;; (add-buf-cursor buf c) when query c opens a stream, add cursor to the 
;;;                  stream buffer 
;;; (delete-buf-cursor buf c) delete cursor when query c closes the stream 
;;;
;;; PRIVATE functions: 
;;; (buf-get buf) get data element from the beginning of buffer buf, not used
;;; (buf-size buf) calculates the real number of elements 
;;; (buf-grow buf) increase the size of buffer heap with grow-factor elements  
;;; (buf-empty-p buf) predicate function is true if buffer is empty
;;; (buf-print buf) print slots of the buf structure for debugging 
;;; =============================================================

(defglobal _max-buf-size_ 5000) ;; maximum size of buffers
(defglobal _max-buf-util_ 0.9) ;; threshold for buffer overflow 
(defglobal _buf-overflow_ nil) ;; flag for buffer overflow 

; A queue structure
(defstruct buf
  head ; first element
  tail ; first free location for a newly arriving element
  heap ; contains the elements of the queue, adj. array
  overflow ; true if the buffer is full
  grow-factor ; factor to grow the heap size
  cursors ; associative list of query id-s and 
            ;;their corresponding pointers to the heap
  dropcnt  ;; number of dropped data
  cyclic ;; flag for cyclic buffer to not be cleaned
)

(defun buf-init (sz &optional gf)
"Create a new buf structure with initial size of the heap sz"
(let (bgf)
  (if (> sz _max-buf-size_) (print "Increase _max-buf-size_ param"))
  (setq bgf (if gf gf (floor (* _max-buf-size_ 0.1))))
  ;; grow with 10% of _max-buf-size_
  ;; To Do initial size param?
  (make-buf :head 0 :tail 0 :heap (make-array sz :adjustable t) 
	    :overflow nil :grow-factor bgf :dropcnt 0)
))

(defun buf-put (bf data)
"Put data as a single element at the end of buffer bf"
  (progn 
    (if (buf-overflow bf) (buf-overflow-man bf))
    ;;call buf-overflow-man to increase the buffer heap size and clean
    
    (if (buf-overflow bf) ;; buffer has max size - drop new data
	(setf (buf-dropcnt bf) (1+ (buf-dropcnt bf)))
      ;; otherwise put data
      (let ((hp (buf-heap bf))
	    (tl (buf-tail bf)))
	
	(seta hp tl data)
	(setf (buf-tail bf) 
	      (mod (1+ tl) (array-total-size hp))) 
	;; check for overflow
	(if (equal (buf-tail bf) (buf-head bf))
	    (let () (setf (buf-overflow bf) t)
		  (if (null (buf-cyclic bf)) (buf-overflow-man bf)))
	))
 )))

(defun buf-get (bf)
(prog-let ((hp (buf-heap bf))
	   (head (buf-head bf)) data)
;; check for underflow
(if (buf-empty-p bf)
(return nil)) ;;empty queue
   (setq data (aref hp head))
   (seta hp head nil) ;;eventually nil
      (setf (buf-head bf) 
	    (mod (1+ head) (array-total-size hp)))
(if (buf-overflow bf) (setf (buf-overflow bf) nil)) 
(return data)
))

(defun buf-empty-p (bf)
(and (equal (buf-head bf) (buf-tail bf))
(not (buf-overflow bf)))) 

(defun buf-print (bf)
  (formatl t "Buffer: " t)
  (formatl t "head " )
  (print (buf-head bf))
  (formatl t "tail " )
  (print (buf-tail bf))
  (formatl t "heap " t )
  (dotimes (i (array-total-size (buf-heap bf)))
    (print (aref (buf-heap bf) i)) )
  (formatl t "overflow " )
  (print (buf-overflow bf))
  (formatl t "grow factor " )
  (print (buf-grow-factor bf))
)



(defun buf-size (bf)
"Number of elements in the buffer"
(prog-let ((sz (- (buf-tail bf) (buf-head bf))))
(if (or (< sz 0) (and (equal sz 0)(buf-overflow bf)))
(setq sz (+ sz (array-total-size (buf-heap bf)))))
(return sz)
))

(defun buf-grow (bf)
  "If needed adjusts the size of the heap according 
   to its grow-factor."
  (let* ((heap (buf-heap bf)) newcl
	 (old-size (array-total-size heap))
	 (new-size  (+ old-size (buf-grow-factor bf))))
    (if (<= _max-buf-size_ old-size) (print "Buffer at max size")
      (let ()
	(setq new-size (min new-size _max-buf-size_))
	(adjust-array heap new-size)
	;;move the elements from the tail part
	(dotimes (i (buf-tail bf))
	  (seta heap (mod (+ i old-size) new-size) (aref heap i))
	  (seta heap i nil))
	;; Move cursors
	(dolist (c (buf-cursors bf))
	  (setq newcl (putassoc (car c) 
			(if (< (cdr c) (buf-head bf)) 
			    (mod (+ (cdr c) old-size) new-size)
			  (cdr c))
		 newcl)))

	(setf (buf-cursors bf) newcl)
	(setf (buf-tail bf) (mod (+ (buf-tail bf) old-size) new-size))
	(setf (buf-overflow bf) nil)))
))

(defun buf-heap-size (bf)
(array-total-size (buf-heap bf)))

(defun expand-pos (p bf)
  (if (< p (buf-head bf)) 
      (+ p (buf-heap-size bf))
    p))

(defun putassoc (key val l)
  "Add/update (key . value) to the associative list l"
  (let (al)
    (setq al (remove (assoc key l) l))
    (setq al (nconc1 al (cons key val)))
    ))
;; help function
(defun mymin (l)
"Minimum element among list of elements"
  (cond ((null l) nil)
	((eq 1 (length l)) (car l))
	(t (let ((m (car l)))
	     (dolist (el (cdr l))
	       (setq m (min m el))
	       )
	     m))
))

(defun buf-size-for-cursor (bf q)
"Check how many elements in the buffer bf are not read by the cursor q"
(let* ((p (cdr (assoc q (buf-cursors bf)))) ;;pointer for the cursor
       (pq (expand-pos p bf)) ptail)

  (if (buf-cyclic bf) 
      (buf-heap-size bf) 
   ; (- (expand-pos (buf-tail bf) bf) pq))
    (let ()
      (if (and (equal (buf-tail bf) (buf-head bf)) (buf-overflow bf)
	       (not (equal (buf-tail bf) p)))
      (setq ptail (+ (buf-heap-size bf) (buf-tail bf)))
      (setq ptail (expand-pos (buf-tail bf) bf)))
    (- ptail pq)))
  ))

(defun buf-size-for-curso-org (bf q)
"Check how many elements in the buffer bf are not read by the cursor q"
(let* ((p (cdr (assoc q (buf-cursors bf)))) ;;pointer for the cursor
       (pq (expand-pos p bf)) ptail)

  (if (and (equal (buf-tail bf) (buf-head bf)) (buf-overflow bf))
      (setq ptail (+ (buf-heap-size bf) (buf-tail bf)))
      (setq ptail (expand-pos (buf-tail bf) bf)))
    (- ptail pq))
)

(defun buf-read (bf q n) 
"Read n elements in list from the buffer bf starting from pointer for query q(qid). If there are not enough data return nil"
(let (resl (p (cdr (assoc q (buf-cursors bf))))
	   (bs (buf-size-for-cursor bf q)))
  
  (if (<= n bs)
      ;; enough elements
	 (dotimes (i n) 
	   (setq resl (append2 resl (list (aref (buf-heap bf) 
					(mod (+ i p)(buf-heap-size bf))))))
  ))
  ;; update pointer for the query q
  (if resl (setf (buf-cursors bf)
		 (putassoc q (mod (+ p n) (buf-heap-size bf))
			   (buf-cursors bf))))
  resl
))

(defun buf-clean (bf)
  "Deletes data that all queries have already consumed"
  (let ((plist (mapcar 'cdr (buf-cursors bf))) ;;list of cur. pointers
	p  ;;the oldest not consumed position
	cleancnt) ;; number of cleaned positions as indicator for overflow->nil
    (if (null (buf-cyclic bf))
	(let ()
	  (setq p 
		(cond ((null plist) (buf-head bf))
		      ((< 1 (length plist))
		       (mymin (mapcar (f/l (x) (expand-pos x bf)) 
				      plist)))
		      (t (expand-pos (car plist) bf))))
	  (setq cleancnt (- p (buf-head bf)))
	  (if (> cleancnt 0)
	      (let ()
		(dotimes (i cleancnt)
		  (seta (buf-heap bf) 
			(mod (+ i (buf-head bf)) (buf-heap-size bf)) nil))
		(setf (buf-head bf) (mod p (buf-heap-size bf)))
		(setf (buf-overflow bf) nil)))
	  (buf-analyse bf)))
))

(defun buf-analyse (bf)
"If the buffer is full 70 % of max capacity - set a flag to trigger adaptation"
(if (> (buf-size bf) (floor (* 0.7 _max-buf-size_))
       (setq _buf-overflow_ t)))
)

(defun buf-overflow-man (bf)
"Called when buffer overflow occurs to increase the buffer heap size and clean"
(let ()
  ;; expand the heap until _buf-max-size_ not reached
  (buf-grow bf)
  (if (buf-overflow bf) (buf-clean bf)) 
    ;; if buffer can not grow more - clean old consumed data in advance
  
))

(defun buf-print-short (bf)
  (prog-let ((bs (buf-size bf)))
    (formatl t "Head " (buf-head bf) " Tail " (buf-tail bf) t)
    (setq bs (min bs 10))
    (dotimes (i bs)
      (print (aref (buf-heap bf)
		   (mod (+ i (buf-head bf))(buf-heap-size bf)))))
  )
)

(defun add-buf-cursor (bf q)
"Add new query cursor of data in the buffer."
  (setf (buf-cursors bf)
	(putassoc q (buf-head bf) (buf-cursors bf))))


(defun delete-buf-cursor (bf q)
"Delete a query cursor of data in the buffer."
  (let ()
    (buf-clean bf) ;; first clean the buffer from data consumed by this query
    (setf (buf-cursors bf)
	  (remove (assoc q (buf-cursors bf)) (buf-cursors bf)))))