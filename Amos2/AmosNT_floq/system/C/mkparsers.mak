all: sql_parser_tab.c parser_tab.c sql_parser_tab.h parser_tab.h lexyy.c

sql_parser_tab.h: sql_parser_tab.c

sql_parser_tab.c: sql_parser.y sql_lexer.l
	bison -d -p SQL sql_parser.y
	flex -PSQL -i sql_lexer.l

parser_tab.h: parser_tab.c

parser_tab.c: parser.y scanner.l
	bison -d --debug --verbose parser.y
	flex scanner.l
