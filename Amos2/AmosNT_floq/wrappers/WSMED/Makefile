WSMED_ROOT = $(AMOS_HOME)/wrappers/WSMED/
WSMED_LIB = $(WSMED_ROOT)/lib

DUMPLIBRARYPATH = -Djava.library.path=$(AMOS_HOME)/bin/
DUMPCLASSPATH = classes:$(WSMED_LIB)/saxon8-dom.jar:$(WSMED_LIB)/xercesImpl.jar:$(WSMED_LIB)/jdom.jar:$(WSMED_LIB)/qname.jar:$(WSMED_LIB)/wsdl4j.jar:$(WSMED_LIB)/castor-1.0.2-xml.jar:$(WSMED_LIB)/castor-1.0.2.jar:$(WSMED_LIB)/saaj-api.jar:$(WSMED_LIB)/saaj-impl.jar:$(WSMED_LIB)/jaxp-api.jar:$(WSMED_LIB)/jax-qname.jar:$(WSMED_LIB)/jaxm-api.jar:$(WSMED_LIB)/saxon8.jar:$(WSMED_LIB)/saxon8-xpath.jar:$(WSMED_LIB)/commons-logging.jar:$(AMOS_HOME)/bin/javaamos.jar

all: compile dump

compile:
	rm -rf ./classes
	mkdir classes
	javac -Xlint -classpath $(WSMED_LIB)/saxon8-dom.jar:$(WSMED_LIB)/xercesImpl.jar:$(WSMED_LIB)/jdom.jar:$(WSMED_LIB)/qname.jar:$(WSMED_LIB)/wsdl4j.jar:$(WSMED_LIB)/castor-1.0.2-xml.jar:$(WSMED_LIB)/saaj-api.jar:$(WSMED_LIB)/saaj-impl.jar:$(WSMED_LIB)/jaxm-api.jar:$(WSMED_LIB)/jaxp-api.jar:$(WSMED_LIB)/servlet.jar:$(WSMED_LIB)/jax-qname.jar:$(WSMED_LIB)/saxon8.jar:$(WSMED_LIB)/saxon8-xpath.jar:$(AMOS_HOME)/bin/javaamos.jar:$(WSMED_LIB)/castor-1.0.2.jar:$(WSMED_LIB)/jndi_1.2.1.jar:$(WSMED_LIB)/cglib-full-2.0.2.jar: -d $(WSMED_ROOT)/classes $(WSMED_ROOT)/src/*.java

dump:
	java $(DUMPLIBRARYPATH) -classpath $(DUMPCLASSPATH) JavaAMOS amos2.dmp src/amosql/master.amosql