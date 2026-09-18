;;; Directory for DUMP files is defined in settings.osql
;;; RDFStore database name is defnied in ../settings.osql
;;; That database should exist (and initialized with ../setup.cmd), 
;;; WAMP should be running
;;; 
;;; This script to be executed under ..\run

(load "dumper.lsp")

(osql
"
csvdump_start(20, 1); /* Initialize with chunk size */

csvdump_store_triple(turtle(getenv('AMOS_HOME')+'/SQoND/test/data/turtle/alltypes.ttl')); /* Dump a Turtle file */

csvdump_store_triple(URI('http://example.org/ns#x12'),URI('http://example.org/ns#p'), /* Dump a triple with long literal */
                     USTR('A long enough string to exceed the limit of 32 bytes used to store \"normal\" literals','En-Us'));

csvdump_save();

rdf:bulkload(true); /* Load the CSV files into the current RDF store */
")

(checkequal "consistency of dump-loaded dataset..."
	    ((sorttuples (osql "SDEF();")) 
	     (sorttuples '((#[URI "http://example.org/ns#x8"] #[URI "http://example.org/ns#p"] #[URI "http://example.org/ns#katze"])
			   (#[URI "http://example.org/ns#x9"] #[URI "http://example.org/ns#p"] #[URI "_:cattus"])
			   (#[URI "http://example.org/ns#x10"] #[URI "http://example.org/ns#p"] #[URI "_:b0"])
			   (#[URI "http://example.org/ns#x1"] #[URI "http://example.org/ns#p"] 5)
			   (#[URI "http://example.org/ns#x2"] #[URI "http://example.org/ns#p"] 3.14)
			   (#[URI "http://example.org/ns#x3"] #[URI "http://example.org/ns#p"] TRUE)
			   (#[URI "http://example.org/ns#x4"] #[URI "http://example.org/ns#p"] #[T 1109545200 0])
			   (#[URI "http://example.org/ns#x5"] #[URI "http://example.org/ns#p"] #[USTR "cat"])
			   (#[URI "http://example.org/ns#x6"] #[URI "http://example.org/ns#p"] #[USTR "katt" "sv"])
			   (#[URI "http://example.org/ns#x11"] #[URI "http://example.org/ns#p"] #[TYPEDRDF "chat" "http://example.org/datatype#specialDatatype"])
			   (#[URI "http://example.org/ns#x12"] #[URI "http://example.org/ns#p"] #[USTR "A long enough string to exceed the limit of 32 bytes used to store \"normal\" literals" "En-Us"])
			   (#[URI "http://example.org/ns#x7"] #[URI "http://example.org/ns#p"] #[NMA 0 (2 3) ((1 2 3) (4 5 6))])))
	     ))



