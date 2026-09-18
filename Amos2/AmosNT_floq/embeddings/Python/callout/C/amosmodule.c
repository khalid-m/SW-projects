/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: amosmodule.c,v $
 * $Revision: 1.8 $ $Date: 2011/04/26 17:52:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python oidtype wrapper.
 * ===========================================================================
 * $Log: amosmodule.c,v $
 * Revision 1.8  2011/04/26 17:52:54  roka4241
 * Merged PyAmosOid, PyAmosScan and PyAmosConn into a single python type PyAmosObj. Will simplify addition of amos generator wrapper.
 *
 * Revision 1.7  2011/04/20 17:16:18  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.6  2011/04/07 17:48:16  roka4241
 * Calling of python functions with amos scans and iterating over the scan transparently in python.
 *
 * Revision 1.5  2011/02/24 23:05:52  roka4241
 * Embedding of NumPy. Foreign function definition and calling of python function that returns the NumPy ndarray datatype.
 *
 * Revision 1.4  2011/02/21 17:22:06  roka4241
 * *** empty log message ***
 *
 * Revision 1.3  2011/02/03 14:13:35  roka4241
 * Added console based compilation of the project.
 *
 * Revision 1.2  2011/02/01 18:44:57  roka4241
 * Added regression tests for much of the current callout functionality.
 *
 *
 *
 *****************************************************************************/

#include <Python.h>
#define AMOS_MODULE
#include "amos.h"
#include "callin.h"
#include "callout.h"
#include "pyobj.h"
#include "amosmodule.h"
#include "scan.h"

#define CONNECTIONTYPE 13001


static PyObject *
AmosObj_new(PyTypeObject *type, PyObject *pArgs, PyObject *pKwds)
{
  PyAmosObj *pSelf;

  pSelf = (PyAmosObj *)type->tp_alloc(type, 0);
  return (PyObject *)pSelf;
}


static void
AmosObj_dealloc(PyAmosObj *pSelf)
{
  switch (pSelf->iType) {
    case SURROGATETYPE:
      a_free(pSelf->uObj.oSurr);
      break;
    case CONNECTIONTYPE:
      free_connection(pSelf->uObj.aConn);
      break;
  }

  if (pSelf->iType == scantype) {
    a_free(pSelf->uObj.oScan);
  }

  pSelf->ob_type->tp_free((PyObject*)pSelf);
}

static PyObject *
AmosObj_GetSurr(PyAmosObj *pSelf)
{
  return PyLong_FromLong((int)pSelf->uObj.oSurr);
}

static PyObject * 
AmosObj_iter(PyObject *pSelf)
{
  if (((PyAmosObj *)pSelf)->iType != scantype) {
    PyErr_Format(PyExc_NotImplementedError, "AmosObj_iter supports only amos scan objects. Found amos object of type %i.", ((PyAmosObj *)pSelf)->iType);
    Py_INCREF(Py_None);
    return Py_None;
  }

  Py_INCREF(pSelf);
  return pSelf;
}

static PyObject * 
AmosScan_iternext(PyObject *pSelf)
{
  oidtype oRow;

  if ((oRow = scan_next(((PyAmosObj *)pSelf)->uObj.oScan)) != nil) {
    return oid_to_pyobj(oRow);
  } else {
    PyErr_SetNone(PyExc_StopIteration);
    return NULL;
  }
}

static PyObject * 
AmosObj_iternext(PyObject *pSelf)
{
  if (((PyAmosObj *)pSelf)->iType != scantype) {
    PyErr_Format(PyExc_NotImplementedError, "AmosObj_iternext supports only amos scan objects. Found amos object of type %i.", ((PyAmosObj *)pSelf)->iType);
    Py_INCREF(Py_None);
    return Py_None;
  } else {
    return AmosScan_iternext(pSelf);
  } 
}

static PyMethodDef AmosObj_methods[] = {
    {"get_surrogate", (PyCFunction)AmosObj_GetSurr, METH_NOARGS,
     "Return the surrogate object id."},
    {NULL}  //Sentinel 
};

static PyTypeObject AmosObj = {
  PyObject_HEAD_INIT(NULL)
  0,                         /*ob_size*/
  AMOS_MOUDLE ".AmosObj",            /*tp_name*/
  sizeof(PyAmosObj),           /*tp_basicsize*/
  0,                         /*tp_itemsize*/
  (destructor)AmosObj_dealloc, /*tp_dealloc*/
  0,                         /*tp_print*/
  0,                         /*tp_getattr*/
  0,                         /*tp_setattr*/
  0,                         /*tp_compare*/
  0,                         /*tp_repr*/
  0,                         /*tp_as_number*/
  0,                         /*tp_as_sequence*/
  0,                         /*tp_as_mapping*/
  0,                         /*tp_hash */
  0,                         /*tp_call*/
  0,                         /*tp_str*/
  0,                         /*tp_getattro*/
  0,                         /*tp_setattro*/
  0,                         /*tp_as_buffer*/
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE | Py_TPFLAGS_HAVE_ITER, /*tp_flags*/
  "Amos object wrapper.", /* tp_doc */
  0,		                     /* tp_traverse */
  0,		                     /* tp_clear */
  0,		                     /* tp_richcompare */
  0,		                     /* tp_weaklistoffset */
  AmosObj_iter,		         /* tp_iter */
  AmosObj_iternext,		     /* tp_iternext */
  AmosObj_methods,           /* tp_methods */
  0,                         /* tp_members */
  0,                         /* tp_getset */
  0,                         /* tp_base */
  0,                         /* tp_dict */
  0,                         /* tp_descr_get */
  0,                         /* tp_descr_set */
  0,                         /* tp_dictoffset */
  0,    /* tp_init */
  0,                         /* tp_alloc */
  AmosObj_new,               /* tp_new */
};

static PyAmosObj *
AmosObj_Create() 
{
  return (PyAmosObj *)PyObject_CallObject((PyObject *)&AmosObj, NULL);
}

int
AmosObj_Check(PyObject *pObj) 
{
  return PyObject_TypeCheck(pObj, &AmosObj);
}

// Surrogate
static oidtype 
AmosObj_AsSurr(PyAmosObj *pObj) {
  return pObj->uObj.oSurr;
}

PyAmosObj *
AmosObj_FromSurr(oidtype oSurr) 
{
  PyAmosObj *pObj;

  incref(doid(oSurr));

  pObj = AmosObj_Create();
  pObj->iType = SURROGATETYPE;
  pObj->uObj.oSurr = oSurr;
  return pObj;
}

int 
AmosSurr_Check(PyObject *pObj) {
  return AmosObj_Check(pObj) && ((PyAmosObj *)pObj)->iType == SURROGATETYPE;
}

// Connection
static a_connection 
AmosObj_AsConn(PyAmosObj *pObj) {
  return pObj->uObj.aConn;
}

PyAmosObj *
AmosObj_FromConn(a_connection aConn) 
{
  PyAmosObj *pObj;

  pObj = AmosObj_Create();
  pObj->iType = CONNECTIONTYPE;
  pObj->uObj.aConn = aConn;
  return pObj;
}

int 
AmosConn_Check(PyObject *pObj) {
  return AmosObj_Check(pObj) && ((PyAmosObj *)pObj)->iType == CONNECTIONTYPE;
}


// Scan
static oidtype 
AmosObj_AsScan(PyAmosObj *pObj) {
  return pObj->uObj.oScan;
}

PyAmosObj *
AmosObj_FromScan(oidtype oScan) 
{
  PyAmosObj *pObj;

  incref(doid(oScan));

  pObj = AmosObj_Create();
  pObj->iType = scantype;
  pObj->uObj.oScan = oScan;
  return pObj;
}

int 
AmosScan_Check(PyObject *pObj) {
  return AmosObj_Check(pObj) && ((PyAmosObj *)pObj)->iType == scantype;
}

/**
 * Connect to amos 
 */
static PyObject *amos_connect(PyObject *pSelf, PyObject *pArgs)
{
	char *sPeer;
  char sPeerEmbedded[1];
	
	dcl_connection(aConn); /* To hold connection to Amos */

  // Default to embedded amos if no peer is given
  if (!PyArg_ParseTuple(pArgs, "s", &sPeer)) {
	   PyErr_Clear();
     sPeerEmbedded[0] = '\0';
     sPeer = sPeerEmbedded;
  };

	if(!AmosInitialized())
	{
		char *sAmosHome;
		char sDumpPath[200];

		sAmosHome = getenv("AMOS_HOME");

		sprintf(sDumpPath, "%sbin/amos2.dmp", sAmosHome);
		a_initialize(sDumpPath, TRUE);  // Initialize embedded Amos from %AMOS_HOME/bin
    if(a_errorflag) {
      fprintf(stderr, "amos_connect: could not initialize amos with dump at '%s'.\n", sDumpPath);
    }
	}


	a_connect(aConn, sPeer, TRUE); 
	if(a_errorflag) {
		free_connection(aConn);
		fprintf(stderr, "amos_connect: could not connect to amos peer '%s'.\n", sPeer);
		return NULL;
	}

  return (PyObject *)AmosObj_FromConn(aConn);
}

oidtype extract_amos_fn(PyObject *pArgs, int iPos) {
  PyObject *pFn;
  oidtype oFn;
  char *sFn;

  pFn = PyTuple_GetItem(pArgs, iPos);
  if(PyString_Check(pFn)) {
    sFn = PyString_AsString(pFn);

    oFn = a_getfunctionnamed(sFn, TRUE); 
		if(a_errorflag) {
      PyErr_Format(PyExc_NotImplementedError, "a_getfunctionnamed threw and error when trying to resolve amos function %s.", sFn);
      return nil;
    } else if (oFn == nil) {
      PyErr_Format(PyExc_NotImplementedError, "a_getfunctionnamed failed to resolve amos function %s.", sFn);
      return nil;
    }
  } else if(AmosSurr_Check(pFn)) {
		a_let(oFn, ((PyAmosObj *)pFn)->uObj.oSurr);
  } else{
    PyErr_SetString(PyExc_TypeError, "Expecting string or oid function parameter.");
    return nil;
	}
  return oFn;
}


oidtype amos_mapf_mapper(a_callcontext aCxt, int iWidth, oidtype oTpl[], PyObject *pMapper) {
  PyObject *pArgs, *pTpl, *pMapperRet;

  pArgs = PyTuple_New(1);
  pTpl = oid_to_pyobj(*oTpl);

  if (PyErr_Occurred()) {
    PyErr_Print();
    fprintf(stderr, "amos_map_mapper: Cannot convert argument:\n");
    a_print(*oTpl);
    PyErr_Clear();
    return nil;
  }

  PyTuple_SetItem(pArgs, 0, pTpl);

  pMapperRet = PyObject_CallObject(pMapper, pArgs);
  Py_DECREF(pArgs);
  
  if (PyErr_Occurred()) {
    PyErr_Print();
    fprintf(stderr, "amos_map_mapper: Mapper call failed.\n");
    PyErr_Clear();
    return nil;
  }

  if (pMapperRet == Py_False) {
    a_map_done(aCxt, oTpl[0]);
  }
  Py_DECREF(pMapperRet);
  return nil;
}

static PyObject *amos_mapf(PyObject *pSelf, PyObject *pArgs)
{
	PyObject *pMapper, *pArg;

  dcl_global_cxt(aCxt);

  oidtype oFn;
  oidtype *oArgs;
	int i, iArity;

	iArity = PyTuple_Size(pArgs);

  // Get python mapper function
  pMapper = PyTuple_GetItem(pArgs, 0);
  if (!PyCallable_Check(pMapper)) {
    fprintf(stderr, "amos_mapf: The supplied mapper is not callable.\n");
    Py_INCREF(Py_None);
    return Py_None;
  }

  // Get amos function
  oFn = extract_amos_fn(pArgs, 1);
  if (oFn == nil) {
    Py_INCREF(Py_None);
    return Py_None;
  }

  // Allocate argument array
  oArgs = (oidtype *)malloc((iArity-2)*sizeof(oidtype));
  if (oArgs == NULL) {
    PyErr_SetString(PyExc_MemoryError, "Could not allocate memory for amos arguments array.");
    Py_INCREF(Py_None);
    return Py_None;
  }

  // Create argument array
	for(i=0; i<iArity-2; i++) {
    pArg = PyTuple_GetItem(pArgs, i+2);
    oArgs[i] = pyobj_to_oid(aCxt->env, pArg);
	}

  // Call amos function
  a_mapfunctionC(aCxt, oFn, iArity-2, oArgs, amos_mapf_mapper, pMapper); 

  if(a_errorflag) {
		fprintf(stderr, "amos_mapf: Call to a_mapfunctionC failed.");
    AMOS_ERROR(amos_mapf);
	}

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *amos_callf(PyObject *pSelf, PyObject *pArgs)
{
	PyObject *pArg;

  dcl_global_cxt(aCxt);
  dcl_tuple(aArgs);

  oidtype oFn, oArg, oResult;
	int i, iArity;

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entering amos_callf\n");
#endif

	iArity = PyTuple_Size(pArgs);
  a_setarity(aArgs, iArity-1);

  // Get amos function
  oFn = extract_amos_fn(pArgs, 0);
  if (oFn == nil) {
    Py_INCREF(Py_None);
    return Py_None;
  }

  // Create argument tuple
	for(i=0; i<iArity-1; i++) {
    pArg = PyTuple_GetItem(pArgs, i+1);
    oArg = pyobj_to_oid(aCxt->env, pArg);
    a_setelem(aArgs, i, oArg);
	}

  // Call amos function
  oResult = callfunction(aCxt->env, oFn, aArgs->tpl, -1); 

  if(a_errorflag) {
		fprintf(stderr, "amos_callf: Call to callfunction failed.");
    AMOS_ERROR(amos_callf);
    Py_INCREF(Py_None);
    return Py_None;
	}

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "leaving amos_callf\n");
#endif

  return oid_to_pyobj(oResult);
}

static PyMethodDef module_methods[] = {
  {"amos_connect", amos_connect, METH_VARARGS, 
	 "amos_connect(peer)\n  peer: peer is the name of the Amos II database to connect to. If peer is the empty string it represents a connection to the embedded database; otherwise peer must be the name of an Amos II peer known to the nameserver running on the same host as the application.\n Returns: An Amos II connection.\n"},
  {"amos_mapf", amos_mapf, METH_VARARGS, 
   "amos_mapf(mapper, afunc, *args)\n" 
   "  mapper: python mapper function."
   "  afunc: amos function to call.\n"
   "  *args: arguments to pass to afunc.\n"}, 
  {"amos_callf", amos_callf, METH_VARARGS, 
   "amos_callf(afunc, *args)\n" 
   "  afunc: amos function to call.\n"
   "  *args: arguments to pass to afunc.\n"}, 
  {NULL, NULL}  /* Sentinel */
};

#ifndef PyMODINIT_FUNC	/* declarations for DLL import/export */
#define PyMODINIT_FUNC void
#endif
PyMODINIT_FUNC
initamos2(void) 
{
  PyObject* m;
  static void *Amos_API[Amos_API_pointers];
  PyObject *pAmosAPIObject;

  

  // initialize amos 
#ifdef AMOS_MODULE
  //pycallout_register();   /* Initialize python callout */
  //dcl_connection(c);
  //pymodule_register();    /* Register python module loading */
  pyobj_register();
#endif

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "entered initamos2\n");
#endif

  if (PyType_Ready(&AmosObj) < 0) return;

  m = Py_InitModule3(AMOS_MOUDLE, module_methods,
                     "Amos 2 module.");
#ifdef PYAMOS_DEBUG
  fprintf(stderr, "executed Py_InitModule3\n");
#endif

  if (m == NULL) {
    return;
  }

  Py_INCREF(&AmosObj);
  PyModule_AddObject(m, "AmosObj", (PyObject *)&AmosObj);

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "executed 3xPyModule_AddObject\n");
#endif

  /* Initialize the C API pointer array */
  Amos_API[AmosObj_AsSurr_NUM] = (void *)AmosObj_AsSurr;
  Amos_API[AmosObj_FromSurr_NUM] = (void *)AmosObj_FromSurr;
  Amos_API[AmosSurr_Check_NUM] = (void *)AmosSurr_Check;

  //Amos_API[AmosConn_Create_NUM] = (void *)AmosConn_Create;
  Amos_API[AmosObj_AsConn_NUM] = (void *)AmosObj_AsConn;
  Amos_API[AmosObj_FromConn_NUM] = (void *)AmosObj_FromConn;
  Amos_API[AmosConn_Check_NUM] = (void *)AmosConn_Check;

  //Amos_API[AmosScan_Create_NUM] = (void *)AmosScan_Create;
  Amos_API[AmosObj_AsScan_NUM] = (void *)AmosObj_AsScan;
  Amos_API[AmosObj_FromScan_NUM] = (void *)AmosObj_FromScan;
  Amos_API[AmosScan_Check_NUM] = (void *)AmosScan_Check;

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "initialized Amos_API array\n");
#endif

  /* Create a Capsule containing the API pointer array's address */
#ifdef Py_CAPSULE_H
  pAmosAPIObject = PyCapsule_New((void *)Amos_API, AMOS_MOUDLE "._C_API", NULL);
#else
  pAmosAPIObject = PyCObject_FromVoidPtr((void *)Amos_API, NULL);
#endif;

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "created capsule\n");
#endif 

  if (pAmosAPIObject != NULL) {
    PyModule_AddObject(m, "_C_API", pAmosAPIObject);
  }

#ifdef PYAMOS_DEBUG
  fprintf(stderr, "leaving initamos2\n");
#endif
}

