SWARD_ROOT = $(AMOS_HOME)/SWARD/
C_PATH =  $(SWARD_ROOT)/src/C
CFLAGS =  -O2 -I../C -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/C -DUNIX=1 -DLINUX=1 -m32 
LDFLAGS = -lpthread -lm -lnsl
CCOMP = gcc

all:
	cd $(C_PATH) && gmake
	cd $(AMOS_HOME)/bin && $(CCOMP) $(CFLAGS) $(C_PATH)/lexSparQL.c $(C_PATH)/SPO/sparqlMain.c $(C_PATH)/sparqlMemory.c $(C_PATH)/sparqlparser_tab.c $(C_PATH)/sparqlUtils.c $(AMOS_HOME)/C/callin.h $(AMOS_HOME)/C/callout.h libamos.a $(LDFLAGS) -o sparqlParser
