=======================================================================
                   How to install and run "sard"
=======================================================================

In order to be able to install and run SARD you need:
   - Amos II, available to download at http://user.it.uu.se/~udbl/amos/; 
     Unzip it, for instance in a direcory, called amos2, add amos2/bin directory 
     to your PATH and then follow the instructions in AmosII's in order to install it. 
   - JDK version 1.5.0_11 or higher
   - JDBC driver(s) for the RDBMS you are going to use as a back-end; Add 
     the correpondent jar file(s) to your Classpath
  
1) Install sard by running 
   (In order to run successful this command you need to have the directory of
    javaamos.jar as a part of your path):

   install.cmd

2) As an example, run SARD using MySQL as a back-end RDBMS following the steps:

(!!! SARD works with other RDBMS as well. !!!)
     
   2.1)  Create user 'regress' and 'EGOVERNMENT' database in MySQL by using the start_mysql.sql file

      (the file 'start_mysql.sql' might be located inside the regress folder)

	
   2.2)	Populate the 'EGOVERNMENT' database in MySQL by running
	 (In order to run successfuly this command you need to have the jar file of the
	 MySQL JDBC driver as a part of your classpath):

   egovdb.cmd

   (the file 'egovdb.cmd' might be located inside the regress folder)

   2.3)  Start SARD system by:

   sard.cmd


   2.4) Define an RDF view over the 'EGOVERNMENT' database by running the commands:


defineDS("EGOVDS",
          "jdbc:mysql://localhost:3306/egovernment",
          "com.mysql.jdbc.Driver",
          "egovernment",
          "",
          "regress",
          "regress");


defineUPV("EGOVDS","EGov","http://udbl.it.uu.se/upv/eGov/");

DSConnect("EGov");

wrapRDB(jdbcOfDS("EGOVDS"),"egovernment","egovernment","");

assignIDs("EGov","egovernment","");

ViewRDB("EGov");

/*!!The folowing commands imporove a lot the query optimization!!!*/
/* Run them ad they are*/


parteval('pmap');
parteval('cmap');
parteval('rmap');
parteval('rowid');
parteval('like');
parteval('rmap');
parteval('rmmMap');
parteval('typeMap');
parteval('xsd_Shortmap');
parteval("valueid");
parteval("OBJECT.OBJECT.!=->BOOLEAN");
parteval("CHARSTRING.AREG->CHARSTRING");
lisp;
(setq _rewrite_row_and_like_ T);;rewrite SARD
(setq _el-corcl_ t)
(setq _elcon_ifnounif_ t);;rewrite for { * * ?s. ?s ?p ?o }
(setq _rewrite_row_and_like_ t);;rewrite when FILTER on subject/object
(setq _unif_ t) 
(setq _gct_ t) 
:osql

make_def("EGov");


  2.5) Now you can define Sparql queries against the definied view and run them. 
       Use the examples below!


   set :sparql_schema_1 = 
      "SELECT ?lifeeventprop
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?lifeeventprop <http://www.w3.org/2000/01/rdf-schema#domain> 
		<http://user.it.uu.se/~udbl/sard/egovernment#lifeevent> .
       FILTER (?lifeeventprop != <http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LIDcmap();
>) .}";

Run this query by;

sparql(:sparql_schema_1);


The result should be:
-----------------------
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/NAME"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LAW"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/COUNTRY"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LANG"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/DESCR"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LID"}


     set :sparql_content_1 = 
      "SELECT ?val1 ?val2
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?s1 <http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/NAME> ?val1 .
              ?s1 <http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/DESCR> ?val2 .}";


sparql(:sparql_content_1);

The result:
---------------------
{"Moving House","A citizen intends to move from one EU country to another."}
{"Job","A citizen from one EU country intends to look for a job in another EU country ."}



An example of unboubd-property query:

 set :sparql_content_2 = 
      "SELECT ?s1 ?p1 ?val1 
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?s1 <http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/NAME> 'Moving House' .
              ?s1 ?p1 ?val1 .}";

sparql(:sparql_content_2);

The result:
-------------

{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LAW","sql null"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/DESCR","A citizen intends to move from one EU country to another."}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LANG","EN"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/country","italy"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/NAME","Moving House"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/LID","movinghouse"}
{"http://user.it.uu.se/~udbl/sard/egovernment#lifeevent/_movinghouse","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://user.it.uu.se/~udbl/sard/egovernment#lifeevent"}
    

To archive the relational content as RDF (store in NT file), retrieved by the query :sparql_content2, run
the following commands:


    eval("create function q02i()-> <Charstring,Charstring,Charstring>
	as " + parse_sparql(:sparql_content_2));

	create function q02()-> (Charstring,Charstring,Charstring)
	as select remove_null(q02i());


The following command stores the content in the file 'data2.nt' and the relational schema concerning the retrieved content
in the file 'schema2.nt'.

   archive_content(#'q02',"data2.nt","schema2.nt");
     
