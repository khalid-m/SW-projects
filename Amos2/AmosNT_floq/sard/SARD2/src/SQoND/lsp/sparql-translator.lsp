;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-translator.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:41 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Translator functionality based on sparql-lsp-parser
;;; =============================================================
;;; $Log: sparql-translator.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:41  silvias
;;; *** empty log message ***
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

(defvar _sq_basetype_ (if _sq_string_based_ "Charstring " "Literal ")) ; should end with space!

(unless (boundp 'lisp_reader_breaks)
  (load "sparql-stream-parser.lsp"))

(load "sparql-utils.lsp")

(load "uri-to-fn.lsp")

;;;;;;;;;;;;;;;;;;;;; PARAMETERS ;;;;;;;;;;;;;;;;;;;;;

; (defvar _sq_ub_ "UB()") 

(defvar _sq_python_ranges_ t)

(defvar *session-prefixes* '(("rdf" . "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
			     ("xsd" . "http://www.w3.org/2001/XMLSchema#")))

;;;;;;;;;;;;;;;;;;;;;; TRANSLATING EXPRESSIONS ;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-var-to-amosql (v substs)
  "Translate SparQL variable to AmosQL variable, using SUBSTS substitution list"
  (let ((subst (assoc v substs))) ;substitute variable names inside OPTIONAL conditions
    (if subst (second subst) v)))

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

(defun sparql-make-newvar (data n)
  "Create a new variable prefixed with n: or arg:, unique to NEWVARS"
  (let ((i 1) res)
    (loop
      (setq res (concat (if n "n:" "arg:") (mkstring i)))
      (if (member res (expr-data-newvars data)) (incf i) (return t)))
    (push res (expr-data-newvars data))
    res))

(defun sparql-closure-to-amosql (e data)
  "Translate closure E, return (<translation> . <newvars>), add newvars to DATA, ignore possible TLAs"
  (let* (newvars
	 (tr (concat "rdf:" (cdar e) "(" 
		     (strings-to-string (mapcar (f/l (arg) (if (eq (car arg) 'asterisk)							       
							       (car (push (sparql-make-newvar data nil) newvars))
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
			  (prefixed (sparql-expr-to-amosql (list 'uri (concat (cdr (assoc (second e) (expr-data-prefixes data))) (third e))) data 0 nil))			  
			  (= ; (if (and (not (eq (expr-data-bound data) t)) ; whenever BOUND is specified
;				      (or (set-difference-equal (collect-expr-vars (second e) nil nil) (expr-data-bound data)) ; and a used variable is not in CUR-BOUND
;					  (set-difference-equal (collect-expr-vars (third e) nil nil) (expr-data-bound data))))
;				 (concat "rdf:equal(" (sparql-expr-to-amosql (second e) data 0) ; enforce EQUAL--
;					 "," (sparql-expr-to-amosql (third e) data 0) ")")
			   (concat (sparql-expr-to-amosql (second e) data prec nil) " = " ; otherwise allow the optimizer use other binding patterns
				   (sparql-expr-to-amosql (third e) data prec nil))) ; )
			  ((and or) 
			   (concat (sparql-expr-to-amosql (second e) data prec nil) " " (string-downcase (mkstring (car e))) " "
				   (sparql-expr-to-amosql (third e) data prec nil)))
			  ((< > <= >= !=)
			   (let* ((arg1 (sparql-expr-to-amosql (second e) data 0 t)) ;apr(x) < apr(y) and comparable(apr(x), apr(y))
				  (arg2 (sparql-expr-to-amosql (third e) data 0 t))
				  (res1 (concat arg1 (mkstring (car e)) arg2)))
			     (if _sq_string_based_ res1 ; always comparable in string mode
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
				       ((or (eq (caadr e) 'var) (listp (caadr e))) ; use notany for variables and funcalls
					(let* ((v (if (listp (caadr e)) (sparql-make-newvar data t) ; translating !<funcall>
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
						    (t (concat "TypedRDF(USTR('" (second e) "'), " type-uri ")")))))
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
			   (cond ((string= (cdar e) "regex") ; regex translation: preprocess arguments if constants provided
				  (concat "rdf:regex(" (sparql-expr-to-amosql (second e) data 0 nil) ", "
					  (if (eq (car (third e)) 'ustr) (string-to-amosql (sparql-regex-to-amosql (second (third e))))
					; ^ pass 2nd arg as Amos string (translated)
					    (sparql-expr-to-amosql (third e) data 0 nil)) ; pass 2nd arg as USTR
					  (if (fourth e) (concat ", " (if (eq (car (fourth e)) 'ustr) 
									  (concat "'" (second (fourth e)) "'")
									(sparql-expr-to-amosql (fourth e) data 0 nil))) "") ")"))
                                                                        ; ^ pass 3rd arg as USTR
				 ((and (not _sq_string_based_) (string= (cdar e) "permute")) 
					; permute translation: put the arguments except the first one into an amos vector
				  (let ((args (mapcar (f/l (arg) (sparql-expr-to-amosql arg data 0 nil)) (cdr e))))
				    (concat "rdf:permute(" (car args) ",{" (strings-to-string (cdr args) "" "," "") "})")))
				 ((member (cdar e) '("argmin" "argmax"))				  				  
				  (unless (and (null (cddr e)) (listp (car (second e))) (eq (caar (second e)) 'id))
				    (error (concat (string-upcase (cdar e)) " requieres a unary closure as a single parameter!")))
				  (let* ((inner-ed (make-expr-data :prefixes (expr-data-prefixes data) ; clone current context for closure translation
								   :substs (expr-data-substs data) 
								   :bound (expr-data-bound data)))
					 (closure-itr (sparql-closure-to-amosql (second e) inner-ed)) ; translate closure
					 (tla (gethash (cdar (second e)) *rdf-tla-fns*))) ; add GROUPBY inside ARG* call if TLA is used on closure
				    (concat "rdf:" (cdar e) (if tla "(groupby((" "(") "select arg:1, " (first closure-itr) " from "
					    (strings-to-string (expr-data-newvars inner-ed) _sq_basetype_ ", " "") 
					    (if (expr-data-newconds inner-ed) 
						(concat " where " (strings-to-string (expr-data-newconds inner-ed) "" " and " "")) "")  
					    (if tla (concat "), #'" tla "'))") ")"))))
				 ((sparql-aggfn-p (cdar e)) "") ; do not translate aggregate fncalls
				 (t (setq res (concat "rdf:" (cdar e) "(" (sparql-arglist-to-amosql (cdr e) data ; default fncall translation
												    (member (cdar e) _sq_proxy_intolerant_fns_)) ")")) 
				    (if (setq tla (gethash (cdar e) *rdf-tla-fns*)) ; if a function contains top-level aggregation
					(concat tla "(" res ")") res)))) ; wrap it around this fncall
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
	  
(defun sparql-block-preprocess (b par)
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
	     (bindseq (dolist (bind (cdr c))
			(sparql-resolve-bind (list bind) (cdr c) b)))
	     (optional (sparql-block-preprocess (cdr c) par) ; recursive
		       (setf (block-ref* b) (union-equal (block-ref* b) (block-ref* (cdr c))))
		       (setf (block-partial b) (union-equal (block-partial b) (block-partial (cdr c)))))
	     (union (let (bound-in-union)
		      (dolist (u (cdr c))
			(sparql-block-preprocess u par) ; recursive
			(if (eq u (second c)) (setq bound-in-union (block-bound+ u))
			  (setq bound-in-union (intersection-equal bound-in-union (block-bound+ u))))
			(setf (block-ref* b) (union-equal (block-ref* b) (block-ref* u)))
			(setf (block-partial b) (union-equal (block-partial b) (block-partial u))))
		      (setf (block-bound+ b) (union-equal (block-bound+ b) bound-in-union))))
	     t)) 
  (setf (block-partial b) (union-equal (block-partial b) (block-bound+ b))) ; count all bound+ variables also as partial
  b)

(defun collect-expr-vars (e buf stat)
  "collect variable names from expression E in BUF, 
   put aggregate-expressions to (SPARQL-STAT-AGG STAT) if specified,
   skip variables that are direct arguments to one of SKIP-FNS"
  (when (and stat (eq (car e) 'named) (consp (third e)) (consp (car (third e))) 
	     (eq (caar (third e)) 'id) (sparql-aggfn-p (cdar (third e))))
    (setf (sparql-stat-agg stat) e)) ;; anyway expect at most 1 aggregate expression
  (cond ((eq (car e) 'var)
	 (pushnew-equal (cdr e) buf))
	((listp (cdr e)) ;; process subexpressions recursively
	 (dolist (sub-e (cdr e)) 
	   (when (consp sub-e) (setq buf (collect-expr-vars sub-e buf stat)))))) ; recursive
  buf)

(defun sparql-triples-vars (triples buf)
  "collect variables from triple patterns in BUF"
  (dolist (triple triples buf)
    (dolist (term triple)
      (when (eq (car term) 'var)
	(pushnew-equal (cdr term) buf)))))

;; Preprocessing aggregate queries

(defun sparql-extend-sellist (stat)
  "Generate extended select-list"
  (let* ((res (sparql-stat-what stat))
	 (sellist (sellist-to-vars res)))
    (dolist (groupvar (sparql-stat-groupby stat))
      (unless (member groupvar sellist) (setq res (cons (cons 'var groupvar) res))))
    (setf (sparql-stat-ext-what stat) res)))

(defun sparql-rewrite-expression (stat expr)
  "use EXT-WHAT list of (var ..) and (named ..) entries to rewrite expr, extend the list with any new vars"
  (let ((expr-as-named))
    (cond ((atom expr) expr)
	  ((eq (car expr) 'var) 
	   (unless (dolist (nov (sparql-stat-ext-what stat)) ; if new variable found
		     (when (string= (if (eq (car nov) 'var) (cdr nov) (second nov)) (cdr expr)) (return t)))
	     (setf (sparql-stat-ext-what stat) (cons expr (sparql-stat-ext-what stat))))) ; add it to EXT-WHAT
	  ((setq expr-as-named (dolist (nov (sparql-stat-ext-what stat)) ; if expr mathces a named expression
				 (when (and (eq (car nov) 'named) (equal expr (third nov))) (return (second nov)))))
	   (cons 'var expr-as-named)) ; rewrite it as variable 
	  (t (cons (car expr) (if (listp (cdr expr)) (mapcar (f/l (e) (sparql-rewrite-expression stat e)) (cdr expr)) ; recursively rewrite
				(cdr expr)))))))

;;;;;;;;;;;;;;;;;;;;; MANAGING PREFIXES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun merge-prefix-lists (bottom top)
  "Combine two prefix lists"
  (let ((res (if top (copy-tree bottom) bottom)) bpref)
    (dolist (tpref top res)
      (setq bpref (assoc (car tpref) res))
      (if bpref (setf (cdr bpref) (cdr tpref))
	(push tpref res)))))

;;;;;;;;;;;;;;;;;;;;; MANAGING SUBSTITUTION LISTS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
		   	    
(defun extend-substs (substs vars modifier)
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
	 (prefixes (merge-prefix-lists *session-prefixes* (first pq)))
	 (stat (second pq)))
    (cond ((listp stat)
	   (selectq (car stat)
		    (nil '*eof*)
		    (quit "quit;")
		    (lisp 'language-lisp) 
		    (call (let* ((ed (make-expr-data :prefixes prefixes :bound t))
				 (tr (concat "select " (sparql-expr-to-amosql (cdr stat) ed 0 nil)))) ; translate without apr()
			    (when (expr-data-newvars ed)
			      (setq tr (concat tr (nl 2) "from " (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v nil))
											    (expr-data-newvars ed)) _sq_basetype_ ", " ""))))
			    (when (expr-data-newconds ed)
			      (setq tr (concat tr (nl 1) "where " (strings-to-string (expr-data-newconds ed) "" (concat (nl 3) "and ") ""))))
			    (concat tr ";")))
		    (prefix (setq *session-prefixes* (merge-prefix-lists *session-prefixes* (list (cdr stat)))) "")
		    ""))
	  ((sparql-stat-p stat) ;;SELECT/CONSTRUCT queries
	   (selectq (sparql-stat-type stat)
		    (select (concat (sparql-select-to-amosql stat prefixes nil t) ";"))
		    (construct (concat (sparql-construct-to-amosql stat prefixes) ";"))
		    ""))		     
	  ((define-stat-p stat) ;;DECLARE FUNCTION/AGGREGATE
	   (let ((header (concat "create function rdf:" (define-stat-name stat) "(" 
				 (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v nil)) (define-stat-vars stat)) 
						    (if (define-stat-agg stat) (concat "Bag of " _sq_basetype_) _sq_basetype_) ", " "") 
				 ") -> Bag of " _sq_basetype_ (nl 2) "as "))
		 definition-translator)
	     (when (and (define-stat-agg stat) (not (member (define-stat-name stat) _sq_aggregate_fns_)))
	       (push (define-stat-name stat) _sq_aggregate_fns_))
	     (if (eq (car (define-stat-body stat)) 'sparql)
		 (concat header (sparql-select-to-amosql (cadr (define-stat-body stat)) prefixes (define-stat-vars stat) (define-stat-name stat)) ";")
	       (progn
		 (setq definition-translator (cdr (assoc (car (define-stat-body stat)) *sparql-extender-engines*)))
		 (concat header (if definition-translator 
				    (funcall definition-translator (cadr (define-stat-body stat)) (define-stat-vars stat))
				  (concat "foreign '" (cadr (define-stat-body stat)) "'")) ";"))))) ; default case for LISP and C definitions
	  (t ""))))

(defun sparql-select-to-amosql (stat prefixes param root)
  "Translate SparQL SELECT query to AmosQL"
  (let ((triples-fn (uri-to-amos-function (sparql-stat-from stat)))
	(basic-block (sparql-stat-where stat)) (select nil))
    (unless basic-block
      (setq basic-block (make-block)))
    (dolist (s (sparql-stat-what stat))  ; calculate SELECT set of variables
      (setq select (collect-expr-vars s select stat))) 
    (setf (block-ref* basic-block) select) ; SELECT variables are also REF* for the basic block
    (sparql-block-preprocess basic-block param) ; general preprocessing
    (if (sparql-stat-agg stat) ; if aggregate query
	(progn 
	  (sparql-extend-sellist stat) ; join SELECT list with GROUP BY
	  (when (sparql-stat-having stat) ; rewrite HAVING expression and/or further extend SELECT list
	    (setf (sparql-stat-having stat) (sparql-rewrite-expression stat (sparql-stat-having stat)))))
      (setf (sparql-stat-ext-what stat) (sparql-stat-what stat)))
    (sparql-block-to-amosql (list basic-block) select param prefixes triples-fn 0 (when root stat) (when (stringp root) root)))) ; translate SELECT query

(defparameter sparql-construct-output-vars '("c:ss" "c:pp" "c:oo"))

(defun sparql-construct-to-amosql (stat prefixes) ;TODO: should be tested with aggregate functions in what-block
  "Translate Sparql CONSTRUCT query to AmosQL"
  (let ((triples-fn (uri-to-amos-function (sparql-stat-from stat)))		 
	(where-block (sparql-stat-where stat))
	ed construct-disjunction)
    (setf (block-ref* where-block) sparql-construct-output-vars)
    (dolist (c (block-conds (sparql-stat-what stat))) ; all variables used in what-block 
      (when (eq (car c) 'triples) ; are counted as REF* in where-block
	(setf (block-ref* where-block) (sparql-triples-vars (cdr c) (block-ref* where-block)))))
    (sparql-block-preprocess where-block nil) 
    (setq ed (make-expr-data :prefixes prefixes :bound (block-bound+ where-block)))
    (setq construct-disjunction (sparql-construct-disjunction (sparql-stat-what stat) ed)) ; translate WHAT block to disjunction, possibly generating new VARS and CONDS
    (setf (block-ref* where-block) (union-equal (block-ref* where-block) (expr-data-newvars ed))) ; add EXPR-generated variables to the REF* set before translating main block
    (concat (sparql-block-to-amosql (list where-block) sparql-construct-output-vars nil prefixes triples-fn 0 stat nil) ; TODO: maybe shouldn't put apr() in construct
	    (strings-to-string (expr-data-newconds ed) (concat (nl 6) "and ") "" "") ; add any extra conditions to the end of main block
	    (nl 6) "and (" construct-disjunction ")"))) ; add translated disjunction

(defun sparql-construct-disjunction (b ed)
  "Translate WHAT-block of a CONSTRUCT query as an extra condition"
  (let (disjuncts)
    (dolist (c (block-conds b))
      (when (eq (car c) 'triples)
	(dolist (tr (cdr c))
	  (push (concat "(" (first sparql-construct-output-vars) " = " (sparql-expr-to-amosql (first tr) ed 0 nil) 
			" and " (second sparql-construct-output-vars) " = " (sparql-expr-to-amosql (second tr) ed 0 nil) 
			" and " (third sparql-construct-output-vars) " = " (sparql-expr-to-amosql (third tr) ed 0 nil) 
			(strings-to-string (mapcar (f/l (v) (concat " and rdf:bound(" (sparql-var-to-amosql v (expr-data-substs ed)) ")"))
						   (set-difference-equal (sparql-triples-vars (list tr) nil) (expr-data-bound ed)))
					   "" "" "")
			")") disjuncts))))
    (strings-to-string (nreverse disjuncts) "" (concat (nl 8) "or ") "")))


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

(defun sparql-block-to-amosql (b-stack select param prefixes triples-fn offset stat defines) ; SELECT blocks translation
  "Translate SparQL query block (SPARQL-BLOCK structure) on top of B-STACK, using provided SELECT and PARAM sets of variables,
   PREFIXES for URI translation, TRIPLES-FN as triple storage function, formatting the output with OFFSET, STAT indicates the root block is passed"
  (let* (ext-what-vars grouping-vars aggfn-name tr sel-tr res 
         (agg (when stat (sparql-stat-agg stat))) ; aggregation NAMED-construct, if any, discovered in COLLECT-EXPR-VARS
	 (ret-vector (and (cdr select) (or (not stat) agg)))
	 (declare (set-difference-equal (block-ref* (car b-stack)) param)) ; declare all (recursively) referenced variables except query parameters
	 (ed (make-expr-data :prefixes prefixes :bound param)))
    (when agg 
      (setq ext-what-vars (sellist-to-vars (sparql-stat-ext-what stat)))
      (setq grouping-vars (set-difference-equal ext-what-vars (list (second agg))))
      (setq aggfn-name (sparql-aggfn-to-amosql (cdar (third agg))))
      (setq offset (if grouping-vars (+ offset 12)
		     (+ offset (length aggfn-name) 1))))
    (setf (expr-data-free ed) (set-difference-equal (set-difference-equal (block-ref* (car b-stack)) (block-bound+ (car b-stack))) ; use these free variables to translate conditions
						    (block-partial (car b-stack))))
    (setq tr (sparql-conds-to-amosql b-stack ed triples-fn offset)) ; WHERE all translated CONDS
    (setf (expr-data-bound ed) (block-bound+ (car b-stack))) ; ED accumulated only NEWVARS
    (setq sel-tr (strings-to-string (if (and stat (sparql-stat-ext-what stat)) ; SELECT all extended-WHAT expressions if basic block
					(mapcar (f/l (e) (sparql-expr-to-amosql e ed 0 (not defines))) (sparql-stat-ext-what stat))
				      (mapcar (f/l (v) (sparql-var-to-amosql v nil)) select))  "" ", " "")) ; or just SELECT variables otherwise
    (setq res
	  (concat "select " (if (and stat (sparql-stat-distinct stat)) "distinct " "") ;TODO: putting 'distinct' into the main query INSIDE groupby(), check if correct
		  (if (and ret-vector (not (string= sel-tr ""))) (concat "{" sel-tr "}") sel-tr) ; if >1 variable returned or translating the basic block - enclose in { }
		  (if agg (concat (if (string= sel-tr "") "" ", ") ; translate expression that is argument to aggregate function 
				  (sparql-expr-to-amosql (second (third agg)) ed 0 nil)) "") ; agg is always (named ".." ((id . "agg") (..)))
		  (if (or declare (block-blanks (car b-stack)) (expr-data-newvars ed)) ; FROM all normal, blank-representing, and expr-originating VARS
		      (concat (nl offset) "  from " (strings-to-string (append declare (block-blanks (car b-stack)) (expr-data-newvars ed)) 
								       _sq_basetype_ ", " "")) "")
		  (nl offset) " where " (if (string= tr "") "true" tr) ; translate empty blocks to TRUE so that it's possible to append 'and ...' extra CONDS
		  (strings-to-string (expr-data-newconds ed) (concat (nl offset) "   and ") "" ""))) ; add expr-originating CONDS
    (when agg (if grouping-vars ;construct outer query around RES
		  (let (having-tr outer-ed)
		    (when (sparql-stat-having stat) ; translate rewritten HAVING expressions using vars from EXT-WHAT
		      (setq outer-ed (make-expr-data :prefixes prefixes :substs (extend-substs nil ext-what-vars "e") :bound (block-bound+ (car b-stack))))
		      (setq having-tr (concat (sparql-expr-to-amosql (sparql-stat-having stat) outer-ed (sparql-expr-prec '(and)) nil)
					      (strings-to-string (expr-data-newconds outer-ed) (concat (nl 3) "and ") "" ""))))		      
		    (setq res (concat "select " (strings-to-string (sellist-to-vars (sparql-stat-what stat)) "" ", " ":e") 
				      (nl 2) "from " (strings-to-string ext-what-vars _sq_basetype_ ", " ":e")
				      (if outer-ed (strings-to-string (expr-data-newvars outer-ed) (concat ", " _sq_basetype_) "" "") "")				      
				      (nl 1) "where (" (if ret-vector "{" "") (strings-to-string grouping-vars "" ", " ":e")
				      (if ret-vector "}" "") ", " (second agg) ":e) in" 
				      (nl 3) "groupby((" res "),#'" aggfn-name "')" ; TODO: handle unbound values
				      (if having-tr (concat (nl 3) "and " having-tr) ""))))
		(if defines (setf (gethash defines *rdf-tla-fns*) aggfn-name) ; if defining a function - store outer aggregate name in *rdf-tla-fns*
		  (setq res (concat aggfn-name "(" res ")"))))) ; otherwise pass the entire result of inner query to that aggregate function
    res))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATING CONDITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sparql-conds-to-amosql (b-stack par-ed triples-fn offset) 
  "Translate the list of conditions of SparQL block (SPARQL-BLOCK structure) on top of B-STACK, 
   use PREFIXES for URI translation, TRIPLES-FN as triple storage function, format with OFFSET,
   accumulate BOUND down the stack and propagate NEWVARS up the stack"
  (let ((ed (make-expr-data :prefixes (expr-data-prefixes par-ed) :bound (expr-data-bound par-ed) :free (expr-data-free par-ed) :newvars (expr-data-newvars par-ed)))
	conjuncts)
    (dolist (c (block-conds (car b-stack)))
      (selectq (car c)
	       (triples (let (amos-spo amos-p amos-triple) 
			  (dolist (triple (cdr c)) ; add triple pattern conjuncts
			    (setq amos-spo (mapcar (f/l (o) (sparql-expr-to-amosql o ed 0 nil)) triple))
			    (setq amos-p (second amos-spo))
			    (setq amos-triple (concat "(" (strings-to-string amos-spo "" ", " "") ") in " triples-fn))
			    (push (cond ((equal amos-p "URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#first')") ; special translation for rdf:first 
					 (concat "(rdf:first(" (first amos-spo) ") = " (third amos-spo) " or " amos-triple ")")) ;TODO: should be more general
					((equal amos-p "URI('http://www.w3.org/1999/02/22-rdf-syntax-ns#rest')") ; special translation for rdf:rest 
					 (concat "(rdf:rest(" (first amos-spo) ") = " (third amos-spo) " or " amos-triple ")"))
					(t amos-triple)) conjuncts)))
			(setf (expr-data-bound ed) (sparql-triples-vars (cdr c) (expr-data-bound ed))))
	       (filter (push (sparql-expr-to-amosql (cdr c) ed (sparql-expr-prec '(and)) nil) conjuncts))
	       (bindseq (dolist (bind (cdr c))
			  (push (concat (sparql-var-to-amosql (first bind) nil) " = "
					(if (second bind) "" "rdf:bind(") ; enforce uni-directional assignment if BIND is not completelty resolved
					(sparql-expr-to-amosql (third bind) ed (if (second bind) (sparql-expr-prec '(=)) 0) nil)
					(if (second bind) "" ")")) conjuncts)
			  (when (second bind) ; if BIND is resolved, mark assigned variable as bound
			    (pushnew-equal (first bind) (expr-data-bound ed)))))
	       (optional (push (concat "optional(" (sparql-conds-to-amosql (cons (cdr c) b-stack) ed triples-fn (+ offset 13)) ; recursive
				       ")") conjuncts))
	       (union (let (disjuncts bound-in-union); add union condition
			(dolist (u (cdr c))
			  (push (sparql-conds-to-amosql (cons u b-stack) ed triples-fn (+ offset 2)) disjuncts) ; recurive
			  (if (eq u (second c)) (setq bound-in-union (block-bound+ u))
			    (setq bound-in-union (intersection-equal bound-in-union (block-bound+ u)))))
			(push (concat "((" (strings-to-string (nreverse disjuncts) "" (concat ")" (nl (+ offset 4)) " or (") "") "))") conjuncts)
			(setf (expr-data-bound ed) (union-equal (expr-data-bound ed) bound-in-union))))
	       t)
      (when (expr-data-newconds ed) ; add expr-originating CONDS directly after their source CONDS
	(dolist (nc (expr-data-newconds ed)) 
	  (push nc conjuncts))
	(setf (expr-data-newconds ed) nil)))
    (when (expr-data-newvars ed) ; propagate all expr-originating VARS up the recursion stack
      (setf (expr-data-newvars par-ed) (union-equal (expr-data-newvars par-ed) (expr-data-newvars ed))))
    (strings-to-string (nreverse conjuncts) "" (concat (nl offset) "   and ") "")))


  

