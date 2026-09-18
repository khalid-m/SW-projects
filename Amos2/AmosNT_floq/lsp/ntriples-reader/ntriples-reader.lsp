;; using file reader
(load (concat (getenv "AMOS_HOME") "/lsp/grm/file-reader.lsp"))

(unless (boundp 'nlt) 
  (load (concat (getenv "AMOS_HOME") "/lsp/grm/parse-utils.lsp")))

(defun ntriples-lexer (fr)
  "Simple state-machine implementing tokenizer of NTRIPLES files, uses FILE-READER struct"
  (do ((ch nil) (block-count 0) (string-opener nil))
      (nil nil) ; never return normally     
    (setq ch (fr-nextchar fr)) ; read next character
    (selectq (fr-lexerstate fr)
	     (:start (cond
		      ((string= ch "") (return nil))
		      ((string= ch ".") (return '(dot)))
		      ((string= ch "^") (fr-newstate fr :after-cap))
		      ((string= ch "#") (fr-passline fr))
		      ((string= ch "<") (progn (fr-startbuffer fr 1) (fr-newstate fr :iri)))
		      ((member ch '("\"" "'")) (progn (fr-startbuffer fr 1) (setf (fr-data fr) ch) (fr-newstate fr :string)))
		      ((string= ch "_") (fr-newstate fr :after-underscore))
		      (t (unless (whitespace-p ch) 
			   (error (concat "Illegal symbol : " ch " at " (fr-pos-string fr)))))))
	     (:after-cap (if (string= ch "^") 
			     (progn (fr-newstate fr :start) (return '(double-cap)))
			   (error (concat "Illegal symbol: ^ before " (fr-pos-string fr)))))
	     (:iri (when (string= ch ">") 
		     (fr-newstate fr :start) 
		     (return (cons 'iri (fr-popbuffer fr)))))
	     (:string (cond
		       ((string= ch "") (error "Unterminated string" nil))
		       ((string= ch "\\") (fr-newstate fr :escape))
		       ((string= ch (fr-data fr)) 
			(fr-newstate fr :after-string)  
			(return (cons 'string (fr-popbuffer fr)))))) ;; fr-data stores the opening string delimeter
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
	     (:after-underscore (if (string= ch ":") 
				    (progn (fr-startbuffer fr 1) (fr-newstate fr :id))
				  (progn (fr-newstate fr :start) (return (cons 'blank "_")))))
	     (:id (unless (or (digit-p ch) (rdf-basechar-p ch))
		    (fr-newstate fr :start) 
		    (fr-pushback fr ch) 
		    (return (cons 'blank (concat "_:" (fr-popbuffer fr)))))) ; decorate labelled blanks with '_:'
	     t)))

(defun ntriples-print-lexems (filename)
  "Check what tokens are produced by NTRIPLES-LEXER"
  (let ((fr (fr-open filename)))
    (unwind-protect
	(do ((token t))
	    ((null token) t)
	  (setq token (ntriples-lexer fr))
	  (print token))
      (fr-close fr))))

(defun ntriples-+++ (fno filename s p o)
  "Read triples from NTriples file"
  (let ((fr (fr-open filename)))
    (unwind-protect
	(do ((triple (make-array 3)) (i -1) (token t) (state :general))
	    ((null token) t)
	  (setq token (ntriples-lexer fr))
	  (selectq state
		   (:general (selectq (car token)
				      (dot (if (= i 2) ; return triple if complete
					       (progn (setq i -1)
						      (osql-result filename (aref triple 0) (aref triple 1) (aref triple 2)))
					     (error (concat "Syntax error at " (fr-pos-string fr) ": Unexpected '.'"))))
				      ((iri string blank) ; add another term to a triple
				       (incf i)
				       (setf (aref triple i) (cdr token)))
				      (double-cap (setq state :type)) ; ignore next IRI
				      t)) ; ignore LANGTAG
		   (:type (if (eq (car token) 'iri) (setq state :general) ; ignore IRI after ^^, break on all other tokens
			    (error (concat "Syntax error at " (fr-pos-string fr) ": IRI expected after ^^"))))
		   t))
      (fr-close fr))))

(osql "create function ntriples(Charstring filename)->Bag of (Charstring, Charstring, Charstring) as foreign 'ntriples-+++';") 


						 
			  
			  