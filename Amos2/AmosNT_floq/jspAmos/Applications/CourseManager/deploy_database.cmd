rem starts a version of the course manager as Amos server named CM
IF "%1%"=="" GOTO nodatabase

net stop XYNTService
net stop "Apache tomcat"

copy /Y %AMOS_HOME%\bin\amos2.exe "%ProgramFiles%\amosII\bin"
copy /Y %AMOS_HOME%\bin\amos2.dmp "%ProgramFiles%\amosII\bin"
copy /Y %AMOS_HOME%\bin\msvcrtd.dll "%ProgramFiles%\amosII\bin"
copy /Y %AMOS_HOME%\bin\javaamos.dll "%ProgramFiles%\amosII\bin"
copy /Y %AMOS_HOME%\bin\javaamos.jar "%ProgramFiles%\amosII\bin"

call generate_database.cmd %1 %2
copy "WEB-INF\%1_server.dmp" "%ProgramFiles%\AmosII\bin\CM.dmp"
copy "WEB-INF\client.dmp" "%catalina_home%\webapps\CourseManager\WEB-INF"

net start XYNTService

goto end
:nodatabase
echo Specify course manager ID as parameter!
goto end

:end
