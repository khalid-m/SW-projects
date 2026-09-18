ifndef ARCHITECTURE
  $(error The environment variable ARCHITECTURE not set!)
endif

ifeq ($(ARCHITECTURE),Apple32)
XFLAGS = -mmacosx-version-min=10.6
endif

ifeq ($(ARCHITECTURE),Linux32)
DL = -ldl
endif

#CFLAGS =  -g -p -I../C -I../system/include -I../system/C -DUNIX=1 -DLINUX=1 -Walln
CFLAGS =  -O2 -I../C -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/C -I$(AMOS_HOME)/scsq/include -I$(AMOS_HOME)/scsq -DUNIX=1 -DLINUX=1 -m32 $(XFLAGS)
CCOMP = gcc

BINDIR=$(AMOS_HOME)/bin

MPICOMP = mpicc
LDFLAGS = -lpthread -lm $(DL)
LRDATA=lr/DataFeeder.o lr/libLRDataProvider.a
LUTHERCXXLIB=/usr/lib/libstdc++-v3/libstdc++.so.5

BGLIBS = -lm -lcrypt -lnss_files -lnss_dns -lresolv -lc /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_dns.a /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libresolv.a /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_files.a

all: svali

SRCDIR = C
SRC = swin.c

OBJS = $(SRC:%.c=%.o)

svali: libamos.so libscsq.a Makefile
	$(CCOMP) $(CFLAGS) -o $(BINDIR)/svali $(SRCDIR)/svali.c $(SRCDIR)/$(SRC) $(BINDIR)/libamos.so $(BINDIR)/libscsq.a $(LDFLAGS)
ifeq ($(ARCHITECTURE),Apple32)
	install_name_tool -change libamos.so @executable_path/libamos.so \
                          $(BINDIR)/svali
endif
libamos.so:
	cd ../system/Unix && make

libscsq.a:
	cd ../scsq && make libscsq.a

clean:
	rm -f C/*.o
	rm -f ../bin/svali
