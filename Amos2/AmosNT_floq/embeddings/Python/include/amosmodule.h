/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: amosmodule.h,v $
 * $Revision: 1.4 $ $Date: 2011/06/01 15:10:58 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python oidtype wrapper.
 * ===========================================================================
 * $Log: amosmodule.h,v $
 * Revision 1.4  2011/06/01 15:10:58  roka4241
 * AmosObj objects containing any kind of oidtype are now hashable and comparable. Made NumPy optional by PYAMOS_NUMPY flag.
 *
 * Revision 1.3  2011/05/16 15:56:15  roka4241
 * Implemented and tested nested loop join and mergejoin as python foreign functions. Started with a mapped nested loop join.
 *
 * Revision 1.2  2011/05/11 18:26:23  roka4241
 * Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
 *
 * Revision 1.1  2011/05/05 16:44:10  roka4241
 * moved the whole project down one directory
 *
 * Revision 1.7  2011/05/02 18:05:57  roka4241
 * Better error handling and regression tests of invalid foreign function specifications that cause a_error errors.
 *
 * Revision 1.6  2011/04/26 17:52:57  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.5  2011/04/20 17:16:23  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.4  2011/04/07 17:48:20  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.3  2011/02/24 23:06:00  roka4241
 * Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
 *
 * Revision 1.2  2011/02/01 18:44:58  roka4241
 * Added regression tests for much of the current callout functionality.
 *
 *
 *
 *****************************************************************************/

#ifndef _AMOSMODULE_H
#define _AMOSMODULE_H

#define AMOS_MOUDLE "amos2"

#define AMOS_ERROR(where) do {                                          \
  if (a_errform == nil)                                                 \
    PyErr_Format(PyExc_RuntimeError, #where ": %s", a_errstr);           \
  else                                                                  \
    PyErr_Format(PyExc_RuntimeError, #where ": %s: %s", a_errstr, a_to_string(a_errform));  \
  } while (0)
//#define AMOS_WARNING (a_errform==nil?PyErr_Format(PyExc_RuntimeError, "a_errstr:%s", a_errstr):PyErr_Format(E_WARNING, "%s : %s", a_errstr, a_to_string(a_errform)))
//#define CHECK_AMOS_ERROR if(a_errorflag) AMOS_ERROR

#define MACRO_APPEND(str, m) str ##m


// Amos object wrapper
typedef struct {
  PyObject_HEAD
  int iType;
  union {
    oidtype oObj;
    a_connection aConn;
  } uObj;
} PyAmosObj;


#define AmosObj_AsSurr_NUM 0
#define AmosObj_AsSurr_RETURN oidtype
#define AmosObj_AsSurr_PROTO (PyAmosObj *pObj)

#define AmosObj_FromSurr_NUM 1
#define AmosObj_FromSurr_RETURN PyAmosObj *
#define AmosObj_FromSurr_PROTO (oidtype oSurr)

#define AmosSurr_Check_NUM 2
#define AmosSurr_Check_RETURN int
#define AmosSurr_Check_PROTO (PyObject *pObj)


#define AmosObj_AsConn_NUM 3
#define AmosObj_AsConn_RETURN a_connection
#define AmosObj_AsConn_PROTO (PyAmosObj *pObj)

#define AmosObj_FromConn_NUM 4
#define AmosObj_FromConn_RETURN PyAmosObj *
#define AmosObj_FromConn_PROTO (a_connection aConn)

#define AmosConn_Check_NUM 5
#define AmosConn_Check_RETURN int
#define AmosConn_Check_PROTO (PyObject *pObj)


#define AmosObj_AsStream_NUM 6
#define AmosObj_AsStream_RETURN oidtype
#define AmosObj_AsStream_PROTO (PyAmosObj *pObj)

#define AmosObj_FromStream_NUM 7
#define AmosObj_FromStream_RETURN PyAmosObj *
#define AmosObj_FromStream_PROTO (oidtype oStream)

#define AmosStream_Check_NUM 8
#define AmosStream_Check_RETURN int
#define AmosStream_Check_PROTO (PyObject *pObj)


#define AmosObj_AsGen_NUM 9
#define AmosObj_AsGen_RETURN oidtype
#define AmosObj_AsGen_PROTO (PyAmosObj *pObj)

#define AmosObj_FromGen_NUM 10
#define AmosObj_FromGen_RETURN PyAmosObj *
#define AmosObj_FromGen_PROTO (oidtype oGen)

#define AmosGen_Check_NUM 11
#define AmosGen_Check_RETURN int
#define AmosGen_Check_PROTO (PyObject *pObj)

/* Total number of C API pointers */
#define Amos_API_pointers 12

/* Amos errors */
int PYAMOS_MAP_FUNC_MAPFUNCTIONC, 
    PYAMOS_MAP_GEN_MAPGENC;


#ifdef AMOS_MODULE

PyObject *amos_stream_gen(PyObject *pSelf, PyObject *pArgs);


#else
/* This section is used in modules that use amosmodules's C API */

PyMODINIT_FUNC initamos2(void);

static void **Amos_API;

#define PyAmosObj_AsSurr \
 (*(AmosObj_AsSurr_RETURN (*)AmosObj_AsSurr_PROTO) Amos_API[AmosObj_AsSurr_NUM])
#define PyAmosObj_FromSurr \
 (*(AmosObj_FromSurr_RETURN (*)AmosObj_FromSurr_PROTO) Amos_API[AmosObj_FromSurr_NUM])
#define PyAmosSurr_Check \
 (*(AmosSurr_Check_RETURN (*)AmosSurr_Check_PROTO) Amos_API[AmosSurr_Check_NUM])

#define PyAmosObj_AsConn \
 (*(AmosObj_AsConn_RETURN (*)AmosObj_AsConn_PROTO) Amos_API[AmosObj_AsConn_NUM])
#define PyAmosObj_FromConn \
 (*(AmosObj_FromConn_RETURN (*)AmosObj_FromConn_PROTO) Amos_API[AmosObj_FromConn_NUM])
#define PyAmosConn_Check \
 (*(AmosConn_Check_RETURN (*)AmosConn_Check_PROTO) Amos_API[AmosConn_Check_NUM])

#define PyAmosObj_AsStream \
 (*(AmosObj_AsStream_RETURN (*)AmosObj_AsStream_PROTO) Amos_API[AmosObj_AsStream_NUM])
#define PyAmosObj_FromStream \
 (*(AmosObj_FromStream_RETURN (*)AmosObj_FromStream_PROTO) Amos_API[AmosObj_FromStream_NUM])
#define PyAmosStream_Check \
 (*(AmosStream_Check_RETURN (*)AmosStream_Check_PROTO) Amos_API[AmosStream_Check_NUM])

#define PyAmosObj_AsGen \
 (*(AmosObj_AsGen_RETURN (*)AmosObj_AsGen_PROTO) Amos_API[AmosObj_AsGen_NUM])
#define PyAmosObj_FromGen \
 (*(AmosObj_FromGen_RETURN (*)AmosObj_FromGen_PROTO) Amos_API[AmosObj_FromGen_NUM])
#define PyAmosGen_Check \
 (*(AmosGen_Check_RETURN (*)AmosGen_Check_PROTO) Amos_API[AmosGen_Check_NUM])

/* Return -1 on error, 0 on success.
 * PyCapsule_Import will set an exception if there's an error.
 */
#ifdef Py_CAPSULE_H // python 2.7.1
static int
PyAmos_Import(void)
{
#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entering PyAmos_Import\n");
#endif

  Amos_API = (void **)PyCapsule_Import(AMOS_MOUDLE "._C_API", 0);
  if (PyErr_Occurred()) {
    PyErr_Print();
    return -1;
  }
  return 0;
} 
#else               // python 2.6.6
/* Return -1 and set exception on error, 0 on success. */
static int
PyAmos_Import(void)
{
  PyObject *c_api_object;
  PyObject *module;

  module = PyImport_ImportModule(AMOS_MOUDLE);
  if (module == NULL)
      return -1;

  c_api_object = PyObject_GetAttrString(module, "_C_API");
  if (c_api_object == NULL) {
      Py_DECREF(module);
      return -1;
  }
  if (PyCObject_Check(c_api_object)) {
      Amos_API = (void **)PyCObject_AsVoidPtr(c_api_object);
  }

  Py_DECREF(c_api_object);
  Py_DECREF(module);
  return 0;
}
#endif


#endif /* defined amosmodule C API */

#endif /* !defined(_AMOSMODULE_H) */
