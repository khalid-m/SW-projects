@echo off

java -cp %AMOS_HOME%wrappers\twitter\streamfilter\classes;%CLASSPATH%;%AMOS_HOME%wrappers\twitter\streamfilter\lib\twitter4j-2.0.10.jar;%AMOS_HOME%wrappers\twitter\streamfilter\lib\commons-codec-1.3_1.jar;%AMOS_HOME%wrappers\twitter\streamfilter\lib\commons-httpclient-3.1_1.jar;%AMOS_HOME%wrappers\twitter\streamfilter\lib\commons-logging-1.1.1.jar;%AMOS_HOME%wrappers\twitter\streamfilter\lib\javaamos.jar;%AMOS_HOME%wrappers\twitter\streamfilter\lib\json.jar JavaAMOS twitter.dmp



