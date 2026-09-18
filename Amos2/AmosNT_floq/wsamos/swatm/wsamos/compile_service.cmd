pushd ..
javac -g wsamos\Webamos.java

java org.apache.axis.wsdl.Java2WSDL -o webamos.wsdl -l "%my_http%:8080/axis/services/Webamos" -n "urn:WSAmos" -p"wsamos" "urn:WSAmos" wsamos.Webamos

java org.apache.axis.wsdl.WSDL2Java -o . -d application -s -S true -Nurn:WSAmos wsamos webamos.wsdl

javac wsamos\*.java

popd

copy *.class "%DEPLOY_DIR%\classes\wsamos\"

