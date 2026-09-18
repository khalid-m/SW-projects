
;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Cheng Xu, UDBL
;;; $RCSfile: multi_variable.lsp,v $
;;;
;;; Description: multi variables for hagglund data
;;; =============================================================
;;; $Log: multi_variable.lsp,v $
;;; Revision 1.1  2012/10/24 17:15:29  chexu484
;;; hagglunds model and validate now works
;;; record is used instead of vector
;;;
;;; Revision 1.1  2012/10/17 19:52:18  chexu484
;;; multi variables are possible for hagglunds data
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================


; hash table is used to stored the latest value of the variable
(defun hagglunds-vtuples--+ (fno s v res)
  (let ((ht (make-hash-table :test (function equal)))
	(variables (arraytolist v)))
    (mapbag s (f/l (event)
		      (let* ((tuple (car event))
			     (ts (elt tuple 0)) ; time stamp
			     (variable (elt tuple 1)) ; variable name
			     (value (elt tuple 2))) ; value
			(if (some (f/l (v) (equal v variable)) variables)
			    (osql-result s v
				      (listtoarray
				       (cons ts
				       (mapcar (f/l (e)
						    (let ((val (cadr (gethash e ht))))
						      (cond ((equal e variable)
							     (setf (gethash e ht)
								   (list ts value))
							     value)
							    (t val))))
					       variables))))))))))

(defun hagglunds-rtuples--+ (fno s v res)
  (let ((arr (make-array (* 2 (1+ (length v))))) rec)
    (maparray v (f/l (e i)
		     (seta arr (* 2 (1+ i)) e)))
    (seta arr 0 "ts")
    (setq rec (make-record arr))
    (mapbag s (f/l (event)
		   (let* ((tuple (car event))
			  (ts (elt tuple 0)) ; time stamp
			  (variable (elt tuple 1)) ; variable name
			  (value (elt tuple 2))) ; value
		     (if (somea v (f/l (v i) (equal v variable)))
			 (progn (record-put rec variable value)
				(record-put rec "ts" ts)))
		     (osql-result s v rec))))))