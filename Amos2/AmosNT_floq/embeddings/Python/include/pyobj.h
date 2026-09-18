/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pyobj.h,v $
 * $Revision: 1.3 $ $Date: 2011/05/24 16:19:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python object wrapper and type conversion between python and amos. 
 * ===========================================================================
 * $Log: pyobj.h,v $
 * Revision 1.3  2011/05/24 16:19:19  roka4241
 * Fixed errors in MVC settings. Added support for skipping in an python mapper (return nothing). Also added support for premature breaking. Simplified some regression tests.
 *
 * Revision 1.2  2011/05/11 18:26:24  roka4241
 * Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
 *
 * Revision 1.1  2011/05/05 16:44:10  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.7  2011/04/28 18:27:13  roka4241
 * Merged pyiter.c/h into pyobj.c/h and made a new type pyitertype that is 'sort of' a subtype of pyobj.
 *
 * Revision 1.6  2011/04/26 17:52:58  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.5  2011/04/20 17:16:23  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.4  2011/04/07 17:48:20  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.3  2011/01/31 18:16:07  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.2  2010/12/31 15:42:04  roka4241
 * Python dicts are now translated to Amos records. Why are we using make_recordfn, record_getfn and record_putfn instead of make_record, record_get, record_put? The latter don't seem to be included in amoslib.lib, but why?
 *
 * Revision 1.1  2010/12/25 15:50:37  roka4241
 * Added support for any Python return type by wrapping any unrecognized Python object in a new pyobj data type. Some refactoring.
 *
 * Revision 1.3  2010/12/25 00:56:39  roka4241
 * Added reloading of python modules so that new python code can be tested without restarting amos. Cleaned up and refactored the code.
 *
 * Revision 1.2  2010/12/24 00:55:35  roka4241
 * Added generic py_call function.
 *
 * Revision 1.1  2010/12/23 23:16:05  roka4241
 * Added conversion between basic python and amos types (both way).
 *
 * Revision 1.1  2010/12/17 16:48:44  roka4241
 *
 *
 *****************************************************************************/

#ifndef _PYOBJ_H
#define _PYOBJ_H

//#define PYAMOS_DEBUG


int PYOBJTYPE;
int PYITERTYPE;

typedef struct pyobj
{
	objtags tags;
	HEADFILLER;
	PyObject *pObj;
} pyobj_t;

oidtype pyobj_new(PyObject *);      /* create a new python object wrapper */
oidtype pyiter_new(PyObject *);     /* Attempt to create an iterator from a python object, then wrap it in an amos pyobj. */

PyObject *pyobj_getobj(oidtype);       /* get python object from amos object wrapper */
void pyobj_setobj(oidtype, PyObject *); /* set python object in amos object wrapper */

oidtype pytpl_to_arr(PyObject *);   /* Convert python tuple object to amos array */
PyObject *arr_to_pytpl(oidtype);    /* Convert amos array to python tuple */
PyObject *tpl_to_pytpl(a_tuple);    /* Convert amos tuple to python tuple */
PyObject *record_to_pydict(oidtype);    /* Convert amos record to python dict */

oidtype pyobj_to_obj(bindtype, PyObject *);   /* Convert python object to amos object */
PyObject *obj_to_pyobj(oidtype);    /* Convert amos object to python object */
void pyargs_to_args(a_callcontext aCxt, PyObject *pArgs, a_tuple aArgs, int iOffset); /* Convert python argument tuple to an amos arguments tuple starting conversion from argument iOffset. */
oidtype pyobj_emit(a_callcontext, PyObject *); /* Convert and emit python object to amos */
void pyobj_free(oidtype);           /* Free python object wrapper */

void pyobj_register(void);         /* Register foreign functions */
void pyobj_internal_capsules(void);

#endif