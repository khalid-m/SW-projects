pushd osql
..\..\wrappers\ROOTwrap\ROOTwrap.exe rootwrap.dmp < "master.current.osql"
..\..\wrappers\ROOTwrap\ROOTwrap.exe rootwrap.dmp < "master.current.limited.osql"
..\..\wrappers\ROOTwrap\ROOTwrap.exe rootwrap.dmp < "master.current.naive.osql"
..\..\wrappers\ROOTwrap\ROOTwrap.exe rootwrap.dmp < "master.current.basic.osql"
..\..\wrappers\ROOTwrap\ROOTwrap.exe rootwrap.dmp < "master.current.default.osql"
popd
