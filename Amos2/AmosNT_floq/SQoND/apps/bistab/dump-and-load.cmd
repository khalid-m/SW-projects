@echo off

IF "%1" == "" goto usage

pushd %AMOS_HOME%\SQoND\storage\sql\bulkloader

call ssdm "dumper.lsp" "../../matWrapper/master.lsp" -o "csvdump_ttl(%1,'%2');" -o "quit;"

call javaamos "bulkload.osql" -o "quit;"

popd

goto end

:usage

echo *** USAGE: dump-and-load ChunkSize Source
echo ***  ChunkSize - size of the array chunks in bytes
echo ***  Source - Turtle file to dump and load

:end