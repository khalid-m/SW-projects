;; Very simple SparQL grammar that is able to parse queries from SWARD regression test

(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(defparameter turtle-grammar '(
				 (<ntriples> -> #'(lambda () (make-hash-table :test #'equal))) ;1
				 (<ntriples> -> <ntriples> prefix id iri-tail iri dot ;2
					     #'(lambda (a b c d e f) (puthash c a e) a))
				 (<ntriples> -> <ntriples> prefix iri-tail iri dot ;3
					     #'(lambda (a b c d e) (puthash "" a d) a))
				 (<ntriples> -> <ntriples> <triples> dot ;4
					     #'(lambda (a b c) (dolist (tr (nreverse b)) ;DATA is a filename
								 (osql-result data (term-to-str (first tr) a) (term-to-str (second tr) a) (term-to-str (third tr) a))) a))
				 (<triples> -> <rdf-term> <rdf-term> <rdf-term> #'(lambda (a b c) (list (list a b c))))
				 (<triples> -> <triples> semicolon <rdf-term> <rdf-term> #'(lambda (a b c d) (cons (list (caar a) c d) a)))
				 (<triples> -> <triples> comma <rdf-term> #'(lambda (a b c) (cons (list (caar a) (cadar a) c) a)))
				 (<triples> -> <triples> semicolon 1) ; ignore '; .' and ', .' tails
				 (<triples> -> <triples> comma 1)
				 (<rdf-term> -> blank iri-tail #'(lambda (a b) (list 'blank b))) 
				 (<rdf-term> -> <resource> 1)
				 (<rdf-term> -> <literal> 1) 
				 (<resource> -> iri #'(lambda (a) (list 'iri a)))
				 (<resource> -> id iri-tail #'(lambda (a b) (list 'prefixed a b)))
				 (<resource> -> iri-tail #'(lambda (a) (list 'prefixed "" a)))
				 (<literal> -> number #'(lambda (a) (list 'number a)))
				 (<literal> -> <string-lang> 1)
				 (<literal> -> <string-lang> double-cap <resource> 1) ; ignore type
				 (<string-lang> -> string 1)
				 (<string-lang> -> string langtag 1) ; ignore langtag
				 ))

(make-slr1-parser (grammar-from-johnsons turtle-grammar) nil "turtle-slr1-parser" "turtle-slr1.lsp" nil)


