@echo off

IF "%1" == "" goto usage

java -cp "%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\jarlib\sqljdbc4.jar" JavaAMOS amos2.dmp -o "set :chunksize = %1;" -O "setup_ms.osql" -o "quit;"

goto end

:usage

echo *** USAGE: setup ChunkSize
echo ***  ChunkSize - max number of bytes per chunk in the RDF store being setup

:end