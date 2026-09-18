pushd HashTable
call javac ExinmaDemo.java
IF EXIST  exinmademo.dmp DEL exinmademo.dmp
@echo ----------------------------------------------------------
@echo Index data with MYMAP and save it
@echo -----------------------------------------------------------
@echo call javaamos  -o "<'exinmademo.osql'; save 'exinmademo.dmp'; quit;"

@echo -----------------------------------------------------------
@echo Load MYMAP index info 
@echo -----------------------------------------------------------
@echo call javaamos exinmademo.dmp -L "exinma_test.lsp" -o "quit;"
popd 


pushd KDTree
set CLASSPATH=%CLASSPATH%;kd.jar
call javac KDTreeIndex.java
IF EXIST  kdtree.dmp DEL kdtree.dmp
@echo ----------------------------------------------------------
@echo Index data with KDTree and save it
@echo -----------------------------------------------------------
call javaamos  -O "kdtree.osql" -o "save 'kdtree.dmp'; quit;"

@echo -----------------------------------------------------------
@echo Load KDTree index info 
@echo -----------------------------------------------------------
call javaamos  kdtree.dmp  -o "load_lisp('kdtree_test.lsp');quit;"
popd


pushd DB2_3rdEx
call javac *.java
IF EXIST  db2_3rd.dmp DEL db2_3rd.dmp
@echo ----------------------------------------------------------
@echo DB2_3rd Index data with KDTree and save it
@echo -----------------------------------------------------------
call javaamos  -O "lab3.osql" -o "save 'db2_3rd.dmp'; quit;"

@echo -----------------------------------------------------------
@echo DB2_3rd Load KDTree index info 
@echo -----------------------------------------------------------
call javaamos  db2_3rd.dmp  -o "cd('../KDTREE');load_lisp('kdtree_test.lsp');quit;"
popd

