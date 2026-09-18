1. Set environment variables:
   1.1 Set APACHE_HOME to the parent of the wamp server home directory e.g. c:\WAMP
   1.2 Set WSDL_HOME to a WSDL directory in WAMP server %APACHE_home%\www\wsdl


2. To set up WSMOS database server with course organization information:

   call setup_wsmos.cmd

   It should be called only once. Otherwise stored data will be lost !!!

3. To start course maager:

   call start_coursemanager.cmd

/*To automatically start course manger with xynt,  start_coursemanager_xynt should be used*/


/* only needed once the coursemanger crashed */
To restore the backup of coursemanger:
call setup_wsmos_backup.cmd
Then continue the above step 3.

/*To upload a new course information*\

1. Create an osql file  %AMOS_HOME%\embeddings\Javascript\CourseManager\courses\course.osql that having the new course information.

2. call load_newcourse course.osql




