pushd ..\..\wrappers\RDF
call compile
popd
javac *.java
jar -uf ../../bin/RDFAmos.jar *.class

