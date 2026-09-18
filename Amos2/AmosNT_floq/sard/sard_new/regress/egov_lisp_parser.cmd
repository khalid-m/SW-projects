@echo off


java -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes" JavaAMOS "%AMOS_HOME%\sard\sard_new\sard.dmp" -O %AMOS_HOME%/sard/sard_new/regress/egov_extended.amosql -o "quit;" 


GOTO END


:END
