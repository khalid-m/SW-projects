(defun sql-query-plan (query)
  "Compile SQL query string into AMOSQL function"
  (let* ((sql-debugging t)
         (form (eval (sql-parse query))))
    (selectq (car form)
	     (osql-select 
	      (pc (createfunction 
		   '*TRANSIENT*
		   nil
		   (mapcar (f/l (x) (list _object_))(cadr form))
		   (cadr form) 
		   (substdeclarations(getf form 'foreach)) 
		   (getf form 'where))))
	     (amos-error "Not a SELECT expression: " query))))
