/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: pyobj.c,v $
 * $Revision: 1.8 $ $Date: 2011/12/17 16:16:17 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python object wrapper and type conversion between python and amos. 
 * ===========================================================================
 * $Log: pyobj.c,v $
 * Revision 1.8  2011/12/17 16:16:17  torer
 * Storage leaks fixed
 *
 * Revision 1.7  2011/09/13 18:25:51  torer
 * Aggregate functions in Python now work over materialized bags too
 *
 * Revision 1.6  2011/06/01 15:10:56  roka4241
 * AmosObj objects containing any kind of oidtype are now hashable and comparable. Made NumPy optional by PYAMOS_NUMPY flag.
 *
 * Revision 1.5  2011/05/31 15:19:01  roka4241
 * Fixed amos_map_func in callin. Record to dict conversion.
 *
 * Revision 1.4  2011/05/24 16:19:14  roka4241
 * Fixed errors in MVC settings. Added support for skipping in an python mapper (return nothing). Also added support for premature breaking. Simplified some regression tests.
 *
 * Revision 1.3  2011/05/11 18:26:18  roka4241
 * Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
 *
 * Revision 1.2  2011/05/06 15:56:54  torer
 * nytt
 *
 * Revision 1.1  2011/05/05 16:44:02  roka4241
 * moved the whole project down one directory
 *
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
#include "amos.h"
#include "storagetypes.h"

#include "pycallout.h"
#ifdef PYAMOS_NUMPY
  #include "arrayobject.h"
#endif

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
    oItem = pyobj_to_obj(env, pItem);
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
    oKey = pyobj_to_obj(env, pKey);
    oValue = pyobj_to_obj(env, pValue);
    a_seta(oKeyValues, i*2, oKey);
    a_seta(oKeyValues, i*2+1, oValue);
    i++;
  }

  return make_recordfn(env, oKeyValues);
}

PyObject *record_to_pydict(oidtype oRecord) {
  PyObject *pDict, *pKey, *pValue;
  struct recordcell *dRecord;
  int i, iSize;
  
  dRecord = dr(oRecord, recordcell);
  iSize = a_arraysize(dRecord->fields);

  pDict = PyDict_New();
  
  for (i=0; i<iSize; i=i+2) {
    pKey = obj_to_pyobj(a_elt(dRecord->fields, i));
    pValue = obj_to_pyobj(a_elt(dRecord->fields, i+1));
    PyDict_SetItem(pDict, pKey, pValue);
    Py_DECREF(pKey);
    Py_DECREF(pValue);
  }

  return pDict;
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
    pItem = obj_to_pyobj(oItem);
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
    PyList_Append(pList, obj_to_pyobj(hd(oTl)));
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

oidtype pyobj_to_obj(bindtype env, PyObject *pObj) 
{
  oidtype oIter;
    

  if (pObj == Py_None) {
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
  } else if (PyAmosStream_Check(pObj)) {
    return PyAmosObj_AsStream((PyAmosObj *)pObj);
  } else if (PyAmosGen_Check(pObj)) {
    return PyAmosObj_AsGen((PyAmosObj *)pObj);
  }
  
#ifdef PYAMOS_NUMPY
  if (PyArray_Check(pObj)) {
    PyObject *pList;
    pList = PyArray_ToList((PyArrayObject *)pObj);
    return pylist_to_arr(env, pList);
  } 
#endif

  return nil;
}

PyObject *obj_to_pyobj(oidtype oObj) 
     /* Convert Amos object to Python object */
{
  int iType;

  iType = a_datatype(oObj);

  switch (iType) 
    {
    case INTEGERTYPE: 
      return PyInt_FromLong(getinteger(oObj));
    case REALTYPE: 
      return PyFloat_FromDouble(getreal(oObj));
    case STRINGTYPE:
      return PyString_FromString(getstring(oObj));
    case LISTTYPE:
      if(is_bag(oObj)) return (PyObject *)PyAmosObj_FromGen(oObj);
      return list_to_pylist(oObj);
    case ARRAYTYPE:
      return arr_to_pytpl(oObj);
    case SYMBOLTYPE:
      if (oObj == a_true) 
	{
	  Py_INCREF(Py_True);
	  return Py_True;
	} 
      else if (oObj == a_false) 
	{
	  Py_INCREF(Py_False);
	  return Py_False;
	} 
      else if (oObj == nil) 
	{
	  Py_INCREF(Py_None);
	  return Py_None;
	} 
      else 
	{
	  fprintf(stderr, 
		  "oid_to_pyobj: Unrecognized symboltype: %d.\n", oObj);
	  Py_INCREF(Py_None); 
	  return Py_None;
	}
    case SURROGATETYPE:
      return (PyObject *)PyAmosObj_FromSurr(oObj);
    }

  if (iType == recordtype) 
    return record_to_pydict(oObj);
  else if (iType == scantype) 
    return (PyObject *)PyAmosObj_FromStream(oObj);
  else if (iType == generatortype) 
    return (PyObject *)PyAmosObj_FromGen(oObj);

  fprintf(stderr, "oid_to_pyobj: Unrecognized object type: %d.\n", iType);
  Py_INCREF(Py_None);
  return Py_None;
}

void pyargs_to_args(a_callcontext aCxt, PyObject *pArgs, a_tuple aArgs, 
		    int iOffset) 
{
  PyObject *pArg;
  oidtype oArg;
  int i, iArity;

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entering pyargs_to_args\n");
#endif

  iArity = PyTuple_Size(pArgs);
  a_setarity(aArgs, iArity-1);

  // Create argument tuple
  for(i=iOffset; i<iArity; i++) 
    {
      pArg = PyTuple_GetItem(pArgs, i);
      oArg = pyobj_to_obj(aCxt->env, pArg);
      a_setelem(aArgs, i-iOffset, oArg);
    }
}

void pyobj_free(oidtype oObj)
{
  pyobj_t *dObj;
#ifdef PYAMOS_DEBUG
  printf("Deallocating object\n");
#endif
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
#ifdef PYAMOS_NUMPY
  import_array();
#endif
}
