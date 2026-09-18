pushd ..\..\..\bin
call install
popd
pushd ..\SCSQ-trie\Judy-1.0.5\src
call build
popd
call compile.cmd
copy hpt-rewrite.lsp ..\..\..\bin
copy hptrie.dll  ..\..\..\bin
