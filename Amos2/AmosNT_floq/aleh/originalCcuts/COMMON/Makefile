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

#------------------------------------------------------------------------
#------ improved Makefile below suggested by ----------------------------
#--------- Philippe Canal <pcanal@fnal.gov> -------------------------------
#--------------------------------------------------------------------------

# source name testConverter.C(main) TParticleCodeConverter.C/h

RUNTRUTHANALYS_O    = testConverter.o TParticleCodeConverter.o

all:    testConverter.run

#-- "testConverter.C depends on TParticleCodeConverter.h " ---
testConverter.o: testConverter.C TParticleCodeConverter.h

#-- "TParticleCodeConverter.C depends on TParticleCodeConverter.h" -----
TParticleCodeConverter.o: TParticleCodeConverter.C TParticleCodeConverter.h

testConverter.run: $(RUNTRUTHANALYS_O)
	@echo "Building runTruthAnalys.run ...."
	$(LD) $(LDFLAGS) $(RUNTRUTHANALYS_O) $(ROOTLIBS) -o testConverter.run

clean:;         @rm -f *.o core *Dict* 

#--------------------------------------------------------------------------






