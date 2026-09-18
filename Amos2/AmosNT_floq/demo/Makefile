# To run the executiable you must set an OS dependent variable to
# include the path to the Amos II binary directory (../bin):
# Windows: PATH
# Linux:   LD_LIBRARY_PATH
# OSX:     DYLD_LIBARY_PATH
# The variable ARCHITECTURE must be set to:
# Linux:   Linux32
# OSX:     Apple32

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
CFLAGS = -O2 -DLINUX=1 -m32 -I$(INCLUDES) $(XFLAGS)
LIBRARIES = -L$(BINDIR) -l amos -lm -lpthread


all: clientdemo ../bin/myforeign.so

# An client demonstration program:
clientdemo: clientdemo.o
	cc $(CFLAGS) -o clientdemo clientdemo.o $(LIBRARIES)

clientdemo.o: clientdemo.c
	cc $(CFLAGS) -c clientdemo.c

# Demonstration of AmosQL foreign functions in C:
$(BINDIR)/myforeign.so: foreign.o
	cc $(LFLAGS) -o $(BINDIR)/myforeign.so -lm -lpthread foreign.o

foreign.o: foreign.c
	cc -c $(CFLAGS) foreign.c 
