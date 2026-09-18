pushd ..\..\..\bin
call install
popd
pushd Judy-1.0.5\src
call build
popd
call compile
