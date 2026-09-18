@echo off
if not exist testdata mkdir testdata
if not exist realdata\target mkdir realdata\target
if not exist testdata\skew (
mkdir testdata\skew
mkdir testdata\skew\1
mkdir testdata\skew\2
)
java -cp "%CLASSPATH%;%AMOS_HOME%\logdir\lib\logdir.jar;%AMOS_HOME%\bin\javascsq.jar" JavaSCSQ scsq.dmp -o "< 'init.osql'; save '..\..\bin\hlund.dmp'; quit;"
