(defun parteval-pred (pr)
  (let* ((bpat (mapcar (f/l (x)(if (osql-constantp x) '- '+)) (cdr pr)))
         (fno (the-tbr-function (if (relationp (car pr))
                                    (getobject (car pr) 'predof)
				  (car pr)) 
				bpat t))
         (count 0)
         res)
    (cond ((null fno) nil);;no TBR fn applicable -> no partial evaluation
	  ((mapfunction 
	      fno 
	      (mapcan (f/l (x)
			   (if (osql-constantp x) 
			       (list x))) 
		      (cdr pr))		; argl = constant arguments
	      (f/l (r);;Iterate over result of partial evaluated fn
                   (1++ count)
		   (push (mapcan (f/l (c v) 
				      (if (osql-constantp v) nil 
					(list (list _=_ c v))))
				 r (subset (cdr pr) 
					   (function symbolp)))
			 res))))
	  ((< count 1) (list 'false));;pr evaluated without any result -> FALSE
	  ((= count 1) (if res (car res) 'true));;pr evaluated with one 
          (t (list (orify (mapcar (function andify) (nreverse res))))))))
