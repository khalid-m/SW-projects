/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pyobj.c,v $
 * $Revision: 1.15 $ $Date: 2011/04/28 18:27:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python object wrapper and type conversion between python and amos. 
 * ===========================================================================
 * $Log: pyobj.c,v $
 * Revision 1.15  2011/04/28 18:27:07  roka4241
 * Merged pyiter.c/h into pyobj.c/h and made a new type pyitertype that is 'sort of' a subtype of pyobj.
 *
 * Revision 1.14  2011/04/27 18:16:30  roka4241
 * Turns out we do need an unwind protect wrapping iterator emission. Settings for command line building and regression testing.
 *
 * Revision 1.13  2011/04/27 14:23:43  torer
 * *** empty log message ***
 *
 * Revision 1.12  2011/04/26 17:52:55  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.11  2011/04/20 17:16:19  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.10  2011/04/07 17:48:16  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.9  2011/02/25 16:51:57  roka4241
 * Better command line building and visual studio settings.
 *
 * Revision 1.8  2011/02/24 23:05:52  roka4241
 * Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
 *
 * Revision 1.7  2011/02/17 13:30:54  roka4241
 * Added support for binding patterns to allow unbound arguments and multidirectional functions.
 *
 * Revision 1.6  2011/02/01 18:44:57  roka4241
 * Added regression tests for much of the current callout functionality.
 *
 * Revision 1.5  2011/01/31 18:16:04  roka4241
 * Made it possible to define amos foreign functions in python using the 'language:method' syntax as previously used with java foreign functions.
 *
 * Revision 1.4  2010/12/31 15:42:00  roka4241
 * Python dicts are now translated to Amos records. Why are we using make_recordfn, record_getfn and record_putfn instead of make_record, record_get, record_put? The latter don't seem to be included in amoslib.lib, but why?
 *
 * Revision 1.3  2010/12/29 18:21:39  roka4241
 * Python objects and iterators can no longer be returned to amos. Added support for converting python lists and dicts to amos vectors. Unrecongized python objects will be iterated and their items emited if the object supports iteration. Removed the pyiter data type.
 *
 * Revision 1.2  2010/12/28 20:51:13  roka4241
 * Made it so that returned iterators/generators are not exposed to the user but instead processed by the c interface. On a side note, it turns out we can use the same code both for iterators and generators (generators are an extension of iterators). Removed previous ALisp callout interface.
 *
 * Revision 1.1  2010/12/25 15:50:33  roka4241
 * Added support for any Python return type by wrapping any unrecognized Python object in a new pyobj data type. Some refactoring.
 *
 * Revision 1.2  2010/12/24 00:55:33  roka4241
 * Added generic py_call function.
 *
 * Revision 1.1  2010/12/23 23:16:03  roka4241
 * Added conversion between basic python and amos types (both way).
 *
 * Revision 1.1  2010/12/17 16:48:44  roka4241
 *
 *
 *****************************************************************************/

#include <Python.h>
#include "arrayobject.h"
#include "callout.h"
#include "record.h"
#include "pyobj.h"
#include "amosmodule.h"
#include "scan.h"


oidtype pyobj_new(PyObject *pObj)
{
  oidtype oObj;

  oObj = new_object(sizeof(pyobj_t), PYOBJTYPE);
  pyobj_setobj(oObj, pObj);

  return oObj;
}

oidtype pyiter_new(PyObject *pObj) 
{
  PyObject *pIter;
  oidtype oIter;

  pIter = PyObject_GetIter(pObj);
  if (PyErr_Occurred()) {
    PyErr_Clear(); 
    return nil;
  }

  oIter = new_object(sizeof(pyobj_t), PYITERTYPE);
  pyobj_setobj(oIter, pIter);
  return oIter;
}



PyObject *pyobj_getobj(oidtype oObj) 
{
  pyobj_t *dObj;

  dObj = dr(oObj, pyobj);
  return dObj->pObj;
}

void pyobj_setobj(oidtype oObj, PyObject *pObj) {
  pyobj_t *dObj;

  dObj = dr(oObj, pyobj);
  dObj->pObj = pObj;
}

oidtype pyseq_to_arr0(bindtype env, 
                      PyObject *pSeq, 
                      Py_ssize_t (*seq_size)(PyObject *), 
                      PyObject *(*get_item)(PyObject *, Py_ssize_t)) 
{
  oidtype oArr, oItem;
  PyObject *pItem;
  Py_ssize_t psSize;
  int i;
  
  psSize = seq_size(pSeq);
  oArr = new_array(psSize, nil);

  for(i=0; i<psSize; i++) {    
    pItem = get_item(pSeq, i);
    oItem = pyobj_to_oid(env, pItem);
    a_seta(oArr, i, oItem);
  }

  return oArr;
}

oidtype pytuple_to_arr(bindtype env, PyObject *pTuple) 
{
  return pyseq_to_arr0(env, pTuple, PyTuple_Size, PyTuple_GetItem);
}

oidtype pylist_to_arr(bindtype env, PyObject *pList) 
{
  return pyseq_to_arr0(env, pList, PyList_Size, PyList_GetItem);
}

oidtype pyseq_to_arr(bindtype env, PyObject *pSeq) 
{
  return pyseq_to_arr0(env, pSeq, PySequence_Size, PySequence_GetItem);
}

oidtype pydict_to_record(bindtype env, PyObject *pDict) 
{
  oidtype oKeyValues, oKey, oValue;
  PyObject *pKey, *pValue;
  Py_ssize_t psSize;
  int iPos, i;

  psSize = PyDict_Size(pDict);
  oKeyValues = new_array(psSize*2, nil);

  iPos = 0;
  i = 0;
  while (PyDict_Next(pDict, &iPos, &pKey, &pValue)) {
    oKey = pyobj_to_oid(env, pKey);
    oValue = pyobj_to_oid(env, pValue);
    a_seta(oKeyValues, i*2, oKey);
    a_seta(oKeyValues, i*2+1, oValue);
    i++;
  }

  return make_recordfn(env, oKeyValues);
}

PyObject *
arr_to_pytpl(oidtype oArr) 
{
  PyObject *pTpl, *pItem;
  oidtype oItem;
  int i, iSize;

  iSize = a_arraysize(oArr);
  pTpl = PyTuple_New(iSize);

  for (i=0; i<iSize; i++) {
    oItem = a_elt(oArr, i);
    pItem = oid_to_pyobj(oItem);
    PyTuple_SetItem(pTpl, i, pItem);
  }

  return pTpl;
}

PyObject *
list_to_pylist(oidtype oList) 
{
  PyObject *pList;
  oidtype oTl;

  pList = PyList_New(0);

  for (oTl=oList; listp(oTl); oTl=tl(oTl)) {
    PyList_Append(pList, oid_to_pyobj(hd(oTl)));
  }
  return pList;
}


/*
PyObject *
tpl_to_pytpl(a_tuple aTuple) 
{
  PyObject *pTpl, *pItem;
  oidtype oItem;
  int i, iSize;

  iSize = a_getarity(aTuple, FALSE);
  pTpl = PyTuple_New(iSize);

  for (i=0; i<iSize; i++) {
    oItem = a_getelem(aTuple, i, FALSE);
    pItem = oid_to_pyobj(oItem);
    PyTuple_SetItem(pTpl, i, pItem);
  }

  return pTpl;
}*/

oidtype pyobj_to_oid(bindtype env, PyObject *pObj) 
{
  oidtype oIter;
    

  if (PyArray_Check(pObj)) {
    PyObject *pList;
    pList = PyArray_ToList((PyArrayObject *)pObj);
    return pylist_to_arr(env, pList);
  } else if (pObj == Py_None) {
    return nil;
  } else if (pObj == Py_True) {
    return a_true;
  } else if (pObj == Py_False) {
    return a_false;
  } else if (PyInt_Check(pObj) || PyLong_Check(pObj)) {
    return mkinteger(PyInt_AsLong(pObj));
  } else if (PyFloat_Check(pObj)) {
    return mkreal(PyFloat_AsDouble(pObj));
  } else if (PyString_Check(pObj)) {
    return mkstring(PyString_AsString(pObj));
  } else if (PyTuple_Check(pObj)) {
    return pytuple_to_arr(env, pObj);
  } else if (PyList_Check(pObj)) {
    return pylist_to_arr(env, pObj);
  } else if (PyDict_Check(pObj)) {
    return pydict_to_record(env, pObj);
  } else if (PyGen_Check(pObj)) {
    return pyiter_new(pObj);
  } else if (PySequence_Check(pObj)) {
    oIter = pyiter_new(pObj);
    if (oIter != nil) {
      return oIter;
    } else {
      return pyseq_to_arr(env, pObj);
    }
  } else if (PyAmosSurr_Check(pObj)) {
    return PyAmosObj_AsSurr((PyAmosObj *)pObj);
  } else if (PyAmosScan_Check(pObj)) {
    return PyAmosObj_AsScan((PyAmosObj *)pObj);
  }

  return nil;
}

PyObject *oid_to_pyobj(oidtype oObj) 
{
  int iType;

  iType = a_datatype(oObj);

  switch (iType) {
  case INTEGERTYPE: 
    return PyInt_FromLong(getinteger(oObj));
  case REALTYPE: 
    return PyFloat_FromDouble(getreal(oObj));
  case STRINGTYPE:
    return PyString_FromString(getstring(oObj));
  case LISTTYPE: 
    return list_to_pylist(oObj);
  case ARRAYTYPE:
    return arr_to_pytpl(oObj);
  case SYMBOLTYPE:
    if (oObj == a_true) {
      Py_INCREF(Py_True);
      return Py_True;
    } else if (oObj == a_false) {
      Py_INCREF(Py_False);
      return Py_False;
    } else if (oObj == nil) {
      Py_INCREF(Py_None);
      return Py_None;
    } else {
      fprintf(stderr, "oid_to_pyobj: Unrecognized symboltype: %d.\n", oObj);
      Py_INCREF(Py_None); 
      return Py_None;
    }
	case SURROGATETYPE:
	  return (PyObject *)PyAmosObj_FromSurr(oObj);
  }

  if (iType == scantype) { // scan
    return (PyObject *)PyAmosObj_FromScan(oObj);
  }

  fprintf(stderr, "oid_to_pyobj: Unrecognized object type: %d.\n", iType);
  Py_INCREF(Py_None);
  return Py_None;
}

void pyobj_free(oidtype oObj)
{
  pyobj_t *dObj;
  printf("Deallocating object\n");
  dObj = dr(oObj, pyobj);
  Py_DECREF(dObj->pObj);
  dealloc_object(oObj);
}

void pyobj_internal_capsules(void)
{
  PyAmos_Import();
}

void pyobj_register(void)
{
  PYOBJTYPE = a_definetype("pyobj", pyobj_free, NULL);
  PYITERTYPE = a_definetype("pyiter", pyobj_free, NULL);
  import_array();
}