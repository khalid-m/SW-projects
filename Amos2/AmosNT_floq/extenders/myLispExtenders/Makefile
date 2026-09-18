#####################################################################
# This is a generic Makefile for making Amos II extenders
# Assign SOURCES to your C source files
# Assign EXTENDER to the name of your extender
# The extender will be generated in the library $AMOS_HOME/bin
# The environment variable must be set to the architecture of 
# your system, currently one of Linux32 or Apple32
#####################################################################

SOURCES = myLispExtenders.c

EXTENDER = myLispExtenders

#####################################################################

ifndef ARCHITECTURE
  $(error The environment variable ARCHITECTURE not set!)
endif

ifeq ($(ARCHITECTURE),Apple32)
XFLAGS = -mmacosx-version-min=10.6
LFLAGS = -m32 -undefined dynamic_lookup -dynamic
endif

ifeq ($(ARCHITECTURE),Linux32)
LFLAGS = -m32 -shared -rdynamic -dynamic -L $(AMOS_HOME)/bin -l amos 
endif

CC = gcc

CFLAGS = -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32 $(XFLAGS)

LIBDIR = $(AMOS_HOME)/bin

INCLUDES= -I $(AMOS_HOME)/C -I $(AMOS_HOME)/system/include 

OBJECTS=$(SOURCES:.c=.o)

all: $(OBJECTS)
	$(CC) $(LFLAGS) -o $(LIBDIR)/$(EXTENDER).so -lm -lpthread \
              $(OBJECTS) 

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(INCLUDES) 

clean:
	rm -f $(OBJECTS)
