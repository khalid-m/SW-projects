		    How to install and run RDFAmos
		     wrapper of RDF and RDFSchema

1. Download Jena 2 from 
    http://jena.sourceforge.net/downloads.html

2. Set environment variable JENA_HOME to point to Jena 2 root
   directory, e.g.
    C:\Program\Jena-2.1

3. Generate Amos II database image for RDFAmos by calling
    mkdmp.cmd

4. Test RDFAmos by calling
    test.cmd

5. Run RDFAmos by callin
    RDFAmos.cmd

You can load RDF(S) documents with
   load_rdf_schema("uri");
for example
   load_rdf_schema("xxxx");

The wrapper translates RDF-Schema classes and properties into Amos II
types and functions prefixed with "RDF_". The loaded documents and
classes can be queried using AmosQL or browsed using Goovi.
