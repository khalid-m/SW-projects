call installVortex.cmd
pushd extensions\csvwrapper
msdev csvwrapper.dsw /make
popd
pushd extensions\numtuples
msdev numtuples.dsw /make
popd
pushd bin
svali -O "../extensions/signatures.osql" -o "save 'myimage.dmp'; quit;"
svali myimage.dmp -O "../test/master.osql" -o "quit;"
popd

