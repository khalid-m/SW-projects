/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Tore Risch, Markus Jägerskogh, UDBL
 * $RCSfile: SQLParse.c,v $
 * $Revision: 1.5 $ $Date: 2013/04/29 14:11:15 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SQL parser in Amos II
 *
 ****************************************************************************/
#include "storage.h"
#include "alisp.h"
#define reverse(x)(call_lisp(mksymbol("nreverse"),varstack,1,x))
extern int SQLparse(void); /* Bison generated parse function */
char *myinputptr;   /* Argument to parse function */
int mybufsize;      /* Length of argument to parse function */
extern oidtype sql_statement; /* Result from parse function.
                                 failure -> nil */
char *parse_err    ;       /* Error message buffer */

oidtype sql_parsefn(bindtype env, oidtype str)
{
  /* Lisp foreign function to parse SQL string into S-expression */
  char *stmt;
  static char *buffer=NULL;
  static int buflen=0;
  int len;

  IntoString(str, stmt, env);
  len = 1+strlen(stmt);
  /* Dynamic buffer for statement to which stmt is copied */
  if(buffer==NULL)
    {

      buffer = malloc(len);
      buflen = len;
    }
  else if(len>buflen)
    {
      buffer = realloc(buffer,len);
      buflen = len;
    }
  memcpy(buffer, stmt, len); /* Copy stmt from database image to buffer */

  /* Call the parser */
  myinputptr = buffer;
  mybufsize = len;
  a_free(sql_statement);
  sprintf(parse_err, "");
  SQLparse();
  if (strlen(parse_err) > 0)
    call_lisp(mksymbol("error"),varstack,2,
	      mkstring("parse error at"), mkstring(parse_err));

  return sql_statement; 
}

void register_SQLParse(void)
{
  /* Register foreign functions */
  extfunction1("sql-parse",sql_parsefn);

  /* Allocate error message buffer for parser: */
  parse_err=(char*)malloc(100);
}
