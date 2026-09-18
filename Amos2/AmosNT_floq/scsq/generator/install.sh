pushd ..
cp config/spconfig-$HOSTNAME.osql osql/spconfig.osql
make scsq
popd
cp src/config-linux.osql src/config.osql
../../bin/scsq.exe -i ../../lsp/init.lsp -o "loadsystem('../osql','sc.osql'); loadsystem('src','master.osql'); save '../../bin/generator.dmp'; quit;"

