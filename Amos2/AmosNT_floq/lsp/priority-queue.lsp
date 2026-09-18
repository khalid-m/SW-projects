;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Timour Katchaounov, UDBL
;;; $RCSfile: priority-queue.lsp,v $
;;; $Revision: 1.3 $ $Date: 2000/12/13 13:28:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:
;;; This file contains two implementations of priority queues (PQs):
;;; 1.
;;; A PQ implemented according to 'Introdunction to Algorithms',
;;; T. Cormen, C. Leiserson, R. Rivest, MIT Press.
;;; The underlying structure is a heap stored in an adjustable array.
;;; All interesting operations are O(lg N).
;;; Allows duplicate keys in the priority queue.
;;; Indended to be used as storage for dynamic programming algorithms.
;;; 2.
;;; A simpler list-based implementation, which performs equally well
;;; for small number of keys, but has worse complexity:
;;; O(1) - to pop the top element, O(N) - to push a new element
;;;
;;; Interface functions (same interface for both implementations, where the
;;; heap-based PQ functions have prefix 'pq', and the list-based - 'pql'):
;;; - pq-make - crate a new PQ
;;; - pq-push - add a new element to a PQ
;;; - pq-pop - get the top element of a PQ and remove it from the PQ
;;; - pq-peek - see what is on the top of the PQ, no changes are made
;;; - pq-pop-all - pop all elements from a PQ
;;; - pq-empty-p - check if a PQ is empty
;;; ===========================================================================


; Interface macros for the dynamic programming algorithms in AMOS

; plan table macros built on top of the HEAP-based priority queue
;(quote
(defmacro maketbl (&optional stat-fn)
  `(pq-make :key-pred '< :stat-fn , stat-fn))
(defmacro puttbl (tbl cost plan)
  `(pq-push , tbl , cost , plan))
(defmacro get-lowest-cost (tbl)
  `(pq-node-key (pq-peek , tbl)))
(defmacro empty-tbl-p (tbl)
  `(pq-empty-p , tbl))
(defmacro pop-cheapest-plans (tbl)
  `(pq-pop , tbl 'data))
(defmacro print-tbl (tbl level)
  `(pq-print , tbl , level))
(defmacro tbl-stat (tbl depth)
  `(pq-stat , tbl , depth))
; interesting functions to profile
;(profile-functions pq-push pq-pop pq-heapify)
;)

; plan table macros built on top of the LIST-based priority queue
(quote
(defmacro maketbl ()
  '(pql-make))
(defmacro puttbl (tbl cost plan)
  (list 'pql-push tbl cost plan))
(defmacro get-lowest-cost (tbl)
  (list 'pq-node-key (list 'pql-peek tbl)))
(defmacro empty-tbl-p (tbl)
  (list 'pql-empty-p tbl))
(defmacro pop-cheapest-plans (tbl)
  (list 'pql-pop-front tbl ''data))
(defmacro print-tbl (tbl level)
  (list 'pql-print tbl level))

;(profile-functions pql-push pql-pop pql-find-key)
)


; A priority queue structure
(defstruct pq
  heap ; contains the elements of the queue
  size ; number of elements in the queue
  key-pred-fn  ; function to compare two node keys
  data-pred-fn ; function to compare two entries in the 'data' field of a node
  stat-fn ; function to extract statistics specific for the data to be stored
  grow-factor ; factor to grow the heap size
  key-ht ; a hash table mapping keys to indexes
)

; A node in a priority queue
(defstruct pq-node
  key   ; a value that is comparable with =, < >
  data  ; the data associated with the key
)

(defun pq-make (&rest args)
  "Create a new empty priority queue."
  (let* ((params (parsekeywordparams
		  args 
		  '(:key-pred :data-pred :init-size :grow-by :stat-fn)))
	 (key-pred (first params))
	 (data-pred (second params))
	 (init-size (third params))
	 (grow-by (fourth params))
	 (stat-fn (fifth params)))
    ; Adjust the starting init-size to be 16 by default
    (if (or (null init-size) (< 16 init-size))
	(setq init-size 16))
    (make-pq
     :heap (mkadjarray init-size)
     :size 0
     :key-pred-fn (if key-pred key-pred '<) ; default is smaller first
     :data-pred-fn data-pred
     :stat-fn stat-fn
     :grow-factor (if grow-by grow-by 32) ; TODO: how to convert reals to integers?
     :key-ht (make-hash-table :size 16 :test #'equal) ; 'equal need for float keys
     )))

(defun pq-empty-p (pq)
  "Check if the prioriry queue is empty."
  (assert pq)
  (= (pq-size pq) 0))

(defun pq-push (pq key data)
  "Insert a new element in a priority queue. Complexity: O(log2(N)).
   If 'key' was already inserted, then data is added to it's 'data' field."
  (assert (and pq key))
  (let* ((i (+ 1 (pq-size pq)))
	 (heap (pq-heap pq))
	 (pred (pq-key-pred-fn pq))
	 (eqfn (pq-data-pred-fn pq))
	 (kht  (pq-key-ht pq))
	 (existing-key-idx (gethash key kht))
	 parent)
    ; check if we already have a node with this key
    (cond (existing-key-idx ; there are elemts with this key
	   (let ((this-data (elt1 heap existing-key-idx)))
	     (if (or (null eqfn) (not (isome this-data eqfn)))
	         ; ATTACH or NCONC1 - changes order of the entries per key
		 (attach data (pq-node-data this-data))
	         ; this is VERY slow for dynprogsort! - 
	         ; order DOES matter to find the optimal plan!?
	         ;(nconc1 (pq-node-data this-data) data)
	       )))
	  (t ; find a place for the node starting from the last node, 
	     ; and swap elements on the way
	   (while (and (> i 1)
		       (setq parent (elt1 heap (pq-parent i)))
		       (funcall pred key (pq-node-key parent)))
	     (set1 heap i parent)
	     (puthash (pq-node-key parent) kht i)
	     (setq i (pq-parent i)))
	   (setf (pq-size pq) (1+ (pq-size pq)))
	   ; if needed make place for the new element
	   (pq-grow pq)
	   ; add the node to the heap
	   (set1 heap i (make-pq-node :key key :data (list data)))
	   ; update the keys hash table
	   (puthash key kht i)))
    pq))

(quote ;backup - version for PQs with duplicate keys
(defun pq-push (pq key data)
  "Insert a new element in a priority queue. Complexity: O(log2(N))"
  (assert (and pq key))
  (setf (pq-size pq) (+ 1 (pq-size pq)))
  (let* ((i (pq-size pq))
	 (heap (pq-heap pq))
	 (pred  (pq-key-pred-fn pq))
	 parent)
    ; if needed make place for the new element
    (pq-grow pq)
    ; find a place for the node starting from the last node, 
    ; and swap elements on the way
    (while (and (> i 1)
		(setq parent (elt1 heap (pq-parent i)))
		(funcall pred key (pq-node-key parent)))
      (set1 heap i parent)
      (setq i (pq-parent i)))
    (set1 heap i (make-pq-node :key key :data data))
    pq))
)

(defun pq-peek (pq)
  "Get the top element of the pqriority queue 'pq', without removing it."
  (assert pq)
  (if (> (pq-size pq) 0)
      (elt (pq-heap pq) 0)
      NIL))

(defun pq-pop (pq &optional what)
  "Get the top element of the priority queue 'pq', and remove it from 'pq'.
   If 'what' = 'key return only the key of the element;
   If 'what' = 'data' return only the data field of the top element.
   Complexity: O(log2(N))"
  (assert pq)
  (let* ((size (pq-size pq))
	 key-ht access-fn heap top-elem)
    (cond ((> size 0)
	   (setq key-ht (pq-key-ht pq))
	   (setq access-fn (get-access-fn what))
	   (setq heap (pq-heap pq))
	   (setq top-elem (elt1 heap 1))
	   (set1 heap 1 (elt1 heap size))
	   (setf (pq-size pq) (- size 1))
	   (pq-heapify pq 1)
	   ; remove the key from the key hash table
	   (remhash (pq-node-key top-elem) key-ht)
	   (funcall access-fn top-elem))
	  (t ; free some memory
	   (clrhash key-ht)
	   NIL))))

(quote ; version for PQ with duplicate keys
(defun pq-pop-front (pq &optional what)
  "Pop the first elements with key equal to the root."
  (assert pq)
  (if (= (pq-size pq) 0)
      NIL
      (let* ((first (pq-pop pq what))
	     (next (pq-peek pq))
	     result)

	(push first result)

	(while (and (neq first NIL) (neq next NIL)
		    (equal (pq-node-key first) (pq-node-key next)))
	  (setq first (pq-pop pq what))
	  (setq next (pq-peek pq))
	  (push first result))
	; note: result is in reverse order
	result)))
)

(defun pq-pop-all (pq &optional what)
  "Pop all the elements off the priority queue.
   Complexity: O(N log2(N))"
  (assert pq)
  (let ((access-fn (get-access-fn what))
	result)
    (while (pq-peek pq)
      (push (funcall access-fn (pq-pop pq)) result))
    (nreverse result)))

(defun pq-stat (pq &optional max-keys)
  "Return statistics about 'pq' of the form:
   (number-of-keys number-of-values (key num-of-values data-specific-stats) ...)
   where 'data-specific-stats' is added by a function specific for the elements
   in the 'data' field for each key. This function is given when the PQ is created.
   No more than the first 'max-keys' are appended to the result.
   Useful to check the distribution of values over the keys."
  (let ((num-keys (pq-size pq))
	(heap (pq-heap pq))
	(tot-num-values 0)
	(data-stat-fn (pq-stat-fn pq))
	res)
    (dotimes (i num-keys)
      (let* ((node (elt heap i))
	     (node-data (pq-node-data node))
	     (key (pq-node-key node))
	     (nvals (length node-data))
	     (stat (list key nvals)))
	(if data-stat-fn
	    (setq stat (append stat (funcall data-stat-fn node-data))))
	(setq tot-num-values (+ tot-num-values nvals))
	(setq res (nconc1 res stat))))
    (setq res (sort res (f/l (x y) (< (car x) (car y)))))
    ; truncate the list if needed
    (if (and max-keys (< max-keys num-keys))
	(rplacd (nthcdr (1- max-keys) res) NIL))
    (push tot-num-values res)
    (push num-keys res)
    res))


; implementation

(defmacro get-access-fn (what)
  `(case , what
     (NIL   #'id)
     ('key  #'pq-node-key)
     ('data #'pq-node-data)
     (otherwise (amos-error "No such element field: " what))))

(defmacro pq-parent (i)
  "Calculate the address of the parent of the i-th node."
  (list '/ i 2))

(defmacro pq-right (i)
  "Calculate the address of the right child of the i-th node."
  (list '1+ (list '* 2 i)))

(defmacro pq-left (i)
  "Calculate the address of the left child of the i-th node."
  (list '* 2 i))

(defun pq-heapify1 (pq i)
  "Helper function that puts the i-th element in the heap in place, and possibly
   reorders all elements below it. Complexity: O(log2(N))
   TODO: write an interative version."
  (assert pq)
  (let* ((heap (pq-heap pq))
	 (size (pq-size pq))
	 (pred  (pq-key-pred-fn pq))
	 (l (pq-left i))
	 (r (pq-right i))
	 largest
	 temp)
    ; determine the largest node
    (if (and (<= l size)
	     (funcall pred (pq-node-key (elt1 heap l)) (pq-node-key (elt1 heap i))))
	(setq largest l)
        (setq largest i))

    (if (and (<= r size)
	     (funcall pred (pq-node-key (elt1 heap r)) (pq-node-key (elt1 heap largest))))
	(setq largest r))

    ; swap the largest node and the i-th node
    (cond ((neq largest i)
	   (setq temp (elt1 heap largest))
	   (set1 heap largest (elt1 heap i))
	   (set1 heap i temp)
	   (pq-heapify pq largest)))
    pq))

(defun pq-heapify (pq i)
  "Helper function that puts the i-th element in the heap in place, and possibly
   reorders all elements below it. Complexity: O(log2(N))
   TODO: write an interative version."
  (assert pq)
  (let* ((heap (pq-heap pq))
	 (size (pq-size pq))
	 (pred (pq-key-pred-fn pq))
	 (l (pq-left i))
	 (r (pq-right i))
	 largest)
    ; determine the largest node
    (if (and (<= l size)
	     (funcall pred (pq-node-key (elt1 heap l)) (pq-node-key (elt1 heap i))))
	(setq largest l)
        (setq largest i))

    (if (and (<= r size)
	     (funcall pred (pq-node-key (elt1 heap r)) (pq-node-key (elt1 heap largest))))
	(setq largest r))

    ; swap the largest node and the i-th node
    (cond ((neq largest i)
	   (swap1 heap largest i)
	   (pq-heapify pq largest)))
    pq))

(defun pq-build-heap (pq)
  "Given a heap reorders all it's elements according to the heap property.
   The result is a 'proper' priority queue. Complexity: O(N)"
  (assert pq)
  (let* ((size (pq-size pq))
	 (i (/ size 2)))
    (while (> i 0)
      (pq-heapify pq i)
      (setq i (- i 1))))
  pq)

(defun pq-grow (pq)
  "If needed adjusts the size of the heap according 
   to its grow-factor."
  (assert pq)
  (let* ((used-size (pq-size pq))
	 (heap (pq-heap pq))
	 (total-size (array-total-size heap))
	 (diff (- total-size used-size)))
    (cond ((= diff 0)
	   (setq total-size (+ (pq-grow-factor pq) total-size))
	   (adjust-array heap total-size)
	   total-size))))

(defmacro elt1 (array index1)
  `(elt , array (1- , index1)))

(defmacro set1 (array index1 data)
  `(seta , array (1- , index1) , data))

(defmacro swap1 (array index1 index2)
  `(swap , array (1- , index1) (1- , index2)))

(defun pq-print (pq level)
  "Simple print, just for debugging."
  (cond ((< level 1)
	 (formatl t "heap size: " (pq-size pq) t)))
  (cond ((>= level 1)
	 (formatl t "heap: " t)
	 (dotimes (i (pq-size pq))
	   (formatl t (elt (pq-heap pq) i) " "))))
  (cond ((>= level 2)
	 (formatl t t "Key HT: " t)
	 (dump-hash-table (pq-key-ht pq)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Priority queue implemented with a list.
; The PQ has the form: (pq-node1 ... pq-nodeN), where every pq-node contains
; a list of entries for this key - same as in the heap-based implementation.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pql-make ()
  (list NIL))

(defun pql-empty-p (pql)
  (eq NIL (car pql)))

(defun qpl-size (pql)
  (length pql))

(defun pql-peek (pql)
  (first pql))

(defun pql-pop (pql &optional what)
  "Complexity: O(1)"
  (let* ((access-fn (get-access-fn what))
	 (res (funcall access-fn (first pql))))
    (rplaca pql (second pql))
    (rplacd pql (cddr pql))
    res))

(defun pql-pop-all (pql &optional what)
  (let (result elem)
    (while (pql-peek pql)
      (setq elem (pql-pop pql what))
      (if (not (listp elem))
	  (setq elem (list elem)))
      (setq result (append result elem)))
    result))

(defun pql-push (pq key data)
  "Complexity: O(N)
   'data' - the data to be added
   'pq' - a priority queue (sorted list)"
  (if (equal pq '(NIL))
      (rplaca pq (make-pq-node :key key :data (list data)))
      (let* ((rest (pql-find-key key pq)))
	(cond ((null rest) ; all nodes have smaller key
	       (nconc1 pq (make-pq-node :key key :data (list data))))
	      ((= (pq-node-key (car rest)) key) ; there is a node with the same key
	       ; changed NCONC1 to ATTACH
	       (attach data (pq-node-data (car rest)))) ; add the data
	      ((eq pq rest) ; all datas have bigger key, add to front
	       (attach (make-pq-node :key key :data (list data)) pq))
	      (t ; no nodes with this key, insert the data before 'rest', after 'prev'
	       (attach (make-pq-node :key key :data (list data)) rest)))
	pq)))

(defun pql-find-key (key pq)
  "Find the rest of table with bigger keys than 'key'.
   Complexity: O(N)"
  (let ((rest pq))
    (while (and (neq NIL rest) (< (pq-node-key (car rest)) key))
      (setq rest (cdr rest)))
    rest))

(defun pql-print (pql level)
  (cond ((< level 1)
	 (formatl t "list size: " (length pql) t)))
  (cond ((>= level 1)
	 (formatl t "list: " t)
	 (pps pql))))
