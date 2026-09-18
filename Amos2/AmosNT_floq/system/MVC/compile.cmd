pushd ..\C
gmake -f mkparsers.mak
popd
pushd adll
msdev adll.dsw /make
popd
pushd amos2
msdev amos2.dsw /make
popd
pushd alisp
msdev alisp.dsw /make
popd


