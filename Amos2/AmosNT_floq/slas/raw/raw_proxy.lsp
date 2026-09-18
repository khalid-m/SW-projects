(defglobal _file-content_ (list #(1 2 3 4 5) #(3 4 5 6 7) #(4 5 6 7 8)))

(defun raw-log-file0 (fn m s bt et  mv)
  (mapc (f/l (i)
	     (if (arrayp i)		 
		 (osql-result (elt i 0) (elt i 1)
			      (elt i 2) (elt i 3)
			      (elt i 4))))
	_file-content_))


(defun raw-log-file (fn m s bt et  mv)
  (let (i)
    (mapc (f/l (l)
	       (setq i (car l))
	       (if (arrayp i)		 
		   (osql-result 
		    (elt i 0) (elt i 1)
		    (elt i 3) (elt i 2)
		    ;; there is some mistake in the file. 
		    ;;I have to  re-map column 2 to et and column 3 to bt
		    (elt i 4))))
	  (amos-execute "csv_file_tuples('raw/measuredB.txt');"))))

