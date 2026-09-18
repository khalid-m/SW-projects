
(foreign-lispfn groupagg ((Charstring filename) (Integer pos)) ((Vector of Vector))
	(let ((fh (openstream filename "r"))
	      (eof (mksymbol "*EOF*"))
	      (trow 0)
	      row window)
	  (while fh
	    (setq row (read fh))
	    (cond ((eq row eof)
		   (closestream fh)
		   (setq fh nil))
		  (t
		   (cond ((< trow (elt row pos))
			  (foreign-result window)
			  (setq trow (elt row pos))
			  (setq window nil)
			  (setq window (push-vector window row)))
			 (t
			  (setq window (push-vector window row)))))))))