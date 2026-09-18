(checkequal "SparQL to AmosQL translation"
;; different kinds of literals
((sparql-to-amosql "SELECT ?x FROM <file://c:/1.rdf> WHERE { ?x <http://a.com/f> 2 . FILTER (?x != 'anybody') }")
"select x
	from RDFResource x
	where ntriples('c:/1.rdf')=<x, rdfr_iri('http://a.com/f'), rdfr_number(2)>
	and rdfr_neq(x,rdfr_string('anybody',''));")
;; arithmeics
((sparql-to-amosql "SELECT ?x FROM <file://c:/1.rdf> WHERE { ?x <http://a.com/f> 2 . FILTER (-?x != 2+3*5.1) }")
"select x
	from RDFResource x
	where ntriples('c:/1.rdf')=<x, rdfr_iri('http://a.com/f'), rdfr_number(2)>
	and (- rdfr_data(x)) != (2 + 3 * 5.1);")
;; combining logics and arithmetics
((sparql-to-amosql "SELECT ?x FROM <file://c:/1.rdf> WHERE { ?x <http://a.com/f> 2 . FILTER (!(-?x = 2+3*5.1)) }")
"select x
	from RDFResource x
	where ntriples('c:/1.rdf')=<x, rdfr_iri('http://a.com/f'), rdfr_number(2)>
	and (- rdfr_data(x)) != (2 + 3 * 5.1);")
;; aggregation
((sparql-to-amosql "SELECT ?x SUM(?z+2) FROM <file://c:/1.rdf> WHERE { ?x <http://a.com/f> 2 . FILTER (-?x != (2+?z)*5.1) }")
"groupby((select {x}, rdfr_number(rdfr_data(z) + 2)
	from RDFResource z, RDFResource x
	where ntriples('c:/1.rdf')=<x, rdfr_iri('http://a.com/f'), rdfr_number(2)>
	and (- rdfr_data(x)) != ((2 + rdfr_data(z)) * 5.1)),#'rdfr_sum');"))