/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: amosmodule.h,v $
 * $Revision: 1.8 $ $Date: 2011/05/05 16:27:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python oidtype wrapper.
 * ===========================================================================
 * $Log: amosmodule.h,v $
 * Revision 1.8  2011/05/05 16:27:54  roka4241
 * removed old python callin from cvs, to make place for new callin/callout
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

//#define PYAMOS_DEBUG

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
    oidtype oSurr;
    a_connection aConn;
    oidtype oScan;
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


#define AmosObj_AsScan_NUM 6
#define AmosObj_AsScan_RETURN oidtype
#define AmosObj_AsScan_PROTO (PyAmosObj *pObj)

#define AmosObj_FromScan_NUM 7
#define AmosObj_FromScan_RETURN PyAmosObj *
#define AmosObj_FromScan_PROTO (oidtype oScan)

#define AmosScan_Check_NUM 8
#define AmosScan_Check_RETURN int
#define AmosScan_Check_PROTO (PyObject *pObj)

/* Total number of C API pointers */
#define Amos_API_pointers 9


#ifdef AMOS_MODULE
/* This section is used when compiling amosmodule.c */



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

#define PyAmosObj_AsScan \
 (*(AmosObj_AsScan_RETURN (*)AmosObj_AsScan_PROTO) Amos_API[AmosObj_AsScan_NUM])
#define PyAmosObj_FromScan \
 (*(AmosObj_FromScan_RETURN (*)AmosObj_FromScan_PROTO) Amos_API[AmosObj_FromScan_NUM])
#define PyAmosScan_Check \
 (*(AmosScan_Check_RETURN (*)AmosScan_Check_PROTO) Amos_API[AmosScan_Check_NUM])

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
