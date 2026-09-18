$(error This Makfile obsolete. Use AmosNT/system/Unix/Makefile!)

ifndef HOSTTYPE
 HOSTTYPE=i386
endif
ifeq ($(HOSTTYPE),x86_64)
HOSTTYPE=i386
endif
AMOSHOME=../..
SRC= JavaCallin.cpp JavaCallout.cpp

JAVA_INCLUDE=$(JAVA_HOME)/include
OBJDIR=./$(HOSTTYPE)
CFLAGS =  -I$(JAVA_INCLUDE)/linux -I$(JAVA_INCLUDE) -I$(AMOSHOME)/C \
-I$(AMOSHOME)/system/include -I$(AMOSHOME)/system/C -O2 -DUNIX=1 -DLINUX=1 -m32

BINDIR=$(AMOSHOME)/bin
CC = gcc

all: $(BINDIR)/javaamos.jar ../C/javaamos.c
	cc -O2  -rdynamic -o$(BINDIR)/javaamos -m32 ../C/javaamos.c $(OBJDIR)/getexename.o

$(BINDIR)/libJavaAmos.so: $(BINDIR)/libamos.a ../C/*.cpp
	cd ../C && $(CC) $(CFLAGS) -c $(SRC)
	cp ../C/*.o $(OBJDIR)
	g++ -m32 -O2 -shared -rdynamic -o$(BINDIR)/libJavaAmos.so $(OBJDIR)/JavaCallin.o $(OBJDIR)/JavaCallout.o $(BINDIR)/libamos.a $(AMOS_HOME)/bin/bt.so $(AMOS_HOME)/bin/xt.so -lm -lnsl -lpthread 

$(BINDIR)/javaamos.jar: $(BINDIR)/libJavaAmos.so
	cd ../../Java && gmake 
	cd ../../wrappers/JDBC && export CLASSPATH=../../bin/javaamos.jar:. && gmake
clean:
	rm ../C/JavaCallout.o ../C/JavaCallin.o $(BINDIR)/javaamos.jar $(BINDIR)/libJavaAmos.so
