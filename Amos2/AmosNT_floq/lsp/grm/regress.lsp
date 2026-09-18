(defparameter ex2 '(
		    (<expr> -> <expr> + <term> #'(lambda (a b c) (list '+ a c))) ;1
		    (<expr> -> <expr> - <term> #'(lambda (a b c) (list '- a c))) ;2
		    (<expr> -> <term> 1) ;3
		    (<term> -> <term> * <factor> #'(lambda (a b c) (list '* a c))) ;4
		    (<term> -> <term> / <factor> #'(lambda (a b c) (list '/ a c))) ;5
		    (<term> -> <factor> 1) ;6
		    (<factor> -> const 1) ;7
		    (<factor> -> var 1) ;8
		    (<factor> -> lp <expr> rp 2) ;9
		    ))

(load "ascend.lsp")

(make-slr1-parser (grammar-from-johnsons ex2) '(semicolon) "slr1-parser" "ex2.lsp" nil)

(load "ex2.lsp")

(checkequal "generated parser for infix arithmetics - correct input"
	    ((let ((input '((const . 1) (+) (const . 2) (*) (const . 3) (semicolon) (const . 4))))
	       (slr1-parser (f/l () (pop input)) nil))
	     '(+ 1 (* 2 3))))

(checkequal "generated parser for infix arithmetics - throwing errors"
	    ((let ((input '((const . 1) (+) (const . 2) (*) (*) (const . 3))))
	       (slr1-parser (f/l () (pop input)) nil))
	     '(SYNTAX-ERROR *-4.2 (CONST VAR LP) *)))

(delete-file "ex2.lsp")