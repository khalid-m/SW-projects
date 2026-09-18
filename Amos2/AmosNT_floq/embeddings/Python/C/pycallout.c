/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pycallout.c,v $
 * $Revision: 1.10 $ $Date: 2012/10/22 20:14:08 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python callout.
 * ===========================================================================
 * $Log: pycallout.c,v $
 * Revision 1.10  2012/10/22 20:14:08  torer
 * Foreign language (e.g. Python) code automatically loaded when saved in image
 *
 * Revision 1.9  2011/11/01 21:37:57  torer
 * Replaced Python error messages with Amos errors
 *
 * Revision 1.8  2011/08/08 20:20:03  torer
 * Python foreign TBR definitions without binding patterns
 *
 * Revision 1.7  2011/05/31 16:16:41  roka4241
 * Moved the amos context and pyamos callinfo into a pyamos context struct for faster loading and unloading during coroutine context switching.
 *
 * Revision 1.6  2011/05/31 15:19:01  roka4241
 * Fixed amos_map_func in callin. Record to dict conversion.
 *
 * Revision 1.5  2011/05/27 12:38:27  roka4241
 * All foreign function definitions will now reload their target module to detect code added since last time the module was loaded.
 *
 * Revision 1.4  2011/05/18 15:03:41  roka4241
 * Fast nested loop join implemented using mapping over generators.
 *
 * Revision 1.3  2011/05/16 15:56:13  roka4241
 * Implemented and tested nested loop join and mergejoin as python foreign functions. Started with a mapped nested loop join.
 *
 * Revision 1.2  2011/05/11 18:26:18  roka4241
 * Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
 *
 * Revision 1.1  2011/05/05 16:44:01  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.12  2011/05/02 18:05:54  roka4241
 * Better error handling and regression tests of invalid foreign function specifications that cause a_error errors.
 *
 * Revision 1.11  2011/04/28 18:27:07  roka4241
 * Merged pyiter.c/h into pyobj.c/h and made a new type pyitertype that is 'sort of' a subtype of pyobj.
 *
 * Revision 1.10  2011/04/27 18:16:30  roka4241
 * Turns out we do need an unwind protect wrapping iterator emission. Settings for command line building and regression testing.
 *
 * Revision 1.9  2011/04/27 14:23:43  torer
 * *** empty log message ***
 *
 * Revision 1.8  2011/04/26 17:52:55  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.7  2011/04/20 17:16:19  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.6  2011/04/07 17:48:16  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.5  2011/02/24 23:05:52  roka4241
 * Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
 *
 * Revision 1.4  2011/02/22 09:01:24  roka4241
 * *** empty log message ***
 *
 * Revision 1.3  2011/02/21 17:27:15  roka4241
 * *** empty log message ***
 *
 * Revision 1.2  2011/02/17 13:30:54  roka4241
 * Added support for binding patterns to allow unbound arguments and multidirectional functions.
 *
 * Revision 1.1  2011/01/31 18:16:04  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.5  2010/12/31 15:42:00  roka4241
 * Python dicts are now translated to Amos records. Why are we using make_recordfn, record_getfn and record_putfn instead of make_record, record_get, record_put? The latter don't seem to be included in amoslib.lib, but why?
 *
 * Revision 1.4  2010/12/29 18:21:39  roka4241
 * Python objects and iterators can no longer be returned to amos. Added support for converting python lists and dicts to amos vectors. Unrecongized python objects will be iterated and their items emited if the object supports iteration. Removed the pyiter data type.
 *
 * Revision 1.3  2010/12/28 20:51:13  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.2  2010/12/25 15:50:33  roka4241
 * Added support for any Python return type by wrapping any unrecognized Python object in a new pyobj data type. Some refactoring.
 *
 * Revision 1.1  2010/12/25 00:56:35  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 *
 *
 *****************************************************************************/
#include <Python.h>
#include "callout.h"
#include "language.h"
#include "amosmodule.h"
#include "pycallout.h"
#include "pymodule.h"
#include "pyobj.h"
#include "stdarg.h"
#include "assert.h"
#include "a_time.h"

int pycallout_enabled(void) 
{
  return iPycalloutEnabled;
}

oidtype pycallout_enabledfn(bindtype env)
{
  if(pycallout_enabled()) return t;
  return nil;
}

int pycallout_parse_bp(char *sBindingPattern, pycallout_bp_t *bp) 
{
  // note: changes sBindingPattern
  int i; 

  bp->iArity = 0;
  bp->iWidth = 0;
  for (i=0; i<PYTHON_BP_MAXLEN, *sBindingPattern != '\0'; 
       i++, sBindingPattern++) 
    {
      if (*sBindingPattern == 'b') 
	{
	  bp->arrcIn[bp->iArity] = i;
	  bp->iArity++;
	} 
      else if (*sBindingPattern == 'f') 
	{
	  bp->arrcOut[bp->iWidth] = i;
	  bp->iWidth++;
	} 
      else 
	{
#ifdef PYAMOS_DEBUG
	  fprintf(stderr, "The binding pattern may only contain the letters 'b' for bound and 'f' for free. Found '%c' at position %i.", *sBindingPattern, i);
#endif
	  a_error_str(PYAMOS_ERR_INVALID_BP, sBindingPattern, FALSE);
	  return 1;
	}
    }
  return 0;
}

int pycallout_parse_ff(char *sForeignName, char *bpat, pycallout_ff_t *ff) 
{
  int iModuleLen;
  char *sColon;
  char *sLastDot;

  // find the colon
  sColon = strchr(sForeignName, ':');
  if (sColon == NULL) 
    {
      a_error_str(PYAMOS_ERR_FIRST_COLON, sForeignName, FALSE);
      return 1;
    }

  // make sure the foreign function definition begins with 'py'
  if (strncmp(sForeignName, PYTHON_FOREIGN_PREFIX, sColon-sForeignName) 
      != 0) 
    {
      a_error_str(PYAMOS_ERR_PREFIX, sForeignName, FALSE);
      return 1;
    }

  // copy binding pattern
  strcpy(ff->sBindingPattern, bpat);

  // look for dot that indicates a module is specified
  sLastDot = strrchr(sForeignName, '.');
  if (sLastDot == NULL) 
    {
      strcpy(ff->sModule, PYTHON_BUILTIN_MODULE);
      strcpy(ff->sFunction, &sColon[1]);
    } 
  else 
    {
      iModuleLen = sLastDot-sColon-1;
      strncpy(ff->sModule, &sColon[1], iModuleLen);
      ff->sModule[iModuleLen] = '\0';
  
      // make sure the module name is not empty
      if (strlen(ff->sModule) == 0) 
	{
	  a_error_str(PYAMOS_ERR_MODULE_EMPTY, sForeignName, FALSE);
	  return 1;
	}

      strcpy(ff->sFunction, &sLastDot[1]);
    }
  // make sure the function name is not empty
  if (strlen(ff->sFunction) == 0) 
    {
      a_error_str(PYAMOS_ERR_FUNC_MISSING, sForeignName, FALSE);
      return 1;
    }
  return 0;
}

int pycallout_bind(char *sForeignName, char *bpat) 
{
  PyObject *pModule, *pFunction;
  pycallout_callinfo_t *ci;
  pycallout_ff_t ff;

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entered pycallout_bind\n");
#endif

  if (pycallout_parse_ff(sForeignName, bpat, &ff) != 0) return FALSE;
  pModule = pymodule_reload(ff.sModule);

  /* Check if the module import suceeded. */
  if (!pModule) 
    {
#ifdef PYAMOS_DEBUG
      fprintf(stderr, "pycallout_bind: Failed to import module %s.\n", 
	      ff.sModule);
#endif
      a_error_str(PYAMOS_ERR_MODULE_DEF, sForeignName, FALSE);
      return (FALSE);
    }

  pFunction = PyObject_GetAttrString(pModule, ff.sFunction); 
  // Py_DECREF(pModule); note: the callinfo object is responsible 
  // for decrementing pModule

  /* Couldn't find function */
  if (PyErr_Occurred()) 
    {
      Py_DECREF(pModule); 
      //PyErr_Print();
      //PyErr_Clear();
      a_error_str(PYAMOS_ERR_FUNC_DEF, sForeignName, FALSE);
      return (FALSE);
    }

  /* Found something that isn't callable */
  if (!PyCallable_Check(pFunction)) 
    {
      Py_DECREF(pModule); 
      Py_DECREF(pFunction); 
#ifdef PYAMOS_DEBUG
      fprintf(stderr, "pycallout_bind: Found '%s' in module '%s', but it is not callable. Is it a function?\n", 
	      ff.sFunction, ff.sModule);
#endif
      a_error_str(PYAMOS_ERR_FUNC_CALLABLE, sForeignName, FALSE);
      return (FALSE);
    }

  // Build a callInfo struct
  if ((ci = (pycallout_callinfo_t *)
       malloc(sizeof(pycallout_callinfo_t))) == NULL) 
    {
      fprintf(stderr, "pycallout_bind: Can't allocate memory for callinfo object.\n");
      return (FALSE);
    }
  ci->pModule = pModule;
  ci->pFunction = pFunction;

  pycallout_parse_bp(ff.sBindingPattern, &ci->bp);

  // Register foreign function
  a_extimpl(sForeignName, pycallout_call);

  // Save callInfo struct
  a_setpredparam(sForeignName, (char *)ci);

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "leaving pycallout_bind\n");
#endif

  return TRUE;
}

oidtype pycallout_bindfn(bindtype env, oidtype oForeignName, oidtype bpat)
{
  char *sForeignName, *sbpat;

  IntoStackString(oForeignName, sForeignName, env);
  IntoStackString(bpat, sbpat, env);
  if(pycallout_bind(sForeignName, sbpat)) return t;
  return nil;
}

oidtype pycallout_reload_foreign(a_callcontext cxt) 
{
  PyObject *pModule, *pFunction;
  char *sForeignName;
  oidtype oForeignName;
  pycallout_callinfo_t *ci;
  pycallout_ff_t ff;

  oForeignName = a_arg(cxt, 1);
  IntoString(oForeignName, sForeignName, a_env(cxt));

  printf("reload_foreign disabled\n");
  //if (pycallout_parse_ff(sForeignName, &ff) != 0) {
  return (FALSE);
  // }

  
  //remove("C:\\AmosNT\\embeddings\\Python\\callout\\regress\\reload.pyc");
 
  ci = (pycallout_callinfo_t *)(a_getextpred(sForeignName)->param);


  // Remove previously created bytecode
  //pFilename = PyObject_GetAttrString(ci->pModule, "__file__"); 
  //fprintf(stderr, "filename: %s\n", PyString_AsString(pFilename));
  //Py_DECREF(pFilename);
  

  pModule = pymodule_reload(ff.sModule);
  if (pModule == NULL) {
    return nil;
  }

  pFunction = PyObject_GetAttrString(pModule, ff.sFunction); 
  /* Couldn't find function */
  if (PyErr_Occurred()) {
    Py_DECREF(pModule);
    PyErr_Print();
    fprintf(stderr, "pycallout_reload: Can't find function '%s' in module '%s'.\n", 
	    ff.sFunction, ff.sModule);
    return (FALSE);
  }

  /* Found something that isn't callable */
  if (!PyCallable_Check(pFunction)) {
    Py_DECREF(pModule);
    Py_DECREF(pFunction); 
    fprintf(stderr, "pycallout_reload: Found '%s' in module '%s', but it is not callable.\n", 
	    ff.sFunction, ff.sModule);
    return (FALSE);
  }

  Py_DECREF(ci->pModule);
  Py_DECREF(ci->pFunction);

  ci->pModule = pModule;
  ci->pFunction = pFunction;
  //pycallout_parse_bp(ff.sBindingPattern, &ci->bp);
  return t;
}

oidtype pycallout_call(a_callcontext aCxt) 
{
  int i, iArity;
  PyObject *pFunction, *pArgs, *pValue;
  oidtype oArg;
  pycallout_callinfo_t *pyaCi;

  pya_cxt_t pyaOldCxt;


#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entered pycallout_call\n");
#endif

  pyaCi = (pycallout_callinfo_t *)a_extpredparam(aCxt);
  iArity = callinfo_arity(pyaCi);
  pFunction = pyaCi->pFunction;
  pArgs = PyTuple_New(iArity);

  /* Create argument tuple */
  for (i=0; i<iArity; i++) 
    {
      oArg = callinfo_arg(aCxt, pyaCi, i); 

      pValue = obj_to_pyobj(oArg);

      if (PyErr_Occurred()) 
	{
	  Py_DECREF(pFunction);
	  Py_DECREF(pArgs);

	  PyErr_Print();
	  fprintf(stderr, "Cannot convert argument %d\n", i);
	  return nil;
	}
      PyTuple_SetItem(pArgs, i, pValue);
    }

  // Keep track of the current python callout contex, so that we know where to emit in case of mapping
  pyaOldCxt.aCxt = pyaCxt.aCxt;
  pyaOldCxt.pyaCi = pyaCxt.pyaCi;
  {unwind_protect_begin;
  pyaCxt.aCxt = aCxt;
  pyaCxt.pyaCi = pyaCi;
  pValue = PyObject_CallObject(pFunction, pArgs);
  unwind_protect_catch;
  pyaCxt.aCxt = pyaOldCxt.aCxt;
  pyaCxt.pyaCi = pyaOldCxt.pyaCi;
  unwind_protect_end;}

  // Py_DECREF(pFunction); todo: the callinfo object is responsible for decrementing this
  Py_DECREF(pArgs);
  
  if (PyErr_Occurred()) 
    {
      PyErr_Print();
      fprintf(stderr, "pycallout_call: Function call failed.\n");
      return nil;
    }

  // Emit python object
  pycallout_emit_obj(aCxt, pyaCi, pValue); 
  Py_DECREF(pValue);

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "leaving pycallout_bind\n");
#endif

  return nil;
}

void pycallout_emit_iter(a_callcontext cxt, pycallout_callinfo_t *ci, 
			 PyObject *pIter) 
{
  PyObject *pItem;

  while (pItem = PyIter_Next(pIter)) 
    {
      pycallout_emit_obj(cxt, ci, pItem);
      Py_DECREF(pItem);           
    }
}


void pycallout_emit_obj(a_callcontext cxt, pycallout_callinfo_t *ci, 
			PyObject *pObj) 
{
  int i, iWidth;
  oidtype oRet;

  //iArity = a_arity(cxt);
  iWidth = callinfo_width(ci);

  oRet = pyobj_to_obj(cxt->env, pObj);

  if (oRet == nil) return;

  // Emit all elements of an iterator
  if (a_datatype(oRet) == PYITERTYPE) 
    {
      unwind_protect_begin;
      pycallout_emit_iter(cxt, ci, pyobj_getobj(oRet));
      unwind_protect_catch;
      release(oRet);
      unwind_protect_end;
    } 
  else if (iWidth == 1) 
    {
      // The function has a single return variable
      a_bind(cxt, callinfo_reti(cxt, ci, 0)+1, oRet); 
      a_result(cxt);
    } 
  else 
    {
      // ... or multiple variables were returned
      for (i=0; i<iWidth; i++) 
	{
	  a_bind(cxt, callinfo_reti(cxt, ci, i)+1, a_elt(oRet, i));    
	}
      a_result(cxt); 
    }
}

void pycallout_register_errors(void) 
{
  PYAMOS_ERR_FIRST_COLON  = a_register_error("PYAMOS_ERR_FIRST_COLON, \
Colon (:) missing from foreign function definition");
  PYAMOS_ERR_PREFIX       = a_register_error("PYAMOS_ERR_PREFIX, \
A python foreign function definition must begin with 'py'");
  PYAMOS_ERR_MODULE_EMPTY = a_register_error("PYAMOS_ERR_MODULE_EMPTY, \
The foreign function module may be omitted, but must not be empty if given");
  PYAMOS_ERR_MODULE_DEF = a_register_error("PYAMOS_ERR_MODULE_DEF, \
The specified module was not found");
  PYAMOS_ERR_FUNC_MISSING = a_register_error("PYAMOS_ERR_FUNC_MISSING, \
The foreign function name may not be omitted");
  PYAMOS_ERR_FUNC_DEF = a_register_error("PYAMOS_ERR_FUNC_DEF, \
The specified function was not found");
  PYAMOS_ERR_FUNC_CALLABLE = a_register_error("PYAMOS_ERR_FUNC_CALLABLE, \
The specified function is not callable");
  PYAMOS_ERR_INVALID_BP = a_register_error("PYAMOS_ERR_INVALID_BP, \
A binding pattern may contain only letters 'b' for bound and 'f' for free");
  PYAMOS_ERR_MALLOC_CALLINFO = a_register_error("PYAMOS_ERR_MALLOC_CALLINFO, \
Could not allocate memory for callinfo object");
}

void pycallout_register(void)
{
  dcl_global_cxt(aCxt);
  pyaCxt.aCxt = aCxt;
  pyaCxt.pyaCi = NULL;

  pycallout_register_errors();
  extfunction0("python-enabled", pycallout_enabledfn);
  extfunction2("python-bind", pycallout_bindfn); /* Foreign function loader */

  a_register_enabled(PYTHON_FOREIGN_PREFIX, "python-enabled"); /* Checks if python foreign function callout is enabled. */
  a_register_loader(PYTHON_FOREIGN_PREFIX, "python-bind"); /* Foreign function loader */

  a_extimpl("pycallout_reload_foreign", pycallout_reload_foreign);
  iPycalloutEnabled = TRUE;
}
