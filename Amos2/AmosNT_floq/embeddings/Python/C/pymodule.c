/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pymodule.c,v $
 * $Revision: 1.5 $ $Date: 2011/11/01 21:37:58 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python module loading. 
 * ===========================================================================
 * $Log: pymodule.c,v $
 * Revision 1.5  2011/11/01 21:37:58  torer
 * Replaced Python error messages with Amos errors
 *
 * Revision 1.4  2011/05/31 15:19:01  roka4241
 * Fixed amos_map_func in callin. Record to dict conversion.
 *
 * Revision 1.3  2011/05/27 12:38:27  roka4241
 * All foreign function definitions will now reload their target module to detect code added since last time the module was loaded.
 *
 * Revision 1.2  2011/05/16 15:56:13  roka4241
 * Implemented and tested nested loop join and mergejoin as python foreign functions. Started with a mapped nested loop join.
 *
 * Revision 1.1  2011/05/05 16:44:02  roka4241
 * moved the whole project down one directory
 *
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

int PYAMOS_RELOAD_MODULE, PYAMOS_IMPORT_FAILED;

PyObject *pymodule_import(char *sModule) 
{
  PyObject *pModule;

  pModule = PyImport_ImportModule(sModule);
  if (PyErr_Occurred()) 
    {
      a_error_str(PYAMOS_IMPORT_FAILED, sModule, FALSE);
      //PyErr_Print(); 
      //PyErr_Clear(); 
      return NULL; 
    }
  return pModule;
}

PyObject *pymodule_reload(char *sModule) 
{
  PyObject *pModule, *pReloadedModule;
  pModule = pymodule_import(sModule);
  if (!pModule) return NULL;
  pReloadedModule = PyImport_ReloadModule(pModule);
  Py_DECREF(pModule);
  if (PyErr_Occurred()) 
    {
      //PyErr_Print();
      a_error_str(PYAMOS_RELOAD_MODULE, sModule, FALSE);
      //PyErr_Clear();
      return NULL;
    } 
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

  PYAMOS_RELOAD_MODULE = a_register_error("PYAMOS_RELOAD_MODULE, \
Failed to reload module");
  PYAMOS_IMPORT_FAILED = a_register_error("PYAMOS_IMPORT_FAILED, \
Failed to import module");
}
