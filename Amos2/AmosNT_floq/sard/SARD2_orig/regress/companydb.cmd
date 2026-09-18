@echo off

:MYSQLSETUP
set URLDB=jdbc:mysql://localhost:3306/regress
set DRIVERDB=com.mysql.jdbc.Driver
set CATALOGDB=regress
set SCHEMADB=""
set NAMEDB=regress
set USERDB=regress
set PASSWORDDB=regress

call javaamos -O mysqlpopulate.osql

goto end


:END

