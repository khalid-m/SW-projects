amos2  -o " <'bench_xtree.osql'; set volData() = 1000000; gen_data(volData(), 20); save 'test.dmp';quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 2);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 2);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 4);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 4);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 6);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 6);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 8);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 8);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 10);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 10);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 12);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 12);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('XT',volData(), 14);quit;"
amos2  test.dmp -o "register_exindextype('XT', 'C:xt', FALSE); abenchmark('MBTREE',volData(), 14);quit;"






