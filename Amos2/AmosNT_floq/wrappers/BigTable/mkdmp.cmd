@echo off

::javaamos -o "loadsystem('src/AmosQL','master.amosql'); save 'bigtable.dmp'; quit;" 


javaamos -L src/Lisp/master.lsp -o "save 'bigtable.dmp'; quit;" 
