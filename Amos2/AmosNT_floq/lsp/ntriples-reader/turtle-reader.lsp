;; using file reader
(load (concat (getenv "AMOS_HOME") "/lsp/grm/file-reader.lsp"))

(unless (boundp 'nlt) 
  (load (concat (getenv "AMOS_HOME") "/lsp/grm/parse-utils.lsp")))

(defun turtle-lexer (fr)
  "Simple state-machine implementing tokenizer of Turtle files, uses FILE-READER struct"
  (do ((ch nil) (block-count 0) (string-opener nil))
      (nil nil) ; never return normally     
    (setq ch (fr-nextchar fr)) ; read next character
    (selectq (fr-lexerstate fr)
	     (:start (cond
		      ((string= ch "") (return nil))
		      ((string= ch "_") (return '(blank)))
		      ((string= ch ".") (return '(dot)))
		      ((string= ch ";") (return '(semicolon)))
		      ((string= ch ",") (return '(comma)))
		      ((string= ch "^") (fr-newstate fr :after-cap))
		      ((string= ch "#") (fr-passline fr))
		      ((string= ch "@") (progn (fr-startbuffer fr 1) (fr-newstate fr :decl)))
		      ((string= ch "<") (progn (fr-startbuffer fr 1) (fr-newstate fr :iri)))
		      ((string= ch ":") (progn (fr-startbuffer fr 1) (fr-newstate fr :iri-tail)))
		      ((member ch '("\"" "'")) (progn (fr-startbuffer fr 1) (setf (fr-data fr) ch) (fr-newstate fr :string)))
		      ((or (digit-p ch) (string= ch "-")) (progn (fr-startbuffer fr 0) (fr-newstate fr :number)))
		      ((basechar-p ch) (progn (fr-startbuffer fr 0) (fr-newstate fr :id)))
		      (t (unless (whitespace-p ch) 
			   (error (concat "Illegal symbol : " ch " at " (fr-pos-string fr)))))))
	     (:after-cap (if (string= ch "^") 
			     (progn (fr-newstate fr :start) (return '(double-cap)))
			   (error (concat "Illegal symbol: ^ at " (fr-pos-string fr)))))
	     (:decl (unless (rdf-basechar-p ch) 
		      (let ((decl (fr-popbuffer fr)))
			(if (string= (string-downcase decl) "prefix")
			    (progn (fr-newstate fr :start) (fr-pushback fr ch) (return '(prefix)))
			  (error (concat "Illegal declaration : " decl " at " (fr-pos-string fr)))))))
	     (:iri (when (string= ch ">") 
		     (fr-newstate fr :start) (return (cons 'iri (fr-popbuffer fr)))))
	     (:iri-tail (unless (or (digit-p ch) (rdf-basechar-p ch) (string= ch "-"))
			  (fr-newstate fr :start) (fr-pushback fr ch) (return (cons 'iri-tail (fr-popbuffer fr)))))
	     (:string (cond
		       ((string= ch "") (error "Unterminated string" nil))
		       ((string= ch "\\") (fr-newstate fr :escape))
		       ((string= ch (fr-data fr)) (fr-newstate fr :after-string)  (return (cons 'string (fr-popbuffer fr)))))) ;; fr-data stores the opening string delimeter
	     (:escape (cond ;carriage return is ignored, backspace and form feed are not supported
		       ((string= ch "t") (fr-substitute fr 1 2 (int-char 9))) ;tab
		       ((string= ch "n") (fr-substitute fr 1 2 (int-char 10))) ;newline 
		       ((member ch '("\\" "'" "\"")) (fr-substitute fr 0 1 ""))) ;ignore '\' but bufferize these characters
		      (fr-newstate fr :string))
	     (:after-string (if (string= ch "@") 
				(progn (fr-startbuffer fr 1) (fr-newstate fr :langtag))
			      (progn (fr-pushback fr ch) (fr-newstate fr :start))))
	     (:langtag (unless (or (basechar-p ch) (string= ch "-")) 
			 (fr-newstate fr :start) (fr-pushback fr ch) (return (cons 'langtag (fr-popbuffer fr)))))
	     (:number (cond
		       ((string= ch ".") (fr-newstate fr :number-nextpart))
		       ((member ch '("e" "E")) (fr-newstate fr :number-after-e))
		       ((not (digit-p ch))
			(fr-newstate fr :start) (fr-pushback fr ch) (return (cons 'number (fr-popbuffer fr))))))
	     (:number-nextpart (if (digit-p ch) (fr-newstate fr :number)
				 (progn (fr-newstate fr :start) 
					(fr-pushback fr ch) ; process this char later
					(fr-pushback fr ".") ; process previous char '.' on next call
					(fr-substitute fr 0 1 "") ; remove '.' from buffer
					(return (cons 'number (fr-popbuffer fr))))))
	     (:number-after-e (if (or (digit-p ch) (member ch '("-" "+"))) (fr-newstate fr :number-nextpart)
				(error (concat "Illegal character in number : " ch " at " (fr-pos-string fr)))))
	     (:id (unless (or (digit-p ch) (rdf-basechar-p ch) (string= ch "-"))
		    (let ((id-str (fr-popbuffer fr)))
		      (fr-newstate fr :start) 
		      (fr-pushback fr ch) 
		      (return (if (string= id-str "a") (cons 'iri "http://www.w3.org/1999/02/22-rdf-syntax-ns#type") 
				(cons 'id id-str))))))
	     t)))

(defun turtle-print-lexems (filename)
  (let ((fr (fr-open filename)))
    (unwind-protect
	(do ((token t))
	    ((null token) t)
	  (setq token (turtle-lexer fr))
	  (print token))
      (fr-close fr))))

(defun term-to-str (term prefix-ht)
  (cond ((stringp term) term)
	((eq (car term) 'blank) (concat "_:" (second term)))
	((eq (car term) 'number) (second term)) ; make numbers indistinguishable from string
	((eq (car term) 'iri) (second term))
	((eq (car term) 'prefixed) (concat (gethash (second term) prefix-ht) (third term)))
	(t "")))

(load "turtle-slr1.lsp")

(defun turtle-+++ (fno filename s p o)
  "Read triples from Turtle file"
  (let ((fr (fr-open filename)) res)
    (unwind-protect
	(progn
	  (setq res (turtle-slr1-parser (f/l () (turtle-lexer fr)) filename)) ; run SLR(1) parser routine
	  (when (and (listp res) (eq (car res) 'syntax-error)) 
	    (error (concat "Syntax error at " (fr-pos-string fr) ": Input: " (fourth res) " Expected: " (third res) " at state " (second res)))))
      (fr-close fr))))

(osql "create function turtle(Charstring filename)->Bag of (Charstring, Charstring, Charstring) as foreign 'turtle-+++';") 

(defun returtle-amosfn (amosfn filename)
  "drop contents of Amos triple store function and load new triples from Turtle file"
  (when (file-exists-p filename)
    (eval (list 'osql (concat "dropfunction(#'" amosfn "',1);")))
    (eval (list 'osql (concat "add " amosfn "() = turtle('" filename "');")))
    t))


						 
			  
			  