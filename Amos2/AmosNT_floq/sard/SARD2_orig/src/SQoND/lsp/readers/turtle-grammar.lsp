;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: turtle-grammar.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:49:12 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================
;;; $Log: turtle-grammar.lsp,v $
;;; Revision 1.1  2013/08/09 14:49:12  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.10  2012/04/23 16:13:44  andan342
;;; Now allowing '.' in prefixes
;;;
;;; Revision 1.9  2012/04/21 14:41:48  andan342
;;; Added MAX and MIN binary and aggregate functions, regression test for aggregate functions,
;;; fixed reader bug with negative numbers
;;;
;;; Revision 1.8  2012/02/20 17:09:10  andan342
;;; Added reader and storage support for boolean values
;;;
;;; Revision 1.7  2012/02/08 16:18:16  andan342
;;; Now using READ-TOKEN-based SPARQL lexer in Turtle/NTriples reader,
;;; moved (returtle-amosfn ...) def to master.lsp
;;;
;;; Revision 1.6  2011/11/19 16:28:15  andan342
;;; Updated all grammars and grammar converters with new argument list to MAKE-SLR1-PARSER.
;;;
;;; Revision 1.5  2011/07/06 16:19:23  andan342
;;; Added array transposition, projection and selection operations, changed printer and reader.
;;; Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
;;; Added Lisp testcases for this and one SparQL query with array variables
;;;
;;; Revision 1.4  2011/05/25 08:35:45  andan342
;;; Now supporting '[ :p :o ] .' syntax for input triples
;;;
;;; Revision 1.3  2011/05/23 20:00:44  andan342
;;; Now supporting blank nodes abbreviations [] and collection abbreviations (),
;;; "rdf" prefix is now built-in
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; TODO: @base declaration

(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(defparameter turtle-grammar '(
			       (<ntriples> -> #'(lambda () t)) ;1
			       (<ntriples> -> <ntriples> at-id pref uri-tail uri dot ;2
					   #'(lambda (a b c d e f) (if (string= (string-downcase b) "prefix")
								       (add-prefix data c e)
								     (error (concat "Unknown statement: @" b))) a))					   
			       (<ntriples> -> <ntriples> at-id uri-tail uri dot ;3
					   #'(lambda (a b c d e) (if (string= (string-downcase b) "prefix")
								     (add-prefix data "" d)
								   (error (concat "Unknown statement: @" b))) a))
			       (<ntriples> -> <ntriples> <rdf-term> <pred-obj-list> dot ;4
					   #'(lambda (a b c d) (emit-triples data b (nreverse c)) a))
;			       (<ntriples> -> <ntriples> <bracketed-prop-list> dot 1) ;;Should not be a problem - investigate by extending GRMGUI with transition diagrams
			       (<pred-obj-list> -> <rdf-term> <obj-list> #'(lambda (a b) (list (cons a (nreverse b))))) ;5
			       (<pred-obj-list> -> <pred-obj-list> semicolon <rdf-term> <obj-list> #'(lambda (a b c d) (cons (cons c (nreverse d)) a))) ;6
			       (<pred-obj-list> -> <pred-obj-list> semicolon 1) ;7
			       (<obj-list> -> <rdf-term> #'(lambda (a) (list a))) ;8
			       (<obj-list> -> <obj-list> comma <rdf-term> #'(lambda (a b c) (cons c a))) ;9
			       (<obj-list> -> <obj-list> comma 1) ;10

			       (<rdf-term> -> underscore uri-tail #'(lambda (a b) (list 'blank b))) ;11
			       (<rdf-term> -> <resource> 1) ;12
			       (<rdf-term> -> <literal> 1) ;13

			       (<rdf-term> -> <bracketed-prop-list> 1)
			       (<bracketed-prop-list> -> left-bracket <pred-obj-list> right-bracket ;14
						      #'(lambda (a b c) (let ((res (gen-blank data))) (emit-triples data res b) res))) 
			       (<rdf-term> -> left-bracket right-bracket #'(lambda (a b) (gen-blank data))) ;15

			       (<rdf-term> -> left-par <rdf-terms> right-par #'(lambda (a b c) (nreverse b)))
			       (<rdf-terms> -> #'(lambda () nil))
			       (<rdf-terms> -> <rdf-terms> <rdf-term> #'(lambda (a b) (cons b a)))

			       (<resource> -> uri #'(lambda (a) (URI a))) 
			       (<resource> -> pref uri-tail #'(lambda (a b) (list 'prefixed a b))) 
			       (<resource> -> uri-tail #'(lambda (a) (list 'prefixed "" a)))
			       (<resource> -> a #'(lambda (a) (URI "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")))
			       (<literal> -> number #'(lambda (a) (read a)))
			       (<literal> -> minus number #'(lambda (a b) (* (read b) -1)))
			       (<literal> -> <string-lang> 1)
			       (<literal> -> <string-lang> double-cap <resource> #'(lambda (a b c) (list 'typed a c)))
			       (<literal> -> true #'(lambda (a) 'true))
			       (<literal> -> false #'(lambda (a) 'false))			       
			       (<string-lang> -> string #'(lambda (a) (USTR a)))
			       (<string-lang> -> string at-id #'(lambda (a b) (USTR a b)))
			       ))

(make-slr1-parser (grammar-from-johnsons turtle-grammar) nil "turtle-slr1-parser" "turtle-slr1.lsp" nil)


