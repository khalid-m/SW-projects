/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: EXP_lexer.l,v $
 * $Revision: 1.1 $ $Date: 2009/09/01 20:20:16 $
 * $State: Exp $ $Locker:  $
 *
 * Description: A simple expression parser
 * Generate code by running: flex -PEXP -i EXP_lexer.l
 * ===========================================================================
 * $Log: EXP_lexer.l,v $
 * Revision 1.1  2009/09/01 20:20:16  torer
 * Added example of very simple bison/flex parser
 *
 ****************************************************************************/

%{
#include "amos.h"
#include "exp_parser_tab.h" 
#include <memory.h>
#include <math.h>
#define MAXLENGTH 4096

oidtype EXP_statement = nil; /* The parsed expression */
oidtype EXPrefs = nil;     /* List of objects created during parsing */
unsigned int EXPerrno;     /* Parser error number. Assigned in driver */

#define RESULT EXPlval
#define SAVE_REF if(!symbolp(RESULT.oidval))a_setf(EXPrefs,cons(RESULT.oidval,EXPrefs))
#undef EXPwrap
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
{ \
	int c; flexstream *fs=(flexstream *)yyin; \
        c = a_getc(fs->stream); \
	if (c == '\r') c = ' '; \
	if (c == '\n' || fs->char_num>=MAXLENGTH) {fs->char_num = 0; };  \
        result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
}

void EXPerror(char *s){ a_error(EXPerrno, mkstring(s), FALSE);};

#define TOK(name) {RESULT.oidval = mksymbol(yytext); SAVE_REF; return name;}
%}

%s EXP

%%

	/* comparison */

"="	TOK(EQ)
"<>"	TOK(NEQ);
"<"	TOK(LT)
">"	TOK(GT)
"<="	TOK(LTE)
">="	TOK(GTE)

     
[-+*/:();,]	TOK(yytext[0])

	/* names */

[a-zA-Z][A-Za-z0-9_]*  TOK(NAME)


	/* numbers */

[-]?[0-9]+	|
[-]?[0-9]+"."[0-9]* |
[-]?"."[0-9]*			TOK(INTNUM)

[-]?[0-9]+[eE][+-]?[0-9]+		|
[-]?[0-9]+"."[0-9]*[eE][+-]?[0-9]+	|
[-]?"."[0-9]*[eE][+-]?[0-9]+	TOK(APPROXNUM)

	/* strings */

'[^'\n]*'	{
                  yytext[strlen(yytext)-1]='\0';
                  RESULT.oidval = mkstring(yytext+1); SAVE_REF;
		  return STRING;
		}

'[^'\n]*$	{EXPerror("Unterminated string");}

	/* whitespace */

\n		{}

[ \t\r\f]+	{;}	/* whitespace */

	/* anything else */
.		{EXPerror("syntax error, invalid character");}


%%

int EXPwrap()
{
  return 1;
}

un_exp()
{
  BEGIN INITIAL;
}



