mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo"
copy  %AMOS_HOME%\sard\sard_new\compile.cmd "%AMOS_HOME%\sard\sard_new\SARD_demo\compile.cmd"
copy  %AMOS_HOME%\sard\sard_new\mkdmp.cmd "%AMOS_HOME%\sard\sard_new\SARD_demo\mkdmp.cmd"
copy  %AMOS_HOME%\sard\sard_new\install.cmd "%AMOS_HOME%\sard\sard_new\SARD_demo\install.cmd"
copy  %AMOS_HOME%\sard\sard_new\sard.cmd "%AMOS_HOME%\sard\sard_new\SARD_demo\sard.cmd"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src"
copy  %AMOS_HOME%\sard\sard_new\src\*.amosql "%AMOS_HOME%\sard\sard_new\SARD_demo\src\*amosql"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src\AmosQL"
copy  %AMOS_HOME%\sard\sard_new\src\AmosQL\*.amosql "%AMOS_HOME%\sard\sard_new\SARD_demo\src\AmosQL\*.amosql"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src\classes"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src\Java"
copy  %AMOS_HOME%\sard\sard_new\src\Java\*.java "%AMOS_HOME%\sard\sard_new\SARD_demo\src\Java\*.java"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src\lsp"
copy  %AMOS_HOME%\sard\sard_new\src\lsp\*.lsp "%AMOS_HOME%\sard\sard_new\SARD_demo\src\lsp\*.lsp"

mkdir "%AMOS_HOME%\sard\sard_new\SARD_demo\src\lsp\sparql-lsp-parser"
copy  %AMOS_HOME%\lsp\sparql-lsp-parser\*.lsp "%AMOS_HOME%\sard\sard_new\SARD_demo\src\lsp\sparql-lsp-parser\*.lsp"

copy  %AMOS_HOME%\sard\sard_new\readme.txt "%AMOS_HOME%\sard\sard_new\SARD_demo\readme.txt"

copy  %AMOS_HOME%\sard\sard_new\regress\start_mysql.sql "%AMOS_HOME%\sard\sard_new\SARD_demo\start_mysql.sql"
copy  %AMOS_HOME%\sard\sard_new\regress\egovdb.cmd "%AMOS_HOME%\sard\sard_new\SARD_demo\egovdb.cmd"
copy  %AMOS_HOME%\sard\sard_new\regress\egov.sql "%AMOS_HOME%\sard\sard_new\SARD_demo\egov.sql"
copy  %AMOS_HOME%\sard\sard_new\regress\egovpopulate.osql "%AMOS_HOME%\sard\sard_new\SARD_demo\egovpopulate.osql"


