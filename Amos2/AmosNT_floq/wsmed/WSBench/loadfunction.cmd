pushd %AMOS_HOME%
java -cp .;jarlib\mysql-connector-java-5.1.6-bin.jar;%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\wsmed\WSBench\src\java; JavaAMOS -O wsmed/WSBench/src/amosql/WSBench.amosql
popd
