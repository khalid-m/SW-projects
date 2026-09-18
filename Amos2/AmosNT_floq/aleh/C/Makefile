# -----------------------------------------------------------------------
# All the following comes from the Makefile (which is 
# automatically created by the root install process...)
# in $ROOTSYS/doc/root/test/Makefile .....
# It sets all the needed Variables correctly...
#------------------------------------------------------------------------ 
ObjSuf        = o
SrcSuf        = C
ExeSuf        = run
DllSuf        = so
OutPutOpt     = -o


ROOTCFLAGS    = $(shell root-config --cflags) 
ROOTGLIBS     = $(shell root-config --glibs)

# Linux with egcs
CXX           = g++
CXXFLAGS      = -O2 -Wall -fPIC $(ROOTCFLAGS) 
LD            = g++
LDFLAGS       = -L$(UU_ROOT_LIB) -L$(shell pwd)
SOFLAGS       = -shared

MPID	= mpicc

ROOTLIBS      = $(ROOTGLIBS) 

AMOSBIN = ../../bin
ALEHBIN = ..

all:    $(AMOSBIN)/aleh

$(AMOSBIN)/aleh: amain.o amath.o TTreeClass.o
	$(LD) -g $(LDFLAGS) amath.o TTreeClass.o amain.o $(AMOSBIN)/libamos.a $(ROOTLIBS) -o $(AMOSBIN)/aleh -lm -lnsl

startup: startup.c
	$(MPID) -static startup.c -o $(AMOSBIN)/startup

debug:	$(ALEHBIN)/aleh
$(ALEHBIN)/aleh: amain.debug.o amath.o TTreeClass.o
	$(LD) -g $(LDFLAGS) amath.o TTreeClass.o amain.debug.o $(AMOSBIN)/libamos.a $(ROOTLIBS) -o $(AMOSBIN)/aleh -lm -lnsl

TTreeClass.o: TTreeClass.h