pushd ..
javac -g rdfview\RDFViewWS.java

java org.apache.axis.wsdl.Java2WSDL -o RDFViewWS.wsdl -l "%my_http%:8080/axis/services/RDFViewWS" -n "urn:RDFViewWS" -p"rdfview" "urn:RDFViewWS" rdfview.RDFViewWS

java org.apache.axis.wsdl.WSDL2Java -o . -d application -s -S true -Nurn:RDFViewWS rdfview RDFViewWS.wsdl

javac rdfview\*.java

popd

copy *.class "%DEPLOY_DIR%\classes\rdfview\"
copy "%AMOS_HOME%\bin\javaamos.jar" "%CATALINA_HOME%\shared\lib"
copy "%AMOS_HOME%\bin\amos.dll" "%CATALINA_HOME%\bin"
copy "%AMOS_HOME%\bin\javaamos.dll" "%CATALINA_HOME%\bin"
copy "%AMOS_HOME%\bin\amos2.dmp" "%CATALINA_HOME%\"
