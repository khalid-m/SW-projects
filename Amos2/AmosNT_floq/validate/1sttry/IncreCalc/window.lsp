
;;;;;;;;;;;;;;;;;;;;;;;;;new type WINDOW;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create a new type WINDOW in Amos II
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(createliteraltype 'window (list _collection_) 'swin)

(defun emptyw-p (w)
  "check if a given window is empty"
  (and (null (get-headl w))
       (null (get-taill w))))

(defun emptyh-p (w)
  "check if a given window's headl is empty"
  (null (get-headl w)))

(defun emptyt-p (w)
  "check if a given window's taill is empty"
  (null (get-taill w)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create 1 second tumbling window
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun window-add-t (w eleml)
  (cond ((emptyh-p w)
	 (set-headl w eleml)
	 (set-taill w eleml))
	(t
	 (rplacd (get-taill w) eleml)
	 (set-taill w eleml)))
  (inc-sizec w 1)
  w)

;;forming the 1-second tumbling window
(foreign-lispfn windowagg_t ((Bag svec) (Integer pos)) ((Window))
	(let* ((tvec -1) (hs (make-hash-table :test (Function equal)))
	      (window (make-swin 0 -1 hs)))
	  (mapbag svec
		  (f/l (vec)
		       (let ((vec (car vec)))
			 (cond ((not (= tvec (elt vec pos)))
				(set-incre window hs)
				(if (T>= tvec 0) (foreign-result window))
				(setq tvec (elt vec pos))
				(setq hs (make-hash-table :test (Function equal)))
				(if (= (elt vec 3) 0)
				    (setf (gethash
					   (vector (elt vec 2) (elt vec 4);  2: vid  4: xway
						   (elt vec 5) (elt vec 6);  5: lane 6: dir
						   (elt vec 7) (elt vec 8)); 7: seg  8: pos
					   hs) 1))
				(setq window (window-add-t (make-swin 0 tvec hs) (list vec))))
			       (t
				;; if previously stored
				(if (= (elt vec 3) 0)
				    (let ((frv (vector (elt vec 2) (elt vec 4)
						       (elt vec 5) (elt vec 6)
						       (elt vec 7) (elt vec 8))))
				      (cond ((gethash frv hs)
					     (setf (gethash frv hs)
						   (1+ (gethash frv hs))))
					    (t
					     (setf (gethash frv hs) 1)))))
				(setq window (window-add-t window (list vec))))))))
	(set-incre window hs)
	(foreign-result window)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;count window;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smart function taking care of adding and emitting new counting windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; vec-compare is used to compare if two vectors have
; exact the same value based on the positions
; example: (vec-compare #(1 2 3) #(0 2 3) #(1 2)) => T
; (vec-compare #(1 2 3) #(0 2 3) #(0 1 2)) => NIL
; possibly used for new groupby?
; not used now
(defun vec-compare (vec1 vec2 vecpos)
  (let ((res t))
    (maparray vecpos
	      (f/l (pos i)
		   (setq res (and res (= (elt vec1 pos) (elt vec2 pos))))))
    res))

;; operator for adding
(defun incre-add-c (whs subhs)
  (maphash (f/l (key value)
		(cond ((gethash key whs)
		       (setf (gethash key whs)
			     (+ (gethash key whs) value)))
		      (t
		       (setf (gethash key whs) value))))
	   subhs)
  whs)

;; operator for removing
(defun incre-remove-c (whs subhs)
  (maphash (f/l (key value)
		(cond ((gethash key whs)
		       (setf (gethash key whs)
			     (- (gethash key whs) value)))
		      (t
		       (setf (gethash key whs) (- value)))))  ;; should be error message here
	   subhs)
  whs)

;; home-made hash table copy
(defun copy-hash (hs)
  (let ((chs (make-hash-table :test (Function equal))))
    (maphash (f/l (key value)
		  (setf (gethash key chs) value))
	     hs)
    chs))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal 1stwindow T
  "creating counting windows for the first time")

(defun set-first-time ()
  (setq 1stwindow T))

(defun window-add-c (w size slide eleml)
  (let (sizec nw)
    (cond ((emptyh-p w)
	   (set-headl w eleml)
	   (set-taill w eleml))
	  (t
	   (rplacd (get-taill w) eleml)
	   (set-taill w eleml)))
    (cond (1stwindow
	   (incre-add-c (car deltahtl) (get-incre (car eleml))))
	  (t
	   (maphash (f/l (key value)
			 (add-delta key value deltahtl))
		    (get-incre (car eleml)))))
    (set-timec w (get-timec (car eleml)))
    (inc-sizec w 1)
    (setq sizec (get-sizec w))
    (cond ((= sizec size)
	   (cond ((and (zerop (hash-table-count (car deltahtl)))
		       (null 1stwindow))
		  (setq nw (make-swin size (get-timec w) (cdr deltahtl) (get-headl w) (get-taill w))))
		 (t
		  (setq nw (make-swin size (get-timec w) deltahtl (get-headl w) (get-taill w)))
		  (setq deltahtl (cons (make-hash-table :test 'equal) deltahtl))
		  (setq 1stwindow nil)))
	   (let ((hdl (get-headl w)))
	     (dotimes (i slide)
	       (maphash (f/l (key value)
			     (remove-delta key value deltahtl))
			(get-incre (car hdl)))
	       (setq hdl (cdr hdl)))
	     (set-headl w hdl))
	   (inc-sizec w (- slide))))
    nw))

;; windowagg_c(Stream sw, Integer size, Integer slide) -> Bag of Window
(foreign-lispfn windowagg_c ((Bag sw) (Integer size) (Integer slide)) ((Window))
	(let (ew (bw (make-swin 0 -1 (make-hash-table :test (Function equal)))))
	  (set-first-time)
	  (clear-delta)
	  (mapbag sw
		  (f/l (w)
		       (setq ew (window-add-c bw size slide w))
		       (cond (ew (foreign-result ew)))))
	  (if (< (- size slide) (get-sizec bw)) (foreign-result bw))))

;;; 
;;; Tuple window
;;; 
(defun window-add-tuple (w size slide el)
  "Add element [elml] to window [w] and return nil. If the window size [size] is exceded, a new window is created where the oldest [slide] elements from the old window have been dropped. In this case the new window is returned."
  (let (sizec nw)
    (cond ((emptyh-p w)
	   (set-headl w el)
	   (set-taill w el))
	  (t
	   (rplacd (get-taill w) el)
	   (set-taill w el)))
    (inc-sizec w 1)
    (setq sizec (get-sizec w))
    (cond ((= sizec size)
	   (setq nw (make-swin size (get-timec w) (copy-hash (get-incre w)) (get-headl w) (get-taill w)))
	   (let ((hdl (get-headl w)))
	     (dotimes (i slide)
	       (setq hdl (cdr hdl)))
	     (set-headl w hdl))
	   (inc-sizec w (- slide))))
    nw))

(foreign-lispfn windowagg_tuple ((Stream stream) (Integer size) (Integer slide)) ((Window))
  "Apply a tuple window of size [size] and with slide [slide] on stream [stream]."              
  (let* (neww
         (basew (make-swin 0 -1 (make-hash-table :test (Function equal)))))
    (mapbag stream
            (f/l (v)
                 (setq neww (window-add-tuple basew size slide v))
                 (cond (neww (foreign-result neww)))))))

;;; 
;;; Time window
;;; 
(defun window-add-time (w el)
  "Add element [el] to window [w]."
  (rplacd (get-taill w) el)
  (set-taill w el)
  (inc-sizec w 1))

(defun window-slide-time (w ts_idx)
  "Slide window [w] forward to its current starting timestamp [w_start_ts], removing all window elements with timestamps smaller than {w_start_ts}. The vector index [ts_idx] specifies the index of the timestamp cell of each window element." 
  (let 
      (head_ts
       (head (get-headl w)) 
       (w_start_ts (get-timec w)))
    (loop
     (setq head_ts (elt (car head) ts_idx))
     (when (<= w_start_ts head_ts) 
       (set-headl w head)
       (return))
     (inc-sizec w -1)
     (setq head (cdr head)))))

(foreign-lispfn windowagg_time ((Stream stream) (Integer size) (Integer slide) (Integer ts_idx)) ((Window))
  "Apply a time window of [size] seconds and with a slide of [slide] seconds on stream [stream]."     
  (let ((w (make-swin 0 -1 (make-hash-table :test (Function equal)))))
    (mapbag stream
            (f/l (el)
                 (let*
                     ((ts (elt (car el) ts_idx)))
                   (if (emptyh-p w) 
                       (progn
                         (set-headl w el)
                         (set-taill w el)
                         (set-timec w ts))
                     (let*                       
                         ((w_head_ts (get-timec w)) 
                          (time_span (- ts w_head_ts))) 
                       (if (> time_span size)
                           (progn 
                             (foreign-result w) ; emitt window
                             ;; copy old window and add new el 
                             (setq w (make-swin ts ts (copy-hash (get-incre w)) 
                                                (get-headl w) (get-taill w)))
                             (window-add-time w el)
                             ;; slide the window by incrementing its starting timestamp
                             (set-timec w (+ w_head_ts slide))
                             ;; drop old els from new window
                             (window-slide-time w ts_idx))
                         ;; add new el to old window
                         (window-add-time w el)))))))))
              

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; infinite window
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun window-add-inf (w eleml)
  (let (nw)
    (cond ((emptyh-p w)
	   (set-headl w eleml)
	   (set-taill w eleml))
	  (t
	   (rplacd (get-taill w) eleml)
	   (set-taill w eleml)))
    (inc-sizec w 1)
    (setq nw (make-swin (get-sizec w) (get-timec w) (make-hash-table :test 'equal) (get-headl w) (get-taill w)))
    nw))

(foreign-lispfn windowagg_inf ((Stream sv)) ((Window))
		(let ((bw (make-swin 0 -1)))
		  (mapbag sv
			  (f/l (ve)
			       (foreign-result (window-add-inf bw ve))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get incrementally calculated hashtable
(foreign-lispfn get_incre ((Window w)) ((Vector) (Integer))
		(let ((resht (make-hash-table :test 'equal)))
		  (mapc (f/l (ht) (map-deltahash resht ht)) (get-incre w))
		  (maphash (f/l (key value)
				(foreign-result key value))
			   resht)))
			   

;; get the time stamp of the window
(foreign-lispfn get_timec ((Window w)) ((Integer))
		(foreign-result (get-timec w)))


;; debugging use
(foreign-lispfn get_winfo ((Window w)) ((Integer) (Integer) (Integer) (Integer))
		(foreign-result (get-sizec w) (get-timec w) 
				(get-timec (car (get-headl w)))
				(get-timec (car (get-taill w)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; accident detection in lisp(???)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;V_GROUPBY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; do a groupby over a bag of vector based on a vector of positions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; get a fragment of the vector
;; TODO: bundary check
(defun vfrag (vec vpos)
  (let* ((rl (length vpos))
	(res (make-array rl)))
    (maparray vpos
	      (f/l (value index)
		   (seta res index (elt vec value))))
    res))

;; v_groupby:
;; bv: bag of vectors, vpos: vector of positions to be grouped
;; vpos: position of the group value
;; filter: acts like "having" in sql
;; not used
(foreign-lispfn v_groupby ((Bag bv) (Vector kposs) (Integer vpos) (Function grouper) (Function filter)) ((Object key) (Object value))
		(let ((hs (make-hash-table :test (Function equal))))
		  (mapbag bv
			  (f/l (v)
			       (let ((key (vfrag (car v) kposs))
				     (value (elt (car v) vpos)))
				 (cond ((callfunction filter (list value))
					(setf (gethash key hs)
					      (cons value (gethash key hs))))))))
		  (maphash (f/l (key value)
				(mapfunction grouper (list (bagify value))
					     (f/l (rs)
						  (foreign-result key (car rs)))))
			   hs)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QUEUE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; a list implementation of FIFO queue
;; which is used for keeping the headers of the windows
;; "windows should be closed in the order they created"
;; obsolete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(defun make-queue ()
;  "to void bundary check the empty queue hold an aditional cell"
;  (let ((q (list nil)))
;    (cons q q)))

;(defun empty-queue-p (q)
;  (null (cdar q)))

;(defun peak-queue (q)
;  (cadar q))

;(defun push-queue (q elem)
;  (setf (cdr q) (setf (cddr q) (list elem))))

;(defun pop-queue (q)
;  (car (setf (car q) (cdar q))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(defglobal _fno_ (getfunctionnamed 'stream.integer.integer.windowagg_a->window))

;(defun tester4 (s size slide)
;  (mapfunction _fno_ (list s size slide) (function null)))

;(osql "count(windowagg_a(streamof(readfile(\"data/cdp_mid15.out\")), 40000, 1));")

;count(windowagg_a(streamof(readfile("../../lr/data/cardatapoints10.out")), 2000, 1));

;count(winagg(readfile("../../lr/data/cardatapoints10.out"), 20000, 1));

;(osql "count(windowagg(streamof(readfile(\"data/cdp_mid15.out\")), 40000, 1));")

;(osql "count(winagg(readfile(\"data/cdp_mid15.out\"), 20000, 1));")