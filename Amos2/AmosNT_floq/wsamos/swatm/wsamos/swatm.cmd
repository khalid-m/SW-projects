@echo off

java -ms64m -mx512m -cp "%AMOS_HOME%/bin/javaamos.jar;%AMOS_HOME%/bin/sward.jar;lib/swatm.jar;lib/tm4j-0.9.7.jar;lib/resolver.jar;lib/mango.jar;lib/commons-logging.jar" JavaAMOS swatm.dmp 
