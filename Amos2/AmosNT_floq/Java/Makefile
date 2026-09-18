D=:
ifeq ($(OS),Windows_NT)
D=;
endif
LIBRARIES = lib/jbcl.jar$(D)lib/jcchart.jar$(D)lib/jctable.jar$(D)lib/jgl3.1.0.jar
SOURCES = callin/*.java callout/*.java Goovi/*.java JavaAMOS.java SWARD.java
TESTSOURCES = AmosDemo.java JavaTest.java Foreign.java EvalTest.java trazan.java trazan2.java localThreads.java
TESTBINS = AmosDemo.class JavaTest.class Foreign.class EvalTest.class trazan.class trazan2.class

LOCALCLASSPATH = $(AMOS_HOME)/bin/javaamos.jar$(D)$(AMOS_HOME)/wrappers/JDBC/$(D).
LOCALLIBRARYPATH = -d32 -Djava.library.path=$(AMOS_HOME)/bin

all: $(SOURCES)
	cd classdir && jar xf ../lib/goovilib.jar
	javac -d classdir -classpath "$(LIBRARIES)" $(SOURCES)
	cd classdir && jar cf $(AMOS_HOME)/bin/javaamos.jar *

test: $(AMOS_HOME)/bin/javaamos.jar $(TESTSOURCES)
	javac $(TESTSOURCES) -cp .
	javaamos -O javadefs.osql -o "save 'java.dmp'; quit;"
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) AmosDemo $(AMOS_HOME)/bin/amos2.dmp
	javaamos java.dmp -O javatest.osql
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) JavaTest 
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) localThreads java.dmp 1000 10 niota
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) localThreads java.dmp 1 1000 cciota
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) localThreads java.dmp 2 1 zbg
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) trazan java.dmp 100
	java $(LOCALLIBRARYPATH) -classpath $(LOCALCLASSPATH) trazan2 java.dmp 4 10

test2:	$(AMOS_HOME)/bin/javaamos.jar $(TESTSOURCES)
	javac -classpath . $(TESTSOURCES)

ifndef NSPORT
	javaamos -o "<'javadefs.osql'; save 'java.dmp'; quit;"
else
	javaamos -o "nameserverport($(NSPORT)); <'javadefs.osql'; save 'java.dmp'; quit;"
endif

	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) AmosDemo $(AMOS_HOME)/bin/amos2.dmp
	javaamos java.dmp -O javatest.osql
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) JavaTest 
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) localThreads java.dmp 1000 10 niota
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) localThreads java.dmp 1 1000 cciota
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) localThreads java.dmp 2 1 zbg
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) trazan java.dmp 100
	java $(LOCALLIBRARYPATH) -cp $(LOCALCLASSPATH) trazan2 java.dmp 4 10

clean:
	rm $(AMOS_HOME)/bin/javaamos.jar
