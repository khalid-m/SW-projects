AMOSHOME=$(AMOS_HOME)
SRC= JavaSCSQ.cpp javascsqutils.c
OBJS = C/JavaSCSQ.o C/javascsqutils.o

JAVA_INCLUDE=$(JAVA_HOME)/include
OBJDIR=../../system/Unix/$(ARCHITECTURE)
SCSQDIR = $(AMOSHOME)/scsq
CFLAGS = -I$(JAVA_INCLUDE)/linux -I$(JAVA_INCLUDE) -I$(AMOSHOME)/C \
         -I$(AMOSHOME)/system/include -I$(AMOSHOME)/system/C \
         -I$(SCSQDIR)/include -O2 -DUNIX=1 -DLINUX=1 -m32

BINDIR=$(AMOSHOME)/bin
CC = gcc
CXX = g++

all: $(BINDIR)/javascsq.jar C/javascsq.c
	$(CC) -m32 -o $(BINDIR)/javascsq C/javascsq.c $(OBJDIR)/getexename.o

$(BINDIR)/libJavaSCSQ.so: $(BINDIR)/libamos.so
	cd C && $(CC) $(CFLAGS) -c $(SRC)
	$(CXX) -m32 -O2 -shared -o$(BINDIR)/libJavaSCSQ.so \
        $(AMOS_HOME)/system/C/JavaCallin.o $(AMOS_HOME)/system/C/JavaCallout.o $(OBJS) \
        $(BINDIR)/libamos.so $(AMOS_HOME)/bin/bt.so $(AMOS_HOME)/bin/xt.so $(SCSQDIR)/libscsq.a -lm -lnsl

$(BINDIR)/javascsq.jar: $(BINDIR)/libJavaSCSQ.so
	javac -classpath "../../bin/javaamos.jar" -d classes java/JavaSCSQ.java
	cd classes && jar cf ../../../bin/javascsq.jar *

clean:
	rm -f classes/JavaSCSQ.class $(BINDIR)/javascsq.jar
	rm -f $(BINDIR)/libJavaSCSQ.so
