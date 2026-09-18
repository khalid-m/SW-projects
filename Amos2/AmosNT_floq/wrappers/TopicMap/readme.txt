	How to run the Topic Map to RDF tripple mapper and query the
	          created views by SPARQL, RDQL and SQL.
	-----------------------------------------------------------------------

1. Compile by
   compile.cmd	

2. Then run
   mkdmp.cmd

3. Start by 
   tamos.cmd
	
4. Querying Topic Maps in term of RDF triples by Semantic Web query languages
   
   4.1. First create the RDF view over a Topic Map data stored in XTM file by:

	importTopicMap("http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm");

!!!!	The below provided examples of queries use the XTM file having URL:
	 http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm.	
	 

!!!!	 You can import other Topic Map data stored in XTM files, for instance:

	importTopicMap("http://user.it.uu.se/~udbl/software/swatm/plays.xtm");
	importTopicMap("http://user.it.uu.se/~udbl/software/swatm/opera.xtm");

!!!!	In the case if you make other imports than http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm 
	you have to write own queries.

Following this model it is possible to create many views over different Topic Map files (xtm files).
	   
   4.2. Examples of querying Topic Map views in terms of RDF by RDQL:

Important
----------
Querying the Topic Map views by RDQL has to be made so that in the FROM clause of the
query the URL of the xtm file must be written!!! 

The examples concern
http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm.

	4.2.1. Schema query 
	In order to run a SPARQL schema query it is not needed to write a source in the FROM clasue since the
	Topic Map schema is generic, i.e. independent on the Topic Map data.
	
	The provided example retrieves all the attributes of the entity type 'Topic' except 'idTopic' from the XTM file. 

	Query in SPARQL:
	set :sparql_schema = 
	"SELECT ?tp
	WHERE { ?tp <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>. 
	      ?tp  <http://www.w3.org/2000/01/rdf-schema#domain> <http://udbl2.it.uu.se/swatm#TOPIC>.
	      ?tp  <http://www.w3.org/2000/01/rdf-schema#range>  <http://www.w3.org/2000/01/rdf-schema#Literal>.
	FILTER  (?tp != <http://udbl2.it.uu.se/swatm#IDTOPIC>).} ";

      Run it by:
      sparql(:sparql_schema);

      The result:
     {"http://udbl2.it.uu.se/swatm#SUBJECTIDENTITY"}
     {"http://udbl2.it.uu.se/swatm#SUBJECTADDRESS"}

      Query in RDQL:
      set :rdql_schema = 
     "SELECT ?tp
      FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm>
      WHERE(?tp, <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>, <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>) 
	   (?tp, <http://www.w3.org/2000/01/rdf-schema#domain>, <http://udbl2.it.uu.se/swatm#TOPIC>)
	   (?tp, <http://www.w3.org/2000/01/rdf-schema#range>, <http://www.w3.org/2000/01/rdf-schema#Literal>)
      AND ?tp != <http://udbl2.it.uu.se/swatm#IDTOPIC>";

      rdql(:rdql_schema);

      The result:
     {"http://udbl2.it.uu.se/swatm#SUBJECTIDENTITY"}
     {"http://udbl2.it.uu.se/swatm#SUBJECTADDRESS"}

      4.2.2. Content query (it is necessary to import Topic Map data first)

      The example retrieves the resources, supplying information relevant to the Shakespear's play 'Hamlet, Prince of Denmark'.

      Query in SPARQL:
      set :sparql_content  = 
      "SELECT ?occurrence 
      FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm>
      WHERE{?tm0 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?tm1 .
	    ?tm1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Hamlet, Prince of Denmark'. 
	    ?tm0 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?tm2.
	    ?tm2 <http://udbl2.it.uu.se/swatm#REFERENCE> ?occurrence}";

      sparql(:sparql_content);

      The result;
      {"http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml"}
      {"http://www.enotes.com/hamlet"}

      The query in RDQL:
      set :rdql_content  = 
      "SELECT ?occurrence 
      FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm>
      WHERE (?tm0 , <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?tm1)
            (?tm1 , <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Hamlet, Prince of Denmark') 
	    (?tm0 , <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?tm2)
            (?tm2 , <http://udbl2.it.uu.se/swatm#REFERENCE>, ?occurrence)";

      rdql(:rdql_content);


      The result:
      {"http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml"}
      {"http://www.enotes.com/hamlet"}


      4.2.3. Hybrid query
      It retrieves the type of a resource, i.e. its RDFS class and an instance of it. 
      The information resource concerns Shakespeare's plays, which has to be relevant 
      to the play 'Hamlet, Prince of Denmark' and also to differ the following URI
      http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml. 
      
      Query in SPARQL:
      set :sparql_hybrid  = 
      "SELECT ?iofoc ?tm3
      FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm>
      WHERE {?tm0 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?tm1.
	     ?tm1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Hamlet, Prince of Denmark'. 
	     ?tm0 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?tm2.
             ?tm2 <http://udbl2.it.uu.se/swatm#REFERENCE> ?occurrence.
	     ?tm2 <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> ?iofoc.
	     <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> <http://www.w3.org/2000/01/rdf-schema#range> ?tm3.
      FILTER (?occurrence != <http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml>).}";

      sparql(:sparql_hybrid);

      The result:
      {"http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm#6","http://udbl2.it.uu.se/swatm#TOPIC"}

      Query in RDQL:
      set :rdql_hybrid  = 
      "SELECT ?iofoc, ?tm3
      FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm>
      WHERE (?tm0 , <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?tm1)
	    (?tm1 , <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Hamlet, Prince of Denmark') 
	    (?tm0 , <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?tm2)
            (?tm2 , <http://udbl2.it.uu.se/swatm#REFERENCE>, ?occurrence)
	    (?tm2 , <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE>, ?iofoc)
	    (<http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE>, <http://www.w3.org/2000/01/rdf-schema#range>,?tm3)
      AND ?occurrence  != <http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml>";

      rdql(:rdql_hybrid);

      The result:
     {"http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm#6","http://udbl2.it.uu.se/swatm#TOPIC"}


5.Examples of querying Topic Map views in term of RDF by SQL:

Important
----------
Querying the Topic Map views by SQL has to be made so that in the FROM clause of the
query the short name of the view must be written!!! The short name is assigned in the
importTopicMap command as a first argument. Look at the beginning of the instructions.  


The example concerns again the file http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm.

    5.1. Schema query

    set :sql_schema = 
    "SELECT t1.s
    FROM let t1, let t2
    WHERE t1.p = 'http://www.w3.org/2000/01/rdf-schema#domain' AND
	  t1.val= 'http://udbl2.it.uu.se/swatm#TOPIC' AND
	  t2.p = 'http://www.w3.org/2000/01/rdf-schema#range' AND
	  t2.val='http://www.w3.org/2000/01/rdf-schema#Literal' AND
	  t1.s=t2.s AND t1.s <> 'http://udbl2.it.uu.se/swatm#IDTOPIC';";

    sql(:sql_schema);

    The result:
   {"http://udbl2.it.uu.se/swatm#SUBJECTIDENTITY"}
   {"http://udbl2.it.uu.se/swatm#SUBJECTADDRESS"}

    5.2. Content query

    set :sql_content =
    "SELECT t1.val 
    FROM let t1, let t2, let t3, let t4
    WHERE t1.p='http://udbl2.it.uu.se/swatm#REFERENCE' AND t1.s=t2.val AND t2.p='http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC'
    AND t2.s=t3.s AND t3.val = t4.s AND t4.p='http://udbl2.it.uu.se/swatm#BASENAMESTRING' AND t4.val = 'Hamlet, Prince of Denmark';";

    sql(:sql_content);

    The result:
    {"http://www.enotes.com/hamlet"}
    {"http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml"}

    5.3. Hybrid query in SQL

    set :sql_hybrid =
    "SELECT t5.val, t6.val 
    FROM let t1, let t2, let t3, let t4, let t5, let t6
    WHERE t1.p='http://udbl2.it.uu.se/swatm#REFERENCE' AND t1.s=t2.val AND t2.p='http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC'
    AND t2.s=t3.s AND t3.val = t4.s AND t4.p='http://udbl2.it.uu.se/swatm#BASENAMESTRING' AND t4.val = 'Hamlet, Prince of Denmark'
    AND t5.s=t1.s AND t5.p='http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE' AND t6.s='http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE'
    AND t6.p='http://www.w3.org/2000/01/rdf-schema#range' AND t1.val <> 'http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml' ;";


    sql(:sql_hybrid);

    The result:
    {"http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm#6","http://udbl2.it.uu.se/swatm#TOPIC"}
