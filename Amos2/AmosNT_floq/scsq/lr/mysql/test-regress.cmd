@echo off

set PORTDB="3306"

mysql -u regress regress --password=regress -P %PORTDB% < master.sql
rem Regression test for MySQL implementation
javascsq mysql-lr.dmp -O "test-mysql.osql" -o "quit;"