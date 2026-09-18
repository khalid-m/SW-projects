(defun dircsv (dir)
  (mapcar #'(lambda (file)
	      (concat dir (car file)))
	  (getfunction (getfunctionnamed 'dir_i)
		       (list dir "*.csv"))))

(defun clear-dir (files)
  (mapc #'delete-file files))

(defun copy-file (from to)
  (system (concat "copy " from " " to)))

(defun copier (from to delay &optional keep-to)
  (unless keep-to
    (clear-dir (dircsv to))
    (sleep 1))
  (dolist (file (dircsv from))
    (copy-file file to)
    (sleep delay)))

(defun copier---+ (fno from to delay)
  (copier (string-replace-char from "/" "\\") 
	  (string-replace-char to "/" "\\") 
	  delay))

(osql "
create function copier(charstring fromdir,charstring todir,real delay)
                     ->boolean 
       /* Copy logfiles from the first directory to the second at regular 
          interval delay to simulate arriving logfiles. 
          Deletes existing logfiles in destination directory before 
          copying starts.*/
       as foreign 'copier---+';")
