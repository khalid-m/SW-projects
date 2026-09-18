
BINDIR = ../../bin
JAVA_HOME = /usr/jdk_base
JDKLDIR = $(JAVA_HOME)/lib
CCOMP = xlc_r
LINKER = /usr/ibmcxx/bin/makeC++SharedLib -p 235
RTOS = aix
CFLAGS =  -I../../C -I../include -I../C -c -M -I. -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/aix -DUNIX=1 -DAIX=1

all: $(BINDIR)/JavaAmos.o

$(BINDIR)/JavaAmos.o: $(BINDIR)/libamos.a JavaCallout.o JavaCallin.o
	$(LINKER) -O2 -brtl -o$(BINDIR)/libJavaAMOS.so JavaCallin.o JavaCallout.o $(BINDIR)/libamos.a  -L$(JDKLDIR)/$(RTOS)/native_threads/ -L$(JDKLDIR)/$(RTOS)/classic/ -L$(JDKLDIR)/$(RTOS)/ -ljava -lm -lnsl 

%.o: %.cpp
	$(CCOMP) $(CFLAGS) -c $< 

JavaCallin.o: ../C/JavaCallin.cpp
	$(CCOMP) $(CFLAGS) ../C/JavaCallin.cpp

JavaCallout.o: ../C/JavaCallout.cpp
	$(CCOMP) $(CFLAGS) ../C/JavaCallout.cpp