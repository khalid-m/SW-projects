@echo off


java -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes" JavaAMOS "%AMOS_HOME%\sard\SARD2\sard2.dmp" -O %AMOS_HOME%/sard/SARD2/regress/egov2.amosql -o "quit;" 


GOTO END


:END
