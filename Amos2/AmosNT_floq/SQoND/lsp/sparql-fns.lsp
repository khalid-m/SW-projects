;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-2013 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-fns.lsp,v $
;;; $Revision: 1.5 $ $Date: 2014/01/16 00:43:02 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Standard SPARQL 1.1 functions
;;; =============================================================
;;; $Log: sparql-fns.lsp,v $
;;; Revision 1.5  2014/01/16 00:43:02  andan342
;;; Added TIMEVAL functions from W3C specs,
;;; redefined sameTerm() in rdf-types.lsp as more strict equality
;;;
;;; Revision 1.4  2013/10/03 13:04:28  andan342
;;; Fixed mistype
;;;
;;; Revision 1.3  2013/09/29 15:32:32  andan342
;;; Added langMatches() as specified in http://www.ietf.org/rfc/rfc4647.txt
;;; Added sameTerm() as synonym for equality
;;;
;;; Revision 1.2  2013/09/07 19:06:03  andan342
;;; - added ENCODE_FOR_URI() function,
;;; - no special translation is now done for REGEX(),
;;; - n-ary CONCAT() is enabled
;;;
;;; Revision 1.1  2013/09/06 21:47:24  andan342
;;; - Moved definitions of standard SPARQL functions to sparql-fns.lsp, SciSPARQL functions to scisparql-fns.lsp
;;; - Implemented all SPARQL 1.1 string functions (except REPLACE, ENCODE_FOR_URI, langMAtches)
;;; - Redefined rdf:regex() using Amos functions like() and like_i()
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Depends on:
;; _sq_string_based_
;; _sq_literal_fns_

;; -------------------- REGEX ----------------------------

; Implementation of RDF regex() function according to http://www.w3.org/TR/sparql11-query/#func-regex
; following regular expression definition in http://www.w3.org/TR/xpath-functions/#regex-syntax
; 
; 's' option is always on, i.e. #0A character can be matched by .* and .? 
; 'm' option - multiline mode (TODO) can be defined as 2 or 4 calls to like() or like_i()
; 'x' option - whitespace removal (TODO) behavior can be added into sparql-regex-to-amosql preprocessor

(setq _sq_literal_fns_ (cons "regex" _sq_literal_fns_))

(defun sparql-regex-to-amosql (regex)
  "convert SparQL REGEX format to Amos LIKE pattern"
  (let ((lastpos (1- (length regex))) regex1)
    (setq regex1 (if (string-pos regex "^") (substring 1 lastpos regex) (concat "*" regex))) ; left anchoring
    (setq regex1 (if (string-pos regex1 "$") (substring 0 lastpos regex1) (concat regex1 "*"))) ; right anchoring
    (string-remove-cont-duplicates (string-substitute regex1 '((".*" . "*"))) "*")))

(defun rdf-regex2like-+ (fno pat res)
  (selectq (typename pat)
	   (string (osql-result pat (sparql-regex-to-amosql pat)))
	   (ustr (osql-result pat (sparql-regex-to-amosql (ustr-str pat))))
	   nil))
			      

(osql "
create function regex2like(Literal pat) -> Charstring as foreign 'rdf-regex2like-+';

parteval('regex2like');
")

(if _sq_string_based_
(osql "
create function rdf:regex(Charstring x, Charstring pat) -> Boolean
  as like(x, regex2like(pat));

create function rdf:regex(Charstring x, Charstring pat, Charstring opt) -> Boolean
  as (like(x, regex2like(pat)) and notany(like(opt, '*i*')))
   or(like_i(x, regex2like(pat)) and like(opt, '*i*'));
")
(osql "
create function rdf:regex(Literal x, Literal pat) -> Boolean
  as like(USTR_str(x), regex2like(pat));

create function rdf:regex(Literal x, Literal pat, Literal opt) -> Boolean
  as (like(USTR_str(x), regex2like(USTR_str(pat))) and notany(like(USTR_str(opt), '*i*')))
   or(like_i(USTR_str(x), regex2like(USTR_str(pat))) and like(USTR_str(opt), '*i*'));
"))

;; ------------------- STRSTARTS, STRENDS, CONTAINS, STRBEFORE, STRAFTER ------------

(setq _sq_literal_fns_ (append _sq_literal_fns_ '("strstarts" "strends" "contains" "strbefore" "strafter")))

(defun str_pos--+ (fno x y res)
  (setq res (string-pos x y))
  (when res
    (osql-result x y res)))

(osql "
create function str_pos(Charstring x, Charstring y) -> Integer as foreign 'str_pos--+';
")

(defun str_compatible-- (fno x y)
  (when (or (string= (ustr-lang y) "")
	    (string= (ustr-lang y) (ustr-lang x)))
    (osql-result x y)))

(if _sq_string_based_
(osql "
create function rdf:strstarts(Charstring x, Charstring y) -> Boolean 
  as like(x, y+'*');

create function rdf:strends(Charstring x, Charstring y) -> Boolean 
  as like(x, '*'+y);

create function rdf:contains(Charstring x, Charstring y) -> Boolean 
  as like(x, '*'+y+'*');

create function rdf:strbefore(Charstring x, Charstring y) -> Charstring
  as substring(x, 0, str_pos(x, y)-1);

create function rdf:strafter(Charstring x, Charstring y) -> Charstring
  as substring(x, str_pos(x, y)+char_length(y), char_length(x)-1);
")
(osql "
create function str_compatible(Literal x, Literal y) -> Boolean as foreign 'str_compatible--';

create function rdf:strstarts(Literal x, Literal y) -> Boolean 
  as like(USTR_str(x), USTR_str(y)+'*') and str_compatible(x, y);

create function rdf:strends(Literal x, Literal y) -> Boolean 
  as like(USTR_str(x), '*'+USTR_str(y)) and str_compatible(x, y);

create function rdf:contains(Literal x, Literal y) -> Boolean 
  as like(USTR_str(x), '*'+USTR_str(y)+'*') and str_compatible(x, y);

create function rdf:strbefore(Literal x, Literal y) -> Literal
  as select USTR(substring(xs, 0, str_pos(xs, USTR_str(y))-1), USTR_lang(x))
       from Charstring xs
      where str_compatible(x, y)
        and xs = USTR_str(x);

create function rdf:strafter(Literal x, Literal y) -> Literal
  as select USTR(substring(xs, str_pos(xs, ys)+char_length(ys), char_length(xs)-1), USTR_lang(x))
       from Charstring xs, Charstring ys
      where str_compatible(x, y)
        and xs = USTR_str(x)
        and ys = USTR_str(y);
"))

;; ------------------- STRLEN, UCASE, LCASE, CONCAT

(setq _sq_literal_fns_ (append _sq_literal_fns_ '("strlen" "ucase" "lcase" "concat")))

(if _sq_string_based_ 
(osql " 
create function rdf:strlen(Charstring x) -> Charstring
  as stringify(char_length(x));

create function rdf:ucase(Charstring x) -> Charstring
  as upper(x);

create function rdf:lcase(Charstring x) -> Charstring
  as lower(x);

create function rdf:concat(Charstring x, Charstring y) -> Charstring
  as x + y;
")
(osql "
create function rdf:strlen(Literal x) -> Literal
  as char_length(USTR_str(x));

create function rdf:ucase(Literal x) -> Literal
  as USTR(upper(USTR_str(x)), USTR_lang(x));

create function rdf:lcase(Literal x) -> Literal
  as USTR(lower(USTR_str(x)), USTR_lang(x));

create function rdf:concat(Literal x, Literal y) -> Literal
  as select USTR(USTR_str(x) + USTR_str(y), reslang)
       from Charstring reslang
      where (reslang = USTR_lang(x) and reslang = USTR_lang(y))
         or (reslang = '' and USTR_lang(x) != USTR_lang(y));
"))

;; ------------------- SUBSTR ---------------------

(setq _sq_literal_fns_ (append _sq_literal_fns_ '("substr")))

(unless _sq_string_based_ (osql "
create function rdf:substr(Literal x, Literal start) -> Literal
  as select USTR(substring(xs, cast(start as Integer)-1, char_length(xs)-1), USTR_lang(x))
       from Charstring xs
      where xs = USTR_str(x)
        and typenamed('integer') in typesof(start);

create function rdf:substr(Literal x, Literal start, Literal length) -> Literal
  as select USTR(substring(xs, starti-1, starti+cast(length as Integer)-2), USTR_lang(x))
       from Charstring xs, Type integerType, Integer starti
      where xs = USTR_str(x)
        and starti = cast(start as Integer)
        and integerType = typenamed('integer')
        and integerType in typesof(start)
        and integerType in typesof(length);
"))

;;---------------- %-BASED ESCAPES ------------------

(defun escape-percent (str)
  (let ((i (1- (length str))) cc)
    (while (>= i 0)
      (setq cc (substring i i str)) 
      (unless (or (basechar-p cc) (member cc '("." "-" "~")))
	(setq str (concat (if (= i 0) "" (substring 0 (1- i) str))
			  "%" (hex (char-int cc) 2)
			  (substring (1+ i) (1- (length str)) str))))
      (decf i))
    str))

(defun unescape-percent (str)
  (let ((i (- (length str) 3)))
    (while (>= i 0)
      (when (string= (substring i i str) "%")
	(setq str (concat (if (= i 0) "" (substring 0 (1- i) str))
			  (int-char (unhex (substring (1+ i) (+ i 2) str)))
			  (substring (+ i 3) (1- (length str)) str))))
      (decf i))
    str))

(defun escape_percent-+ (fno str res)
  (osql-result str (escape-percent str)))

(defun escape_percent+- (fno str res)
  (osql-result (unescape-percent res) res))

(osql "
create function escape_percent(Charstring str) -> Charstring 
as multidirectional
  ('bf' foreign 'escape_percent-+')
  ('fb' foreign 'escape_percent+-');
")

(if _sq_string_based_
(osql "
create function rdf:encode_for_uri(Charstring str) -> Charstring
  as escape_percent(str);
")
(osql "
create function rdf:encode_for_uri(Literal str) -> Literal
  as USTR(escape_percent(USTR_str(str)));
"))

;; -------------------- langMatches ---------------------------

;; Algorithm from section 3.3.2 of http://www.ietf.org/rfc/rfc4647.txt

(defun lang-tag-match (tag range)
  (let* ((tag-e (string-explode tag "-")) ;1
	 (range-e (string-explode range "-"))
	 (st (pop tag-e)) ;2
	 (rst (pop range-e)))
    (if (or (string-like-i st rst)
	    (string= rst "*"))
      (progn
	(setq st (pop tag-e))
	(setq rst (pop range-e))
	(loop ;3
	  (cond ((null rst) ;4
		 (return t))
		((string= rst "*") ;A
		 (setq rst (pop range-e)))
		((null st) ;B
		 (return nil))
		((string-like-i st rst) ;C
		 (setq st (pop tag-e))
		 (setq rst (pop range-e)))
		((= (length st) 1) ;D
		 (return nil))
		(t ;E
		 (setq st (pop tag-e)))
		)))
      nil)))

(defun rdf-langMatches-- (fno tag range)
  (when (lang-tag-match tag range)
    (osql-result tag range)))

(if _sq_string_based_
(osql "
create function rdf:langMatches(Charstring tag, Charstring range) -> Boolean as foreign 'rdf-langMatches--';
")
(osql "
create function langMatches(Charstring tag, Charstring range) -> Boolean as foreign 'rdf-langMatches--';

create function rdf:langMatches(Literal tag, Literal range) -> Boolean 
  as langMatches(USTR_str(tag), USTR_str(range));
"))			 
