pushd HashTable
javac ExinmaDemo.java
rm exinmademo.dmp
# ----------------------------------------------------------
# Index data with MYMAP and save it
# -----------------------------------------------------------
javaamos  -o "<'exinmademo.osql'; save 'exinmademo.dmp'; quit;"

# -----------------------------------------------------------
# Load MYMAP index info 
# -----------------------------------------------------------
javaamos exinmademo.dmp -L "exinma_test.lsp" -o "quit;"
popd


pushd KDTree
export CLASSPATH=kd.jar:$CLASSPATH
javac KDTreeIndex.java
rm kdtree.dmp
# ----------------------------------------------------------
# Index data with KDTree and save it
# -----------------------------------------------------------
javaamos  -o "<'kdtree.osql'; save 'kdtree.dmp'; quit;"

# -----------------------------------------------------------
# Load KDTree index info 
# -----------------------------------------------------------
javaamos  kdtree.dmp  -o "quit;"
popd

# -----------------------------------------------------------
# Linear Hashing
# -----------------------------------------------------------
pushd LinearHashingDLL
pushd  ../../../system/MVC/linh/linhdll
make
popd

rm linh.dmp
# -----------------------------------------------------------
# Linear Hashing as a shared object
# -----------------------------------------------------------
amos2  -o "<'test_dll.osql'; save 'linh.dmp'; quit;"

# -----------------------------------------------------------
# Reload Linear Hashing
# -----------------------------------------------------------
amos2  linh.dmp -o "quit;"
popd


# -----------------------------------------------------------
# Main memory BTree
# -----------------------------------------------------------
pushd BT
pushd  ../../../system/MVC/BT/BTDLL
make
popd

rm bt.dmp
# -----------------------------------------------------------
# Main memory BTree as a DLL
# -----------------------------------------------------------
amos2  -o "<'bt.osql'; save 'bt.dmp'; quit;"

# -----------------------------------------------------------
# Reload BTree
# -----------------------------------------------------------
amos2  bt.dmp -o "quit;"
popd


# -----------------------------------------------------------
# XTree as dynamic library
# -----------------------------------------------------------
pushd XT
pushd  ../../../system/MVC/xtree
make
popd

IF EXIST xt.dmp DEL xt.dmp
# ----------------------------------------------------------
# Index data , test saving all xtrees 
# -----------------------------------------------------------
amos2  -o " <'regress.osql'; save 'xt.dmp'; quit;"

# -----------------------------------------------------------
# Load xtrees from database image and drop some of them
# -----------------------------------------------------------
amos2 xt.dmp -o "drop_index('ptest1', 'fv'); drop_index('ptest2', 'fv'); drop_index('ptest3', 'fv'); save 'xt.dmp'; quit; "


# --------------------------------------------------------------
# Load xtrees from db image and test rewrite
# --------------------------------------------------------------
amos2 xt.dmp -o "load_amosql('similarity_test.osql');load_amosql('knn_test.osql'); save 'xt.dmp'; quit;"


# --------------------------------------------------------------
# Drop all xtrees from db image and test rewrite
# --------------------------------------------------------------
amos2 xt.dmp -o "drop_index('pictureFeatures', 'features'); load_amosql('similarity_test.osql'); load_amosql('knn_test.osql');quit;"


popd


