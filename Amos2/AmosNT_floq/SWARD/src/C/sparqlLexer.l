/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, Tore Risch, UDBL
 * $RCSfile: sparqlLexer.l,v $
 * $Revision: 1.12 $ $Date: 2010/04/28 14:46:29 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SparQL scanner
 * ===========================================================================
 * $Log: sparqlLexer.l,v $
 * Revision 1.12  2010/04/28 14:46:29  fred2431
 * Compile and regression test for SWARD under Linux
 *
 * Revision 1.11  2008/04/17 14:30:15  torer
 * CR and LF delimiter in scanners
 *
 * Revision 1.10  2008/04/16 14:13:57  torer
 * Handling of CR and LF as delimiters in SparQL parser
 *
 * Revision 1.9  2008/04/11 18:25:49  torer
 * Printing character code at failure
 *
 * Revision 1.8  2007/11/27 13:01:26  petrini
 * Added information to gpErrMsg of where error originates in query string i.e. the token generating the error.
 *
 * Revision 1.7  2007/11/26 18:55:51  torer
 * Fixed parser error handling problem
 *
 * Revision 1.6  2007/11/26 14:18:39  petrini
 * Writing argument to SparQLerror fn to gpErrMsg instead of SparQLtext.
 *
 * Revision 1.5  2007/11/26 13:21:47  petrini
 * Error message gpErrMsg is set only if it is not set before. I.e. the first error is reported.
 *
 * Revision 1.4  2007/11/24 14:35:34  torer
 * Bug that crashed SparQL-parser fixed!!
 *
 * Revision 1.3  2007/07/24 05:55:36  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/07/23 20:24:16  petrini
 * *** empty log message ***
 *
 * Revision 1.2  2007/06/12 20:05:45  torer
 * Better syntax error messages
 *
 ****************************************************************************/

/* scanner for a toy Pascal-like language */
%{
	/* need this for the call to atof() below */
	#include <stdio.h>
	#include <string.h>
	#include "sparqlparser_tab.h"
	#include "storage.h"
	#include "sparqlUtils.h"
        #include "sparqlMemory.h"
	
	#undef YY_INPUT
	#define YY_INPUT(b, r, ms) (r = sparql_input(b, ms))
	
	#define TOK(name)	{ DBG_PRT("Keyword %s, Return %s\n", yytext, #name); return name;}
	
	unsigned int guiLineNo = 1;
	void SparQLerror(const char *s);
%}

DIGIT						[0-9]
EXPONENT				[eE][+-]?[0-9]+	
WS							[\x20\x9\xD\xA]
HEX							[0-9]|[A-F]|[a-f]
ECHAR						\\[tbnrf\"']
UCHAR						\\[uU]{HEX}{HEX}{HEX}{HEX}
NCCHAR1p				[A-Z]|[a-z]|{UCHAR}
NCCHAR1					{NCCHAR1p}|_
NCCHAR					{NCCHAR1}|-|{DIGIT}
NCNAME					{NCCHAR1}(({NCCHAR}|\.)*{NCCHAR})?
%%

 /* literal keyword */
"^^"				TOK(UPUP)
"||"				TOK(OR)
"&&"				TOK(AND)

[Ff][Aa][Ll][Ss][Ee] 													TOK(_FALSE)
[Tt][Rr][Uu][Ee]															TOK(_TRUE)
[Aa][Ss][Cc]																	TOK(ASC)
[Aa][Ss][Kk]																	TOK(ASK)
[Bb][Aa][Ss][Ee]															TOK(BASE)
[Bb][Oo][Uu][Nn][Dd]													TOK(BOUND)
[Bb][Yy]																			TOK(BY)
[Cc][Oo][Nn][Ss][Tt][Rr][Uu][Cc][Tt]					TOK(CONSTRUCT)
[Dd][Aa][Tt][Aa][Tt][Yy][Pp][Ee]							TOK(DATATYPE)
[Dd][Ee][Ss][Cc]															TOK(DESC)
[Dd][Ee][Ss][Cc][Rr][Ii][Bb][Ee]							TOK(DESCRIBE)
[Dd][Ii][Ss][Tt][Ii][Nn][Cc][Tt]							TOK(DISTINCT)
[Ff][Rr][Oo][Mm]															TOK(FROM)
[Ff][Ii][Ll][Tt][Ee][Rr]											TOK(FILTER)
[Gg][Rr][Aa][Pp][Hh]													TOK(GRAPH)
[Ii][Ss][Bb][Ll][Aa][Nn][Kk]									TOK(IS_BLANK)
[Ii][Ss][Ll][Ii][Tt][Ee][Rr][Aa][Ll]					TOK(IS_LITERAL)
[Ii][Ss][Ii][Rr][Ii]													TOK(IS_IRI)
[Ii][Ss][Uu][Rr][Ii]													TOK(IS_URI )
[Ll][Aa][Nn][Gg]															TOK(LANG)
[Ll][Aa][Nn][Gg][Mm][Aa][Tt][Cc][Hh][Ee][Ss]	TOK(LANGMATCHES)
[Ll][Ii][Mm][Ii][Tt]													TOK(LIMIT)
[Nn][Aa][Mm][Ee][Dd]													TOK(NAMED)
[Oo][Ff][Ff][Ss][Ee][Tt]											TOK(OFFSET)
[Oo][Pp][Tt][Ii][Oo][Nn][Aa][Ll]							TOK(OPTIONAL)
[Oo][Rr][Dd][Ee][Rr] 													TOK(ORDER)
[Pp][Rr][Ee][Ff][Ii][Xx]											TOK(PREFIX)
[Rr][Ee][Gg][Ee][Xx]													TOK(REGEX)
[Ss][Ee][Ll][Ee][Cc][Tt]											TOK(SELECT)
[Ss][Tt][Rr]																	TOK(STR)
[Uu][Nn][Ii][Oo][Nn]													TOK(UNION)
[Ww][Hh][Ee][Rr][Ee]													TOK(WHERE)

 /* comparison */
"="		TOK(EQ)
"!="	TOK(NEQ)
"<"		TOK(LT)
">"		TOK(GT)
"<="	TOK(LTE)
">="	TOK(GTE)

[-\+_!:;,(){}\[\]\.\*/]	{
	DBG_PRT("Symbol %s\n", SparQLtext);
	return SparQLtext[0];
}

a/[ \t]+	{return SparQLtext[0];}

%{/*[67] Q_IRI_REF */%}
"<"([^<>'{}\^\"\`\x00-\x20])*">" {
	int newIRI;
	
	char *pIRI = SparQLtext;

	pIRI++;
	pIRI[strlen(pIRI)-1] = '\0';

	DBG_PRT("Keyword Q_IRI_REF, '%s'\n", pIRI);
	
	newIRI = mk_iri(pIRI);
	
	if (newIRI == T_UNKNOWN)
		return 0;
		
	SparQLlval.id = newIRI;
	return Q_IRI_REF;
}

%{/*[70] BLANK_NODE_LABEL*/%}
_:{NCNAME}	TOK(BLANK_NODE_LABEL)

%{/*[71][72] VAR1 VAR2 */%}
[?$]({NCCHAR1}|{DIGIT})({NCCHAR1}|{DIGIT})* {
	int newVar = T_UNKNOWN;
	
	char *pVar = SparQLtext+1; /*ignore the first letter, '$' or '?'*/
	pVar[strlen(pVar)] = '\0';
	DBG_PRT("Keyword VAR, '%s'\n", pVar);
	
	newVar = mk_var(pVar);
	SparQLlval.id = newVar;
	
	return VAR;
}

%{/*[73] LANGTAG */%}
"@"[a-zA-Z]+("-"[a-zA-Z0-9]+)* TOK(LANGTAG)

%{/*[74] INTEGER */%}
{DIGIT}+ TOK(INTEGER)

%{/*[75] DECIMAL */%}
{DIGIT}+"."{DIGIT}* |
"."{DIGIT}+ TOK(DECIMAL)

%{/*[76] DOUBLE */%}
{DIGIT}+"."{DIGIT}*{EXPONENT} |
"."{DIGIT}+{EXPONENT} |
{DIGIT}+{EXPONENT} TOK(DOUBLE)

%{/*[78] STRING_LITERAL1 */%}
\x27([^\x27\xA\xD]|{ECHAR}|{UCHAR})*\x27 {
	int newLtr;
	
	DBG_PRT("Keyword STRING_LITERAL12, '%s'\n", SparQLtext);
	
	newLtr = mk_str(SparQLtext);
	SparQLlval.id = newLtr;
	
	return STRING_LITERAL12;
}

%{/*[79] STRING_LITERAL2 */%}
\x22([^\x22\xA\xD]|{ECHAR}|{UCHAR})*\x22 {
	int newLtr;
	
	DBG_PRT("Keyword STRING_LITERAL12, '%s'\n", SparQLtext);
	
	newLtr = mk_str(SparQLtext);
	SparQLlval.id = newLtr;
	
	return STRING_LITERAL12;
}

%{/*
	[80] STRING_LITERAL_LONG1
	problem
*/%}
\x27\x27\x27(\x27|\x27\x27)?([^\x27\x5C\xA\xD]|{ECHAR}|{UCHAR})*\x27\x27\x27 TOK(STRING_LITERAL_LONG1)

%{/*
	[81] STRING_LITERAL_LONG2 
	problem
*/%}
\x22\x22\x22(\x22|\x22\x22)?([^\x22\x5C\xA\xD]|{ECHAR}|{UCHAR})*\x22\x22\x22 TOK(STRING_LITERAL_LONG2)

%{/*[85] NIL */%}
"("{WS}*")" TOK(NIL)

%{/*[87] ANON */%}
"["{WS}*"]" TOK(ANON)

%{/*[92] NCNAME_PREFIX */%}
{NCCHAR1p}(({NCCHAR}|\.)*{NCCHAR})?: TOK(NCNAME_PREFIX_SPC)

%{/* : NCNAME */%}
{NCNAME} TOK(NCNAME)

%{/* Commnet */%}
#[^\n]*	/**/

\n {guiLineNo++; /*Increase line number*/}

[ \t\r\f] /**/

 /* anything else */
.		{ SparQLerror("syntax error, invalid character"); }
%%

void SparQLerror(const char *s)
{ 
  int charcode;
  char charbuff[20];

  if (gpErrMsg == NULL){ 
    gpErrMsg= sparql_new(strlen(s)+strlen(SparQLtext)+ 50);
    strcpy(gpErrMsg,s);
    strcat(gpErrMsg, " when reaching: ");
    strcat(gpErrMsg, SparQLtext);
  }
}

int SparQLwrap()
{
  return 1;
}
