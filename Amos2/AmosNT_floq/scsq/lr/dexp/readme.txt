MYSQL implementation of Linear Road
===================================

Requirements
------------
SCSQ
Java
MySQL 5.0 or newer
MySQL JDBC driver

Install MySQL
--------------

Please read the introductions in Mysql_Setup.txt 

Create database
--------------------------
1. Log in the MySQL ("mysql -h localhost regress -u regress -p") Enter password regress and type
> source master.sql;


Configuration
-------------
1. Execute install.sh/install.cmd in the folder scsq/lr/dexp

How to run the regression test and simulation
------------------------------------
1. Execute  “test.cmd” under Windows.
2. The result is printed to the screen


Load historical input data & Run java file
------------------------------------------

1. compile History.java by
	>javac History.java

2. Run History Class to load historical data. This may take some time depending on the number of VIDs
	>java History 1 100000 1 //The first argument is L, second is the number of VIDs and the last one is direction
3. compile Expenditure.java by
	>javac Expenditure.java
4. Run Expenditure Class to run daily expenditure queries.
	java Expenditure lr-0.5.out // the argument is the path to the input file.

5. or mysql> load data infile '~/AmosNT/scsq/lr/dexp/data/history.txt' into table historical_toll lines terminated by '\r\n'; 
if you have it stored before.
	
