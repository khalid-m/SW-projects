# ifndef JENA_HOME
#     quit:
# 	@echo "*******************************************************************************"
# 	@echo "* Please set environment variable JENA_HOME first!"
# 	@echo "*******************************************************************************"
# endif

TOPICMAPPATH=$(AMOS_HOME)/wrappers/TopicMap/
TOPICMAPLIB=$(TOPICMAPPATH)/lib/
LOCALCLASSPATH=.:$(TOPICMAPLIB)/tm4j-0.9.7.jar:$(TOPICMAPLIB)/resolver.jar:$(TOPICMAPLIB)/mango.jar:$(TOPICMAPLIB)/commons-logging.jar:$(CLASSPATH):classes:$(AMOS_HOME)/bin/sward.jar:$(AMOS_HOME)/bin/RDFAmos.jar
LOCALLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin

all: compile dump

compile:
	javac -classpath $(AMOS_HOME)/bin/javaamos.jar:$(TOPICMAPLIB)/tm4j-0.9.7.jar:$(TOPICMAPLIB)/resolver.jar:$(TOPICMAPLIB)/mango.jar:$(TOPICMAPLIB)/commons-logging.jar  -d $(TOPICMAPPATH)/classes $(TOPICMAPPATH)/src/TMWrapper.java
	cd classes && jar -cf $(TOPICMAPLIB)/swatm.jar *.class 

dump:
	cd classes && java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) SWARD amos2.dmp ../src/mkdmp.amosql

test:	compile dump
	java -ms64m -mx512m $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) SWARD TAmos.dmp regress/test.amosql