=============================== Server side ===============================
A. Install TomCat

1. Make sure you have Java version 5 installed.

2. Download Tomcat Windows Executable from http://tomcat.apache.org/
The system is tested for Tomcat 5.5

3. Download AXIS from http://ws.apache.org/axis/java/releases.html The
system is tested for AXIS version 1.4. Extract zip file to somewhere,
e.g. C:\Program\

4. Set SYSTEM environment variables:
  AXIS_HOME to the home directory of AXIS, e.g.:
       C:\Program\Axis-1_4

  CATALINA_HOME: Home directory of TomCat, e.g.: 
     C:\Program Files\Apache Software Foundation\Tomcat 5.5
  Add %CATALINA_HOME%\bin to PATH
  Add %CATALINA_HOME%\common\lib\servlets-api.jar to CLASSPATH

5. Copy directory %AXIS_HOME%\webapps\axis 
   to new %CATALINA_HOME%\webapps\axis

6. Copy the following jar files from %AMOS_HOME%\wrappers\wsmed\lib to
   "%CATALINA_HOME%"\webapps\axis\WEB-INF\lib:
         xercesImpl.jar and xml-apis.jar
        
7. Download Java Activation Framework from 
http://java.sun.com/products/javabeans/glasgow/jaf.html
You need only the file activation.jar.
Extract it to %CATALINA_HOME%\webapps\axis\WEB-INF\lib

8. Start Tomcat service (small icon at screen bottom)

9. Validate that Tomcat and AXIS work by opening browser on
http://localhost:8080/, logging in as admin, make sure axis is
started, and check the 'validation' link.

Now Tomcat and AXIS are installed!

B. Install latest Amos II as in instructions

10. Copy the file %AMOS_HOME%\bin\javaamos.jar to the 
directory %CATALINA_HOME%\shared\lib.

C. Deploy the RDFViewer web service by:

11.Set environment variable MY_HTTP to the real HTTP address of your
computer. NOTICE that http://localhost means that the outside
computers cannot call your service!

12.Set up environment for the deployment by running:
      setup_service.cmd

13.Compile the service by running:
      compile_service.cmd

14. Deploy service. This will .....


15. Run the command:
    java org.apache.axis.client.AdminClient deploy.wsdd

16. Start the server of the Amos II web service
      start.cmd

   NOTICE that this procedure starts an Amos II nameserver and three peers.
   Run it after login as these processes are killed by logout.
   Normally you do not need to rerun it before you log out from Windows.



