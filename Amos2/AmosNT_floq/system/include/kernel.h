/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $Revision:
 * $State:
 *
 * Description: Internal Lisp kernel declarations (not exported)
 *
 * Requirements:
 * ===========================================================================
 * $Log:
 */

#ifndef _kernel_h_
#define _kernel_h_

#include "intstorage.h"
#include "htbl.h"
#include "alisp.h"

#define feval(env,xx) (listp(xx) ? evallist(fhd(xx),ftl(xx),env,xx,NULL,0)\
 : evalatom(env,xx,FALSE)) /* Fast evaluation macro */
extern void stack_overflow(bindtype, oidtype);
extern void lsp_interrupthandler(int);
extern oidtype kwotefn(bindtype,oidtype);
extern oidtype evalatom(bindtype,oidtype,int);
extern oidtype lambda, nobind, evalsymbol;
extern oidtype evallist(oidtype fn,oidtype args,bindtype env,oidtype form,
                        const oidtype *argvec,int arity);
extern oidtype macro_functionfn(bindtype env,oidtype fn);
extern oidtype macroexpand(bindtype env, oidtype form, int depth);
extern oidtype symbol_functionfn(bindtype env, oidtype fn);
extern oidtype symbol_setfunctionfn(bindtype env, oidtype fn, oidtype def,
                                    oidtype macro);
oidtype a_printerror(bindtype env,int errnr,char *msg,oidtype x);

#define tonextenv(env1) while(env1!=varstack){(env1)--; \
    if((env1)->env != NULL)break;}

#define resetframe varstack+1
#define MAX_MACRO_DEPTH 50

#endif
