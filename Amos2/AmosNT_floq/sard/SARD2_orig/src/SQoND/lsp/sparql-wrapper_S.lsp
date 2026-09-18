;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-wrapper_S.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:43 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SparQL processor (vector-based)
;;; =============================================================
;;; $Log: sparql-wrapper_S.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:43  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.13  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.12  2012/05/24 10:59:50  andan342
;;; Now translating SPARQL OPTIONAL to Amos optional() and SPARQL UNION to Amos 'or'
;;;
;;; Revision 1.11  2012/04/14 16:05:24  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.10  2012/03/27 14:02:19  andan342
;;; Made 'talk.sparql queries work
;;;
;;; Revision 1.9  2012/02/07 16:43:57  andan342
;;; - made SOURCE() work on files with language switches
;;; - changed internal language name and toploop prompt to "SPARQL"
;;;
;;; Revision 1.8  2012/02/03 16:00:56  andan342
;;; (sparql ...) now calls parse-stream
;;;
;;; Revision 1.7  2012/02/01 10:59:10  andan342
;;; Added BIND syntax from W3C SPARQL 1.1,
;;; made '.' optional between conditions in the block
;;;
;;; Revision 1.6  2012/01/25 18:13:23  torer
;;; indentation
;;;
;;; Revision 1.5  2012/01/24 15:12:20  andan342
;;; Sparql_translate(...) and (sparql-translate ...) functions added,
;;; minor bugs fixed
;;;
;;; Revision 1.4  2011/12/05 14:21:05  andan342
;;; Put all the wrapper code and Lisp functions interfaced from C into sparql-wrapper.lsp
;;; Added parse_sparql() and sparql() function in AmosQL, (SPARQL ...) macro in Lisp
;;;
;;; Revision 1.3  2011/12/02 00:46:45  andan342
;;; - now using the complete (evaluating) parser in the toploop
;;; - made SparQL the default toploop language
;;; - not using any environment variables anywhere
;;;
;;; Revision 1.2  2011/09/14 09:11:10  andan342
;;; Added DECLARE FUNCTION and DECLARE aggregate to SciSparQL, Python integration now supported
;;;
;;; Revision 1.1  2011/04/04 12:23:35  andan342
;;; Separated translator code from the parser code,
;;; added "SparQL tools"
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Depends on:
;;  _sq_string_based_

(with-directory (concat (getenv "AMOS_HOME") "SQoND/lsp/")
		(load "sparql-translator.lsp")
		(load "nma-fns.lsp"))

(defun sparql-translate (query ret-vectors)
  "Return AmosQL translation of SparQL query"
  (resetvar _sq_always_return_vectors_ ret-vectors
	    (with-textstream s query (sparql-to-amosql s))))
  
(foreign-lispfn sparql_translate 
		((Charstring query) (Boolean ret_vectors)) ((Charstring))
		(foreign-result (sparql-translate query 
						  (eq ret_vectors 'true))))

(osql "
create function sparql(Charstring sparql)->Vector
   as select evalv(sparql_translate(sparql,false));")

(foreign-lispfn add_prefix_if_empty ((Charstring prefix) (Charstring namespace)) ()
  (when (string= prefix "")
    (setq *session-prefixes* (merge-prefix-lists *session-prefixes* (list (cons "" namespace))))))


