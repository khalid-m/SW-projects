;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Andrej Andrejev, UDBL
;;; $RCSfile: sql-store-utils.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/02/01 12:04:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Common code used in sql-store and bulkload/dumper.lsp
;;; =============================================================
;;; $Log: sql-store-utils.lsp,v $
;;; Revision 1.3  2013/02/01 12:04:07  andan342
;;; Using same NMA descriptor objects as proxies
;;;
;;; Revision 1.2  2013/01/21 16:49:20  andan342
;;; Storing chunksize in Parameter table inside RDF store, comes as a parameter to setup.cmd script
;;; Added test script for bulk-loading
;;;
;;; Revision 1.1  2013/01/11 17:30:48  andan342
;;; Added bulk-loading and dumper functionality
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================


(defparameter rdf-store-utils.lsp t)

(defparameter rdf-store-default-uris '((1 . "http://www.w3.org/2001/XMLSchema#integer")
				       (2 . "http://www.w3.org/2001/XMLSchema#float")
				       (3 . "http://www.w3.org/2001/XMLSchema#boolean")
				       (4 . "http://www.w3.org/2001/XMLSchema#dateTime")
				       (5 . "http://www.w3.org/2001/XMLSchema#string")
				       (6 . "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")
				       (7 . "http://udbl.uu.se/SciSPARQL/Types#NMA")))

(foreign-lispfn sqlStoreDefaultURIs () ((Integer) (Charstring)) ; used in setup.osql
		(dolist (iu rdf-store-default-uris)
		  (foreign-result (car iu) (cdr iu))))

(defun rdf-to-store (x) 
  "Storage string representation of literal"
  (selectq (typename x) 
	   ((uri typedrdf)
	    (rdf-to-string x))
	   (ustr (if (string= (ustr-lang x) "") (ustr-str x)
		   (concat (escape-string (ustr-str x) "@") "@" (ustr-lang x))))
	   (timeval (amos-timeval-to-sparql x))
	   (nma "") ; a different mechanism is used to store NMAs
	   (with-string s (princ x s))))

(defun rdf-storage-type (x lookup-or-add-uri-fn)
  "Storage type tag of literal"
  (selectq (typename x)
	   (uri 0)
	   (integer 1)
	   (real 2)
	   (symbol 3) ;boolean
	   (timeval 4) 
	   (ustr (if (string= (ustr-lang x) "") 5 6))
	   (nma 7)
	   (typedrdf (funcall lookup-or-add-uri-fn (typedrdf-typeuri x)))
	   nil))

(defun getNMAMeta-+ (fno x res)
  (let ((kind (nma-kind x))
	(dims (nma-dims x)))
    (setq res (mkarray 6))
    (setf (aref res 0) kind)
    (setf (aref res 1) (length dims))
    (dotimes (i 4)
      (setf (aref res (+ 2 i)) 
	    (if (< i (length dims)) (aref dims i) 0)))
    (osql-result x res)))

(osql "
create function getNMAMeta(Literal x) -> Vector of Integer as foreign 'getNMAMeta-+';
")