=======================================================================
 How to install and test SWARD exporting RDF views, 
 Universal Property Views, over back-end relational databases.
=======================================================================

(Administrative steps)	
1. Download JDK version 1.5.0_11 or higher
   (regression tested with version 1.5.0_11 and 1.6.0_01).
		
   Source:
   http://java.sun.com/javase/downloads/index.jsp
   
2. Create example database

 2.1 Using InterBase/FireBird

  2.1.1 Download FireBird/InterBase relational database

        Source:
        http://user.it.uu.se/~udbl/software/Firebird-1.0.0.796-Win32.exe

        Installation: Installation shield

  2.1.2 Download InterClient JDBC driver

        Source:
        http://user.it.uu.se/~udbl/software/interclient_201_Win32.zip

        Purpose: JDBC driver manager for FireBird/Interbase. 
        Installation: Installation shield.

        After the installation of InterClient do

  2.1.3 Make sure that you have manually entered the following line into
        your services file in c:\winnt\system32\drivers\etc\services:

        interserver      3060/tcp             # InterBase InterServer

  2.1.4 Run isconfig.exe to start the local InterClient server.

  2.1.5 Add 'interclient.jar' to your CLASSPATH. It is, e.g., located in
           c:\Program Files\FireBird\InterClient\interclient.jar.

  2.1.6 Create and set environment variable INTERBASE_BIN to point to 
           the directory where Interbase/FireBird keeps the the binaries, 
           e.g. c:\Program Files\FireBird\bin

  2.1.7 Set environment variables:

        setup.cmd

  2.1.8 Create and populate the 'EGOVERNMENT' database: 

        regress/egovdb.cmd
	
 2.2 Using MSSQL Server 2005

  2.2.1 Install MSSQL 2005 Server
  
  2.2.2 Download MSSQL JDBC Driver
					
        Source:
        http://user.it.uu.se/~udbl/software/SQLServer_JDBC.zip
	
        Add 'mssqlserver.jar', 'msbase.jar' and 'msutil.jar' to your CLASSPATH.

  2.2.3 Create new database 'EGOVERNMENT'. Add new login (e.g. 'egovmgr') for 
        'EGOVERNMENT' with password (e.g. '12345').  
        Create new user (e.g. 'egovmgr') for login 'egovmgr'. 
        Set 'Database role' of user 'egovmgr' in 'EGOVERNMENT' to 'db_owner'.
        Create new schema (e.g. 'EGOVSCHEMA'). Set 'Default schema' of 'egovmgr' in 
        'EGOVERNMENT' to 'EGOVSCHEMA'. 
        Input sql script 'egov.sql' as login 'egovmgr' to populate 'EGOVERNMENT'.

3. Set environment variables (if not already done):

   setup.cmd

4. Compile source code (not needed for downloadable SWARD distribution)
    
   compile.cmd

5. Build SWARD (not needed for downloadable SWARD distribution)

   mkdmp.cmd

6. Run SWARD:

   sward.cmd

7. Set up a UPV over the small relational database 'EGOVERNMENT'.
    		
 7.1 Define a data source to access the relational database.
     A data source simply stores all the information needed 
     to access a particular relational database.
        
     Using InterBase/FireBird: 

     defineDS("EGOVDS",
                 "jdbc:interbase://localhost/" + getenv("SWARD_ROOT") + 
                 "/bin/EGOVERNMENT.gdb",
                 "interbase.interclient.Driver",
                 "",
                 "",
                 "SYSDBA",
                 "masterkey");
							
     Using MSSQL Server 2005:
	
     defineDS("EGOVDS",
                 "jdbc:microsoft:sqlserver://localhost;DatabaseName=EGOVERNMENT",
                 "com.microsoft.jdbc.sqlserver.SQLServerDriver",
                 "EGOVERNMENT",
                 "EGOVSCHEMA",
                 "egovmgr",
                 "12345");

 7.2 Define a UPV and associate it with the UPV data source defined above.
     Every UPV must be associated with a UPV data source.
     Each UPV data source can be associated with several UPVs.

     Using InterBase/FireBird: 

     defineUPV("EGOVDS","EGov","http://udbl.it.uu.se/upv/eGov/");

     Using MSSQL Server 2005:

     defineUPV("EGOVDS","EGov","http://udbl.it.uu.se/upv/eGov/");

 5.5 Initialize predefined UPV data source:

     DSConnect("EGov");		

 5.3 Add mappings between viewed columns and mapped RDFS properties. 
     E.g. column 'LID' in table 'LIFEEVENT' is mapped to the property 
     'http://purl.org/dc/elements/1.1/Identifier' in the UPV 'eGov':

     assignPropID("LIFEEVENT","LID","EGov",
       "http://udbl.it.uu.se/schemas/eGovern#LifeEventID");
     assignPropID("LIFEEVENT","NAME","EGov",
       "http://purl.org/dc/elements/1.1/title");
     assignPropID("LIFEEVENT","DESCR","EGov",
       "http://purl.org/dc/elements/1.1/description");

     assignPropID("FORM","FID","EGov",
      "http://udbl.it.uu.se/schemas/eGovern#FormID");
     assignPropID("FORM","URL","EGov",
      "http://udbl.it.uu.se/schemas/eGovern#URL");
     assignPropID("FORM","CREATOR","EGov",
      "http://www.egov_project.org/GovMLSchema#Creator");
     assignPropID("FORM","NOFF","EGov",
      "http://udbl.it.uu.se/schemas/eGovern#NumberOfFields");
     assignPropID("FORM","LIFEEVENT","EGov",
      "http://udbl.it.uu.se/schemas/eGovern#LifeEventID");

     assignCRID("FORM","LIFEEVENT","LIFEEVENT","EGov","http://udbl.it.uu.se/schemas/eGovern#Concern");

     assignClassID("FORM","EGov","http://udbl.it.uu.se/schemas/eGovern#Form"); 
     assignClassID("LIFEEVENT","EGov",
                "http://udbl.it.uu.se/schemas/eGovern#LifeEvent");


 5.4 Add mappings between exported tables and mapped RDFS classes 
     e.g. table 'LIFEEVENT' is mapped to the class 
     'http://udbl.it.uu.se/schemas/eGovern#LifeEvent' in the UPV 'eGov':

     assignClassID("FORM","EGov","http://udbl.it.uu.se/schemas/eGovern#Form"); 
     assignClassID("LIFEEVENT","EGov",
                "http://udbl.it.uu.se/schemas/eGovern#LifeEvent");
		
 5.6 Generate a UPV over 'EGOVERN' by calling the function ViewRDB with 
     the name of the UPV as argument: 

     ViewRDB("EGov");

(End of administrative steps)

 5.7 We give exemples of three different types of queries:

     1.	Schema queries accessing the relational database schema:

         Give me all properties, except for the property
          http://purl.org/dc/elements/1.1/Identifier, of a life event.

     2. Content queries accessing the relational database content:

         Give me the names and descriptions of all life events.
         Give me all life event services.
         

     3. Hybrid queries joining schema and content data: 

         Give me all life-event forms about moving and their properties 
         except for the properties http://udbl.it.uu.se/schemas/eGovern#FormID
         and http://udbl.it.uu.se/schemas/eGovern#LifeEventID and
          http://udbl.it.uu.se/schemas/eGovern#Concern.     

     In SparQL:
     ==========
     set :sparql_schema_1 = 
      "SELECT ?lifeeventprop
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?lifeeventprop <http://www.w3.org/2000/01/rdf-schema#domain> 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent> .
       FILTER (?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>) .}";

     set :sparql_content_1 = 
      "SELECT ?val1 ?val2
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?s1 <http://purl.org/dc/elements/1.1/title> ?val1 .
              ?s1 <http://purl.org/dc/elements/1.1/description> ?val2 .}";

     set :sparql_content_2 = 
      "SELECT ?service
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?service <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://udbl.it.uu.se/schemas/eGovern#Service> .}";

     set :sparql_hybrid_1 = 
      "SELECT ?s2 ?p ?val3
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE {?s1 <http://purl.org/dc/elements/1.1/description> ?val1 .
              ?s2 <http://udbl.it.uu.se/schemas/eGovern#Concern> ?s1 .
              ?p <http://www.w3.org/2000/01/rdf-schema#domain> 
                <http://udbl.it.uu.se/schemas/eGovern#Form> .
             ?s2 ?p ?val3 .
       FILTER (?p != <http://udbl.it.uu.se/schemas/eGovern#FormID>) .
       FILTER (?p != <http://udbl.it.uu.se/schemas/eGovern#LifeEventID>) .
       FILTER (?p != <http://udbl.it.uu.se/schemas/eGovern#Concern>) .
       FILTER REGEX (?val1, '.*move.*') .}";

     In RDQL:
     ========
     set :rdql_schema_1 = 
      "SELECT ?lifeeventprop
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE (?lifeeventprop, <http://www.w3.org/2000/01/rdf-schema#domain>, 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent>)
       AND ?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>";

     set :rdql_content_1 = 
      "SELECT ?val1, ?val2
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE (?s1,<http://purl.org/dc/elements/1.1/title>,?val1)
             (?s1,<http://purl.org/dc/elements/1.1/description>,?val2)";

     set :rdql_content_2 = 
      "SELECT ?service
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE (?service,<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>,<http://udbl.it.uu.se/schemas/eGovern#Service>)";

     set :rdql_hybrid_1 = 
      "SELECT ?s2, ?p, ?val3
       FROM <http://udbl.it.uu.se/upv/eGov/>
       WHERE (?s1,<http://purl.org/dc/elements/1.1/description>,?val1),
             (?s2,<http://udbl.it.uu.se/schemas/eGovern#Concern>,?s1),
             (?p,<http://www.w3.org/2000/01/rdf-schema#domain>,
              <http://udbl.it.uu.se/schemas/eGovern#Form>),
             (?s2,?p,?val3)
       AND ?p != <http://udbl.it.uu.se/schemas/eGovern#FormID>
       AND ?p != <http://udbl.it.uu.se/schemas/eGovern#LifeEventID>
       AND ?p != <http://udbl.it.uu.se/schemas/eGovern#Concern> 
       AND ?val1 =~ '.*move.*'";

     In SQL:
     =======
     set :sql_schema_1 = 
      "SELECT t1.s
       FROM EGov t1
       WHERE t1.p = 'http://www.w3.org/2000/01/rdf-schema#domain' and
             t1.val = 'http://udbl.it.uu.se/schemas/eGovern#LifeEvent' and
             t1.s <> 'http://purl.org/dc/elements/1.1/identifier'";

     set :sql_content_1 =	
      "SELECT t1.val, t2.val
       FROM EGov AS t1, 
            EGov AS t2
       WHERE t1.p = 'http://purl.org/dc/elements/1.1/title' AND
             t2.p = 'http://purl.org/dc/elements/1.1/description' AND
             t1.s = t2.s";

    set :sql_content_2 =	
     "SELECT t1.s
      FROM EGov AS t1
      WHERE t1.p = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' AND
            t1.val = 'http://udbl.it.uu.se/schemas/eGovern#Service'";

     set :sql_hybrid_1 = 
      "SELECT t5.s, t5.p, t5.val
       FROM EGov AS t1,
            EGov AS t3,
            EGov AS t4,
            EGov AS t5
       WHERE t1.p = 'http://purl.org/dc/elements/1.1/description' AND
             t1.s = t3.val AND
             t3.p = 'http://udbl.it.uu.se/schemas/eGovern#Concern' AND
             t4.p = 'http://www.w3.org/2000/01/rdf-schema#domain' AND
             t4.val = 'http://udbl.it.uu.se/schemas/eGovern#Form' AND
             t5.p = t4.s AND
             t5.s = t3.s AND
             t5.p <> 'http://udbl.it.uu.se/schemas/eGovern#FormID' AND
             t5.p <> 'http://udbl.it.uu.se/schemas/eGovern#LifeEventID' AND
             t5.p <> 'http://udbl.it.uu.se/schemas/eGovern#Concern' AND
             t1.val LIKE '%move%'";

 5.8 Execute the SparQL/RDQL/SQL demo queries. E.g. the first SparQL 
     schema query is executed as: 
 
     sparql(:sparql_schema_1);

     The other queries is executed analogously. 

     The expected result is:

     Schema query 1:
     {"http://purl.org/dc/elements/1.1/description"}
     {"http://purl.org/dc/elements/1.1/title"}

     Content query 1:
     {"Moving House","A citizen intends to move from one EU country to another."}

     Content query 2:
     {"http://udbl.it.uu.se/schemas/eGovern#Service/movinghouse@0"}

     Hybrid query 1:
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_0","http://udbl.it.uu.se/schemas/eGovern#NumberOfFields","25"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_1","http://udbl.it.uu.se/schemas/eGovern#NumberOfFields","129"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_2","http://udbl.it.uu.se/schemas/eGovern#NumberOfFields","59"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_0","http://www.egov_project.org/GovMLSchema#Creator","National Tax Board of Sweden"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_1","http://www.egov_project.org/GovMLSchema#Creator","National Tax Board of Sweden"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_2","http://www.egov_project.org/GovMLSchema#Creator","http://www.workpermit.com"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_0","http://udbl.it.uu.se/schemas/eGovern#URL","http://www.skatteverket.se/etjanster/skrivutpersonbevis.4.18e1b10334ebe8bc80001262.html"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_1","http://udbl.it.uu.se/schemas/eGovern#URL","http://www.skatteverket.se/download/18.3dfca4f410f4fc63c86800010627/7665B5.pdf"}
     {"http://udbl.it.uu.se/schemas/eGovern#FormID/fid_2","http://udbl.it.uu.se/schemas/eGovern#URL","http://www.workpermit.com/uk/employer_form.htm"}

 5.9 Exit SWARD:

    quit;











