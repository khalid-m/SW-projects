@echo --------------------------------------------------------------------
@echo Bench mark for Xtree index
@echo Function abenchmark
@echo Input - Indextype (Xtree/Mbtree)
@echo       - Number of records  
@echo       - Dimension ex. 12
@echo The first line will generate random data and save it to dmp file.
@echo Which can be used later on
@echo ----------------------------------------------------------------------
%AMOS_HOME/%amos2  -o " <'bench_xtree.osql'; set volData() = 2000000; gen_data(volData(), 20); save 'test.dmp';quit;"
%AMOS_HOME/%amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 4);quit;"
%AMOS_HOME/%amos2  test.dmp -o "abenchmark('MBTREE',volData(), 4);quit;"

@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 4);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 6);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 8);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 2);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 12);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 14);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 16);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 18);quit;"
@echo %AMOS_HOME/%amos2  test.dmp -o "abenchmark('Xtree',volData(), 20);quit;"
