;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2011 Silvia Stefanova, UDBL
;;; $RCSfile: uri.lsp,v $
;;; $Revision: 1.5 $ $Date: 2012/06/04 13:43:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Pre- and post- processing 
;;;;;; ===========================================================================


(defun gen-concat (fno val xsdtype form)
"Concatenates val and xsd type to form the value of an RDF triple"
  (if (null val)
	(osql-result val xsdtype NIL)
	  (if (string-like xsdtype "*string*")
	    (osql-result val xsdtype val);;don't type if val is a string
	    (osql-result val xsdtype (concat "\"" val "\""  "\^\^" "<" xsdtype ">" )))))



(defun is-date? (str)
"True if the string is representing a date, datetime"
  (if (stringp str)
      (let ((ll nil ))
	(setf ll (string-explode str "-"))
	(if (and (numberp (encode-numeric (first ll)))
		 (>= (encode-numeric (first ll)) 1970)
		 (<= (encode-numeric (first ll)) 2030))
	    (if (and (numberp (encode-numeric (second ll)))
		     (>= (encode-numeric (second ll)) 1)
		     (<= (encode-numeric (second ll)) 12))
		(if (and (numberp (encode-numeric (substring 0 1 (third ll))))
			 (>= (encode-numeric (substring 0 1 (third ll))) 1)
			 (<= (encode-numeric (substring 0 1 (third ll))) 31))
		    (if (datep (mkdate (encode-numeric (first ll)) 
				       (encode-numeric (second ll))
				       (encode-numeric (substring 0 1 (third ll)))))
			't)))))))



(defun is-like-cMap (str)
"True if the string str is like one of the URIs in cMap"
 (if (stringp str)
   (dolist ( el (osql "cMap();") )
     (if (string-like str  (concat (car (last el)) "*"))
	 (return t) ))))
     
		

(defun split-value (fno xsdstring xsdtype val)
"Retrieves only the value from a xsdstring, i.e. 4216^^http://www.w3.org/2001/XMLSchema#int returns 4216"
  (cond 
       ((null xsdstring) (osql-result xsdstring xsdtype NIL));;if the xsdstring is NIL
       ((null (stringp xsdstring)) (osql-result xsdstring xsdtype xsdstring));;if the xsdstring is not a string
       (t
	 (if (string-like xsdstring "*XMLSchema*") 
	   (if (string-like (substring (string-pos xsdstring "http://") (- (length xsdstring) 2) xsdstring)  xsdtype);;if xsdstring is typed literal
	    (osql-result xsdstring xsdtype (encode-numeric (mkstring  (substring 1 (- (string-pos xsdstring "^") 2) xsdstring)))))
	   (if (null (or (is-like-cMap xsdstring)
		         (and (numberp (encode-numeric xsdstring)) (string-like xsdtype "*string"));;if xsdstring is plain literal
			 (and (stringp (encode-numeric xsdstring)) (string-like xsdtype "*int*"))
			 (and (stringp (encode-numeric xsdstring)) (string-like xsdtype "*decimal"))
			  (and (stringp (encode-numeric xsdstring)) (string-like xsdtype "*float"))
			 (and (is-date? xsdstring)                 (string-like xsdtype "*string"))
			 (and (null (is-date? xsdstring))          (string-like xsdtype "*dateTime"))
			 (and (null (is-date? xsdstring))          (string-like xsdtype "*date"))
			 (and (stringp (encode-numeric xsdstring)) (string-like xsdtype "*double"))))
	       (osql-result xsdstring xsdtype (encode-numeric (mkstring xsdstring))))))))

  



(defun separ-slash (st)
"Separates the elements delimited by /"
 (cond ((null st) nil)
       ((equal st "") nil)
       ((null (string-pos st "/")) (list st))
	(t
	  (cons (substring 0 (- (string-pos st "/") 1) st) (separ-slash (substring (+ (string-pos st "/") 1) (length st) st))))))


(defun separ-pkcolumns (fno st pkcols)
 (osql-result st (listtoarray (separ-slash st))))

(defun notlike-- (fno str pat)
"The negation of like"
  (if (null (string-like str pat))
      (osql-result str pat)))





;(defglobal _rdf-resource_ (gettypenamed 'rdf_resource))
;(defglobal _buri-cnt_ -1)

;(defun encode-rdf-resource (fno k transient)
;  "Create transient RDF object with k as key" 
;  (osql-result k (encode-mapped-object k _rdf-resource_)))

;(defun decode-rdf-resource (fno k resource)
;  "Get key of resource"
;  (osql-result (decode-mapped-object resource) resource))

;(defun blankSubject-+ (fno po s)
;  "Create new blank node"
;  (let* ((id (1++ _buri-cnt_))
;         (new (encode-mapped-object id _rdf-resource_)))
;    (putobject new 'po po)
;    (osql-result po new)))

;(defun blankSubject+- (fno po s)
;  "Create new blank node"
;  (let ((po (getobject s 'po)))
;    (osql-result po s)))
