net stop "Apache Tomcat"
net start "Apache Tomcat"
start /min ..\bin\amos2 -n NS
start /min ..\bin\amos2 -O webamos.osql -s WEB-AMOS