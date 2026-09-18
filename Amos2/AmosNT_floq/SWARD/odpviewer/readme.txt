	=====================================================================================

	Steps needed to download a fresh dmoz into MySQL database and query it in SWARD
	(This file comes together with the download package) 

	=====================================================================================

	-------- This is solely for the Windows OS ------------------------------------------

1.	Download and install MySQL,PHP & Apache server 
	(you will need a Web server capable of running PHP and a mySQL database).

	source:http://www.wampserver.com/en/download.php
	
	It's a simple full installation shield by following the default wizard instructions.


2.	Download MySQL JDBC driver

        Source:
        http://dev.mysql.com/downloads/connector/j/3.1.html

        Purpose: JDBC driver manager for MySQL. 
        Installation: Installation shield.

        After the installation of MySQL JDBC do:
	extract the jar file named mysql-connector-java-3.0.15-ga-bin.jar from the zip file and copy it into the 			folder named e.g. 	c:\Program Files\Java\jdk1.5.0_11\jre\lib\ext

	Add  mysql-connector-java-3.1.14-bin.jar to your CLASSPATH
	e.g. c:\Program Files\Java\jdk1.5.0_11\jre\lib\ext\mysql-connector-java-3.1.14-bin.jar


3.	Check the installation is correct, go to start--->All programs--->wampserver
	This will automatically get the MySQL,PHP & Apache running.
	Down on the right hand corner,on the taskbar there should be a small icon showing: wamp5-all service running-

4.	Open the browser and type this URL: http://localhost
	This will show a welcome windows, and the different versions of the applications being used.
	
	Tools: indicate the interface that you can use, such as PHPmyadmin 2.10.1
	Your projects: The roots directory...this is where you keep your files (instance:dmoz) in the folder.


5.	Locate the path to PHP.exe and add it to PATH

    	The php.exe path could be located at: C:\wamp\php


6.      Create an empty MySQL ODP database by calling
           add.cmd              
	

7.	Download fresh dmoz dump:
           odpxtension.cmd

	Options given to choose from gz,txt and rdf

  7.1      odpdownload.cmd
	

        All extracted and downloaded files will be located in the current folder.

	Keep in mind: when you use odpdowload.cmd, this will immediately download the fresh dump files into your php directory and then 	clean and populate them into MySQL.
	You may drop the database anytime you like through drop.cmd, and also recreate the same databse. However, for this particular project, 	the database name is always fixed, (DMOZ).
	
	========================================
	RDQL queries through SWARD:
	========================================

8.      Make empty SWARD database by
          mkdmp.cmd


9. 	Test ODPVIEWER by
          test.cmd

10. 	Run queries:

        
11.	Results:  	