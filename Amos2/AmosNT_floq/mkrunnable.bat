rem @echo off
set releasing=1
set mexi=1
pushd embeddings\php
call compile.cmd
popd
echo Making image...
pushd bin
call install
popd
pushd embeddings\php
call compile.cmd
popd
echo Removing old amos2.zip ...
del amos2.zip

echo Building new amos2.zip ...
zip amos2 README bin\README bin\javaamos.dll bin\amos2.exe bin\bt.dll bin\xt.dll bin\amos2.dmp bin\alisp.dmp bin\alisp.exe bin\amos2.lib bin\amos2.dll bin\javaamos.bat bin\javaamos.jar demo\wcdata.amosql demo\tutorial.amosql demo\Foreign.java demo\mydbdef.amosql demo/foreign.c demo/myCdbdef.amosql demo/README doc\tut.pdf doc\javaapi.pdf doc\alisp.pdf doc/amos_users_guide.html C/callin.h C/callout.h C/storage.h C/environ.h C/complex.h C/alisp.h C/main.c demo/clientdemo.c demo/amosclient.vcxproj demo/myForeign.vcxproj demo/ClientDemo.java demo/foreign.c demo/myCdbdef.amosql demo/README bin/php_amos.dll embeddings/PHP/readme.txt embeddings/PHP/ZendLicense.txt embeddings/PHP/htdocs/*


:END
