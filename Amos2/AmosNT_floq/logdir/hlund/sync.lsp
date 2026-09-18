;; work in progress

(defmacro do-vector (eia &rest body)
  (let ((element (first eia))
	(index (second eia))
	(array (third eia))
	(avar (gensym)))
    `(let ((,avar ,array))
       (dotimes (,index (length ,avar))
	 (let ((,element (aref ,avar ,index)))
	   ,@body)))))

(defun ml:maparray (fn array)
  (let ((res (make-array (array-total-size array))))
    (dotimes (i (array-total-size array) res)
      (seta res i (funcall fn (aref array i))))))

(defun mapvector-args---+ (fno fn v args)
  (let ((argl (arraytolist args)))
    (osql-result fn v args 
		 (ml:maparray #'(lambda (x)
				  (ml:callfn1* fn (cons x argl)))
			      v))))

(defun pq-push* (pq key data)
  "Insert a new element in a priority queue. Complexity: O(log2(N)). 
   If 'key' was already inserted, then data is added to it's 'data' field." 
  (assert (and pq key))
  (let* ((i (1+ (pq-size pq)))
	 (heap (pq-heap pq))
	 (pred (pq-key-pred-fn pq))
	 parent)
    ; find a place for the node starting from the last node, 
    ; and swap elements on the way
    (while (and (> i 1)
		(setq parent (elt1 heap (pq-parent i)))
		(funcall pred key (pq-node-key parent))
		(not (equal key (pq-node-key parent))))
      (set1 heap i parent)
      (setq i (pq-parent i)))
    ; add the node to the heap
    (cond ((and parent (equal key (pq-node-key parent)))
	   (attach data (pq-node-data parent)))
	  (t (incf (pq-size pq))
	     (pq-grow pq)
	     (set1 heap i (make-pq-node :key key :data (list data)))))
    pq))

(defun pq-pop-all (pq &optional what)
  "Pop all the elements off the priority queue. 
   Complexity: O(N log2(N))"
  (assert pq)
  (let ((access-fn (get-access-fn what))
	(result (tconc nil)))
    (while (pq-peek pq)
      (tconc result (funcall access-fn (pq-pop pq))))
    (car result)))

(defun stream-union-old (svec kfn ofn combfn emitter)
  (let ((scans (arraytolist (ml:maparray #'open-bag-scan svec)))
	(values (pq-make :key-pred (lambda-amosfn ofn e1 e2)))
	min-ts)
    (when (and combfn (every #'(lambda (s) (not (scan-eos s))) scans))
      (let ((buf (mapcar #'(lambda (s) (car (scan-peek s))) scans)))
	(getfunction combfn (list (listtoarray buf)))))
    (while (some #'(lambda (s) (not (scan-eos s))) scans)
      (let (buf) 
	(dolist (s scans)
	  (unless (scan-eos s) 
	    (push (car (scan-nextrow s)) buf)))
	(setf min-ts (maxl (mapcar #'(lambda (e)
				       (pq-push* values (ml:callfn1 kfn e) e)
				       (ml:callfn1 kfn e))
				   buf) (lambda-amosfn ofn e1 e2))))
      (while (and (not (pq-empty-p values)) 
		  (funcall (lambda-amosfn ofn x y) 
			   (pq-node-key (pq-peek values)) min-ts))
	(mapc #'(lambda (x)
		  (funcall emitter x))
	      (pq-pop values 'data))))
    (unless (pq-empty-p values)
      (mapc #'(lambda (x)
		(funcall emitter x))
	    (pq-pop-all values 'data)))))

(defun stream-union----+ (fno svec kfn ofn combfn)
  (stream-union svec kfn ofn combfn
		#'(lambda (x)
		    (if (listp x)
			(mapc #'(lambda (y)
				  (osql-result svec kfn ofn combfn y))
			      x)
			(osql-result svec kfn ofn combfn x)))))

(defun stream-union---+ (fno svec kfn ofn)
  (stream-union svec kfn ofn nil
		#'(lambda (x)
		    (if (listp x)
			(mapc #'(lambda (y)
				  (osql-result svec kfn ofn y))
			      x)
			(osql-result svec kfn ofn x)))))


;; scans w/ timeout test

(defun make-buffers (n)
  (ml:maparray #'(lambda (x)
		   (tconc nil))
	       (make-array n)))

(defun get-buffer-fronts (bufs)
  (arraytolist (ml:maparray #'caar bufs)))

(defun pop-buffer-fronts (bufs)
  (let ((res (make-array (array-total-size bufs))))
    (do-vector (b i bufs)
      (if (eq (caar b) 'done)
	  (seta res i 'done)
	  (seta res i (pop (car b))))
      (unless (caar b)
	(seta bufs i (tconc nil))))
    (arraytolist res)))

(defun drain-buffers (bufs)
  (let (res)
    (ml:maparray #'(lambda (b)
		     (while (and (caar b) (neq (caar b) 'done))
		       (push (pop (car b)) res)))
		 bufs)
    res))

(defun stream-union (svec kfn ofn combfn emitter)
  "SVEC is input vector of streams. 
   KFN is amos function selecting the time stamp in all SVECS.
   OFN is boolean amos function testing if two time stamps are in order.
   Procedural init function COMBFN(vector of Object inp)-> Boolean 
     applied only on first on vector of input tuples. 
     E.g. computes skew and stores in log directory as side effect. 
   The a temporal union is made o0n the key. The skew will be accessed
   in the key function KFN"
  (let ((scans (ml:maparray #'(lambda (s)
				(open-bag-scan s '(:timeout 0.1))) svec))
	(values (pq-make :key-pred (lambda-amosfn ofn e1 e2)))
	min-ts)
    ;;(formatl t "scans: " scans t)
    (when (and combfn (everya scans #'(lambda (s) (not (scan-eos s)))))
      (let ((buf (ml:maparray #'(lambda (s) 
				  (car (scan-peek s))) scans)))
	(while (somea buf #'null)
	  (do-vector (s i scans)
		     (when (car (scan-peek s))
		       (seta buf i (car (scan-peek s))))))
	;;(formatl t "peeks: " buf t)
	(getfunction combfn (list buf))))
    (let ((buf (make-buffers (array-total-size scans)))) 
      (while (somea scans #'(lambda (s) (not (scan-eos s))))
	(do-vector (s i scans)
		   (unless (scan-eos s)
		     (let ((val (car (scan-nextrow s))))
		       (when val
			 (tconc (aref buf i) val)
			 (when (scan-eos s)
			   (tconc (aref buf i) 'done)
			   (scan-close s))))))
	(let ((fronts (get-buffer-fronts buf)))
	  (unless (some #'null fronts)
	    (setf fronts (remove 'done (pop-buffer-fronts buf)))
	    (setf min-ts (maxl (mapcar #'(lambda (e)
					   (pq-push* values (ml:callfn1 kfn e)
						     e)
					   (ml:callfn1 kfn e))
				       fronts)
			       (lambda-amosfn ofn e1 e2)))
	    ;;(formatl t "min-ts: " min-ts t)
            ))
	(while (and (not (pq-empty-p values)) 
		    (funcall (lambda-amosfn ofn x y) (pq-node-key 
						      (pq-peek values)) 
			     min-ts))
	  (mapc #'(lambda (x)
		    (funcall emitter x))
		(pq-pop values 'data))))
      (dolist (e (drain-buffers buf))
	(pq-push* values (ml:callfn1 kfn e) e)))
    (unless (pq-empty-p values)
      (mapc #'(lambda (x)
		(funcall emitter x))
	    (pq-pop-all values 'data)))))
