echo Making image...
pushd ../bin
export releasing=1
source install.sh
popd
make clean
make

echo Removing old zip ...
rm ssdm_Linux.zip

pushd ..

echo Building new ssdm_Linux.zip ...
zip SQoND/ssdm_Linux bin/amos2 bin/libamos.so bin/libJavaAmos.so bin/ssdm.sh bin/ssdm.dmp bin/ssdm.so bin/bt.so bin/xt.so bin/javaamos.jar jarlib/mysql-connector-java-5.1.6-bin.jar SQoND/storage/sql/master.osql SQoND/storage/sql/run.sh SQoND/storage/sql/settings.osql SQoND/storage/sql/setup.osql SQoND/storage/sql/setup.sh SQoND/storage/sql/setup.sql SQoND/storage/sql/sql-store.lsp SQoND/storage/sql/sql-store-utils.lsp SQoND/storage/sql/bulkloader/bulkloader.osql SQoND/storage/sql/bulkloader/dumper.lsp SQoND/storage/sql/bulkloader/settings.osql SQoND/example/talk.sparql SQoND/example/talk.ttl SQoND/example/callinDemo/callinDemo.c

popd