
if exist ..\bin\vsq.exe del ..\bin\vsq.exe
if exist ..\bin\vsq_labview.dll del ..\bin\vsq_labview.dll

pushd MVC
msdev vsqlib.dsw /make /rebuild
msbuild vsq.vcxproj /t:rebuild /v:minimal
popd
