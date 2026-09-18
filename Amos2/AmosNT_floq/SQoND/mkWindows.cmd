echo Making image...
pushd ..\bin
set releasing=1
call install
popd

pushd storage\matWrapper
call compile
popd

echo Removing old zip ...
rm ssdm_Windows.zip

pushd ..

echo Building new ssdm_Linux.zip ...
zip SQoND/ssdm_Windows bin/amos2.exe bin/amos2.dll bin/JavaAmos.dll bin/ssdm.cmd bin/ssdm.dmp bin/ssdm.dll bin/bt.dll bin/xt.dll bin/javaamos.jar bin/matWrapper.dll jarlib/mysql-connector-java-5.1.6-bin.jar SQoND/storage/sql/master.osql SQoND/storage/sql/run.sh SQoND/storage/sql/settings.osql SQoND/storage/sql/setup.osql SQoND/storage/sql/setup.sh SQoND/storage/sql/setup.sql SQoND/storage/sql/sql-store.lsp SQoND/storage/sql/sql-store-utils.lsp SQoND/storage/sql/bulkloader/bulkloader.osql SQoND/storage/sql/bulkloader/dumper.lsp SQoND/storage/sql/bulkloader/settings.osql SQoND/example/talk.sparql SQoND/example/talk.ttl SQoND/example/callinDemo/callinDemo.c SQoND/example/callinDemo/callinDemo.dsp SQoND/example/callinDemo/callinDemo.dsw SQoND/Embeddings/MATLAB/readme.txt SQoND/Embeddings/MATLAB/test.cmd SQoND/Embeddings/MATLAB/MATLAB/msl.dll SQoND/Embeddings/MATLAB/MATLAB/msl.h SQoND/Embeddings/MATLAB/MATLAB/*.m SQoND/storage/matWrapper/test/test.* SQoND/storage/matWrapper/master.lsp SQoND/storage/matWrapper/readme.txt 

popd