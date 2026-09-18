@echo off
call checkenv

IF "%EDUTELLA_HOME%" == "" goto noedutellahome
goto top 

:noedutellahome
echo Please set environment variable EDUTELLA_HOME first!
goto end

:top
set NSPORT=%1
rem set PROVIDERSETUP=%2
rem set PATH=%AMOS_HOME%\bin;%PATH%

echo %NSPORT%
echo %AMOS_HOME%
rem echo %PROVIDERSETUP%
echo %PATH%

del pselo.dmp
del peer.dmp

call mkdmp
call compile

copy %AMOS_HOME%\bin\*.dll .

amos2 -o "nameserverport(cast(atoi(getenv('NSPORT')) as integer));" -l "(unwind-protect (reval@nameserver '(quit))(quit))" 
amos2 -o "nameserverport(cast(atoi(getenv('NSPORT')) as integer));" -l "(REGISTER-INIT-FORM '(TRACE-CINTERFACE T))(setq _debugging_ t) (setq _batch_ t) (setq *connectionless* t)" -o "save 'peer.dmp'; quit;"

start "PSELO" server.cmd

rem Wait 20 sec if and only if there are no IP address 1.1.1.1. Ugly!!!
echo Sleep for 20 sec...
PING 1.1.1.1 -n 20 -w 1000 >NUL

rem sleep 30

rem initializeAmos() with PEER.dmp and .dll files from dir %AMOS_HOME%\embeddings\Edutella?
"%java_home%java" -classpath .;%AMOS_HOME%\bin\javaamos.jar;classes\PSELO.jar;%EDUTELLA_HOME%\ea.jar net.jxta.edutella.peer.PeerServiceRegistry file:Configuration.rdf log\peer.log

:end

