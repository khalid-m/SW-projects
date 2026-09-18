;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-grammar.lsp,v $
;;; $Revision: 1.4 $ $Date: 2012/02/28 21:25:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SparQL grammar in format accepted by GRM parser generator
;;; =============================================================


;; Very simple SparQL grammar that is able to parse queries from SWARD regression test

(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(load "sparql-lsp-parser-datamodel.lsp")

(defparameter sparql-grammar '(
			       (<prefixed-stat> -> <select> #'(lambda (a) (list nil a)))
                               (<prefixed-stat> -> <construct> #'(lambda (a) (list nil a)))			       
			       (<prefixed-stat> -> prefix id localname uri <prefixed-stat> #'(lambda (a b c d e) (push (cons b d) (first e)) e)) ; localname is empty
			       (<select> -> select <var-list> #'(lambda (a b) (make-select-stat :what b)))
			       (<select> -> select distinct <var-list> #'(lambda (a b c) (make-select-stat :what c :distinct t)))
			       (<select> -> <select> from uri #'(lambda (a b c) (setf (select-stat-from a) c) a))
			       (<select> -> <select> where <block> #'(lambda (a b c) (setf (select-stat-where a) c) a))
			       (<var-list> -> var #'(lambda (a) (list a)))
			       (<var-list> -> var <var-list> #'(lambda (a b) (cons a b)))
			       ;;("x" "y")
			       (<block> -> left-brace <conds> right-brace #'(lambda (a b c) (make-block :conds b)))
			       (<conds> -> <triples> #'(lambda (a) (list a))) ;DOT after triples is only optional in the end of block
			       (<conds> -> <triples> dot #'(lambda (a b) (list a)))
			       (<conds> -> <triples> dot <conds> #'(lambda (a b c)  (cons a c)))
			       (<conds> -> <nontriples> dot #'(lambda (a b) (list a)))
			       (<conds> -> <nontriples> #'(lambda (a) (list a)))
			       (<conds> -> <nontriples> dot <conds> #'(lambda (a b c) (cons a c)))
			       (<conds> -> <nontriples> <conds> #'(lambda (a b) (cons a b))) ; DOT after non-triple conditions is always optional;			       
			       ;;(triple (var "x") (uri "http://w3.org/prop") (string "a"))
			       (<nontriples> -> filter left-par <expr> right-par #'(lambda (a b c d) (cons 'filter c)))
			       (<nontriples> -> filter <fncall> #'(lambda (a b) (cons 'filter b)))			       
			       (<expr> -> <expr> or <conjunction> #'(lambda (a b c) (list 'or a c))) ;54
			       (<expr> -> <conjunction> 1) ;55
			       (<conjunction> -> <conjunction> and <rel-expr> #'(lambda (a b c) (list 'and a c))) ;56
			       (<conjunction> -> <rel-expr> 1) ;57
			       (<rel-expr> -> <prime-expr> 1) ;58
			       (<rel-expr> -> <prime-expr> <compare-op> <prime-expr> #'(lambda (a b c) (list b a c))) ;59
			       (<prime-expr> -> <object> 1)
			       (<prime-expr> -> left-par <expr> right-par #'(lambda (a b c) b)) ;76
			       (<prime-expr> -> not <prime-expr> #'(lambda (a b) (list 'not b))) ;78
			       (<prime-expr> -> <fncall> 1)
			       (<fncall> -> id left-par <expr-list> right-par #'(lambda (a b c d) (cons (cons 'id a) c))) ;82
			       (<expr-list> -> <expr> #'(lambda (a) (list a))) ;87
			       (<expr-list> -> <expr> comma <expr-list> #'(lambda (a b c) (cons a c))) ;88
			       ;;(filter not-equal (var "y") (string "b")))
;			       (<nontriples> -> filter regex left-par var comma string right-par #'(lambda (a b c d e f g) (list 'regex (cons 'var d) f)))
			       (<nontriples> -> optional <block> #'(lambda (a b) (cons 'optional b)))			       
			       (<nontriples> -> <union> 1)
			       (<union> -> <block> union <block> #'(lambda (a b c) (list 'union a c)))
			       (<union> -> <union> union <block> #'(lambda (a b c) (append a (list c)))) 
			       ;;((triples ((var "x") (uri "http://w3.org/prop") (string "a"))))
			       (<triples> -> <uri-or-var> <uri-or-var> <object> #'(lambda (a b c) (list 'triples (list a b c))))
			       (<triples> -> <triples> semicolon <uri-or-var> <object> #'(lambda (a b c d) (append a (list (list (caar (last a)) c d)))))
			       (<triples> -> <triples> comma <object> #'(lambda (a b c) (let ((lt (car (last a)))) (append a (list (list (car lt) (cadr lt) c))))))
			       (<object> -> string #'(lambda (a) (cons 'string a)))
			       (<object> -> <uri-or-var> 1)
			       (<uri-or-var> -> uri #'(lambda (a) (cons 'uri a)))
			       (<uri-or-var> -> var #'(lambda (a) (cons 'var a)))
			       (<uri-or-var> -> id localname #'(lambda (a b) (list 'prefixed a b)))
			       (<compare-op> -> not-equal #'(lambda (a) '!=)) 
			       (<compare-op> -> equal #'(lambda (a) '=)) 
			       (<compare-op> -> less #'(lambda (a) '<)) 
			       (<compare-op> -> greater #'(lambda (a) '>)) 
			       (<compare-op> -> less-or-equal #'(lambda (a) '<=)) 
			       (<compare-op> -> greater-or-equal #'(lambda (a) '>=)) 
                               (<construct> -> construct <block> #'(lambda (a b) (make-construct-stat :what b)))
                               (<construct> -> <construct> from uri #'(lambda (a b c)(setf (construct-stat-from a) c) a))
                               (<construct> -> <construct> where <block>  #'(lambda (a b c)(setf (construct-stat-where a) c) a))
			       ))

(make-slr1-parser (grammar-from-johnsons sparql-grammar) nil "sparql-slr1" "sparql-slr1.lsp" )


