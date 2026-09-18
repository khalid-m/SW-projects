/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1997 Tore Risch, EDSLAB
 * $RCSfile: alisp.h,v $
 * $Revision: 1.19 $ $Date: 2013/03/28 19:04:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Lisp <-> C interface
 ****************************************************************************/

#ifndef _alisp_h_
#define _alisp_h_

#include "callin.h"

/*** Lisp storage structures ***/

struct extfncell /* C function called from ALisp, type EXTFN */
{
  objtags tags;
  short int evalargs; /* Number of arguments, NO_EVAL or NO_SPREAD */
  oidtype name;       /* Name of function */
  oidtype next;       /* next SUBR */
  Lispfunction fnaddr;/* Address of C function */
};

struct closurecell    /* ALisp closure */
{
  objtags tags;
  short int hasstatlink;
  oidtype function, nxt, bindings, statlink;
  struct bindenv *stkptr;
};

/*** Tags for external C functions called from ALisp ***/

#define NOEVAL 0
#define NO_SPREAD -1
#define NO_EVAL -2

/*** Macros to pick up actual arguement when variable arity***/

#define nthargval(xenv,xpos) xenv[xpos].val
                                           /* Value of n:th argument of SUBR */
#define arg_start(arg,env) (arg = env + 1)
                                   /* initialize pointer to current argument */
#define arg_varp(arg) (arg->env==NULL)
                                 /* TRUE if current arg is not last argument */
#define arg_next(arg) ((void)++arg)
                                               /* increment arg list pointer */
#define arg_val(arg) arg->val
                                                /* Value of current argument */
#define arg_nextval(arg) (arg++)->val
                            /* increment arg list pointer and get next value */
#define arg_var(arg) arg->var

/*** Signatures of ALisp functions implemented in C ***/

typedef oidtype (*Lispfunction0) (bindtype);
typedef oidtype (*Lispfunction1) (bindtype,oidtype);
typedef oidtype (*Lispfunction2) (bindtype,oidtype,oidtype);
typedef oidtype (*Lispfunction3) (bindtype,oidtype,oidtype,oidtype);
typedef oidtype (*Lispfunction4) (bindtype,oidtype,oidtype,oidtype,oidtype);
typedef oidtype (*Lispfunction5) (bindtype,oidtype,oidtype,oidtype,oidtype,
                                  oidtype);
typedef oidtype (*Lispfunctionn) (bindtype,bindtype);

/*** Defining ALisp functions in C ***/

EXTERN void extfunction0(char *,Lispfunction0);
EXTERN void extfunction1(char *,Lispfunction1);
EXTERN void extfunction2(char *,Lispfunction2);
EXTERN void extfunction3(char *,Lispfunction3);
EXTERN void extfunction4(char *,Lispfunction4);
EXTERN void extfunction5(char *,Lispfunction5);
EXTERN void extfunctionn(char *,Lispfunctionn);
EXTERN void extfunctionq(char *,Lispfunctionn);

/*** Some common ALisp functions implemented in C ***/

EXTERN oidtype carfn(bindtype, oidtype);
EXTERN oidtype cdrfn(bindtype, oidtype);
EXTERN oidtype putffn(bindtype,oidtype l,oidtype i, oidtype v);
EXTERN oidtype getffn(bindtype, oidtype l,oidtype i);
EXTERN oidtype putpropfn(bindtype env, oidtype a, oidtype i, oidtype v);
EXTERN oidtype getpropfn(bindtype env,oidtype a,oidtype i);
EXTERN oidtype rempropfn(bindtype env, oidtype a, oidtype i);
EXTERN oidtype appendfn(bindtype,oidtype,oidtype);
EXTERN oidtype concat2fn(bindtype,oidtype,oidtype);
EXTERN oidtype nconcfn(bindtype env,oidtype x,oidtype y);
EXTERN oidtype nconc1fn(bindtype,oidtype,oidtype);
EXTERN oidtype subpairfn(bindtype env, oidtype old, oidtype nw, oidtype tree);
EXTERN oidtype assqfn(bindtype env, oidtype x, oidtype l);
EXTERN oidtype assocfn(bindtype env, oidtype x, oidtype l);
EXTERN oidtype memqfn(bindtype env, oidtype x, oidtype l);
EXTERN oidtype reversefn(bindtype env, oidtype l);
EXTERN oidtype nreversefn(bindtype env, oidtype l);
EXTERN oidtype deletefn(bindtype env, oidtype x, oidtype l);
EXTERN oidtype unionfn(bindtype env, oidtype x, oidtype y, oidtype equal);
EXTERN oidtype set_differencefn(bindtype env, oidtype x, oidtype y, 
                                oidtype equal);
EXTERN oidtype mksymbolfn(bindtype env, oidtype x);
EXTERN oidtype minusfn(bindtype,oidtype);

/*** Hash tables ***/

EXTERN oidtype gethashfn(bindtype env,oidtype key,oidtype ht);
EXTERN oidtype remhashfn(bindtype env, oidtype key, oidtype ht);
EXTERN oidtype puthashfn(bindtype env,oidtype key, oidtype ht, oidtype val);
EXTERN oidtype hash_table_countfn(bindtype, oidtype ht);

/*** Calling ALisp interpreter from C ***/

EXTERN oidtype eval_forms(bindtype env, char *forms);
EXTERN oidtype evalfn(bindtype, oidtype form);
EXTERN oidtype applyfn(bindtype,oidtype fn,oidtype argl);
EXTERN oidtype call_lisp(oidtype fn,bindtype,int arity, ...);
EXTERN oidtype apply_lisp(oidtype fn,bindtype,int arity,oidtype args[]);
EXTERN oidtype applyarrayfn(bindtype env, oidtype fn, oidtype args);
EXTERN oidtype setfn(bindtype env,oidtype x, oidtype val);
EXTERN int envarity(bindtype);                     /* arity of NSUBR */
EXTERN void evalloop(char *prompter);

/*** Error handling ***/

EXTERN oidtype interror(int,oidtype);
EXTERN oidtype hardresetfn(bindtype);
EXTERN int a_check_reset(bindtype);
typedef oidtype (*catch_function)(bindtype env,void *xa);
EXTERN oidtype a_catch(bindtype env,oidtype label,catch_function fn,void *xa,
                       int *caught);
EXTERN void a_throw(bindtype env, oidtype label, oidtype value);

/*** I/O ***/

EXTERN oidtype maketextstreamfn(bindtype env, oidtype size);
EXTERN oidtype textstreamstringfn(bindtype env, oidtype stream);
EXTERN oidtype loadfn(bindtype,oidtype,oidtype);
EXTERN oidtype openstreamfn(bindtype,oidtype,oidtype);
EXTERN oidtype closestreamfn(bindtype,oidtype);
EXTERN oidtype prin1fn(bindtype env, oidtype x, oidtype stream);
EXTERN oidtype princfn(bindtype env, oidtype x, oidtype stream);
EXTERN oidtype printfn(bindtype env,oidtype form,oidtype stream);
EXTERN oidtype princ_charcodefn(bindtype env, oidtype cc, oidtype stream);
EXTERN oidtype terprifn(bindtype env, oidtype stream);
EXTERN oidtype flushfn(bindtype env, oidtype stream);
EXTERN oidtype readfn(bindtype env,oidtype stream);     /* Read S-expression */
EXTERN oidtype unread_charcodefn(bindtype env, oidtype co, oidtype stream);
EXTERN oidtype read_charcodefn(bindtype env, oidtype stream);

/*** Debugging ***/

EXTERN void a_setdemon(oidtype loc, int val);
EXTERN void a_btv(int depth);
EXTERN void backtrace(bindtype env, int depth, int filtered);
EXTERN void printframe(bindtype,int);
EXTERN void dumpstack(bindtype,int);
EXTERN size_t frameno(bindtype e);
EXTERN int lsp_traceforms;              /* Traces EVERY ALisp call when TRUE */
EXTERN oidtype a_pgv(char *var);           /* Print global value of variable */
#endif



