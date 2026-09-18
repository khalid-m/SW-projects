In order to use wsmos to generate WSDL file, you need to install TOMCAT and Java to support wsmos and AmosSoapServer.

WSMOS is tested under TOMCAT5.5. It is further assumed that you
have installed Java 1.6. To install TOMCAT and test it, please refer
to:

	http://tomcat.apache.org/tomcat-5.5-doc/index.html
	
If you are using TOMCAT6, you need to change the CLASSPATH in setup.cmd in the wsmos directory.

Go to: cd %AMOS_HOME%\embeddings\wsmos
file: setup.cmd
Change: %CATALINA_HOME%\common\lib\servlet-api.jar;%CATALINA_HOME%\common\lib\jasper-runtime.jar;%CATALINA_HOME%\common\lib\jsp-api.jar;
to: %CATALINA_HOME%\lib\servlet-api.jar;%CATALINA_HOME%\lib\jasper-runtime.jar;%CATALINA_HOME%\lib\jsp-api.jar;

More information about TOMCAT6, please refer to:

	http://tomcat.apache.org/tomcat-6.0-doc/index.html
	
--------------------------------------------
	
In order to make the Course Manager system supported by more kinds of browers and deal with the javascript cross domain problems,
you need to install the Apache HTTP Server openssl version.

CourseManager is tested under apache_2.2.14-win32-x86-openssl version.
To install and test it, please refer to:

	http://httpd.apache.org/download.cgi
	
--------------------------------------------

Set SYSTEM environment variables:
  AMOS_HOME: Home directory of AmosNT, e.g.: C:\AmosNT\

  CATALINA_HOME: Home directory of TomCat, e.g.: C:\Program\Tomcat6
  Add %CATALINA_HOME%\bin to PATH
  Add %CATALINA_HOME%\lib\servlet-api.jar to CLASSPATH
  
  APACHE_HOME: Home directory of apache, e.g.: C:\Program Files\Apache Software Foundation\Apache2.2
  
  WSDL_HOME: Directory where the generated WSDL files should be stored. It should be a directory reachable from your web server.
  e.g.: %APACHE_HOME%\htdocs\wsdl\ (ended with \)

--------------------------------------------
*** Installing the WSMOS database server ***
--------------------------------------------
1. change the current directory to CourseManager home directory:

   cd %AMOS_HOME%\embeddings\Javascript\CourseManager

2. To gernerate WSDL by using WSMOS:
2.1 First make sure you have environment variable WSDL_HOME.

2.2 setup enviroment variables, Compile the code in the wsmos and generate wsmos.dmp image file:
    Add different courses into the wsmos image. (I take dbt_summer06.osql and dbt_ht07.osql as the examples).
    If you want to add different courses, you can modify the least part of osql/CMWS.osql file.

  	setup_wsmos.cmd
  
  
2.3 To start a new Amos II nameserver and the the wsmos database server:
  
  	start_database.cmd
  

2.4 To execute the above call in the WSMOS database server without
stopping it, you can start a separate Amos II peer and use the SHIP
function to generate the WSDL file in the WSMOS database server:

	amos2
	> register("me");
	>ship("wsmos","deploy_wsdl({'login','registerstudent','registerstudentgroup','updategroup','listStudents','listLonelyStudents','listGroupMembers','studentAssignmentStatus','checkauthority','listStudentsFull','selectstudentInfoFull','assignmentInfo','updateStudentAssignmentExp','updateGroupAssignmentExp','listStudentsFullAss','executesql','existcourse'},'CMWS.wsdl','cm');");
	> quit;

This will generate a wsdl file which contains all course manager's oprations into the WSDL_HOME.
open the generated .wsdl file, you will find the line at the end:
<wsdlsoap:address location="http://%AmosSoapServer_ip_address%:%port_code%/wsmos/service/AmosServlet"/>
This %AmosSoapServer_ip_address% and %port_code% will be your web service's deploy address, 
it will be used in deploying course manager client.

--------------------------------------------
*** Start the AmosSoapServer ***
--------------------------------------------
3. To start AmosSoapServer(quickserver):
3.1 change the server config file:
	Go to %AMOS_HOME%\embeddings\wsmos\AmosWebServer\conf directory;
	Edit AmosSoapServer.xml file.
	
	Chang the first:
	<port>8082</port>
	<bind-address>0.0.0.0</bind-address>
	To:
	<port>%port_code%</port>
	<bind-address>%AmosSoapServer_ip_address%</bind-address>

3.2 Start amos soap server

		start_amos_server.cmd
  
--------------------------------------------
*** Deploy the course manager client ***
--------------------------------------------
4. Deploy client.
4.1 change the client config file:
	Go to %AMOS_HOME%\embeddings\Javascript\CourseManager\WEB-INF directory;
	Edit web.xml file.
	
	Chang:
	<wsdl-url>http://localhost/wsdl/CMWS.wsdl</wsdl-url>
	To:
	<wsdl-url>%your_WSDLfile_deploy_url%</wsdl-url>

4.2 copy client code to apache.

  deploy.cmd
  
4.2 Configuration in apache.
4.2.1	Go to %APACHE_HOME%\conf directory;
	Edit httpd.conf and configure mod_proxy to pass requests through it.
	
	uncomment:
	LoadModule proxy_module modules/mod_proxy.so
	LoadModule proxy_http_module modules/mod_proxy_http.so
	
	add:
	ProxyRequests Off
	ProxyPass /wsmos/service/AmosServlet http://%AmosSoapServer_ip_address%:%port_code%/wsmos/service/AmosServlet
	
4.2.2 Go to %APACHE_HOME%\conf directory;
	Edit mime.types and make it support read .wsdl file through GET method.
	
	Change:
	application/wsdl+xml				wsdl
	to:
	application/xml				wsdl
  
--------------------------------------------
*** Start the Course Manager ***
--------------------------------------------
5. Start Course Manager:
  
  start_coursemanager.cmd
  
6. Open a browser and give the web application address, such as:
    http://localhost/CourseManager/index.html