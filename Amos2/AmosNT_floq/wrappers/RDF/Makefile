ifndef JENA_HOME
quit:
@echo "***********************************************************************"
@echo "* Please set environment variable JENA_HOME first!"
@echo "***********************************************************************"
endif


MKDUMPCLASSPATH = $(AMOS_HOME)/bin/javaamos.jar:$(AMOS_HOME)/wrappers/RDF/classes
LOCALLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin
COMPILELASSPATH=$(AMOS_HOME)/bin/javaamos.jar:$(JENA_HOME)/lib/jena.jar:$(JENA_HOME)/lib/:$(JENA_HOME)/lib/xercesImpl.jar:$(JENA_HOME)/lib/xmlAPIs.jar:$(JENA_HOME)/lib/commons-logging.jar:$(JENA_HOME)/lib/icu4j.jar
export CLASSPATH=$(MKDUMPCLASSPATH)

all: compile dump

compile:
	cd src/Java && javac -classpath $(COMPILELASSPATH) -d ../../classes AmosStmt.java
	cd classes && jar -cf ../../../bin/RDFAmos.jar *.class

dump:
	javaamos src/AmosQL/mkdmp.amosql

test:   compile dump
	./RDFAmos.sh regress/test.amosql