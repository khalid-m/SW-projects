@echo off

java -ms64m -mx512m -cp "%AMOS_HOME%/bin/javaamos.jar;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/bin/RDFAmos.jar;%AMOS_HOME%wrappers/TopicMap/lib/swatm.jar;%AMOS_HOME%/wrappers/TopicMap/lib/tm4j-0.9.7.jar;%AMOS_HOME%/wrappers/TopicMap/lib/resolver.jar;%AMOS_HOME%/wrappers/TopicMap/lib/mango.jar;%AMOS_HOME%/wrappers/TopicMap/lib/commons-logging.jar" JavaAMOS swatm.dmp swatm.osql
