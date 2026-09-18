/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pymodule.c,v $
 * $Revision: 1.5 $ $Date: 2011/05/02 18:05:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python module loading. 
 * ===========================================================================
 * $Log: pymodule.c,v $
 * Revision 1.5  2011/05/02 18:05:54  roka4241
 * Better error handling and regression tests of invalid foreign function specifications that cause a_error errors.
 *
 * Revision 1.4  2011/01/31 18:16:04  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.3  2010/12/31 15:42:00  roka4241
 * Python dicts are now translated to Amos records. Why are we using make_recordfn, record_getfn and record_putfn instead of make_record, record_get, record_put? The latter don't seem to be included in amoslib.lib, but why?
 *
 * Revision 1.2  2010/12/28 20:51:13  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.1  2010/12/25 00:56:36  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 * Revision 1.1  2010/12/17 16:48:44  roka4241
 *
 *
 *****************************************************************************/

#include <Python.h>
#include "callout.h"
#include "amosmodule.h"

PyObject *pymodule_import(char *sModule) 
{
  PyObject *pModule;
  pModule = PyImport_ImportModule(sModule);

  if (PyErr_Occurred()) {
#ifdef PYAMOS_DEBUG
    PyErr_Print();
    fprintf(stderr, "Failed to load module %s\n", sModule);
#endif
    PyErr_Clear(); 
    return NULL; 
  }

  return pModule;
}

PyObject *pymodule_reload(char *sModule) 
{
  PyObject *pModule, *pReloadedModule;
  pModule = pymodule_import(sModule);

  if (!pModule) {
    return NULL;
  }

  pReloadedModule = PyImport_ReloadModule(pModule);

  if (PyErr_Occurred()) {
    Py_DECREF(pModule);
#ifdef PYAMOS_DEBUG
    PyErr_Print();
    fprintf(stderr, "Failed to reload module %s\n", sModule);
#endif
    PyErr_Clear();
    return NULL;
  }

  Py_DECREF(pModule);
  return pReloadedModule;
}

oidtype pymodule_amosreload(a_callcontext cxt) 
{
  char *sModule;

  IntoString(a_arg(cxt,1), sModule, cxt->env); 
  pymodule_reload(sModule);

  return nil;
}

void pymodule_register(void) 
{
  a_extimpl("pymodule_reload", pymodule_amosreload);
}