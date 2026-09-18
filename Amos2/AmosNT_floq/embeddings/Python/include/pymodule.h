/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pymodule.h,v $
 * $Revision: 1.1 $ $Date: 2011/05/05 16:44:10 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python module loading. 
 * ===========================================================================
 * $Log: pymodule.h,v $
 * Revision 1.1  2011/05/05 16:44:10  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.4  2011/01/31 18:16:07  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.3  2010/12/31 15:42:03  roka4241
 * Python dicts are now translated to Amos records. Why are we using make_recordfn, record_getfn and record_putfn instead of make_record, record_get, record_put? The latter don't seem to be included in amoslib.lib, but why?
 *
 * Revision 1.2  2010/12/28 20:51:15  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.1  2010/12/25 00:56:39  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 * Revision 1.1  2010/12/17 16:48:44  roka4241
 *
 *
 *****************************************************************************/

#ifndef _PYMODULE_H
#define _PYMODULE_H

PyObject *pymodule_import(char *);              /* Import module */
PyObject *pymodule_reload(char *);              /* Reload module */
void pymodule_register(void);                   /* Register foreign functions */

#endif