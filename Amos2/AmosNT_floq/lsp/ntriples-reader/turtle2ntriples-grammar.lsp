;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11, Andrej Andrejev, UDBL
;;; $RCSfile: turtle2ntriples-grammar.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/11/19 16:26:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Grammar File for the converters from Turtle format
;;; =============================================================
;;; $Log: turtle2ntriples-grammar.lsp,v $
;;; Revision 1.3  2011/11/19 16:26:14  andan342
;;; Enabled ascending SLR(1) parsers to accept delimeter tokens between top-level syntagms.
;;; Updated all grammars and grammar converters with new argument list to MAKE-SLR1-PARSER.
;;;
;;; Revision 1.2  2011/04/11 13:55:08  andan342
;;; Restructured code, added headers and 1 custom triples filter script
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(defparameter turtle2ntriples-grammar '(
					(<ntriples> -> #'(lambda () (make-hash-table :test #'equal))) ;1
					(<ntriples> -> <ntriples> prefix id iri-tail iri dot ;2
						    #'(lambda (a b c d e f) (puthash c a e) a))
					(<ntriples> -> <ntriples> prefix iri-tail iri dot ;3
						    #'(lambda (a b c d e) (puthash "" a d) a))
					(<ntriples> -> <ntriples> <triples> dot ;4
						    #'(lambda (a b c) (when (car data) ;(CAR DATA) is the output stream
									(dolist (tr (nreverse b))
									  (when (apply (cdr data) tr) ;(CDR DATA) is the filter function
									    (formatl (car data) t (term-to-str (first tr) a) " " 
										     (term-to-str (second tr) a) " " (term-to-str (third tr) a) " . "))))
							a))
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
					(<literal> -> <string-lang> double-cap <resource> #'(lambda (a b c) (setf (fourth a) c) a))
					(<string-lang> -> string #'(lambda (a) (list 'string a nil nil)))
					(<string-lang> -> string langtag #'(lambda (a b) (list 'string a b nil)))
					))

(make-slr1-parser (grammar-from-johnsons turtle2ntriples-grammar) nil "turtle2ntriples-slr1-parser" "turtle2ntriples-slr1.lsp" nil)


