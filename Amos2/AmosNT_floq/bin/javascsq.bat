@echo off

if "%1" NEQ "" goto run  
 java -cp "%CLASSPATH%;%AMOS_HOME%bin/javaamos.jar;%AMOS_HOME%/bin/javascsq.jar" JavaSCSQ scsq.dmp
goto end
:run
 java -cp "%CLASSPATH%;%AMOS_HOME%bin/javaamos.jar;%AMOS_HOME%/bin/javascsq.jar" JavaSCSQ %1 %2 %3 %4 %5 %6 %7 %8 %9
:end
