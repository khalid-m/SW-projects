/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: expression.c,v $
 * $Revision: 1.3 $ $Date: 2013/05/31 09:18:25 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Query expression storage type
 * ===========================================================================
 * $Log: expression.c,v $
 * Revision 1.3  2013/05/31 09:18:25  torer
 * Introduced accessfilter predicates
 *
 * Revision 1.2  2011/01/20 18:26:48  torer
 * print function for storage type EXPRESSION
 *
 * Revision 1.1  2011/01/12 16:32:15  minzh812
 * New storage type EXPRESSION
 *
 * Revision 1.4  2006/02/13 07:37:48  torer
 ****************************************************************************/

#include "amos.h"
#include "storagetypes.h"

int expressiontype;

struct expressioncell
{
  objtags tags;
  oidtype filter;
  oidtype source;
  oidtype finalizer;
};

oidtype make_expressionfn(bindtype env, oidtype filter, oidtype source,
                          oidtype finalizer)
     /* Construct new expression with finalizer */
{
  oidtype res;
  struct expressioncell *dres;

  res = new_object(sizeof(*dres),expressiontype);
  dres = dr(res,expressioncell);
  a_let(dres->filter,filter);
  a_let(dres->source,source);
  a_let(dres->finalizer,finalizer);
  return res;  
}

void free_expression(oidtype x) 
{
  struct expressioncell *dx = dr(x,expressioncell);

  a_free(dx->filter);
  a_free(dx->source);
  a_free(dx->finalizer);
  dealloc_object(x);
}

void print_expression(oidtype x, oidtype stream, int princflg) 
{
  struct expressioncell *dx = dr(x, expressioncell);

  a_puts("#[EXPRESSION ",stream);
  a_prin1(dx->filter, stream, princflg);
  a_putc(' ',stream);
  a_prin1(dx->source, stream, princflg);
  a_putc(' ',stream);
  a_prin1(dx->finalizer, stream, princflg);
  a_putc(']',stream);
}


oidtype expression_filterfn(bindtype env, oidtype xp)
     /* Access query expression filter */
{
  OfType(xp, expressiontype, env);
  
  return dr(xp,expressioncell)->filter;
}

oidtype expression_sourcefn(bindtype env, oidtype xp)
     /* Access query expression data source  */
{
  OfType(xp, expressiontype, env);
  
  return dr(xp,expressioncell)->source;
}

oidtype expression_finalizerfn(bindtype env, oidtype xp)
     /* Acess query expression finalizer */
{
  OfType(xp, expressiontype, env);
  
  return dr(xp,expressioncell)->finalizer;
}

void register_expression(void)
{
  expressiontype = a_definetype("expression", free_expression, 
                                print_expression);
  extfunction3("make-expression", make_expressionfn);
  extfunction1("expression-filter", expression_filterfn);
  extfunction1("expression-source", expression_sourcefn);
  extfunction1("expression-finalizer", expression_finalizerfn);
}
