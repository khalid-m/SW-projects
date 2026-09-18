WSMED_ROOT = $(AMOS_HOME)/wsmed
WSMED_LIB = $(WSMED_ROOT)/lib
LOCALCLASSPATH = .:$(WSMED_LIB)/xercesImpl.jar:$(WSMED_LIB)/jdom.jar:$(WSMED_LIB)/qname.jar:$(WSMED_LIB)/wsdl4j.jar:$(WSMED_LIB)/saaj-api.jar:$(WSMED_LIB)/jaxm-api.jar:$(WSMED_LIB)/jaxp-api.jar:$(WSMED_LIB)/servlet.jar:$(WSMED_LIB)/jax-qname.jar:$(AMOS_HOME)/bin/javaamos.jar:$(WSMED_LIB)/castor-1.0.2.jar:$(WSMED_LIB)/jndi_1.2.1.jar:$(WSMED_LIB)/cglib-full-2.0.2.jar

DUMPLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin/
DUMPCLASSPATH = $(AMOS_HOME)/bin/javaamos.jar:classes:$(WSMED_LIB)/xercesImpl.jar:$(WSMED_LIB)/jdom.jar:$(WSMED_LIB)/qname.jar:$(WSMED_LIB)/wsdl4j.jar:$(WSMED_LIB)/castor-1.0.2.jar:$(WSMED_LIB)/saaj-api.jar:$(WSMED_LIB)/jaxp-api.jar:$(WSMED_LIB)/jax-qname.jar:$(WSMED_LIB)/jaxm-api.jar

all: compile dump

compile:
	javac -Xlint -classpath $(LOCALCLASSPATH) -d $(WSMED_ROOT)/classes src/java/*.java
dump:
	java $(DUMPLIBRARYPATH) -classpath $(DUMPCLASSPATH) JavaAMOS amos2.dmp ./src/amosql/master.amosql