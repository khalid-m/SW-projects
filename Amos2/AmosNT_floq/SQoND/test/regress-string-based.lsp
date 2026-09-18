;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-2012, Andrej Andrejev, UDBL
;;;
;;; Description: String-based SPARQL regression test
;;; =============================================================


;(with-directory (concat (getenv "AMOS_HOME") "/SQoND") (load "lsp/string-based-wrapper.lsp"))

(osql "< 'w3c-queries.osql';")

(checkequal 
 "queries from W3C specifications at http://www.w3.org/TR/rdf-sparql-query/ "
 ((sparql "LOAD('data/sparql11/6.1.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q6_1);"))
  (sorttuples '((#("Alice" "mailto:alice@example.com")) 
		(#("Alice" "mailto:alice@work.example")) 
		(#("Bob" nil)))))

 ((sparql "LOAD('data/sparql11/3.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q6_2);")) 
  (sorttuples  '((#("SPARQL Tutorial" nil)) 
		 (#("The Semantic Web" "23")))))
	     
 ((sparql "LOAD('data/sparql11/6.3.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q6_3);")) 
  (sorttuples '((#("Alice" nil "http://work.example.org/alice/")) 
		(#("Bob" "mailto:bob@work.example" nil)))))
	     
 ((sparql "LOAD('data/sparql11/7.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q7a);")) 
  (sorttuples '((#("SPARQL Query Language Tutorial")) 
		(#("SPARQL")) (#("SPARQL Protocol Tutorial")) 
		(#("SPARQL (updated)")))))
 ((sorttuples (osql "sparql(:q7b);")) 
  (sorttuples '((#("SPARQL Query Language Tutorial" nil)) 
		(#("SPARQL" nil)) 
		(#(nil "SPARQL Protocol Tutorial")) 
		(#(nil "SPARQL (updated)")))))
 ((sorttuples (osql "sparql(:q7c);")) 
  (sorttuples '((#("SPARQL Query Language Tutorial" "Alice")) 
		(#("SPARQL Protocol Tutorial" "Bob")))))
	    
 ((sparql "LOAD('data/sparql11/16.1.1.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q16_1_1);")) 
  (sorttuples '((#("Alice" "Bob" nil)) 
		(#("Alice" "Clare" "CT")))))
 )


(osql "< 'dawg-queries.osql';")

(checkequal 
 "queries from DAWG testcases at http://www.w3.org/2001/sw/DataAccess/tests/ "
 ((sparql "LOAD('data/dawg/Expr1/data-1.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_expr1);")) 
  (sorttuples '((#("TITLE 1" "10")) 
		(#("TITLE 2" nil)) 
		(#("TITLE 3" nil)))))
; ((osql "sparql(:q_expr2);") '((#("TITLE 1" "10")))) ;TODO: detect and check semibound variables in FILTER expressions! 
                                                      ; (RDF-based version relies on comparable() condition)

 ((sparql "LOAD('data/dawg/extracted-examples/data-5.5.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_5_5);")) 
  (sorttuples '((#("Alice" "mailto:alice@work.example" "Alice" "Hacker")) 
		(#("Bob" "mailto:bob@work.example" nil nil)) 
		(#("Ella" nil "Eleanor" nil)))))
 ((sorttuples (osql "sparql(:q_5_5a);")) 
  (sorttuples '((#("Alice" "mailto:alice@work.example" "Alice" 
		   "Hacker" nil)) 
		(#("Bob" "mailto:bob@work.example" nil 
		   nil nil)) 
		(#("Ella" nil "Eleanor" nil nil)))))

 ((sparql "LOAD('data/dawg/extracted-examples/data-10.2.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_10_2);")) 
  (sorttuples '((#("Alice" "Bob" nil)) 
		(#("Alice" "Clare" "CT")))))
 )

(osql "< 'priority-binding-queries.osql';")

(checkequal 
 "queries to detect prioritized inner joins 
  from http://user.it.uu.se/~andan342/pij3.ppt"
 ((sparql "LOAD('data/pij3.ttl',true)") nil)
 ((sorttuples (osql "sparql(:Q1);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/y2" "z2")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")))))
 ((sorttuples (osql "sparql(:Q2);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/y2" "z2")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")) 
		(#("http://example.org/x4" "http://example.org/y4" 
		   nil)))))
 ((sorttuples (osql "sparql(:Q3);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/y2" "z2")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")))))

 ((sparql "LOAD('data/pij3a.ttl',true)") nil)
 ((osql "sparql(:Q1);") '((#("http://example.org/x3" "http://example.org/y3"
			     "z3"))))
 ((sorttuples (osql "sparql(:Q2);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/y2" "z2")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")) 
		(#("http://example.org/x4" "http://example.org/y4" 
		   nil)))))
 ((sorttuples (osql "sparql(:Q3);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/y2" "z2a")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")))))
 )

(checkequal 
 "queries binding same variables with several OPTOTONAL:s and/or UNION:s"
 ((sparql "LOAD('data/quu.ttl',true)") nil)
 ((osql "sparql(:q_uu);") 
  '((#("http://example.org/x2" nil "z"))))
; ((osql "sparql(:q_uu1);") ;TODO: Binding filter problem
;  '((#("http://example.org/x2" nil "z"))))
	    
 ((sparql "LOAD('data/qoo.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_oo);")) 
  (sorttuples '((#("http://example.org/x1" "http://example.org/x1y" 
		   nil)) 
		(#("http://example.org/x2" "http://example.org/x2y" "z")) 
		(#("http://example.org/x3" nil nil)))))
	    
 ((sparql "LOAD('data/quo.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_uo);")) 
  (sorttuples '((#("http://example.org/x2" "http://example.org/x2y" 
		   nil)) 
		(#("http://example.org/x2" "http://example.org/x2y" "z")))))

 ((sparql "LOAD('data/qouf.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_ouf1);")) 
  (sorttuples '((#("http://example.org/x1" "http://example.org/y1" "z1")) 
		(#("http://example.org/x3" "http://example.org/y3" "z3")))))

 ((sparql "LOAD('data/qouoo.ttl',true)") nil)
 ((sorttuples (osql "sparql(:q_ouoo);")) 
  (sorttuples '((#("http://example.org/x1" "y1" "z1")) 
		(#("http://example.org/x2" "y2" "z2")) 
		(#("http://example.org/x3" "y3" "z3")) 
		(#("http://example.org/x4" nil "z4")))))
 )


