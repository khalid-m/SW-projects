LOCALLIBRARYPATH="-Djava.library.path="$AMOS_HOME/bin/
COMPILE_CLASSPATH=classes:$AMOS_HOME/bin/javaamos.jar::classes

echo --------------------------------------------------
echo Testing ff_applyp...............
echo --------------------------------------------------

java $LOCALLIBRARYPATH -classpath $COMPILE_CLASSPATH JavaAMOS wsmed.dmp -O src/amosql/testcoroutine1.amosql
amos2 -O src/amosql/testcoroutine4.amosql











