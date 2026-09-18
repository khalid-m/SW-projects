rem starts a version of the course manager as Amos server named CM
IF "%1%"=="" GOTO nodatabase

net stop XYNTService
net stop "Tomcat6"

call generate_database.cmd %1 %2
copy "WEB-INF\%1_server.dmp" "%AMOS_HOME%\bin\CM.dmp"
copy "WEB-INF\client.dmp" "%CATALINA_HOME%\webapps\axis\WEB-INF"

net start XYNTService

goto end
:nodatabase
echo Specify course manager ID as parameter!
goto end

:end
