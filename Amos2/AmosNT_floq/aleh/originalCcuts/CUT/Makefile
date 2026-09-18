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

# source name runTreeCut.C(main) TTreeCut.C/h ../COMMON/TTreeClass.C/h ../COMMON/TObjectClass.C/h
#             ../COMMON/TInvMassCalc.C/h   Parameters.C/h

RUNTREECUT_O    = runTreeCut.o TTreeCut.o ../COMMON/TTreeClass.o ../COMMON/TObjectClass.o ../COMMON/TInvMassCalc.o Parameters.o

all:    runTreeCut.run

#-- "runTreeCut.C depends on ../COMMON/TTreeClass.h, TTreeCut.h, ../COMMON/TObjectClass.h and Parameters.h" ---
runTreeCut.o: runTreeCut.C ../COMMON/TTreeClass.h  TTreeCut.h ../COMMON/TObjectClass.h Parameters.h

#-- "TTreeCut.C depends on TTreeCut.h, ../COMMON/TTreeClass.h, ../COMMON/TObjectClass.h and Parameters.h" -----
TTreeCut.o: TTreeCut.C TTreeCut.h  ../COMMON/TTreeClass.h ../COMMON/TObjectClass.h Parameters.h

#----- "../COMMON/TObjectClass.C depends on ../COMMON/TObjectClass.h, ../COMMON/TTreeClass.h" -----------------------------
../COMMON/TObjectClass.o: ../COMMON/TObjectClass.C ../COMMON/TObjectClass.h ../COMMON/TTreeClass.h

#----- "../COMMON/TInvMassCalc.C depends on ../COMMON/TInvMassCalc.h, ../COMMON/TObjectClass.h " ----------
../COMMON/TInvMassCalc.o: ../COMMON/TInvMassCalc.C ../COMMON/TInvMassCalc.h ../COMMON/TObjectClass.h

#----- "../COMMON/TTreeClass.C depends on ../COMMON/TTreeClass.h" -----------------------------
../COMMON/TTreeClass.o: ../COMMON/TTreeClass.C ../COMMON/TTreeClass.h

#-------- "Parameters.C depends on Parameters.h" --------------------------
Parameters.o: Parameters.C Parameters.h

runTreeCut.run: $(RUNTREECUT_O)
	@echo "Building runTreeCut.run ...."
	$(LD) $(LDFLAGS) $(RUNTREECUT_O) $(ROOTLIBS) -o runTreeCut.run

clean:;         @rm -f *.o core *Dict* 

#--------------------------------------------------------------------------






