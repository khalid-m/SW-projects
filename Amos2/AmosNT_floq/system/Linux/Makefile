# If no IP communication is desired:
# (i) set env variable NOCOMM to 1.
# (ii) define NOCOMM to C preprocessor

$(error This Makfile obsolete. Use AmosNT/system/Unix/Makefile!)

export BigIntegrator=1
export mexi=1

ifndef HOSTTYPE
 HOSTTYPE=i386
endif
ifeq ($(HOSTTYPE),x86_64)
HOSTTYPE=i386
endif
ifeq ($(HOSTTYPE),i686)
HOSTTYPE=i386
endif

SRC= aggops.c amosfns.c lock.c winagg.c cinterf.c coroutine.c buffer.c strings.c \
   init.c event_manager.c text_fns.c a_pca.c lproctime.c\
   linh.c htbl.c text_match.c comm.c math_fns.c compl_fns.c top.c a_time.c\
   commands.c getopt.c os_fns.c lexyy.c parser_tab.c SQLParse.c \
   sql_parser_tab.c sql_lexyy.c uri.c typecheck.c language.c\
   lispfns.c files.c storagetypes.c binary.c filefns.c getexename.c \
   event_objects_ux.c tls.c mersenne.c extender.c \
   mexima/mexi.c mexima/mexima.c mexima/mex_foreign.c mexima/mexi_ff.c mexima/mexmeda.c \
   mexima/mex_relation.c  mexima/mex_generic_api.c mexima/mexutilities.c \
   expression.c scan.c scan_remote.c RDF.c nbprint.c

BINS=eval.o extfns.o print.o read.o storage.o \
   misc.o olog.o rel.o hist.o \
   oid.o systemfns.o \
   fncall.o index.o btree.o libyywrap.o unix_socket.o 
OBJDIR=./$(HOSTTYPE)
CFLAGS =  -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include -I$(AMOS_HOME)/system/C \
	 -I$(AMOS_HOME)/system/C/mexima \
          -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE -m32

BINDIR=$(AMOS_HOME)/bin
CC = gcc
OBJS = $(SRC:%.c=$(OBJDIR)/%.o)

all: $(BINDIR)/amos2 $(BINDIR)/bt.so $(BINDIR)/xt.so $(BINDIR)/amos2.dmp $(BINDIR)/alisp.dmp 

comm:	../C/comm.c
	cd ../C && $(CC) $(CFLAGS) -c comm.c

../C/sql_parser_tab.c: ../C/sql_parser.y
	cd ../C && bison -d -osql_parser_tab.c -p SQL sql_parser.y
	cd ../C && flex -osql_lexyy.c  -PSQL -i sql_lexer.l

../C/parser_tab.c: ../C/lexyy.c

../C/lexyy.c: ../C/parser.y ../C/scanner.l
	cd ../C && bison -d -oparser_tab.c parser.y
	cd ../C && flex -olexyy.c scanner.l

$(BINDIR)/libamos.a: ../C/parser_tab.c ../C/sql_parser_tab.c $(HOSTTYPE)/*.o ../C/*.c
	cd ../C && $(CC) $(CFLAGS) -c $(SRC)
	cp ../C/*.o $(OBJDIR)
	cd $(OBJDIR) && ar rc $(BINDIR)/libamos.a *.o

$(BINDIR)/amos2: $(BINDIR)/libamos.a $(AMOS_HOME)/C/main.o 
	$(CC) -O2  -rdynamic $(CFLAGS) -o $(BINDIR)/amos2 $(AMOS_HOME)/C/main.c $(BINDIR)/libamos.a -lm -lnsl -ldl -m32 -lpthread

$(BINDIR)/alisp: $(BINDIR)/amos2
	$(CC) -O2 -rdynamic $(CFLAGS) -o $(BINDIR)/alisp $(AMOS_HOME)/C/alisp.c $(BINDIR)/libamos.a -lm -lnsl -ldl -m32 -lpthread

$(BINDIR)/amos2.dmp: $(BINDIR)/amos2 
	$(BINDIR)/amos2 -i../../lsp/init.lsp -o "save '$(BINDIR)/amos2.dmp';quit;"

$(BINDIR)/alisp.dmp: $(BINDIR)/alisp
	cd $(BINDIR) && make alisp.dmp

$(BINDIR)/bt.so: $(AMOS_HOME)/extenders/BTREE/bt.c
	cd ../C
	gcc $(AMOS_HOME)/extenders/BTREE/bt.c $(AMOS_HOME)/extenders/BTREE/bt.h $(AMOS_HOME)/extenders/BTREE/BT_mexi_extender.c -o$(AMOS_HOME)/bin/bt.so -shared -rdynamic -ldl -I./ -I$(AMOS_HOME)/C -m32 -DLINUX=1 -DUINUX=1

$(BINDIR)/xt.so: $(AMOS_HOME)/extenders/XTREE/xtree.c
	gcc $(AMOS_HOME)/extenders/XTREE/amosXtree.c $(AMOS_HOME)/extenders/XTREE/amosXtree.h $(AMOS_HOME)/extenders/XTREE/xt_mexi_extender.c $(AMOS_HOME)/extenders/XTREE/xfile.c $(AMOS_HOME)/extenders/XTREE/xpbuild.c $(AMOS_HOME)/extenders/XTREE/xsearch.c $(AMOS_HOME)/extenders/XTREE/xtree.c $(AMOS_HOME)/extenders/XTREE/xtree.h $(AMOS_HOME)/extenders/XTREE/xtreeconst.h  $(AMOS_HOME)/extenders/XTREE/utils.c -o$(AMOS_HOME)/bin/xt.so  -shared -rdynamic -ldl -I./ -I$(AMOS_HOME)/C -m32 -DLINUX=1 -DUINUX=1

clean:
	rm ../C/*.o
	rm ../../bin/libamos.a
	rm ../../bin/bt.so
	rm ../../bin/xt.so


