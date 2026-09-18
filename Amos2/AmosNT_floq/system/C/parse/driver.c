/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: driver.c,v $
 * $Revision: 1.2 $ $Date: 2009/09/02 07:51:25 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 driver program
 ****************************************************************************/

#include "amos.h"

extern FILE *EXPin;
extern int EXPparse (void);
extern oidtype EXP_statement;
extern unsigned int EXPerrno;
extern void register_resource(void);

oidtype parse_exprfn(bindtype env, oidtype str)
{
   flexstream fls;

   OfType(str, STREAMTYPE, env);
   init_flexstream(str,&fls);
   EXPin = (FILE *)&fls;
   printf("Parsing>");
   EXPparse();
   return EXP_statement;
}

main(int argc,char **argv)
{ 
  init_amos(argc,argv);
  register_resource();
  extfunction1("parse-expr", parse_exprfn);
  EXPerrno = a_register_error("in PARSE-EXPR");
  amos_toploop("Amos");
  return 0;
}
