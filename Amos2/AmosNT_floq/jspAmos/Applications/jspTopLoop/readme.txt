1. Download TomCat from http://tomcat.apache.org/

2. Make sure environment variables set:

    CATALINA_HOME set to home directory of TomCat and
    AMOS_HOME set to home directory of Amos II
    PATH includes directory %AMOS_HOME%\bin 
    CLASSPATH includes location of javaamos.jar 

3. Compile and launch the application in one step with:

   launch.cmd

----------------------------------------------------------------------
The launcher does the following:

4. Copy Amos II system files:

    JavaAmos API:

    copy "%AMOS_HOME%\bin\javaamos.jar" "%CATALINA_HOME%\shared\lib"

    The empty embedded database:

    copy %AMOS_HOME%\bin\amos2.dmp WEB-INF

5. Restart TomCat

   This will load the javaamos.jar file into Tomcat


6. To compile Java utility code used in .jsp files, execute command: 
      compile.cmd


7. To deploy application after Java compilation or changes to .jsp files:

   7.1 stop the application from TomCat's manager window, 
       http://localhost:8080/manager/html

   7.2 Copy this entire directory to
       %catalina_home%/webapps

   7.3 Start the application from TomCat's manager window.
