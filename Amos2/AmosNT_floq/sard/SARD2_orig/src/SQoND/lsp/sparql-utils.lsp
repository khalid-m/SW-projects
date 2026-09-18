;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2011 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-utils.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utility functions used in AmosQL translations of SparQL queries
;;; =============================================================
;;; $Log: sparql-utils.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:42  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.18  2013/01/15 21:55:29  andan342
;;; Added more efficient and safe versions of ARGMIN and ARGMAX
;;;
;;; Revision 1.17  2013/01/10 12:19:34  andan342
;;; REGEX now handles both W3C standard and legacy (TopicMap) regular expression syntax
;;;
;;; Revision 1.16  2013/01/09 11:46:26  andan342
;;; Full support for string-based version
;;;
;;; Revision 1.15  2012/11/19 23:58:09  andan342
;;; - using resolve-nma inside all array-processing functions as part of proxy-allowing polymorphic behavior,
;;; - moved _nma_proxy_threshold_ to core SSDM, setting this value in regression test return NMAs from queries,
;;; - added _nma_limit_ for a max NMA size to be retrieved, printing a warning if exceeded
;;;
;;; Revision 1.14  2012/11/05 23:10:42  andan342
;;; LOAD() functition now reads remote Turtle files via HTTP
;;;
;;; Revision 1.13  2012/06/25 20:36:35  andan342
;;; Added TypedRDF and support for custom types in Turtle reader and SciSPARQL queries
;;; - rdf:toTypedRDF and rdf:strdf can be used as constructors in terms of RDF literals
;;; - rdf:str and rdf:datatype can be used as field accessors
;;;
;;; Revision 1.12  2012/06/24 15:00:16  andan342
;;; Fixed typecheck bug in rdf:regex
;;;
;;; Revision 1.11  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.10  2012/04/27 10:16:09  torer
;;; optional() -> optional0()
;;;
;;; Revision 1.9  2012/03/17 14:23:38  andan342
;;; Added DUMP() function to dump current triple store into Turtle file
;;;
;;; Revision 1.8  2012/02/23 19:15:39  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.7  2012/02/10 11:47:50  andan342
;;; All Amos functions implementing SciSPARQL functions now have/get rdf: namespace
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; ----------------- LOAD & CLEAR  --------------------

;; Depends on:
;; _sq_default_triples_fn_
;; _sq_string_based_

(defun load-in-memory (filename-or-url) 
  ;TODO: may be rewritten to directly call turtle() with provided argument, avoid AmosQL parsing, stop using _sq_default_triples_fn_
  "Default in-memory implementation of LOAD(), return T on success"
  (parse (concat "add " _sq_default_triples_fn_  " = turtle("
		 (selectq (typename filename-or-url)
			  (ustr (concat "'" (ustr-str filename-or-url) "'"))
			  (uri (concat "uri('" (uri-id filename-or-url) "')"))
			  (concat "'" filename-or-url "'")) ;if string
		 ");") t) t)

(defun clear-in-memory () 
  "Default in-memory implementation of CLEAR()"
  (clearfunction (car (getobject (getfunctionnamed (mksymbol (with-textstream s _sq_default_triples_fn_ (read-token s))))
				 'resolvents)) nil))

;; Load triples into triple store, return T on success 
(defvar _sq_load_triples_ #'load-in-memory)

;; Clear triple store
(defvar _sq_clear_triples_ #'clear-in-memory)


;; -------------------- REGEX ----------------------------

(defun sparql-regex-to-amosql (regex)
  "convert SparQL REGEX format to Amos LIKE pattern"
  (let ((lastpos (1- (length regex))) regex1)
    (setq regex1 (if (string-pos regex "^") (substring 1 lastpos regex) (concat "*" regex))) ; left anchoring
    (setq regex1 (if (string-pos regex1 "$") (substring 0 (1- lastpos) regex1) (concat regex1 "*"))) ; right anchoring
    (string-remove-cont-duplicates (string-substitute regex1 '((".*" . "*"))) "*")))

;; TODO: Only "i" flag is supported. Other flags described here: http://www.w3.org/TR/xpath-functions/#flags 
(defun rdf-regex--- (fno str pat options)
  (let ((options1 (cond ((stringp options) options) ; options were constant at translation time (or string-based)
			((eq (typename options) 'ustr) (ustr-str options)) ; options resulted from expression
			(t nil)))
	(pat1 (cond ((stringp pat) pat) ; pattern translated at translstion-time (or string-based)
		    ((eq (typename pat) 'ustr) (sparql-regex-to-amosql (ustr-str pat))) ; pattern resulted from expression
		    (t nil)))
	(str1 (cond (_sq_string_based_ str)
		    ((eq (typename str) 'ustr) (ustr-str str))
		    (t nil))))
      (when (and options1 pat1 str1
		 (if (string-pos options1 "i") 
		     (string-like-i str1 pat1) 
		   (string-like str1 pat1)))
	(osql-result str pat options))))

  
(if _sq_string_based_
(osql "
create function rdf:regex(Charstring str, Charstring pat, Charstring options) -> Boolean as foreign 'rdf-regex---';

create function rdf:regex(Charstring str, Charstring pat) -> Boolean as rdf:regex(str,pat,'');
")
(osql "
create function rdf:regex(Literal str, Literal pat, Literal options) -> Boolean as foreign 'rdf-regex---';

create function rdf:regex(Literal str, Literal pat) -> Boolean as rdf:regex(str,pat,'');
"))


;; ------------------- SOURCE, LOAD & CLEAR -----------------

(defun rdf-source- (fno filename) 
  (parse-file (ustr-str filename) "SPARQL"))

(defun rdf-load-- (fno filename-or-url replace res)
  (when (if _sq_string_based_ (string-like-i replace "true") 
	  (eq replace 'true))
    (funcall _sq_clear_triples_))
  (funcall _sq_load_triples_ filename-or-url))

(if _sq_string_based_
(osql "
create function rdf:source(Charstring filename) -> Boolean 
  as foreign 'rdf-source-';

create function rdf:load(Charstring filename_or_url, Charstring replace) -> Boolean
  as foreign 'rdf-load--';

create function rdf:load(Charstring filename_or_url) -> Boolean 
  as rdf:load(filename_or_url,'false');
")
(osql "
create function rdf:source(Literal filename) -> Boolean 
  as foreign 'rdf-source-';

create function rdf:load(Literal filename_or_url, Literal replace) -> Boolean
  as foreign 'rdf-load--';

create function rdf:load(Literal filename_or_url) -> Boolean 
  as rdf:load(filename_or_url,false);
"))


(defun rdf-clear (fno)
  (funcall _sq_clear_triples_))

(osql "
create function rdf:clear() -> Boolean 
  as foreign 'rdf-clear';
")

;; ---------------- DUMP (only available in RDF-based version) ----------

(unless _sq_string_based_

(defun rdf-dump (term outs) 
  "Print RDF resource to Turtle file" ;TODO: support N-Triples as well
  (selectq (typename term)
	   (ustr (formatl outs "\"" (ustr-str term) "\"") ; base string
		 (when (> (length (ustr-lang term)) 0) ; unless langtag is empty
		   (formatl outs "@" (ustr-lang term)))) ; concatenate langtag
	   (uri (if (and (>= (length (uri-id term)) 2) 
			 (string= (substring 0 1 (uri-id term)) "_:"))
		    (formatl outs (uri-id term)) ; notation for blank nodes
		  (formatl outs "<" (uri-id term) ">"))) ; notation for URIs
	   (typedrdf (formatl outs "\"" (typedrdf-str term) "\"^^") ; notation for typed literals
		     (rdf-dump (typedrdf-typeuri term) outs)) ;recursive
	   (nma (nma-dump term outs)) ; print array as list
	   (formatl outs (rdf-to-string term)))) ; use rdf:str() function in all other cases
	   
(defun dump-triples-- (fno filename triples)
  (let ((outs (openstream filename "w")) (cnt 0))
    (unwind-protect
	(progn
	  (mapbag triples (f/l (triple)
			       (dolist (term triple)
				 (rdf-dump term outs)
				 (formatl outs " "))
			       (formatl outs "." t)
			       (incf cnt)))      
	  (print (concat cnt " triples written to file: " filename)))
      (closestream outs))))

(defun rdf-dump- (fno fileuri)
  (parse (concat "dump_triples('" (fileuri-to-filename fileuri) "'," _sq_default_triples_fn_ ");") t))

(osql "
create function dump_triples(Charstring filename, Bag of (Literal, Literal, Literal) triples) -> Boolean
  as foreign 'dump-triples--';

create function rdf:dump(Literal fileuri) -> Boolean
  as foreign 'rdf-dump-';
"))


;; --------------- 2ND-ORDER FUNCTIONS --------------------------------

(defun rdf-argmin-+ (fno bag)
  (let (resrow)
    (mapbag bag (f/l (row) (when (or (null resrow) (< (second row) (second resrow)))
			     (setq resrow row))))
    (when resrow
      (osql-result bag (first resrow)))))

(defun rdf-argmax-+ (fno bag)
  (let (resrow)
    (mapbag bag (f/l (row) (when (or (null resrow) (> (second row) (second resrow)))
			     (setq resrow row))))
    (when resrow
      (osql-result bag (first resrow)))))

(osql "
create function rdf:argmin(Bag b) -> Literal
  as foreign 'rdf-argmin-+';

create function rdf:argmax(Bag b) -> Literal
  as foreign 'rdf-argmax-+';
")
