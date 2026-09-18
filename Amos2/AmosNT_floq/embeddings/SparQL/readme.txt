		    How to install and run SparQL

Make sure 'AmosNT\wrappers\CRDF' has been updated. Follow installation
desscriptions in AmosNT/wrappers/CRDF/readme.txt.

Source was compiled with redland-1.0.3 on 21/07/2006
				
1. Compile C code with
    compile.cmd

2.	In case you want to run regression test, official test
		cases should be downloaded from 
		http://www.w3.org/2001/sw/DataAccess/tests/data.zip or
		http://www.w3.org/2001/sw/DataAccess/tests/data.tar.gz
		Then, unzip 'data' directory into 
		'AmosNT\embeddings\SparQL\regress'
				
3. Generate Amos II database image for CRDFAmos by calling
    mkdmp.cmd

4. Test RDFAmos by calling
    "test.cmd" for caching RDF source
    "test_no_cache.cmd" for not caching RDF source

5. Run SparQL by calling
    SparQL.cmd

You can input SparQL query with
   sparql_from_file(RDF_source,cached,file_of_SPARQL);
   sparql(RDF_source,cached,SPARQL_query);

for example
	/*Not caching RDF source*/
  sparql_from_file("./regress/data/examples/ex2-1a.n3",0,"./regress/data/examples/ex2-1a.rq");
  
  /*Caching RDF source*/
  sparql("./regress/data/examples/ex2-1a.n3",1,
  		"SELECT ?title WHERE{ <http://example.org/book/book1> <http://purl.org/dc/elements/1.1/title> ?title }");

