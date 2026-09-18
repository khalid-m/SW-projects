all:
	bison -d -p SparQL sparqlParser.y
	flex -PSparQL -i sparqlLexer.l
	mv lex.SparQL.c lexSparQL.c
	mv sparqlParser.tab.c sparqlparser_tab.c
	mv sparqlParser.tab.h sparqlparser_tab.h