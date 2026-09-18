;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-lsp-parser.lsp,v $
;;; $Revision: 1.22 $ $Date: 2012/02/24 14:44:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SparQL to AmosQL translator, main file
;;; =============================================================

(defparameter home-dir (concat (getenv "AMOS_HOME") "/lsp/sparql-lsp-parser/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SPARQL LEXER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;SparQL lexer based on http://www.w3.org/TR/rdf-sparql-query/

;;TODO: Add "long" strings

(unless (boundp 'nlt) 
  (load (concat (getenv "AMOS_HOME") "/lsp/grm/parse-utils.lsp")))

(defstruct lexer-tape str (pos 0))

(defun sparql-lexer (tape)
  (do ((state :general) (ch nil) (ch0 nil) (pos 0) (pos0 0) (buf ""))
      (nil nil) ; never return normally          
    (setq pos (lexer-tape-pos tape))
    (setq ch (substring pos pos (lexer-tape-str tape)))
    (incf (lexer-tape-pos tape))
    (flet ((subtape (start end) (substring start end (lexer-tape-str tape))))
      (flet ((bufferize (start end) (setq buf (concat buf (subtape start end))))
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
		     ((rdf-basechar-p ch) (setq state :id) (setq pos0 pos))
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
				      (t (setq state :uri) (setq pos0 pos))))
	  (:after-right-angle-bracket (if (string= ch "=") (return '(greater-or-equal))
					(progn (stepback) (return '(greater))))) ;;process same CH in general state
	  (:after-dot (if (digit-p ch) (progn (setq state :number) (setq pos0 (1- pos)))
			(progn (stepback) (return '(dot)))))
	  (:localname (unless (or (digit-p ch) (rdf-basechar-p ch) (member ch '("." "-"))) ;allow letters, digits '-' and '.' in local (prefixed) names
			(stepback) (return (cons 'localname (subtape pos0 (1- pos))))))
	  (:langtag (unless (or (rdf-basechar-p ch) (string= ch "-"))
		      (stepback) (return (cons 'langtag (subtape pos0 (1- pos))))))
	  (:uri (cond
		 ((string= ch "") (error (concat "Unterminated URI at pos " (1- pos)) nil))
		 ((string= ch ">") 
		  (bufferize pos0 (1- pos)) (return (cons 'uri buf)))
		 ((whitespace-p ch) ;;remove inner whitespaces from URI
		  (when (< pos0 pos) (bufferize pos0 (1- pos)))
		  (setq pos0 (1+ pos)))))
	  (:var (unless (or (digit-p ch) (rdf-basechar-p ch))
		  (if (< pos0 pos) (progn (stepback) ;;process same CH in general state
					  (return (cons 'var (string-downcase (subtape pos0 (1- pos))))))
		    (error (concat "Variable name expected at pos " pos) nil))))
	  (:id (unless (or (digit-p ch) (rdf-basechar-p ch) (string= ch "-"))
		 (bufferize pos0 (1- pos))
		 (stepback) ;;process same CH in general state
		 (if (member (string-upcase buf) 
			     '("BASE" "PREFIX" "SELECT" "CONSTRUCT" "DESCRIBE" "ASK" "ORDER" "BY" "LIMIT" "OFFSET" "DISTINCT"
			       "REDUCED" "FROM" "NAMED" "WHERE" "GRAPH" "OPTIONAL" "UNION" "FILTER" "A" "STR" "LANG"
			       "LANGMATCHES" "DATATYPE" "SAMETERM" "ISURI" "ISIRI" "ISLITERAL" "TRUE" "FALSE"))
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
	  t)))))

(defparameter terminals
  '((-! . "<end_of_query>")
    (uri . "<uri>")
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

;; Grammar is specified in sparql-grammar.lsp

(load (concat home-dir "sparql-lsp-parser-datamodel.lsp"))

(load (concat home-dir "sparql-slr1.lsp"))

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
    (setq res (sparql-slr1 (f/l () (sparql-lexer tape)) nil))
    (if (eq (car res) 'syntax-error) 
	(error (concat "Syntax error at pos " (lexer-tape-pos tape) ": " (syntax-error-msg res)))
      res)))

      