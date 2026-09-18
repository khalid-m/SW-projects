;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Andrej Andrejev, UDBL
;;; $RCSfile: rdf-types.lsp,v $
;;; $Revision: 1.31 $ $Date: 2014/01/16 00:43:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Definition of RDF types and SciSparQL extentions
;;; =============================================================
;;; $Log: rdf-types.lsp,v $
;;; Revision 1.31  2014/01/16 00:43:01  andan342
;;; Added TIMEVAL functions from W3C specs,
;;; redefined sameTerm() in rdf-types.lsp as more strict equality
;;;
;;; Revision 1.30  2014/01/07 11:26:50  andan342
;;; bug fix with rdf:bound()
;;;
;;; Revision 1.29  2013/09/16 15:19:09  andan342
;;; Re-defined RDF arithmetics with cast()
;;;
;;; Revision 1.28  2013/09/10 13:40:10  andan342
;;; Added rdf:abs()
;;;
;;; Revision 1.27  2013/09/06 21:47:23  andan342
;;; - Moved definitions of standard SPARQL functions to sparql-fns.lsp, SciSPARQL functions to scisparql-fns.lsp
;;; - Implemented all SPARQL 1.1 string functions (except REPLACE, ENCODE_FOR_URI, langMAtches)
;;; - Redefined rdf:regex() using Amos functions like() and like_i()
;;;
;;; Revision 1.26  2013/02/21 23:34:45  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR,
;;; defined all SciSparql foreign functions as proxy-tolerant,
;;; updated the translator to enable truly lazy data retrieval
;;;
;;; Revision 1.25  2013/02/01 12:02:05  andan342
;;; Using same NMA descriptor objects as proxies
;;;
;;; Revision 1.24  2013/01/28 09:22:13  andan342
;;; Added MOD and DIV functions, cost hints, fixed bug when reading URIs with comma, TODO comments to improve error reporting
;;;
;;; Revision 1.23  2012/06/25 20:36:34  andan342
;;; Added TypedRDF and support for custom types in Turtle reader and SciSPARQL queries
;;; - rdf:toTypedRDF and rdf:strdf can be used as constructors in terms of RDF literals
;;; - rdf:str and rdf:datatype can be used as field accessors
;;;
;;; Revision 1.22  2012/06/13 15:02:37  andan342
;;; Added translation-phase condition reordering and BIND-dependency tracing to choose uni-directional or optimizable tranlation of '=' filters and BIND assignments
;;;
;;; Revision 1.21  2012/06/11 15:24:34  andan342
;;; Keeping track of unbound variables used in equality filters, enforcing EQUAL-- to avoid false positives
;;;
;;; Revision 1.20  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.19  2012/05/24 14:41:25  andan342
;;; More simplifications, prepared to remove #[UB] value
;;;
;;; Revision 1.18  2012/05/24 13:24:53  andan342
;;; Now always working with _amos-optional_ = T, removed that variable,
;;; Removed all notion of BOUND, SEMIBOUND, REBOUND, LINKED and MERGED variables from the translator
;;;
;;; Revision 1.17  2012/05/02 17:23:58  torer
;;; Can instruct SSDM to generate Amos queries with optional() by calling
;;; the Amos directive:
;;;
;;; amos_optional(true);
;;;
;;; Revision 1.16  2012/04/21 14:41:48  andan342
;;; Added MAX and MIN binary and aggregate functions, regression test for aggregate functions,
;;; fixed reader bug with negative numbers
;;;
;;; Revision 1.15  2012/04/14 16:05:24  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.14  2012/02/23 19:15:39  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.13  2012/02/14 13:39:29  andan342
;;; Added support for blank node isolation when loading multiple sources into store
;;;
;;; Revision 1.12  2012/02/10 15:33:25  andan342
;;; Added rdf:isNumeric(), now correctly translating queries without variables
;;;
;;; Revision 1.11  2012/02/10 11:47:50  andan342
;;; All Amos functions implementing SciSPARQL functions now have/get rdf: namespace
;;;
;;; Revision 1.10  2012/01/30 15:45:10  andan342
;;; Now partially evaluating all simple constructors.
;;; Added call to VERIFY-ALL to regression test, fixed related bugs
;;;
;;; Revision 1.9  2012/01/24 16:34:31  mikla885
;;; Made URI invertible.
;;;
;;; Revision 1.8  2012/01/24 15:12:20  andan342
;;; Sparql_translate(...) and (sparql-translate ...) functions added,
;;; minor bugs fixed
;;;
;;; Revision 1.7  2011/09/14 08:40:10  andan342
;;; Enabled arithmetics on RDF literals, added ADIMS accessor to SciSparql
;;;
;;; Revision 1.6  2011/05/23 19:59:40  andan342
;;; Encoding generated blank nodes as URIs starting with '-:b', to avoid colisions with explicit blank nodes, as '_:'
;;;
;;; Revision 1.5  2011/05/01 19:42:22  andan342
;;; Ported predicates and arithmetics, added type predicates and typecasting
;;;
;;; Revision 1.4  2011/04/20 15:24:59  andan342
;;; Now handling RDF data as triples of Literal type
;;;
;;; Revision 1.3  2011/04/13 21:14:45  andan342
;;; Addded Amos wrappers for RDF storage types
;;;
;;; Revision 1.2  2011/04/04 12:23:34  andan342
;;; Separated translator code from the parser code,
;;; added "SparQL tools"
;;;
;;; Revision 1.1  2011/03/08 13:02:26  andan342
;;; Introduced URI type into Amos type system
;;;
;;; =============================================================

;; unprefixed chapter numbers refer to http://www.w3.org/TR/sparql11-query/

;;TODO: IRI 17.4.2.8, BNODE 17.4.2.9, 
;;TODO: String Functions 17.4.3, except REGEX 17.4.3.14 in sparql-utils.lsp
;;TODO: Numeric functions 17.4.4, Date & Time functions 17.4.5, Hash functions 17.4.6

;; TRANSLATOR-SPECIFIC LISTS OF 'rdf:' FUNCTIONS

(defglobal _sq_aggregate_fns_ '("count" "sum" "min" "max" "avg"))

;TODO: _sq_literal_fns_ should be for both requiring non-proxy arguments and guarantee of returning non-proxy results

(defglobal _sq_proxy_intolerant_fns_ '("intdiv" "mod" "round"))

(defglobal _sq_literal_fns_ '("intdiv" "mod" "round" ; built-in functions returning literal values
                              "str" "lang" "tointeger" "todouble" "todateyime" "toboolean" "strlang" "strdt"
                              "isiri" "isblank" "isnumeric" "isliteral" "datatype"  "bound" 
                              "count" "sum" "min" "max" "avg"
                              "now" "year" "month" "day" "hours" "minutes" "seconds" "timezone" "tz" "sameTerm"))

;; AmosQL CONSTRUCTORS & ACCESSORS

(defun URI-+ (fno s r)
  (osql-result s (uri s)))

(defun URI+- (fno s r)
  (when (eq (typename r) 'uri)
    (osql-result (uri-id r) r)))

(defun empty-print (x str) nil)

;(defun UB+ (fno r)
;  (osql-result #[UB]))

(defun USTR--+ (fno str lang res)
  (osql-result str lang (ustr str lang)))

(defun USTR-+ (fno str res)
  (osql-result str (ustr str)))

(defun USTR-str-+ (fno x res)
  (when (eq (typename x) 'ustr)
    (osql-result x (ustr-str x))))

(defun USTR-lang-+ (fno x res)
  (when (eq (typename x) 'ustr)
    (osql-result x (ustr-lang x))))


(defun TypedRDF--+ (fno str typeuri res)
  (osql-result str typeuri (typedrdf str typeuri)))

(defun TypedRDF-str-+ (fno x res)
  (when (eq (typename res) 'typedrdf)
    (osql-result x (typedrdf-str x))))

(defun TypedRDF-typeuri-+ (fno x res)
  (when (eq (typename res) 'typedrdf)
    (osql-result x (typedrdf-typeuri x))))


(defun init-rdf-types ()
  (createliteraltype 'URI '(literal) 'URI 'empty-print)
;  (createliteraltype 'UB '(literal) 'UB 'empty-print)
  (createliteraltype 'USTR '(literal) 'USTR 'empty-print)
  (createliteraltype 'TypedRDF '(literal) 'TypedRDF 'empty-print)
  (osql "
create function URI(Charstring s key)-> URI r key
  as multidirectional 
  ('bf' foreign 'URI-+')
  ('fb' foreign 'URI+-');

create function URI_id(Literal x)-> Charstring s
  as select s where URI(s) = x;

/*create function UB() -> UB
  as foreign 'UB+';*/

create function USTR_str(Literal us) -> Charstring
  as foreign 'USTR-str-+';

create function USTR_lang(Literal us) -> Charstring
  as foreign 'USTR-lang-+';

create function USTR(Charstring str, Charstring lang) -> USTR res key
  as multidirectional 
  ('bbf' foreign 'USTR--+')
  ('ffb' select USTR_str(res), USTR_lang(res));

create function USTR(Charstring str) -> USTR
  as foreign 'USTR-+';

create function TypedRDF_str(Literal x) -> Charstring
  as foreign 'TypedRDF-str-+';

create function TypedRDF_typeuri(Literal x) -> URI
  as foreign 'TypedRDF-uri-+';

create function TypedRDF(Charstring str, URI typeuri) -> TypedRDF res key
  as multidirectional
  ('bbf' foreign 'TypedRDF--+')
  ('ffb' select TypedRDF_str(res), TypedRDF_typeuri(res));

create function TypedRDF(Charstring str, Charstring typeuri) -> TypedRDF res key
  as multidirectional
  ('bbf' select TypedRDF(str,URI(typeuri)))
  ('ffb' select TypedRDF_str(res), URI_id(TypedRDF_typeuri(res)));

/* Always partially evaluate simple constructors */

parteval('URI');
parteval('URI_id');

parteval('USTR');
parteval('USTR_str');
parteval('USTR_lang');

parteval('TypedRDF');
parteval('TypedRDF_str');
parteval('TypedRDF_typeuri');

/*parteval('UB');*/

"))

(init-rdf-types)

(defparameter _rdf_types_declared_ t)


;; AmosQL/SPARQL TYPE PREDICATES

(defun rdf-bound- (fno x)
  (unless  (or (null x) (eq x '*))
    (osql-result x)))

(osql "create function rdf:bound(Object x)->Boolean as foreign 'rdf-bound-';")

(defun rdf-notbound- (fno x)
  (when  (or (null x) (eq x '*))
    (osql-result x)))

(osql "create function rdf:notbound(Object x)->Boolean as foreign 'rdf-notbound-';")

(defun rdf-realtype-p (typeuri)
  "Test whether URI denotes an XMLS type compatible with AmosQL Real"
  (member typeuri '("http://www.w3.org/2001/XMLSchema#float"
		    "http://www.w3.org/2001/XMLSchema#double"
		    "http://www.w3.org/2001/XMLSchema#decimal")))
 
(foreign-lispfn rdf:isIRI ((Literal x)) ((Boolean)) ;17.4.2.1
		(when (and (eq (typename x) 'uri) (not (member (substring 0 0 (uri-id x)) '("_" "-")))) 
		  (foreign-result 'true)))

(osql "create function rdf:isURI(Literal x) -> Boolean as rdf:isIRI(x);") ;alias

(foreign-lispfn rdf:isBlank ((Literal x)) ((Boolean)) ;17.4.2.2
		(when (and (eq (typename x) 'uri) (member (substring 0 0 (uri-id x)) '("_" "-")))
		  (foreign-result 'true)))

(foreign-lispfn rdf:isLiteral ((Literal x)) ((Boolean)) ;17.4.2.3 ;TODO: should treat complex numbers similarly
		(when (or (member x '(true false)) (member (typename x) '(integer real ustr timeval typedrdf)))
		  (foreign-result 'true)))

(foreign-lispfn rdf:isNumeric ((Literal x)) ((Boolean)) ;17.4.2.4
		(when (member (typename x) '(integer real))
		  (foreign-result 'true)))

(foreign-lispfn rdf:datatype ((Literal x)) ((URI)) ;17.4.2.7	
		(let ((res (selectq (typename x)
				    (symbol (when (member x '(true false)) "boolean"))
				    (ustr (if (string= (ustr-lang x) "") "string"
					    (progn
					      (foreign-result (uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"))
					      nil)))
				    (typedrdf (foreign-result (typedrdf-typeuri x)) 
					      nil)
				    (uri "IRI")
				    (real "double")
				    (integer "integer")
				    (timeval "dateTime")
				    nil)))
		  (when res (foreign-result (uri (concat "http://www.w3.org/2001/XMLSchema#" res))))))

(defun isNumeric (x) (member (typename x) '(integer real)))

(foreign-lispfn comparable ((Literal x) (Literal y)) ((Boolean))
		(when (or (and (eq (typename x) (typename y)) 
			       (or (not (eq (typename x) 'typedrdf))
				   (= (typedrdf-typeuri x) (typedrdf-typeuri y))))
			  (and (isNumeric x) (isNumeric y)))
		  (foreign-result 'true)))
					    					   					   

;; Lisp/AmosQL/SPARQL TYPE CONVERTERS

(defun amos-timeval-timezone-to-sparql (tz)
  "Genearate RDF/SPARQL string representation of timezone stored with Amos TIMEVAL"
  (cond ((= tz (get-tz-reserved)) "") 
	((= tz 0) "Z")
	(t (concat (if (> tz 0) "-" "+") (leftpad (/ (abs tz) 3600) "0" 2) 
		   ":" (leftpad (mod (abs tz) 3600) "0" 2)))))

  
(defun amos-timeval-to-sparql (tv)
  "Generate RDF/SPARQL string representation of Amos TIMEVAL"
  (let ((dt (timevalz-to-date tv t)))
    (concat (leftpad (aref dt 0) "0" 4) "-" ;year
	    (leftpad (aref dt 1) "0" 2) "-" ;month
	    (leftpad (aref dt 2) "0" 2) "T" ;day
	    (leftpad (aref dt 3) "0" 2) "-" ;hour
	    (leftpad (aref dt 4) "0" 2) "-" ;minute
	    (leftpad (aref dt 5) "0" 2) ;second
	    (if (> (aref dt 6) 0) (concat "." (string-right-trim "0" (leftpad (aref dt 6) "0" 6))) "") ;microsecond
	    (amos-timeval-timezone-to-sparql (timeval-timezone tv))))) ;timezone

(defun rdf-to-string (x)   
  "Get string representation of RDF value according to 17.4.2.5"
  (selectq (typename x)
	   (symbol (when (member x '(true false)) (string-downcase (mkstring x))))
	   (ustr (ustr-str x))
	   (typedrdf (typedrdf-str x))
	   (uri (uri-id x))
	   ((real integer) (mkstring x))
	   (timeval (amos-timeval-to-sparql x))
	   nil))

(foreign-lispfn rdf:str ((Literal x)) ((USTR)) ;17.4.2.5
		(let ((res (rdf-to-string (apr x))))
		  (when res (foreign-result (ustr res)))))

(foreign-lispfn rdf_str ((Literal x)) ((Charstring)) ;AmosQL version
		(let ((res (rdf-to-string x)))
		  (when res (foreign-result res))))

(defun Literal2Double (x)
  "Try converting an RDF value to a floating-point number"
  (selectq (typename x)
	   (symbol (selectq x (true 1.0) (false 0.0) nil))
	   (integer (* x 1.0))
	   (real x)
	   (ustr (let ((rres (read (ustr-str x))))
		   (when (member (typename rres) '(real integer)) (Literal2double rres))))
	   nil))

(foreign-lispfn rdf:toDouble ((Literal x)) ((Real))
		(let ((res (Literal2Double (apr x))))
		  (when res (osql-result res))))

(defun Literal2Integer (x)
  "Try converting an RDF value to an integer"
  (selectq (typename x)
	   (symbol (selectq x (true 1) (false 0) nil))
	   (integer x)
	   (real (when (= 0 (mod x 1)) (round x)))
	   (ustr (let ((rres (read (ustr-str x))))
		   (when (member (typename rres '(real integer))) (literal2Integer rres))))
	   nil))

(foreign-lispfn rdf:toInteger ((Literal x)) ((Real))
		(let ((res (Literal2Integer (apr x))))
		  (when res (osql-result res))))

(defun rdf-str-to-timeval (dt)
  "Create Amos TIMEVAL based on RDF/SPARQL string reperesentation of date&time"
  (let* ((tzpos (string-rightpos dt '("+" "-" "Z") 17)) tzhead
	 (sec (read (substring 17 (1- (if tzpos tzpos (length dt))) dt))) 
	 (components (when (numberp sec) (list (read (substring 0 3 dt)) ;year
					       (read (substring 5 6 dt)) ;month
					       (read (substring 8 9 dt)) ;day
					       (read (substring 11 12 dt)) ;hour
					       (read (substring 14 15 dt)) ;minute
					       (floor sec) ;second
					       (round (* (mod sec 1) 1000000)))))) ;microsecond
    (when (and components (every #'numberp components))
      (date-to-timevalz (listtoarray components)
			(cond ((null tzpos) (get-tz-reserved)) ; unknown timezone
			      ((string= (setq tzhead (substring tzpos tzpos dt)) "Z") 0) ; Zulu time (UTC)
			      (t (let ((tzcomponents (string-explode (substring (1+ tzpos) (1- (length dt)) dt) ":"))) 
				   (* (if (string= tzhead "-") 1 -1) ; compute seconds West of Greenwich
				      (+ (* 3600 (read (first tzcomponents))) ; hours
					 (* 60 (if (second tzcomponents) (read (second tzcomponents)) 0))))))))))) ; minutes

(foreign-lispfn rdf:toDateTime ((Literal x)) ((Timeval))
		(let ((res (selectq (typename x)
				    (timeval x)
				    (ustr (rdf-str-to-timeval (ustr-str x)))
				    nil)))
		  (when res (foreign-result res))))

(foreign-lispfn rdf:toBoolean ((Literal x)) ((Boolean))
		(let* ((x0 (apr x))
		       (res (selectq (typename x0)
				     (symbol (when (member x0 '(true false)) x0))
				     ((integer real) (if (= x0 0) 'false 'true))
				     (ustr (cond ((string-like-i (ustr-str x0) "true") 'true)
						 ((string-like-i (ustr-str x0) "false") 'false)))
				     nil)))
		  (when res (foreign-result res))))

(osql "
create function rdf:toTypedRDF(Literal x) -> Literal res
  as select TypedRDF(rdf_str(x),rdf:datatype(x));
")

(defun rdf-strdt--+ (fno str typeuri res) ;17.4.2.10
  "Create RDF/SPARQL typed literal"
  (when (and (eq (typename str) 'ustr)
	     (eq (typename typeuri) 'uri))
    (osql-result str typeuri (typedrdf (ustr-str str) typeuri))))

(osql "
create function rdf:strdt(Literal str, Literal typeuri) -> Literal res key /* 17.4.2.10 */ 
  as multidirectional
  ('bbf' foreign 'rdf-strdt--+')
  ('ffb' select select USTR(TypedRDF_str(res)), TypedRDF_typeuri(res));

create function rdf:strlang(Literal str, Literal lang) -> Literal res key /* 17.4.2.11 */
  as multidirectional 
  ('bbf' select USTR(USTR_str(str),USTR_str(lang)))
  ('ffb' select USTR_str(res), USTR_lang(res));
")
	   						     						     
; LANGUAGE handling

(foreign-lispfn rdf:lang ((Literal x)) ((USTR)) ;17.4.2.6
		(when (eq (typename x) 'ustr)
		  (foreign-result (ustr (ustr-lang x)))))


;; EQUALITY (bound-only) & ASSIGNMENT (uni-directional)

(defun rdf-equal-- (fno x y)
  (when (and (equal x y) (not (eq x '*)))
    (osql-result x y)))

(defun rdf-bind-+ (fno x y)
  (unless (eq x '*)
    (osql-result x x)))

(osql "
create function rdf:equal(Literal x, Literal y) -> Boolean
   as multidirectional 
      ('bb' foreign 'rdf-equal--');

create function rdf:bind(Literal x) -> Literal
   as multidirectional
      ('bf' foreign 'rdf-bind-+');
")

;; ARITHMETICS

(osql "
create function rdf:plus(Literal x, Literal y) -> Literal z
   as cast(x as number) + cast(y as number); 

create function rdf:minus(Literal x, Literal y) -> Literal z
   as cast(x as number) - cast(y as number); 

create function rdf:times(Literal x, Literal y) -> Literal z
  as cast(x as number) * cast(y as number);

create function rdf:div(Literal x, Literal y) -> Literal z
   as cast(x as number) / cast(y as number);

create function rdf:round(Literal x) -> Literal z
   /* Round number n to an integer */ 
  as round(cast(x as number));

create function rdf:intdiv(Literal x, Literal y) -> Literal z
   as select rdf:div(rdf:round(x), y);

create function rdf:mod(Literal x, Literal y) -> Literal z
  /* Remainder when dividing number n with x */
  as mod(cast(x as number), cast(y as number));

create function rdf:abs(Literal x) -> Literal z
  /* Return absolute value of x */
  as abs(cast(x as number));     
")

;; TEMPORAL FUNCTIONS 17.4.5

(osql "
create function rdf:now() -> Literal 
  as now();

/* The following functions project TIMEVAL to its own timezone,
   in contrast to similar Amos functions, that project it to local timezone */

create function rdf:year(Literal x) -> Literal
  as timevalz_to_date(cast(x as Timeval))[0];

create function rdf:month(Literal x) -> Literal
  as timevalz_to_date(cast(x as Timeval))[1];

create function rdf:day(Literal x) -> Literal
  as timevalz_to_date(cast(x as Timeval))[2];

create function rdf:hours(Literal x) -> Literal
  as timevalz_to_date(cast(x as Timeval))[3];

create function rdf:minutes(Literal x) -> Literal
  as timevalz_to_date(cast(x as Timeval))[4];

create function rdf:seconds(Literal x) -> Literal
  as select zd[5] + 0.000001 * zd[6]
       from Vector of Integer zd
      where zd = timevalz_to_date(cast(x as Timeval));
")

(foreign-lispfn rdf:timezone ((Literal tv)) ((TypedRDF)) 
		(let (tz)
		  (when (and (timevalp tv) (not (= (setq tz (timeval-timezone tv)) (get-tz-reserved))))
		    (foreign-result (typedrdf (concat (if (> tz 0) "-" "") "PT" (mkstring (abs tz)) "S")
					      (uri "http://www.w3.org/2001/XMLSchema#dayTimeDuration"))))))

(foreign-lispfn rdf:tz ((Literal tv)) ((USTR)) 
		(when (timevalp tv)
		  (foreign-result (ustr (amos-timeval-timezone-to-sparql (timeval-timezone tv))))))

(foreign-lispfn rdf:sameTerm ((Literal x) (Literal y)) ((Literal)) ; more strict equality
		(when (and (eq (typename x) (typename y))
			   (equal x y)
			   (cond ((timevalp x)
				  (= (timeval-timezone x) (timeval-timezone y)))
				 (t t)))
		  (foreign-result 'true)))
				  
				  