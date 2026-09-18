pushd amosjdbc
javac *.java
popd
javac JdbcTest.java
jar -cf ../../bin/amosjdbc.jar amosjdbc/*.class


