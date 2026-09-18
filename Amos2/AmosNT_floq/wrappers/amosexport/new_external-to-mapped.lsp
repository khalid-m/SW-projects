(defun get-decode-datasource (decodefno)
  (getobject 
   (getresolvent
    (getobject (first (get-resolvent-argtypes decodefno)) 'cclusterfn))
   'datasource))

(defun external-to-mapped (fno o &rest decodedtuple) 
  "Convert DECODED -> OID"
   (let* ((mapped-supertype (first (getobject fno 'argtypes)))
	  (ds (get-decode-datasource fno))
	  (mapped-type (if (subtypes mapped-supertype)
			   (most-specific-type ds mapped-supertype 
					       (car decodedtuple))
			 mapped-supertype))
	  res)
;     (print (concat "e:"(car decodedtuple)" of t:"mapped-supertype" st:"mapped-type))
     (setq res (encode-mapped-object (make-key decodedtuple) mapped-type))
     (if res (apply 'osql-result (cons res decodedtuple)))))
 

(defun decoded-ok (fno o &rest decodedtuple)
  "Check that O is encoding of decodedtuple with most specific type
   given by type of FNO"
  (let ((mapped-type (first (getobject fno 'argtypes))) ; the type of O
	res)
    (if (and o 
	     (or (eq (arg-type o) mapped-type)
		 (memq (arg-type o) (type-allsubtypes mapped-type)))
	     (equal (mklist(decode-mapped-object o)) decodedtuple))
	(apply 'osql-result (cons o decodedtuple)))))
