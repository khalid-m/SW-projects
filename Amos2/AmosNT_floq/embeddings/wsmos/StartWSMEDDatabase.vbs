
set WshShell = createObject("Wscript.shell")
WshShell.run "java -cp WEB-INF\classes;WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS WEB-INF/wsmos.dmp WEB-INF/src/amosql/wsqs.amosql",0,false


