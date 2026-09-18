;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-14 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-translator.lsp,v $
;;; $Revision: 1.71 $ $Date: 2014/01/10 11:25:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Translator functionality based on sparql-lsp-parser
;;; =============================================================
;;; $Log: sparql-translator.lsp,v $
;;; Revision 1.71  2014/01/10 11:25:45  andan342
;;; Added ARCHIVE queries from A-SPARQL using archive_content_schema() function
;;;
;;; Revision 1.70  2014/01/09 13:43:10  andan342
;;; Added DELETE/INSERT updates, as specified in http://www.w3.org/TR/2013/REC-sparql11-update-20130321/
;;;
;;; Revision 1.69  2013/12/20 14:48:23  andan342
;;; Supporting multiple stored graphs:
;;; - added GRAPH and FROM NAMED syntax
;;; - LOAD() and CLEAR() functions now take a graph URI as the last argument
;;; - default stored graph is now in GRAPH(0)
;;;
;;; Revision 1.68  2013/12/16 14:04:56  andan342
;;; Added subqueries, SELECT *, EXISTS, NOT EXISTS, ans ASK syntax
;;;
;;; Revision 1.67  2013/12/11 16:41:25  andan342
;;; Improved the translation of top-level-aggregate functions
;;;
;;; Revision 1.66  2013/12/09 19:54:14  andan342
;;; Further refined the translator code
;;;
;;; Revision 1.65  2013/12/09 17:37:41  andan342
;;; Second-order functions now support all valid kinds of functions with top-level aggregation,
;;; tranlator code is largely re-factored.
;;;
;;; Revision 1.64  2013/12/06 22:48:20  andan342
;;; Added support for cross-referencing of SELECT expressions,
;;; simplified the translation of aggregate expressions
;;;
;;; Revision 1.63  2013/11/29 17:05:46  andan342
;;; Added support for multiple aggregate function calls in the SELECT statement
;;;
;;; Revision 1.62  2013/11/25 16:20:16  andan342
;;; Fixed bug with using Typed RDF literals in queries
;;;
;;; Revision 1.61  2013/09/22 13:23:34  andan342
;;; Added IN and NOT IN operators
;;;
;;; Revision 1.60  2013/09/13 15:54:02  andan342
;;; Added _sq_strict_ flag, default NIL
;;;
;;; Revision 1.59  2013/09/07 19:06:03  andan342
;;; - added ENCODE_FOR_URI() function,
;;; - no special translation is now done for REGEX(),
;;; - n-ary CONCAT() is enabled
;;;
;;; Revision 1.58  2013/04/25 09:23:47  andan342
;;; Bug with matlab-python syntax switch fixed
;;;
;;; Revision 1.57  2013/02/21 23:34:45  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR,
;;; defined all SciSparql foreign functions as proxy-tolerant,
;;; updated the translator to enable truly lazy data retrieval
;;;
;;; Revision 1.56  2013/02/08 00:48:14  andan342
;;; Using C implementation of NMA-PROXY-RESOLVE, including (nma-proxy-enabled)
;;;
;;; Revision 1.55  2013/01/28 09:22:13  andan342
;;; Added MOD and DIV functions, cost hints, fixed bug when reading URIs with comma, TODO comments to improve error reporting
;;;
;;; Revision 1.54  2013/01/22 16:21:32  andan342
;;; Added (sparql-add-extender-engine ...) to add engines (and new ways to define foreign functions) at runtime
;;;
;;; Revision 1.53  2013/01/15 21:55:29  andan342
;;; Added more efficient and safe versions of ARGMIN and ARGMAX
;;;
;;; Revision 1.52  2013/01/10 12:19:34  andan342
;;; REGEX now handles both W3C standard and legacy (TopicMap) regular expression syntax
;;;
;;; Revision 1.51  2013/01/09 14:58:19  andan342
;;; Fixed bug with REGEX
;;;
;;; Revision 1.49  2012/10/18 11:01:08  andan342
;;; Fixed bug when translating !<funcall>
;;;
;;; Revision 1.48  2012/06/25 20:36:34  andan342
;;; Added TypedRDF and support for custom types in Turtle reader and SciSPARQL queries
;;; - rdf:toTypedRDF and rdf:strdf can be used as constructors in terms of RDF literals
;;; - rdf:str and rdf:datatype can be used as field accessors
;;;
;;; Revision 1.47  2012/06/15 16:14:39  andan342
;;; Added ARGMIN and ARGMAX second-order functions, brief and complete f(*) syntax for closures,
;;; all new variables now contain ':' to avoid conflicts with user variables,
;;; a mechanism introduced to generate new variables and conditions from inside expression translator.
;;;
;;; All intr
;;;
;;; Revision 1.46  2012/06/13 15:02:38  andan342
;;; Added translation-phase condition reordering and BIND-dependency tracing to choose uni-directional or optimizable tranlation of '=' filters and BIND assignments
;;;
;;; Revision 1.45  2012/06/11 15:24:34  andan342
;;; Keeping track of unbound variables used in equality filters, enforcing EQUAL-- to avoid false positives
;;;
;;; Revision 1.44  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.43  2012/05/26 11:45:38  andan342
;;; Introduced CONSTRUCT into the new version of the parser
;;;
;;; Revision 1.42  2012/05/24 14:41:26  andan342
;;; More simplifications, prepared to remove #[UB] value
;;;
;;; Revision 1.41  2012/05/24 13:24:53  andan342
;;; Now always working with _amos-optional_ = T, removed that variable,
;;; Removed all notion of BOUND, SEMIBOUND, REBOUND, LINKED and MERGED variables from the translator
;;;
;;; Revision 1.39  2012/05/20 13:23:05  andan342
;;; Not marking any variables as 'semibound' when translating OPTIONAL with _amos-optional_ = T
;;;
;;; Revision 1.38  2012/05/02 17:23:58  torer
;;; Can instruct SSDM to generate Amos queries with optional() by calling
;;; the Amos directive:
;;;
;;; amos_optional(true);
;;;
;;; Revision 1.37  2012/04/27 10:16:08  torer
;;; optional() -> optional0()
;;;
;;; Revision 1.36  2012/03/28 11:14:15  torer
;;; regression testing if (setq _regression_ t)
;;;
;;; Revision 1.35  2012/03/28 09:52:44  andan342
;;; Added generic aggregate functions (SUM, AVG, ...) to operate both on numbers and NMAs
;;;
;;; Revision 1.34  2012/03/27 21:07:49  andan342
;;; Made rdf:first and rdf:rest work both as triple patterns and function calls
;;;
;;; Revision 1.33  2012/03/27 14:02:19  andan342
;;; Made 'talk.sparql queries work
;;;
;;; Revision 1.32  2012/03/19 11:05:10  andan342
;;; NMA-PROXIES now accumulate ASUB operations, and are resolved automatically in expressions
;;;
;;; Revision 1.31  2012/02/23 19:15:39  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.30  2012/02/10 15:33:25  andan342
;;; Added rdf:isNumeric(), now correctly translating queries without variables
;;;
;;; Revision 1.29  2012/02/10 11:47:50  andan342
;;; All Amos functions implementing SciSPARQL functions now have/get rdf: namespace
;;;
;;; Revision 1.28  2012/02/09 10:54:58  andan342
;;; Replaced LABELS with FLET
;;;
;;; Revision 1.27  2012/02/08 16:18:15  andan342
;;; Now using READ-TOKEN-based SPARQL lexer in Turtle/NTriples reader,
;;; moved (returtle-amosfn ...) def to master.lsp
;;;
;;; Revision 1.26  2012/02/07 16:43:57  andan342
;;; - made SOURCE() work on files with language switches
;;; - changed internal language name and toploop prompt to "SPARQL"
;;;
;;; Revision 1.25  2012/02/02 22:52:36  andan342
;;; Enabled session-wide PREFIX statements,
;;; fixed bugs with:
;;; - 'total' aggregates in non-vectorized mode,
;;; - floating-point number reader,
;;; - default step for array projections in Python-syntax mode
;;;
;;; Revision 1.24  2012/02/01 10:59:10  andan342
;;; Added BIND syntax from W3C SPARQL 1.1,
;;; made '.' optional between conditions in the block
;;;
;;; Revision 1.23  2012/01/24 15:12:20  andan342
;;; Sparql_translate(...) and (sparql-translate ...) functions added,
;;; minor bugs fixed
;;;
;;; Revision 1.22  2012/01/20 14:29:17  andan342
;;; Fixed grammar and reader bugs
;;;
;;; Revision 1.21  2011/12/05 16:02:50  andan342
;;; Lexical and Syntax messages are now fast-forwarding the input stream until next ';' or *EOF*
;;;
;;; Revision 1.20  2011/12/05 14:21:05  andan342
;;; Put all the wrapper code and Lisp functions interfaced from C into sparql-wrapper.lsp
;;; Added parse_sparql() and sparql() function in AmosQL, (SPARQL ...) macro in Lisp
;;;
;;; Revision 1.19  2011/12/02 15:48:05  torer
;;; bugs
;;;
;;; Revision 1.18  2011/12/02 00:46:45  andan342
;;; - now using the complete (evaluating) parser in the toploop
;;; - made SparQL the default toploop language
;;; - not using any environment variables anywhere
;;;
;;; Revision 1.17  2011/12/01 11:52:07  andan342
;;; Switched to stream-based scanner and parser.
;;; ssdm -q SparQL calls Toploop with STUB functionality (translation only)
;;;
;;; Revision 1.16  2011/11/25 16:25:59  andan342
;;; Fixed grammar to make '.' an optional token after FILTER, OPTIONAL and UNION,
;;; Fixed bug with BOUND, and !BOUND expressions, added comments and doc-strings
;;;
;;; Revision 1.15  2011/11/18 15:36:28  andan342
;;; Registered SciSparQL parser in AFTER_ROLLIN hook. STUB reader and printer used in Toploop (no SciSparQL functionality available so far).
;;; SciSparQL Toploop is called with ssdm -q SciSparQL
;;;
;;; Revision 1.14  2011/10/23 14:43:54  andan342
;;; Now specifying array ranges in Python style, as controlled by
;;; (defvar _sq_python_ranges_ t)
;;;
;;; Revision 1.13  2011/10/23 12:13:40  andan342
;;; Using common fuctions defined in %AMOS_HOME%/lsp/grm/parse-utils
;;;
;;; Revision 1.12  2011/09/30 11:08:56  andan342
;;; Added SparQL views (CREATE FUNCTION ... AS SELECT ...)
;;;
;;; Revision 1.11  2011/09/14 09:11:09  andan342
;;; Added DECLARE FUNCTION and DECLARE aggregate to SciSparQL, Python integration now supported
;;;
;;; Revision 1.10  2011/08/11 10:36:26  andan342
;;; Added YeastPolarization app
;;; Now allowing extentions to register new aggregate functions
;;;
;;; Revision 1.9  2011/08/09 21:21:20  andan342
;;; Added new dereference-or-project functionality, AmosQL functions Aref and ASub to translate SciSparQL array expressions to
;;;
;;; Revision 1.8  2011/07/20 16:05:21  andan342
;;; Added Permute, Sub & Project array operations to SciSparql
;;; Added AmosQL testcases showing multidirectional array access
;;;
;;; Revision 1.7  2011/07/08 07:38:14  andan342
;;; Defined reneric nmaref() function for Literal type
;;;
;;; Revision 1.6  2011/07/07 12:56:47  andan342
;;; Added array dereference [i], projection [i,:] and subrange selection [i:s:j] syntax into SciSparQL grammar
;;;
;;; Revision 1.5  2011/05/24 10:37:11  andan342
;;; Now translating SparQL blank nodes as "non-distinguished variables", according to 4.1.3 in specs
;;;
;;; Revision 1.4  2011/05/05 08:53:49  andan342
;;; Now handling aggregates in compliance with W3C SparQL 1.1. recommendationds:
;;; http://www.w3.org/TR/2010/WD-sparql11-query-20101014/
;;;
;;; Revision 1.3  2011/05/01 19:42:23  andan342
;;; Ported predicates and arithmetics, added type predicates and typecasting
;;;
;;; Revision 1.2  2011/04/20 15:24:59  andan342
;;; Now handling RDF data as triples of Literal type
;;;
;;; Revision 1.1  2011/04/04 12:23:34  andan342
;;; Separated translator code from the parser code,
;;; added "SparQL tools"
;;;
;;; =============================================================

;; Depends on:
;;  _sq_string_based_

(defvar _sq_basetype_ (if _sq_string_based_ "Charstring " "Literal ")) ; should end with a space!

(unless (boundp 'lisp_reader_breaks)
  (load "sparql-stream-parser.lsp"))

(load "sparql-utils.lsp")

(load "uri-to-fn.lsp")

;;;;;;;;;;;;;;;;;;;;; PARAMETERS ;;;;;;;;;;;;;;;;;;;;;

; (defvar _sq_ub_ "UB()") 

(defvar _sq_python_ranges_ t)

(defvar _sq_strict_ nil)

(defvar *session-prefixes* '(("rdf" . "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
			     ("xsd" . "http://www.w3.org/2001/XMLSchema#")))

;;;;;;;;;;;;;;;;;;;;;; TRANSLATING EXPRESSIONS ;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-var-to-amosql (v substs)
  "Translate SparQL variable to AmosQL variable, using SUBSTS substitution list"
  (let ((subst (assoc v substs))) ;substitute variable names inside OPTIONAL conditions
    (if subst (second subst) v)))

(defun sparql-vars-to-amosql (vars ed)
  (mapcar (f/l (v) (sparql-var-to-amosql v (expr-data-substs ed))) vars))

(defun sparql-blank-to-amosql (term)
  "Create an AmosQL variable to denote a blank node of SparQL query"
  (selectq (car term)
	   (blank (concat "b:" (second term))) ; translate user blanks to 'b:'-prefixed variables
	   (genblank (concat "g:" (second term))) ; translate generated blanks to 'g:'-prefixed variables
	   ""))

(defun string-to-amosql (str)
  "Encase string either in single quotes (if no escapes are required) or in escaped double quotes"
  (if (string-pos str "'") 
      (with-string s0 (prin1 str s0)) ; contain string in \" .. \", use escapes inside
    (concat "'" str "'"))) ; contain string in ' .. ', don't use escapes

(defun sparql-ustr-to-amosql (args)
  "Create AmosQL constructor expression for a Unicode String with optional Language and Locale tags"
  (concat "USTR(" (string-to-amosql (first args)) (if (second args) (concat ", '" (second args) "'") "") ")"))

(defun sparql-datetime-to-amosql (dt) ;TODO: loss of microsecond precision, perhaps should use same parsing as in turtle reader
  "Translate SparQL datatime string to AmosQL notation"
  (concat "|" (substring 0 9 dt) "/" (substring 11 18 dt) "|")) ;TODO: ignoring timezones, due to lack of temporal arithmetics   

(defun sparql-expr-prec (e)
  "Amos root precedence of translated SparQL expression"
  (selectq (car e)
	   (or 1)
	   (and 2)
	   ((= != < > >= <=) 3)
;	   ((+ -) 4)
;	   ((* /) 5)
	   (u- 6) ;TODO: not?
	   7)) ; literals, variables, fncalls, arefs

(defun sparql-real-p (translated-uri)
  "Test whether URI string denotes an XMLS type compatible with AmosQL Real"
  (rdf-realtype-p (substring 5 (- (length translated-uri) 3) translated-uri)))

(defun sparql-string-p (translated-uri)
  "Test whether URI string denotes an XMLS type compatible with AmosQL Real"
  (member translated-uri '("URI('http://www.w3.org/2001/XMLSchema#string')"
			   "URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#langString')")))

(defglobal *rdf-tla-fns* (make-hash-table :test #'equal)) ; functions with rdf: prefix with top-level aggregation

(defun sparql-aggfn-p (fn)
  "Test whether FN function is registered as aggregate function"
  (member fn _sq_aggregate_fns_))

(defun amosql-expr-dec (s)
  "Decrement value of AmosQL expression S, given as string"
  (let ((n (read s)))
    (if (integerp n) (concat "" (1- n))
      (concat s "-1"))))

(defun sparql-arglist-to-amosql (args data resolve)
  "Translate expressions to AmosQL arglist"
  (strings-to-string (mapcar (f/l (arg) (sparql-expr-to-amosql arg data 0 resolve)) args) "" ", " ""))

(defun sparql-make-newvar (data prefix)
  "Create a new variable prefixed with PREFIX, unique to NEWVARS"
  (let ((i 1) res)
    (loop
      (setq res (concat prefix ":" (mkstring i)))
      (if (member res (expr-data-newvars data)) (incf i) (return t)))
    (push res (expr-data-newvars data))
    res))

(defun sparql-closure-to-amosql (e data suffix)
  "Translate closure E, return (<translation> . <newvars>), add newvars to DATA, ignore possible TLAs"
  (let* (newvars
	 (tr (concat "rdf:" (cdar e) suffix "(" 
		     (strings-to-string (mapcar (f/l (arg) (if (eq (car arg) 'asterisk)	
							       (let ((newvar (sparql-make-newvar data "arg")))
								 (add-subst data (list newvar) "i")
								 (push newvar newvars)
								 (sparql-var-to-amosql newvar (expr-data-substs data)))
							     (sparql-expr-to-amosql arg data 0 (member (cdar e) _sq_proxy_intolerant_fns_))))
						(cdr e)) "" ", " "") ")")))
    (cons tr (nreverse newvars))))

(defun sparql-expr-can-be-proxy (e data)
  "Determines whether E can have a proxy as result"
  (or (and (eq (car e) 'aref) (sparql-expr-can-be-proxy (second e) data))  ; recursive if dereferencing an array
      (and (eq (car e) 'var) (not (member (cdr e) (expr-data-free data)))) ; T for non-free variables
      (and (listp (car e)) (eq (caar e) 'id) ; T for functions
	   (not (gethash (cdar e) *rdf-tla-fns*)) ; except ones with top-level aggregate
	   (not (member (cdar e) _sq_literal_fns_))))) ; and built-in

(defun sparql-resource-to-string (e data)
  "Translate URI expr to its string, recombine PREFIXED expr"
  (selectq (car e)
	   (prefixed (concat (cdr (or (assoc (second e) (expr-data-prefixes data))
				      (assoc (second e) *session-prefixes*))) (third e)))
	   (uri (second e))
	   nil))

(defun sparql-expr-to-amosql (e data base-prec resolve)
  "Translate expression E using EXPR-DATA fields: PREFIXES for URIs and SUBSTS substitutions for variables,
   put it into parentheses if its precedence is less than BASE-PREC,
   unless EXPR-DATA-BOUND is T, refer to it as a set of bound variables when translating '=' "
  (let ((prec (sparql-expr-prec e)) tla res)
    (setq res		      
	  (cond ((atom (car e))
		 (selectq (car e)
			  ((true false) (let ((res1 (string-downcase (mkstring (car e)))))
					  (if _sq_string_based_ (concat "'" res1 "'") res1))) ;MAYBE: upcase
			  (var (sparql-var-to-amosql (cdr e) (expr-data-substs data)))
			  (named (sparql-expr-to-amosql (third e) data base-prec resolve))
			  ((blank genblank) (sparql-blank-to-amosql e))
			  (prefixed (sparql-expr-to-amosql (list 'uri (sparql-resource-to-string e data)) data 0 nil))			  
			  (= ;PROXY: should resolve both if any 'might be' resolved

; (if (and (not (eq (expr-data-bound data) t)) ; whenever BOUND is specified
;				      (or (set-difference-equal (collect-expr-vars (second e) nil nil) (expr-data-bound data)) ; and a used variable is not in CUR-BOUND
;					  (set-difference-equal (collect-expr-vars (third e) nil nil) (expr-data-bound data))))
;				 (concat "rdf:equal(" (sparql-expr-to-amosql (second e) data 0) ; enforce EQUAL--
;					 "," (sparql-expr-to-amosql (third e) data 0) ")")
			   (concat (sparql-expr-to-amosql (second e) data prec nil) " = " ; otherwise allow the optimizer use other binding patterns
				   (sparql-expr-to-amosql (third e) data prec nil))) ; )
			  ((and or) 
			   (concat (sparql-expr-to-amosql (second e) data prec nil) " " (string-downcase (mkstring (car e))) " "
				   (sparql-expr-to-amosql (third e) data prec nil)))
			  (in ;PROXY: should resolve all if any 'might be' resolved
			   (concat (sparql-expr-to-amosql (second e) data 0 nil) " in {"
				   (sparql-arglist-to-amosql (third e) data nil) "}"))
			  ((< > <= >= !=)
			   (let* ((arg1 (sparql-expr-to-amosql (second e) data 0 t)) ;apr(x) < apr(y) and comparable(apr(x), apr(y))
				  (arg2 (sparql-expr-to-amosql (third e) data 0 t))
				  (res1 (concat arg1 (mkstring (car e)) arg2)))
			     (if (or _sq_string_based_ (not _sq_strict_)) res1 ; always comparable in string mode, only check if _sq_strict_
			       (progn
				 (setq prec (sparql-expr-prec '(and))) ; precedence value for AND
				 (concat res1 " and comparable(" arg1 ", " arg2 ")")))))
			  (not (let ((opposite-op (cdr (assoc (caadr e) '((= . !=) (< . >=) (> . <=) (true . false) 
									  (!= . =) (>= . <) (<= . >) (false . true)
									  ((id . "bound") . (id . "notbound"))
									  ((id . "notbound") . (id . "bound")))))))
				 ;;since there is no 'not' in Amos, do rewrites:
				 (cond (opposite-op (sparql-expr-to-amosql (cons opposite-op (cdadr e)) data base-prec nil))
				       ((or (member (caadr e) '(+ - * / u-)) 
					    (and (not _sq_string_based_) (eq (caadr e) 'number))) ; not(number) -> number = 0
					(sparql-expr-to-amosql (list '= (cadr e) '(number . 0)) data base-prec nil))
				       ((eq (caadr e) 'in) (concat "notany(" (sparql-expr-to-amosql (cadr e) data 0 nil) ")"))
				       ((or (eq (caadr e) 'var) (listp (caadr e))) ; use notany for variables and funcalls
					(let* ((v (if (listp (caadr e)) (sparql-make-newvar data "n") ; translating !<funcall>
						    (sparql-var-to-amosql (cdadr e) (expr-data-substs data)))) ; translating !<var>
					       (res1 (concat "notany(" v ")")))
					  (when (listp (caadr e)) ; translating !<funcall>
					    (push (concat v " = " (sparql-expr-to-amosql (cadr e) data 0 nil))
						  (expr-data-newconds data)))
					  (if _sq_string_based_ res1
					    (progn							      
					      (setq prec (sparql-expr-prec '(or))) ; precedence value for OR
					      (concat res1 " or (" v " = 0) or (" v " = USTR(''))")))))
				       (t "false")))) ;;the case for URIs and strings
			  (asterisk (error "Unexpected closure: * can't be outside a call to ARGMIN or ARGMAX")) ; translate closure expressions with a different function
			  ;TODO: can be misleading if the enclosed function is undefined
			  (if _sq_string_based_
			      (selectq (car e)
				       ((uri ustr number typed) ;MAYBE: add < > for URI
					(concat "'" (second e) "'")) ; translate these values to strings in the query, ignore language & type
				       (error "Arithmetic and array expressions are not supported in string-based version!"))
			    (selectq (car e)
				     (uri (concat "URI('" (second e) "')"))
				     (ustr (sparql-ustr-to-amosql (cdr e)))
				     (typed (let ((type-uri (sparql-expr-to-amosql (fourth e) data 0 nil)))
					      (cond ((or (string= type-uri "URI('http://www.w3.org/2001/XMLSchema#integer')")
							 (sparql-real-p type-uri))
						     (unless (numberp (read (second e)))
						       (error (concat "Invalid numeric literal: " (second e))))
						     (second e)) ; use same string representation of a number
						    ((sparql-string-p type-uri)
						     (sparql-ustr-to-amosql (list (second e))))
						    ((string= type-uri "URI('http://www.w3.org/2001/XMLSchema#dateTime')")
						     (sparql-datetime-to-amosql (second e))) ; convert xsd:dateTime to Timeval literal
						    ((string= type-uri "URI('http://www.w3.org/2001/XMLSchema#boolean')")
						     (unless (member (string-downcase (second e)) '("true" "false"))
						       (error (concat "Invalid boolean literal: " (second e))))
						     (second e))
						    (t (concat "TypedRDF(" (string-to-amosql (second e)) ", " type-uri ")")))))
				     ((+ - * /)
				      (concat "rdf:" (selectq (car e) (+ "plus") (- "minus") (* "times") "div") 
					      "(" (sparql-arglist-to-amosql (cdr e) data t) ")")) ; rdf:plus(apr(x), apr(y))	
				     (u- (concat "-" (sparql-expr-to-amosql (second e) data prec t))) ; -apr(x)
				     (aref (let ((res (sparql-expr-to-amosql (cadr e) data -1 nil)) (k 0))
					     (dolist (subscript (cddr e))
					       (if (member (car subscript) '(range0 range2 range3))
						   (let ((rt (mapcar (f/l (re) (sparql-expr-to-amosql re data 0 nil)) 
								     (cdr subscript)))) ; translated range expressions
						     (selectq (car subscript)
							      (range2 (setq res (concat "asub(" res "," k "," (first rt) ",1," 
											(if _sq_python_ranges_ (second rt) (amosql-expr-dec (second rt))) ")")))
							      (range3 (setq res (concat "asub(" res "," k 
											(strings-to-string 
											 (if _sq_python_ranges_ ; swap HI and STEP
											     (list (first rt) 
												   (if (string= (third rt) "-1") "1" (third rt)) 
												   (amosql-expr-dec (second rt))) ; ^ no negative steps
											   rt) "," "" "") ")")))
							      t) (incf k))
						 (setq res (concat "aref(" res "," k "," (let ((st (sparql-expr-to-amosql subscript data 0 nil)))
											   (if _sq_python_ranges_ st (amosql-expr-dec st))) ")"))))
;TODO: should instead put apr() in front of proxy-intolerant operations (like +, mod) or on top level of SELECT queries
;					     (when (and (nma-proxy-enabled) (>= base-prec 0)) ; if nma-proxies are enabled and immediate outer operator is not aref
;					       (setq res (concat "apr(" res ")"))) ; add a call to nma-proxy-resolve
					     res))
				     (second e))))) ; expect direct Amos representation in other cases (e.g. numbers)
		((listp (car e)) ; FNCALL or TYPECAST
		 (selectq (caar e)
			  (id ; FNCALL translation
			   (cond ((and (string= (cdar e) "concat") (> (length e) 3)) ; CONCAT
				  (sparql-expr-to-amosql (list (car e) (cadr e) (cons (car e) (cddr e))) data 0 resolve))
				 ((and (not _sq_string_based_) (string= (cdar e) "permute"))  ; PERMUTE
					; permute translation: put the arguments except the first one into an amos vector
				  (let ((args (mapcar (f/l (arg) (sparql-expr-to-amosql arg data 0 nil)) (cdr e))))
				    (concat "rdf:permute(" (car args) ",{" (strings-to-string (cdr args) "" "," "") "})")))
				 ; translating 2nd-order-function calls: ARGMIN, ARGMAX
				 ((member (cdar e) '("argmin" "argmax"))
				  (unless (and (null (cddr e)) (listp (car (second e))) (eq (caar (second e)) 'id))
				    (error (concat (string-upcase (cdar e)) " requires a unary closure as a single parameter!")))
				  (let* ((inner-ed (clone-expr-data data))
					 (tla (gethash (cdar (second e)) *rdf-tla-fns*))
					 (closure-itr (sparql-closure-to-amosql (second e) inner-ed (if tla ":inner" ""))) ; translate closure
					 (inner-tr (concat (sparql-var-to-amosql (second closure-itr) (expr-data-substs inner-ed)) ", " (first closure-itr) 
							   " from " (strings-to-string (sparql-vars-to-amosql (expr-data-newvars inner-ed) inner-ed) _sq_basetype_ ", " "")
							   (if (expr-data-newconds inner-ed) 
							       (concat " where " (strings-to-string (expr-data-newconds inner-ed) "" " and " "")) "")))) ;TODO: offset!
				    (concat "rdf:" (cdar e) "("
					    (if tla (sparql-tla-to-amosql inner-tr (cons (cons 'var (second closure-itr)) (tla-data-exprs tla)) (tla-data-aggs tla)
									  (list (second closure-itr)) (clone-expr-data data) 18 nil nil) ;TODO: offset!
					      (concat "select " inner-tr)) ")")))
				 ; not translating aggregate functions
				 ((sparql-aggfn-p (cdar e)) "") 
				 ; translating all other functions
				 (t (setq res (concat "rdf:" (cdar e) "(" (sparql-arglist-to-amosql (cdr e) data ; default fncall translation
												    (member (cdar e) _sq_proxy_intolerant_fns_)) ")")) 
				    res)))
;				    (let ((tla (gethash (cdar e) *rdf-tla-fns*)))
;				      (if tla (sparql-tla-to-amosql res (tla-data-exprs tla) (tla-data-aggs tla) nil (clone-expr-data data) 0 nil t) res))))) ;TODO: offset!
											
;				    (if (setq tla (gethash (cdar e) *rdf-tla-fns*)) ; if a function contains top-level aggregation
;					(concat tla "(" res ")") res)))) ; wrap it around this fncall
			  ((uri prefixed) (let ((fn-uri (sparql-expr-to-amosql (car e) data 0 nil)) ; TYPECAST translation
						(arg (sparql-expr-to-amosql (second e) data 0 nil)))
					    (cond (_sq_string_based_ ; ignore all typecasting operations in string mode
						   (setq prec (sparql-expr-prec (second e)))
						   arg)
						  ((sparql-string-p fn-uri) (concat "rdf:str(" arg ")"))
						  ((string= fn-uri "URI('http://www.w3.org/2001/XMLSchema#dateTime')") (concat "rdf:toDateTime(" arg ")"))
						  ((string= fn-uri "URI('http://www.w3.org/2001/XMLSchema#boolean')") (concat "rdf:toBoolean(" arg ")"))
						  ((string= fn-uri "URI('http://www.w3.org/2001/XMLSchema#integer')") (concat "rdf:toInteger(" arg ")"))
						  ((sparql-real-p fn-uri) (concat "rdf:toDouble(" arg ")"))
						  (t (error (concat "Unknown type to cast to: " (substring 5 (- (length fn-uri) 3) fn-uri)))))))
			  ""))))
;    (print (list 'e= e 'resolve= resolve 'res= res)) ;DEBUG
    (cond ((and resolve (nma-proxy-enabled) (sparql-expr-can-be-proxy e data))
	   (concat "apr(" res ")"))
	  ((> base-prec prec) 
	   (concat "(" res ")"))
	  (t res))))

;;;;;;;;;;;;;;;;;;;; PREPROCESSING ;;;;;;;;;;;;;;;;;;;;;;;;

(defun nswap (l)
  "Swap first and second elements of the given list"
  (let ((elt2 (second l)))
    (rplaca (cdr l) (car l))
    (rplaca l elt2)
    l))

(defun reorder-sparql-conds (cs)
  "Reorder conds list to (TRIPLES|UNION)* BIND* FILTER* sections, never move across OPTIONAL
   Should be run multiple times until NIL is returned"  
  (cond ((null (cdr cs)) nil) ; return NIL - nothing to swap
	((or (and (eq (caar cs) 'filter) (member (caadr cs) '(triples union bind)))
	     (and (eq (caar cs) 'bind) (member (caadr cs) '(triples union))))
	 (nswap cs) 
	 t) ; run again from beginning of C
	(t (reorder-sparql-conds (cdr cs))))) ; recursive

(defun sparql-bind-to-bindseq (cs)
  "Group an unbroken sequence of BIND conditions into BINDSEQ"
  (cond ((null cs) nil)
	((eq (caar cs) 'bind)
	 (let ((cs1 cs) seq)
	   (while (eq (caar cs1) 'bind)
	     (push (list (second (car cs1)) nil (third (car cs1))) seq)
	     (setq cs1 (cdr cs1)))
	   (cons (cons 'bindseq (nreverse seq)) (sparql-bind-to-bindseq cs1)))) ;recursive
	(t (cons (car cs) (sparql-bind-to-bindseq (cdr cs)))))) ;recursive

(defun sparql-resolve-bind (bind-stack bindseq b)
  "If all variables in BIND expression are in BOUND+ or are recursively bound,
   mark this BIND as 'resolved' and add BIND variable to BOUND+"
  (if (second (car bind-stack)) t ; don't do anything if BIND is already resolved
    (let ((ref (collect-expr-vars (third (car bind-stack)) nil nil))
	  unboundvars)
      (setf (block-ref* b) (union-equal (block-ref* b) ref)) ; update REF* set of the block
      (setq unboundvars (set-difference-equal ref (block-bound+ b)))
      (when unboundvars ; if any variables in BIND expression are not bound
	(dolist (bind1 bindseq) ; check if another BIND from this BINDSEQ
	  (when (and (member (first bind1) unboundvars) ; binds an unbound variable
		     (not (member bind1 bind-stack)) ; while not in the stack (cycle prevention)
		     (sparql-resolve-bind (cons bind1 bind-stack) bindseq b)) ; and is recursively resolved
	    (setq unboundvars (remove (first bind1) unboundvars))))) ; count that variable as bound
      (unless unboundvars ; if all variables in expression are bound
	(pushnew-equal (first (car bind-stack)) (block-bound+ b)) ; add bound variable to BOUND+ set of the block 
	(setf (second (car bind-stack)) t) ; mark this BIND as resolved
	t)))) ; and return T (otherwise NIL)	   
	  
(defun sparql-block-preprocess (b par ed)
  "Preprocess block B given the query parameters PAR"
  (loop (unless (reorder-sparql-conds (block-conds b)) ; reorder conditions
	  (return t)))
  (setf (block-conds b) (sparql-bind-to-bindseq (block-conds b))) ; group BIND into BINDSEQ
  (setf (block-bound+ b) par)
  (dolist (c (block-conds b))      
    (selectq (car c)
	     (triples (dolist (triple (cdr c))
			(dolist (term triple)
			  (selectq (car term)
				   (var (pushnew-equal (cdr term) (block-bound+ b))
					(pushnew-equal (cdr term) (block-ref* b))
					)
				   ((blank genblank) 
				    (pushnew-equal (sparql-blank-to-amosql term) (block-blanks b)))
				   t))))
	     (filter (setf (block-ref* b) (collect-expr-vars (cdr c) (block-ref* b) nil))) 
	     (bindseq (dolist (bind (cdr c)) ;TODO: might want to use the BOUND+ variables from the following TRIPLES, BIND, and UNION conditions
			(sparql-resolve-bind (list bind) (cdr c) b))) 
	     (optional (sparql-block-preprocess (cdr c) par nil) ; recursive
		       (setf (block-ref* b) (union-equal (block-ref* b) (block-ref* (cdr c))))
		       (setf (block-partial b) (union-equal (block-partial b) (block-partial (cdr c)))))
	     (union (let (bound-in-union)
		      (dolist (u (cdr c))
			(sparql-block-preprocess u par nil) ; recursive
			(if (eq u (second c)) (setq bound-in-union (block-bound+ u))
			  (setq bound-in-union (intersection-equal bound-in-union (block-bound+ u))))
			(setf (block-ref* b) (union-equal (block-ref* b) (block-ref* u)))
			(setf (block-partial b) (union-equal (block-partial b) (block-partial u))))
		      (setf (block-bound+ b) (union-equal (block-bound+ b) bound-in-union))))
	     (graph-block (sparql-block-preprocess (third c) par nil)
			  (setf (block-ref* b) (union-equal (block-ref* b) (block-ref* (third c))))
			  (setf (block-bound+ b) (union-equal (block-bound+ b) (block-bound+ (third c))))
			  (setf (block-partial b) (union-equal (block-partial b) (block-partial (third c))))
			  (when (eq (car (second c)) 'var) 
			    (pushnew-equal (cdr (second c)) (block-ref* b))))
	     t)) 
  (setf (block-partial b) (union-equal (block-partial b) (block-bound+ b))) ; count all bound+ variables also as partial
  ;; Update Expression Data
  (when ed
    (setf (expr-data-bound ed) (union-equal (block-bound+ b) (expr-data-bound ed))) ; treating all bound+ variables as bound,
    (setf (expr-data-ref ed) (union-equal (block-ref* b) (expr-data-ref ed))) ; all ref* variables as referenced,
    (setf (expr-data-free ed) (set-difference-equal (set-difference-equal (expr-data-ref ed) (expr-data-bound ed)) 
						    (block-partial b)))) ; free variables are disjoint from partial    
  b)

(defun sparql-triples-vars (triples buf)
  "collect variables from triple patterns in BUF"
  (dolist (triple triples buf)
    (dolist (term triple)
      (when (and (eq (car term) 'var))
	(pushnew-equal (cdr term) buf)))))

;; Preprocessing aggregate queries

(defun collect-expr-vars (e buf ignore)
  "collect variable names from expression E in BUF, ignoring variables in IGNORE"
  (cond ((and (consp e) (eq (car e) 'var) (not (member (cdr e) ignore)))
	 (pushnew-equal (cdr e) buf))
	((listp (cdr e)) ;; process subexpressions recursively
	 (dolist (sub-e (cdr e)) 
	   (when (consp sub-e) (setq buf (collect-expr-vars sub-e buf ignore)))))) ; recursive 
  buf)

;;;;;;;;;;;;;;;;;;;;; MANAGING PREFIXES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun merge-prefix-lists (bottom top)
  "Combine two prefix lists"
  (let ((res (if top (copy-tree bottom) bottom)) bpref)
    (dolist (tpref top res)
      (setq bpref (assoc (car tpref) res))
      (if bpref (setf (cdr bpref) (cdr tpref))
	(push tpref res)))))

;;;;;;;;;;;;;;;;;;;;; MANAGING SUBSTITUTION LISTS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   	    
(defun extend-substs (substs vars modifier) ;TODO: Not used!
  "Modify variable names with suffix ':' and either 'i','u' or 'o' modifier, remove trailing 'i' when adding 'o'"
  (let ((res (if vars (copy-tree substs) substs)) ac) 
    (dolist (v vars)
      (setq ac (assoc v res)) 
      (if ac (setf (cdr ac) (if (string= modifier "o") (list (concat (string-right-trim "iu" (second ac)) "o")) 
			      (cons (concat (second ac) modifier) (cdr ac))))
	(push (list v (concat v ":" modifier)) res)))
    res))

(defun noverride-substs (substs vars modifier) ;TODO: Not used!
  "Override last modifier of variables with the given one"
  (let (ac)
    (dolist (v vars)
      (setq ac (assoc v substs))
      (setf (cadr ac) (concat (substring 0 (- (length (cadr ac)) 2) (cadr ac)) modifier)))
    substs))

(defun nmerge-substs (base-substs top-substs) ;TODO: Not used!
  "Add the TOP-substs on top of BASE-SUBSTS"
  (let (base-ac)
    (dolist (top-ac top-substs)
      (setq base-ac (assoc (car top-ac) base-substs))
      (if base-ac (dolist (top-i (cdr top-ac))
		    (pushnew-equal top-i (cdr base-ac)))
	(setf base-substs (cons top-ac base-substs))))
    base-substs))

;;;;;;;;;;;;;;;;;;;;; EXTENSIBLE EXTENSIBILITY ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *sparql-extender-engines* nil) ; registry of different ways to define foreign functions

(defun sparql-add-extender-engine (engine-name definition-translator)
  (push (cons engine-name definition-translator) *sparql-extender-engines*))

(sparql-add-extender-engine "python"
			    (f/l (foreign-name arg-names) 
				 (concat  "foreign 'py:" foreign-name "'"))) 

;;;;;;;;;;;;;;;;;;;;; TRANSLATING BLOCKS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   	    
(defun sparql-to-amosql (stream)
  "Translate SparQL statement to AmosQL statement"
  (let* ((pq (sparql-parse stream))
	 (ed (make-expr-data :prefixes (first pq)))
	 (stat (second pq)))
    (cond ((listp stat)
	   (selectq (car stat)
		    (nil '*eof*)
		    (quit "quit;")
		    (lisp 'language-lisp) 
		    (call (setf (expr-data-bound ed) t) ;;Top-level function call
			  (let ((tr (concat "select " (sparql-expr-to-amosql (cdr stat) ed 0 nil)))) ; translate w/o apr()
			    (when (expr-data-newvars ed)
			      (setq tr (concat tr (nl 2) "from " 
					       (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v nil))
									  (expr-data-newvars ed)) _sq_basetype_ ", " ""))))
			    (when (expr-data-newconds ed) ;ASSERT: all NEWCONDS are translated
			      (setq tr (concat tr (nl 1) "where " 
					       (strings-to-string (expr-data-newconds ed) "" (concat (nl 3) "and ") ""))))
			    (concat tr ";")))
		    (prefix (setq *session-prefixes* (merge-prefix-lists *session-prefixes* (list (cdr stat)))) "")
		    ""))
	  ((sparql-stat-p stat) ;;SELECT/CONSTRUCT/ASK queries
	   (selectq (sparql-stat-type stat)
		    (select (concat (sparql-select-to-amosql stat nil '(top) ed) ";"))
		    (construct (concat (sparql-construct-to-amosql stat ed 0) ";"))
		    (ask (concat "select " (sparql-block-to-amosql (sparql-stat-what stat) nil nil nil ed 
								   (uri-to-amos-function (sparql-stat-from stat)) nil 0) 
				 ";"))
		    ""))	
	  ((sparql-update-p stat) ;;DELETE/INSERT updates
	   (sparql-update-to-amosql stat ed))
	  ((sparql-archive-p stat) ;;ARCHIVE statements
	   (sparql-archive-to-amosql stat ed))
	  ((define-stat-p stat) ;;DEFINE FUNCTION/AGGREGATE
	   (let ((header1 (concat "create function rdf:" (define-stat-name stat) )) ; 1. prepare headers
		 (header2 (concat "(" (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v nil)) 
								 (define-stat-vars stat)) 
							 (if (define-stat-agg stat) (concat "Bag of " _sq_basetype_) 
							   _sq_basetype_) ", " "") ") -> Bag of " ))
		 definition-translator)
	     (when (define-stat-agg stat) ; 2. register in _sq_aggregate_fns_ if defining an aggregate fn
	       (pushnew-equal (define-stat-name stat) _sq_aggregate_fns_))
	     (setf (expr-data-bound ed) (define-stat-vars stat)) ; 3. all parameters are treated as bound
	     (if (eq (car (define-stat-body stat)) 'sparql) ; 4.1. functional view definition
		 (let* ((body-tr (sparql-select-to-amosql (cadr (define-stat-body stat)) (define-stat-vars stat) 
							  (cons 'fn (define-stat-name stat)) ed))
			(tla-data (gethash (define-stat-name stat) *rdf-tla-fns*))
			(res-width (if tla-data (length (tla-data-aggs tla-data)) 1))
			(res-tr (strings-to-string (buildn res-width (string-right-trim " " _sq_basetype_)) "" ", " ""))
			tr)
		   (when (> res-width 1) (setq res-tr (concat "(" res-tr ")")))
		   ; 4.1a. make flat/inner definition
		   (setq tr (concat header1 (if tla-data ":inner" "") header2 res-tr (nl 2) "as " body-tr ";")) 
		   (if tla-data (concat tr (nl 0) header1 header2 _sq_basetype_ (nl 2) "as " ; 4.1b. add outer definition
					(sparql-stat-to-amosql (second (define-stat-body stat)) (define-stat-vars stat) 
							       (cons 'outer-fn (define-stat-name stat)) ed 0) ";")
		     tr))
	       (progn ; 4.2. foreign function definition
		 (setq definition-translator (cdr (assoc (car (define-stat-body stat)) *sparql-extender-engines*)))
		 (concat header1 header2 _sq_basetype_ (nl 2) "as "
			 (if definition-translator 
			     (funcall definition-translator (cadr (define-stat-body stat)) (define-stat-vars stat))
			   (concat "foreign '" (cadr (define-stat-body stat)) "'")) ";"))))) ; default case for LISP and C
	  (t ""))))

(defun sparql-aggfn-call-p (e)
  "Check if the expression E is a call to an aggregate function"
  (and (consp e) (consp (car e))
       (eq (caar e) 'id)
       (sparql-aggfn-p (cdar e))))

(defun sparql-expr-lookup (e named-list)
  "Look up expression E in a list of NAMED expressions, return naming var if found"
  (dolist (named-e named-list)
    (when (equal e (third named-e)) 
      (return (second named-e)))))

(defun sparql-expr-collect-named-aggfn (e stat)
  "Add NAMED aggregate call expression to the list of aggragate expressions, if new"
  (when (and (listp e) (eq (car e) 'named) (sparql-aggfn-call-p (third e))
	     (not (sparql-expr-lookup (third e) (sparql-stat-agg-expr stat))))
    (push e (sparql-stat-agg-expr stat))))


(defun sparql-expr-rewrite (e stat ed named-vars)
  "Recursively rewrite any agregate call expressions to VAR expressions,
   add new aggregate expressions to the list of aggregate expresions
   add all other referenced variables to GROUPBY list"
  (cond ((sparql-aggfn-call-p e) ; rewrite aggregate calls
	 (let ((varname (sparql-expr-lookup e (sparql-stat-agg-expr stat))))
	   (unless varname ; (create new NAMED expressions in AGG-EXPR if required)
	     (setq varname (sparql-make-newvar ed "agg"))
	     (push (list 'named varname e) (sparql-stat-agg-expr stat)))
	   (cons 'var varname))) ; with VAR
	((and (consp e) (eq (car e) 'var)) ; add variables outside aggregate calls
	 (pushnew-equal (cdr e) (expr-data-ref ed)) ;TODO: named-vars were excluded for some reason!
	 (if (member (cdr e) named-vars) ; to list of cross-referenced select variables (not the names of aggregate calls)
	     (pushnew-equal (cdr e) (sparql-stat-ext-ref stat))
	   (pushnew-equal (cdr e) (sparql-stat-groupby stat))) ; or to GROUPBY list (not used if not an aggregate query)
	 e)
	((and (consp e) (listp (cdr e))) ; recursively rewrite all other expressions
	 (cons (car e) (mapcar (f/l (a) (sparql-expr-rewrite a stat ed named-vars)) (cdr e))))
	(t e)))


(defun sparql-named-rewrite-cross-ref (e stat all)
  "If NAMED names a variable that is found in EXT-REF, add BIND to EXT-COND, rewrite to VAR"
  (if (and (listp e) (eq (car e) 'named) ; look for NAMED expresions
	   (or all (member (second e) (sparql-stat-ext-ref stat))) ; all or those defining vars in EXT-REF 
	   (not (and (consp (third e)) (eq (car (third e)) 'var) (string= (cdr (third e)) (second e))))) ; > 1 variable
      (progn
	(push (cons 'bind (cdr e)) (sparql-stat-ext-cond stat))
	(cons 'var (second e)))
    e))

(defun sparql-select-to-amosql (stat params target ed)
  "Do SELECT-specific preprocessing and translate SPARQL-STAT to a SELECT query to AmosQL"
  (let (named-vars)
    (unless (eq (sparql-stat-what stat) 'asterisk)
      ; WHAT pass 0: collect named-vars
      (dolist (e (sparql-stat-what stat)) 
	(when (and (listp e) (eq (car e) 'named))
	  (push (second e) named-vars)))
      ; WHAT pass 1: collect variables, put named aggregates to AGG-EXPR in order of appearance
      (dolist (e (reverse (sparql-stat-what stat)))  
	(sparql-expr-collect-named-aggfn e stat))
      ; WHAT pass 2: rewrite aggregate calls to variables, add other variables to GROUPBY or EXT-REF
      (setf (sparql-stat-what stat) 
	    (mapcar (f/l (e) (sparql-expr-rewrite e stat ed named-vars))
		    (sparql-stat-what stat)))
      (setf (sparql-stat-having stat) ; same with HAVING
	    (sparql-expr-rewrite (sparql-stat-having stat) stat ed named-vars))
      ; WHAT pass 3: rewrite cross-referenced named expressions into extra BIND conds	  
      (setf (sparql-stat-what stat) 
	    (mapcar (f/l (e) (sparql-named-rewrite-cross-ref e stat (eq (car target) 'sub)))
		    (sparql-stat-what stat))))
    (unless (sparql-stat-where stat)
      (setf (sparql-stat-where stat) (make-block)))
    (when (sparql-stat-ext-ref stat) ;TODO: EXT-REF and EXT-CONDS might not be used elsewhere!
      (setf (expr-data-newvars ed) (union-equal (expr-data-newvars ed) (sparql-stat-ext-ref stat)))
      (setf (expr-data-newconds ed) (append (expr-data-newconds ed) (sparql-stat-ext-cond stat))))
    (when (sparql-stat-having stat)
      (push (list 'filter (sparql-stat-having stat)) (expr-data-newconds ed)))
    (sparql-stat-to-amosql stat params target ed 0))) ; translate SELECT query ;TODO: offset!

(defun sparql-block-subblocks (b) ;TODO: Not used!
  "List the subblocks of a SparQL query block B, i.e. OPTIONAL and UNION branches"
  (let (res)
    (dolist (c (block-conds b))
      (selectq (car c)
	       (optional (push (cdr c) res))
	       (union (dolist (u (cdr c))
			(setq res (append (sparql-block-subblocks u) res)))) ; recursive
	       t)) res))

(defun sparql-aggfn-to-amosql (aggfn) ;;TODO: aggregates should correctly handle any RDF terms
  "Translate SciSparQL aggregate function names to AmosQL equivalents"
  (cond ((string= aggfn "count") aggfn)
	(t (concat "rdf:" aggfn))))

(defun sparql-block-to-amosql (b select-group select params ed triples-fn resolve offset)
  "Translate sparql block to Amos query, selecting SELECT-GROUP variables grouped into vector and SELECT expressions,
   use expression context ED (should contain any NEWVARS from outer query!), 
   resolve flag, triples-fn in conditions, and formatting offset"
  (sparql-block-preprocess b (expr-data-bound ed) ed)
  (let* ((select-tr (strings-to-string (mapcar (f/l (e) (sparql-expr-to-amosql e ed 0 resolve)) 
					       (unless (eq select 'asterisk) select)) "" ", " ""))
	 select-group-tr)
    (when (eq select 'asterisk) ; interpret * select list
      (setq select-group (set-difference-equal (expr-data-ref ed) params))
      (setq select nil)
      (when (null select-group) (error "No variables to select!")))
    (setq select-group-tr (strings-to-string (sparql-vars-to-amosql select-group ed) "" ", " ""))
    (when (and (cdr select-group) (cdr select)) ;TODO: maybe (and ... select)
      (setq select-group-tr (concat "{" select-group-tr "}")))
    (concat select-group-tr (if (or (null select) (string= select-group-tr "")) "" ", ") select-tr
	    (if (and (null select) (string= select-group-tr "")) "true" "") ; select TRUE when both select lists are empty
	    (sparql-block0-to-amosql b params ed triples-fn offset t))))


(defun sparql-block0-to-amosql (b params ed triples-fn offset from-p)
  "Translate sparql block to Amos query, selecting SELECT-GROUP variables grouped into vector and SELECT expressions,
   use expression context ED (should contain any NEWVARS from outer query!), 
   resolve flag, triples-fn in conditions, and formatting offset"
  (let* ((cond-tr (sparql-conds-to-amosql (list b) ed triples-fn offset))
	 (declare (union-equal (set-difference-equal (expr-data-ref ed) params)
			       (expr-data-newvars ed))))
    (concat (if (or declare (block-blanks b))
		(concat (if from-p (concat (nl offset) "  from ") "")
			(strings-to-string (sparql-vars-to-amosql (append (nreverse declare) (block-blanks b)) 
								  ed) _sq_basetype_ ", " "")) "")
	    (if (string= cond-tr "") "" (concat (nl offset) " where " cond-tr)))))

(defun sparql-stat-to-amosql (stat params target ed offset) ; SELECT blocks translation
  "Translate SPARQL-STAT structure, SELECT set overrides WHAT expression list,
   using expression context ED, formatting offset. (CAR TARGET) is either top, fn, outer-fn"
  (setf (expr-data-sources ed) (sparql-stat-from stat)) ; TODO: process prefixed!
  (let* ((triples-fn (uri-to-amos-function (sparql-stat-from stat)))
         (b (sparql-stat-where stat))
         (agg (sparql-stat-agg-expr stat)) ; list of named aggregation calls
	 (inner-ed (if (or (eq (car target) 'sub) (and agg (not (eq (car target) 'outer-fn)))) 
		     (clone-expr-data ed) ed)) ; create inner query expresion context
	 res)
    (when (eq (car target) 'sub) ; use :s name susbstitutions inside a subquery
      (add-subst inner-ed (set-difference-equal (expr-data-ref ed) (expr-data-bound ed)) "s"))
    (cond ((not agg) ;1. flat query or function
	   (setq res (concat "select " (if (sparql-stat-distinct stat) "distinct " "")
			     (sparql-block-to-amosql b nil (sparql-stat-what stat) params inner-ed 
						     triples-fn t offset)))
	   (if (eq (car target) 'sub)
	       (concat (if (cdr (sparql-stat-what stat)) "(" "") 
		       (sparql-vars-to-amosql (sellist-to-vars (sparql-stat-what stat)) ed) 
		       (if (cdr (sparql-stat-what stat)) ")" "") " in (" res ")")
	     res))
	  ((eq (car target) 'outer-fn) ; 2. outer function
	   (let ((tla-data (gethash (cdr target) *rdf-tla-fns*)))
	     (sparql-tla-to-amosql (concat "rdf:" (cdr target) ":inner(" (strings-to-string params "" ", " "") ")")
				   (sparql-stat-what stat) (sparql-stat-agg-expr stat) (sparql-stat-groupby stat) 
				   ed offset stat nil)))
	  (t ; 3. inner function or both inner and outer queries
	   ; 3.1. inner query ;TODO offset!
	   (setq res (sparql-block-to-amosql b (sparql-stat-groupby stat) (mapcar (f/l (e) (second (third e))) agg) params
					     inner-ed triples-fn (not (member (car target) '(fn outer-fn))) (+ offset 10))) 
	   (cond ((eq (car target) 'sub) ; 3.2a subquery
		  (sparql-tla-to-amosql-cond res (sparql-stat-agg-expr stat) (sparql-stat-groupby stat) ed nil))
		 ; 3.2b. inner function
		 ((and (eq (car target) 'fn) (null (sparql-stat-groupby stat)) (null (cdr (sparql-stat-what stat)))) 
		  (setf (gethash (cdr target) *rdf-tla-fns*) ; register TLA-data
			(make-tla-data :exprs (sparql-stat-what stat) :aggs (sparql-stat-agg-expr stat))) 
		  (concat "select " res))
		 (t ; 3.2c. outer query
		  (sparql-tla-to-amosql res (sparql-stat-what stat) (sparql-stat-agg-expr stat) 
					(sparql-stat-groupby stat) ed offset stat nil)))))))


(defun sparql-tla-to-amosql-cond (inner-tr aggs groupby ed expr)
  "Translate simplified or generic aggregation/grouping around the translated inner query in INNER-TR,
   unless EXPR, form a valid condition bidning groping and aggregate variabls,
   use expression translator context ED to translate these variables"
  (let* ((use-groupby (or groupby (cdr aggs)))
	 (aggfn-trs (mapcar (f/l (e) (sparql-aggfn-to-amosql (cdar (third e)))) aggs))
	 ; translate to groupby((<inner>), <agg-fns>)  
	 (res (if use-groupby (concat "groupby((select " (if groupby "" "{}, ") inner-tr "), " 
				      (if (cdr aggfn-trs) "{" "") (strings-to-string aggfn-trs "#'" ", " "'") 
				      (if (cdr aggfn-trs) "}" "") ")")
		(concat (car aggfn-trs) "(select " inner-tr ")")))) ; translate to <agg-fn>(<inner>)
    (if expr res
      ; return as a condition
      (let ((groupby-tr (strings-to-string (sparql-vars-to-amosql groupby ed) "" ", " "")))  
	(when (or (cdr groupby) (and (null groupby) use-groupby))
	  (setq groupby-tr (concat "{" groupby-tr "}")))
	(concat (if use-groupby "(" "") groupby-tr (if (string= groupby-tr "") "" ", ") 
		(strings-to-string (sparql-vars-to-amosql (sellist-to-vars aggs) ed) "" ", " "")
		(if use-groupby ") in " " = ") res)))))

(defun sparql-match-select-list (select groupby aggs)
  "Check whether SELECT list can be directly mapped from the result grouping/aggregation"
  (if (and (null select) (null aggs)) t
    (let ((sel-var (selectq (caar select)
			    (named (when (eq (car (third (car select))) 'var)
				     (cdr (third (car select)))))
			    (var (cdar select))
			    nil)))
      (when (and sel-var (equal sel-var (if groupby (car groupby) (second (car aggs)))))
	(sparql-match-select-list (cdr select) (cdr groupby) (if groupby aggs (cdr aggs))))))) ; recursive


(defun sparql-tla-to-amosql (inner-tr exprs aggs groupby ed offset stat strict)
  "Translate select EXPRS and aggregation around tranlated inner query INNER-TR (no 'select ' included)
   use GROUPBY variables, extra conditions (e.g. HAVING and cross-reference binding),
   expression translator context ED, offset, STAT if actually translating a SPARQL select statement
   guaranteed to return valid non-bag-valued expression if STRICT"
  (let* ((distinct (and stat (sparql-stat-distinct stat)))
	 (res (when (and (null (expr-data-newconds ed)) 
			 (null (expr-data-newvars ed)) (not distinct)) ; if simplifications are possible
		(cond ((sparql-match-select-list exprs groupby aggs) ; simplification A: use direct aggregate expression
		       (sparql-tla-to-amosql-cond inner-tr aggs groupby ed t))
		      ; simplification B: translate single select expression to use direct aggregate expression
		      ((and (null groupby) (null (cdr exprs)) (null (cdr aggs))) 
		       (push (list (second (car aggs)) (sparql-tla-to-amosql-cond inner-tr aggs groupby ed t)) 
			     (expr-data-substs ed)) ; substituting an aggregate variable with translated TLA expression
		       (sparql-expr-to-amosql (car exprs) ed 0 nil))
		      (t nil)))))
    (if res res ; otherwise translate without simplifications
      (let ((select-trs (mapcar (f/l (e) (sparql-expr-to-amosql e ed 0 nil)) exprs)) ; translate SELECT expressions
	    (ext-conds-trs (sparql-conds-to-amosql-new nil ed offset)) ; translate any extra conditions in NEWCONDS
	    (declare (union-equal groupby (union-equal (sellist-to-vars aggs) (expr-data-newvars ed)))))
;	(print (list 'select-trs= select-trs 'ext-conds-trs= ext-conds-trs 'declare= declare)) ;DEBUG
	(setq res (concat "select " (if distinct "distinct " "") (strings-to-string select-trs "" ", " "")
			  (if declare (concat (nl offset) "  from " (strings-to-string (sparql-vars-to-amosql declare ed) 
										       _sq_basetype_ ", " "")) "") 
			  (nl offset) " where " (sparql-tla-to-amosql-cond inner-tr aggs groupby ed nil)
			  (strings-to-string ext-conds-trs (concat (nl offset) "   and ") "" "")))
	(if strict (concat "in(" res ")") res))))) ; adapter for strict expressions

(defun sparql-conds-to-amosql-new (conds ed offset) 
  "A simplified translator of condition list, also translates any new and emerginc conditions from ED"
  (let (res newconds)
    (dolist (c conds)
      (push (sparql-cond-to-amosql-new c ed offset) res))
    (while (expr-data-newconds ed) ; repeat until no more newconds
      (setq newconds (expr-data-newconds ed))
      (setf (expr-data-newconds ed) nil)
      (dolist (c newconds)
	(push (sparql-cond-to-amosql-new c ed offset) res)))
    (nreverse res))) ; TODO: translate expr-data-newconds-tr

(defun sparql-cond-to-amosql-new (c ed offset)
  "A simplified translator of conditions, only BIND and FILTER are supported"
  (if (stringp c) c
    (selectq (car c)
	     ; translate cross-references
	     (bind (concat (sparql-var-to-amosql (second c) nil) " = " ; TODO: use substitutions!
			   (sparql-expr-to-amosql (third c) ed (sparql-expr-prec '(=)) nil)))
	     ; translate HAVING filter
	     (filter (sparql-expr-to-amosql (second c) ed (sparql-expr-prec '(and)) nil))
	     "")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATING CONDITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-conds-to-amosql (b-stack ed triples-fn offset) 
  "Translate the list of conditions of SPARQL block (BLOCK structure) on top of B-STACK, 
   accumulate NEWVARS and translate all NEWCONDS inside expression context ED,
   use TRIPLES-FN as triple storage function, format with OFFSET"
  (let (newconds conjuncts)
    (dolist (c (block-conds (car b-stack)))
      (selectq (car c)
	       (triples (let (amos-spo amos-p amos-triple) 
			  (dolist (triple (cdr c)) ; add triple pattern conjuncts
			    (setq amos-spo (mapcar (f/l (o) (sparql-expr-to-amosql o ed 0 nil)) triple))
			    (setq amos-p (second amos-spo))
			    (setq amos-triple (concat "(" (strings-to-string amos-spo "" ", " "") ") in " triples-fn))
			    (push (cond ((equal amos-p "URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#first')") 
					 (concat "(rdf:first(" (first amos-spo) ") = " ; special translation for rdf:first 
						 (third amos-spo) " or " amos-triple ")")) ;TODO: should be more general
					((equal amos-p "URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#rest')") 
					 (concat "(rdf:rest(" (first amos-spo) ") = " ; special translation for rdf:rest 
						 (third amos-spo) " or " amos-triple ")"))
					(t amos-triple)) conjuncts)))
			(setf (expr-data-bound ed) (sparql-triples-vars (cdr c) (expr-data-bound ed))))
	       (filter (push (sparql-expr-to-amosql (cdr c) ed (sparql-expr-prec '(and)) nil) conjuncts))
	       (bindseq (dolist (bind (cdr c))
			  (when (member (first bind) (expr-data-ref ed)) ; avoid binding otherwise unused variables
			    (push (concat (sparql-var-to-amosql (first bind) nil) " = "
					  (if (second bind) "" "rdf:bind(") 
					  ; enforce uni-directional assignment if BIND is not completelty resolved
					  (sparql-expr-to-amosql (third bind) ed (if (second bind) (sparql-expr-prec '(=)) 
										   0) nil)
					  (if (second bind) "" ")")) conjuncts)
			    (when (second bind) ; if BIND is resolved, mark assigned variable as bound
			      (pushnew-equal (first bind) (expr-data-bound ed))))))
	       (optional (push (concat "optional(" (sparql-conds-to-amosql (cons (cdr c) b-stack) ed triples-fn 
									   (+ offset 13)) ; recursive
				       ")") conjuncts))
	       (union (let (disjuncts bound-in-union); add union condition
			(dolist (u (cdr c))
			  (push (sparql-conds-to-amosql (cons u b-stack) ed triples-fn (+ offset 2)) disjuncts) ; recurive
			  (if (eq u (second c)) (setq bound-in-union (block-bound+ u))
			    (setq bound-in-union (intersection-equal bound-in-union (block-bound+ u)))))
			(push (concat "((" (strings-to-string (nreverse disjuncts) "" 
							      (concat ")" (nl (+ offset 4)) " or (") "") "))") conjuncts)
			(setf (expr-data-bound ed) (union-equal (expr-data-bound ed) bound-in-union))))
	       (subquery (push (sparql-select-to-amosql (cdr c) (expr-data-bound ed) '(sub) ed) conjuncts)
			 (setf (expr-data-bound ed) ;TODO: assuming all variables returned from subquery are bound!
			       (union-equal (expr-data-bound ed) (sellist-to-vars (sparql-stat-what (cdr c)))))) 
	       ((exists not-exists) 
		(let ((left (concat (if (eq (car c) 'exists) "some" "notany") "(select ")))
		  (push (concat left (sparql-block-to-amosql (cdr c) nil nil (expr-data-bound ed) (clone-expr-data ed) 
							     triples-fn nil (+ offset (length left))) ")") conjuncts)))
	       (graph-block 
		(let ((triples-fn-var (resource-or-var-to-triples-fn (second c) ed nil)))
		  (push (sparql-conds-to-amosql (list (third c)) ed (car triples-fn-var) offset) conjuncts)
		  (when (and (cdr triples-fn-var) (not (member (cdr (second c)) (expr-data-bound ed)))) ;in-bind unbound graph var
		    ;TODO: shouldn't treat var bound only in this block as bound
		    (push (concat (cdr triples-fn-var) " in {" 
				  (strings-to-string (mapcar (f/l (s) (sparql-expr-to-amosql (list 'uri s) ed 0 t))
							     (expr-data-sources ed)) "" ", " "") "}") conjuncts))))
	       t)
      (while (expr-data-newconds ed) ; add expr-originating CONDS directly after their source CONDS
	(setq newconds (expr-data-newconds ed))
	(setf (expr-data-newconds ed) nil)
	(dolist (nc newconds) 
	  (push (sparql-cond-to-amosql-new nc ed offset) conjuncts))
	(setf (expr-data-newconds ed) nil)))
    (strings-to-string (nreverse conjuncts) "" (concat (nl offset) "   and ") "")))


(defun resource-or-var-to-triples-fn (e ed add-missing)
  (let* ((var-tr (when (eq (car e) 'var) 
		   (sparql-var-to-amosql (cdr e) (expr-data-substs ed))))
	 (graph (unless var-tr (sparql-resource-to-string e ed))))
    (when (and graph (not _sq_string_based_))
      (setq graph (uri graph)))
    (cons (if var-tr (concat "GRAPH(NGDict(" var-tr "))")
	    (graphs-to-triples-fn (list graph) add-missing))
	  var-tr)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATING CONSTRUCT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defparameter sparql-construct-output-vars '("c:ss" "c:pp" "c:oo"))

(defun sparql-construct-to-amosql (stat ed offset) ;TODO: should be tested with aggregate functions in what-block
  "Translate CONSTRUCT query to AmosQL"
  (sparql-block-preprocess (sparql-stat-where stat) nil ed)
  (setf (expr-data-ref ed) (append (expr-data-ref ed) sparql-construct-output-vars))
  ;; 1. translate WHAT block to disjunction, possibly generating new VARS and CONDS
  (let ((triples-fn (uri-to-amos-function (sparql-stat-from stat)))
	(construct-disjuncts (sparql-construct-disjuncts (sparql-stat-what stat) ed))) 
    (dolist (c (block-conds (sparql-stat-what stat))) ; all variables used in what-block 
      (when (eq (car c) 'triples) ; are counted as REF when translating where-block
	(setf (expr-data-ref ed) (sparql-triples-vars (cdr c) (expr-data-ref ed)))))
    ;; 2. translate WHERE block as in SELECT query
    (concat "select " (strings-to-string sparql-construct-output-vars "" ", " "")
	    (sparql-block0-to-amosql (sparql-stat-where stat) nil ed triples-fn offset t)
	    (nl offset) "   and (" (strings-to-string construct-disjuncts "" (concat (nl (+ offset 5)) "or ") "") ")"))) ; add translated disjunction 

(defun sparql-construct-disjuncts (b ed)
  "Translate WHAT-block of a CONSTRUCT query to a list of OR disjunctions inside an extra condition"
  (let (disjuncts)
    (dolist (c (block-conds b))
      (when (eq (car c) 'triples)
	(dolist (tr (cdr c))
	  (push (concat "(" (first sparql-construct-output-vars) " = " (sparql-expr-to-amosql (first tr) ed 0 nil) 
			" and " (second sparql-construct-output-vars) " = " (sparql-expr-to-amosql (second tr) ed 0 nil) 
			" and " (third sparql-construct-output-vars) " = " (sparql-expr-to-amosql (third tr) ed 0 nil) 
			(strings-to-string (mapcar (f/l (v) (concat " and rdf:bound(" ; TODO: add this only for partial-bound vars!
								    (sparql-var-to-amosql v (expr-data-substs ed)) ")"))
						   (set-difference-equal (sparql-triples-vars (list tr) nil) 
									 (expr-data-bound ed))) "" "" "")
			")") disjuncts))))
    (nreverse disjuncts)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATING UPDATES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-update-to-amosql (stat ed)
  "Translate SPARQL-UPDATE to AmosQL, using expression data ED"
  (sparql-block-preprocess (sparql-update-where stat) nil ed)
  (let* ((update-triples-fn (uri-to-amos-function (when (sparql-update-with stat) (list (sparql-update-with stat)))))
	 (where-triples-fn (if (sparql-update-using stat) (uri-to-amos-function (sparql-update-using stat)) update-triples-fn))
	 (update-trs (append (if (eq (sparql-update-delete stat) 'asterisk) ; use WHERE clause and where-graph if DELETE WHERE
				 (sparql-update-patterns-to-amosql (sparql-update-where stat) ed where-triples-fn nil) 
			       (sparql-update-patterns-to-amosql (sparql-update-delete stat) ed update-triples-fn nil)) ; use DELETE clause and WITH graph otherwise
			     (sparql-update-patterns-to-amosql (sparql-update-insert stat) ed update-triples-fn t)))) ; use DELETE clause and WITH graph
    (concat "for each " (sparql-block0-to-amosql (sparql-update-where stat) nil ed where-triples-fn 1 nil)
	    (nl 0) "begin" (strings-to-string update-trs (nl 2) "" ";") (nl 0) "end;")))

(defun sparql-update-patterns-to-amosql (b ed triples-fn insert-p)
  "Translate a SPARQL DELETE or INSERT block to AmosQL remove/add statements, 
   conditional if used variables are not BOUND in the ED context, use graph reference in TRIPLES-FN"
  (when b
    (let (trs check-vars)
      (dolist (c (block-conds b))
	(selectq (car c) 
		 (triples
		  (dolist (tp (cdr c))
		    (setq check-vars (when insert-p (set-difference-equal (sparql-triples-vars (list tp) nil) (expr-data-bound ed))))
		    (push (concat (if check-vars (concat "if " (strings-to-string (sparql-vars-to-amosql check-vars ed) "rdf:bound(" " and " ")") " then ") "")
				  (if insert-p "add " "remove ") triples-fn " = (" 
				  (strings-to-string (mapcar (f/l (o) (sparql-expr-to-amosql o ed 0 nil)) tp) "" ", " "") ")") trs)))
		 (graph-block
		  (let ((triples-fn-var (resource-or-var-to-triples-fn (second c) ed insert-p)))
		    (dolist (tr (sparql-update-patterns-to-amosql (third c) ed (car triples-fn-var) insert-p)) ;TODO: maybe should in-bind unbound graph var
		      (push tr trs))))
		 t))
      (nreverse trs))))
		     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATING ARCHIVE STATEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-archive-to-amosql (stat ed)
  "Transform ARCHIVE statement to CONSTRUCT query, translate and wrap it inside call to archive_content_schema() function"
  (let (construct-patterns construct-where where-block construct)
    (dolist (branch (nreverse (sparql-archive-triples stat)))
      (setq where-block (if (cdr branch) (cdr branch) (make-block)))
      (dolist (c (block-conds (car branch)))
	(when (eq (car c) 'triples)
	  (push c (block-conds where-block))
	  (dolist (tp (cdr c))
	    (pushnew-equal c construct-patterns))))
      (push where-block construct-where))
    (setq construct (make-sparql-stat :type 'construct :from (sparql-archive-from stat) 
				      :what (make-block :conds construct-patterns)
				      :where (if (cdr construct-where) (make-block :conds (list (cons 'union construct-where))) (car construct-where))))
    (concat "archive_content_schema('" (car (sparql-archive-as stat)) "', '" (cdr (sparql-archive-as stat)) "',"
	    (nl 23) "(" (sparql-construct-to-amosql construct ed 24) "));")))

