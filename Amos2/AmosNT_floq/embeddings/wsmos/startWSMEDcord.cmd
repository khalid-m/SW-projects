pushd "%AMOS_HOME%"wsmed
call setup
call mkdmp
"java" JavaAMOS wsmed.dmp -o "register('cod');load_lisp('src/lisp/ff_receive_dynamic_co.lsp'); load_lisp('src/lisp/pardecom_ff_dynamic_co.lsp'); save 'wsmed.dmp'; listen();"
popd