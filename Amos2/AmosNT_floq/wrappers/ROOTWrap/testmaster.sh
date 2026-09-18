# Compiling and testing ROOT wrapper under Linux
# First amos is installed and tested

rm ../../bin/amos2

pushd ../../system/Linux
make
popd
pushd ../../regress
make
popd

rm ../../bin/rootwrap
pushd C
rm amain.o
rm aleh_udfs.o
rm structs.o
make
popd
./mkdmp.sh
./regress.sh
pushd ../../aleh
./regress.current.sh
cd originalCcuts/CUT
rm TTreeCut.o
make
./runTreeCut.run
popd
