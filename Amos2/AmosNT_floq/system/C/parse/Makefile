all: EXP_parser_tab.c EXP_parser_tab.h 

EXP_parser_tab.h: EXP_parser_tab.c

EXP_parser_tab.c: EXP_parser.y EXP_lexer.l
	bison -d -p EXP EXP_parser.y
	flex -PEXP -i EXP_lexer.l

clean:
	del EXP_parser_tab.c EXP_parser_tab.h lexEXP.c
