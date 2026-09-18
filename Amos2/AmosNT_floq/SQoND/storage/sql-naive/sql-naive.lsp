;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012, Andrej Andrejev, UDBL
;;; $RCSfile: sql-naive.lsp,v $
;;; $Revision: 1.7 $ $Date: 2012/10/15 14:15:57 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Naive SQL-based RDF-store implementation
;;; =============================================================
;;; $Log: sql-naive.lsp,v $
;;; Revision 1.7  2012/10/15 14:15:57  andan342
;;; Complete regression test for SQL-naive backend implementation
;;;
;;; Revision 1.6  2012/10/12 14:53:31  andan342
;;; Made StoreToRDF++- intolerant to NIL and *
;;;
;;; Revision 1.5  2012/09/01 16:42:51  andan342
;;; Now aware of TYPEDRDF
;;;
;;; Revision 1.4  2012/05/21 11:14:21  andan342
;;; Loading Python as permanent extension, removed some debug printing
;;;
;;; Revision 1.3  2012/02/23 19:15:40  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.2  2012/02/20 17:09:11  andan342
;;; Added reader and storage support for boolean values
;;;
;;; Revision 1.1  2012/02/14 15:09:51  andan342
;;; Added naive SQL-based implementation of RDF store
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;;; ----------------------- LOADING ------------------------------

(setq _sq_storage_system_ :sql-naive) 

(defparameter _storage_value_length_ #(520 100 100)) ; O-P-S

(defun rdf-to-store (x) ;TODO: ignoring langtags and custom types
  "Storage string representation of literal"
  (if (member (typename x) '(ustr uri typedrdf))
      (rdf-to-string x)			
    (with-string s (princ x s))))

(defun rdf-storage-type (x)
  "Storage type tag of literal"
  (selectq (typename x)
	   (uri 1)
	   (integer 2)
	   (real 3)
	   ((ustr typedrdf) 4) ;TODO: ignoring custom types
	   (timeval 5)
	   (symbol (when (member x '(true false)) 6)) ;boolean
	   (nma 7)
	   nil))

(defun triple-to-constructor (constructor row)
  "Calls the constructor function with the translated triple,
   returns 0 on success and 1 on failure"
  (let ((argl (list (rdf-storage-type (third row)))) (i 0) sterm)
    (when (car argl) 
      (dolist (term (nreverse row))
	(setq sterm (rdf-to-store term))
	(if (> (length sterm) (aref _storage_value_length_ i))
	    (progn (setq argl nil) 
		   (return nil)))
	(incf i)
	(setq argl (cons sterm argl)))
      (if argl (progn (getfunction constructor argl) 0) 1))))

	  
(defun load-into-rdfstore (filename)
  "Loads triples from Turtle file into SQL-naive store mapped to TRIPLES_RDFTORE type"
  (let ((turtle-fn (car (getobject (getfunctionnamed 'turtle) 'resolvents)))
	(constructor (getobject (gettypenamed 'triples_rdfstore) 'constructor))
	(warning-count 0))
    (mapfunction turtle-fn (list filename)
		 (f/l (row) 
		      (setq warning-count (+ warning-count (triple-to-constructor constructor row)))))
    (when (> warning-count 0) (print (concat "WARNING: " warning-count 
					     " triples were rejected due to exceeding term length")))
    t))
    
(defun clear-rdfstore ()
  (osql "sql(:rdfstore,'DELETE FROM Triples');"))

(setq _sq_load_triples_ #'load-into-rdfstore)

(setq _sq_clear_triples_ #'clear-rdfstore)

;;; ----------------------- ACCESSING ----------------------

(setq _sq_default_triples_fn_ "SDEF()")

(defun storeToRDF--+ (fno s ltype res)
  (osql-result s ltype
	       (selectq ltype
			(1 (uri s))
			(3 (* (read s) 1.0))
			(4 (ustr s))
			(read s)))) ; int, timeval, boolean, NMA
  

(defun storeToRDF++- (fno s ltype res)
  (let ((st (rdf-storage-type res)))
    (when st
      (osql-result (rdf-to-store res) st res))))

(osql "
create function storeToRdf(Charstring s, Integer ltype) -> Literal 
  as multidirectional
  ('bbf' key foreign 'storeToRDF--+')
  ('ffb' key foreign 'storeToRDF++-');


parteval('StoreToRDF');
")

;;; -------------------- BLANKS LOOKUP ----------------------------

(defun get-blank-in-store (x)
  (getfunction (car (getobject (getfunctionnamed 'URI_in_SDEF) 'resolvents)) (list amos_rdfstore x)))

(setq _sq_get_blank_ #'get-blank-in-store)
