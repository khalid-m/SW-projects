net stop "Apache Tomcat"
net start "Apache Tomcat"
start /min "NS" %AMOS_HOME%bin\amos2 -n NS
start /min "SWATM_SERVER" swatm_server
start /min "SWARD_SERVER" sward_server
start /min "RDFVIEWER" rdfviewer


