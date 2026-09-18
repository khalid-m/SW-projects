It is assumed that you have successfully installed TOMCAT and Java
1.5. WSMOS is tested under TOMCAT5.5. It is further assumed that you
have installed Java 1.5. To install TOMCAT and test it, please refer
to:

	http://tomcat.apache.org/tomcat-5.5-doc/index.html

--------------------------------------------
*** Installing the WSMOS database server ***
--------------------------------------------

Enter the directory "%AMOA_HOME%\embeddings\WSMOS"

1. setup enviroment variables:

setup.cmd


2. compile the Java code:

compile.cmd


3. Generate database images:

3.1 First make sure you have environment variable WSDL_HOME set to the
directory where the generated WSDL files should be stored. WSDL_HOME
should be a directory reachable from your (e.g. Apache) web server,
e.g.  C:\Program\Apache Group\Apache2\htdocs\wsdl

3.2 Make the WSMOS server database image by:
      mkdmp.cmd


4. Start WSMOS database server:

4.1 Make sure you have an Amos II nameserver running.Otherwise do
      start amos2 -n

4.2 Start the wsmos database server by:
      startDatabase.cmd

A database server named WSMOS will be started in separate windows.

--------------------------------------------------
*** Deploying the WSMOS stand-alone web server ***
--------------------------------------------------

1. Enter the WSMOS web server directory 

cd "%AMOS_HOME%\embeddings\WSMOS\AmosWebServer"


2. Setup enviroment variables

setup.cmd


3. Compile the Java code:

compile.cmd


4. Run the WSMOS web server

WSMOSServer.cmd

This will start the stand-alone WSMOS web server in a separate window.


-----------------------------------------
*** Deploying WSMOS as Tomcat service ***
-----------------------------------------

1.  The WSDL_HOME directory has to be 
       %CATALINA_HOME%\webapps\wsmos\wsdl\

2.  Deploy WSMOS as a Tomcat service.

    deploy_tomcat.cmd


3.  Publish WSMED files using Tomcat

    Open a browser and give the web application address, such as:
    http://localhost:8080/wsmos/.

    You give a comma list of function name, then click "submit". For
    example, enter 'info, getallpersons'. The server will automatically
    generate a wsdl file in the text area. It is also published as a
    unique WSDL file that you can inspect through the browser. You can
    copy and save it.

------------------------------------------------------------
*** Deploying the WSDL file in the WSMOS database server ***
------------------------------------------------------------

We provide two ways to generate and deploy the WSDL file for exportable
functions stored in the exportTable table:

 A.  Publish the WSDL file using a web interface with Tomcat as
     explained above.

 B.  Generate WSDL in the WSMOS database server, as explained next.

In the WSMOS database server there is a foreign function:
   deploy_wsdl(Vector of Charstring expfns, Charstring WSDL)
It generates a WSDL file exporting the functions in EXPFNS.

The function has two arguments. The first argument is a Vector of
function names to be exported. The second argument is WSDL file name. For
example:

        deploy_wsdl({"info","getAllPersons"},
                      "person.wsdl");

All the resolvents of generic functions (e.g. INFO) will be
exported. Specific resolvents can also be specified. 

Only functions declared to be exportable are deployed. Declare them
using function:

      exportable(Charstring fn)->Boolean
e.g.
      exportable("plus");

The file will be written into the directory in

  deploy_dir()->Charstring

The default is %APACHE_HOME%/htdocs/. You can change it
to some other directory if you wish, e.g.
  
 set deploy_dir() = ".";

To execute the above call in the WSMOS database server without
stopping it, you can start a separate Amos II peer and use the SHIP
function to generate the WSDL file in the WSMOS database server:

  amos2
  > register("me");
  > ship("wsmos","exportable('info');");
  > ship("wsmos","deploy_wsdl({'info'},'info.wsdl');");


To actually plublish the WSDL file on the web it has to be written to
some location reachable by the web server.

A more complicated and unsecure alternative could be to export
'generate_wsdl' as a web service operation. Then external programs can
generate the WSDL too by using a web service operation but that would
be a security back door since any file can be overwritten.

----------------------------------------------
*** Testing deployed  WSDL file with WSMED ***
----------------------------------------------

1.  Install and run WSMED.

2.  call
      importwsdl("http://localhost/wsdl/info.wsdl");
    assuming WSDL_HOME is the folder 'wsdl' under web server directory.

3.  Call AmosQL function
      info();
    It will call info() through the web service mechanism.
