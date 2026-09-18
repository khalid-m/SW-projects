;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: master.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:35 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SciSparql master initialization script
;;; =============================================================
;;; $Log: master.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:35  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.19  2013/04/14 17:23:46  andan342
;;; Reverted to completely functional system, including Python
;;;
;;; Revision 1.17  2012/12/14 14:02:03  andan342
;;; Added rdf:insert and rdf:clear Amos functions, callable from SciSPARQL
;;;
;;; Revision 1.16  2012/09/01 16:42:04  andan342
;;; Added _sq_storage_system_ variable to identify current storage capabilities e.g. in regression test
;;;
;;; Revision 1.15  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.14  2012/05/24 14:59:11  andan342
;;; Removed UB type, #[UB] value and UB() constructor, now using NIL instead
;;;
;;; Revision 1.13  2012/05/24 13:24:53  andan342
;;; Now always working with _amos-optional_ = T, removed that variable,
;;; Removed all notion of BOUND, SEMIBOUND, REBOUND, LINKED and MERGED variables from the translator
;;;
;;; Revision 1.12  2012/05/02 17:23:58  torer
;;; Can instruct SSDM to generate Amos queries with optional() by calling
;;; the Amos directive:
;;;
;;; amos_optional(true);
;;;
;;; Revision 1.11  2012/03/27 14:13:38  torer
;;; Added Python as persistent extension
;;;
;;; Revision 1.10  2012/02/23 19:15:38  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.9  2012/02/14 13:39:29  andan342
;;; Added support for blank node isolation when loading multiple sources into store
;;;
;;; Revision 1.8  2012/02/10 11:47:50  andan342
;;; All Amos functions implementing SciSPARQL functions now have/get rdf: namespace
;;;
;;; Revision 1.7  2012/02/08 16:18:15  andan342
;;; Now using READ-TOKEN-based SPARQL lexer in Turtle/NTriples reader,
;;; moved (returtle-amosfn ...) def to master.lsp
;;;
;;; Revision 1.6  2012/01/23 11:20:55  andan342
;;; Now compiling SSDM.DLL, and loading it as an extender
;;;
;;; Revision 1.5  2011/12/02 00:46:44  andan342
;;; - now using the complete (evaluating) parser in the toploop
;;; - made SparQL the default toploop language
;;; - not using any environment variables anywhere
;;;
;;; Revision 1.4  2011/12/01 14:26:43  torer
;;; Removed environment variables in file loading
;;;
;;; Revision 1.3  2011/07/06 16:19:22  andan342
;;; Added array transposition, projection and selection operations, changed printer and reader.
;;; Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
;;; Added Lisp testcases for this and one SparQL query with array variables
;;;
;;; Revision 1.2  2011/06/01 06:15:51  andan342
;;; Defined basic AmosQL functions to handle Numeric Multidimensional Arrays
;;;
;;; Revision 1.1  2011/05/29 00:01:41  andan342
;;; Added stub MS Visual Studion 6.0 project for SQoND storage extensions
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================


;;; The current directory should be %AMOS_HOME%/SQoND

(defvar _sq_storage_system_ :in-memory)

(defvar _sq_default_triples_fn_ "DEF()")

(defvar _sq_string_based_ nil)

(load-extension "ssdm" t)

(load "../../scsq/lsp/numarray.lsp")

(with-directory "src/SQoND/lsp/readers" 
		(load "turtle-reader.lsp"))

(setq _sq_emit_nmas_ t) ;; emit Turtle collections as arrays

(with-directory "src/SQoND/lsp"
		(load "sparql-wrapper.lsp"))

;;(with-directory "lsp" load "sparql-wrapper.lsp")

(defun sparql (str)
  (within-lisp
   (eval (with-textstream s str 
			  (parse-stream s "SPARQL")))))

(defun sparql-stream-eval (stream);;called from C
  (let ((tr (sparql-to-amosql stream)))
    (if (stringp tr)
	(parse tr);;translate string into s-expression, e.g. OSQL-SELECT call
      tr)));;symbols bypass further parsing

(defun print-sparql-result (qres stream);;called from C
  (print-amosql-result qres stream));;TODO: should be changed

;; Default in-memory triple store
(osql "
create function DEF() -> (Literal s, Literal p, Literal o);
create_index('def','s','hash','multiple');
create_index('def','p','hash','multiple');
create_index('def','o','hash','multiple');
")

;; Simple insert function, may be redefined by storage engines
(osql "
create function rdf:insert(Literal s, Literal p, Literal o) -> Boolean
  as add DEF() = (s,p,o);
")

;; Lookup function for blanks

(osql "
create function TermInDEF(URI x) -> Boolean
  as some(select x
            from Literal s, Literal p, Literal o
           where (s,p,o) in DEF()
             and ((s = x) or (p = x) or (o = x)));
")

(defun get-blank-in-DEF (x)
  (getfunction (car (getobject (getfunctionnamed 'TermInDEF) 'resolvents)) (list (URI x))))

(setq _sq_get_blank_ #'get-blank-in-DEF)

(osql "extlang('python');")

