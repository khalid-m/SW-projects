pushd MBTree\regress
call wrappertest.bat
popd
pushd JDBC\regress
call wrappertest.bat
popd
rem pushd ODBC\regress
rem call wrappertest.bat
rem popd
pushd RDF\regress
call wrappertest.cmd
popd
pushd ROOTWrap
call testmaster.cmd
popd