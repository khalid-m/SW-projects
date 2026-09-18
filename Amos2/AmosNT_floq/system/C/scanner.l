/*-*-C-*-**********************************************************************
 * AMOS2
 *
 * Author: (c) 1993-2006 Martin Sköld, Tore Risch, Vanja Josifovski, 
 *                       EDSLAB, UDBL
 * $RCSfile: scanner.l,v $
 * $Revision: 1.34 $ $Date: 2013/01/25 18:09:06 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Scanner for AmosQL
 * ===========================================================================
 * $Log: scanner.l,v $
 * Revision 1.34  2013/01/25 18:09:06  torer
 * Parsing large integers to doubles
 *
 * Revision 1.33  2013/01/24 17:41:57  torer
 * *** empty log message ***
 *
 * Revision 1.30  2012/05/21 20:57:36  torer
 * Reserved word 'result' removed (gives syntax error)
 *
 * Revision 1.29  2012/02/03 18:03:38  torer
 * a:b allowed in identifiers for namespaces
 *
 * Revision 1.28  2012/02/03 16:02:31  torer
 * Extremely ugly definition of ID replaced
 *
 * Revision 1.27  2011/12/30 15:39:37  torer
 * *** empty log message ***
 *
 * Revision 1.26  2011/12/30 15:26:56  torer
 * Introduced flex_c, the last character read in a flexstream
 *
 * Revision 1.25  2011/11/25 14:31:40  torer
 * Removed debug printing
 *
 * Revision 1.24  2011/11/20 19:56:43  torer
 * mixup of parser line buffers between SQL and AmosQL scanners
 *
 * Revision 1.23  2011/11/17 21:44:33  torer
 * A more modular C interface to parsers fro different languages
 *
 * Revision 1.22  2011/11/17 11:23:43  torer
 * SQL parser integrated
 * Try:  amos2 -q SQL
 *
 * Revision 1.21  2011/11/16 22:01:59  torer
 * Leaner parser interface
 *
 * Revision 1.20  2011/11/16 12:12:37  torer
 * Support for multiple parsers
 *
 * Revision 1.19  2011/04/27 12:27:10  torer
 * revert to old scanner.l
 *
 * Revision 1.15  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.14  2011/01/28 09:17:26  torer
 * 'result' -> PSM's 'return'
 *
 * Revision 1.13  2011/01/27 21:05:14  torer
 * Added nomore(Scan)
 * and the PSM control structures 'loop' and 'while'
 *
 * Revision 1.12  2011/01/26 20:58:51  torer
 * Mulitiple assinments allowed in procedural functions
 *
 * Revision 1.11  2010/12/29 10:31:38  torer
 * @ did not scan correctly
 *
 * Revision 1.10  2010/12/27 10:16:20  torer
 * C warnings removed
 *
 * Revision 1.9  2009/11/20 15:00:03  zeitler
 * power(Number, Number)->Number infix operator ^
 * elempower(Vector of Number, Number)->Vector of Number infix operator .^
 *
 * Revision 1.8  2009/09/30 15:05:47  zeitler
 * DOTDOV, DOTMUL: element-wise vector operations
 *
 * Revision 1.7  2008/11/17 20:22:25  torer
 * General functional expressions as function bodies
 *
 * Revision 1.6  2008/09/27 15:36:06  torer
 * New syntax for 'vector selection' as in SCSQ:
 *
 * vselect iota(2,10); <=> vectorof(select iota(2,20));
 *
 * Revision 1.5  2008/09/27 10:58:51  torer
 * Functional constants #'iota' <=> theresolvent('iota')
 *
 * Revision 1.4  2006/07/28 09:30:40  torer
 * Dead code removed
 *
 * Revision 1.3  2006/05/03 19:56:36  torer
 * Infix 'in' operator
 *
 * Revision 1.2  2006/04/15 18:48:24  torer
 * Possibility to specify 'key' on multidirectional implementation
 *
 * Revision 1.1  2006/04/14 19:11:17  torer
 * AmosQL parser added to repository
 *
 ****************************************************************************/

%{
#undef YY_USE_PROTOS
#define YY_USE_PROTOS 1
#include <memory.h>

#include "amos.h"

extern void yyerror(char *);
#define yyin_fs ((flexstream *)yyin)

#include "parser_tab.h"
#include <math.h>

  static char *string_bufp=NULL;
  static int string_buf_size = 0, string_buf_pos=0;

  /********************* flexstream interface ************************/
  /* Interface must be here since lex defines parser specific macros */
  /*******************************************************************/

  YY_BUFFER_STATE yy_create_buffer( FILE *file, int size );
  void yy_delete_buffer( YY_BUFFER_STATE b );

  void yy_initialize_flexstream(flexstream *fs)
    /*** called when parser has changed from other parser to this parser ***/
    {
      fs->buffer = (char *)yy_create_buffer((FILE*)fs,YY_BUF_SIZE);
    }

  void yy_finalize_flexstream(flexstream *fs)
    /*** called before parser changes from this parser to other parser ***/
    {
      yy_delete_buffer((YY_BUFFER_STATE)fs->buffer);
    }

  void yyerror(char *msg)
    /*** called when parser syntax error detected ***/
    { 
      a_parse_error((flexstream *)yyin, msg);
    }

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size)\
        result = a_flexstream_getc((flexstream *)yyin, buf)

  /*******************************************************************/

  void add_stringbuff(char c)
    {
      if(string_bufp == NULL)
	{
	  string_bufp = malloc(10);
	  string_buf_size = 10;
	}
      if(string_buf_pos >= string_buf_size-2)
	{
	  string_buf_size = 2*string_buf_size;
	  string_bufp = myrealloc(string_bufp, string_buf_size);
	}
      string_bufp[string_buf_pos]=c;
      string_buf_pos++;
    }

%}

DIGIT 	[0-9]
EDIGIT ["e""E"][+-]?{DIGIT}+
ID [a-zA-Z_?#][A-Za-z0-9_#:]*[A-Za-z0-9_#]|[a-zA-Z_?#]
%x COMMENT STRING STRING1 OID_NUM END_OF_OID
%%


"/*"			BEGIN(COMMENT);

<COMMENT><<EOF>>	{
  BEGIN(INITIAL);
  yyerror("syntax error, end of file in comment,");
}
<COMMENT>[^*]* 	/* eat anything that's not a '*' */
<COMMENT>"*"+[^*/]* 	/* eat '*'s not followed by '/'s */
<COMMENT>"*"+"/" 	BEGIN(INITIAL);

"\""			{
  BEGIN(STRING);
}
<STRING><<EOF>>		{
  BEGIN(INITIAL);
  yyerror("syntax error, end of file in string,");
}
<STRING>[^\"^\\]	{ /* save everything that's not a '"' or '\' */
  add_stringbuff(*yytext);
}
<STRING>"\\".            { /* Escape */
  add_stringbuff(yytext[1]);
}
<STRING>"\""	 	{ /* end of string */
  add_stringbuff('\0');
  yylval.oidval = mkstring(string_bufp);
  string_buf_pos=0;
  BEGIN(INITIAL);
  return(_STRING_CONST);
}

"\'"			{
  BEGIN(STRING1);
}
<STRING1><<EOF>>	{
  BEGIN(INITIAL);
  yyerror("syntax error, end of file in string,");
}
<STRING1>[^\']	 	{ /* save everything that's not a "'" */
  add_stringbuff(*yytext);
}
<STRING1>"\'"	 	{
  add_stringbuff('\0');
  yylval.oidval = mkstring(string_bufp);
  string_buf_pos=0;
  BEGIN(INITIAL);
  return(_STRING_CONST);
}

"\0"			return(_EOF);
<<EOF>>			return(_EOF);

[ \t\n]+		/* whitespace */

{DIGIT}+		{
  yylval.oidval = a_encodeNumeric(yytext);
  return(_INTEGER_CONST);
}

{DIGIT}+{EDIGIT}	{ 
  yylval.oidval = mkreal(atof(yytext));
  return(_REAL_CONST);
}

{DIGIT}*"."{DIGIT}+ {   
  yylval.oidval = mkreal(atof(yytext));
  return(_REAL_CONST);
}

{DIGIT}*"."{DIGIT}*{EDIGIT} { 
  yylval.oidval = mkreal(atof(yytext));
  return(_REAL_CONST);
}

true			{
  yylval.oidval = mksymbol("true");
  return(_BOOLEAN_CONST);
}
false			{
  yylval.oidval = mksymbol("false");
  return(_BOOLEAN_CONST);
}

"+" 			return(_PLUS);
"-" 			return(_MINUS);
"*" 			return(_TIMES);
".*"                    return(_DOTTIMES);
"/" 			return(_DIVIDE);
"./" 			return(_DOTDIVIDE);
and 			return(_AND);
or 			return(_OR);
"=" 			return(_EQUAL);
"<" 			return(_LESS);
">" 			return(_GREATER);
"<=" 			return(_LESSEQ);
">=" 			return(_GREATEREQ);
"!=" 			return(_UNEQUAL);
"(" 			return(_LEFTPAREN);
")" 			return(_RIGHTPAREN);
"[" 			return(_LEFTBRACKET);
"]" 			return(_RIGHTBRACKET);
"{" 			return(_LEFTCURL);
"}" 			return(_RIGHTCURL);
"," 			return(_COMMA);
"." 			return(_DOT);
"^" 			return(_CARET);
".^" 			return(_DOTCARET);
":" 			return(_COLON);
";" 			return(_SEMICOLON);
"@"                     return(_ALPHAB);
"|"                     return(_BAR);
"#"                     return(_HASH);
begin 			return(_BEGIN);
declare			return(_DECLARE);
end 			return(_END);
create 		yyin_fs->key_pos = dr(yyin_fs->logstream,textstreamcell)->pos-7;	return(_CREATE);
delete 			return(_DELETE);
set 			return(_SET);
add 			return(_ADD);
to 			return(_TO);
remove 			return(_REMOVE);
from 			return(_FROM);
"->" 			return(_ARROW);
as 			return(_AS);
key 			return(_KEY);
nonkey 			return(_NONKEY);
stored 			return(_STORED);
foreign 		return(_FOREIGN);
type 			return(_TYPE);
subtype 		return(_SUBTYPE);
under                   return(_UNDER);
supertype 		return(_SUPERTYPE);
function 		return(_FUNCTION);
functions 		return(_FUNCTIONS);
in                      return(_IN);
on 			return(_ON);
off 			return(_OFF);
properties 		return(_PROPERTIES);
instances 		return(_INSTANCES);
rule 			return(_RULE);
when 			return(_WHEN);
do 			return(_DO);
activate 		return(_ACTIVATE);
deactivate 		return(_DEACTIVATE);
priority   		return(_PRIORITY);
strict   		return(_STRICT);
multidirectional        return(_MULTIDIRECTIONAL);
cost                    return(_COST);
rewriter                return(_REWRITER);
select 			return(_SELECT);
vselect                 return(_VSELECT);
distinct 		return(_DISTINCT);
original                return(_ORIGINAL);
for 			return(_FOR);
each 			return(_EACH);
where 			return(_WHERE);
if			return(_IF);
then			return(_THEN);
else			return(_ELSE);
bag 			return(_BAG);
Bag                     return(_BAG);
of 			return(_OF);
vector 			return(_VECTOR);
return 			return(_RETURN);
open 			return(_OPEN);
into 			return(_INTO);
close 			return(_CLOSE);
fetch 			return(_FETCH);
logging 		return(_LOGGING);
imagesize 		return(_IMAGESIZE);
save 			return(_SAVE);
commit			return(_COMMIT);
rollback		return(_ROLLBACK);
lisp			return(_LISP);
quit			return(_QUIT);
exit			return(_EXIT);
at                      return(_AT);
within                  return(_WITHIN);
updated                 return(_UPDATED);
added                   return(_ADDED);
removed                 return(_REMOVED);
deleted                 return(_DELETED);
created                 return(_CREATED);
after                   return(_AFTER);
before                  return(_BEFORE);
derived                 return(_DERIVED);
validate                return(_VALIDATE);
case                    return(_CASE);
cast                    return(_CAST);
loop                    return(_LOOP);
leave                   return(_LEAVE);
while                   return(_WHILE);
"#[OID "                return(_OIDTAG);

":"{ID}			{
  a_toupper(yytext); /* real toupper */
  yylval.oidval = mksymbol(yytext);
  return(_IVAR);
}
{ID}			{
  a_toupper(yytext); /* real toupper */
  yylval.oidval = mksymbol(yytext);
  return(_ID);
}
.			{
  yyerror("syntax error, illegal character,");
}
