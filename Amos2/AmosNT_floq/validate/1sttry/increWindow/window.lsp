
;;;;;;;;;;;;;;;;;;;;;;;;;new type WINDOW;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create a new type WINDOW in Amos II
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(createliteraltype 'window (list _collection_) 'swin)

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

;; retrieving from the window
;(foreign-lispfn inwindow ((Window win)) ((Object))
;	(let* ((hl (get-headl win))
;	      (sizec (get-sizec win)) (temp hl))
;	  (do ((i 0 (1+ i)))
;	      ((= i sizec))
;	    (foreign-result (car temp))
;	    (setq temp (cdr temp)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;count window;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; smart function taking care of adding and emitting new counting windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun window-add-c (w size slide eleml)
  (let (sizec nw)
    (cond ((emptyh-p w)
	   (set-headl w eleml)
	   (set-taill w eleml))
	  (t
	   (rplacd (get-taill w) eleml)
	   (set-taill w eleml)))
    (inc-sizec w 1)
    (setq sizec (get-sizec w))
    (cond ((= sizec size)
	   (setq nw (make-swin size -1 (make-hash-table :test 'equal) (get-headl w) (get-taill w)))
	   (set-headl w (nthcdr slide (get-headl w)))
	   (inc-sizec w (- slide))))
    nw))

;; windowagg_c(Stream sw, Integer size, Integer slide) -> Bag of Window
(foreign-lispfn windowagg_c ((Bag sw) (Integer size) (Integer slide)) ((Window))
	(let (ew (bw (make-swin 0 -1)))
	  (mapbag sw
		  (f/l (w)
		     (setq ew (window-add-c bw size slide w))
		     (cond (ew (foreign-result ew)))))
	  (if (< (- size slide) (get-sizec bw))
	      (foreign-result (make-swin (get-sizec bw) -1 (make-hash-table :test 'equal)
					 (get-headl bw) (get-taill bw))))))
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
	(let ((tvec -1) (window (make-swin 0 -1)))
	  (mapbag svec
		  (f/l (vec)
		       (cond ((not (= tvec (elt (car vec) pos)))
			      (if (T>= tvec 0) (foreign-result window))
			      (setq tvec (elt (car vec) pos))
			      (setq window (window-add-t (make-swin 0 -1) vec)))
			     (t
			      (setq window (window-add-t window vec))))))
	  (foreign-result window)))

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