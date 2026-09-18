ifndef ARCHITECTURE
  $(error The environment variable ARCHITECTURE not set!)
endif

export LD_LIBRARY_PATH=$(AMOS_HOME)/bin

ifeq ($(ARCHITECTURE),Apple32)
XFLAGS = -mmacosx-version-min=10.6
endif

ifeq ($(ARCHITECTURE),Linux32)
DL = -ldl
endif

CC = gcc

CFLAGS = $(XFLAGS) -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32 

BINDIR = $(AMOS_HOME)/bin

SOURCES = slaslogger.c test.c main.c
OBJECTS =$(SOURCES:.c=.o)

INCLUDES = -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include

all: $(BINDIR)/liblofixP.so $(BINDIR)/liblofixS.so logger $(OBJECTS)
	$(CC) -O2  $(CFLAGS) $(INCLUDES) \
              -o slaslogger.exe -L$(BINDIR) $(SRCDIR) \
              ../lofixP/lofixP.o $(AMOS_HOME)/extenders/BTREE/bt.o ../logger/logger.o -lamos -lm $(DL) -m32 -lpthread $(OBJECTS)
	chmod +x slaslogger.exe
	./slaslogger.exe svali.dmp -o "<'init.osql';cd('../../');save 'slas.dmp'; quit;"

$(BINDIR)/liblofixP.so: 
	cd ../lofixP && make clean && make

$(BINDIR)/liblofixS.so: 
	cd ../lofixS && make clean && make

logger:
	cd ../logger && make clean && make

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(INCLUDES)

clean:
	rm -f slaslogger.exe *.o
	rm -f $(BINDIR)/liblofixP.so $(BINDIR)/liblofixS.so
	cd ../logger && make clean
