@echo off

:MYSQLSETUP
set URLDB=jdbc:mysql://localhost:3306/egovernment
set DRIVERDB=com.mysql.jdbc.Driver
set CATALOGDB=regress
set USERDB=regress
set PASSWORDDB=regress

call javaamos -O egovpopulate.osql

goto end


:END

