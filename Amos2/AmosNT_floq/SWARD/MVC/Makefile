SWARD_ROOT = $(AMOS_HOME)/SWARD/
C_PATH =  $(SWARD_ROOT)/src/C
JAVA_INCLUDE=$(JAVA_HOME)/include
LDFLAGS =-lm -lnsl
BINDIR=$(AMOS_HOME)/bin
SYSTEMDIR=$(AMOS_HOME)/system/
LINUXDIR=$(SYSTEMDIR)/Linux
INCLUDE_DIR=-I$(AMOS_HOME)/C/SPO -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/include/ -I$(AMOS_HOME)/C/
OBJDIR =$(LINUXDIR)/i386/

all:
	cd $(C_PATH) && gmake
	cc -o$(BINDIR)/sward -m32 $(C_PATH)/sward_exec.c $(SYSTEMDIR)/C/getexename.o

	gcc -m32 -O2 -c $(C_PATH)/sparqlUtils.c $(INCLUDE_DIR) $(C_PATH)/lexSparQL.c $(C_PATH)/SPO/sparqlMain.c $(C_PATH)/sparqlMemory.c $(C_PATH)/sparqlparser_tab.c $(C_PATH)/sward_linux.c

	g++ -m32 -O2 -shared ./*.o -o$(BINDIR)/libSWARD.so $(OBJDIR)/JavaCallin.o $(OBJDIR)/JavaCallout.o $(BINDIR)/libJavaAmos.so $(LDFLAGS)
	javac -classpath $(BINDIR)/javaamos.jar -d $(SWARD_ROOT)/classes $(SWARD_ROOT)/src/Java/SparQL.java