export BigIntegrator=1
export mexi=1
export LD_LIBRARY_PATH=$(AMOS_HOME)/bin

ifndef ARCHITECTURE
  $(error The environment variable ARCHITECTURE not set!)
endif

ifeq ($(ARCHITECTURE),Apple32)
XFLAGS = -mmacosx-version-min=10.6
endif

ifeq ($(ARCHITECTURE),Linux32)
DL = -ldl
endif

CC = cc

CFLAGS = $(XFLAGS) -O4 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32 

DESTOBJECTS = $(ARCHITECTURE)/*.o

BINDIR = $(AMOS_HOME)/bin

SRCDIR = $(AMOS_HOME)/system/C

INCLUDES = -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include \
           -I$(SRCDIR) -I$(SRCDIR)/mexima 

all: subdirs | $(BINDIR)/bt.so $(BINDIR)/xt.so $(BINDIR)/amos2.dmp \
               $(BINDIR)/alisp.dmp
	make -f Makefile.$(ARCHITECTURE)
subdirs:
	cd $(SRCDIR) && make

$(BINDIR)/libamos.so: $(DESTOBJECTS)
	cd $(BINDIR) && $(CC) -dynamiclib -shared -o libamos.so -lm $(DL) \
                     -m32 -lpthread $(AMOS_HOME)/system/Unix/$(DESTOBJECTS) 

$(BINDIR)/amos2: $(BINDIR)/libamos.so $(AMOS_HOME)/C/main.o 
	$(CC) -O2 $(CFLAGS) -rdynamic \
              -o $(BINDIR)/amos2 -L$(BINDIR) $(AMOS_HOME)/C/main.c \
              -lamos -lm $(DL) -m32 -lpthread
ifeq ($(ARCHITECTURE),Apple32)
	install_name_tool -change libamos.so @executable_path/libamos.so \
                          $(BINDIR)/amos2
endif

$(BINDIR)/amos2.dmp: $(BINDIR)/amos2 $(AMOS_HOME)/lsp/*.lsp
	$(BINDIR)/amos2 -i../../lsp/init.lsp \
                        -o "save '$(BINDIR)/amos2.dmp';quit;"


$(BINDIR)/alisp: $(BINDIR)/libamos.so
	$(CC) -O2 $(CFLAGS) -rdynamic -o $(BINDIR)/alisp -L$(BINDIR) \
               $(AMOS_HOME)/C/alisp.c $(BINDIR)/libamos.so -lm $(DL) -m32 \
               -lpthread
ifeq ($(ARCHITECTURE),Apple32)
	install_name_tool -change libamos.so @executable_path/libamos.so \
                          $(BINDIR)/alisp
endif

$(BINDIR)/alisp.dmp: $(BINDIR)/alisp
	cd $(BINDIR) && make alisp.dmp

$(BINDIR)/xt.so: $(BINDIR)/libamos.so
	cd $(AMOS_HOME)/extenders/XTREE && make

$(BINDIR)/bt.so: $(BINDIR)/libamos.so
	cd $(AMOS_HOME)/extenders/BTREE && make

clean:
	rm -f $(BINDIR)/libamos.so $(BINDIR)amos2 $(BINDIR)/amos2.dmp $(BINDIR)alisp $(BINDIR)/alisp.dmp 
	make -f Makefile.$(ARCHITECTURE) clean
	cd $(SRCDIR) && make clean
	cd $(AMOS_HOME)/extenders/BTREE && make clean
	cd $(AMOS_HOME)/extenders/XTREE && make clean


