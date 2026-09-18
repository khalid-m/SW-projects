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
CFLAGS =  -O2 -I../C -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/C -I$(AMOS_HOME)/scsq/include -I$(AMOS_HOME)/scsq -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32 $(XFLAGS)
CCOMP = gcc

BINDIR=$(AMOS_HOME)/bin

MPICOMP = mpicc
#BGHOME = /bglst1/$(HOME)/amos
BGHOME = /bglst1/home/zeitler/amos
LDFLAGS = -lpthread -lm $(DL)
LRDATA=lr/DataFeeder.o lr/libLRDataProvider.a
LUTHERCXXLIB=/usr/lib/libstdc++-v3/libstdc++.so.5

BGLIBS = -lm -lcrypt -lnss_files -lnss_dns -lresolv -lc /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_dns.a /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libresolv.a /bgl/BlueLight/V1R3M0_240_2006-060623/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_files.a

#/bgl/BlueLight/DRV202_2005-050606/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_dns.a /bgl/BlueLight/DRV202_2005-050606/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libresolv.a /bgl/BlueLight/DRV202_2005-050606/ppc/blrts-gnu/powerpc-bgl-blrts-gnu/lib/libnss_files.a # -lmpe -llmpe

all: scsq 

SRCDIR = C
SRC = bgsubmit.c bgextract.c extract.c fourier.c lofardata.c realfft.c sproc.c a_fft.c fileaccess.c ft.c fork.c numarray.c multiarray.c lrmultiply.c twinagg.c udpq.c bgcommon.c filestream.c mathfns.c pipemerge.c pipestream.c port.c swin.c bitwise.c udpq.c udp_src.c w.c init_scsq.c

ifdef LR
SRC:=$(SRC) lrdata.c
endif

OBJS = $(SRC:%.c=%.o)

scsq: libamos.so libscsq.a 
	$(CCOMP)  -O2  -rdynamic $(CFLAGS) -o $(BINDIR)/scsq.exe $(SRCDIR)/scsq.c $(BINDIR)/libscsq.a $(BINDIR)/libamos.so $(LDFLAGS)
ifeq ($(ARCHITECTURE),Apple32)
	install_name_tool -change libamos.so @executable_path/libamos.so \
                          $(BINDIR)/scsq.exe
endif

libamos.so:
	cd ../system/Unix && make

libscsq.a: C/*.c Makefile
	cd $(SRCDIR) && $(CCOMP) $(CFLAGS) -c $(SRC)
	cd $(SRCDIR) && ar rc $(BINDIR)/libscsq.a $(OBJS)

clean:
	rm -f C/*.o ../bin/libscsq.a
	rm -f ../bin/scsq.exe ../bin/sp.exe
