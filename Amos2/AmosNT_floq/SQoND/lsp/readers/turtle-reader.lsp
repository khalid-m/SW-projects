;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: turtle-reader.lsp,v $
;;; $Revision: 1.26 $ $Date: 2013/12/20 14:48:24 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Streaming turtle reader
;;; =============================================================
;;; $Log: turtle-reader.lsp,v $
;;; Revision 1.26  2013/12/20 14:48:24  andan342
;;; Supporting multiple stored graphs:
;;; - added GRAPH and FROM NAMED syntax
;;; - LOAD() and CLEAR() functions now take a graph URI as the last argument
;;; - default stored graph is now in GRAPH(0)
;;;
;;; Revision 1.25  2013/02/05 14:13:45  andan342
;;; Renamed nma-init to nma-fill, aded more typechecks, removed lisp implementation of RDF:SUM and RDF:AVG
;;;
;;; Revision 1.24  2013/01/09 14:16:56  andan342
;;; *** empty log message ***
;;;
;;; Revision 1.23  2013/01/09 11:45:55  andan342
;;; Full support for string-based version
;;;
;;; Revision 1.22  2012/12/17 23:30:58  andan342
;;; Enabling file-links with parameters, always resolving in same dir as .TTL file
;;;
;;; Revision 1.21  2012/11/22 12:41:55  andan342
;;; Added extensible plug-in reader mechanism to resolve file-links in Turtle files
;;; Implemented CheloniaArray reader to load BISTAB data
;;;
;;; Revision 1.20  2012/11/05 23:10:43  andan342
;;; LOAD() functition now reads remote Turtle files via HTTP
;;;
;;; Revision 1.19  2012/06/25 20:36:35  andan342
;;; Added TypedRDF and support for custom types in Turtle reader and SciSPARQL queries
;;; - rdf:toTypedRDF and rdf:strdf can be used as constructors in terms of RDF literals
;;; - rdf:str and rdf:datatype can be used as field accessors
;;;
;;; Revision 1.18  2012/06/21 14:00:48  andan342
;;; Fixed a bug when isolating blank nodes from the same dataset
;;;
;;; Revision 1.17  2012/06/06 13:09:45  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.16  2012/03/16 16:16:49  andan342
;;; Changed the notation for generated blank nodes, checking for possible conflicts with user blank nodes
;;;
;;; Revision 1.15  2012/02/23 19:15:40  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.14  2012/02/20 17:09:10  andan342
;;; Added reader and storage support for boolean values
;;;
;;; Revision 1.13  2012/02/14 15:08:06  andan342
;;; Added Amos setter fn for _last_blank_
;;;
;;; Revision 1.12  2012/02/14 13:39:29  andan342
;;; Added support for blank node isolation when loading multiple sources into store
;;;
;;; Revision 1.11  2012/02/08 16:18:16  andan342
;;; Now using READ-TOKEN-based SPARQL lexer in Turtle/NTriples reader,
;;; moved (returtle-amosfn ...) def to master.lsp
;;;
;;; Revision 1.9  2011/12/05 15:09:41  andan342
;;; Now printing how many triples are read from Turtle/Ntriples file
;;;
;;; Revision 1.8  2011/12/02 00:46:46  andan342
;;; - now using the complete (evaluating) parser in the toploop
;;; - made SparQL the default toploop language
;;; - not using any environment variables anywhere
;;;
;;; Revision 1.7  2011/12/01 14:26:43  torer
;;; Removed environment variables in file loading
;;;
;;; Revision 1.6  2011/10/23 12:13:40  andan342
;;; Using common fuctions defined in %AMOS_HOME%/lsp/grm/parse-utils
;;;
;;; Revision 1.5  2011/07/06 16:19:23  andan342
;;; Added array transposition, projection and selection operations, changed printer and reader.
;;; Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
;;; Added Lisp testcases for this and one SparQL query with array variables
;;;
;;; Revision 1.4  2011/05/23 20:00:44  andan342
;;; Now supporting blank nodes abbreviations [] and collection abbreviations (),
;;; "rdf" prefix is now built-in
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defvar _emit_strings_ (and (boundp '_sq_string_based_) _sq_string_based_))

(with-directory ".." ;; Import from SQoND Lisp directory
		(unless (boundp 'lisp_reader_breaks)
		  (load "sparql-stream-parser.lsp")) ;; using the same lexer as SPARQL
		(unless (boundp '_rdf_types_declared_) 
		  (load "rdf-types.lsp"))  ;; using RDF types
		(unless (or (boundp '_nma_types_declared_) _emit_strings_)
		  (load "nma.lsp"))) ;; using numeric multidimensional arrays

(load "reader-utils.lsp")

(defvar _supported_file_formats_ nil)

;(unless _emit_strings_
;  (load "chelonia-reader.lsp")
;  (push '("cheloniaarray" . cheloniaarray-read) _supported_file_formats_))

(defvar _sq_emit_nmas_ nil) ;; Emit collections as NMAs when possible if T

(defvar _sq_resolve_file_links_ :verbose) ;; Emit file link URIs if NIL, resolve if T, print progress if :verbose

(defvar _sq_last_blank_ -1) ;;Currently Turtle-reader is only way to import RDF. Other possible readers should use the same _sq_last_blank_ value

(foreign-lispfn Update_last_blank ((Number x)) () (setq _sq_last_blank_ x)) ;; Amos setter for _sq_last_blank_

(defvar _sq_get_blank_ nil) ;;Hook for a function that takes a blank URI and returns non-NIL if it is already in the store

(defstruct turtle-data filename (prefixes (make-hash-table :test #'equal)) (blank-substs (make-hash-table :test #'equal)) (emit-count 0))

(defun emit-triples (data s pos)
  (let ((ps (turtle-data-prefixes data)))
    (dolist (po pos)
      (dolist (o (cdr po))
	(incf (turtle-data-emit-count data))
	(osql-result (turtle-data-filename data) (term-to-value s data) (term-to-value (car po) data) (term-to-value o data))))))

(defun emit-collection (data c)
  (if (null c) (URI "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil") 
    (let ((res (term-to-value (gen-blank data) data))
	  (fn (turtle-data-filename data)))
      (incf (turtle-data-emit-count data))
      (osql-result fn res (URI "http://www.w3.org/1999/02/22-rdf-syntax-ns#first") (term-to-value (car c) data)) ; m-recursive
      (incf (turtle-data-emit-count data))
      (osql-result fn res (URI "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest") (emit-collection data (cdr c))) ; recursive
      res)))
 
(defun add-prefix (data key val)
  (puthash key (turtle-data-prefixes data) val))

(defun gen-blank (data)
  (incf _sq_last_blank_)
  (list 'genblank _sq_last_blank_))

(defun make-uri (x)
  (if _emit_strings_ x ;MAYBE: (concat "<" x ">")
    (uri x)))

(defun file-link-validate (x)
  "Check whether X is a file-link, return a reader function, resource and parameter"  
  (when (eq (typename x) 'uri)
    (let ((x-split (string-explode (uri-id x) ":"))
	  type-and-par sff-entry)
      (when (and (third x-split) (string= (first x-split) "file")) ; when uri can be parsed as file://<filename>:<type-and-par>
	(setq type-and-par (string-explode (car (last x-split)) "#"))
	(setq sff-entry (assoc (first type-and-par) _supported_file_formats_))
	(when sff-entry ; only if type is registered, return 
	  (list (cdr sff-entry) ; function symbol
		(substring 2 (1- (length (second x-split))) (second x-split)) ; extracted filename
		(if (second type-and-par) (second type-and-par) ""))))))) ; par


      
(defun term-to-value (term data)
  (let (res valid-link)
    (setq res
	  (cond ((atom term) (if _emit_strings_
				 (selectq (typename term)
					  (ustr (ustr-str term))
					  (uri (uri-id term))
					  ((symbol real integer) (mkstring term)) ;MAYBE: downcase
					  term)
			       term))
		((eq (car term) 'blank) (let* ((blank-str (concat "_:" (second term)))
					       (subst (gethash blank-str (turtle-data-blank-substs data))))
					  (if subst subst ; use blank substitute if already in HT
					    (progn
					      (if (or (and (string= (substring 0 0 (second term)) "b") ; if user blank node might come into conflict with generated ones
							   (integerp (read (substring 1 (1- (length (second term))) (second term)))))
						      (and _sq_get_blank_ (funcall _sq_get_blank_ blank-str))) ; or if it is found in store
						  (setq subst (term-to-value (gen-blank data) data)) ; substitute user blank with generated one
						(setq subst (make-uri blank-str))) ; store user blank as URI beginning with '_:'
					      (puthash blank-str (turtle-data-blank-substs data) subst) ; put the pair into HT
					      subst))))
		((eq (car term) 'genblank) (make-uri (concat "_:b" (second term)))) ; store generated blanks as URIs beginning with '_:b' 
		((eq (car term) 'iri) (make-uri (second term)))
		((eq (car term) 'prefixed) (make-uri (concat (gethash (second term) (turtle-data-prefixes data)) (third term))))
		((eq (car term) 'typed) (if _emit_strings_ (ustr-str (second term)) ;MAYBE: upcase
					  (let ((type-uri (term-to-value (third term) data))) ;recursive
					    (cond ((or (rdf-realtype-p (uri-id type-uri))
						       (= type-uri #[URI "http://www.w3.org/2001/XMLSchema#integer"]))
						   (read (ustr-str (second term))))
						  ((member type-uri '(#[URI "http://www.w3.org/2001/XMLSchema#string"]
								      #[URI "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"]))
						   (second term))
						  ((= type-uri #[URI "http://www.w3.org/2001/XMLSchema#dateTime"])
						   (rdf-str-to-timeval (ustr-str (second term))))
						  ((= type-uri #[URI "http://www.w3.org/2001/XMLSchema#boolean"])
						   (selectq (string-downcase (ustr-str (second term)))
							    ("true" 'true)
							    ("false" 'false)
							    (error (concat "Invalid boolean value: " (ustr-str (second term))))))
						  (t (typedrdf (ustr-str (second term)) type-uri))))))
		((listp term) 
		 (when _sq_emit_nmas_ 
		   (setq res (list-to-nma term)))
		 (if res res (emit-collection data term))))) ;m-recursive
    (setq valid-link (file-link-validate res))
    (if valid-link (with-directory (filename-or-url-dir (turtle-data-filename data))
				   (funcall (first valid-link) ; reader function symbol
					    (second valid-link) ; resource (filename or url)
					    (third valid-link) ; parameters
					    (eq _sq_resolve_file_links_ :verbose))) ; verbose flag
      res)))

(load "turtle-slr1.lsp")

(defun turtle-+++ (fno filename-or-url s p o)
  "Read triples from a local (if arg is string or USTR) or remote (if arg is URI) Turtle file"
  (let ((data (make-turtle-data :filename filename-or-url))
	(ores (open-filename-or-url filename-or-url))
	tape res)
    (add-prefix data "rdf" "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    (add-prefix data "xsd" "http://www.w3.org/2001/XMLSchema#")
    (setq tape (make-lexer-tape :str (car ores)))
    (unwind-protect
	(progn
	  (setq res (turtle-slr1-parser (f/l () (sparql-stream-lexer-ex tape)) data)) ; run SLR(1) parser routine
	  (formatl t (concat (turtle-data-emit-count data) " triples read from " (cdr ores)) t)
	  (when (and (listp res) (eq (car res) 'syntax-error)) 
	    (sq-error (concat "Syntax error: " (syntax-error-msg res) " in " (cdr ores)) tape)))
      (unless (chunked-stream-p (car ores)) (closestream (car ores)))))) ; a socket is closed automatically otherwise

(if _emit_strings_
    (osql "create function turtle(Charstring filename)->Bag of (Charstring, Charstring, Charstring) as foreign 'turtle-+++';") 
  (osql "create function turtle(Literal filename)->Bag of (Literal, Literal, Literal) as foreign 'turtle-+++';"))

;;;ARRAYS

(defun is-nma-desc-compatible (x y) 
  "compare 2 NMA descriptors for CONCAT-compatibility"
  (if (null (cdr x)) ; if elements of numeric type
      (when (null (cdr y)) (max (car x) (car y))) ; return the broadest numeric kind
    (when (and (cdr y) ; if elements of NMA type
	       (equal (cdr x) (cdr y))) ; and dimensionalities agree
      (max (car x) (car y))))) ; also return the broadest numeric kind
    

(defun list-to-nma-desc (x)
  "create an NMA descriptor for Turtle list"
  (cond ((null x) nil) ; empty lists are never valid
	((atom x) (selectq (typename x) ; return numeric kinds
			   (integer (cons 0 nil))
			   (real (cons 1 nil))
			   (complex (cons 2 nil))
			   nil))
	(t (let ((desc0 (list-to-nma-desc (car x))) desci (cnt 1)) ;recursive		 
	     (when (and desc0 
			(dolist (i (cdr x) t) 
			  (setq desci (list-to-nma-desc i)) ;recursive
					;check for compatibility and update broadest numeric kind
			  (unless (and desci (setf (car desc0) (is-nma-desc-compatible desc0 desci))) 
			    (return nil))
			  (incf cnt))) ; update counter
	       (cons (car desc0) (cons cnt (cdr desc0)))))))) ;extend array dimensions

(if _emit_strings_
    (defun list-to-nma (x) nil) ; never actually called
  (defun list-to-nma (x)
    "create an NMA object for Turtle list"
    (let ((desc (list-to-nma-desc x)) res) ;1st pass
      (when desc
	(setq res (make-nma (car desc) (cdr desc)))
	(nma-fill res x) ;2nd pass
	res))))



