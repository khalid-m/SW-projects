How to install WSMED demo, WSBENCH, and course manager
======================================================
     
Here is an introduction about how to install the WSBENCH:

1. Make sure that the AmosNT has been installed correctly.

2. Download and install the software Wampserver
   purpose: Use Apache server of WampServer as our web service 

   Installation: download the software from
   http://user.it.uu.se/~udbl/software/WampServer2.0a.exe

3. Set environment variables:

   3.1 Set APACHE_HOME to the parent of the Wampserver home directory
   e.g. c:\WAMP

   3.2 Set WSDL_HOME to a WSDL directory in Wampserver
   %APACHE_home%\www\wsdl

4. Load the Berlin Benchmark dataset

   Open MySQL console input your password and then pass in the
   following SQL commmand under mysql>
        source C:\AmosNT\wsmed\WSBench\MySQL_Dataset\Berlin_Benchmark.sql 

   If you did not install AmosNT under C:\, then you have to find the
   correct directory for the file Berlin_Benchmark.sql.

5. Install xyntservice
   5.1 Download xyntservice from 

       http://user.it.uu.se/~udbl/software/XYNTServiceProject.zip

   5.2 Unzip XYNTServiceProject.zip and place under
       C:\Program1\XYNTServiceProject

   5.3 Copy %AMOS_HOME%\wsqs\XYNTService.ini to C:\Program1\XYNTService.ini

   5.4 Start the xyntservice in C:\Program1\XYNTService by runnin
        XYNTService -i

6. Edit entries with localhost with udbl2.it.uu.se in following files:
  6.1 %AMOS_HOME%\embeddings\Javascript\CourseManager\WEB-INF\web.xml 
  6.2 %AMOS_HOME%\embeddings\Javascript\CourseManager\scripts\SoapClient.js
  6.3 %AMOS_HOME%\wsmed\WSBench\Soap_Client.js
  6.4 %AMOS_HOME%\wsmed\WSBench\WEB-INF\web.xml

7. Copy WSWED, CourseManager and WSBench to the Apache home directory:
   %AMOS_HOME%\wsqs\copycode.cmd

8. Start the services with:
   %AMOS_HOME%\wsqs\wsqs.cmd
  

9. Limited process restarts:

NOTICE: With the current method XYNTService will NOT restart processes
like the amos name server, the database server, the wsmed server,
etc. when there is a crash. Everything has to be cleaned up manually,
which can be problematic since you don't know what processes are
up. E.g. there are many java processes running you don't know which
ones are services.

XYNT is used ONLY for stalling the services, not for restarting
separate processes.

