=============================== Server side ===============================
1. Make sure you have Java version 5+ installed.
--------------------------------------

2. Deploy Tomcat and Axis

2.1 Download Tomcat "Windows Service Installer" from http://tomcat.apache.org/
The system is tested for Tomcat 6.0 and the windows service name is "Tomcat6"
if you use other version of tomcat, you should change the service name in the .cmd files.

2.2 Download AXIS from http://ws.apache.org/axis/java/releases.html The
system is tested for AXIS version 1.4. Extract zip file to some path,
e.g. C:\Program\ (you'd better have no space in the path)

2.3 Set SYSTEM environment variables:
  AXIS_HOME to the home directory of AXIS, e.g.: C:\Program\Axis-1_4

  CATALINA_HOME: Home directory of TomCat, e.g.: C:\Program\Tomcat6
  Add %CATALINA_HOME%\bin to PATH
  Add %CATALINA_HOME%\lib\servlet-api.jar to CLASSPATH

2.4 Copy directory %AXIS_HOME%\webapps\axis to new %CATALINA_HOME%\webapps\axis
   
2.5 add "<user name="%your manager name%" password="%your manager password%" roles="admin,manager" />" 
	 under tag <tomcat-users> in the file $CATALINA_HOME/conf/tomcat-users.xml if there is empty under this tag.
	 (This step is not neccessary to run the web service, just in case if you want to see the Tomcat Web Application Manager page)

2.6 Start Tomcat service (execute: "net start Tomcat6" in command line if you install the Windows Executable version)

2.7 Validate that Tomcat and AXIS work by opening browser on
http://localhost:8080/, login as manager, browser "/axis" link in the application form
make sure axis is started, and check the 'validation' link.

Now Tomcat and AXIS are installed!

-------------------------------------------------------

3. Deploy the database
The Course Manager Web Service(CMWS) requires a running Amos II CMWS database 
server with the current course's database loaded.

3.1 Installing database server software

The CMWS database relies on running the CMWS server as a Windows
service. To do this a package called XYNTService is utilized. It
allows regular console applications to be installed as Windows
services. XYNTService files are stored in %amosNT_home%/xynt.

3.1.1 Make Amos II a Windows program

To enable full reconstruction in case of errors, it is very important
that the CMWS relies on a released Amos II version, e.g. the officially
released zip. Simply unzip a release to folder %programfiles%/AmosII.
Do not use the running CVS version. 
The system current test successfully with Amos II Release 11, v3.

Set SYSTEM environment variables:
  AMOS_HOME to the home directory of Amos II, e.g.: C:\Program\AmosII

3.1.2 Installing XYNTService

Go to directory %amosNT_home%\xynt 
In the install.cmd file, it need the path to generate the output of XYNTService.
You can change the %programfiles% in the install.cmd file with your
own path. Then run the command procedure ONCE:

   install.cmd

It will copy all files in this directory to a folder
%programfiles%\xynt and install XYNTService as a Windows
service. However, the service is NOT activated yet.

When XYNTService is installed, copy the file XYNTService.ini in the 
%amosNT_HOME%\wsamos\CourseManagerWebService folder to "%programfiles%\xynt". 
In the XYNTService.ini file, replace the %programfiles% with your AmosII install directory.

NOTICE that the XYNTService should NOT be started until the CMWS is
launched.

3.2 CMWS database deployment

In folder %amosNT_home%/wsamos/CourseManagerWebService/CMWS The
subdirectory 'courses' contains osql-scripts describing configurations
of each course's CMWS database. The file dbt_summer06.osql has been
provided as an example.

3.2.1 Deploy the CMWS database server

To do all the steps required to deploy the CMWS server, call the script in command line:

    deploy_database dbt_summer06

The database deployment assumes that XYNTService is installed
properly.  The command procedure 'install_database.cmd' is first
called to generate the empty database images used by the CMWS
application. Then an Amos II name server is started as a Windows
service (see XYNTService.ini). If the 2nd argument is 'recover' a
populated database is recovered from an unload file named
courses\dbt_summer06_unload.osql. Otherwise an empty database is
generated from courses\dbt_summer06.osql

You can test that the deployment worked OK by doing:

   amos2
   > amos_servers();

An object named CM should be returned.

Normally this is sufficient to deploy the CMWS database. 

When finish this step, 
you need to change the file path in the %AmosNT_HOME%\wsamos\CourseManagerWebService\CMWS\jspamos\Amos.java
in line20 "private String userPath = new File("/thesis/Tomcat 6.0/webapps/axis/WEB-INF").getAbsolutePath();"
Because the web service will read your client.dmp file in where you located it. If you doesn't change it, there
might be some error when loading the database imageFile.

--------------------------------------------------------
4. course manager web service (CMWS)  deployment

4.1 Set up environment for the deployment by running:
      compile_service.cmd
      deploy_service.cmd

4.2 Restart tomcat server:
      start_amos_server.cmd
    browser http://localhost:8080/axis/ click"List"
    to see the course manager web service for student and admin
    
Then the web service deployed successfully.
    
=============================== Client side ===============================

1. Copy CMWS client code to tomcat webapp folder:
    copy_client.cmd
    
2. start database service
    start_database.cmd

2. Browse web service client:
    open http://localhost:8080/CMWSClient/index.jsp