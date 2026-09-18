@echo off

java -cp "%CLASSPATH%;%AMOS_HOME%\logdir\lib\logdir.jar" JavaAMOS -o "loadsystem(getenv('amos_home')+'/logdir/src/AmosQL/','init.osql'); save 'logdir.dmp'; quit;"
