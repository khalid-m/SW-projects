if exist ..\bin\svali.* del ..\bin\svali.*
if exist svali.* del svali.*
pushd ..\scsq
call install
popd
pushd ..\validate\MVC
msdev MVC.dsw /make
cd svali_dll
msdev svali.dsw /make
popd