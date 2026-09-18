;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2011 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-grammar.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SciSPARQL grammar in format accepted by GRM parser generator
;;; =============================================================
;;; $Log: sparql-grammar.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:38  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.27  2013/01/22 16:21:32  andan342
;;; Added (sparql-add-extender-engine ...) to add engines (and new ways to define foreign functions) at runtime
;;;
;;; Revision 1.26  2012/12/14 14:02:03  andan342
;;; Added rdf:insert and rdf:clear Amos functions, callable from SciSPARQL
;;;
;;; Revision 1.25  2012/06/15 16:14:38  andan342
;;; Added ARGMIN and ARGMAX second-order functions, brief and complete f(*) syntax for closures,
;;; all new variables now contain ':' to avoid conflicts with user variables,
;;; a mechanism introduced to generate new variables and conditions from inside expression translator.
;;;
;;; Revision 1.24  2012/06/06 13:09:44  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.23  2012/05/26 11:45:37  andan342
;;; Introduced CONSTRUCT into the new version of the parser
;;;
;;; Revision 1.22  2012/02/08 16:18:15  andan342
;;; Now using READ-TOKEN-based SPARQL lexer in Turtle/NTriples reader,
;;; moved (returtle-amosfn ...) def to master.lsp
;;;
;;; Revision 1.21  2012/02/02 22:52:35  andan342
;;; Enabled session-wide PREFIX statements,
;;; fixed bugs with:
;;; - 'total' aggregates in non-vectorized mode,
;;; - floating-point number reader,
;;; - default step for array projections in Python-syntax mode
;;;
;;; Revision 1.20  2012/02/01 10:59:09  andan342
;;; Added BIND syntax from W3C SPARQL 1.1,
;;; made '.' optional between conditions in the block
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

;;(load "sparql-lsp-parser-datamodel.lsp")

(defparameter sparql-grammar '((<stat> -> <simple-fncall> #'(lambda (a) (list nil (cons 'call a))))
			       (<stat> -> quit #'(lambda (a b) '(nil (quit))))
			       (<stat> -> lisp #'(lambda (a b) '(nil (lisp))))
			       (<stat> -> <prefix> #'(lambda (a) (list nil (cons 'prefix a))))
			       (<stat> -> <prefixed-stat> 1)
			       (<prefixed-stat> -> <select> #'(lambda (a) (list nil a))) 
			       (<prefixed-stat> -> <construct> #'(lambda (a) (list nil a)))
			       (<prefixed-stat> -> <prefix> <prefixed-stat> #'(lambda (a b) (push a (first b)) b)) 
			       (<prefix> -> prefix pref uri-tail uri #'(lambda (a b c d) (cons b d))) ; PREFIX p: <..>, uri-tail is empty
			       (<prefix> -> prefix uri-tail uri #'(lambda (a b c) (cons "" c))) ; PREFIX : <..>
			       (<select> -> select <sel-list> #'(lambda (a b) (make-sparql-stat :type 'select :what b))) 
			       (<select> -> select distinct <sel-list> #'(lambda (a b c) (make-sparql-stat :type 'select :what c :distinct t))) 
			       (<select> -> <select> from uri #'(lambda (a b c) (setf (sparql-stat-from a) c) a)) ;6
			       (<select> -> <select> where <block> #'(lambda (a b c) (setf (sparql-stat-where a) c) a)) ;7
			       (<select> -> <select> <block> #'(lambda (a b) (setf (sparql-stat-where a) b) a)) ;; WHERE keyword can be omitted
			       (<select> -> <select> group by <var-list> #'(lambda (a b c d) (setf (sparql-stat-groupby a) d) a)) ;8
			       (<select> -> <select> having <expr> #'(lambda (a b c) (setf (sparql-stat-having a) c) a)) ;9
			       (<sel-list> -> <named-expr-or-var> #'(lambda (a) (list a))) ;10
			       (<sel-list> -> <named-expr-or-var> <sel-list> #'(lambda (a b) (cons a b))) ;11
			       (<named-expr-or-var> -> var #'(lambda (a) (cons 'var a))) ;12
			       (<named-expr-or-var> -> <named-expr> 1)
			       (<named-expr> -> left-par <expr> as var right-par #'(lambda (a b c d e) (list 'named d b)))
			       (<var-list> -> var #'(lambda (a) (list a))) ;14
			       (<var-list> -> var <var-list> #'(lambda (a b) (cons a b))) ;15
			       (<block> -> left-brace <conds> right-brace #'(lambda (a b c) (make-block :conds b))) ;16

			       (<conds> -> #'(lambda () nil))
			       (<conds> -> <triples> <conds> #'(lambda (a b) (cons a b)))
			       (<conds> -> <nontriples> <conds> #'(lambda (a b) (cons a b)))
			       (<conds> -> dot <conds> 2)			       
			       
			       (<nontriples> -> filter left-par <expr> right-par #'(lambda (a b c d) (cons 'filter c))) ;25
			       (<nontriples> -> filter <simple-fncall> #'(lambda (a b) (cons 'filter b)))
			       (<nontriples> -> optional <block> #'(lambda (a b) (cons 'optional b)))	;23
			       (<nontriples> -> <union> 1) ;24
			       (<nontriples> -> bind <named-expr> #'(lambda (a b) (cons 'bind (cdr b))))
			       (<union> -> <block> union <block> #'(lambda (a b c) (list 'union a c))) ;25
			       (<union> -> <union> union <block> #'(lambda (a b c) (append a (list c)))) ;26

			       (<triples> -> <node> <pred-obj-list> #'(lambda (a b) (cons 'triples (sparql-make-triples a b)))) ;27
			       (<pred-obj-list> -> <object> <obj-list> #'(lambda (a b) (make-sqo :n (mapcar (f/l (o) (list a (sqo-n o))) (nreverse b)) ;28
												 :ts (mapcan #'sqo-ts b)))) ; merge triples lists
			       (<pred-obj-list> -> <pred-obj-list> semicolon <object> <obj-list> ;29
						#'(lambda (a b c d) (make-sqo :n (append (sqo-n a) (mapcar (f/l (o) (list c (sqo-n o))) (nreverse d)))
									      :ts (append (sqo-ts a) (mapcan #'sqo-ts d)))))
			       (<obj-list> -> <node> #'(lambda (a) (list a))) ;30
			       (<obj-list> -> <obj-list> comma <node> #'(lambda (a b c) (cons c a))) ;31
			       
			       (<node> -> <object> #'(lambda (a) (make-sqo :n a))) ;32
			       (<node> -> left-bracket <pred-obj-list> right-bracket ;33
						    #'(lambda (a b c) (let ((res (sparql-gen-blank data)))
									(make-sqo :n res :ts (sparql-make-triples (make-sqo :n res) b)))))
			       (<node> -> left-bracket right-bracket #'(lambda (a b) (make-sqo :n (sparql-gen-blank data)))) ;34

			       (<node> -> left-par <nodes> right-par #'(lambda (a b c) (sparql-collection-to-triples data (nreverse b)))) ;35
			       (<nodes> -> #'(lambda () nil)) ;36
			       (<nodes> -> <nodes> <node> #'(lambda (a b) (cons b a))) ;37
			       
			       (<object> -> <rdf-term> 1) ;38
			       (<object> -> var #'(lambda (a) (cons 'var a))) ;39
			       (<rdf-term> -> underscore uri-tail #'(lambda (a b) (list 'blank b))) ;40
			       (<rdf-term> -> <resource> 1) ;41
			       (<object> -> <literal> 1) ;42

			       (<resource> -> uri #'(lambda (a) (list 'uri a))) ;43
			       (<resource> -> pref uri-tail #'(lambda (a b) (list 'prefixed a b))) ;44
			       (<resource> -> uri-tail #'(lambda (a) (list 'prefixed "" a))) ;45
			       (<resource> -> a #'(lambda (a) (list 'uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))) ;46
			       (<literal> -> number #'(lambda (a) (list 'number a))) ;47
			       (<literal> -> true #'(lambda (a) '(true))) ;48
			       (<literal> -> false #'(lambda (a) '(false))) ;49
			       (<literal> -> <string-lang> 1) ;50
			       (<literal> -> <string-lang> double-cap <resource>  ;51
					  #'(lambda (a b c) (list 'typed (second a) (third a) c)))
			       (<string-lang> -> string #'(lambda (a) (list 'ustr a nil))) ;52
			       (<string-lang> -> string at-id #'(lambda (a b) (list 'ustr a b))) ;53

			       (<expr> -> <expr> or <conjunction> #'(lambda (a b c) (list 'or a c))) ;54
			       (<expr> -> <conjunction> 1) ;55
			       (<expr> -> id #'(lambda (a) (cons (cons 'id a) '((asterisk)))))
			       (<expr> -> times #'(lambda (a) '(asterisk)))
			       (<conjunction> -> <conjunction> and <rel-expr> #'(lambda (a b c) (list 'and a c))) ;56
			       (<conjunction> -> <rel-expr> 1) ;57
			       (<rel-expr> -> <num-expr-or-uri> 1) ;58
			       (<rel-expr> -> <num-expr-or-uri> <compare-op> <num-expr-or-uri> #'(lambda (a b c) (list b a c))) ;59
			       (<compare-op> -> not-equal #'(lambda (a) '!=)) ;60
			       (<compare-op> -> equal #'(lambda (a) '=)) ;61
			       (<compare-op> -> less #'(lambda (a) '<)) ;62
			       (<compare-op> -> greater #'(lambda (a) '>)) ;63
			       (<compare-op> -> less-or-equal #'(lambda (a) '<=)) ;64
			       (<compare-op> -> greater-or-equal #'(lambda (a) '>=)) ;65

			       (<num-expr-or-uri> -> <num-expr> 1) ;66
			       (<num-expr-or-uri> -> <rdf-term> 1) ;67---------------------------

			       (<num-expr> -> <mult-expr> plus <mult-expr> #'(lambda (a b c) (list '+ a c))) ;68
			       (<num-expr> -> <mult-expr> minus <mult-expr> #'(lambda (a b c) (list '- a c))) ;69
			       (<num-expr> -> <mult-expr> 1) ;70
			       (<mult-expr> -> <unary-expr> times <unary-expr> #'(lambda (a b c) (list '* a c))) ;71
			       (<mult-expr> -> <unary-expr> divide <unary-expr> #'(lambda (a b c) (list '/ a c))) ;72
			       (<mult-expr> -> <unary-expr> 1) ;73
			       (<unary-expr> -> <prim-expr> 1) ;74
			       (<unary-expr> -> minus <prim-expr> #'(lambda (a b) (list 'u- b))) ;75
			       (<prim-expr> -> left-par <expr> right-par #'(lambda (a b c) b)) ;76
			       (<prim-expr> -> <literal> 1) ;77
			       (<prim-expr> -> not <prim-expr> #'(lambda (a b) (list 'not b))) ;78
			       (<prim-expr> -> <var-or-fncall> 1) ;79
       			       (<var-or-fncall> -> var #'(lambda (a) (cons 'var a))) ;80
			       (<var-or-fncall> -> <fncall> 1) ;81			       
			       (<simple-fncall> -> id left-par <expr-list> right-par #'(lambda (a b c d) (cons (cons 'id a) c))) ;82
			       (<simple-fncall> -> id left-par right-par #'(lambda (a b c) (list (cons 'id a)))) ;82
			       (<fncall> -> <simple-fncall> 1)
			       (<fncall> -> uri-cast <expr> right-par #'(lambda (a b c) (list (list 'uri a) b))) ;83
			       (<fncall> -> pref uri-tail-cast <expr> right-par ;84
					 #'(lambda (a b c d) (list (list 'prefixed a b) c)))
			       (<fncall> -> uri-tail-cast <expr> right-par ;85
					 #'(lambda (a b c) (list (list 'prefixed "" a) b)))
			       (<fncall> -> <var-or-fncall> left-bracket <range-expr-list> right-bracket #'(lambda (a b c d) (cons 'aref (cons a c)))) ;86

			       (<expr-list> -> <expr> #'(lambda (a) (list a))) ;87
			       (<expr-list> -> <expr> comma <expr-list> #'(lambda (a b c) (cons a c))) ;88

      			       (<range-expr> -> colon #'(lambda (a) (list 'range0))) ;89
			       (<range-expr> -> <num-expr> 1) ;90
			       (<range-expr> -> <num-expr> colon <num-expr> #'(lambda (a b c) (list 'range2 a c))) ;91
			       (<range-expr> -> colon <num-expr> #'(lambda (a b) (list 'range2 '(number "0") b))) ;92
			       (<range-expr> -> <num-expr> colon #'(lambda (a b) (list 'range2 a '(number "-1")))) ;93
			       (<range-expr> -> <num-expr> colon <num-expr> colon <num-expr> #'(lambda (a b c d e) (list 'range3 a c e))) ;94
			       (<range-expr> -> colon <num-expr> colon <num-expr> #'(lambda (a b c d) (list 'range3 '(number "0") b d))) ;95
			       (<range-expr> -> <num-expr> colon <num-expr> colon #'(lambda (a b c d) (list 'range3 a c '(number "-1")))) ;96
			       (<range-expr> -> colon <num-expr> colon #'(lambda (a b c) (list 'range3 '(number "0") b '(number "-1")))) ;97
			       (<range-expr> -> colon colon <num-expr> #'(lambda (a b c) (list 'range3 '(number "0") '(number "-1") c))) ;97a
			       (<range-expr> -> <num-expr> colon colon <num-expr> #'(lambda (a b c d) (list 'range3 a '(number "-1") d))) ;97b

			       (<range-expr-list> -> <range-expr> #'(lambda (a) (list a))) ;98
			       (<range-expr-list> -> <range-expr> comma <range-expr-list> #'(lambda (a b c) (cons a c))) ;99

			       (<prefixed-stat> -> <define> #'(lambda (a) (list nil a))) ;100
			       (<define> -> define function id left-par <var-list> right-par as <decl-body> ;101
					  #'(lambda (a b c d e f g h) (make-define-stat :name c :agg nil :vars e :body h)))
			       (<define> -> define aggregate id left-par var right-par as <decl-body> ;102
					  #'(lambda (a b c d e f g h) (make-define-stat :name c :agg t :vars (list e) :body h)))
			       (<decl-body> -> id string #'(lambda (a b) (list a b))) ;103
			       (<decl-body> -> lisp string #'(lambda (a b) (list "lisp" b))) 
			       (<decl-body> -> <select> #'(lambda (a) (list 'sparql a))) ;106
			       (<construct> -> construct <block> #'(lambda (a b) (make-sparql-stat :type 'construct :what b)))
                               (<construct> -> <construct> from uri #'(lambda (a b c) (setf (sparql-stat-from a) c) a))
                               (<construct> -> <construct> where <block>  #'(lambda (a b c) (setf (sparql-stat-where a) c) a))
			       ))

(make-slr1-parser (grammar-from-johnsons sparql-grammar) '(semicolon) "sparql-slr1" "sparql-slr1.lsp")
