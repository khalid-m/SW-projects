

How to install and test the RDB reloader for transforming archived RDF
files to relational database.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


Administrative Steps
--------------------

1. Download JDK version 1.5.0_11 or higher (regression tested with
version 1.5.0_11 and 1.8.0_01).

	Source:

		http://java.sun.com/javase/downloads/index.jsp
   
  	Set environment variable JDK to point to your JAVA home
  	directory, e.g.
  
		C:\Program Files\Java\jdk1.8.0_01

2. Install WAMP with a package consisting of Apache web Server having
MYSQL and PHP.  Source:
http://user.it.uu.se/~udbl/software/WampServer2.0a.exe

	2.1 Run Installer.

	2.2 Start All WAMP services.

	2.3 Open a connection to MySQL with empty password.

	2.4 Execute the following SQL statement to create an empty
	sample database 'example_db1' with username 'u1' and password
	'12345'.

		
		CREATE USER 'u1'@'localhost' IDENTIFIED BY  '12345';

		GRANT ALL PRIVILEGES ON * . * TO 'u1'@'localhost'
		IDENTIFIED BY '12345' WITH GRANT OPTION
		MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0
		MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

		CREATE DATABASE IF NOT EXISTS `example_db` ;

		GRANT ALL PRIVILEGES ON `example_db` . * TO
		'u1'@'localhost';

	  		
	2.5 Download the JDBC driver for MySQL and include it in the
	CLASSPATH.

		Source:
         http://user.it.uu.se/~udbl/software/mysql-connector-java-5.1.6-bin.jar


Running RDF-RDB reloader
------------------------

3. Reload the Archived RDF files in the empty database 'example_db'

	4.1 Compile all the function needed to run the RDF-RDB reloader system.

		mkdmp.cmd
	4.2 Run the system by:

		restore.cmd
	
	4.3 Set up connection

		set :dbname="example_db";
		set :dbuser="u1";
		set :dbpass="12345";
		set :a = jdbc("con1", "com.mysql.jdbc.Driver");
		set :dburl="jdbc:mysql://localhost:3306/"+:dbname;
		connect(:a, :dburl, :dbuser, :dbpass);

4. Importing the Archived RDF Schema files. 
	
		logging off;
		importSchema('NTArchives/prod1S.nt','http://user.it.uu.se/~udbl/sard/prod');
		


5 Reloading the Archived Schema and Row-Order Data files(Sorted by Foreign keys).
		
	5.1 [Method: Vector Sorting (Works For Single and Composite key)]
	
		loadSQLFKInsert(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');
					
						
	5.2 [Method: Stored function]

		FKInsertST(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');
	

6. Reloading the Archived Schema and RowOrder Data files(Bulk Insert Loader).
 	
	6.1 [Method: Vector Sorting (Works For Single and Composite key)]
	
		loadSQLBulkInsert(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');
					
						
	6.2 [Method: Stored function]

		BulkInsertATST(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');	

				
7. Reloading the Archived Schema and Row-Order Data files(Plain Insert Loader).
		
	7.1 [Method: Vector Sorting (Works For Single and Composite key)]
	
		loadSQLPlainInsert(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');
					
						
	7.2 [Method: Stored function]

		PlainInsertST(:a,'NTArchives\prod1.nt','http://user.it.uu.se/~udbl/sard/prod');
	
	
		
8. Reloading the Archived Schema and Column-Order Data files(Sorted by Foreign keys).
	
		loadSQLColORderInsert(:a,'NTArchives\producer1.nt','http://user.it.uu.se/~udbl/sard/prod');


9. Reloading the Archived Schema and Column-Order Data files(No Foreign keys).
	
		loadSQLNoCheckColORderInsert(:a,'NTArchives\producer1.nt','http://user.it.uu.se/~udbl/sard/prod');

		
10. Reloading the Archived Schema (No BaseURI).
		
		loadSQLInsertNoURI(:a,'NTArchives\producer1.nt');


11. Clean realtional database (if required).
	
		cleanDatabase(:a,'http://user.it.uu.se/~udbl/sard/prod');

12. Clean imported schema table (if required).
	
		cleanS();



		