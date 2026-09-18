WORDLEN = 32

CARCH = -m$(WORDLEN) 

CFLAGS = -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE $(CARCH)

SOURCES = mexi.c mexima.c mex_foreign.c mexi_ff.c mexmeda.c \
          mex_relation.c  mex_generic_api.c mexutilities.c  

SRCDIR = $(AMOS_HOME)/system/C

BINDIR = $(AMOS_HOME)/system/Unix/$(ARCHITECTURE)

INCLUDES= -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include \
          -I$(SRCDIR) -I$(SRCDIR)/mexima -I$(SRCDIR)/xtree 

OBJECTS=$(SOURCES:.c=.o)

DESTOBJECTS= $(patsubst %,$(BINDIR)/%,$(OBJECTS))

all: $(DESTOBJECTS)

$(BINDIR)/%.o: %.c
	$(CC) -c $(INCLUDES) -o $@ $< $(CFLAGS)

clean:
	rm -f $(DESTOBJECTS)
