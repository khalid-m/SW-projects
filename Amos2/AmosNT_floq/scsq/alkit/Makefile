
SRC=canrelay.c
BINDIR=$(AMOS_HOME)/bin
CC = gcc

all:
	$(CC) -O2 -I$(AMOS_HOME)/C -o $(BINDIR)/canrelay canrelay.c $(BINDIR)/libamos.a -lm -lnsl -m32 -lpthread
