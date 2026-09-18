copy src\config-pc.osql src\config.osql
pushd ..
call compile
popd
..\..\bin\scsq.exe -i ..\..\lsp\init.lsp -o "loadsystem('../osql','sc.osql'); loadsystem('src','master.osql'); save '../../bin/generator.dmp'; quit;"
