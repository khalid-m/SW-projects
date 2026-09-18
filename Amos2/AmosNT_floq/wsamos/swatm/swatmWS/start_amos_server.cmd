net stop "Apache Tomcat"
net start "Apache Tomcat"
start /min %AMOS_HOME%\bin\amos2 -n NS
swatm_server
