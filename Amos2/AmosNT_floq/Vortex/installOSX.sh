export no_source=1
pushd ../validate
./install.sh
popd

cp ../bin/amos2 binOSX
cp ../bin/amos2.dmp binOSX
cp ../bin/javaamos binOSX

cp ../bin/xt.so binOSX
cp ../bin/bt.so binOSX

cp ../bin/libJavaAmos.jnilib binOSX
cp ../bin/javaamos.jar binOSX

cp ../bin/svali.exe binOSX
cp ../bin/svali.dmp binOSX

binOSX/svali.exe -o "loadsystem('Sandvik','nov2012export.osql');"
