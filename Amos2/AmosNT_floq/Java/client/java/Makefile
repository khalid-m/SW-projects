LIBRARIES = jchart2d-3.2.2.jar
SOURCES = purejavaclient/*.java
CLASSDIR = classdir
LIBRARIES = jchart2d-3.2.2.jar;PureJavaClient.jar

LOCALCLASSPATH = $(AMOSHOME)/bin/javaamos.jar$(D)$(AMOSHOME)/wrappers/JDBC/$(D).
LOCALLIBRARYPATH = -Djava.library.path=$(AMOSHOME)/bin

all:
	javac -d $(CLASSDIR) $(SOURCES)
	cd classdir && jar cf ../lib/purejavaclient.jar *
	cd lib && javac -cp "$(LIBRARIES)" ../../bin/*.java