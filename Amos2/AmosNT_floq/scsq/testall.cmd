echo ----------------Testing SCSQ-LR ------------------
pushd ..\scsq\SCSQ-LR
call install.cmd
call test.cmd
popd
echo ----------------Testing Basic SCSQ ------------------
pushd ..\scsq
call test
popd
echo ----------------Testing CSS ------------------
pushd ..\scsq\css
call test
popd
echo ----------------Testing Linear Road ------------------
pushd ..\scsq\lr
call test
popd
echo ----------------Testing EZGen ------------------
pushd ..\scsq\generator
call test
popd
