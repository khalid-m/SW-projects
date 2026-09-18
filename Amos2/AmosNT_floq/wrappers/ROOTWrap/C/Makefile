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


ROOTLIBS      = $(ROOTGLIBS) 

AMOSBIN = ../../../bin

all:    $(AMOSBIN)/rootwrap

$(AMOSBIN)/rootwrap: structs.o aleh_udfs.o amain.o
	$(LD) -g $(LDFLAGS) structs.o aleh_udfs.o amain.o $(AMOSBIN)/libamos.a $(ROOTLIBS) -o $(AMOSBIN)/rootwrap -lm -lnsl

