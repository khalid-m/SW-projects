ifeq ($(ARCHITECTURE),Linux32)
DL = -lnsl -ldl
endif

BINDIR = $(AMOS_HOME)/bin
CC = gcc
CFLAGS = -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/system/C \
         -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32 -lm -lpthread $(DL)

all: install test

install:
	$(CC) $(CFLAGS) -o localThreads localThreads.c $(BINDIR)/libamos.a
	$(CC) $(CFLAGS) -o crashtest crashtest.c $(BINDIR)/libamos.a
	$(CC) -o crashex crashex.c

test:
	@echo "------------------"
	@echo "LocalThreads check"
	@echo "------------------"
	./localThreads $(BINDIR)/amos2.dmp "< 'defs.osql';" 1000 10 niota
	./localThreads $(BINDIR)/amos2.dmp "< 'defs.osql';" 2 1000 cciota
	./localThreads $(BINDIR)/amos2.dmp "< 'defs.osql';" 2 1 zbg

	@echo "------------------"
	@echo "Coroutine background check"
	@echo "------------------"
	@script -q -c "./crashtest $(BINDIR)/amos2.dmp \"< 'crashtest.osql';\"" tmpfile > /dev/null
	@./crashex "ERROR: Calling Amos II from background thread"
	@rm tmpfile

clean:
	rm -f localThreads crashtest crashex
