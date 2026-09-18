(set-resulttypesfn
 (osql "create function righthjoin(Bag x, Bag y)-> Bag 
   as foreign 'righthjoin';")
 'transparent-bag-resulttypes)

(defun righthjoin (fno x y &rest r)
  (let ((ht (make-hash-table :test (function equal))))
    (mapbag x #'(lambda (row) (setf (gethash (first row) ht) (cdr row)))) 
    (mapbag y #'(lambda (row) 
		  (let ((r0 (gethash (first row) ht)))
		    (if r0
			(apply (function osql-result)
			       (list* x y row))))))))
  