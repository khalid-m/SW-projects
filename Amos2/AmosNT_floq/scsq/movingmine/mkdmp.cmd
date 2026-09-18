if exist css.dmp del css.dmp
scsq.exe -i ..\..\lsp\init.lsp -o "loadsystem('../osql','sc.osql'); loadsystem('src', 'css_core.osql'); save '../../bin/css.dmp'; quit;"
