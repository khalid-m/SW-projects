=======================================================================
                   How to install and run "sard"
=======================================================================

1. Download JDK version 1.5.0_11 or higher(regression tested with version 1.5.0_11 and 1.6.0_01)
   Source:
	http://java.sun.com/javase/downloads/index.jsp
   
  Set environment variable JDK to point to your JAVA home directory, e.g.
      C:\Program Files\Java\jdk1.6.0_01


2. Create example database

 2.1 Using InterBase FireBird

 2.1.1 Download FireBird/InterBase relational database

        Source:
		http://user.it.uu.se/~udbl/software/Firebird-1.0.0.796-Win32.exe

        Installation: Installation shield

 2.1.2 Download InterClient JDBC driver

        Source:
		http://user.it.uu.se/~udbl/software/interclient_201_Win32.zip

        Purpose: JDBC driver manager for FireBird/Interbase. 
        Installation: Installation shield.

        After the installation of InterClient do:

   2.1.2.1 Make sure that you have manually entered the following line into your
            services file in c:\winnt\system32\drivers\etc\services:

            interserver      3060/tcp             # InterBase InterServer

   2.1.2.2 Run isconfig.exe to start the local InterClient server.

   2.1.2.3 Add 'interclient.jar' to your CLASSPATH. It is, e.g., located in
            c:\Program Files\FireBird\InterClient\interclient.jar

   2.1.2.4 Create and set environment variable INTERBASE_BIN to point to the directory
            where Interbase/FireBird keeps the the binaries, e.g. c:\Program Files\FireBird\bin

  2.1.3 Create and populate the 'exampleDB' database by calling 

		exampleDB.cmd

 2.2. Using MySQL

 2.2.1. Install WAMP, which is a package combining Apache web server with PHP and MySQL.
	Source: http://user.it.uu.se/~udbl/software/WampServer2.0a.exe

	Installation: 

	1. Run installer.

	2. Start all WAMP services

	3. Open MySQL console with empty password. Paste in the following SQL
	commands to create database 'example' and user called 'sard':

	  CREATE USER 'sard'@'localhost' IDENTIFIED BY 'sard';

	  GRANT USAGE ON * . * TO 'sard'@'localhost' IDENTIFIED BY 'sard'
	  WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 
	  MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

	  CREATE DATABASE IF NOT EXISTS `example` ;

	  GRANT ALL PRIVILEGES ON `example` . * TO 'sard'@'localhost';

 2.2.2. JDBC driver for MySQL is neede as well

	Source: http://user.it.uu.se/~udbl/software/mysql-connector-java-5.1.6-bin.jar

	Installation: Download and make shure included in CLASSPATH.


3. Download Jena 2 from 
    http://jena.sourceforge.net/downloads.html

4. Set environment variable JENA_HOME to point to Jena 2 root
   directory, e.g.
    C:\Program\Jena-2.1

5. Compile all the needed Java code by 

   compile.cmd
	
6. Install SARD by calling

       mkdmp.cmd
 

6. Run sard by calling

       sard.cmd

       -> If you use MySQL populate the 'example' database by calling 

       <'example.osql';


7.  Generate the RDF schema and RDF data for archiving the relational database
    into RDF files by using following function

	 7.1.Using MySQL

	 set :url = "jdbc:mysql://localhost:3306/" + "example";
	 SARDUnload(:url, "com.mysql.jdbc.Driver", "sard", "sard", "example");
	 
	 7.2.Using Firebird

	set :url = "jdbc:interbase://localhost/" + getenv("INTERBASE_BIN") 
                      + "/exampleDB.gdb";
	SARDUnload(:url, "interbase.interclient.Driver", "SYSDBA", "masterkey", 
                 "exampleDB");

 
8. Reload the archived database

 8.1.Using MySQL

 8.1.1	 Open MySQL console with empty password. Paste in the following SQL
	commands to create an empty database :

	  CREATE DATABASE IF NOT EXISTS `reloadDB` ;

	  GRANT ALL PRIVILEGES ON `reloadDB` . * TO 'sard'@'localhost';
 
8.1.2	Reload the 'example' database from the rdf files in the empty database 'reloadDB'

	    Run sard by calling 
	 
	    sard.cmd

	    set :url = "jdbc:mysql://localhost:3306/" + "reloadDB";

	    SARDLoad(:url, "com.mysql.jdbc.Driver", "sard", "sard", "example");
	 
 8.2.Using Firebird

 8.2.1 create empty database to reload RDF into
	
	reloadDB.cmd


 8.2.2 /* Reload the unloaded data in to new database using RDF Archival files */
       
      sard.cmd
	
	set :url = "jdbc:interbase://localhost/" + getenv("INTERBASE_BIN") 
                      + "/reloadDB.gdb";
	SARDLoad(:url, "interbase.interclient.Driver", "SYSDBA", "masterkey", 
                 "exampleDB");

