if exist scsq.dmp del scsq.dmp
if exist ..\bin\scsq.dmp del ..\bin\scsq.dmp
copy config\spconfig-win.osql osql\spconfig.osql
..\bin\scsq -i ..\lsp\init.lsp -o "loadsystem('osql','sc.osql'); save '../bin/scsq.dmp'; quit;"
