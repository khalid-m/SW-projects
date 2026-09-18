pushd ..\C
make -f demo.mak
make -f callout.mak
make -f remote.mak
make -f testcpp.mak
demo ..\bin\amos2.dmp 
callout ../bin/amos2.dmp ../C/callout.amosql
callout callout.dmp 
popd
start testnameserver
pushd ..\C
remote
testcpp ..\bin\amos2.dmp
popd





