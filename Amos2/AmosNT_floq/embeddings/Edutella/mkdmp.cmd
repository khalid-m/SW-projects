@echo off
call checkenv
pushd ..\..\wrappers\rdf
call compile
call mkdmp.cmd
popd

 "%java_home%java" -classpath "%CLASSPATH%;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/xmlAPIs.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar;%AMOS_HOME%\wrappers\rdf\classes" JavaAMOS %AMOS_HOME%\bin\rdfamos.dmp src/AmosQL/mkdmp.amosql



