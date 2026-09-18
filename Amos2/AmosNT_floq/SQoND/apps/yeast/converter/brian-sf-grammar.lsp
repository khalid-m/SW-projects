(load (concat (getenv "AMOS_HOME") "/lsp/grm/ascend.lsp"))

(defparameter brian-sf-grammar '(
				 (<sf> -> <model> int <algorithm> <input> d int int tf int tstep int son int int km int kon float dash int 
				       #'(lambda (a b c d e f g h i j k l m n o p q r s u)
					   (make-sf :model a :version b :algorithm c :input d :d (concat f "." g) :tf i :tstep k :son (concat m "." n)
						    :km p :kon r :trajno u)))			      
				 (<model> -> all alt #'(lambda (a b) "\"ALL_alt\""))
				 (<algorithm> -> issa #'(lambda (a) ":issa_Algorithm"))
				 (<input> -> grad switch #'(lambda (a b) ":GradientWithSwitching_Input"))
				 ))

(make-slr1-parser (grammar-from-johnsons brian-sf-grammar) nil "brian-sf-slr1-parser" "brian-sf-slr1.lsp" nil)