	How to run the Topic Map to RDF tripple mapper and query the
	          created views by SPARQL, RDQL and SQL.
	-----------------------------------------------------------------------

1. Compile by
   compile.cmd	

2. Then run
   mkdmp.cmd

3. Start by 
   tamos.cmd
	
4. Loading Topic Maps in term of RDF triples by Semantic Web query languages
   
   4.1. Small XTM file by:

	importTopicMap("hamlet","http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm");

   4.2. A 10,5 MB XTM file	 

	importTopicMap("mondial","http://user.it.uu.se/~udbl/software/swatm/mondial.xtm");

   4.3. A 19 MB XTM file

	importTopicMap("unsp","11unspsc.xtm");
	

