;; Very simple SparQL grammar that is able to parse queries from SWARD regression test

(load "ascend.lsp")

(load "sparql-lsp-parser-datamodel.lsp")

;;TODO: add functional calls as <prim-expr>

;;TODO prefixed URIs may have leading digits in second part

(defparameter sparql-grammar '(
			       (<prefixed-stat> -> <select> #'(lambda (a) (list nil a)))			       
			       (<prefixed-stat> -> prefix id localname iri <prefixed-stat> #'(lambda (a b c d e) (push (cons b d) (first e)) e)) ; localname is empty
			       (<select> -> select <sel-list> #'(lambda (a b) (make-select-stat :what b)))
			       (<select> -> <select> from iri #'(lambda (a b c) (setf (select-stat-from a) c) a))
			       (<select> -> <select> where left-brace <conds> right-brace #'(lambda (a b c d e) (setf (select-stat-where a) d) a))
			       (<sel-list> -> <agg-expr> #'(lambda (a) (list a)))
			       (<sel-list> -> <agg-expr> <sel-list> #'(lambda (a b) (cons a b)))
			       ;;("x" "y")
			       (<conds> -> <cond> #'(lambda (a) (list a)))
			       (<conds> -> <cond> dot #'(lambda (a b) (list a)))
			       (<conds> -> <cond> dot <conds> #'(lambda (a b c)  (cons a c)))
			       ;;((triple (var "x") (iri "http://w3.org/prop") (string "a"))
			       (<cond> -> <iri-or-var> <iri-or-var> <num-expr> #'(lambda (a b c) (list 'triple a b c))) 
			       ;;(triple (var "x") (iri "http://w3.org/prop") (string "a"))
			       (<cond> -> filter left-par <expr> right-par #'(lambda (a b c d) (cons 'filter c))) 
			       ;;(filter non-equal (var "y") (string "b")))
			       (<cond> -> filter regex left-par var comma string right-par #'(lambda (a b c d e f g) (list 'regex (cons 'var d) f)))
			       (<cond> -> optional left-brace <conds> right-brace #'(lambda (a b c d) (cons 'optional c)))
			       (<iri-or-var> -> <iri-ref> #'(lambda (a) a))
			       (<iri-or-var> -> var #'(lambda (a) (cons 'var a)))			       
			       (<expr> -> <expr> or <conjunction> #'(lambda (a b c) (list 'or a c)))
			       (<expr> -> <conjunction> #'(lambda (a) a))
			       (<conjunction> -> <conjunction> and <rel-expr> #'(lambda (a b c) (list 'and a c)))
			       (<conjunction> -> <rel-expr> #'(lambda (a) a))
			       (<rel-expr> -> <num-expr> #'(lambda (a) a)) ;21
			       (<rel-expr> -> <num-expr> equal <num-expr> #'(lambda (a b c) (list '= a c))) ;22
			       (<rel-expr> -> <num-expr> not-equal <num-expr> #'(lambda (a b c) (list '!= a c))) ;23
			       (<rel-expr> -> <num-expr> less <num-expr> #'(lambda (a b c) (list '< a c))) ;24
			       (<rel-expr> -> <num-expr> greater <num-expr> #'(lambda (a b c) (list '> a c))) ;25
			       (<rel-expr> -> <num-expr> less-or-equal <num-expr> #'(lambda (a b c) (list '<= a c))) ;26
			       (<rel-expr> -> <num-expr> greater-or-equal <num-expr> #'(lambda (a b c) (list '>= a c))) ;27
			       (<num-expr> -> <num-expr> plus <mult-expr> #'(lambda (a b c) (list '+ a c))) ;28
			       (<num-expr> -> <num-expr> minus <mult-expr> #'(lambda (a b c) (list '- a c))) ;29
			       (<num-expr> -> minus <mult-expr> #'(lambda (a b) (list '- b)))  ;30
			       (<num-expr> -> <mult-expr> #'(lambda (a) a)) ;31
			       (<mult-expr> -> <mult-expr> times <prim-expr> #'(lambda (a b c) (list '* a c))) ;32
			       (<mult-expr> -> <mult-expr> divide <prim-expr> #'(lambda (a b c) (list '/ a c))) ;33
			       (<mult-expr> -> <prim-expr> #'(lambda (a) a)) ;34
			       (<prim-expr> -> left-par <expr> right-par #'(lambda (a b c) b)) ;35
			       (<prim-expr> -> <literal> #'(lambda (a) a)) ;36
			       (<prim-expr> -> <iri-ref> #'(lambda (a) a)) ;37
			       (<prim-expr> -> var #'(lambda (a) (cons 'var a))) ;38
			       (<prim-expr> -> not <prim-expr> #'(lambda (a b) (list 'not b)))
			       (<literal> -> <string-lang> #'(lambda (a) a))
			       (<literal> -> <string-lang> double-cap <iri-ref> #'(lambda (a b c) (append a (list c))))
			       (<literal> -> number #'(lambda (a) (cons 'number a)))
			       (<literal> -> true #'(lambda (a) '(true)))
			       (<literal> -> false #'(lambda (a) '(false)))
			       (<string-lang> -> string #'(lambda (a) (list 'literal a)))
			       (<string-lang> -> string langtag #'(lambda (a b) (list 'literal a b)))
			       (<iri-ref> -> iri #'(lambda (a) (cons 'iri a)))
			       (<iri-ref> -> id localname #'(lambda (a b) (list 'prefixed a b))) 			       
			       (<agg-expr> -> <num-expr> #'(lambda (a) a)) ;new
			       (<agg-expr> -> <agg-fn> left-par <num-expr> right-par #'(lambda (a b c d) (list a c))) ;new
			       (<agg-fn> -> count #'(lambda (a) 'count))
			       (<agg-fn> -> sum #'(lambda (a) 'sum))
			       (<agg-fn> -> min #'(lambda (a) 'min))
			       (<agg-fn> -> max #'(lambda (a) 'max))
			       (<agg-fn> -> avg #'(lambda (a) 'avg))
			       ))

(make-slr1-parser (grammar-from-johnsons sparql-grammar) "slr1-parser.lsp")


