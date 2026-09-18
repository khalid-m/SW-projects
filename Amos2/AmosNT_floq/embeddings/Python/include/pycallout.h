/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pycallout.h,v $
 * $Revision: 1.6 $ $Date: 2011/11/01 21:37:58 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python callers.
 * ===========================================================================
 * $Log: pycallout.h,v $
 * Revision 1.6  2011/11/01 21:37:58  torer
 * Replaced Python error messages with Amos errors
 *
 * Revision 1.5  2011/08/08 20:20:04  torer
 * Python foreign TBR definitions without binding patterns
 *
 * Revision 1.4  2011/06/01 15:10:58  roka4241
 * AmosObj objects containing any kind of oidtype are now hashable and comparable. Made NumPy optional by PYAMOS_NUMPY flag.
 *
 * Revision 1.3  2011/05/31 16:16:43  roka4241
 * Moved the amos context and pyamos callinfo into a pyamos context struct for faster loading and unloading during coroutine context switching.
 *
 * Revision 1.2  2011/05/18 15:03:45  roka4241
 * Fast nested loop join implemented using mapping over generators.
 *
 * Revision 1.1  2011/05/05 16:44:10  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.4  2011/05/02 18:05:57  roka4241
 * Better error handling and regression tests of invalid foreign function specifications that cause a_error errors.
 *
 * Revision 1.3  2011/04/27 18:16:35  roka4241
 * Turns out we do need an unwind protect wrapping iterator emission. Settings for command line building and regression testing.
 *
 * Revision 1.2  2011/02/17 13:30:56  roka4241
 * Added support for binding patterns to allow unbound arguments and multidirectional functions.
 *
 * Revision 1.1  2011/01/31 18:16:07  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.3  2010/12/29 18:21:43  roka4241
 * Python objects and iterators can no longer be returned to amos. Added support for converting python lists and dicts to amos vectors. Unrecongized python objects will be iterated and their items emited if the object supports iteration. Removed the pyiter data type.
 *
 * Revision 1.2  2010/12/28 20:51:15  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.1  2010/12/25 00:56:38  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 *
 *
 *****************************************************************************/

#ifndef _PYCALLOUT_H
#define _PYCALLOUT_H

//#define PYAMOS_DEBUG
//#define PYAMOS_NUMPY

int PYAMOS_ERR_FIRST_COLON,
    PYAMOS_ERR_PREFIX,
    PYAMOS_ERR_SECOND_COLON,
    PYAMOS_ERR_MODULE_EMPTY,
    PYAMOS_ERR_MODULE_DEF, 
    PYAMOS_ERR_FUNC_MISSING, 
    PYAMOS_ERR_FUNC_DEF, 
    PYAMOS_ERR_FUNC_CALLABLE,

    PYAMOS_ERR_INVALID_BP, 
    PYAMOS_ERR_MALLOC_CALLINFO;

#define PYTHON_FOREIGN_SYNTAX " The syntax is 'py:[module.]function'"
#define PYTHON_BUILTIN_MODULE "__builtin__"
#define PYTHON_FOREIGN_PREFIX "py"

#define PYTHON_MODULE_MAXLEN 384
#define PYTHON_FUNCTION_MAXLEN 128
#define PYTHON_BP_MAXLEN 32

static int iPycalloutEnabled = FALSE; 

typedef struct pycallout_bp {
  int iArity;
  int iWidth;
  char arrcIn[PYTHON_BP_MAXLEN];
  char arrcOut[PYTHON_BP_MAXLEN];
} pycallout_bp_t;

typedef struct pycallout_ff {
    char sModule[PYTHON_MODULE_MAXLEN]; 
    char sFunction[PYTHON_FUNCTION_MAXLEN];
    char sBindingPattern[PYTHON_BP_MAXLEN];
} pycallout_ff_t;

typedef struct pycallout_callinfo {
  PyObject *pModule;
  PyObject *pFunction;
  pycallout_bp_t bp;
} pycallout_callinfo_t; /* todo: pycallout_callinfo is responsible for freeing all python objects contained within */

#define callinfo_arity(ci) ci->bp.iArity
#define callinfo_width(ci) ci->bp.iWidth

#define callinfo_argi(cxt, ci, i) ci->bp.arrcIn[i]
#define callinfo_reti(cxt, ci, i) ci->bp.arrcOut[i]

#define callinfo_arg(cxt, ci, i) a_arg(cxt, callinfo_argi(cxt, ci, i)+1)
#define callinfo_ret(cxt, ci, i) a_arg(cxt, callinfo_reti(cxt, ci, i)+1)


typedef struct pya_cxt {
    a_callcontext aCxt;
    pycallout_callinfo_t *pyaCi;
} pya_cxt_t;

pya_cxt_t pyaCxt;

oidtype pycallout_enabledfn(bindtype); /* Check if python callout is enabled */
int pycallout_parse_ff(char *fn, char *bpat, pycallout_ff_t *); 
                                     /* Parse python foreign function string */
int pycallout_bind(char *fn, char *bpat);
                  /* Register a python foreign function with pycallout_call. */
oidtype pycallout_reload_foreign(a_callcontext);      
                            /* Reload previously registred foreign function. */
oidtype pycallout_call(a_callcontext);                
                 /* Calls the python foreign functon that is associated with 
                    the currently called amos function. */
void pycallout_emit_iter(a_callcontext, pycallout_callinfo_t *, PyObject *);
void pycallout_emit_obj(a_callcontext, pycallout_callinfo_t *, PyObject *);

void pycallout_register(void);        /* Initialize python callout interface */

#endif
