@echo off


"%JDK%\bin\java" -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes;" JavaAMOS "%AMOS_HOME%\sard\sard_new\sard.dmp" %AMOS_HOME%/sard/sard_new/regress/egov_setup_new.amosql -o "quit;" 


GOTO END


:END
