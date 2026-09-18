@echo off
pushd "%AMOS_HOME%/"wsmed
call setup
"java" -Xms256m -Xmx1024m JavaAMOS wsmed.dmp  -o "load_lisp('src/lisp/ff_receive_dynamic_mixed_co.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_mixed_co.lsp'); register('P%1'); load_amosql('WSBench/src/amosql/WSBench_wsmed.amosql'); listen();"
popd