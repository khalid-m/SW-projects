(defun sample--+ (fno b s r)
  (let ((res (make-array s))
	(res-size 0) (count 0))
    (mapbag b (f/l (row) 
		   (1++ count)
		   (if (< res-size s)  ; put all input into RES array until it's full
		       (progn
			 (setf (aref res res-size) row)
			 (1++ res-size))
		     (let ((i (random count)))
		       (when (< i s) ; replace a random element in RES with probability = size/count
			 (setf (aref res i) row))))))
    (dotimes (i res-size) (osql-result b s (car (aref res i)))))) ; return entries in RES array
			 
(osql "create function sample(Bag b, Integer s) -> Bag as foreign 'sample--+';")

(defun sample-resulttypes (fno args)
  (let ((argtype (arg-type (car args))))
    (if argtype 
	(type-parameters argtype)
      (list (gettypenamed 'object)))))

(set-resulttypesfn (theresolvent 'sample) 'sample-resulttypes)
