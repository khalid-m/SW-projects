pushd DenstreamMiner
set classpath=%classpath%;src/.
javaamos   ..\..\..\..\bin\amos2.dmp sql\with-database.osql -o "save 'database\Denstreamminer.dmp'; quit;"
popd

