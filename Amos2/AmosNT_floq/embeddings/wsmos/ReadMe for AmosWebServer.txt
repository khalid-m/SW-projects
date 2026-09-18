WSMOS using AmosSoapServer communication server:

In order to deploy the WSMOS, we need to install two application:
  1. install WSDL Generator.
  2. install AmosSoapServer.

It is assumed that you have successfully installed Java 1.5.

--------------------------------------------
*** Installing the WSMOS database server ***
--------------------------------------------

Enter the directory "%AMOA_HOME%\embeddings\WSMOS"

1. setup enviroment variable:

setup.cmd


2. compile the codes.

compile.cmd


3. Generate database images

mkdmp.cmd


4. start WSMOS database server.

Type:

    startDatabase.cmd

A nameserver and a database server named WSMOS will be started in
separate windows.


-----------------------------------------
*** Deploying WSMOS as Tomcat service ***
-----------------------------------------

1.  Deploy WSMOS as a Tomcat service.

    deploy_tomcat.cmd


2.  Publish WSMED files using Tomcat

    Open a browser and give the web application address, such as:
    http://localhost:8080/wsmos/.

    You give a comma list of function name, then click "submit". For
    example, enter 'info, getallpersons'. The server will automatically
    generate a wsdl file in the text area. It is also published as a
    unique WSDL file that you can inspect through the browser. You can
    copy and save it.

--------------------------------------------------
*** Deploying the WSMOS stand-alone web server ***
--------------------------------------------------

1. Enter the WSMOS web server directory 

cd "%AMOS_HOME%\embeddings\WSMOS\AmosWebServer"


2. Setup enviroment variables

setup.cmd


3. Compile the codes.

compile.cmd


4. Run the WSMOS web server

WSMOSServer.cmd


------------------------------------------------------------
*** Deploying the WSDL file in the WSMOS database server ***
------------------------------------------------------------


We provide two ways to generate and deploy the WSDL file for exportable
functions stored in the exportTable table:

 A.  Publish the WSDL file using a web interface with Tomcat as
     explained above.

 B.  Generated WSDL in the WSMOS database server, as explained next.

In the WSMOS database server there is a foreign function,
"generate_wsdl". You can use this function to generate the WSDL file.
The function has two arguments. The first argument is a Vector of
Functions. The second one is output file name.

    For example, 

        generate_wsdl({functionnamed("info"),functionnamed("getAllPersons")},
                      "person.wsdl");

To execute the above call in the WSMOS database server you can start a
separate Amos II peer and use the SHIP function to generate the WSDL
file in the WSMOS database server.

To actually plublish the WSDL file on the web it has to be copied
to some location reachable by the web server,
e.g. %CATALINA_HOME%\htdocs.

A more complicated and unsecure alternative is to export
'generate_wsdl' as a web service operation. Then external programs can
generate the WSDL too by using a web service operation but it would be
a severe security back door since any file can be overwritten.

------------------------------
*** Using WSMOS with WSMED ***
------------------------------

1. load wsdl into WSMED.

  Please make sure that you succeeded in installing WSMED. Using
  "importwsdl" function to parse the WSDL file.

  for example,

  	importwsdl("wsdl/person.wsdl");

  You can use goovi() to check the service.

2. Call the accessed web service operation from WSMED:

  info();  

