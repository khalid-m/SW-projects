@echo off

rem call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp %1 %2 %3 %4 %5

::if  "%1" EQU "norewrite" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp  -o "load_lisp('src/Lisp/gql.lsp'); load_amosql('src/AmosQL/btNoRewrite.amosql');") else (if  "%1" EQU "clientNLJ" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp -o "load_lisp('src/Lisp/gql.lsp'); load_amosql('src/AmosQL/bt.amosql');"))

::if  "%1" EQU "clientcaching" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp  -o "load_amosql('src/AmosQL/clientCaching.amosql'); load_lisp('src/Lisp/gql_clientCaching.lsp'); load_amosql('src/AmosQL/bt.amosql');")

::if  "%1" EQU "clienthj" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp  -o "load_amosql('src/AmosQL/hj.amosql'); load_lisp('src/Lisp/gql.lsp'); load_amosql('src/AmosQL/bt.amosql'); ")

::if  "%1" EQU "clientnlj" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp  -o "load_amosql('src/AmosQL/nlj.amosql'); load_lisp('src/Lisp/gql.lsp'); load_amosql('src/AmosQL/bt.amosql'); ")

::if  "%1" EQU "" (call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp  -o "load_amosql('src/AmosQL/hj.amosql'); load_lisp('src/Lisp/gql.lsp'); load_amosql('src/AmosQL/bt.amosql'); ")

call javaamos %AMOS_HOME%/wrappers/BigTable/bigtable.dmp %1 %2 %3 %4 %5