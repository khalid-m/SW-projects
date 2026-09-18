/*****************************************************************************
 * AMOS2
 *
 * Author:  Hanzheng Zou
 *
 * Description: Amos II as plug-in to Python
 * ===========================================================================
 *
 ****************************************************************************/

#include "Python.h"
#include "callin.h"


//Threee types of pythonCfunc
static PyObject *MyFunction( PyObject *self, PyObject *args );
static PyObject *MyFunctionWithKeywords(PyObject *self,PyObject *args,PyObject *kw);
static PyObject *MyFunctionWithNoArgs( PyObject *self );

static PyObject * ex_amos_call(PyObject *self, PyObject *args);
static PyObject * ex_amos_call_1(PyObject *self, PyObject *args);
static PyObject * ex_amos_connect(PyObject *self, PyObject *args);
static PyObject * ex_amos_execute(PyObject *self, PyObject *args);
static PyObject * ex_amos_eos(PyObject *self, PyObject *args);
static PyObject * ex_amos_getrow(PyObject *self, PyObject *args);
static PyObject * ex_amos_next(PyObject *self, PyObject *args);
static PyObject * ex_amos_getfunction(PyObject *self, PyObject *args);
static PyObject * ex_amos_disconnect(PyObject *self, PyObject *args);

static PyObject * ex_amos_closeScan(PyObject *self, PyObject *args);
static PyObject * ex_amos_createobject(PyObject *self, PyObject *args);
static PyObject * ex_amos_deleteobject(PyObject *self, PyObject *args);
static PyObject * ex_amos_commit(PyObject *self, PyObject *args);
static PyObject * ex_amos_rollback(PyObject *self, PyObject *args);


char* make_OID_string(oidtype oid);
oidtype getoidtype(char *s, a_connection conn);
int is_OID_string(char *str);
PyObject* amostuple_to_pytuple(a_tuple tpl);
a_tuple pytuple_to_amostuple(PyObject *pyTuple,a_connection conn);

int TestConnectMain();

//PyErr_Format(PyExc_RuntimeError, "a_errstr:%s", a_errstr);


/* Error Messages */
#define ILLEGAL_PARAM PyErr_BadArgument();
#define AMOS_ERROR (a_errform==nil?PyErr_Format(PyExc_RuntimeError, "a_errstr:%s", a_errstr):PyErr_Format(PyExc_RuntimeError, "%s : %s", a_errstr, a_to_string(a_errform)))
//#define AMOS_WARNING (a_errform==nil?PyErr_Format(PyExc_RuntimeError, "a_errstr:%s", a_errstr):PyErr_Format(E_WARNING, "%s : %s", a_errstr, a_to_string(a_errform)))
#define CHECK_AMOS_ERROR if(a_errorflag) AMOS_ERROR
int empty_scan; /* Amos II error id */

////////////////////////////////////////////////////////////////////////////////////
// Here we use some definition that might use in python 3.0

struct module_state {
	PyObject *error;
};
#if PY_MAJOR_VERSION >= 3 
   #define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))
#else
#define GETSTATE(m) (&_state)
static struct module_state _state;
#endif

static PyObject * error_out(PyObject *m) 
{ 
	struct module_state *st ;
	st = GETSTATE(m);
	PyErr_SetString(st->error, "something bad happened");
	return NULL;
}

static int myextension_traverse(PyObject *m, visitproc visit, void *arg) {
	Py_VISIT(GETSTATE(m)->error);
	return 0;
}

static int myextension_clear(PyObject *m) {
	printf("Exit module and clear all things\n");
	Py_CLEAR(GETSTATE(m)->error);
	return 0;
}


static PyMethodDef amos2_methods[] = {
	
	{"amos_connect", ex_amos_connect, METH_VARARGS, 
		"amos_connect(dbName)\n  dbName : This is a string object.And will pass the AmosII database name to the function\n Return:The function will return a reference of AmosII connection object\n"},
	{"amos_execute", ex_amos_execute, METH_VARARGS, 
		"amos_execute(connection,queryString)\n connection:This is a reference of AmosII connection object, which is created by amos_connection(dbName) function\n queryString: string object,the query string that you want to execute\n Return: Will return the reference of AmosII Scan object"},
	{"amos_eos", ex_amos_eos, METH_VARARGS, 
		"amos_eos(scan)\n  scan:the reference of scan object\n Return: Will return True or False\n"},
	{"amos_getrow", ex_amos_getrow, METH_VARARGS, 
		"amos_getrow(scan)\n scan:the reference of scan object\n Return: return none\n"},
	{"amos_next", ex_amos_next, METH_VARARGS, 
		"amos_next(scan)\n scan:the reference of scan object\n Return: return none\n"},
	{"amos_getfunction", ex_amos_getfunction, METH_VARARGS, 
		"amos_getfunction(connection,functionName,errorTrack) \nconnection:This is a reference of AmosII connection object, which is created by amos_connection(dbName) function\n"},
	{"amos_call", ex_amos_call, METH_VARARGS, 
		"amos_call(connection, function, a1,....,an ) -> scan\n connection:This is a reference of AmosII connection object, which is created by amos_connection(dbName) function\n function: function you wanna call\n a1,a2....: parameters for the function calling\n call function and will return a Scan object\n"},

	{ "amos_call_1",    (PyCFunction) ex_amos_call_1, METH_VARARGS,
         "amos_call_1(connection, function, a1,....,an ) -> scan\n connection:This is a reference of AmosII connection object, which is created by amos_connection(dbName) function\n function: function you wanna call\n a1,a2....: parameters for the function calling\n call function and will return a Value" },
	
	{"amos_disconnect", ex_amos_disconnect, METH_VARARGS, 
		"amos_disconnect(conn)\n Disconnect the connection when done\n"},

	//{"amos_openScan", ex_amos_openScan, METH_VARARGS, 
	//	"amos_openScan(conn) \n Will return a Scan Object\n"},
	{"amos_closeScan", ex_amos_closeScan, METH_VARARGS, 
		"amos_closeScan(scan)\n Will clear up an Scan Object\n"},
	//{"amos_getType", ex_amos_getType, METH_VARARGS, 
	//	"amos_getType(conn,typename)\n Will return a OID string\n"},
	{"amos_createobject", ex_amos_createobject, METH_VARARGS, 
		"amos_createobject(conn,ObjectName)\n Will return a OID string\n"},
	{"amos_deleteobject", ex_amos_deleteobject, METH_VARARGS, 
		"amos_deleteobject(conn,ObjectName)\n Passing a OID string and delete the related AmosII object\n"},

	//{"amos_addfunction", ex_amos_addfunction, METH_VARARGS, 
	//	"amos_addfunction(conn,funcname,arglTuple)\n"},
	//{"amos_setfunction", ex_amos_setfunction, METH_VARARGS, 
	//	"amos_setfunction(conn,funcname,arglTuple)\n"},
	//{"amos_remfunction", ex_amos_remfunction, METH_VARARGS, 
	//	"amos_remfunction(conn,funcname,arglTuple)\n"},

	{"amos_commit", ex_amos_commit, METH_VARARGS, 
		"amos_commit(conn)\n Commit the changes\n"},
	{"amos_rollback", ex_amos_rollback, METH_VARARGS, 
		"amos_rollback(conn)\n Rollback the execution\n"},

	//{"foo", ex_foo, METH_VARARGS, "foo() \n Sample AMOS2 excutions"},

	{NULL, NULL}
};

/* 
	This is Python Object definition for the AmosII a_scan 
	Use the AmosScanObject, we can make a_scan object used in Python
 */

typedef struct {
    PyObject_HEAD
	a_scan _scan;
} Py_AmosScanObject;

static PyMethodDef AmosScan_methods[] = {
    
    { NULL }
};
static int AmosScanObject_init(Py_AmosScanObject *self, PyObject *args, PyObject *kwds)
{
	printf("print in the AmosScan Init function\n");

	PyErr_SetString(PyExc_RuntimeError,"Can Not create an empty AmosScan Object");
	
	PyObject_Del(self);
	
	return 0;
}
static void AmosScanObject_dealloc(Py_AmosScanObject* self)
{
	//printf("[#del] Deallocate the AmosScan\n");

	if(self->_scan)
		free_scan(self->_scan);
    
	PyObject_Del(self);
}
static PyTypeObject AmosScanType = {
    PyObject_HEAD_INIT(NULL)
    0,
    "AmosScan",
    sizeof(Py_AmosScanObject),
    0,
    (destructor)AmosScanObject_dealloc, ///tp_dealloc
     0,                         /* tp_print */
   0,                         /* tp_getattr */
   0,                         /* tp_setattr */
   0,                         /* tp_compare */
   0,                         /* tp_repr */
   0,                         /* tp_as_number */
   0,                         /* tp_as_sequence */
   0,                         /* tp_as_mapping */
   0,                         /* tp_hash */
   0,                         /* tp_call */
   0,                         /* tp_str */
   0,                         /* tp_getattro */
   0,                         /* tp_setattro */
   0,                         /* tp_as_buffer */
   Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /* tp_flags*/
   "AmosScan object",         /* tp_doc */
   0,                         /* tp_traverse */
   0,                         /* tp_clear */
   0,                         /* tp_richcompare */
   0,                         /* tp_weaklistoffset */
   0,                         /* tp_iter */
   0,                         /* tp_iternext */
   AmosScan_methods,         /* tp_methods */
   0,						  /* tp_members */
   0,                         /* tp_getset */
   0,                         /* tp_base */
   0,                         /* tp_dict */
   0,                         /* tp_descr_get */
   0,                         /* tp_descr_set */
   0,                         /* tp_dictoffset */
   (initproc)AmosScanObject_init,  /* tp_init */
   0,                         /* tp_alloc */
   0,                         /* tp_new */
};
static Py_AmosScanObject* new_AmosScanObject()
{
    Py_AmosScanObject* scanObj;

    scanObj = PyObject_New(Py_AmosScanObject, &AmosScanType);
    //scanObj = _PyObject_New( &AmosScanType);
    return scanObj;
}


/* 
	This is Python Object definition for the AmosII a_conn 
 */
//static PyTypeObject AmosConnType;

typedef struct {
    PyObject_HEAD
	a_connection _conn;
} Py_AmosConnObject;

static int AmosConnObject_init(Py_AmosConnObject *self, PyObject *args, PyObject *kwds)
{
	dcl_connection(conn); 

	self->_conn = conn;
	printf("print in the AmosConn Init function\n");

	return 0;
}
static void AmosConnObject_dealloc(Py_AmosConnObject* self)
{
	//printf("[#del] Deallocate the AmosConn \n");

	if(self->_conn)
	  free_connection(self->_conn);

    PyObject_Del(self);
}
static PyMethodDef AmosConn_methods[] = {
	
   { NULL }
};

static PyTypeObject AmosConnType = {
   PyObject_HEAD_INIT(NULL)
   0,                         /* ob_size */
   "AmosConn",               /* tp_name */
   sizeof(Py_AmosConnObject), /* tp_basicsize */
   0,                         /* tp_itemsize */
   (destructor)AmosConnObject_dealloc, /* tp_dealloc */
   0,                         /* tp_print */
   0,                         /* tp_getattr */
   0,                         /* tp_setattr */
   0,                         /* tp_compare */
   0,                         /* tp_repr */
   0,                         /* tp_as_number */
   0,                         /* tp_as_sequence */
   0,                         /* tp_as_mapping */
   0,                         /* tp_hash */
   0,                         /* tp_call */
   0,                         /* tp_str */
   0,                         /* tp_getattro */
   0,                         /* tp_setattro */
   0,                         /* tp_as_buffer */
   Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /* tp_flags*/
   "AmosConn object",        /* tp_doc */
   0,                         /* tp_traverse */
   0,                         /* tp_clear */
   0,                         /* tp_richcompare */
   0,                         /* tp_weaklistoffset */
   0,                         /* tp_iter */
   0,                         /* tp_iternext */
   AmosConn_methods,         /* tp_methods */
   0,						  /* tp_members */
   0,                         /* tp_getset */
   0,                         /* tp_base */
   0,                         /* tp_dict */
   0,                         /* tp_descr_get */
   0,                         /* tp_descr_set */
   0,                         /* tp_dictoffset */
   (initproc)AmosConnObject_init,  /* tp_init */
   0,                         /* tp_alloc */
   0,                         /* tp_new */
};
static Py_AmosConnObject* new_AmosConnObject()
{
    Py_AmosConnObject* connObj;

    connObj = PyObject_New(Py_AmosConnObject, &AmosConnType);

    return connObj;
}

/* 
	This is Python Object definition for the AmosII OID 
 */
//static PyTypeObject AmosOIDType;

typedef struct {
    PyObject_HEAD
	oidtype _oid;
} Py_AmosOIDObject;

static int AmosOIDObject_init(Py_AmosOIDObject *self, PyObject *args, PyObject *kwds)
{

	printf("print in the AmosOIDObject Init function\n");

	return 0;
}
static void AmosOIDObject_dealloc(Py_AmosOIDObject* self)
{
	//printf("[#del] Deallocate the OID \n");

	if(self->_oid)
	   a_free(self->_oid); // release()

    PyObject_Del(self);
}
static PyObject * AmosOID_toString(Py_AmosOIDObject *self, PyObject *args)
{
	oidtype oid;
	char * OID_str;
	PyObject* ret;

	oid = self->_oid;

	OID_str = make_OID_string(oid);
	ret = Py_BuildValue("s", OID_str);
	Py_INCREF(ret);
	return  ret;

	//Py_INCREF(Py_None);
	//return Py_None;
}
static PyMethodDef AmosOID_methods[] = {
   { "toString",    (PyCFunction) AmosOID_toString, METH_VARARGS,
               "AmosOID toString function" },
   { NULL }
};

static PyTypeObject AmosOIDType = {
   PyObject_HEAD_INIT(NULL)
   0,                         /* ob_size */
   "AmosOID",               /* tp_name */
   sizeof(Py_AmosOIDObject), /* tp_basicsize */
   0,                         /* tp_itemsize */
   (destructor)AmosOIDObject_dealloc, /* tp_dealloc */
   0,                         /* tp_print */
   0,                         /* tp_getattr */
   0,                         /* tp_setattr */
   0,                         /* tp_compare */
   0,                         /* tp_repr */
   0,                         /* tp_as_number */
   0,                         /* tp_as_sequence */
   0,                         /* tp_as_mapping */
   0,                         /* tp_hash */
   0,                         /* tp_call */
   0,                         /* tp_str */
   0,                         /* tp_getattro */
   0,                         /* tp_setattro */
   0,                         /* tp_as_buffer */
   Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /* tp_flags*/ 
   "AmosOID object",        /* tp_doc */
   0,                         /* tp_traverse */
   0,                         /* tp_clear */
   0,                         /* tp_richcompare */
   0,                         /* tp_weaklistoffset */
   0,                         /* tp_iter */
   0,                         /* tp_iternext */
   AmosOID_methods,         /* tp_methods */
   0,						  /* tp_members */
   0,                         /* tp_getset */
   0,                         /* tp_base */
   0,                         /* tp_dict */
   0,                         /* tp_descr_get */
   0,                         /* tp_descr_set */
   0,                         /* tp_dictoffset */
   (initproc)AmosOIDObject_init,  /* tp_init */
   0,                         /* tp_alloc */
   0,                         /* tp_new */
};
static Py_AmosOIDObject* new_AmosOIDObject()
{
    Py_AmosOIDObject* oidObj;

    oidObj = PyObject_New(Py_AmosOIDObject, &AmosOIDType);

    return oidObj;
}


/*
   Here start the entrance part of the python extension module
*/
#if PY_MAJOR_VERSION >= 3

static struct PyModuleDef moduledef = {
	PyModuleDef_HEAD_INIT,
	"amos2",
	NULL,
	sizeof(struct module_state),
	amos2_methods,
	NULL,
	myextension_traverse,
	myextension_clear,
	NULL
};
#define INITERROR return NULL
/*
  Entrance of the extension module
*/
PyMODINIT_FUNC PyInit_amos2(void)
#else
#define INITERROR return
PyMODINIT_FUNC initamos2(void)
#endif
{

	PyObject *module;
	PyObject *dict;
	struct module_state * st;

	#if PY_MAJOR_VERSION >= 3
		module = PyModule_Create(&moduledef);
	#else
		module= Py_InitModule("amos2", amos2_methods);
	#endif

	printf("\ncreate python module succeed \n");

	if (module == NULL)
		INITERROR;
	
	st = GETSTATE(module);

	st->error = PyErr_NewException("pythonAmos.Error", NULL, NULL);
	if (st->error == NULL) {
		Py_DECREF(module);
		INITERROR;
	}

	dict = PyModule_GetDict(module);

	///////////////////////////////////////////////////////////////////////////
	// Fill in some slots in the type, and make it ready
	AmosConnType.ob_type = &PyType_Type;
	AmosConnType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&AmosConnType) < 0) {
      return;
	}

	AmosScanType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&AmosScanType) < 0) {
      return;
	}

	AmosOIDType.tp_new = PyType_GenericNew;
	if (PyType_Ready(&AmosOIDType) < 0) {
      return;
	}

	// Add the type to the module.
	Py_INCREF(&AmosConnType);
	PyModule_AddObject(module, "AmosConn", (PyObject*)&AmosConnType);

	Py_INCREF(&AmosScanType);
	PyModule_AddObject(module, "AmosScan", (PyObject*)&AmosScanType);

	Py_INCREF(&AmosOIDType);
	PyModule_AddObject(module, "AmosOID", (PyObject*)&AmosOIDType);

	///////////////////////////////////////////////////////////////////////////

	#if PY_MAJOR_VERSION >= 3
	return module;
	#endif
}

/*
	Here start the amos2.py functions part.
	This is a alternative way of using Amos funcitons in Python
*/

static int isAmosInitialized = 0;

static PyObject * ex_amos_connect(PyObject *self, PyObject *args)
{
	char *dbname;
	Py_AmosConnObject* py_conn;
	

	dcl_connection(conn); /* To hold connection to Amos */

    if (!PyArg_ParseTuple(args, "s", &dbname)) {
	   printf("[#PyAmos] error: wrong args in funcition amos_connect \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(!isAmosInitialized)
	{
		//  Use a static bool variable here, then check if it is initiazled or not
		// just initialize it for one time
		char * pPath;
		char dmpPath[200];
		pPath = getenv ("AMOS_HOME");
		if (pPath!=NULL)
			printf ("[#PyAmos] The amosHome path is: %s\n",pPath);

		sprintf(dmpPath, "%sbin/amos2.dmp", pPath);
		printf ("[#PyAmos] The dmp path is: %s\n",dmpPath);
		a_initialize(dmpPath, TRUE);  // Initialize embedded Amos from %AMOS_HOME/bin
		
		CHECK_AMOS_ERROR;
		printf("[#PyAmos] Amos Initialize done\n");
		isAmosInitialized = 1;
	}

	///*** Always start with connecting to Amos ***/
	a_connect(conn,dbname,TRUE); /*** name "" indicates connect to embedded Amos ***/

	if(a_errorflag)
	{
		free_connection(conn);
		AMOS_ERROR;
		//a_print(a_errform);
		return NULL;
	}

	//CONNECTION = conn;
	printf("[#PyAmos] Amos a_connect done\n");

	//AmosConnType.ob_type = &PyType_Type;
	//py_conn = PyObject_New(Py_AmosConnObject, &AmosConnType);
	py_conn = new_AmosConnObject();
	py_conn->_conn = conn;

	// If dont increase reference count here, the python gc "might" collect it after some excution
	// But if increase here, the AmosConn Object won't run the deallocate function
	//Py_INCREF(py_conn);
	return (PyObject*)py_conn;

}

static PyObject * ex_amos_execute(PyObject *self, PyObject *args)
{
	
	char *queryString;
	a_connection conn;
	Py_AmosConnObject* py_conn;
	Py_AmosScanObject* py_scan;

	if (!PyArg_ParseTuple(args, "Os", &py_conn,&queryString)) {
	   printf("error: wrong args in funcition ex_amos_execute \n");
	   PyErr_BadArgument();
       return NULL;
    };

	
	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] py_conn is not a PyType_Type\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	if(conn == NULL) 
		printf("[#PyAmos] conn get failed");
	else
    {
		dcl_scan(scan);
		//printf("===For Debug====\nBefore a_execute\n");
		a_execute(conn, scan, queryString, TRUE);
		if(a_errorflag)
		{
			free_scan(scan);
			AMOS_ERROR;
			return NULL;
		}

		// printf("Amos a_execute done\n");

		AmosScanType.ob_type = &PyType_Type;
		py_scan = new_AmosScanObject();
		py_scan->_scan = scan;

		//Py_INCREF(py_scan);	
		return (PyObject*)py_scan;

	}

	Py_INCREF(Py_None);
	return Py_None;
}


static PyObject * ex_amos_eos(PyObject *self, PyObject *args)
{

	a_scan scan;
	Py_AmosScanObject* py_scan;

	if (!PyArg_ParseTuple(args, "O", &py_scan)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_scan->ob_type !=  &AmosScanType)
	{
		printf("[#PyAmos] First parameter should be a AmosScanType\n");
		PyErr_BadArgument();
		return NULL;
	}

	scan = py_scan->_scan;

	if(scan == NULL){
		Py_INCREF(Py_None);
		return Py_None;
	}

	if(a_eos(scan))
		 Py_RETURN_TRUE;
	else
		 Py_RETURN_FALSE;
}

static PyObject * ex_amos_getrow(PyObject *self, PyObject *args)
{
	dcl_tuple(row);
	a_scan scan;
	Py_AmosScanObject* py_scan;
	PyObject * pyRow;

	if (!PyArg_ParseTuple(args, "O", &py_scan)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_scan->ob_type !=  &AmosScanType)
	{
		printf("[#PyAmos] First parameter should be a AmosScanType\n");
		PyErr_BadArgument();
		return NULL;
	}
	
	scan = py_scan->_scan;
	if(scan == NULL){
		return Py_None;
		printf("\n");
	}

	a_getrow(scan, row, TRUE);

	if(a_errorflag)
	{
		free_tuple(row);
		//if(a_errno==empty_scan)
		{
              //ZVAL_NULL(return_value);
			printf("Error %d: %s ",a_errno, a_errstr); 
			a_print(a_errform);
		    Py_INCREF(Py_None);
			return Py_None;
		}
		AMOS_ERROR;
		Py_INCREF(Py_None);
		return Py_None;
	}
	
    pyRow = amostuple_to_pytuple(row);

	free_tuple(row);

	return pyRow;
}


static PyObject * ex_amos_next(PyObject *self, PyObject *args)
{

	dcl_tuple(row);
	a_scan scan;
	Py_AmosScanObject* py_scan;

	if (!PyArg_ParseTuple(args, "O", &py_scan)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_scan->ob_type !=  &AmosScanType)
	{
		printf("[#PyAmos] First parameter should be a AmosScanType\n");
		PyErr_BadArgument();
		return NULL;
	}

	scan = py_scan->_scan;
	if(scan == NULL){
		Py_INCREF(Py_None);
		return Py_None;
		printf("\n");
	}

	if (a_nextrow(scan, TRUE) != 0) 
	{
		AMOS_ERROR;
		Py_INCREF(Py_None);
		return Py_None;
	}
	Py_INCREF(Py_None);
	return Py_None;
}

static PyObject * ex_amos_getfunction(PyObject *self, PyObject *args)
{
	char *name;
	//int catcherror;
	oidtype fct;
	a_connection conn;
	//char * OID_str;
	//PyObject* ret;
	Py_AmosConnObject* py_conn;
	Py_AmosOIDObject* py_oid;

	if (!PyArg_ParseTuple(args, "Os", &py_conn,&name)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	fct = a_getfunction(conn, name, TRUE); // errOpen = FALSE

	if(a_errorflag)
	{
		//free_connection(conn);
		AMOS_ERROR;
		printf("[#PyAmos] Amos getfunction error\n");
		return NULL;
	}

	//OID_str = make_OID_string(fct);
	//ret = Py_BuildValue("s", OID_str);
	//Py_INCREF(ret);
	//return  ret;

	AmosOIDType.ob_type = &PyType_Type;
	py_oid = new_AmosOIDObject();
	a_let(py_oid->_oid,fct);
	return (PyObject*)py_oid;


}


static PyObject * ex_amos_call(PyObject *self, PyObject *args)
{
	/* Call an Amos II function from Python
       Result returned as a scan resource.
	   amos_call(connection, function, a1,....,an ) -> scan
	*/

	a_connection conn;
	dcl_scan(scan);
	dcl_tuple(argl); 
	Py_AmosConnObject* py_conn;
	Py_AmosScanObject* py_scan;
	Py_AmosOIDObject* py_oid;
	PyObject * funcObj;
	//dcl_oid(fct); /* dcl_oid(x) declares a C variable to hold reference to Amos object */
	oidtype fno;
	char * str;
	dcl_tuple(row);  /* To hold results from Amos function calls */
	int argsNum;

	//Parse the argments
	argsNum = PyTuple_Size(args);
	if (argsNum<2)
	{
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong number of parameters");
		return NULL;
	}
	else 
	{
		int i;
		PyObject * item;

		py_conn = (Py_AmosConnObject*)PyTuple_GetItem(args,0);

		if(py_conn->ob_type !=  &AmosConnType)
		{
			printf("[#PyAmos] First parameter should be a AmosConnType\n");
			PyErr_BadArgument();
			return NULL;
		}
		conn = py_conn->_conn;

		//str = PyString_AsString(PyTuple_GetItem(args,1));
		funcObj = PyTuple_GetItem(args,1);

		a_setarity(argl,argsNum-2);

		for(i=0;i<argsNum-2;i++)
		{
			//int j = i+2;
			//dcl_tuple(tpl);
			item = PyTuple_GetItem(args,i+2);

			if(item == Py_None) //if the item is an Py_None
			{
				
			}
			if(PyInt_Check(item)) //if the item is an int
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, TRUE);
			}
			if(item == Py_True)  
				a_setobjectelem(argl, i, a_true, TRUE);
			if(item == Py_False) 
				a_setobjectelem(argl, i, a_false, TRUE);
			else if(PyLong_Check(item)) // if item is long
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, TRUE);

			}
			else if(PyFloat_Check(item)) // if item is double (python float is same as double in C)
			{
				double d;
				d = PyFloat_AsDouble(item);
				a_setdoubleelem(argl, i, d, TRUE);

			}
			else if(PyString_Check(item)) // if item is string
			{
				char* str;
				str = PyString_AsString(item);

				if(is_OID_string(str)) 
					a_setobjectelem(argl, i, getoidtype(str, conn), TRUE);
				else a_setstringelem(argl, i, str, TRUE);

			}
			else if(PyTuple_Check(item)) // if item is tuple or an array
			{
				
				a_tuple vec= pytuple_to_amostuple(item,conn);
				a_setseqelem(argl, i, vec,TRUE);
				free_tuple(vec);
			}

			else if(item->ob_type ==  &AmosOIDType) // if item is OID
			{
				Py_AmosOIDObject*  py_oid = (Py_AmosOIDObject* )item;

				a_setobjectelem(argl, i, py_oid->_oid, TRUE);
			}

			if(a_errorflag)
			{
				free_tuple(argl);
				AMOS_ERROR;
				return NULL;
			}		
		}
	}


	if(PyString_Check(funcObj))
	{
		str = PyString_AsString(funcObj);

		fno = a_getfunction(conn, str, TRUE); 

		if(a_errorflag)
		{
			AMOS_ERROR;
			printf("[#PyAmos] Amos getfunction error\n");
			return NULL;
		}
	}
	else if(funcObj->ob_type ==  &AmosOIDType)
	{
		py_oid = (Py_AmosOIDObject* )funcObj;
		//fno = py_oid->_oid;
		a_let(fno,py_oid->_oid);
	}
	else{
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong Function/functionOID parameters");
		Py_INCREF(Py_None);
		return Py_None;
	}
	
	CHECK_AMOS_ERROR;
	{

		a_callfunction(conn, scan, fno, argl, TRUE); 
	    if(a_errorflag)
		{
			free_tuple(argl);
			free_scan(scan);
			AMOS_ERROR;
			Py_INCREF(Py_None);
			return Py_None;
		}
		else
		{
			  free_tuple(argl);

			  AmosScanType.ob_type = &PyType_Type;
			  py_scan = new_AmosScanObject();
			  py_scan->_scan = scan;

			  //Py_INCREF(py_scan);

			  return (PyObject*)py_scan;
		}
	}
	Py_INCREF(Py_None);
	return Py_None;
    
}


static PyObject * ex_amos_call_1(PyObject *self, PyObject *args)
{
	/* Call an Amos II function from Python
       Result returned as a scan resource.
	   call1(connection, function, a1,....,an ) -> scan
	*/

	a_connection conn;
	dcl_scan(scan);
	dcl_tuple(argl); 
	Py_AmosConnObject* py_conn;
	//Py_AmosScanObject* py_scan;
	Py_AmosOIDObject* py_oid;
	PyObject * funcObj;
	oidtype fno;
	char * str;
	dcl_tuple(row);  /* To hold results from Amos function calls */
	int argsNum;

	//Parse the argments
	argsNum = PyTuple_Size(args);
	if (argsNum<2)
	{
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong number of parameters");
		return NULL;
	}
	else 
	{
		int i;
		PyObject * item;

		py_conn = (Py_AmosConnObject*)PyTuple_GetItem(args,0);
		conn = py_conn->_conn;
		if(!conn)
		{
			printf("[#PyAmos] null connection\n");
			return NULL;
		}

		//str = PyString_AsString(PyTuple_GetItem(args,1));
		funcObj = PyTuple_GetItem(args,1);

		a_setarity(argl,argsNum-2);

		for(i=0;i<argsNum-2;i++)
		{
	
			item = PyTuple_GetItem(args,i+2);

			if(item == Py_None) //if the item is an Py_None
			{
				
			}
			if(PyInt_Check(item)) //if the item is an int
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, TRUE);
			}
			if(item == Py_True) 
					a_setobjectelem(argl, i, a_true, TRUE);
			if(item == Py_False) 
					a_setobjectelem(argl, i, a_false, TRUE);

			if(PyLong_Check(item)) // if item is long
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, TRUE);

			}
			else if(PyFloat_Check(item)) // if item is double (python float is same as double in C)
			{
				double d;
				d = PyFloat_AsDouble(item);
				a_setdoubleelem(argl, i, d, TRUE);

			}
			else if(PyString_Check(item)) // if item is string
			{
				char* str;
				str = PyString_AsString(item);

				if(is_OID_string(str)) 
					a_setobjectelem(argl, i, getoidtype(str, conn), TRUE);
				else a_setstringelem(argl, i, str, FALSE);

			}
			else if(PyTuple_Check(item)) // if item is tuple or an array
			{
				a_tuple vec= pytuple_to_amostuple(item,conn);
				a_setseqelem(argl, i, vec,TRUE);
				free_tuple(vec);
			}

			else if(item->ob_type ==  &AmosOIDType) // if item is OID
			{
				Py_AmosOIDObject*  py_oid = (Py_AmosOIDObject* )item;

				a_setobjectelem(argl, i, py_oid->_oid, TRUE);
			}

			if(a_errorflag)
			{
				free_tuple(argl);
				AMOS_ERROR;
				return NULL;
			}		
		}
	}

	if(PyString_Check(funcObj))
	{
		str = PyString_AsString(funcObj);
		fno = a_getfunction(conn, str, TRUE);
		
		if(a_errorflag)
		{
			AMOS_ERROR;
			printf("[#PyAmos] Amos getfunction error\n");
			return NULL;
		}
	}
	else if(funcObj->ob_type ==  &AmosOIDType)
	{
		py_oid = (Py_AmosOIDObject* )funcObj;
		fno = py_oid->_oid;
	}
	else{
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong Function/functionOID parameters");
		return NULL;
	}
	
	CHECK_AMOS_ERROR;
	{

		a_callfunction(conn, scan, fno, argl, TRUE); 
	    if(a_errorflag)
		{
			free_tuple(argl);
			free_scan(scan);
			AMOS_ERROR;
			return NULL;
		}
		else
		{
			dcl_tuple(row);
			PyObject* pyRow;
			
			if(!a_eos(scan))				
			{
				a_getrow(scan, row, TRUE);
				if(a_errorflag)
				{
					free_tuple(argl);
					free_tuple(row);
					AMOS_ERROR;
					return NULL;
				}				
				pyRow = amostuple_to_pytuple(row);	
				free_tuple(row);
			    free_tuple(argl);
				return PyTuple_GetItem(pyRow,0);
			} 
			else // empty scan
			{
				free_tuple(row);
				free_tuple(argl);
				Py_INCREF(Py_None);
				return Py_None;
			}
		}
	}
	Py_INCREF(Py_None);
	return Py_None;
}

/*
static PyObject * ex_amos_mapCall(PyObject *self, PyObject *args) 
{

	// amos_mapcall(conn,PythonFunction,funcName,a1,a2......)

	a_connection conn;
	dcl_scan(scan);
	dcl_tuple(argl); 
	Py_AmosConnObject* py_conn;
	Py_AmosScanObject* py_scan;
	Py_AmosOIDObject* py_oid;
	PyObject * funcObj;
	oidtype fno;
	char * str;
	dcl_tuple(row);  // To hold results from Amos function calls 
	int argsNum;
	PyObject* my_callback;
	PyObject* callback_arglist;

	//Parse the argments
	argsNum = PyTuple_Size(args);
	if (argsNum<=1)
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong number of parameters\n");
	else 
	{
		int i,tuplesize;
		PyObject * item;

		py_conn = (Py_AmosConnObject*)PyTuple_GetItem(args,0);
		conn = py_conn->_conn;
		if(!conn)
		{
			PyErr_SetString(PyExc_RuntimeError, "[#PyAmos] null connection\n");
			return NULL;
		}

		// To get callback Python function
		my_callback = (PyObject*)PyTuple_GetItem(args,1);
		if (!PyCallable_Check(my_callback)) {
            PyErr_SetString(PyExc_TypeError,"[#PyAmos] First parameter must be callable");
			return NULL;
        }
		Py_XINCREF(my_callback);

		// To get the function address
		funcObj = PyTuple_GetItem(args,2);
		//str = PyString_AsString(PyTuple_GetItem(args,2));

		// To get the argument list for the calling function
		tuplesize = argsNum-3;
		a_setarity(argl,tuplesize);
		for(i=0;i<tuplesize;i++)
		{
	
			item = PyTuple_GetItem(args,i+3);

			if(item == Py_None){//if the item is an Py_None				
			}
			if(PyInt_Check(item)) //if the item is an int
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, FALSE);
			}
			else if(PyBool_Check(item)) // if item is a bool
			{
				if(item == Py_True) 
					a_setobjectelem(argl, i, a_true, FALSE);
				else 
					a_setobjectelem(argl, i, a_false, FALSE);

			}
			else if(PyLong_Check(item)) // if item is long
			{
				int a;
				a = PyInt_AsLong(item);
				a_setintelem(argl, i, a, FALSE);

			}
			else if(PyFloat_Check(item)) // if item is double (python float is same as double in C)
			{
				double d;
				d = PyFloat_AsDouble(item);
				a_setdoubleelem(argl, i, d, FALSE);

			}
			else if(PyString_Check(item)) // if item is string
			{
				char* str;
				str = PyString_AsString(item);

				if(is_OID_string(str)) 
					a_setobjectelem(argl, i, getoidtype(str, conn), FALSE);
				else a_setstringelem(argl, i, str, FALSE);

			}
			else if(PyTuple_Check(item)) // if item is tuple or an array
			{
				a_setseqelem(argl, i, pytuple_to_amostuple(item,conn),FALSE);
			}

			else if(item->ob_type ==  &AmosOIDType) // if item is OID
			{
				Py_AmosOIDObject*  py_oid = (Py_AmosOIDObject* )item;

				a_setobjectelem(argl, i, py_oid->_oid, FALSE);
			}

			if(a_errorflag)
			{
				free_tuple(argl);
				AMOS_ERROR;
				return NULL;
			}		
		}
	}

	//if(is_OID_string(str)) 
	//	fno = getoidtype(str,conn);
	//else 
	//	fno = a_mksymbol(str,FALSE);

	if(PyString_Check(funcObj))
	{
		str = PyString_AsString(funcObj);
		fno = a_mksymbol(str,FALSE);
	}
	else if(funcObj->ob_type ==  &AmosOIDType)
	{
		py_oid = (Py_AmosOIDObject* )funcObj;
		fno = py_oid->_oid;
	}
	else{
		PyErr_SetString(PyExc_TypeError, "[#PyAmos] Wrong Function/functionOID parameters");
		return NULL;
	}
	
	CHECK_AMOS_ERROR;
	{

		a_callfunction(conn, scan, fno, argl, FALSE); 
	    if(a_errorflag)
		{
			free_tuple(argl);
			free_scan(scan);
			AMOS_ERROR;
			return Py_None;
		}
		else
		{
			  dcl_tuple(row);

			  free_tuple(argl);

			  while(!a_eos(scan))
			  {										
					a_getrow(scan,row,FALSE);

					callback_arglist = (PyObject*)amostuple_to_pytuple(row);
					if (!PyTuple_Check(callback_arglist)) {
						PyErr_SetString(PyExc_TypeError,"Second parameter must be Tuple");return NULL;
					}

					//Call the Python callback function
					PyEval_CallObject(my_callback,callback_arglist);

					a_nextrow(scan,FALSE);			 
			  }

			  free_tuple(row);
			  Py_XDECREF(my_callback);

			  AmosScanType.ob_type = &PyType_Type;
			  py_scan = new_AmosScanObject();
			  py_scan->_scan = scan;

			  Py_INCREF(py_scan);
			  return (PyObject*)py_scan;
		}
	}
	Py_INCREF(Py_None);
	return Py_None;

}
*/


static PyObject * ex_amos_disconnect(PyObject *self, PyObject *args)
{

	a_connection conn;
	Py_AmosConnObject* py_conn;
	dcl_scan(scan);

	if (!PyArg_ParseTuple(args, "O", &py_conn)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	if(conn == NULL){
		Py_INCREF(Py_None);
		return Py_None;
		printf("\n");
	}

	a_execute(conn,scan,"commit;",TRUE); /* Flush changes and empty log */

	a_disconnect(conn,TRUE); /* Always disconnect connection when done! */

	free_scan(scan);
	free_connection(conn);

	printf("\nAmos a_disconnect done\n");

	Py_INCREF(Py_None);
	return Py_None;
}

/* 
	Some other usefull Amos APIs in Python 
*/


static PyObject * ex_amos_closeScan(PyObject *self, PyObject *args)
{
	/* 
	   This function might also use as scan.close()
	   The secondary scans s must be closed when no longer used with it 
	*/

	a_scan scan;
	Py_AmosScanObject* py_scan;

	if (!PyArg_ParseTuple(args, "O", &py_scan)) {
	   printf("error: wrong args in funcition ex_amos_getrow \n");
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_scan->ob_type !=  &AmosScanType)
	{
		printf("[#PyAmos] First parameter should be a AmosScanType\n");
		PyErr_BadArgument();
		return NULL;
	}

	scan = py_scan->_scan;

	if(scan == NULL){

		Py_INCREF(Py_None);
		return Py_None;
		printf("\n");
	}

	a_closescan(scan,TRUE);

	if(a_errorflag)
	{
		free_scan(scan);
		AMOS_ERROR;
		return NULL;

	}

	Py_INCREF(Py_None);
	return Py_None;
}


static PyObject * ex_amos_createobject(PyObject *self, PyObject *args)
{
	// this function 
    // New Amos II objects are created with createobject
	
	char *typeName;
	oidtype type_oid;
	oidtype object_oid;
	a_connection conn;
	//char * OID_str;
	//PyObject* ret;
	Py_AmosConnObject* py_conn;
	Py_AmosOIDObject* py_oid;

	if (!PyArg_ParseTuple(args, "Os", &py_conn,&typeName)) {
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	if(is_OID_string(typeName)) 
		type_oid = getoidtype(typeName,conn);
	else 
		type_oid = a_mksymbol(typeName,TRUE);
	
	CHECK_AMOS_ERROR;

	object_oid = a_createobject(conn, type_oid, TRUE);
        if(object_oid == nil) return Py_None;
	CHECK_AMOS_ERROR;
	//OID_str = make_OID_string(object_oid);
	//ret = Py_BuildValue("s", OID_str);
	//Py_INCREF(ret);
	//return  ret;

	AmosOIDType.ob_type = &PyType_Type;
	py_oid = new_AmosOIDObject();
	py_oid->_oid = object_oid;
	a_let(py_oid->_oid,object_oid);

	return (PyObject*)py_oid;
}

static PyObject * ex_amos_deleteobject(PyObject *self, PyObject *args)
{
	// this function 
	// To delete an object o use deleteobject
	
	oidtype object_oid;
	a_connection conn;
	//char * OID_str;
	Py_AmosConnObject* py_conn;
	Py_AmosOIDObject* py_oid;

	if (!PyArg_ParseTuple(args, "OO", &py_conn,&py_oid)) {
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	if(py_oid->ob_type !=  &AmosOIDType)
	{
		printf("[#PyAmos] First parameter should be a AmosOIDType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	object_oid = py_oid->_oid;

	//if(is_OID_string(OID_str)) 
	//	object_oid = getoidtype(OID_str,conn);
	//else 
	//	object_oid = a_mksymbol(OID_str,TRUE);
	
	CHECK_AMOS_ERROR;

	a_deleteobject(conn, object_oid, TRUE);
	CHECK_AMOS_ERROR;

	Py_INCREF(Py_None);
	return Py_None;
}


//Transaction Control
static PyObject * ex_amos_commit(PyObject *self, PyObject *args)
{
	// this function 

	a_connection conn;
	Py_AmosConnObject* py_conn;

	if (!PyArg_ParseTuple(args, "O", &py_conn)) {
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	a_commit(conn,TRUE);
	CHECK_AMOS_ERROR;

	Py_INCREF(Py_None);
	return Py_None;
}

static PyObject * ex_amos_rollback(PyObject *self, PyObject *args)
{
	// this function 
	a_connection conn;
	Py_AmosConnObject* py_conn;

	if (!PyArg_ParseTuple(args, "O", &py_conn)) {
	   PyErr_BadArgument();
       return NULL;
    };

	if(py_conn->ob_type !=  &AmosConnType)
	{
		printf("[#PyAmos] First parameter should be a AmosConnType\n");
		PyErr_BadArgument();
		return NULL;
	}

	conn = py_conn->_conn;

	a_rollback(conn,TRUE);
	CHECK_AMOS_ERROR;

	Py_INCREF(Py_None);
	return Py_None;

}

//#######################################################################################################

/////////////////////////////////////////////////////////////////////////
//// Use string to represent the OID
//// Might be change
//// Alternative is to use python object or class concept
/////////////////////////////////////////////////////////////////////////
char* make_OID_string(oidtype oid) 
{
	/* Makes stringified OIDs given a handle to a surrogate object */

	char *retOIDstr;
	char buffer[30];
	int id = a_getid(oid, TRUE);
	
	CHECK_AMOS_ERROR;
	sprintf(buffer, "#[OID %d]", id);
	retOIDstr = (char *)malloc(strlen(buffer)+1);
    strcpy(retOIDstr,buffer);
	return retOIDstr;
}

int is_OID_string(char *str)
{
	/* Returns length of OID number if str is an object identifier */

	if(strlen(str)<=7 || strncmp(str,"#[OID ",6)) return 0;
	return strspn(str+6,"0123456789");
}

oidtype getoidtype(char *s, a_connection conn) 
{
    /* Gets Amos II handle to stringified OID */

	int oid, idlen;
	char num[100];
	oidtype res=nil;
     
	idlen=is_OID_string(s);
	if(!idlen) printf("Not a legal OID: '%s'",s);
	strncpy(num,s+6,idlen);
	num[idlen]='\0';
	oid = atoi(num);
	res = a_getobjectno(conn, oid, TRUE);
	CHECK_AMOS_ERROR;
	return res;
}

/////////////////////////////////////////////////////////////////////////
// This function is used to convert amos_tuple(a_tuple) to python Typle
PyObject* amostuple_to_pytuple(a_tuple tpl)
{
	int size, i;
	PyObject* pyTuple;
	
	size=a_getarity(tpl, TRUE);
	pyTuple = PyTuple_New(size);
	
	//printf("###In amostuple_to_pytuple###\n");

	for(i=0; i<size; i++)
	{
		int type = a_getelemtype(tpl,i,TRUE);

		CHECK_AMOS_ERROR;

		switch(type)
		{

			case INTEGERTYPE:
			{
				int integer;
				PyObject* pyInt;
				
				integer = a_getintelem(tpl,i,TRUE);
				CHECK_AMOS_ERROR;

				//add integertype to the i-th position of the tuple
				pyInt = Py_BuildValue("i", integer);
				Py_INCREF(pyInt);
				PyTuple_SetItem(pyTuple, i, pyInt);

				break;
			}

			case REALTYPE:
			{
				double r;
				PyObject* pyReal;
				
				r = a_getdoubleelem(tpl,i,TRUE);

				CHECK_AMOS_ERROR;

				//add realtype to the i-th position of the tuple
				pyReal = Py_BuildValue("d", r);
				Py_INCREF(pyReal);
				PyTuple_SetItem(pyTuple, i, pyReal);
				
				break;
			}

			case STRINGTYPE:
			{
				char str[10000];
				PyObject* pyStr;
				
				a_getstringelem(tpl, i, str, sizeof(str), TRUE);

				CHECK_AMOS_ERROR;

				//add stringtype to the i-th position of the tuple
				pyStr = Py_BuildValue("s", str);
				Py_INCREF(pyStr);
				PyTuple_SetItem(pyTuple, i,pyStr);
				

				break;
			}

			case ARRAYTYPE:
			{
				dcl_tuple(a);
				
				a_getseqelem(tpl, i, a, TRUE);
				if(a_errorflag)
				{
					free_tuple(a);
					AMOS_ERROR;
				}
				else
				{
					
					PyObject* bufTuple;

					//get the arraytype into tuple and put it into a parent tuple
					bufTuple = amostuple_to_pytuple(a);
					Py_INCREF(bufTuple);
					PyTuple_SetItem(pyTuple, i, bufTuple);

					free_tuple(a);
				}
				break;
			}

			case SYMBOLTYPE:
			{
				oidtype symb = a_getobjectelem(tpl, i, TRUE);
				
				CHECK_AMOS_ERROR;

				if(symb == a_true)
				{
					Py_INCREF(Py_True);
					PyTuple_SetItem(pyTuple, i, Py_True);
				}
				else if(symb == a_false) 
				{
					Py_INCREF(Py_False);
					PyTuple_SetItem(pyTuple, i, Py_False);
				}
				else 
				{
					Py_INCREF(Py_None);
					PyTuple_SetItem(pyTuple, i, Py_None);
				}
				break;
			}

			case SURROGATETYPE:
			{
				//char *str;
				//PyObject* pyOIDstr;
				Py_AmosOIDObject* py_oid;

				oidtype obj = a_getobjectelem(tpl, i, TRUE);
				
				CHECK_AMOS_ERROR;

				//str = make_OID_string(obj);
				//pyOIDstr = Py_BuildValue("s", str);
				//Py_INCREF(pyOIDstr);

				AmosOIDType.ob_type = &PyType_Type;
				py_oid = new_AmosOIDObject();
				py_oid->_oid = obj;

				PyTuple_SetItem(pyTuple, i, (PyObject*)py_oid);

				break;
			}

			default: 
				{printf("Illegal Amos II type in tuple %d", type);break;}
		
		}

	}	
		
    return pyTuple;
}

//////////////////////////////////////////////////////////////////////////
// This function is used to convert python Typle to Amos II tuple(a_tuple) 
a_tuple pytuple_to_amostuple(PyObject *pyTuple,a_connection conn)
{
    /* Convert indexed python tuple to Amos II tuple. */

	Py_ssize_t size;
	
	size = PyTuple_Size(pyTuple);
	if(size == 0) {
		printf("No elements in the Python Tuple");
		return NULL;
	}
	{
		int i;
		dcl_tuple(tpl);
		a_setarity(tpl,size);

		for(i= 0; i<size; i++)
		{
			PyObject * item;			
			item= PyTuple_GetItem(pyTuple,i);
			if(item == Py_None) //if the item is an Py_None
			{
				
			}
			if(PyInt_Check(item)) //if the item is an int
			{
				int a;
				
				a = PyInt_AsLong(item);
				a_setintelem(tpl, i, a, TRUE);
			}

			if(item == Py_True) 
					a_setobjectelem(tpl, i, a_true, TRUE);
			if(item == Py_False) 
					a_setobjectelem(tpl, i, a_false, TRUE);

			if(PyLong_Check(item)) // if item is long
			{
				int a;
				
				a = PyInt_AsLong(item);
				a_setintelem(tpl, i, a, TRUE);

			}
			else if(PyFloat_Check(item)) // if item is double (python float is same as double in C)
			{
				double d;
				
				d = PyFloat_AsDouble(item);
				a_setdoubleelem(tpl, i, d, TRUE);

			}
			else if(PyString_Check(item)) // if item is string
			{
				char* str;

				str = PyString_AsString(item);

				//if(is_OID_string(str)) 
				//	a_setobjectelem(tpl, i, getoidtype(str, conn), TRUE);
				//else a_setstringelem(tpl, i, str, TRUE);
				a_setstringelem(tpl, i, str, TRUE);
				CHECK_AMOS_ERROR;

			}
			else if(PyTuple_Check(item)) // if item is tuple or an array
			{
				a_tuple vec= pytuple_to_amostuple(item,conn);
				a_setseqelem(tpl, i, vec,TRUE);
				free_tuple(vec);
			}

			if(a_errorflag)
			{
				free_tuple(tpl);
				AMOS_ERROR;
				return NULL;
			}

			else if(item->ob_type ==  &AmosOIDType) // if item is OID
			{
				Py_AmosOIDObject*  py_oid = (Py_AmosOIDObject* )item;

				a_setobjectelem(tpl, i, py_oid->_oid, TRUE);
			}

		}
		return tpl;
	}

	return NULL;

}

