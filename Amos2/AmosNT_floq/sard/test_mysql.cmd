call compile.cmd
call mkdmp.cmd

call javaamos ../bin/amos2.dmp example.osql

"%JDK%\bin\java"  -classpath "../bin/javaamos.jar;classes;src;%AMOS_HOME%/bin/sward.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar;%CLASSPATH%;%AMOS_HOME%/wrappers/RDF/classes/" JavaAMOS sard.dmp regress/test_mysql.amosql

call javaamos ../bin/amos2.dmp regress/testloaded_mysql.amosql