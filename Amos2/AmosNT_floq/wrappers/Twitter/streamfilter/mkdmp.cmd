IF EXIST twitter.dmp del twitter.dmp /q
java -cp classes;lib\commons-codec-1.3_1.jar;lib\commons-httpclient-3.1_1.jar;lib\commons-logging-1.1.1.jar;lib\javaamos.jar;lib\json.jar JavaAMOS "%AMOS_HOME%/bin\amos2.dmp" src/amosql/mkdmp.amosql






