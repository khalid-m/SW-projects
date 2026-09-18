all: NTR_parser_tab.c NTR_parser_tab.h 

NTR_parser_tab.h: NTR_parser_tab.c

NTR_parser_tab.c: NTR_parser.y NTR_lexer.l
	bison -d -p NTR NTR_parser.y
	flex -PNTR -i NTR_lexer.l

clean:
	del NTR_parser_tab.c NTR_parser_tab.h lexNTR.c
