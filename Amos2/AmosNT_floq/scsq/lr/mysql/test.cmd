@echo off

set PORTDB="3306"

mysql -u regress regress --password=regress -P %PORTDB% < master.sql

rem Test SCSQ-LR in single-node
javascsq mysql-lr.dmp -O "test_single_node.osql" -o "quit;";