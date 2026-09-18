3;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-2011, Andrej Andrejev, UDBL
;;;
;;; Description: Test of views defined in .sparql file(s)
;;; =============================================================

; current directory on localhost is used as base URI for filenames in LOAD and SOURCE

(sparql "LOAD('data/udfs/1.ttl',true)") ;load data

(sparql "SOURCE('sumxy.sparql')") ;define view

(checkequal "sumxy.sparql view(s)"
	    ((sorttuples (sparql "
PREFIX  : <http://example.org/> 
SELECT (sumxy(?s) as ?sum)
WHERE { ?s :x ?x }
"
				 )) (sorttuples '((3) 
						  (5.86))))
	    )
	    
