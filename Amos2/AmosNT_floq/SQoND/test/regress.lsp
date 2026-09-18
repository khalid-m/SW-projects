3;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-2014, Andrej Andrejev, UDBL
;;;
;;; Description: genearal SSDM regression test
;;; =============================================================

;; (osql "create function DEF() -> (Literal s, Literal p, Literal o);")
;; ^ MOVED TO master.lsp

; (checkequal "verify-all"   
;	    ((verify-all) t))

(setq _sq_strict_ t)

(osql "< 'w3c-queries.osql';")

(checkequal "queries from W3C specifications at http://www.w3.org/TR/sparql11-query/ "

	    ((sparql "LOAD('data/sparql11/2.1.ttl',true)") nil)
	    ((sparql amos_q2_1) '((#[USTR "SPARQL Tutorial"])))

	    ((sparql "LOAD('data/sparql11/2.2.ttl',true)") nil)
	    ((sorttuples (sparql amos_q2_2)) (sorttuples '((#[USTR "Johnny Lee Outlaw"] #[URI "mailto:jlow@example.com"]) 
							   (#[USTR "Peter Goodguy"] #[URI "mailto:peter@example.org"]))))

	    ((sparql "LOAD('data/sparql11/2.5.ttl',true)") nil)
	    ((sparql amos_q2_5a) '((#[USTR "John Doe"])))
	    ((sparql amos_q2_5b) '((#[USTR "John Doe"])))

	    ((sparql "LOAD('data/sparql11/2.6x.ttl',true)") nil) ; Replaced blanks with URIs
	    ((sorttuples (sparql amos_q2_6)) (sorttuples '((#[URI "http://example.com/staff#a"] #[URI "http://xmlns.com/foaf/0.1/name"] #[USTR "Alice"]) 
							   (#[URI "http://example.com/staff#b"] #[URI "http://xmlns.com/foaf/0.1/name"] #[USTR "Bob"]))))

	    ((sparql "LOAD('data/sparql11/3.ttl',true)") nil)
	    ((sparql amos_q3_1a) '((#[USTR "SPARQL Tutorial"])))
	    ((sparql amos_q3_1b) '((#[USTR "The Semantic Web"])))
	    ((sparql amos_q3_2) '((#[USTR "The Semantic Web"] 23)))

	    ((sparql "LOAD('data/sparql11/6.1.ttl',true)") nil)
	    ((sorttuples (sparql amos_q6_1)) (sorttuples '((#[USTR "Alice"] #[URI "mailto:alice@example.com"])
							   (#[USTR "Alice"] #[URI "mailto:alice@work.example"])
							   (#[USTR "Bob"] nil))))	    

	    ((sparql "LOAD('data/sparql11/3.ttl',true)") nil)
	    ((sorttuples (sparql amos_q6_2)) (sorttuples  '((#[USTR "SPARQL Tutorial"] nil)
							    (#[USTR "The Semantic Web"] 23))))

	    ((sparql "LOAD('data/sparql11/6.3.ttl',true)") nil)
	    ((sorttuples (sparql amos_q6_3)) (sorttuples '((#[USTR "Alice"] nil #[URI "http://work.example.org/alice/"]) 
							   (#[USTR "Bob"] #[URI "mailto:bob@work.example"] nil))))
	     
	    ((sparql "LOAD('data/sparql11/7.ttl',true)") nil)
	    ((sorttuples (sparql amos_q7a)) (sorttuples '((#[USTR "SPARQL Query Language Tutorial"])
							  (#[USTR "SPARQL"])
							  (#[USTR "SPARQL Protocol Tutorial"])
							  (#[USTR "SPARQL (updated)"]))))
	    ((sorttuples (sparql amos_q7b)) (sorttuples '((#[USTR "SPARQL Query Language Tutorial"] nil)
							  (#[USTR "SPARQL"] nil)
							  (nil #[USTR "SPARQL Protocol Tutorial"])
							  (nil #[USTR "SPARQL (updated)"]))))
	    ((sorttuples (sparql amos_q7c)) (sorttuples '((#[USTR "SPARQL Query Language Tutorial"] #[USTR "Alice"])
							  (#[USTR "SPARQL Protocol Tutorial"] #[USTR "Bob"]))))

	    ((sparql "LOAD('data/sparql11/8.1.ttl',true)") nil)
	    ((sparql amos_q8_1_1) '((#[URI "http://example/bob"])))
	    ((sparql amos_q8_1_2) '((#[URI "http://example/alice"])))

	    ((sparql "LOAD('data/sparql11/8.3.1.ttl',true)") nil)
	    ((sparql amos_q8_3_1a) nil)
	    ((sparql amos_q8_3_3a) nil)

	    ((sparql "LOAD('data/sparql11/8.3.3.ttl',true)") nil)
	    ((sparql amos_q8_3_3a) '((#[URI "http://example.com/b"] 3.0)))
	    

	    ((sparql "LOAD('data/sparql11/10.1.ttl',true)") nil) ; original
	    ((sparql amos_q10_1a) '((#[USTR "The Semantic Web"] 17.25)))
	    ((sparql "LOAD('data/sparql11/10.1x.ttl',true)") nil) ; 1 missing ns:discount 
	    ((sparql amos_q10_1ax) '((#[USTR "The Semantic Web"] 17.25)))

	    ((sparql "LOAD('data/sparql11/11.1.ttl',true)") nil)
	    ((sparql amos_q11_1) '((21)))

	    ((sparql "LOAD('data/sparql11/11.5x.ttl',true)") nil) ; only numbes
	    ((sorttuples (sparql amos_q11_5)) (sorttuples '((#[URI "http://example.com/data/#x"] 2.5 2.5) 
							    (#[URI "http://example.com/data/#y"] 252.0 500.5) 
							    (#[URI "http://example.com/data/#z"] 2.75 3.0))))
	    ((sorttuples (sparql amos_q11_5x)) (sorttuples '((#[URI "http://example.com/data/#x"] 1 3) ; cross-referensing in aggregate query
							     (#[URI "http://example.com/data/#y"] 1 999)
							     (#[URI "http://example.com/data/#z"] 1.0 4.0))))
	    ((sorttuples (sparql amos_q11_5y)) (sorttuples '((#[URI "http://example.com/data/#x"] 0.9 3.1) 
							     (#[URI "http://example.com/data/#y"] 0.9 999.1)
							     (#[URI "http://example.com/data/#z"] 0.9 4.1))))
	    ((sparql amos_q11_5z) '((500))) ; aggregation without grouping
	    ((sparql amos_q11_5zz) '((1000 500)))

	    ((sparql "LOAD('data/sparql11/12x.ttl',true)") nil) ; uneven numbers of names
	    ((sorttuples (sparql amos_q12x)) (sorttuples '((#[URI "http://people.example/bob"] 2) ; changed 'min' to 'count'
							   (#[URI "http://people.example/carol"] 3))))
	    ((sparql amos_q12y) '((#[URI "http://people.example/carol"] 3))) ; added 'having'
	    ((roundto-all (sparql amos_q12z) 3) '((#[URI "http://people.example/carol"] 6 0.167))) ; added cross-references to be pushed into outer query

	    ((sparql "LOAD('data/sparql11/13.2.1.ttl',true,<http://example.org/foaf/aliceFoaf>)") nil)
	    ((sparql amos_q13_2_1) '((#[USTR "Alice"])))

	    ((sparql "LOAD('data/sparql11/13.2.3.ttl',true,<http://example.org/dft.ttl>)") nil)
	    ((sparql "LOAD('data/sparql11/13.2.3.alice.ttl',true,<http://example.org/alice>)") nil)
	    ((sparql "LOAD('data/sparql11/13.2.3.bob.ttl',true,<http://example.org/bob>)") nil)
	    ((sorttuples (sparql amos_q13_2_3)) (sorttuples '((#[USTR "Bob Hacker"] #[URI "http://example.org/bob"] #[URI "mailto:bob@oldcorp.example.org"]) 
							      (#[USTR "Alice Hacker"] #[URI "http://example.org/alice"] #[URI "mailto:alice@work.example.org"]))))

	    ((sparql "LOAD('data/sparql11/13.3.alice.ttl',true,<http://example.org/foaf/aliceFoaf>)") nil)
	    ((sparql "LOAD('data/sparql11/13.3.bob.ttl',true,<http://example.org/foaf/bobFoaf>)") nil)
	    ((sorttuples (sparql amos_q13_3_1)) (sorttuples '((#[URI "http://example.org/foaf/bobFoaf"] #[USTR "Robert"]) 
							      (#[URI "http://example.org/foaf/aliceFoaf"] #[USTR "Bobby"]))))
	    ((sparql amos_q13_3_2) '((#[USTR "Robert"])))
	    ((sparql amos_q13_3_3) '((#[URI "mailto:bob@work.example"] #[USTR "Robert"] #[URI "http://example.org/foaf/bobFoaf"])))

	    ((sparql "LOAD('data/sparql11/13.3.4.ttl',true)") nil)
	    ((sparql "PREFIX g: <tag:example.org,2005-06-06:>") nil) ;TODO: loading predixes from TTL might also help
	    ((sparql "LOAD('data/sparql11/13.3.4.graph1.ttl', true, g:graph1)") nil)
	    ((sparql "LOAD('data/sparql11/13.3.4.graph2.ttl', true, g:graph2)") nil)
	    ((sorttuples (sparql amos_q13_3_4)) (sorttuples '((#[USTR "Bob"] #[URI "mailto:bob@oldcorp.example.org"] #[TYPEDRDF "2004-12-06" "http://www.w3.org/2001/XMLSchema#date"]) 
							      (#[USTR "Bob"] #[URI "mailto:bob@newcorp.example.org"] #[TYPEDRDF "2005-01-10" "http://www.w3.org/2001/XMLSchema#date"]))))
	    
	    ((sparql "LOAD('data/sparql11/15.3.ttl',true)") nil)
	    ((sparql amos_q15_3) '((#[USTR "Alice"]) (#[USTR "Alice"]) (#[USTR "Alice"])))
	    ((sparql amos_q15_3_1) '((#[USTR "Alice"])))
	    
	    ((sparql "LOAD('data/sparql11/16.1.1.ttl',true)") nil)
	    ((sorttuples (sparql amos_q16_1_1)) (sorttuples '((#[USTR "Alice"] #[USTR "Bob"] nil)
							      (#[USTR "Alice"] #[USTR "Clare"] #[USTR "CT"]))))

	    ((sparql "LOAD('data/sparql11/16.1.2.ttl',true)") nil)
	    ((sorttuples (sparql amos_q16_1_2a)) (sorttuples '((#[USTR "SPARQL Tutorial"] 33.6) 
							       (#[USTR "The Semantic Web"] 17.25))))
	    ((sorttuples (sparql amos_q16_1_2b)) (sorttuples '((#[USTR "SPARQL Tutorial"] 42 33.6)
							       (#[USTR "The Semantic Web"] 23 17.25))))

	    ((sparql "LOAD('data/sparql11/16.2.ttl',true)") nil)
	    ((sparql amos_q16_2) '((#[URI "http://example.org/person#Alice"] #[URI "http://www.w3.org/2001/vcard-rdf/3.0#FN"] #[USTR "Alice"])))
	    
	    ((sparql "LOAD('data/sparql11/16.3.ttl',true)") nil)
	    ((sparql amos_q16_3) '((TRUE)))

	    ((sparql "LOAD('data/sparql11/17.4.1.1.ttl',true)") nil)
	    ((sparql amos_q17_4_1_1) '((#[USTR "Bob"])))
	    
    	    ((sparql "LOAD('data/sparql11/17.4.2.1.ttl',true)") nil)
	    ((sparql amos_q17_4_2_1) '((#[USTR "Alice"] #[URI "mailto:alice@work.example"])))
	    ((sparql amos_q17_4_2_3) '((#[USTR "Bob"] #[USTR "bob@work.example"])))

	    ((sparql "LOAD('data/sparql11/17.4.2.2.ttl',true)") nil)
	    ((sparql amos_q17_4_2_2) '((#[USTR "Bob"] #[USTR "Smith"])))
	    
	    ((sparql "LOAD('data/sparql11/17.4.2.5.ttl',true)") nil)
	    ((sparql amos_q17_4_2_5) '((#[USTR "Alice"] #[URI "mailto:alice@work.example"])))
	    
	    ((sparql "LOAD('data/sparql11/17.4.2.7.ttl',true)") nil)
	    ((sparql amos_q17_4_2_7) '((#[USTR "Bob"] 42)))
	    
	    ((sparql "LOAD('data/sparql11/17.4.1.7a.ttl',true)") nil)
	    ((sorttuples (sparql amos_q17_4_1_7a)) (sorttuples '((#[USTR "Alice"] #[USTR "Ms A."])
								 (#[USTR "Ms A."] #[USTR "Alice"]))))
	    
	    ((sparql "LOAD('data/sparql11/17.4.3.14.ttl',true)") nil)
	    ((sparql amos_q17_4_3_14) '((#[USTR "Alice"])))
	    )

(unless (eq _sq_storage_system_ :sql-naive) ; current SQL-naive storage does not support typed RDF
  (checkequal "additional queries sensitive to langtags and custom types, ibid"
	      ((sparql "LOAD('data/sparql11/2.3.ttl',true)") nil)
	      ((sparql amos_q2_3_1a) nil)
	      ((sparql amos_q2_3_1b) '((#[URI "http://example.org/ns#x"])))
	      ((sparql amos_q2_3_2) '((#[URI "http://example.org/ns#y"])))
	      ((sparql amos_q2_3_3) '((#[URI "http://example.org/ns#z"])))
	      
	      ((sparql "LOAD('data/sparql11/17.4.2.6.ttl',true)") nil)
 	      ((sparql amos_q17_4_2_6) '((#[USTR "Roberto" "es"] #[URI "mailto:bob@work.example"])))
	      ))

(osql "< 'w3c-updates.osql';")

(checkequal "updates from W3C specifications at http://www.w3.org/TR/2013/REC-sparql11-update-20130321/ "

	    ((sparql "LOAD('data/sparql11u/5.before.ttl',true,<http://example/addresses>)") nil)
	    ((sparql amos_u5) nil)
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example/addresses')));")) (sorttuples (osql "turtle('data/sparql11u/5.after.ttl');")))

	    ((sparql "LOAD('data/sparql11u/6x.before.ttl',true)") nil)
	    ((sparql amos_u6x) nil)
	    ((sorttuples (osql "GRAPH(0);")) (sorttuples (osql "turtle('data/sparql11u/6x.after.ttl');")))

	    ((sparql "LOAD('data/sparql11u/7.before.ttl',true,<http://example/addresses>)") nil)
	    ((sparql amos_u7) nil)
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example/addresses')));")) (sorttuples (osql "turtle('data/sparql11u/7.after.ttl');")))
	    
	    ((sparql "LOAD('data/sparql11u/6x.before.ttl',true,<http://example/bookStore>)") nil)
	    ((sparql "LOAD('data/sparql11u/8.bookStore2.before.ttl',true,<http://example/bookStore2>)") nil)
	    ((sparql amos_u8x) nil)
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example/bookStore2')));")) (sorttuples (osql "turtle('data/sparql11u/8.bookStore2.after.ttl');")))

	    ((sparql "LOAD('data/sparql11u/9.people.ttl',true,<http://example/people>)") nil)
	    ((sparql "LOAD('data/sparql11u/9.addresses.before.ttl',true,<http://example/addresses>)") nil)
	    ((sparql amos_u9) nil)
	    ((sorttuples (mapcar #'cdr (osql "GRAPH(NGDict(URI('http://example/addresses')));"))) ;TODO: graph matching!
	     (sorttuples (mapcar #'cdr (osql "turtle('data/sparql11u/9.addresses.after.ttl');"))))
	    
	    ((sparql "LOAD('data/sparql11u/10.bookStore.before.ttl',true,<http://example/bookStore>)") nil)
	    ((sparql "LOAD('data/sparql11u/8.bookStore2.before.ttl',true,<http://example/bookStore2>)") nil)
	    ((sparql "SOURCE('w3c-u10x.sparql')") nil) ; multiple SPARQL statements ;TODO: single transaction!
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example/bookStore')));")) (sorttuples (osql "turtle('data/sparql11u/10.bookStore.after.ttl');")))
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example/bookStore2')));")) (sorttuples (osql "turtle('data/sparql11u/10.bookStore2.after.ttl');")))
	    
	    ((sparql "LOAD('data/sparql11u/7.before.ttl',true)") nil)
	    ((sparql amos_u11) nil)
	    ((sorttuples (osql "GRAPH(0);")) (sorttuples (osql "turtle('data/sparql11u/7.after.ttl');")))

	    ((sparql "LOAD('data/sparql11u/12.names.before.ttl',true,<http://example.com/names>)") nil)
	    ((sparql "LOAD('data/sparql11u/12.addresses.before.ttl',true,<http://example.com/addresses>)") nil)
	    ((sparql amos_u12) nil)
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example.com/names')));")) (sorttuples (osql "turtle('data/sparql11u/12.names.after.ttl');")))
	    ((sorttuples (osql "GRAPH(NGDict(URI('http://example.com/addresses')));")) (sorttuples (osql "turtle('data/sparql11u/12.addresses.after.ttl');")))	     
	    )

(osql "< 'dawg-queries.osql';")

(checkequal "queries from DAWG testcases at http://www.w3.org/2001/sw/DataAccess/tests/ "
	    ((sparql "LOAD('data/dawg/Expr1/data-1.ttl',true)") nil)
	    ((sorttuples (sparql amos_q_expr1)) (sorttuples '((#[USTR "TITLE 1"] 10)
							      (#[USTR "TITLE 2"] nil)
							      (#[USTR "TITLE 3"] nil))))
	    ((sparql amos_q_expr2) '((#[USTR "TITLE 1"] 10)))

	    ((sparql "LOAD('data/dawg/extracted-examples/data-5.5.ttl',true)") nil)
	    ((sorttuples (sparql amos_q_5_5)) (sorttuples '((#[USTR "Alice"] #[URI "mailto:alice@work.example"] #[USTR "Alice"] #[USTR "Hacker"])
							    (#[USTR "Bob"] #[URI "mailto:bob@work.example"] nil nil)
							    (#[USTR "Ella"] nil #[USTR "Eleanor"] nil))))
	    ((sorttuples (sparql amos_q_5_5a)) (sorttuples '((#[USTR "Alice"] #[URI "mailto:alice@work.example"] #[USTR "Alice"] #[USTR "Hacker"] nil)
							     (#[USTR "Bob"] #[URI "mailto:bob@work.example"] nil nil nil)
							     (#[USTR "Ella"] nil #[USTR "Eleanor"] nil nil))))
	    
	    ((sparql "LOAD('data/dawg/extracted-examples/data-10.2.ttl',true)") nil)
	    ((sorttuples (sparql amos_q_10_2)) (sorttuples '((#[USTR "Alice"] #[USTR "Bob"] nil)
							     (#[USTR "Alice"] #[USTR "Clare"] #[USTR "CT"]))))
	    )
   
(when (eq _sq_storage_system_ :in-memory) ; current implementation of OPTIONAL handles these queries correctly only with HASH-INDEX-SCAN access
  (osql "< 'priority-binding-queries.osql';")
  
  (checkequal "queries to detect prioritized inner joins from http://user.it.uu.se/~andan342/pij3.ppt"
	      ((sparql "LOAD('data/pij3.ttl',true)") nil)
	      ((sorttuples (sparql amos_Q1)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/y2"] #[USTR "z2"])
							   (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"]))))
	      ((sorttuples (sparql amos_Q2)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/y2"] #[USTR "z2"])
							   (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"])
							   (#[URI "http://example.org/x4"] #[URI "http://example.org/y4"] nil))))
	      ((sorttuples (sparql amos_Q3)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/y2"] #[USTR "z2"])
							   (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"]))))
	      
	      ((sparql "LOAD('data/pij3a.ttl',true)") nil)
	      ((sparql amos_Q1) '((#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"])))
	      ((sorttuples (sparql amos_Q2)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/y2"] #[USTR "z2"])
							   (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"])
							   (#[URI "http://example.org/x4"] #[URI "http://example.org/y4"] nil))))
	      ((sorttuples (sparql amos_Q3)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/y2"] #[USTR "z2a"])
							   (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"]))))
	      )

  (checkequal "queries binding same variables with several OPTOTONAL:s and/or UNION:s"
	      ((sparql "LOAD('data/quu.ttl',true)") nil)
	      ((sorttuples (sparql amos_q_uu)) (sorttuples '((#[URI "http://example.org/x2"] nil #[USTR "z"]))))
;	      ((sorttuples (sparql amos_q_uu1)) (sorttuples '((#[URI "http://example.org/x2"] nil #[USTR "z"]))))) ;BINDING FILTER PROBLEM
	      
	      ((sparql "LOAD('data/qoo.ttl',true)") nil)
	      ((sorttuples (sparql amos_q_oo)) (sorttuples '((#[URI "http://example.org/x1"] #[URI "http://example.org/x1y"] nil)
							     (#[URI "http://example.org/x2"] #[URI "http://example.org/x2y"] #[USTR "z"])
							     (#[URI "http://example.org/x3"] nil nil))))
	      
	      ((sparql "LOAD('data/quo.ttl',true)") nil)
	      ((sorttuples (sparql amos_q_uo)) (sorttuples '((#[URI "http://example.org/x2"] #[URI "http://example.org/x2y"] nil)
							     (#[URI "http://example.org/x2"] #[URI "http://example.org/x2y"] #[USTR "z"]))))
	      
	      ((sparql "LOAD('data/qouf.ttl',true)") nil)
	      ((sorttuples (sparql amos_q_ouf1)) (sorttuples '((#[URI "http://example.org/x1"] #[URI "http://example.org/y1"] #[USTR "z1"])
							       (#[URI "http://example.org/x3"] #[URI "http://example.org/y3"] #[USTR "z3"]))))
	    
	      ((sparql "LOAD('data/qouoo.ttl',true)") nil)
	      ((sorttuples (sparql amos_q_ouoo)) (sorttuples '((#[URI "http://example.org/x1"] #[USTR "y1"] #[USTR "z1"])
							       (#[URI "http://example.org/x2"] #[USTR "y2"] #[USTR "z2"])
							       (#[URI "http://example.org/x3"] #[USTR "y3"] #[USTR "z3"])
							       (#[URI "http://example.org/x4"] nil #[USTR "z4"]))))
	      ))


(osql "< 'collection-queries.osql';")

(checkequal "queries with generated blanks and collections "
	    ((sparql "LOAD('data/sparql11/17.4.2.5.ttl',true)") nil)
	    ((sparql amos_q4_1_4d) '((#[USTR "Alice"])))
	    ((sparql amos_q4_1_4e) '((#[USTR "Alice"])))
	    
	    ((sparql "LOAD('data/turtle/example2s1.ttl',true)") nil)
	    ((sparql amos_CQ1) '((#[URI "http://example.org/stuff/1.0/a"]))) ; EP corresponds to DNF with 16 UNION-ALL branches, each with at least 1 SQL call
	    ((sparql amos_CQ2) '((#[URI "http://example.org/stuff/1.0/a2"] #[USTR "banana"]))) ; 64 branches
	    ((sparql amos_CQ3) '((#[URI "http://example.org/stuff/1.0/a2"] #[USTR "banana"]))) ; 64 branches
	    ((sorttuples (sparql amos_CQ4)) (sorttuples '((#[URI "http://example.org/stuff/1.0/a"]) ; 4 branches
							  (#[URI "http://example.org/stuff/1.0/a2"]))))
	    )


(osql "< 'array-queries.osql';")

(setq _nma_proxy_threshold_ 1024) ; always return small arrays from the query

(checkequal "queries with numeric arrays"
	    ((sparql "LOAD('data/array/1.ttl',true)") nil)
	    ((sorttuples (sparql amos_array_q1)) (sorttuples '((#[URI "http://example.org/x"] #[NMA 0 (3) (1 2 3)])
							       (#[URI "http://example.org/y"] #[NMA 0 (2 3) ((1 2 3) (4 5 6))]))))
	    ((sparql amos_array_q2) '((#[URI "http://example.org/x"] #[NMA 0 (3) (1 2 3)])))
	    ((sparql amos_array_q2a) '((#[URI "http://example.org/y"] #[NMA 0 (2 3) ((1 2 3) (4 5 6))])))
	    ((sparql amos_array_q3) '((#[URI "http://example.org/y"] #[NMA 0 (2) (2 5)])))
	    ((sparql amos_array_q4) '((#[URI "http://example.org/y"] #[NMA 0 (2) (4 6)])))
	    ((sparql amos_array_q5) '((#[URI "http://example.org/y"] #[NMA 0 (3 2) ((1 4) (2 5) (3 6))])))
	    )

;; Queries with aggregation over arrays

(checkequal "queries with aggregation involving arrays"
	    ((sparql "LOAD('data/agg/array-agg.ttl',true)") nil)
	    ((sparql "PREFIX : <http://example.org/>;") nil)
	    ((sparql "SELECT (COUNT(?o) AS ?res) WHERE {?s ?p ?o}") '((4))) ; COUNT always works
;	    ((sparql "SELECT (SUM(?o) AS ?res) WHERE {:x ?p ?o}") '((#[NMA 1 (3) (5 -3.1 9)]))) ; only on arrays
	    ((sparql "SELECT (SUM(?o) AS ?res) WHERE {:y ?p ?o}") '((3.5))) ; and on numbers
;	    ((sparql "SELECT (AVG(?o) AS ?res) WHERE {?s ?p ?o}") ((#[NMA 1 (3) (2.5 -1.55 4.5)]))) ;TODO: eps-comparison
;	    ((sparql "SELECT (AVG(?o) AS ?res) WHERE {:x ?p ?o}") '((#[NMA 1 (3) (2.5 -1.55 4.5)]))) ;TODO: eps-comparison on D and C NMA
	    ((sparql "SELECT (AVG(?o) AS ?res) WHERE {:y ?p ?o}") '((1.75))) 
;	    ((sparql "SELECT (MIN(?o) AS ?res) WHERE {:x ?p ?o}") '((#[NMA 1 (3) (1 -5.1 3)]))) ;TODO: eps-comparison
	    ((sparql "SELECT (MIN(?o) AS ?res) WHERE {:y ?p ?o}") '((1)))
	    ((sparql "SELECT (MAX(?o) AS ?res) WHERE {:x ?p ?o}") '((#[NMA 1 (3) (4 2 6)])))
	    ((sparql "SELECT (MAX(?o) AS ?res) WHERE {:y ?p ?o}") '((2.5)))
	    )

;; Queries with binary MIN and MAX over arrays

(checkequal "queries with aggregation involving arrays"
	    ((sparql "LOAD('data/agg/array-agg.ttl',true)") nil)
	    ((sparql "PREFIX : <http://example.org/>;") nil)
	    ((sparql "SELECT (min2(?o1,?o2) AS ?res) WHERE {:x :p1 ?o1 ; :p2 ?o2}") '((#[NMA 1 (3) (1 -5.1 3)])))
	    ((sparql "SELECT (max2(?o1,?o2) AS ?res) WHERE {:x :p1 ?o1 ; :p2 ?o2}") '((#[NMA 1 (3) (4 2 6)])))
	    ((sparql "SELECT (min2(?o1,?o2) AS ?res) WHERE {:y :p1 ?o1 ; :p2 ?o2}") '((1)))
	    ((sparql "SELECT (max2(?o1,?o2) AS ?res) WHERE {:y :p1 ?o1 ; :p2 ?o2}") '((2.5)))
	    )

	    
(osql "< 'udf-queries.osql';")

(checkequal "queries with UDFs"
	    ((sparql "LOAD('data/udfs/1.ttl',true)") nil)
	    ((functiontype (sparql amos_udf_d1)) "foreign")
	    ((sorttuples (sparql amos_udf_q1)) (sorttuples '((1 2 3)
							     (3.14 2.72 5.86))))
	    ((functiontype (sparql amos_udf_d2)) "foreign")
	    ((sparql amos_udf_q2) '((10.5408)))
	    )

;; Data-free queries

(checkequal "data-free queries"
	    ((sparql "SELECT (true || true && false  as ?res) {}") '((TRUE))) ; AND/OR precedence
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 IN (1, 2, 3) ) }") '((TRUE))) ; IN usage
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 IN () ) }") nil)
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 IN (<http://example/iri>, 'str', 2.0) ) }") '((TRUE)))
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 NOT IN (1, 2, 3) ) }") nil) ; NOT IN usage
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 NOT IN () ) }") '((TRUE)))
	    ((sparql "SELECT (true AS ?res) WHERE { FILTER ( 2 NOT IN (<http://example/iri>, 'str', 2.0) ) }") nil)
	    ((sparql "SELECT (langMatches('de-DE', 'de-*-DE') AS ?res) {}") '((TRUE))) ; langMatches
	    ((sparql "SELECT (langMatches('de-de', 'de-*-DE') AS ?res) {}") '((TRUE)))
	    ((sparql "SELECT (langMatches('de-Latn-DE', 'de-*-DE') AS ?res) {}") '((TRUE)))
	    ((sparql "SELECT (langMatches('de-DE-x-goethe', 'de-*-DE') AS ?res) {}") '((TRUE)))
	    ((sparql "SELECT (langMatches('de-Latn-DE-1996', 'de-*-DE') AS ?res) {}") '((TRUE)))
	    ((sparql "SELECT (langMatches('de', 'de-*-DE') AS ?res) {}") nil)
	    ((sparql "SELECT (langMatches('de-x-DE', 'de-*-DE') AS ?res) {}") nil)
	    ((sparql "SELECT (langMatches('de-Deva', 'de-*-DE') AS ?res) {}") nil)
	    )

;; Blank node isolation queries

(defparameter biq1 "
PREFIX : <http://example.org/>
SELECT ?p ?q
WHERE { ?s ?p :y .
        OPTIONAL { ?s ?q :x } }
")

(checkequal "queries to test isolation of blank nodes"
	    ((sparql "LOAD('data/turtle/blanks12.ttl',true)") nil)
	    ((sparql "LOAD('data/turtle/blanks34.ttl')") nil)
	    ((sorttuples (sparql biq1)) (sorttuples '((#[URI "http://example.org/p3"] nil) 
						      (#[URI "http://example.org/p2"] nil))))
	    )

;; Boolean value queries

(checkequal "reader of boolean values"
	    ((sparql "LOAD('data/booleans.ttl',true)") nil)
	    ((sorttuples (sparql "SELECT ?o { ?s ?p ?o }")) (sorttuples '((TRUE) 
									  (FALSE) 
									  (TRUE) 
									  (FALSE))))
	    )

;; Queries where (uni)directionality of EQ-filter makes a difference 

(osql "< 'filter-eq-queries.osql';")

(checkequal "queries with '=' filter"
	    ((sparql "LOAD('data/filter-eq.ttl',true)") nil)
	    ((sorttuples (sparql amos_Q2)) (sorttuples '((#[URI "http://example.org/x1"] #[USTR "y1"] NIL) 
							 (#[URI "http://example.org/x2"] #[USTR "y2"] NIL) 
							 (#[URI "http://example.org/x3"] NIL NIL) 
							 (#[URI "http://example.org/x4"] NIL NIL))))
	    ((sparql "LOAD('data/bind.ttl',true)") nil)
	    ((sparql amos_BQ1a) '((#[URI "http://example.org/x1"] 1 1 1)))
	    )

;; Queries with second-order functions

(defparameter f-decl "
PREFIX : <http://example.org/>
DEFINE FUNCTION f(?x) AS
SELECT ?y
WHERE { [] :x ?x ;
           :y ?y }
")

(defparameter g-decl "
PREFIX : <http://example.org/>
DEFINE FUNCTION g(?x ?y) AS
SELECT (f(?x) * ?y AS ?res)
")

(checkequal "queries with second-order functions"
	    ((sparql "LOAD('data/argmax.ttl',true)") nil)
	    ((functiontype (sparql f-decl)) "derived")
	    ((sorttuples (sparql "SELECT ?x (f(?x) AS ?y)")) (sorttuples '((1 1) (2 3) (3 2.5))))
	    ((sparql "ARGMAX(f)") '((2)))
	    ((sparql "SELECT (ARGMAX(f) - ARGMIN(f) AS ?res)") '((1)))
	    ((functiontype (sparql g-decl)) "derived")
	    ((sorttuples (sparql "SELECT ?a (g(?a,ARGMIN(f)-2) AS ?res)")) (sorttuples '((1 -1) (2 -3) (3 -2.5))))
	    ((sparql "ARGMAX(g(*,ARGMIN(f)-2))") '((1))) ; relies on variable name hiding in Amos subqueries 
	    )


; TOP-LEVEL-AGGREGATE FUNCTIONS to 2ND ORDER FUNCTIONS

; 1. SINGLE SELECT, SINGLE AGG

(defparameter q1 "
PREFIX : <http://example.com/data/#>
SELECT (sum(?x) AS ?res)
 WHERE { ?a :p ?x }
")

(defparameter f1 "
PREFIX : <http://example.com/data/#>
DEFINE FUNCTION f1(?a) AS
SELECT (sum(?x) AS ?res)
 WHERE { ?a :p ?x }
")

; SINGLE SELECT EXPR, SINGLE AGG

(defparameter q2 "
PREFIX : <http://example.com/data/#>
SELECT (1/sum(?x) AS ?res)
 WHERE { ?a :p ?x }
")

(defparameter f2 "
PREFIX : <http://example.com/data/#>
DEFINE FUNCTION f2(?a) AS
SELECT (1/sum(?x) AS ?res)
 WHERE { ?a :p ?x }
")
	    
; 3. SINGLE SELECT EXPR, MULTIPLE AGG

(defparameter q3 "
PREFIX : <http://example.com/data/#>
SELECT (max(?x) - min(?x) AS ?range)
 WHERE { ?a :p ?x }
")

(defparameter f3 "
PREFIX : <http://example.com/data/#>
DEFINE FUNCTION f3(?a) AS
SELECT (max(?x) - min(?x) AS ?range)
 WHERE { ?a :p ?x }
")

(checkequal "queries involving user aggregate functions"
	    ((sparql "LOAD('data/sparql11/11.5x.ttl',true)") nil)
	    ((sparql q1) '((1029.0)))
	    ((functiontype (sparql f1)) "derived")
	    ((sparql "f1(<http://example.com/data/#y>)") '((1008.0)))
	    ((sparql "ARGMAX(f1)") '((#[URI "http://example.com/data/#y"])))
	    ((roundto (caar (sparql q2)) 5) 0.00097)
	    ((functiontype (sparql f2)) "derived")
	    ((sparql "f2(<http://example.com/data/#x>)") '((0.1)))
	    ((sparql "ARGMAX(f2)") '((#[URI "http://example.com/data/#x"])))
	    ((sparql q3) '((999)))
	    ((functiontype (sparql f3)) "derived")
	    ((sparql "f3(<http://example.com/data/#z>)") '((4.0)))
	    ((sparql "ARGMAX(f3)") '((#[URI "http://example.com/data/#y"]))))

(osql "< '../osql/archive_triples.osql';")

(osql "< 'archive.osql';")

(checkequal "archival queries from A-SPARQL"
	    ((sparql "LOAD('data/archive/data.nt',true)") nil)
	    ((sparql amos_archiveq) nil)
	    ((sorttuples (osql "turtle('q1.nt');")) (sorttuples (osql "turtle('data/archive/q1.nt');")))
	    ((delete-file "q1.nt") "q1.nt"))
	    
	     
