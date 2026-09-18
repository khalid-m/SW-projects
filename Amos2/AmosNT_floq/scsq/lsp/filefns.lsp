(foreign-lispfn 
 rfile ((charstring filename)) ((object))
 (let ((fh (new-filestream filename "r")) (eof (mksymbol "*EOF*")) (row))
   (while t
     (setq row (read fh))
     (cond ((equal eof row)
	    (closestream fh)
	    (return t))
	   (t (foreign-result row))))))

(foreign-lispfn 
 wfile ((object o) (charstring filename)) ((integer))
 (let ((fh (new-filestream filename "w")))
   (print o fh)
   (flush fh)
   (closestream fh)
   (foreign-result 'TRUE)))
