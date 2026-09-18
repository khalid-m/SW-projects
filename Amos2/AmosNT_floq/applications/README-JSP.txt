This instruction assumes that you have Amos and JavaAmos up
and running and that you can run the Java regression test

- Configuration related to Tomcat:
  - Get the most recent Tomcat from http://jakarta.apache.org/ which is
    in http://udbl.it.uu.se/software/Apache/jakarta-tomcat-5.0.16.exe
  - Install Tomcat and mark box 'Tomcat->service'
  - Set the variable CATALINA_HOME to point to the root of the 
    installation of Tomcat, e.g.:
    CATALINA_HOME=C:\Program Files\Apache Software Foundation\Tomcat 5.0
  - Edit you CLASSPATH to include:
    %CATALINA_HOME%/common/lib/servlet-api.jar
  - Compile the generic JSPAMOS classes by calling 
       compile.cmd
    in the directory AmosNT/applications
  - Connect to Tomcat in your browser initially on port 8080, 
    e.g. http://localhost:8080
    Click 'Users->admin' then type user name 'admin' and your 
    Tomcat administrator password.
    Click User-Action-New User
    Define a Tomcat user 'deploy' with password 'xxx' having a 'manager' role 
    to be used by ANT to deploy your application. For this use the Tomcat
    administration pages. 

- Configuration related to ANT:
  - Download latest stable release from: http://ant.apache.org/bindownload.cgi
    (e.g. http://apache.archive.sunet.se/dist/ant/binaries/apache-ant-1.5.4-bin.zip)
  - add to your environment the variable ANT_HOME to point to
    ANT root, e.g.: ANT_HOME=D:\Program Files\jakarta-ant-1.5.1
  - add to your PATH the 'bin' directory under ANT:
    e.g.: %ANT_HOME%\bin
  - Copy the catalina-ant file to ant folder: 
     copy "%CATALINA_HOME%\server\lib\catalina-ant.jar" "%ANT_HOME%\lib"

- Set up ANT configuration files:
  - Edit the ANT build file (build.xml) of your application 
    (e.g. %AMOS_HOME%/applications/CourseManager/build.xml):
    set the variable "catalina.home" to point
    to the Tomcat installation path (%CATALINA_HOME%).
  - Add the Tomcat manager and its password to you build file(s)
    'build.xml' under the XML elements "manager.username" and
    "manager.password", e.g.:
    <property name="manager.username" value="deploy"/>
    <property name="manager.password" value="xxx"/>

- Configure each web application so that the embedded Amos can find
  the DB image:
  - for each application there is a file 'web.xml' that resides in
    the WEB-INF directory of the application. This file contains
    application specific configuration information.
  -  In the case of the CourseManager app. this file is replaced by
     a set of files 'web-*.xml' which are copied to the right WEB-INF
     directory by ANT.
  - Each of these files contains an XML element <context-param> with
    sub-element <param-name>amosImage</param-name>. This is the one
    that points to the Amos image. 
  - Change the next <param-value> element to point to the righ image
    on your computer.
  - IMPORTANT: this must be an absolute path, because all paths are
    relative to the Tomcat instance which has nothing to do with
    AMOS.

- Build the course manager applications by going to home directory of
application e.g. cd %AMOS_HOME%/applications/CourseManager. There type
commands to install the application under Tomcat:

    ant -Dapp.name=oop_ht03 pre-install 
    ant -Dapp.name=dbt_ht03 pre-install

- Create Amos II images by typing 

    ant -Dapp.name=oop_ht03 amos
    ant -Dapp.name=dbt_ht03 amos

  The output is logged in install-<app name>.log

- Start the Amos II servers by:

    restart-amos.cmd 
    (or restart-amos.sh under Cygnus)

- Connect to Tomcat at http://localhost:8080 if Tomcat is running
locally or at http://<hostname>:8080 if running somwhere else.

- Tomcat has to be restarted whenever the system is re-built using
some of the procedures above.  Before restarting Tomcat you must kill
the Amos II servers first.  Then to restart Tomcat login on the server
computer with adminstrator priviledges and issue the commands:

  net stop "Apache Tomcat" 
  net start "Apache Tomcat" 

After that you have to restart the amos servers too.

Notice that if you change either an Amos II image or some DLL you have
to restart both Tomcat and Amos II. Application Java code can be
reloaded without restarting Tomcat or Amos, though.
  
Since Tomcat runs as a Windows service all start/restart scripts must
be run with administrator privileges.
