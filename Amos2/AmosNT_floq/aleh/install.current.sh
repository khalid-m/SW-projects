rm ../bin/rootwrap
pushd ../wrappers/ROOTWrap/C
rm amain.o
rm aleh_udfs.o
rm structs.o
make
cd ..
./mkdmp.sh
popd
./mkdmp.current.sh
