WSMED_EMB=$(AMOS_HOME)/embeddings/wsmos/WEB-INF/
WSMED_EMB_LIB=$(WSMED_EMB)/lib/

COMPILE_CLASSPATH=$(WSMED_EMB)/classes:$(WSMED_EMB_LIB)/activation.jar:$(WSMED_EMB_LIB)/axis.jar:$(WSMED_EMB_LIB)/axis-ant.jar:$(WSMED_EMB_LIB)/commons-discovery-0.2.jar:$(WSMED_EMB_LIB)/commons-logging-1.0.4.jar:$(WSMED_EMB_LIB)/jaxrpc.jar:$(WSMED_EMB_LIB)/log4j-1.2.8.jar:$(WSMED_EMB_LIB)/mail.jar:$(WSMED_EMB_LIB)/saaj.jar:$(WSMED_EMB_LIB)/wsdl4j-1.5.1.jar:$(WSMED_EMB_LIB)/xercesImpl.jar:$(WSMED_EMB_LIB)/xml-apis.jar:$(WSMED_EMB_LIB)/servlet-api.jar:$(WSMED_EMB_LIB)/common/lib/jasper-runtime.jar:$(WSMED_EMB_LIB)/jsp-api.jar:$(AMOS_HOME)/bin/javaamos.jar:

DUMPLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin/
export WSDL_HOME:=$(AMOS_HOME)/wsmed/wsdl/

all: compile dump

compile:
	cd WEB-INF/src && javac -classpath $(COMPILE_CLASSPATH) -d ../classes server/*.java
	cd WEB-INF/src && javac -classpath $(COMPILE_CLASSPATH) -d ../classes wsdlcreator/*.java

dump:
	@echo ${WSDL_HOME}
	java $(DUMPLIBRARYPATH) -classpath $(COMPILE_CLASSPATH) JavaAMOS amos2.dmp WEB-INF/src/amosql/server.osql
	java $(DUMPLIBRARYPATH)  $(DUMPLIBRARYPATH) -classpath $(COMPILE_CLASSPATH) JavaAMOS amos2.dmp WEB-INF/src/amosql/client.osql