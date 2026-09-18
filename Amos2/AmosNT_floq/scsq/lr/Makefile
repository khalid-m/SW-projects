CXXCOMP = g++
CCOMP = gcc
CFLAGS = -Wall

all: DataFeeder

clean: 
	rm -f da da.o DataFeeder.o

DataFeeder.o: DataFeeder.cpp Makefile
	$(CXXCOMP) $(CFLAGS) -c DataFeeder.cpp

da.o: da.c Makefile
	$(CCOMP) $(CFLAGS) -c da.c

#DataFeeder: DataFeeder.o da.o Makefile
#	$(CCOMP) $(CFLAGS) -o da da.o DataFeeder.o -lpthread libLRDataProvider.a /usr/lib/libstdc++-v3/libstdc++.so.5

DataFeeder: DataFeeder.o Makefile
	$(CXXCOMP) $(CFLAGS) -o DataFeeder DataFeeder.o -lpthread libLRDataProvider.a /usr/lib/libstdc++-v3/libstdc++.so.5
