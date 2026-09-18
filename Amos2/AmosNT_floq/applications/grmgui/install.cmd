javac -classpath %AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\jarlib\appframework-1.0.3.jar;%AMOS_HOME%\jarlib\swing-worker-1.1.jar;Java\src -d Java\build\classes Java\src\grm\GRMApp.java

mkdir Java\build\classes\grm\resources
copy Java\src\grm\resources\*.* Java\build\classes\grm\resources

call mkdmp