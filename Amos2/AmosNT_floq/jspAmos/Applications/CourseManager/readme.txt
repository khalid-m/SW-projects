The Course Manager (CM) requires a running Amos II CM database server
with the current course's database loaded. The CM database server is
called from the form-based user interface CM application running as a
TomCat application. Both TomCat and the CM server must run as Windows
services independent of any logins.

1. Installing database server software
--------------------------------------

The CM database relies on running the CM server as a Windows
service. To do this a package called XYNTService is utilized. It
allows regular console applications to be installed as Windows
services. XYNTService files are stored in %amos_home%/xynt.

1.1 Make Amos II a Windows program

To enable full reconstruction in case of errors, it is very important
that the CM relies on a released Amos II version, e.g. the officially
released zip. Simply unzip a release to folder %programfiles%/AmosII.
Do not use the running CVS version. 

Do NOT include %programfiles%\AmosII\bin in the system environment
variable PATH. It will override the version of Amos II you are running
for development.

1.2 Installing XYNTService

Go to directory %amos_home%\xynt and read readme.txt on how to install
XYNTService. It should be installed in a directory named
%programfiles%\xynt.

When XYNTService is installed, copy the file XYNTService.ini in the CM
home folder to "%programfiles%\xynt". 

Edit "%programfiles%\xynt\XYNTService.ini" replacing %programfiles%
with the expanded path.

NOTICE that the XYNTService should NOT be started until the CM is
launched.

2. CM database deployment
-------------------------

In folder %amos_home%/jspamos/Applications/CourseManager The
subdirectory 'courses' contains osql-scripts describing configurations
of each course's CM database. The file dbt_summer06.osql has been
provided as an example.

2.1 Deploy the CM database server

To do all the steps required to deploy the CM server and make it
available to the CM TomCat, call the script:

    deploy_database dbt_summer06 recover

The database deployment assumes that XYNTService is installed
properly.  The command procedure 'install_database.cmd' is first
called to generate the empty database images used by the CM
application. Then an Amos II name server is started as a Windows
service (see XYNTService.ini). If the 2nd argument is 'recover' a
populated database is recovered from an unload file named
courses\dbt_summer06_unload.osql. Otherwise an empty database is
generated from courses\dbt_summer06.osql

You can test that the deployment worked OK by doing:

   amos2
   > amos_servers();

An object named CM should be returned.

The output from the CM server is logged in
WEB-INF/dbt_summer06_server.log.

Normally this is sufficient to deploy the CM database. 

2.2.1 Separate database generation

During development you can generate the database images separately by
the command procedure:

   generate_database dbt_summer06

This will generate two database images, dbt_summer06_client.dmp and
dbt_summer06_server.dmp. 

dbt_summer06_server.dmp is the CM database. The script
dbt_summer06.osql is loaded into this database. The database output is
logged into WEB-INF/dbt_summer06_server.log.

dbt_summer06_client.dmp is a dummy embedded database to run inside
TomCat. This database it normally not used by the CM application. It's
output is logged into WEB-INF/dbt_summer06_client.log.

2.2.1 Running empty CM from command window

The generated database server image has the output re-routed to a log
file. It is therefore useful only for an Amos II server. This is not
practical during development or when one wants tolook at an archived
database.

To start a CM from scratch on the command line, use:

     runCM.cmd

Then you can load a specific database as a script, e.g.:

     Amos 1> < 'courses/dbt_summer06.osql';


3. CM TomCat application deployment
-----------------------------------

To execute all steps to install and start the CM as a TomCat
application call:

   deploy_tomcat.cmd

It will 1) stop TomCat 2) compile all Java code 3) copy all files to
where Tomcat needs it 4) start TomCat 5) compile all JSP code.

This should be all that is needed. Test is by typing into your web
browser the URL:

   http://localhost:8080/CourseManager

NOTICE that timing problems have been observed when starting Tomcat
through deploy_tomcat.cmd in one step. It may therefore be necessary
to deploy Tomcat in several steps instead.

2.1 Partial TomCat deployment steps

In case there are problems the following partial deployment steps are
available as separate command procedures:

compile.cmd           compile Java code
copycode.cmd          copy compiled java code to TomCat server   

The CM XYNTService Windows service can be manually controlled visiting
Control Panel - Administrative Tools - Services.

The TomCat service is controlled by a separate window. Each TomCat
application can be restarted manually by visiting the TomCat manager
window.

4. Backup
---------

To make a backup of the currently running CourseManager, execute 
unload("C:/AmosNT/jspAmos/Applications/CourseManager/courses/dbt_summer06_unload.osql");
in the "Execute arbitrary AmosQL" page of CourseManager.
cvs (add + ) commit that file.
