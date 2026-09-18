=======================================================================
 How to install and run S3RDB from Amos
(Universal Property Views, UPV) over relational databases.
=======================================================================


This project have 3 different schemas

repeatidfunctions: 	All particles data is in Particle, lepton and jet inherents idap from particle, and moun and electron 			from lepton and then are join with views. Queries implemented by functions.

duplicatedatafunctions: All particles data is duplicated in all the tables. Queries implemented by functions.

bigtablefunctions: 	All particles data is in particle, and then are seperated by views. Queries implemented by functions.

repeatidviews: 		All particles data is in Particle, lepton and jet inherents idap from particle, and moun and electron 			from lepton and then are join with views. Queries implemented by view.

duplicatedataviews: All particles data is duplicated in all the tables. Queries implemented by views.

bigtableb: 		All particles data is in Particle, lepton and jet inherents idap from particle, and moun and electron 			from lepton and then are join with views. Queries implemented by views.


The folder contains

-readme.txt: Instruction the understand, configure and run S3RDB

-report(folder)
	-repeatid.vsd: Diagram for repeatidfunctions and repeatidviews.
	-duplicatedata.vsd: Diagram for duplicatedatafunctions and duplicatedataviews.
	-bigtable.vsd: Diagram for bigtablefunctions and bigtableviews.
	-testplan.txt: Plan elaborated to test the schemas.
	-executionplans(folders): every folder contains the execution query plans for every query in every schema
	-timesamos.txt: results of execution time of the queries on Amos
	-timesrepeatid.txt: results of execution time of the queries on repeatid
	-timesduplicatedata.txt: results of execution time of the queries on duplicatedata
	-timesbigtable.txt: results of execution time of the queries on bigtable

-prepare(folder)
	-load.txt: javaamos commands to prepare data to import to MSSQL server.
	-importdata.txt: javaamos commands to connect to sql server and import data.

-Sqlfiles(folder):
	-formulas.slq: This file contains all scalar formulas to be use in schemas
	-queriesfunctions.sql: 	Queries implemented by functions for repeatidfunctions, duplicatedatafunctions and 						bigtablefunctions.
	-queriesviews.sql: Queries implemented by views for repeatidviews, duplicatedataviews and bigtableviews.
	-repeatid.sql: Implementation of repeatidfunctions and repeatidviews.
	-duplicatedata.sql: Implementation of duplicatedatafunctions and duplicatedataviews.
	-bigtable.sql: Implementation of bigtablefunctions and bigtableviews.


-test(folder)
	-stadisticstimefunctios.sql: Queries to obtain results and execution times for repeatidfunctions, 				     			     duplicatedatafunctions and bigtablefunctions.
	-stadisticstimeviews.sql: Queries to obtain results and execution times for repeatidviews, duplicatedataviews and 				  bigtableviews.
	-testqueriesfunctions.sql: Queries to obtain execution query plan for schemas repeatidfunctions, 				     			   duplicatedatafunctions and bigtablefunctions.
	-testqueriesviews.sql: Queries to obtain execution query plan for repeatidviews, duplicatedataviews and 			       bigtableviews.



------------------------------
Instructions to configure S3RDB
-------------------------------

1 Download and install all necesary programs from the next link

http://user.it.uu.se/~udbl/software/setup_instructions.txt

2 Install and configure MSSQL Server 2005

  2.1 Install MSSQL 2005 Server

	2.1.1 After installing enter in the SQL Sever Configuration and then enter in SQL Server 2005 Network Configuration,
	      then in protocols for MSSQLSERVE and check that TCP/IP is enable and named pipes and Via are disable.
	2.1.2 Then come back and enter in SQL Server 2005 Services and be sure that SQL Server is running.
  
  2.2 Download MSSQL JDBC Driver
         Source:
		http://user.it.uu.se/~udbl/software/SQLServer_JDBC.zip
	
	Add 'mssqlserver.jar', 'msbase.jar' and 'msutil.jar' to your CLASSPATH.

  2.3 	Create new database 'repeatidfunctions'. Add new login ('loginrepeatidfunctions') for 'repeatidfunctions' with 		password (e.g. '12345').  
       	Create new user ('user') for login 'loginrepeatidfunctions'. Set 'Database role' of user 'user' in 		'repeatidfunctions' to 'db_owner'.
	Create new schema 'srepeatidfunctions'). Set 'Default schema' of 'user' in 'repeatidfunctions' to 		'srepeatidfunctions'. 
        Input sql script 'repeatidfunctions.sql' as login 'loginrepeatidfunctions' to populate 'repeatidfunctions'.

	repeat the same process for repeatidviews, duplicatedatafunctions, duplicatedataviews, bigtablefunctions, 		bigtableviews, remember to change all 	names to corresponding ones

3. Load formulas and queries on MSSQL Server

	3.1 Load 'formulas.sql' for every schema

3.2 Load queries on MSSQL Server
	3.2.1 Load 'queriesfunctions.sql' for repeatidfunctions, duplicatedatafunctions and bigtablefunctions
	3.2.2 Load 'queriesviews.sql' for repeatidviews, duplicatedataviews and bigtableviews


4 Load data from Amos
	4.1 Open Javaamos.bat on console in the folder %Amos_Home%/bin/
	4.2 Load data in javamos
	4.3 run functions from the file %Amos_home%/S3RB/load.amossql
	4.4 run called functions from the file %Amos_home%/S3RB/importdata.amossql

5 testing
	5.1 for time testing use the scripts 'stadisticstimefunctions.sql' and 'stadisticstimeviews.sql' from 	%Amos_home%/S3RB/test/ 	folder
	5.2 for query execution plan use the scrips 'testqueries.sql' and 'testqueriesb.sql' from %Amos_home%/S3RB/test/ 		folder
		5.2.1 Click every link with the left button of the mouse and save as 'queryplanname.sqlplan'
		5.2.2 Open it with MSSQL Server