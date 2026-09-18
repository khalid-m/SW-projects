pushd ..
javac -g swatmWS\SwatmWS.java

java org.apache.axis.wsdl.Java2WSDL -o swatmWS.wsdl -l "%my_http%:8080/axis/services/SwatmWS" -n "urn:SwatmWS" -p"swatmWS" "urn:SWatmWS" swatmWS.SwatmWS

java org.apache.axis.wsdl.WSDL2Java -o . -d application -s -S true -Nurn:SwatmWS swatmWS swatmWS.wsdl

javac swatmWS\*.java

popd

copy *.class "%DEPLOY_DIR%\classes\swatmws\"

