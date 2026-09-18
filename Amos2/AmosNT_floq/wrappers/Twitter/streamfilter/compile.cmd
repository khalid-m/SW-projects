
IF EXIST classes\*.class del classes\*.class /q

javac -Xlint -classpath lib\commons-codec-1.3_1.jar;lib\commons-httpclient-3.1_1.jar;lib\commons-logging-1.1.1.jar;%AMOS_HOME%/bin\javaamos.jar;lib\json.jar; -d classes src\JsonWrapper.java 