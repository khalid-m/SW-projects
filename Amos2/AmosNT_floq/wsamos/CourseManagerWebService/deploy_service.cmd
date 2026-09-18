pushd CMWS

java org.apache.axis.wsdl.Java2WSDL -o CMWSAdmin.wsdl -l "http://localhost:8080/axis/services/CMWSAdmin" -n "urn:CMWSAdmin" -p"jspamos" "urn:CMWSAdmin" jspamos.CMWSAdmin
java org.apache.axis.wsdl.Java2WSDL -o CMWSStudent.wsdl -l "http://localhost:8080/axis/services/CMWSStudent" -n "urn:CMWSStudent" -p"jspamos" "urn:CMWSStudent" jspamos.CMWSStudent

java org.apache.axis.wsdl.WSDL2Java -o WebContent\ -d application -s -c jspamos.CMWSAdmin -Nurn:CMWSAdmin CMWSAdmin CMWSAdmin.wsdl
java org.apache.axis.wsdl.WSDL2Java -o WebContent\ -d application -s -c jspamos.CMWSStudent -Nurn:CMWSStudent CMWSStudent CMWSStudent.wsdl

net stop tomcat6
net start tomcat6

java org.apache.axis.client.AdminClient WebContent\CMWSAdmin_pkg\deploy.wsdd
java org.apache.axis.client.AdminClient WebContent\CMWSStudent_pkg\deploy.wsdd

popd