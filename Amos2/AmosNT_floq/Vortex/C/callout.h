/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: callout.h,v $
 * $Revision: 1.18 $ $Date: 2013/04/17 21:48:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 C call-out interface
 ****************************************************************************/

#ifndef _callout_h_
#define _callout_h_

#include "callin.h"
#include "alisp.h"

/**************************  Internals ***************************************/

typedef void (*cont_function) (const bindtype,void *); 
/* internal continuation fn */

typedef struct a_callcontextrec /* Context of ObjectLog call */
{
  bindtype env;         /* Internal ObjectLog binding environment */
  bindtype eenv;        /* Environment for emit */
  oidtype *inparams;    /* In parameters in call */
  oidtype fno;          /* OID of called function */
  oidtype extp;         /* The internal object representing the predicate */
  cont_function contfn; /* Internal continuation function */
  void *xa;             /* Internal system parameters */
  int done;             /* Set to TRUE when caller does not want more data */
  oidtype res;          /* Result thrown by a_map_done */
  void *userdata;       /* Arbitrary user data structure. Initialized to NULL*/
  int traceindent;      /* ObjectLog trace indentation */
} *a_callcontext;

/* Internal macro: */
#define dcl_cxt_init(cxt,e)((cxt)->env = e, (cxt)->fno=nil,\
(cxt)->extp=nil, (cxt)->done=FALSE, (cxt)->res=nil,cxt)

EXTERN short int extpredtype;

typedef oidtype(*external_implementation) (a_callcontext);
/* ObjectLog external predicate implementation */

typedef void (*external_function) (a_callcontext, a_tuple);
/* Old external predicate prototype (backward compatibility) */

struct extpredcell                 /* External predicates implemented in C */
{
  objtags tags;
  external_implementation cfn;     /* C function to be called */
  external_function ocfn;          /* Implementation of old foreign function */
  oidtype name;                    /* External function name */
  oidtype next;                    /* extpredcells are linked together */
  void *param;                     /* Arbitrary user parameter */
};

/***** Basic interface to external ObjectLog predicates ******************/

/* Declare new context in the global binding environment: */
#define dcl_global_cxt(cxt) struct a_callcontextrec __ ## cxt; \
                     a_callcontext cxt = dcl_cxt_init(&__ ## cxt,varstack)

/* Declare new context in local binding environment e: */
#define dcl_local_cxt(cxt,e) struct a_callcontextrec __ ## cxt; \
                     a_callcontext cxt = dcl_cxt_init(&__ ## cxt,e)

EXTERN oidtype a_extimpl(char *name,external_implementation fn);
/* Bind external ObjectLog TBR name to C implementation function */

EXTERN int a_result(const a_callcontext cxt); 
/* Emit current result tuple. May fail if mapping terminated */

#define a_arg(cxt,no) nthargval((cxt)->eenv,(no))
/* Accesses argument value number no in external predicate. 
   The arguments are enumerated 1 and up */

#define a_isarg(cxt, no) ((cxt)->eenv[no]).env==NULL 
/* TRUE if argument number no is not a frame delimiter */

#define a_bind(cxt,no,v) a_setf(a_arg(cxt,no),v)
/* Binds result parameter of external predicate */

#define a_arity(cxt) envarity((cxt)->eenv)
/* Returns the arity of called predicate */

EXTERN void a_printcall(a_callcontext cxt);
/* Print function call for tracing */

EXTERN void a_printresult(a_callcontext cxt);
/* Print function result emitted for tracing */

#define a_env(cxt) (cxt)->env
/* Returns environment for error handling */

#define a_extpredname(cxt) getstring(dr((cxt)->extp,extpredcell)->name)
/* Picks up the name of the called predicate from a context */

EXTERN struct extpredcell *a_getextpred(char *name);
/* Picks up external predicate object, given external predicate name */

#define a_extpredparam(cxt) (dr((cxt)->extp,extpredcell)->param)
/* Picks up parameter of called predicate from context */

#define a_setpredparam(name,val) a_getextpred(name)->param = (val)
/* Sets parameter field of named external predicate */

typedef oidtype(*mapper_function)(a_callcontext cxt, int width, 
				  oidtype *restpl, void *xa);
/* Mapper functions are applied on each result tuple restpl
   with given width as result of Amos II function call.
   xa is user pointer provided parameter to map function call
   The result is ignored, normally nil */

EXTERN oidtype a_mapfunction(a_callcontext cxt, oidtype fno, oidtype args,
                             mapper_function Mfn, void *xa);
/* Apply mapper function Mfn on each result of Amos II function 
   fno applied on argument list args (vector or list)
   xa is parameter passed to mapper function Mfn */

EXTERN oidtype a_mapfunctionC(a_callcontext cxt, oidtype fno, int arity,
			      oidtype args[], mapper_function Mfn, void *xa);
/* Apply mapper function Mfn on each result of Amos II function fno with
   given argument list in array args for given arity.
   xa is parameter passed to mapper function Mfn */

EXTERN oidtype a_mapbag(a_callcontext cxt, oidtype bag, mapper_function Mfn,
                        void *xa);
/* Apply mapper function Mfn on each tuple in bag.
   xa is parameter passed to Mfn */

EXTERN void a_map_done(a_callcontext cxt, oidtype res);
/* Stop iteration in mapper function
   and return res as result of map function */

EXTERN int a_load_extension(char *extensionName, char *defaultDir);
/* Load extender named 'extensionName'. 
   Look first in current directory, then in defaultDir */

/***** Old style interface to foreign functions ***************/

EXTERN a_connection a_callback_connection; 
/* Connection when calling back from foreign function */

EXTERN oidtype a_extfunction(char *name,external_function fn);
/* Register external predicate */

EXTERN int a_emit(a_callcontext cxt, a_tuple t, int catcherror);
/* Emit a tuple as the result from foreign predicate */

EXTERN oidtype a_resultarray(int width, oidtype *restpl);
/* Convert new style result tuple in mapper to array */

#endif
