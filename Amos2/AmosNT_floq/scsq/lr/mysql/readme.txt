MYSQL implementation of Linear Road
===================================

Requirements
------------
SCSQ
Java
MySQL 5.0 or newer
MySQL JDBC driver

Configuration
-------------
1. Execute install.sh/install.cmd in the folder scsq/lr/mysql

How to run the regression test and simulation
------------------------------------
1. Execute "./test.sh" under Linux or “test.cmd” under Windows.
2. The result is printed to the screen: the regression test followed
  by a small simulation.

Load historical input data
--------------------------
1. Set the path to the historical data file in load_history.sql
2. Log in the MySQL ("mysql -h localhost regress -u regress -p") and type
> source load_history.sql;
