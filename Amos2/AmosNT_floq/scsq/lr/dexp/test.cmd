@echo off

set PORTDB="3306"

start cmd.exe /c javascsq mysql-lr.dmp -l "(trace server-eval)" -ns

mysql -u regress regress --password=regress -P %PORTDB% < master.sql
rem Regression test for MySQL implementation
javascsq mysql-lr.dmp -O "src/test_Regress.osql" -o "q();"
