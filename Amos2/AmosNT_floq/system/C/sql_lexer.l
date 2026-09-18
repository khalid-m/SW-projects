/*-*-C-*-**********************************************************************
 * AMOS2
 *
 * Author: (c) 1998-2011 Marcus Eriksson, Tore Risch, Markus Jägerskogh, EDSLAB, UDBL
 * $RCSfile: sql_lexer.l,v $
 * $Revision: 1.14 $ $Date: 2013/02/13 18:41:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Lexical analyzer for the SQL parser
 * Generate C code by running: flex -PSQL -i sql_lexer.l
 ****************************************************************************/

%{
#include "amos.h"
#include "sql_parser_tab.h"

extern oidtype _oidrefs_; 

#define SAVE_REF if(!symbolp(SQLlval.oidval))\
a_setf(globval(_oidrefs_),cons(SQLlval.oidval,globval(_oidrefs_)))

#define TOK(name) {SQLlval.oidval = mksymbol(yytext); SAVE_REF; return name;}

#undef SQLwrap

  /********************* flexstream interface ************************/
  /* Interface must be here since lex defines parser specific macros */
  /*******************************************************************/

  YY_BUFFER_STATE yy_create_buffer( FILE *file, int size );

  void SQL_initialize_flexstream(flexstream *fs)
    /*** called when parser changes from other parser to this parser ***/
    {
      fs->buffer = (char *)yy_create_buffer((FILE*)fs,YY_BUF_SIZE);
    }

  void SQL_finalize_flexstream(flexstream *fs)
    /*** called when parser changes from this parser to other parser ***/
    {
      yy_delete_buffer((YY_BUFFER_STATE)fs->buffer);
    }

  void SQLerror(char *msg)
    /*** called when syntax error detected ***/
    { 
      a_parse_error((flexstream *)SQLin, msg);
    }

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size)\
        result = a_flexstream_getc((flexstream *)SQLin, buf)

  /***************** end of flexstream interface *********************/

%}

%s SQL

%x COMMENT

%%

ALL           TOK(ALL)
AND	      TOK(AND)
AS            TOK(AS)
ASC           TOK(ASC)
AVG	      TOK(AVG)
BETWEEN       TOK(BETWEEN)
BOOLEAN       TOK(BOOLEAN)
BY            TOK(BY)
CASCADE       TOK(CASCADE)
CASE          TOK(CASE)
CHECK         TOK(CHECK)
CLOB          TOK(CLOB)
COMMIT        TOK(COMMIT)
CONSTRAINT    TOK(CONSTRAINT)
COUNT	      TOK(COUNT)
CREATE        TOK(CREATE)
CROSS         TOK(CROSS)
CHAR(ACTER)?  TOK(CHARACTER)
DEC(IMAL)?    TOK(DECIMAL)
DEFAULT       TOK(DEFAULT)
DESC          TOK(DESC)
DELETE        TOK(_DELETE)
DISTINCT      TOK(DISTINCT)
DOUBLE        TOK(DOUBLE)
DROP          TOK(DROP)
ELSE          TOK(ELSE)
END           TOK(END)
FALSE         TOK(_FALSE)
FLOAT         TOK(FLOAT)
FOREIGN       TOK(FOREIGN)
FROM	      TOK(FROM)
GROUP	      TOK(GROUP)
HAVING        TOK(HAVING)
IN            TOK(_IN)
INNER         TOK(INNER)
INSERT        TOK(INSERT)
INT(EGER)?    TOK(INTEGER)
INTO          TOK(INTO)
JOIN          TOK(JOIN)
KEY           TOK(KEY)
LIKE(_I)?     TOK(LIKE)
MIN	      TOK(MIN)
MAX	      TOK(MAX)
NATRUAL       TOK(NATRUAL)
NOT	      TOK(NOT)
QUIT          TOK(_QUIT)
NULL	      TOK(_NULL)
NUMERIC       TOK(_NUMERIC)
ON            TOK(ON)
OR	      TOK(OR)
ORDER	      TOK(ORDER)
PRECISION     TOK(PRECISION)
PRIMARY       TOK(PRIMARY)
REAL          TOK(REAL)
REFERENCES    TOK(REFERENCES)
RESTRICT      TOK(RESTRICT)
ROLLBACK      TOK(ROLLBACK)
SCHEMA        TOK(SCHEMA)
SELECT	      TOK(SELECT)
SET           TOK(SET)
SMALLINT      TOK(INTEGER)
SUM	      TOK(SUM)
TABLE         TOK(TABLE)
THEN          TOK(THEN)
TRUE          TOK(_TRUE)
UNION	      TOK(UNION)
UNIQUE        TOK(UNIQUE)
UPDATE        TOK(UPDATE)
VALUES        TOK(VALUES)
VARCHAR       TOK(VARCHAR)
VARYING       TOK(VARYING)
WHEN          TOK(WHEN)
WHERE	      TOK(WHERE)
WORK          TOK(WORK)
ISTREAM       TOK(ISTREAM) 
DSTREAM       TOK(DSTREAM) 
RSTREAM       TOK(RSTREAM) 
NOW           TOK(NOW) 
PARTITION     TOK(PARTITION) 
ROWS          TOK(ROWS) 
RANGE         TOK(RANGE) 
SECONDS       TOK(SECONDS)
MINUTES       TOK(MINUTES)

     /* comments */

"/*"			BEGIN(COMMENT);

<COMMENT><<EOF>>	{
  SQLerror("syntax error, end of file in comment,");
}
<COMMENT>[^*]* 	/* eat anything that's not a '*' */
<COMMENT>"*"+[^*/]* 	/* eat '*'s not followed by '/'s */
<COMMENT>"*"+"/" 	BEGIN(INITIAL);

	/* comparison */

"="	TOK(EQ)
"<>"	TOK(NEQ);
"<"	TOK(LT)
">"	TOK(GT)
"<="	TOK(LTE)
">="	TOK(GTE)

	/* Parameter marker */

"?"	TOK(PARAM)     

[-+*/:()\[\\\];,]	TOK(yytext[0])
"."		{return yytext[0];}

	/* names */

[a-zA-Z][A-Za-z0-9_]*  TOK(NAME)
        /* [a-zA-Z][A-Za-z0-9_]*"."[a-zA-Z][A-Za-z0-9_]*  TOK(COLUMN) */


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
                  SQLlval.oidval = mkstring(yytext+1); SAVE_REF;
		  return STRING;
		}

'[^'\n]*$	{SQLerror("Unterminated string");}

	/* whitespace */

[ \t\r\f\n]+	{;}	/* whitespace */

"\0"			return(_EOF);
<<EOF>>			return(_EOF);

	/* anything else */
.		{SQLerror("syntax error, invalid character");}


%%



int SQLwrap(void)
{
  return 1;
}
