/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pyamos2.c,v $
 * $Revision: 1.1 $ $Date: 2011/05/05 16:44:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python callout. 
 * ===========================================================================
 * $Log: pyamos2.c,v $
 * Revision 1.1  2011/05/05 16:44:01  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.16  2011/04/26 17:52:55  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.15  2011/04/20 17:16:18  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.14  2011/04/07 17:48:16  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.13  2011/02/24 23:05:52  roka4241
 * Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
 *
 * Revision 1.12  2011/02/01 18:44:57  roka4241
 * Added regression tests for much of the current callout functionality.
 *
 * Revision 1.11  2011/01/31 18:16:03  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.10  2010/12/29 18:21:39  roka4241
 * Python objects and iterators can no longer be returned to amos. Added support for converting python lists and dicts to amos vectors. Unrecongized python objects will be iterated and their items emited if the object supports iteration. Removed the pyiter data type.
 *
 * Revision 1.9  2010/12/28 20:51:13  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.8  2010/12/25 15:50:33  roka4241
 * Added support for any Python return type by wrapping any unrecognized Python object in a new pyobj data type. Some refactoring.
 *
 * Revision 1.7  2010/12/25 00:56:35  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 * Revision 1.6  2010/12/24 04:59:45  roka4241
 * Calling python from lisp.
 *
 * Revision 1.5  2010/12/24 00:55:33  roka4241
 * Added generic py_call function.
 *
 * Revision 1.4  2010/12/23 23:16:02  roka4241
 * Added conversion between basic python and amos types (both way).
 *
 * Revision 1.3  2010/12/17 16:48:44  roka4241
 * *** empty log message ***
 *
 * Revision 1.2  2010/12/13 15:10:40  roka4241
 * *** empty log message ***
 *
 * Revision 1.1  2010/12/10 21:23:15  roka4241
 * The beginnings of python callout.
 *
 *
 *****************************************************************************/

#include <Python.h>
/*#include "arrayobject.h"*/
#include "callout.h"
#include "pycallout.h"
#include "pymodule.h"
#include "pyobj.h"
#include "amosmodule.h"

void init_pyamos(void) 
{
  Py_Initialize();        /* Initialize Python */
  /*import_array();*/         /* Initialize NumPy */

  initamos2();            /* Initialize python callin module */
  pycallout_register();   /* Initialize python callout */
  pymodule_register();    /* Register python module loading */
  pyobj_register();       /* Register object conversion module */
  pyobj_internal_capsules();
}

main(int argc,char **argv) {
  dcl_connection(c);      /* To hold connection to Amos */
  init_amos(argc, argv);  /* Initialize embedded Amos.
                             Notice that database image file must be specified */

  init_pyamos();          /* Initialize python interface */

  //PySys_SetArgvEx(argc, argv, 1);

  a_connect(c, "", FALSE);  /* Connect to embedded Amos and load init script if
                             specified */
  free_connection(c);
  amos_toploop("Amos");
  Py_Finalize();

  return 0;
}
