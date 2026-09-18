;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SPARQL LEXER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;SparQL lexer based on http://www.w3.org/TR/rdf-sparql-query/
;;Author: Andrej Andrejev, 2010

;;TODO: Add "long" strings

;;TODO: URI is assumed to begin with anything except whitespace, digit or [!+-"'?$].
;; However, according to http://en.wikipedia.org/wiki/URI_scheme#Generic_syntax, it should only begin with a letter

;;TODO: "A" keyword is equivalent to "a", (all other keywords are also case-insensitive)

(defun whitespace-p (ch) (member (char-int ch) '(9 10 32)))

(defun digit-p (ch) (and (>= (char-int ch) 48) (<= (char-int ch) 57)))

(defun basechar-p (ch) (let ((ci (char-int ch)))			
			 (or 
			  (and (>= ci 65) (<= ci 90)) ;; A-Z
			  (= ci 95) ;; underscore
			  (and (>= ci 97) (<= ci 122)) ;; a-z			 
			  (= ci 183) ;; middle dot
			  (and (>= ci 192) (<= ci 255) (not (= ci 215)) (not (= ci 247)))))) ;;letters from Latin-1

(defstruct lexer-tape str (pos 0))

(defun sparql-lexer (tape)
  (do ((state :general) (ch nil) (ch0 nil) (pos 0) (pos0 0) (buf ""))
      (nil nil) ; never return normally          
    (setq pos (lexer-tape-pos tape))
    (setq ch (substring pos pos (lexer-tape-str tape)))
    (incf (lexer-tape-pos tape))
    (labels ((subtape (start end) (substring start end (lexer-tape-str tape)))
	     (bufferize (start end) (setq buf (concat buf (subtape start end))))
	     (stepback () (decf (lexer-tape-pos tape))))
      (selectq state
	       (:general (cond 
			  ((string= ch "") (return nil)) ;;return end-marker
			  ((string= ch "^") (setq state :after-cap))
			  ((string= ch "!") (setq state :after-wow))
			  ((string= ch "|") (setq state :after-bar))
			  ((string= ch "&") (setq state :after-ampersand))			 
			  ((string= ch "<") (setq state :after-left-angle-bracket))
			  ((string= ch ">") (setq state :after-right-angle-bracket))
			  ((string= ch ".") (setq state :after-dot))
			  ((string= ch "{") (return '(left-brace)))
			  ((string= ch "}") (return '(right-brace)))
			  ((string= ch "_") (return '(underscore)))
			  ((string= ch ",") (return '(comma)))
			  ((string= ch ";") (return '(semicolon)))
			  ((string= ch "=") (return '(equal)))
			  ((string= ch "+") (return '(plus)))
			  ((string= ch "-") (return '(minus)))
			  ((string= ch "*") (return '(times)))
			  ((string= ch "/") (return '(divide)))
			  ((string= ch "(") (return '(left-par)))
			  ((string= ch ")") (return '(right-par)))
			  ((string= ch "[") (return '(left-bracket)))
			  ((string= ch "]") (return '(right-bracket)))
			  ((string= ch "#") (setq state :comment))
			  ((string= ch ":") (setq state :localname) (setq pos0 (1+ pos)))
			  ((string= ch "@") (setq state :langtag) (setq pos0 (1+ pos)))
			  ((member ch '("'" "\"")) (setq state :string) (setq ch0 ch) (setq pos0 (1+ pos)))
			  ((member ch '("?" "$")) (setq state :var) (setq pos0 (1+ pos)))
			  ((whitespace-p ch)) ;;ignore whitespaces
			  ((digit-p ch) (setq state :number) (setq pos0 pos) (setq ch0 ch))
			  ((basechar-p ch) (setq state :id) (setq pos0 pos))
			  (t (error (concat "Invalid symbol: " ch " at pos " pos) nil))))
	       (:after-cap (if (string= ch "^") (return '(double-cap))
			     (error (concat "Invalid symbol: ^ at pos " (1- pos)) nil)))
	       (:after-wow (if (string= ch "=") (return '(not-equal))
			     (progn (stepback) (return '(not))))) ;;process same CH in general state
	       (:after-bar (if (string= ch "|") (return '(or))
			     (error (concat "Invalid symbol: | at pos " (1- pos)) nil)))
	       (:after-ampersand (if (string= ch "&") (return '(and))
				   (error (concat "Invalid symbol: & at pos " (1- pos)) nil)))
	       (:after-left-angle-bracket (cond
					   ((string= ch "=") (return '(less-or-equal)))
					   ((or (whitespace-p ch) (digit-p ch) (member ch '("!" "+" "-" "(" "\"" "'" "?" "$"))) ;;precedence of "less"
					    (stepback) (return '(less))) ;;process same CH in general state
					   (t (setq state :iri) (setq pos0 pos))))
	       (:after-right-angle-bracket (if (string= ch "=") (return '(greater-or-equal))
					     (progn (stepback) (return '(greater))))) ;;process same CH in general state
	       (:after-dot (if (digit-p ch) (progn (setq state :number) (setq pos0 (1- pos)))
			     (progn (stepback) (return '(dot)))))
	       (:localname (unless (or (digit-p ch) (basechar-p ch) (member ch '("." "-"))) ;allow letters, digits '-' and '.' in local (prefixed) names
			    (stepback) (return (cons 'localname (subtape pos0 (1- pos))))))
	       (:langtag (unless (or (basechar-p ch) (string= ch "-"))
			   (stepback) (return (cons 'langtag (subtape pos0 (1- pos))))))
	       (:iri (cond
		      ((string= ch "") (error (concat "Unterminated IRI at pos " (1- pos)) nil))
		      ((string= ch ">") 
		       (bufferize pos0 (1- pos)) (return (cons 'iri buf)))
		      ((whitespace-p ch) ;;remove inner whitespaces from IRI
		       (when (< pos0 pos) (bufferize pos0 (1- pos)))
		       (setq pos0 (1+ pos)))))
	       (:var (unless (or (digit-p ch) (basechar-p ch))
		       (if (< pos0 pos) (progn (stepback) ;;process same CH in general state
					       (return (cons 'var (string-downcase (subtape pos0 (1- pos))))))
			 (error (concat "Variable name expected at pos " pos) nil))))
	       (:id (unless (or (digit-p ch) (basechar-p ch))
		      (bufferize pos0 (1- pos))
		      (stepback) ;;process same CH in general state
		      (if (member (string-upcase buf) 
				  '("BASE" "PREFIX" "SELECT" "CONSTRUCT" "DESCRIBE" "ASK" "ORDER" "BY" "LIMIT" "OFFSET" "DISTINCT"
				    "REDUCED" "FROM" "NAMED" "WHERE" "GRAPH" "OPTIONAL" "UNION" "FILTER" "A" "STR" "LANG"
				    "LANGMATCHES" "DATATYPE" "BOUND" "SAMETERM" "ISURI" "ISIRI" "ISLITERAL" "REGEX" "TRUE" "FALSE"
				    "COUNT" "SUM" "MIN" "MAX" "AVG")) ;;Virtuoso-style aggregates
			  (return (list (mksymbol buf)))
			(return (cons 'id (string-downcase buf))))))
	       (:string (cond
			 ((string= ch "") (error (concat "Unterminated string started at pos " pos0) nil))
			 ((string= ch "\\") (bufferize pos0 (1- pos)) (setq pos0 (+ pos 2)) (setq state :escape))
			 ((string= ch ch0) (bufferize pos0 (1- pos)) (return (cons 'string buf))))) ;; CH0 stores the opening string delimeter
	       (:escape (cond ;;carriage return is ignored, backspace and form feed are not supported
			 ((string= ch "t" (setq buf (concat buf (int-char 9))))) ;;tab
			 ((string= ch "n" (setq buf (concat buf (int-char 10))))) ;;newline 
			 ((member ch '("\\" "'" "\"")) (setq buf (concat buf ch)))) ;;bufferize these characters
			(setq state :string))
	       (:number (cond
			 ((string= (string-upcase ch) "E") (setq state :number-after-e))
			 ((or (digit-p ch) (string= ch ".")) (setq ch0 ch)) ; remember last character
			 (t (stepback)  ; return a number without exponent part
			    (bufferize pos0 (1- pos)) 
			    (when (string= ch0 ".") (setq buf (concat buf "0"))) ; trailing dot is not allowed in AmosQL number representation
			    (return (cons 'number buf)))))
	       (:number-after-e (if (or (digit-p ch) (member ch '("+" "-"))) 
				    (progn (setq ch0 ch) (setq state :number-exponent))
				  (error (concat "Exponent expected at pos " pos) nil)))
	       (:number-exponent (cond 
				  ((digit-p ch) (setq ch0 ch)) ;; CH0 holds last character of a number
				  ((digit-p ch0) (stepback) (return (cons 'number (subtape pos0 (1- pos))))) ;; which should end with a digit
				  (t (error (concat "Exponent expected at pos " pos) nil))))
	       (:comment (when (or (string= ch "") (= (char-int ch) 10)) (setq state :general)))
	       t))))

(defparameter terminals
  '((-! . "<end_of_query>")
    (iri . "<IRI>")
    (var . "?<variable>")
    (id . "<id>")
    (string . "<string>")
    (number . "<number>")
    (localname . ":<local_name>")
    (langtag . "@<language_tag>")
    (left-brace . "{")
    (right-brace . "}")
    (underscore . "_")
    (comma . ",")
    (semicolon . ";")
    (equal . "=")
    (plus . "+")
    (minus . "-")
    (times . "*")
    (divide . "/")
    (left-par . "(")
    (right-par . ")")
    (left-bracket . "[")
    (right-bracket . "]")
    (double-cap . "^^")
    (not-equal . "!=")
    (not . "!")
    (or . "||")
    (and . "&&")
    (less-or-equal . "<=")
    (less . "<")
    (greater-or-equal . ">=")
    (greater . ">")
    (dot . ".")))

(defun print-lexems (query)
  (do* ((tape (make-lexer-tape :str query))
	(lexem (sparql-lexer tape) (sparql-lexer tape)))
      ((null lexem) t)
    (print lexem)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SYNTAX PARSER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Grammar is specified in slr1-grammar.lsp

(load "sparql-lsp-parser-datamodel.lsp")

(load "slr1-parser.lsp")

(defun syntax-error-msg (res)
  (let ((ts "") t-str)
    (dolist (terminal (third res))
      (unless (string= ts "") (setq ts (concat ts " ")))
      (setq t-str (assoc terminal terminals))
      (setq ts (concat ts (if t-str (cdr t-str) terminal))))
    (setq t-str (assoc (fourth res) terminals))
    (concat "Input: " (if t-str (cdr t-str) (fourth res)) " Expected: " ts)))

(defun sparql-parse (query)
  (let ((tape (make-lexer-tape :str query)) res)
    (setq res (slr1-parser (f/l () (sparql-lexer tape))))
    (cond ((eq (car res) 'syntax-error) 
	   (error (concat "Syntax error at pos " (lexer-tape-pos tape) ": " (syntax-error-msg res))))
	  (t res))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRANSLATOR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "sparql-utils.lsp")

(defun iri-to-amos-function (iri) ;; NTriples-specific mapping
  (if (string= (substring 0 6 iri) "file://")
      (concat "ntriples('" (substring 7 (1- (length iri)) iri) "')")
    "UNKNOWN_IRI()"))

(defparameter nlt (concat (int-char 10) (int-char 9))) ;;newline+tab

(defun strings-to-string (strings prefix separator)
  (do ((s1 strings (cdr s1)) (res ""))
      ((null s1) res)
    (unless (string= (car s1) "")
      (unless (string= res "")
	(setq res (concat res separator)))
      (setq res (concat res prefix (car s1))))))

(defun sparql-expr-to-rdfr (e p s)
  (selectq (first e)
	   (var (let ((subst (assoc (cdr e) s))) ;substitute variable names inside OPTIONAL conditions
		  (if subst (cdr subst) (cdr e))))
	   ((iri prefixed) (concat "rdfr_iri(" (sparql-expr-to-amosql e p s nil) ")"))
	   (literal (if (fourth e) 
			(concat "rdfr(1,'" (second e) "','" (third e) "'," (sparql-expr-to-amosql (fourth e) p s nil) ")")
		      (concat "rdfr_string('" (second e) "','" (if (third e) (third e) "") "')")))
	   (number (concat "rdfr_number(" (cdr e) ")"))
	   ((+ - * /) (concat "rdfr_number(" (sparql-expr-to-amosql e p s nil) ")"))
	   "")) ;;default case: expression not translated

(defun sparql-expr-to-amosql (e p s outer-op)
  (selectq (first e)
	   (var (concat "rdfr_data(" (sparql-expr-to-rdfr e p s) ")"))
	   (iri (concat "'" (cdr e) "'"))
	   (prefixed (concat "'" (cdr (assoc (second e) p)) (third e) "'"))
	   (literal (concat "'" (second e) "'"))
	   (number (cdr e)) ;;AmosQL representation of a number stored as string
	   ((= != < > <= >= + - * / and or) 
	    (if (and (member (first e) '(= !=)) (member (car (second e)) '(var literal)) (member (car (third e)) '(var literal)))
		(concat (if (eq (first e) '=) "rdfr_eq(" "rdfr_neq(") ;;perform W3C-complient RDFR comparison
			(sparql-expr-to-rdfr (second e) p s) "," (sparql-expr-to-rdfr (third e) p s) ")")
	      (let ((res (concat (if (third e) (concat (sparql-expr-to-amosql (second e) p s (first e)) " ") "") ;;perform AmosQL native comparison
				 (string-downcase (mkstring (first e))) " " (sparql-expr-to-amosql (car (last e)) p s (first e)))))
		(if (or (member outer-op '(= != < > <= >= and or)) (and (member outer-op '(* /)) (member (first e) '(+ -))))
		    (concat "(" res ")") res)))) ;;enclose in parenthes only if required by AmosQL syntax
	   ((true false) (mkstring (first e))) ;;AmosQL constants
	   (not (let ((opposite-op (cdr (assoc (caadr e) '((= . !=) (< . >=) (> . <=) (true . false) (!= . =) (>= . <) (<= . >) (false . true)))))) 
		  (cond (opposite-op (sparql-expr-to-amosql (cons opposite-op (cdadr e)) p s outer-op)) ;;since there is no 'not' in AmosQL, perform rewrites
			((member (caadr e) '(+ - * / number)) (sparql-expr-to-amosql (list '= (cadr e) '(number . 0)) p s outer-op)) ;;not(number) -> number = 0
			((member (caadr e) '(var literal)) (concat ("rdfr_false(" (sparql-expr-to-rdfr (cadr e) p s) ")")))
			(t "false")))) ;;the case for IRIs
	   "")) ;;default case: expression not translated

(defun sparql-condition-to-amosql (c triples-fn p bound-vars s)
  (selectq (car c)
	   (triple (list (concat triples-fn "=<" 
				 (strings-to-string (mapcar (f/l (e) (sparql-expr-to-rdfr e p s)) 
							    (cdr c)) "" ", ") ">")))
	   (filter (list (sparql-expr-to-amosql (cdr c) p s nil)))
	   (regex (list (concat "like(" (sparql-expr-to-amosql (second c) p s nil) ",'" (aregex (third c)) "')")))
	   (optional (let ((res nil))
		       (unless s ; do not process from within another OPTIONAL block, such blocks are flattened
			 (labels ((get-o-var (es bound-vars)
					     (dolist (e es)
					       (cond ((and (eq (car e) 'var) (not (member (cdr e) bound-vars))) 
						      (return (cdr e))) ; O-VAR found
						     ((listp (cdr e)) ; process expressions recursively
						      (let ((ov (get-o-var (cdr e) bound-vars))) (when ov (return ov)))))))
				  (optional-to-amosql (conds outer-optionals)
						      (let ((o-var nil) (bound-vars-ex (append bound-vars outer-optionals))) ; (1) find the optional variable
							(dolist (oc conds) 
							  (when (eq (car oc) 'triple) ; bound by some triple condition of this block
							    (when (setq o-var (get-o-var (cdr oc) bound-vars-ex)) (return t)))) ; and not bound in basic block or outer optional blocks 
							(when o-var ; (2) translate this optional block
							  (push (concat o-var " = optional((select " o-var "_o from RDFResource " o-var "_o where "
									(strings-to-string 
									 (append ; translate conditions as normal with o-var name substitution
									  (mapcan (f/l (co) (sparql-condition-to-amosql co triples-fn p nil ; nested optionals not precessed here
															(list (cons o-var (concat o-var "_o"))))) conds) 
									  (mapcar (f/l (oo-var) (concat "rdfr_neq(" oo-var ",rdfr_nil())")) outer-optionals)) ; add outer-optional conds
									 "" (concat nlt (int-char 9) "and ")) "),rdfr_nil())") res)
							  (dolist (oc conds)
							    (when (eq (car oc) 'optional) ; (3) translate nested optional blocks
							      (optional-to-amosql (cdr oc) (cons o-var outer-optionals))))))))
			   (optional-to-amosql (cdr c) nil))) ; process optional blocks recursively, gathering the results in RES
		       (nreverse res)))
	   nil)) ;;default case: condition not translated		   	  		   

(defun sparql-to-amosql (query)
  (let* ((pq (sparql-parse query))
	 (stat (second pq)))
    (cond ((select-stat-p stat) ;;SELECT queries
	   (let ((triples-fn (iri-to-amos-function (select-stat-from stat)))
		 (all-vars nil) (bound-vars nil) (agg-expr nil) sel-clause res)
	     (labels ((collect-expr-vars (e collect-bound)
					 (when  (member (car e) '(count sum min max avg)) (setq agg-expr e)) ;; anyway expect at most 1 aggregate expression
					 (cond ((eq (car e) 'var)
						(unless (member (cdr e) all-vars) (push (cdr e) all-vars))  ;; collect into ALL-VARS
						(when (and collect-bound (not (member (cdr e) bound-vars))) 
						  (push (cdr e) bound-vars))) ;; collect vars defined in triples outside OPTIONAL blocks in BOUND-VARS
					       ((listp (cdr e)) ;; process subexpressions recursively
						(dolist (sub-e (cdr e)) 
						  (when (consp sub-e) (collect-expr-vars sub-e collect-bound))))))
		      (collect-cond-vars (c base-block)
					 (if (eq (car c 'optional)) (dolist (oc (cdr c)) (collect-cond-vars oc nil)) ;; extract from OPTIONAL block conditions
					   (dolist (term (cdr c)) ;;extract all variables from condition terms		 
					     (when (consp term) (collect-expr-vars term (and (eq (car c) 'triple) base-block)))))))
	       (dolist (se (select-stat-what stat)) (collect-expr-vars se nil)) ;;collect variables from selection expressions
	       (dolist (c (select-stat-where stat)) (collect-cond-vars c t)) ;;collect variables from conditions
	       (setq sel-clause (strings-to-string (mapcar (f/l (se) (sparql-expr-to-rdfr se (first pq) nil)) ;;aggregate expressions are not translated
							    (select-stat-what stat)) "" ", "))
	       (setq res (concat "select " (if agg-expr (concat "{" sel-clause "}, " (sparql-expr-to-rdfr (second agg-expr) (first pq) nil)) sel-clause) nlt
				 "from " (strings-to-string all-vars "RDFResource " ", ") nlt
				 "where " (strings-to-string (mapcan (f/l (c) (sparql-condition-to-amosql 
									       c triples-fn (first pq) bound-vars nil))
								     (select-stat-where stat)) "" (concat nlt "and "))))
	       (when agg-expr (setq res (concat "groupby((" res "),#'" (if (eq (first agg-expr) 'count) "count"
									 (concat "rdfr_" (string-downcase (mkstring (first agg-expr))))) "')")))
	       (concat res ";"))))
	  t "")))
	  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; WRAPPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn parse_sparql ((Charstring query)) ((Charstring))
		(foreign-result (sparql-to-amosql query)))

(osql "create function sparql(Charstring sparql)->Vector as select evalv(parse_sparql(sparql));")
      