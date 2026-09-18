CC=gcc

WORDLEN = 32

CARCH = -m$(WORDLEN)

CFLAGS = -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE $(CARCH)

ifeq ($(ARCHITECTURE),Apple32)
CFLAGS = -mmacosx-version-min=10.6 -O2 -DUNIX=1 -DLINUX=1 -U_FORTIFY_SOURCE $(CARCH)
endif

SOURCES= aggops.c amosfns.c lock.c winagg.c cinterf.c coroutine.c buffer.c \
   strings.c init.c event_manager.c text_fns.c a_pca.c lproctime.c\
   linh.c htbl.c text_match.c comm.c math_fns.c compl_fns.c top.c a_time.c\
   commands.c getopt.c os_fns.c lexyy.c parser_tab.c SQLParse.c \
   sql_parser_tab.c sql_lexer.c uri.c typecheck.c language.c\
   lispfns.c files.c CSV.c storagetypes.c binary.c filefns.c getexename.c \
   event_objects_ux.c tls.c mersenne.c extender.c \
   expression.c scan.c scan_remote.c RDF.c nbprint.c startupdirectory.c

SRCDIR = $(AMOS_HOME)/system/C

BINDIR = $(AMOS_HOME)/system/Unix/$(ARCHITECTURE)

OBJECTS=$(SOURCES:.c=.o)

DESTOBJECTS = $(patsubst %,$(BINDIR)/%,$(OBJECTS))

INCLUDES= -I$(AMOS_HOME)/C -I$(AMOS_HOME)/system/include \
          -I$(SRCDIR) -I$(SRCDIR)/mexima

#ifeq ($(ARCHITECTURE),Linux32)
LEXYY = -olexyy.c
LEXSQL = -osql_lexer.c
#endif
 

$(BINDIR)/%.o: %.c
	$(CC) -c $(INCLUDES) -o $@ $< $(CFLAGS)

all: $(DESTOBJECTS)
	make parsers
	cd mexima && make

parsers:  lexyy.c sql_lexer.c 

sql_lexer.c: sql_parser_tab.c

sql_parser_tab.c: sql_parser.y sql_lexer.l
	bison -d -osql_parser_tab.c -p SQL sql_parser.y
	flex $(LEXSQL) -PSQL -i sql_lexer.l

lexyy.c: parser_tab.c 

parser_tab.c: parser.y scanner.l
	bison -d -oparser_tab.c parser.y
	flex $(LEXYY) scanner.l

clean:
	rm -f $(DESTOBJECTS)
	rm -f lexyy.c *parser_tab.* sql_lexer.c
	cd mexima && make clean
