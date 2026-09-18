;; Differences between GRM and Bison/Yacc:
;; - No default behavior on reduce/reduce conflicts
;; - No operator precedence to define
;; - No Generalized LR parsing
;;
;; Grammars valid in Bison/Yacc might be invalid in GRM parser generator.

(load "../file-reader.lsp")
(load "../parse-utils.lsp")

(defun yy-lexer (fr)
  "Simple state-machine implementing tokenizer of Yacc grammar files, uses FILE-READER struct"
  (do ((ch nil) (block-count 0) (string-opener nil))
      (nil nil) ; never return normally     
    (setq ch (fr-nextchar fr)) ; read next character
    (selectq (fr-lexerstate fr)
	     (:start (cond 
			((string= ch "") (return nil))
			((string= ch ":") (return '(colon)))
			((string= ch "|") (return '(bar)))
			((string= ch ";") (return '(semicolon)))
			((string= ch "{") (fr-newstate fr :block))
			((string= ch "/") (fr-newstate fr :after-slash))
			((string= ch "%") (fr-newstate fr :after-percent))
			((member ch '("\"" "'")) (progn (setq string-opener ch) 
							(fr-startbuffer fr 1) 
							(fr-newstate fr :string)))
			((or (basechar-p ch) (digit-p ch) (string= ch "<"))
			 (fr-startbuffer fr 0)
			 (fr-newstate fr :id))))
	     ;; C blocks
	     (:block (cond ; until respective "}", counted
		      ((string= ch "{") (1++ block-count))
		      ((string= ch "/") (fr-newstate fr :block-after-slash))
		      ((string= ch "}") (if (= block-count 0) (fr-newstate fr :start) (1-- block-count)))
		      ((member ch '("\"" "'")) 
		       (setq string-opener ch) 
		       (fr-newstate fr :block-string))))
	     ;; correcttly handle '<%' and '%>' digraphs for inner braces in C blocks
	     (:block-after-less (progn (when (string= ch "%") (1++ block-count)) (fr-newstate fr :block)))
	     (:block-after-percent (progn (if (string= ch ">") (1-- block-count) (fr-pushback fr ch)) 
					  (fr-newstate fr :block)))
	     ;; correctly handle strings in C blocks
	     (:block-string (cond ; until non-escaped doublequote
			     ((string= ch "\\") (fr-newstate fr :block-string-after-backslash))
			     ((string= ch string-opener) (fr-newstate fr :block))))
	     (:block-string-after-backslash (fr-newstate fr :block-string)) ; ignore escaped character	     
	     ;; correctlty handle comments in C blocks
	     (:block-after-slash (cond 
				  ((string= ch "/") (fr-passline fr)) 
				  ((string= ch "*") (fr-newstate fr :block-comment2))
				  (t (fr-newstate fr :block))))
	     (:block-comment2 (when (string= ch "*") (fr-newstate fr :block-comment2-after-asterisk))) ; until "*/"
	     (:block-comment2-after-asterisk (if (string= ch "/") (fr-newstate fr :block)
					       (unless (string= ch "*") (fr-newstate fr :block-comment2))))
	     ;; comments in grammar section
	     (:after-slash (if (string= ch "*") (fr-newstate fr :comment) (fr-newstate fr :start)))
	     (:comment (when (string= ch "*") (fr-newstate fr :comment-after-asterisk))) ; until "*/"
	     (:comment-after-asterisk (if (string= ch "/") (fr-newstate fr :start)
					(unless (string= ch "*") (fr-newstate fr :comment))))
	     ;; end of grammar section
	     (:after-percent (cond ;declarations and section delimiters
			      ((string= ch "%") (return '(double-percent)))
			      ((basechar-p ch) 
			       (fr-startbuffer fr 0)			       
			       (fr-newstate fr :decl))
			      (t (fr-pushback fr ch) (fr-newstate fr :start))))
	     ;; reading identifiers
	     (:id (unless (or (basechar-p ch) (digit-p ch) (string= ch ">"))
		    (fr-newstate fr :start) 
		    (fr-pushback fr ch) ;; hold CH to process it next time
		    (return (cons 'id (fr-popbuffer fr)))))
	     ;; reading declarations
	     (:decl (unless (basechar-p ch)
		      (fr-newstate fr :start)
		      (fr-pushback fr ch)
		      (return (cons 'decl (fr-popbuffer fr)))))
	     ;; reading strings
	     (:string (cond ; until non-escaped string-opener
		       ((string= ch "\\") (fr-newstate fr :string-after-backslash))
		       ((string= ch string-opener) (fr-newstate fr :start) (return (cons 'string (fr-popbuffer fr))))))
	     (:string-after-backslash (fr-newstate fr :string)) ; ignore escaped character
	     t)))

(defun print-lexems (filename)
  (let ((fr (fr-open filename)))
    (unwind-protect
	(do ((token t))
	    ((null token) t)
	  (setq token (yy-lexer fr))
	  (print token))
      (fr-close fr))))

(load "yy-slr1.lsp")

(defun parse-yy-rules (filename)
  "Syntax parser of Yacc grammar files"
  (let ((fr (fr-open filename)) res)
    (unwind-protect
	(progn
	  (setq res (yy-slr1-parser (f/l () (yy-lexer fr)) nil)) ; run SLR(1) parser routine
	  (if (eq (car res) 'syntax-error)
	      (error (concat "Syntax error at Line " (fr-line fr) " Col " (fr-col fr) 
			     ": Input: " (fourth res) " Expected: " (third res) " at state " (second res)))
	    res))      
      (fr-close fr))))

(defun yy2grm (sourcefile targetfile targetsymbol)
  "Traslator of Yacc grammar files to GRM format"
  (let* ((rd (parse-yy-rules sourcefile))
	 (rules (second rd)) 
	 (rulecnt 0)
	 (ntab (+ (length targetsymbol) 25))
	 (outs (openstream targetfile "w")))
    (unwind-protect
	(progn
	  (let ((start-decl (assoc "start" (first rd))) start-rule) ; handle start-decl
	    (when start-decl 
	      (setq start-rule (assoc (second start-decl) rules))
	      (setq rules (cons start-rule (remove start-rule rules)))))
	  (formatl outs ";;; GRM translation of file " sourcefile t
		  ";;; generated by yy2grm (C) 2010, Andrej Andrejev" t t
		  "(defparameter " targetsymbol "-grammar '(" t)	 
	  (dolist (rule rules)
	    (dolist (rightpart (cdr rule))
	      (spaces ntab outs)
	      (formatl outs "(" (car rule) " ->")
	      (dolist (id rightpart)
		(formatl outs " " id))
	      (formatl outs " 0) ;" (1++ rulecnt) t)))
	  (spaces ntab outs)
	  (formatl outs "))" t t)
	  (formatl outs ";;; This will generate SLR(1) parser, ascend.lsp should be loaded first" t
		   "(make-slr1-parser (grammar-from-johnsons " targetsymbol ") nil \"" 
		   targetsymbol "-slr1\" \"" targetsymbol  "-slr1.lsp\" nil)" t))
      (closestream outs)) t))
	  
		       
