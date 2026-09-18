ifeq ($(ARCHITECTURE),Apple32)
XFLAGS = -mmacosx-version-min=10.6
LFLAGS = -m32 -undefined dynamic_lookup -dynamic
endif

ifeq ($(ARCHITECTURE),Linux32)
LFLAGS = -m32 -shared -rdynamic -dynamic -L $(BINDIR) -l amos 
endif

ifndef ARCHITECTURE
  $(error The environment variable ARCHITECTURE not set!)
endif

BINDIR = ../bin
INCLUDES = ../C
CFLAGS = -O2 -DLINUX=1 -m32 -I $(INCLUDES) -I ../system/include $(XFLAGS)


debswrappers.so: debswrapper.o
	cc $(LFLAGS) -o $(BINDIR)/debswrappers.so -lm -lpthread debswrapper.o $(BINDIR)/libscsq.a

debswrapper.o: src/debswrapper.c
	cc $(CFLAGS) -c src/debswrapper.c

clean:
	rm -f *.o
	rm -f ../bin/debswrappers.so