CFLAGS = -shared -rdynamic -ldl -m32 -DLINUX=1 -DUNIX=1

SRCDIR = MVC

BINDIR=$(AMOS_HOME)/bin

JAVA_INCLUDE=$(JAVA_HOME)/include

CORECFLAGS = -I$(JAVA_INCLUDE)/linux -I$(JAVA_INCLUDE) -I$(AMOS_HOME)/C \
-I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/system/C -O2 -DUNIX=1 -DLINUX=1 -m32

CORESRC = JavaCallin.cpp JavaCallout.cpp

SRC = nma.c nma_fns.c sqond.c nma_chunks.c

OTHER_SRC = $(AMOS_HOME)/scsq/C/numarray.c $(AMOS_HOME)/scsq/C/w.c 

INCLUDE = -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/scsq/include -I$(AMOS_HOME)/C

all: $(BINDIR)/ssdm.so $(BINDIR)/ssdm.dmp

$(BINDIR)/ssdm.so:
	cd $(SRCDIR) && gcc $(CFLAGS) -o$(BINDIR)/ssdm.so -L$(BINDIR) $(INCLUDE) $(SRC) $(OTHER_SRC) -lamos

$(BINDIR)/ssdm.dmp: # $(BINDIR)/python_ext.so
	amos2 -L lsp/master.lsp -o "save '$(BINDIR)/ssdm.dmp'; quit;"

$(BINDIR)/python_ext.so:
	cd ../embeddings/Python && make

clean:
	rm -f $(BINDIR)/ssdm.so
	rm -f $(BINDIR)/ssdm.dmp

