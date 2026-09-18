;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Erik Zeitler, UDBL
;;; $RCSfile: hmerge.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/02/12 23:22:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stream hash merge
;;; =============================================================
;;; $Log: hmerge.lsp,v $
;;; Revision 1.1  2011/02/12 23:22:58  zeitler
;;; Hash merge on numarrays
;;;
;;;
;;; =============================================================

(defun hmerge-na---+ (fno s attrib w res)
  (let ((ht (make-hash-table :test #'equal)))
    (mapbag s (f/l (tpl)
		   (let* ((key (na-elt (car tpl) attrib))
			  (htv (gethash key ht)))
		     (cond (htv (seta (car htv) (cdr htv) (car tpl))
				(rplacd htv (+ 1 (cdr htv)))
				(if (equal w (cdr htv))
				    (progn
				      (osql-result s attrib w (car htv))
				      (remhash key ht))))
			   (t (let ((v (make-array w)))
				(seta v 0 (car tpl))
				(puthash key ht (cons v 1))))))))))

(osql "create function nahmerge(bag of numarray, integer attrib, integer width)
->vector of numarray as foreign 'hmerge-na---+';")
