pushd osql
./../../bin/rootwrap ../../wrappers/ROOTWrap/rootwrap.dmp < "master.current.hagrid.osql"
./../../bin/rootwrap ../../wrappers/ROOTWrap/rootwrap.dmp < "master.current.limited.osql"
./../../bin/rootwrap ../../wrappers/ROOTWrap/rootwrap.dmp < "master.current.naive.osql"
./../../bin/rootwrap ../../wrappers/ROOTWrap/rootwrap.dmp < "master.current.basic.osql"
./../../bin/rootwrap ../../wrappers/ROOTWrap/rootwrap.dmp < "master.current.default.osql"
popd
