=============================== Client side ===============================
1. Make sure you have Java version 5 or later installed.

2. Download AXIS from http://ws.apache.org/axis/java/releases.html The
system is tested for AXIS version 1.4. Extract zip file to somewhere,
e.g. C:\Program\

3. Set environment variable AXIS_HOME to AXIS home directory, e.g. 
C:\Program\axis-1_4

4. Download the file mailapi.jar from http://user.it.uu.se/~udbl/software/mailapi.jar
   and copy it to your AXIS_HOME/lib directory.

5. Set up the classpath by
      setup_client

6. Compile the client demonstration program by
     compile_client

7. Run the client demonstration program by
      run_client

8. The demonstration program will asks you to select a wrapper.
   Choose one of:
      SWATM
      SWARD

9.  You will be asked to choose a query language among: RDQL, SPARQL or SQL.
    Choose one of them


10. The program wil finally asks you to enter a query in the upper chosen language. 

 10.1.For example, the following queries can be given to the SWATM wrapper:      

	RDQL
-------------------- 
     /*Example query 1*/
     /*Which is the default address data for a citizen, in english, and which are the URIs where it can be found?*/

SELECT ?bs1,?sa1 
FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
WHERE (?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
      (?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bs1)
      (?bnt1, <http://udbl2.it.uu.se/swatm#SCOPEBASENAME>, ?s1)
      (?s1, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')
      (?t1, <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS>, ?sa1)
      (?t1, <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC>, ?t2)
      (?t2, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt2)
      (?bnt2, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>,  'Default address data')


      /*Example query 2*/
      /*Give me the description names in english of all resources providing information relevant to the 'Language' topic*/

SELECT ?bns
FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
WHERE ( ?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
      ( ?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Language')
      ( ?t1, <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?ot1)
      ( ?ot1, <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE>, ?iot1)
      ( ?iot1, <http://udbl2.it.uu.se/swatm#IDTOPIC>, ?idt2)
      ( ?iot1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt2)
      ( ?bnt2, <http://udbl2.it.uu.se/swatm#SCOPEBASENAME>, ?t3)
      ( ?t3, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')	
      ( ?bnt2, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bns)     


     /*Example query 3*/
     /*What is the creation date of the previous pass of the citizen?*/ 

SELECT ?bns, ?rdat
FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
WHERE  (?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
       (?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Had previous passport')
       (?t1, <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?ot1)
       (?ot1, <http://udbl2.it.uu.se/swatm#DATA>, ?rdat) 	
       (?ot1, <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE>, ?iot1)
       (?iot1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt2)
       (?bnt2, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bns)
AND ?bns =~ '*date'  


	SPARQL
--------------------
    /*Example query 1*/
     /*Which is the default address data for a citizen, in english, and which are the URIs where it can be found?*/

SELECT DISTINCT ?bs1 ?sa1
	FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
	WHERE{ 	?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
    	?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
    	?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?s1.
    	?s1 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
    	?t1 <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS> ?sa1.
       	?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
    	?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
    	?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Default address data'.}
    

      /*Example query 2*/
      /*Give me the description names in english of all resources providing information relevant to the 'Language' topic*/

SELECT DISTINCT ?bns
FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
       ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Language'.
       ?t1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?ot1.
       ?ot1 <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> ?iot1.
       ?iot1 <http://udbl2.it.uu.se/swatm#IDTOPIC> ?idt2.
       ?iot1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
       ?bnt2 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t3.
       ?t3 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.	
       ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bns. }     
   
  
      /*Example query 3*/
      /*What is the creation date of the previous pass of the citizen?*/    

SELECT DISTINCT ?bns ?rdat
FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
       ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Had previous passport'.
       ?t1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?ot1.
       ?ot1 <http://udbl2.it.uu.se/swatm#DATA> ?rdat. 	
       ?ot1 <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> ?iot1.
       ?iot1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
       ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bns. 
FILTER REGEX (?bns, '*date').}


   10.2.For example, the following queries can be given to the SWARD wrapper:
   
	RDQL
--------------------
	/*schema query*/
	/*Give me all properties, except for http://purl.org/dc/elements/1.1/Identifier, of a life-event.*/

SELECT ?lifeeventprop
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE (?lifeeventprop, <http://www.w3.org/2000/01/rdf-schema#domain>, 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent>)
 AND	?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>

        
	/*content query */
	/*Give me the names and descriptions of all life-events.*/
        
SELECT ?val1, ?val2
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE (?s1,<http://purl.org/dc/elements/1.1/title>,?val1)
       (?s1,<http://purl.org/dc/elements/1.1/description>,?val2)


	SPARQL
---------------------
	/*schema query*/        
	/*Give me all properties, except for http://purl.org/dc/elements/1.1/Identifier, of a life-event.*/

SELECT ?lifeeventprop
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE {?lifeeventprop <http://www.w3.org/2000/01/rdf-schema#domain> 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent> .
 FILTER	(?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>) .}

	/*content query*/
	/*Give me the names and descriptions of all life-events.*/
       
SELECT ?val1 ?val2
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE {?s1 <http://purl.org/dc/elements/1.1/title> ?val1 .
        ?s1 <http://purl.org/dc/elements/1.1/description> ?val2 .}




11. The demonstration program uses the RDFViewer interface to connect
    to a web service running RDFViewer and send the query to the
    desired wrapper. 