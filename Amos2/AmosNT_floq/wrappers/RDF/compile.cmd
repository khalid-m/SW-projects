@echo off
call checkenv
pushd src\Java
"%java_home%javac" -classpath "%AMOS_HOME%/bin/javaamos.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/xmlAPIs.jar;%JENA_HOME%/lib/commons-logging.jar;%JENA_HOME%/lib/icu4j.jar" -d ../../classes AmosStmt.java
popd
pushd classes
jar -cf ../../../bin/RDFAmos.jar *.class 
popd