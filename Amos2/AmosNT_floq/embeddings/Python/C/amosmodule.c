/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: amosmodule.c,v $
 * $Revision: 1.13 $ $Date: 2012/06/28 13:46:18 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Python oidtype wrapper.
 * ===========================================================================
 * $Log: amosmodule.c,v $
 * Revision 1.13  2012/06/28 13:46:18  andan342
 * Fixed misplaced 'static' declaration in C sources
 * Added Linux makefile
 *
 * Revision 1.12  2012/06/27 19:20:06  torer
 * options in custom C functions passed as property list to scan functions
 *
 * Revision 1.11  2012/06/08 16:35:39  larme597
 * Stream function calls updated.
 *
 * Revision 1.10  2011/12/17 16:16:17  torer
 * Storage leaks fixed
 *
 * Revision 1.9  2011/06/01 15:10:56  roka4241
 * AmosObj objects containing any kind of oidtype are now hashable and comparable. Made NumPy optional by PYAMOS_NUMPY flag.
 *
 * Revision 1.8  2011/05/31 16:16:41  roka4241
 * Moved the amos context and pyamos callinfo into a pyamos context struct for faster loading and unloading during coroutine context switching.
 *
 * Revision 1.7  2011/05/31 15:19:00  roka4241
 * Fixed amos_map_func in callin. Record to dict conversion.
 *
 * Revision 1.6  2011/05/24 16:19:14  roka4241
 * Fixed errors in MVC settings. Added support for skipping in an python mapper (return nothing). Also added support for premature breaking. Simplified some regression tests.
 *
 * Revision 1.5  2011/05/18 15:03:41  roka4241
 * Fast nested loop join implemented using mapping over generators.
 *
 * Revision 1.4  2011/05/16 15:56:13  roka4241
 * Implemented and tested nested loop join and mergejoin as python foreign functions. Started with a mapped nested loop join.
 *
 * Revision 1.3  2011/05/11 18:26:18  roka4241
 * Opening of streams over amos functions, queries and generators (bags). Implicit and explicit iteration over bag streams from python (either by explicitly opening a stream over the bag and iterating over the stream, or by iterating over the bag directly).
 *
 * Revision 1.2  2011/05/06 15:56:53  torer
 * nytt
 *
 * Revision 1.1  2011/05/05 16:44:01  roka4241
 * moved the whole project down one directory
 *
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
#include "storagetypes.h"
#include "pyobj.h"
#include "amosmodule.h"
#include "scan.h"
#include "pycallout.h"

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
  if (pSelf->iType == CONNECTIONTYPE) {
    free_connection(pSelf->uObj.aConn);
  } else {
    a_free(pSelf->uObj.oObj);
  }

  pSelf->ob_type->tp_free((PyObject*)pSelf);
}

static oidtype 
AmosObj_AsObj(PyAmosObj *pObj) {
  return pObj->uObj.oObj;
}

long AmosObj_Hash(PyObject *pObj)
{
  if (((PyAmosObj *)pObj)->iType != CONNECTIONTYPE) {
    return (long)compute_hash_key(AmosObj_AsObj((PyAmosObj *)pObj));
  } else {
    PyErr_Format(PyExc_TypeError, "AmosObj of type %i is not hashable.", ((PyAmosObj *)pObj)->iType);
    return -1;
  }
}

int AmosObj_Compare(PyObject *pObj, PyObject *pObj2) 
{
  if (((PyAmosObj *)pObj)->iType != CONNECTIONTYPE && ((PyAmosObj *)pObj2)->iType != CONNECTIONTYPE) {
    return (long)a_compare(AmosObj_AsObj((PyAmosObj *)pObj), AmosObj_AsObj((PyAmosObj *)pObj2));
  } else {
    PyErr_Format(PyExc_TypeError, "AmosObj of type %i is not comparable with AmosObj of type %i.", ((PyAmosObj *)pObj)->iType, ((PyAmosObj *)pObj2)->iType);
    return -1;
  }
}

static PyObject *
AmosObj_GetOid(PyAmosObj *pSelf)
{
  return PyLong_FromLong((int)AmosObj_AsObj(pSelf));
}

static PyObject *
AmosObj_GetType(PyAmosObj *pSelf)
{
  return PyLong_FromLong(pSelf->iType);
}

static PyObject * 
AmosObj_iter(PyObject *pSelf)
{
  if (((PyAmosObj *)pSelf)->iType == scantype) {
    Py_INCREF(pSelf);
    return pSelf;
  } else if (((PyAmosObj *)pSelf)->iType == generatortype) {
    PyObject *pArgs, *pIter;
    pArgs = Py_BuildValue("(O)", pSelf);
    pIter = amos_stream_gen(NULL, pArgs);
    Py_DECREF(pArgs);
    return pIter;
  } else {
    PyErr_Format(PyExc_NotImplementedError, "AmosObj_iter supports only amos stream objects. Got amos object of type %i.", ((PyAmosObj *)pSelf)->iType);
    Py_INCREF(Py_None);
    return Py_None;
  }

  Py_INCREF(pSelf);
  return pSelf;
}

static PyObject * 
AmosStream_iternext(PyObject *pSelf)
{
  oidtype oRow;

  if ((oRow = stream_nextfn(varstack, ((PyAmosObj *)pSelf)->uObj.oObj)) != nil) {
    return obj_to_pyobj(oRow);
  } else {
    PyErr_SetNone(PyExc_StopIteration);
    return NULL;
  }
}


static PyObject * 
AmosObj_iternext(PyObject *pSelf)
{
  if (((PyAmosObj *)pSelf)->iType == scantype) {
    return AmosStream_iternext(pSelf);
  } else {
        PyErr_Format(PyExc_NotImplementedError, "AmosObj_iternext supports only amos stream objects. Got amos object of type %i.", ((PyAmosObj *)pSelf)->iType);
    Py_INCREF(Py_None);
    return Py_None;
    
  } 
}

static PyMethodDef AmosObj_methods[] = {
  {"get_oid", (PyCFunction)AmosObj_GetOid, METH_NOARGS,
   "Return amos object id."},

  {"get_type", (PyCFunction)AmosObj_GetType, METH_NOARGS,
   "Return amos object type number."},
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
  AmosObj_Compare,           /*tp_compare*/
  0,                         /*tp_repr*/
  0,                         /*tp_as_number*/
  0,                         /*tp_as_sequence*/
  0,                         /*tp_as_mapping*/
  AmosObj_Hash,              /*tp_hash */
  0,                         /*tp_call*/
  0,                         /*tp_str*/
  0,                         /*tp_getattro*/
  0,                         /*tp_setattro*/
  0,                         /*tp_as_buffer*/
  Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE | Py_TPFLAGS_HAVE_ITER, /*tp_flags*/
  "Amos object wrapper.", /* tp_doc */
  0,                             /* tp_traverse */
  0,                             /* tp_clear */
  0,                             /* tp_richcompare */
  0,                             /* tp_weaklistoffset */
  AmosObj_iter,              /* tp_iter */
  AmosObj_iternext,          /* tp_iternext */
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
PyAmosObj *
AmosObj_FromSurr(oidtype oSurr) 
{
  PyAmosObj *pObj;

  incref(doid(oSurr));

  pObj = AmosObj_Create();
  pObj->iType = SURROGATETYPE;
  pObj->uObj.oObj = oSurr;
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


// Stream
PyAmosObj *
AmosObj_FromStream(oidtype oStream) 
{
  PyAmosObj *pObj;

  incref(doid(oStream));

  pObj = AmosObj_Create();
  pObj->iType = scantype;
  pObj->uObj.oObj = oStream;
  return pObj;
}

int 
AmosStream_Check(PyObject *pObj) {
  return AmosObj_Check(pObj) && ((PyAmosObj *)pObj)->iType == scantype;
}

// Generator
PyAmosObj *
AmosObj_FromGen(oidtype oGen) 
{
  PyAmosObj *pObj;

  incref(doid(oGen));

  pObj = AmosObj_Create();
  pObj->iType = generatortype;
  pObj->uObj.oObj = oGen;
  return pObj;
}

int 
AmosGen_Check(PyObject *pObj) {
  return AmosObj_Check(pObj) && ((PyAmosObj *)pObj)->iType == generatortype;
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

        sprintf(sDumpPath, "%s/bin/amos2.dmp", sAmosHome);
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

oidtype extract_amos_fn(PyObject *pArgs, int iPos) 
{
  PyObject *pFn;
  oidtype oFn;
  char *sFn;

  pFn = PyTuple_GetItem(pArgs, iPos);
  if(PyString_Check(pFn)) 
    {
      sFn = PyString_AsString(pFn);

      oFn = a_getfunctionnamed(sFn, TRUE); 
      if(a_errorflag) 
	{
	  PyErr_Format(PyExc_NotImplementedError, 
		       "Error when trying to resolve amos function %s.", sFn);
	  return nil;
	} 
      else if (oFn == nil) 
	{
	  PyErr_Format(PyExc_NotImplementedError, 
		       "Failed to resolve amos function %s.", sFn);
	  return nil;
	}
    } 
  else if(AmosSurr_Check(pFn)) 
    {
      a_let(oFn, AmosObj_AsObj(((PyAmosObj *)pFn)));
    }
  else
    {
      PyErr_SetString(PyExc_TypeError, 
		      "Expecting string or oid function parameter.");
      return nil;
    }
  return oFn;
}


oidtype amos_map_func_mapper(a_callcontext aCxt, int iWidth, oidtype oTpl[], PyObject *pMapper) {
  PyObject *pExc, *pArg, *pMapperRet, *pArgs;

  pArg = obj_to_pyobj(*oTpl);

  if (PyErr_Occurred()) {
    PyErr_Print();
    fprintf(stderr, "amos_map_mapper: Cannot convert argument:\n");
    a_print(*oTpl);
    PyErr_Clear();
    return nil;
  }



  pArgs = Py_BuildValue("(O)", pArg);
  pMapperRet = PyObject_CallObject(pMapper, pArgs);
  Py_DECREF(pArgs);
  
  
  if (pyaCxt.aCxt != NULL) {
    // an exception was thrown
    if (pExc = PyErr_Occurred()) {
      // the python mapper wants to stop
      if (PyErr_GivenExceptionMatches(pExc, PyExc_StopIteration)) {
        PyErr_Clear();
        a_map_done(aCxt, oTpl[0]);
      // something really went wrong
      } else {
        PyErr_Print();
        fprintf(stderr, "amos_map_mapper: Mapper call failed.\n");
        PyErr_Clear();
      }
      return nil;
    // check if we should emit the result or just continue (i.e. if nothing was returned)
    } else if (pMapperRet != NULL) {
      pycallout_emit_obj(pyaCxt.aCxt, pyaCxt.pyaCi, pMapperRet); 
      Py_DECREF(pMapperRet);
    }

  } else {
    Py_XDECREF(pMapperRet);
  }

  
  return nil;
}

static PyObject *amos_map_func(PyObject *pSelf, PyObject *pArgs)
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
    fprintf(stderr, "amos_map_func: The supplied mapper is not callable.\n");
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
    oArgs[i] = pyobj_to_obj(aCxt->env, pArg);
    }

  // Call amos function
  a_mapfunctionC(aCxt, oFn, iArity-2, oArgs, amos_map_func_mapper, pMapper); 

  if(a_errorflag) {
        fprintf(stderr, "amos_map_func: Call to a_mapfunctionC failed.");
    AMOS_ERROR(PYAMOS_MAP_FUNC_MAPFUNCTIONC);
    }

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *amos_map_gen(PyObject *pSelf, PyObject *pArgs)
{
  PyObject *pMapper, *pGen;
  dcl_global_cxt(aCxt);
  oidtype oGen;

  // Get python mapper function
  pMapper = PyTuple_GetItem(pArgs, 0);
  if (!PyCallable_Check(pMapper)) 
  {
    fprintf(stderr, "The supplied mapper is not callable.\n");
    Py_INCREF(Py_None);
    return Py_None;
  }

  // Get amos generator
  pGen = PyTuple_GetItem(pArgs, 1);
  oGen = pyobj_to_obj(aCxt->env, pGen);
  if (oGen == nil) 
    {
      Py_INCREF(Py_None);
      return Py_None;
    }

  // Map amos generator
  a_mapbag(aCxt, oGen, amos_map_func_mapper, pMapper); 
  release(oGen);
  if(a_errorflag) 
    {
      fprintf(stderr, "Mapping over Amos function failed.");
      AMOS_ERROR(PYAMOS_MAP_GEN_MAPGENC);
    }

  Py_INCREF(Py_None);
  return Py_None;
}

static PyObject *amos_call_func(PyObject *pSelf, PyObject *pArgs)
{
  oidtype oFn, oResult;
  dcl_global_cxt(aCxt);
  dcl_tuple(aArgs);
  PyObject *res;

  // Get amos function
  oFn = extract_amos_fn(pArgs, 0);
  if (oFn == nil) 
    {
      Py_INCREF(Py_None);
      return Py_None;
    }
  // Build the amos arguments
  pyargs_to_args(aCxt, pArgs, aArgs, 1);

  // Call amos function
  oResult = callfunction(aCxt->env, oFn, aArgs->tpl, -1); 
  free_tuple(aArgs);
  if(a_errorflag) 
    {
      fprintf(stderr, "Call to callfunction failed.");
      AMOS_ERROR(amos_call_func);
      Py_INCREF(Py_None);
      return Py_None;
    }
  res = obj_to_pyobj(oResult);
  release(oResult);
  return res;
}

static PyObject *amos_stream_func(PyObject *pSelf, PyObject *pArgs) 
{
  oidtype oFn, oStream;
  PyObject *res;
  dcl_global_cxt(aCxt);
  dcl_tuple(aArgs);

  // Get amos function
  oFn = extract_amos_fn(pArgs, 0);
  if (oFn == nil) 
    {
      Py_INCREF(Py_None);
      return Py_None;
    }

  // Build the amos arguments
  pyargs_to_args(aCxt, pArgs, aArgs, 1);

  // Call amos function
  oStream = open_function_streamfn(aCxt->env, oFn, aArgs->tpl, nil);
  free_tuple(aArgs); 
  res = obj_to_pyobj(oStream);
  release(oStream);
  return res;
}

static PyObject *amos_stream_query(PyObject *pSelf, PyObject *pArgs) 
{
  PyObject *pQuery, *res;
  oidtype oQuery, oStream;

  dcl_global_cxt(aCxt);

  // Get query
  pQuery = PyTuple_GetItem(pArgs, 0);
  if(!PyString_Check(pQuery)) 
    {
      PyErr_SetString(PyExc_TypeError, "The amos query must be a string.");
      Py_INCREF(Py_None);
      return Py_None;
    }
  oQuery = pyobj_to_obj(aCxt->env, pQuery);

  // Execute amos query
  oStream = open_query_streamfn(aCxt->env, oQuery, nil); 
  res = obj_to_pyobj(oStream);
  release(oStream);
  release(oQuery);
  return res;
}

PyObject *amos_stream_gen(PyObject *pSelf, PyObject *pArgs) {
  PyObject *pGen;
  oidtype oGen, oStream;

  dcl_global_cxt(aCxt);

  // Get query
  pGen = PyTuple_GetItem(pArgs, 0);

  if(!AmosGen_Check(pGen)) {
    PyErr_SetString(PyExc_TypeError, "Expecting an amos generator object.");
    Py_INCREF(Py_None);
    return Py_None;
  }
  oGen = pyobj_to_obj(aCxt->env, pGen);

  // Execute amos query
  oStream = open_bag_streamfn(aCxt->env, oGen, nil); 
  return obj_to_pyobj(oStream);
}

void amosmodule_register_errors(void) 
{
  PYAMOS_MAP_FUNC_MAPFUNCTIONC = a_register_error("PYAMOS_MAP_FUNC_MAPFUNCTIONC, Call to a_mapfunctionC failed.");
  PYAMOS_MAP_GEN_MAPGENC = a_register_error("PYAMOS_MAP_GEN_MAPGENC, Call to a_mapgenC failed.");
}

static PyMethodDef module_methods[] = {
  {"amos_connect", amos_connect, METH_VARARGS, 
     "amos_connect(peer)\n  peer: peer is the name of the Amos II database to connect to. If peer is the empty string it represents a connection to the embedded database; otherwise peer must be the name of an Amos II peer known to the nameserver running on the same host as the application.\n Returns: An Amos II connection.\n"},
  
  {"amos_map_func", amos_map_func, METH_VARARGS, 
   "amos_map_func(mapper, a_func, *args), map over amos function a_func using python function mapper.\n" 
   "  mapper: python mapper function."
   "  a_func: amos function to map.\n"
   "  *args: arguments to pass to afunc.\n"}, 

  {"amos_map_gen", amos_map_gen, METH_VARARGS, 
   "amos_map_gen(mapper, a_gen), map over amos generator (bag) a_gen using python function mapper.\n" 
   "  mapper: python mapper function."
   "  a_gen: amos generator to map.\n"}, 

  {"amos_call_func", amos_call_func, METH_VARARGS, 
   "amos_call_func(a_func, *args), call amos function a_func with args.\n" 
   "  a_func: amos function to call.\n"
   "  *args: arguments to pass to a_func.\n"}, 


  {"amos_stream_func", amos_stream_func, METH_VARARGS, 
   "amos_stream_func(a_func, *args), make a stream from the result of calling the amos function a_func with args.\n" 
   "  a_gen: amos function to wrap.\n"
   "  *args: arguments to pass to a_func.\n"}, 

  {"amos_stream_query", amos_stream_query, METH_VARARGS, 
   "amos_stream_query(a_query), make a stream from the result of executing the amos query a_query.\n" 
   "  a_gen: amos query to wrap.\n"}, 
  
  {"amos_stream_gen", amos_stream_gen, METH_VARARGS, 
   "amos_stream_gen(a_gen), make a stream from an amos generator.\n" 
   "  a_gen: amos generator to wrap.\n"}, 
  {NULL, NULL}  /* Sentinel */
};

#ifndef PyMODINIT_FUNC  /* declarations for DLL import/export */
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
  amosmodule_register_errors();
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
  Amos_API[AmosObj_AsSurr_NUM] = (void *)AmosObj_AsObj;
  Amos_API[AmosObj_FromSurr_NUM] = (void *)AmosObj_FromSurr;
  Amos_API[AmosSurr_Check_NUM] = (void *)AmosSurr_Check;

  Amos_API[AmosObj_AsConn_NUM] = (void *)AmosObj_AsConn;
  Amos_API[AmosObj_FromConn_NUM] = (void *)AmosObj_FromConn;
  Amos_API[AmosConn_Check_NUM] = (void *)AmosConn_Check;

  Amos_API[AmosObj_AsStream_NUM] = (void *)AmosObj_AsObj;
  Amos_API[AmosObj_FromStream_NUM] = (void *)AmosObj_FromStream;
  Amos_API[AmosStream_Check_NUM] = (void *)AmosStream_Check;

  Amos_API[AmosObj_AsGen_NUM] = (void *)AmosObj_AsObj;
  Amos_API[AmosObj_FromGen_NUM] = (void *)AmosObj_FromGen;
  Amos_API[AmosGen_Check_NUM] = (void *)AmosGen_Check;

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

