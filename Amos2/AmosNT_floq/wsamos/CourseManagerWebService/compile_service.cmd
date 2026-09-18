set CLASSPATH=%AMOS_HOME%\bin\javaamos.jar;%AXIS_HOME%\lib\wsdl4j-1.5.1.jar;%AXIS_HOME%\lib\saaj.jar;%AXIS_HOME%\lib\log4j-1.2.8.jar;%AXIS_HOME%\lib\jaxrpc.jar;%AXIS_HOME%\lib\commons-logging-1.0.4.jar;%AXIS_HOME%\lib\commons-discovery-0.2.jar;%AXIS_HOME%\lib\axis-schema.jar;%AXIS_HOME%\lib\axis-ant.jar;%AXIS_HOME%\lib\axis.jar;%CLASSPATH%;.

javac CMWS\jspamos\*.java

xcopy /S /Y CMWS\jspamos\*.class "%CATALINA_HOME%\webapps\axis\WEB-INF\classes\jspamos\"
copy %AMOS_HOME%\bin\javaamos.jar "%CATALINA_HOME%\webapps\axis\WEB-INF\lib\"

pushd %CATALINA_HOME%\webapps\axis\WEB-INF\
copy client.dmp "%CATALINA_HOME%\webapps\axis\WEB-INF\classes\jspamos\"
popd