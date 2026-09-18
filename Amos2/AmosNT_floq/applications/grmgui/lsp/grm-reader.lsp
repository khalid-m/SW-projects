(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(defstruct exported-grammar start-line end-line g (rule-cnt 0) comments null-nts follows)

(defun preread-grammar (filename)
  "Identifies symbols assigned to quoted lists in given lisp file, collects comments
   return an alist of (grammar-symbol . exported-grammar) where the latter is partly initialized"
  (let ((str (openstream filename "r")) res line (line-cnt 0) 
	token (state :before) grm-symbol eg (par-cnt 0) comment-buffer comment-list)
    (unwind-protect
	(do () (nil t) 
	  (setq line (read-line str))	
	  (incf line-cnt)
;	  (print line) ;DEBUG
	  (if (eq line '*eof*) (return nil)
	    (with-textstream line-str line
			     (do () (nil t)
			       (setq token (read-token line-str))
;			       (print (list 'token= token 'state= state 'par-cnt= par-cnt)) ;DEBUG
			       (if (or (eq token '*eof*)
				       (and (not (eq state :read-rules)) (stringp token) (string= token ";"))) (return nil)
				 (selectq state
					  (:before (when (and (stringp token) (string= token "(")) 
						     (setq state :expect-assignment)))
					  (:expect-assignment (if (member token '("defvar" "defparameter" "setq"))
								  (progn  ;start constructing a new grammar symbol
								    (setq eg (make-exported-grammar :start-line line-cnt))
								    (setq comment-list nil)
								    (setq comment-buffer "")
								    (setq par-cnt 0)
								    (setq state :expect-grm-symbol))
								(setq state :before)))
					  (:expect-grm-symbol (if (stringp token) 
								  (progn
								    (setq grm-symbol token)
								    (setq state :expect-quote))
								(setq state :before)))
					  (:expect-quote (setq state (if (and (stringp token) (string= token "'")) 
									 :expect-left-par :before)))
					  (:expect-left-par (setq state (if (and (stringp token) (string= token "(")) 
									    :read-rules :before)))
					  (:read-rules (when (stringp token)
							 (cond ((string= token ";") ;add comments to COMMENT-BUFFER, next token is *EOF*
								(setq comment-buffer (concat comment-buffer 
											     (if (string= comment-buffer "") "" "|") 
											     (read-line line-str))))
							       ((string= token "(") 
								(when (= par-cnt 0) 
								  (when (> (exported-grammar-rule-cnt eg) 0) 
								    (push comment-buffer comment-list)
								  (setq comment-buffer "")))
								(incf par-cnt))
							       ((string= token ")") 
								(decf par-cnt)
								(cond ((= par-cnt 0) 
								       (incf (exported-grammar-rule-cnt eg)))
								      ((= par-cnt -2) 
								       (push comment-buffer comment-list) ;store comment on the last rule
								       (setf (exported-grammar-end-line eg) line-cnt)
								       (setf (exported-grammar-comments eg) (nreverse comment-list))
								       (push (cons grm-symbol eg) res)
								       (setq state :before)))))))
					  t))))))
      (closestream str))
    (nreverse res)))

;; (preread-grammar "../test-grammar.lsp")

(defvar *grm-symbols*)

(defun Preread_grammar-++ (fno filename symbol rulecnt)
  (setq *grm-symbols* (preread-grammar filename))
  (dolist (entry *grm-symbols*)
    (osql-result filename (car entry) (exported-grammar-rule-cnt (cdr entry)))))

(osql "
create function Preread_grammar(Charstring filename) -> Bag of (Charstring symbol, Integer rulecnt)
  as foreign 'Preread_grammar-++';
")

(defun load-lines (filename start-line end-line)
  "Loads lisp forms from FILENAME starting at START-LINE and ending at END-LINE (1-based)"
  (let ((instr (openstream filename "r")) line (linecnt 0))
    (unwind-protect
	(parse (with-string s (do () (nil t)
				(setq line (read-line instr))
				(incf linecnt)
				(if (or (eq line '*eof*) (> linecnt end-line)) (return t)
				  (when (>= linecnt start-line)
				    (formatl s line t)))))
	       t "lisp")
      (closestream instr))))

(defun Load_grammar-- (fno filename symbol)
  (let ((eg (cdr (assoc symbol *grm-symbols*))) g)
    (load-lines filename (exported-grammar-start-line eg) (exported-grammar-end-line eg))
    (setq g (eval `(grammar-from-johnsons ,(mksymbol symbol))))
    (setf (exported-grammar-g eg) g)
    (setf (exported-grammar-null-nts eg) (get-null-nts g))
    (setf (exported-grammar-follows eg) (list-follow-sets-complete g nil)) ;NIL delims
    ))

(osql "
create function Load_grammar(Charstring filename, Charstring symbol) -> Boolean
  as foreign 'Load_grammar--';
")

(defun Get_grammar_rules-+++ (fno symbol lp rp comment)
  (let ((eg (cdr (assoc symbol *grm-symbols*))) (ruleno 0))
    (dolist (rule (grammar-rules (exported-grammar-g eg)))
      (osql-result symbol (mkstring (car rule)) 
		   (listtoarray (mapcar #'mkstring (cdr rule))) 
		   (nth ruleno (exported-grammar-comments eg)))
      (incf ruleno))))

(defun Get_grammar_terminals-+ (fno symbol terminal)
  (dolist (term (grammar-ts (exported-grammar-g (cdr (assoc symbol *grm-symbols*)))))
    (osql-result symbol (mkstring term))))

(defun Get_grammar_nts-+ (fno symbol nonterminal)
  (dolist (nt (grammar-nts (exported-grammar-g (cdr (assoc symbol *grm-symbols*)))))
    (osql-result symbol (mkstring nt))))

(osql "
create function Get_grammar_rules(Charstring symbol) -> Bag of (Charstring lp, Vector of Charstring rp, Charstring comment)
  as foreign 'Get_grammar_rules-+++';

create function Get_grammar_terminals(Charstring symbol) -> Bag of Charstring
  as foreign 'Get_grammar_terminals-+';

create function Get_grammar_nts(Charstring symbol) -> Bag of Charstring
  as foreign 'Get_grammar_nts-+';
")

(defun grammar-get-idf (g null-nts x)
  "gets 'is-directly-followed-by' set for X, together with respective rule numbers"
  (let ((rulecnt 0) right1 res)
    (dolist (rule (grammar-rules g))
      (incf rulecnt)
      (setq right1 (cdr (member x (cdr rule))))
      (when right1
	(dolist (r right1)
	  (push (cons r rulecnt) res)
	  (unless (member r null-nts)
	    (return nil)))))
    res))

(defun grammar-get-bdw (g null-nts x)
  "gets 'begins-directly-with' set for X, together with respective rule numbers"
  (let ((rulecnt 0) res)
    (dolist (rule (grammar-rules g))
      (incf rulecnt)
      (when (eq (car rule) x)
	(dolist (r (cdr rule))
	  (push (cons r rulecnt) res)
	  (unless (member r null-nts)
	    (return nil)))))
    res))

(defun grammar-get-ide (g null-nts x)
  "gets 'is-direct-end-of' set for X, together with respective rule numbers"
  (let ((rulecnt 0) res)
    (dolist (rule (grammar-rules g))
      (incf rulecnt)    
      (dolist (r (reverse (cdr rule)))
	(when (eq r x)
	  (push (cons (car rule) rulecnt) res))
	(unless (member r null-nts)
	  (return nil))))
    res))

(defun tag-to-gfn (tag)
  (selectq tag
	   (1 'grammar-get-idf)
	   (2 'grammar-get-bdw)
	   (3 'grammar-get-ide)
	   t))

(defun group-grammar-set (srs)
  (let (res res-entry)
    (dolist (sr srs)
      (setq res-entry (assoc (car sr) res))
      (if res-entry (push (cdr sr) (cdr res-entry)) ;add rule-number to an existing entry
	(push (list (car sr) (cdr sr)) res))) ;add new entry
    res))


(defun Get_grammar_set---+++ (fno symbol x tag ruleno y ntflag)
  (let* ((eg (cdr (assoc symbol *grm-symbols*)))
	 (g (exported-grammar-g eg)))
    (dolist (res (nreverse (eval `(,(tag-to-gfn tag) g (exported-grammar-null-nts eg) (mksymbol x)))))
      (osql-result symbol x tag (cdr res) (mkstring (car res))
		   (if (member (car res) (grammar-nts g)) 1 0)))))

(defun Get_grammar_grouped_set---+++ (fno symbol x tag rulenos y ntflag)
  (let* ((eg (cdr (assoc symbol *grm-symbols*)))
	 (g (exported-grammar-g eg)))
    (dolist (res (group-grammar-set (eval `(,(tag-to-gfn tag) g (exported-grammar-null-nts eg) (mksymbol x)))))
      (osql-result symbol x tag (listtoarray (cdr res)) (mkstring (car res))
		   (if (member (car res) (grammar-nts g)) 1 0)))))

(osql "
create function Get_grammar_set(Charstring symbol, Charstring x, Integer settag) -> Bag of (Integer ruleno, Charstring y, Integer ntflag)
  as foreign 'Get_grammar_set---+++';

create function Get_grammar_grouped_set(Charstring symbol, Charstring x, Integer settag) -> Bag of (Vector of Integer rulenos, Charstring y, Integer ntflag)
  as foreign 'Get_grammar_grouped_set---+++';
")

(defun Get_grammar_follows--+ (fno symbol x y)
  (dolist (r (cdr (assoc (mksymbol x) (exported-grammar-follows (cdr (assoc symbol *grm-symbols*))))))
    (osql-result symbol x (mkstring r))))

(osql "
create function Get_grammar_follows(Charstring symbol, Charstring x) -> Bag of Charstring y
  as foreign 'Get_grammar_follows--+';
")

;; Preread_grammar("../test-grammar.lsp");
;; Load_grammar("../test-grammar.lsp","ex2");
;; Get_grammar_grouped_set("ex2","<EXPR>",1);

;; Preread_grammar("../sparql-grammar.lsp");
;; Load_grammar("../sparql-grammar.lsp","sparql-grammar");
;; Get_grammar_grouped_set("sparql-grammar","LEFT-PAR",1);

;; Preread_grammar("../sparql11-grammar.lsp");
;; Load_grammar("../sparql11-grammar.lsp","sparql11-grammar-grammar");
;; Get_grammar_grouped_set("sparql-grammar","LEFT-PAR",1);


;; Preread_grammar("../../../SQoND/lsp/sparql-grammar.lsp");
;; Load_grammar("../../../SQoND/lsp/sparql-grammar.lsp","sparql-grammar");
;; Get_grammar_grouped_set("sparql-grammar","<TRIPLES>",3);
;; Get_grammar_grouped_set("sparql-grammar","<CONDS>",3);


    
      

