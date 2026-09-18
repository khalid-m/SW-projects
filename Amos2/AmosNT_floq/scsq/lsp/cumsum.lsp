(defun cumsumbbf (fno v pos r)
  (let ((cs 0)
        (res (copy-array v)))
    (maparray v 
	      (function (lambda (x i)
			  (setq cs (+ cs (aref x pos)))
			  (setf (aref (aref res i)pos) cs))))
    (osql-result v pos res))      
  )

(osql "
create function cumsum(Vector of Vector, Integer pos)->Vector of Vector 
  as foreign 'cumsumbbf';")
