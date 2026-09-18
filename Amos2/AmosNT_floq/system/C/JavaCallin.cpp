/***************************************************************************** 
 * AMOS2
 *
 * Author: (c) 2001-2006 Daniel Elin, EDSLAB, Tore Risch, UDBL
 * $RCSfile: JavaCallin.cpp,v $
 * $Revision: 1.71 $ $Date: 2014/01/05 15:29:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface when calling Amos II from Java
 *
 * ===========================================================================
 * $Log: JavaCallin.cpp,v $
 * Revision 1.71  2014/01/05 15:29:37  torer
 * support for pure client initialization
 *
 * Revision 1.70  2014/01/04 10:53:10  torer
 * OS-independent localization of the startup directory
 *
 * Revision 1.69  2013/03/04 22:12:05  torer
 * Require AMOS_HOME to be set under Linux
 *
 * Revision 1.68  2013/03/04 20:39:59  torer
 * Automatically finding startupDir under OSX
 *
 * Revision 1.67  2013/03/04 11:09:28  torer
 * maco missing
 *
 * Revision 1.66  2012/12/02 22:01:54  andan342
 * Fixed memory leaks when accessing BINARY objects via BLOB functions
 *
 * Revision 1.65  2012/10/29 22:19:12  andan342
 * Added BINARY object support into Java callin interface
 *
 * Revision 1.64  2012/06/19 16:12:54  larme597
 * executeCustom & callFunctionCustom.
 *
 * Revision 1.63  2012/06/14 08:51:52  torer
 * Revert to old lock method
 *
 * Revision 1.60  2012/03/13 16:14:20  torer
 * New release 15:
 *
 * 1. Major change:
 *   The external interfaces in C and Java now always uses Lars' coroutine
 *   scans rather than the old materialized scans
 *
 * 2. Secondary scans removed
 *
 * Revision 1.59  2011/05/12 12:53:55  torer
 * Could not set null in Java tuple
 *
 * Revision 1.57  2011/04/18 18:29:51  torer
 * setElem on byte arrays
 *
 * Revision 1.56  2011/04/06 19:44:14  torer
 * OIDTYPE -> SURROGATETYPE
 *
 * Revision 1.55  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.54  2010/12/29 20:48:30  torer
 * Compiler warning removed
 *
 * Revision 1.53  2010/12/29 20:33:23  torer
 * Removed dead code
 *
 * Revision 1.52  2010/09/30 19:58:06  torer
 * Unlimited string length in Java interface
 *
 * Revision 1.51  2010/09/11 03:07:43  torer
 * Byte buffer interface for JDBC strings
 *
 * Revision 1.50  2010/09/09 14:29:59  torer
 * Added Tuple.addStringElem method in Java
 *
 * Revision 1.49  2010/09/08 17:11:18  torer
 * Extra calls to gbc
 *
 * Revision 1.48  2009/02/12 07:48:20  torer
 * *** empty log message ***
 *
 * Revision 1.47  2009/01/06 14:54:45  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.46  2009/01/02 08:36:34  torer
 * Concurrency bugs
 *
 * Revision 1.45  2008/12/14 16:43:16  torer
 * Added interface to a_callback_connection
 *
 * Revision 1.44  2008/12/06 20:12:32  torer
 * Better threading scalability
 *
 * Revision 1.43  2008/12/06 19:29:22  torer
 * Interface now stress tested for 100000 concurrent threads!
 *
 * Revision 1.42  2008/12/06 12:37:17  torer
 * Correct stringification of vectors
 *
 * Revision 1.41  2008/12/05 18:34:14  torer
 * plus(object,object)->Charstring implements concat
 *
 * Revision 1.39  2008/11/25 16:22:24  torer
 * Delay connect
 *
 * Revision 1.37  2008/07/08 17:38:30  torer
 * Linux version
 *
 * Revision 1.34  2007/10/10 06:56:09  torer
 * The default .dmp file is now picked from the same folder as where the
 * used system DLL is located so that javaamos.bat works exactly as amos2.exe
 *
 * Revision 1.33  2007/10/08 20:14:00  torer
 * javaamos.bat now takes command line parameters same as amos2.exe
 * e.g. javaamos -o "print('Welcome to Amos II!');"
 *
 * Revision 1.32  2007/08/21 14:34:51  zeitler
 * Took out #ifdef ... #define from JavaCallin.cpp
 *
 * Revision 1.31  2007/07/27 17:13:21  torer
 * DLL initialization without modifying system source code
 *
 * Revision 1.30  2007/07/24 06:12:33  petrini
 * Load SparQL parser code into SWARD.dll.
 *
 * Revision 1.29  2007/05/10 17:17:21  torer
 * Wrapped initializeAmos to load the DLL JavaAmos.dll
 *
 * Revision 1.28  2007/05/09 05:46:19  torer
 * Restored original initializeAmos
 *
 * Revision 1.27  2007/04/26 10:53:25  zeitler
 * Optional #ifdef SCSQ code in JavaCallin
 *
 * Revision 1.26  2007/04/05 07:14:13  torer
 * JavaAmos now based on VC++ (not Borland)
 *
 * Revision 1.25  2006/10/23 18:44:58  torer
 * getBooleanElem instead of getbooleanElem
 * Tuple.isBoolean and Tuple.isNull defined
 *
 * Revision 1.24  2006/09/07 12:09:42  petrini
 * Bumped up size of str to 2048.
 *
 * Revision 1.23  2006/02/19 10:42:47  torer
 * Bug in record_putfn
 *
 * Revision 1.22  2006/02/17 10:58:05  torer
 * Setting typeTag of Java proxy objects
 *
 * Revision 1.21  2006/02/15 13:16:13  torer
 * Tuple.getElem(int) can handle opaque Amos II types as Java type Oid
 *
 ****************************************************************************/

#include "environ.h"
#include "JavaAmos.h"
#include "callout.h"
#include "callin_Connection.h"
#include "callin_Scan.h"
#include "callin_Tuple.h"
#include "callin_Oid.h"
#if defined(NT)
#include <windows.h>
#elif defined(__APPLE__)
#include <dlfcn.h>
#endif

#define Trace(x) //printf("%s\n",x); fflush(stdout)

int null_pointer_received, not_boolean; // error codes

a_connection local_connection; // Connection to local database

//
// ===== Private functions ===================================================
//


/*
 * Construct a Java proxy for an Amos II object
 */

jobject NewJavaOid(JNIEnv *env, oidtype o)
{
  jclass OidCls;
  jmethodID Constr;
  jobject jobj;
  oidtype newobj=nil;

  check(OidCls = env->FindClass("callin/Oid"),
	"NewJavaOid: Couldn't find class callin.Oid");
  check(Constr = env->GetMethodID(OidCls, "<init>", "(I)V"),
	"NewJavaOid: Couldn't find Oid proxy constructor");
  if(o==nil) return NULL;
  Trace("NewJavaOid");  a_assign(newobj,o);
  // Java gbc will decrease the reference counter of o
  check(jobj = env->NewObject(OidCls, Constr, o),
	"NewJavaOid: Couldn't construct the Oid object");
  return jobj;
}

/*
 * Generate Java error from Amos II error
 */
jobject ThrowAmosError(JNIEnv *env)
{
  // There was an error, throw AmosException
  jclass excCls;
  jmethodID excConstr;
  jstring msg;
  jobject newexc, jform;
  jint ErrorNumber;

  /* Construct Java error message */

  check(msg=env->NewStringUTF(a_errstr),
	"ThrowAmosError: Couldn't construct error message");

  /* Construct AmosException in Java */

  check(excCls = env->FindClass("callin/AmosException"),
	"ThrowAmosError: Couldn't find class callin.AmosException");
  jform = NewJavaOid(env, a_errform);
  check(excConstr = env->GetMethodID(excCls, "<init>", "(ILcallin/Oid;Ljava/lang/String;)V"),
	"ThrowAmosError: Couldn't find the AmosException constructor");

  ErrorNumber = a_errno;
  check(newexc = env->NewObject(excCls, excConstr, ErrorNumber, jform, msg),
	"ThrowAmosError: Couldn't construct the AmosException object");
  env->Throw((jthrowable)newexc);
  a_errorflag=FALSE;
  return ((jobject)NULL);
}

/*
 * Raise new AmosException in Java
 */
int JavaAmosError(JNIEnv *env, int err, oidtype form)
{
  a_error(err,form,TRUE); 
  ThrowAmosError(env);
  return TRUE;
}

/*
 * Initialize a preallocated connection object
 */
jobject initializeConnectionObject(JNIEnv *env, jobject obj, char *name)
{
  a_connection theConnection;
  jfieldID fid;
  jclass cls;


  if(CheckNullPointer(env,obj)) return NULL;
    
  Trace("initializeConnectionObject");
  if(strcmp(name,"**callback**")==0) theConnection = a_callback_connection;
  else
    {
      theConnection = a_init_connection();
      a_connect(theConnection, name, TRUE);
      if(a_errorflag)
	{
	  free_connection(theConnection);
      
	  return ThrowAmosError(env);
	}
    }
  // Store the opened theConnection in the Java object
  cls = env->GetObjectClass(obj);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return ThrowAmosError(env);
    }

  check(fid = env->GetFieldID(cls, "connectionPointer", "I"),
	"makeConnectionObject: Couldn't get fieldID for connectionPointer");
  env->SetIntField(obj, fid, (int)theConnection);
  return  obj;
}

/*
 * Access the a_connection of a Java Connection object
 */
a_connection getConnection(JNIEnv *env, jobject obj)
{
  jfieldID fid;
  jclass cls;
  jint theConnection;

  Trace("getConnection");
  if(obj == NULL) return local_connection;

  // Get theConnection from the Java object
  cls = env->GetObjectClass(obj);		// No error checking
  check(fid = env->GetFieldID(cls, "connectionPointer", "I"),
        "getConnection: Couldn't get fieldID for connectionPointer");
  theConnection = env->GetIntField(obj, fid);
  return ((a_connection)theConnection);
}

/*
 * Get the connection of a Java object
 */
jobject getConnectionObject(JNIEnv *env, jobject obj)
{
  jfieldID fid;
  jclass cls;
  jobject theConnection;

  Trace("getConnectionObject");
  if(CheckNullPointer(env,obj)) return NULL; // error
  cls = env->GetObjectClass(obj);		// No error checking
  check(fid = env->GetFieldID(cls, "theConnection", "Lcallin/Connection;"),
        "getConnectionObject: Couldn't get fieldID for theConnection");
  theConnection = env->GetObjectField(obj, fid);
  return theConnection;
}

/*
 * Construct a Java Scan object from a_scan
 */
jobject makeScanObject(JNIEnv *env, jobject conn, a_scan theScan)
{
  jclass cls;
  static jmethodID mid=NULL;
  jobject scanObj;

  Trace("makeScanObject");
  if(CheckNullPointer(env,conn)) return NULL; // error
  check(cls = env->FindClass("callin/Scan"),
	"makeScanObject: Couldn't find class callin.Scan");
  if(mid==NULL)
    check(mid = env->GetMethodID(cls, "<init>", "(ILcallin/Connection;)V"),
	"makeScanObject: Couldn't find (ILcallin/Connection;)V constructor in callin.Scan");
  check(scanObj = env->NewObject(cls, mid, theScan, conn),
	"makeScanObject: Couldn't construct the Scan object");
  return scanObj;
}

/*
 * Access a_scan of a Java Scan object
 */
a_scan getScan(JNIEnv *env, jobject obj)
{
  jfieldID fid;
  jclass cls;
  jint theScan;

  Trace("getScan");
  if(CheckNullPointer(env,obj)) return NULL; // error
  cls = env->GetObjectClass(obj);		// No error-checking
  check(fid = env->GetFieldID(cls, "scanPointer", "I"),
        "getScan: Couldn't get fieldID for scanPointer");
  theScan = env->GetIntField(obj, fid);
  return ((a_scan)theScan);
}

/*
 * Construct a Java Tuple object from an a_tuple
 */
jobject makeTupleObject(JNIEnv *env, jobject conn, a_tuple theTuple)
{
  jclass cls=NULL;
  jmethodID mid=NULL;
  jobject tplObj;

  Trace("makeTupleObject");
  check(cls=env->FindClass("callin/Tuple"),
	"makeTupleObject: Couldn't find class callin.Tuple");
  check(mid=env->GetMethodID(cls, "<init>", "(ILcallin/Connection;)V"),
	"makeTupleObject: Couldn't find (ILcallin/Connection;)V constructor in callin.Oid");
  check(tplObj = env->NewObject(cls, mid, theTuple, conn),
	"makeTupleObject: Couldn't construct the Tuple object");
  return tplObj;
}

/*
 * Access the Amos a_tuple of a Java Tuple object
 */
a_tuple getTuple(JNIEnv *env, jobject obj)
{
  jfieldID fid=NULL;
  jclass cls=NULL;
  jint theTuple;

  Trace("getTuple");
  if(CheckNullPointer(env,obj)) return NULL;  // error
  cls= env->GetObjectClass(obj);		// No error-checking.
  check(fid=env->GetFieldID(cls, "tuplePointer", "I"),
        "getTuple: Couldn't get fieldID for tuplePointer");
  theTuple = env->GetIntField(obj, fid);
  return ((a_tuple)theTuple);
}

/*
 * Construct a Java Oid object from oidtype
 */
jobject makeOidObject(JNIEnv *env, jobject conn, oidtype o)
{
  static jclass cls=NULL;
  static jmethodID mid=NULL;
  jobject oidObj;

  Trace("makeOidObject");

  check(cls=env->FindClass("callin/Oid"),
	"Couldn't find class callin.Oid");
  if(mid==NULL)
   check(mid=env->GetMethodID(cls, "<init>", "(IILcallin/Connection;)V"),
	"Couldn't find (ILcallin/Connection;)V constructor in callin.Oid");
  check(oidObj = env->NewObject(cls, mid, o, a_datatype(o), conn),
	"makeOidObject: Couldn't construct the Oid object");
  return (oidObj);
}

/*
 * Access oidtype of a Java Oid object
 */
oidtype getOidObject(JNIEnv *env, jobject oid)
{
  jclass cls;
  oidtype tmpOid;
  jint tmp;
  static jfieldID fid=NULL;

  Trace("getOidObject");
  if(oid==NULL) return nil;
  cls = env->GetObjectClass(oid);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return nil;
    }
  if(fid==NULL)
      check(fid = env->GetFieldID(cls, "oidtypeHandle", "I"),
	 "getOidObject: Couldn't get fieldID for oidtypeHandle");
  tmp = env->GetIntField(oid, fid);
  tmpOid = tmp;

  return tmpOid;
}

/*
 * Create Java boolean object
 */

jobject makeBoolean(JNIEnv *env, jboolean x)
{
  jobject tmpObj;
  jclass cls;
  static jmethodID mid=NULL;

  check(cls=env->FindClass("java/lang/Boolean"),
	"makeBoolean: Couldn't find class java.lang.Boolean");
  if(mid==NULL)
    check(mid=env->GetMethodID(cls, "<init>", "(Z)V"),
	"makeBoolean: Couldn't find (Z)V constructor in java.lang.Boolean");
  check(tmpObj = env->NewObject(cls, mid, x),
	"makeBoolean: Couldn't construct the java.lang.Boolean object");
  return (tmpObj);
}

//
// ===== Native Java Tuple functions ===========================================
//

// ---------- Arity ----------
/*
 * Class:     callin_Tuple
 * Method:    getArity
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_callin_Tuple_getArity
(JNIEnv *env, jobject obj)
{
  int arity;
  a_tuple theTuple;

  theTuple = getTuple(env, obj);

  if(theTuple==NULL) return 0; // error

  arity = a_getarity(theTuple, TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return 0;
    }
  return arity;
}

/*
 * Class:     callin_Tuple
 * Method:    setArity
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setArity
(JNIEnv *env, jobject obj, jint arity)
{
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;

  Trace("setArity"); a_setarity(theTuple, arity); 
}

// ---------- Retrieving elements of a tuple ----------

/*
 * Class:     callin_Tuple
 * Method:    getStringElem
 * Signature: (I)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_callin_Tuple_getStringElem
(JNIEnv *env, jobject obj, jint index)
{
  char str[4]; // Dummy for testing that type of object is string
  jstring theString;
  a_tuple theTuple = getTuple(env, obj);
  oidtype e;

  if(theTuple==NULL) return NULL;

  a_getstringelem(theTuple, index, str, sizeof(str), TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env); 
      return NULL;
    }
  // Convert to a Java string
  e = a_getobjectelem(theTuple, index, TRUE);
  check(theString = env->NewStringUTF(getstring(e)),
	"Tuple.getStringElem: Couldn't construct string");
  return (theString);
}

/*
 * Class:     callin_Tuple
 * Method:    getIntElem
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_callin_Tuple_getIntElem
(JNIEnv *env, jobject obj, jint index)
{
  int res;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return 0;

  res = a_getintelem(theTuple, index, TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return 0;
    }
  return res;
}

/*
 * Class:     callin_Tuple
 * Method:    getDoubleElem
 * Signature: (I)D
 */
JNIEXPORT jdouble JNICALL Java_callin_Tuple_getDoubleElem
(JNIEnv *env, jobject obj, jint index)
{
  double res;
  a_tuple theTuple =  getTuple(env, obj);

  if(theTuple==NULL) return 0.0;

  res = a_getdoubleelem(theTuple, index, TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return 0.0;
    }
  return res;
}

/*
 * Class:     callin_Tuple
 * Method:    getBinaryElem
 * Signature: (I)[B
 */
JNIEXPORT jbyteArray JNICALL Java_callin_Tuple_getBinaryElem //AA
(JNIEnv *env, jobject obj, jint pos)
{
	int sz;
	a_tuple theTuple =  getTuple(env, obj);
	if(theTuple==NULL) return env->NewByteArray(0);
	
	a_blob theBLOB = a_initBLOB();
	char* blobContents;
	jbyteArray res;

	a_getBLOBelem(theTuple, pos, theBLOB, TRUE);
	if (!a_errorflag) a_getBLOBsize(theBLOB, &sz, TRUE);
	if (!a_errorflag) a_getBLOBarea(theBLOB, 0, sz, &blobContents, TRUE);
	if (!a_errorflag) 
	{
		res = env->NewByteArray(sz); 
		env->SetByteArrayRegion(res, 0, sz, (jbyte*)blobContents);
	}
	a_freeBLOB(theBLOB, FALSE);
//	printf("BLOB freed in getBinaryElem!\n"); //DEBUG
	if(a_errorflag)
    {
      ThrowAmosError(env);
      return env->NewByteArray(0);
    }
	return res;
}


/*
 * Class:     callin_Tuple
 * Method:    getbooleanElem
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_getBooleanElem
(JNIEnv *env, jobject obj, jint index)
{
  oidtype res;
  a_tuple theTuple =  getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;

  res = a_getobjectelem(theTuple, index, TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  if(res==truesymbol) return JNI_TRUE;
  if(res==nil || res == falsesymbol) return JNI_FALSE;
  a_error(not_boolean,res,TRUE);
  ThrowAmosError(env);
  return JNI_FALSE;  
}
/*
 * Class:     callin_Tuple
 * Method:    getOidElem
 * Signature: (I)Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Tuple_getOidElem
(JNIEnv *env, jobject obj, jint index)
{
  oidtype theObject=nil;
  a_tuple theTuple = getTuple(env,obj);

  if(theTuple==NULL) return NULL;

  a_assign(theObject,a_getobjectelem(theTuple, index, TRUE));
  if(a_errorflag) return ThrowAmosError(env);
  return makeOidObject(env,getConnectionObject(env, obj),theObject);
}

/*
 * Class:     callin_Tuple
 * Method:    getSeqElem
 * Signature: (I)Lcallin/Tuple;
 */
JNIEXPORT jobject JNICALL Java_callin_Tuple_getSeqElem
(JNIEnv *env, jobject obj, jint index)
{
  a_tuple newTuple;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL)
    return NULL;
  Trace("getSeqElem");
  newTuple = a_init_tuple();
  a_getseqelem(theTuple, index, newTuple, TRUE);
  if(a_errorflag) {return ThrowAmosError(env);}
  return makeTupleObject(env, getConnectionObject(env, obj), newTuple);
}

/*
 * Class:     callin_Tuple
 * Method:    getElem
 * Signature: (I)Ljava/lang/Object;
 */
JNIEXPORT jobject JNICALL Java_callin_Tuple_getElem
(JNIEnv *env, jobject obj, jint index)
{
  a_tuple tpl;
  int etype;

  tpl = getTuple(env,obj);
  if(tpl==NULL) return NULL;
  etype = a_getelemtype(tpl, index, TRUE);
  if(a_errorflag) return ThrowAmosError(env);
  switch(etype)
    {
    case INTEGERTYPE:
      // Integer
      // Get (index + 1)'th arg in tuple as an integer
      {
        int tmpInt;
        static jclass cls=NULL;
        static jmethodID mid=NULL;
        jobject tmpObj;

        tmpInt = a_getintelem(tpl, index, TRUE);
        if(a_errorflag) return ThrowAmosError(env);

        // Construct a java.lang.Integer object
        check(cls=env->FindClass("java/lang/Integer"),
              "Tuple.getElem: Couldn't find class java.lang.Integer");
        if(mid==NULL)
             check(mid=env->GetMethodID(cls, "<init>", "(I)V"),
              "Tuple.getElem: Couldn't find (I)V constructor in java.lang.Integer");
        check(tmpObj = env->NewObject(cls, mid, tmpInt),
              "Tuple.getElem: Couldn't construct the java.lang.Integer object");
        return (tmpObj);
      }
    case REALTYPE:
      {
        double tmpDouble = a_getdoubleelem(tpl, index, TRUE);
        static jclass cls=NULL;
        static jmethodID mid=NULL;
        jobject tmpObj;

        if(a_errorflag) return ThrowAmosError(env);

        // Construct a java.lang.Double object
        check(cls=env->FindClass("java/lang/Double"),
              "Tuple.getElem: Couldn't find class java.lang.Double");
        if(mid==NULL)
           check(mid=env->GetMethodID(cls, "<init>", "(D)V"),
              "Tuple.getElem: Couldn't find (D)V constructor in java.lang.Double");
        check(tmpObj = env->NewObject(cls, mid, tmpDouble),
              "Tuple.getElem: Couldn't construct the java.lang.Double object");
        return (tmpObj);
      }
    case STRINGTYPE:
      {
        char tmpStr[4]; // Just for type string test
        jobject tmpObj;
        oidtype e;

        a_getstringelem(tpl, index, tmpStr, sizeof(tmpStr), TRUE);
        if(a_errorflag) return ThrowAmosError(env);

        // Convert to a Java string
        e = a_getobjectelem(tpl, index, TRUE);
        check(tmpObj= env->NewStringUTF(getstring(e)),
	      "Tuple.getElem: Couldn't construct string");
        return (tmpObj);
      }
    case ARRAYTYPE:
      {
        dcl_tuple(tmpTuple);
        a_tuple theTuple = getTuple(env, obj);

        if(theTuple==NULL) return NULL;

        a_getseqelem(theTuple, index, tmpTuple, TRUE);
        if(a_errorflag) return ThrowAmosError(env);

        return makeTupleObject(env, getConnectionObject(env, obj), tmpTuple);
      }
    case SURROGATETYPE:
    default:
      {
        oidtype elem = a_getelem(tpl,index,TRUE);

        if(elem==nil) return NULL;
        if(elem==starsymbol) return NULL;
        if(elem==truesymbol) return makeBoolean(env,JNI_TRUE);
        if(elem==falsesymbol) return makeBoolean(env,JNI_FALSE);
	{
	  dcloid(tmpObject);

	  a_assign(tmpObject, elem);
	  if(a_errorflag) return ThrowAmosError(env);
	  return makeOidObject(env, getConnectionObject(env, obj), tmpObject);
	}
      }
    }
}

// ---------- Setting elements of a tuple ----------
/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (ILjava/lang/String;)V
 */

EXTERN void gbc(int);

JNIEXPORT void JNICALL Java_callin_Tuple_setElem__ILjava_lang_String_2
(JNIEnv *env, jobject obj, jint index, jstring str)
{
  char *theString;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;

  // Get the string
  check(theString = (char *)env->GetStringUTFChars(str, NULL),
	"Tuple.setElem(String): Failed to get string argument");

  // Set the string element
  Trace("setstringelem");
  gbc(FALSE);
  a_setstringelem(theTuple, index, theString, TRUE); 
  env->ReleaseStringUTFChars(str, theString);
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (I[BI)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__I_3BI
  (JNIEnv *env, jobject obj, jint index, jbyteArray arr, jint sz)
{
  char *theString; 

  a_tuple theTuple = getTuple(env, obj);
  if(theTuple==NULL) return;

  theString = (char *)env->GetByteArrayElements(arr, FALSE);
                                                  //get the byte array
  Trace("setbyteselem");
  a_setbyteselem(theTuple, index, sz, theString, TRUE);
  env->ReleaseByteArrayElements(arr, (signed char *)theString, JNI_ABORT); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setBinaryElem
 * Signature: (I[BI)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setBinaryElem //AA
  (JNIEnv *env, jobject obj, jint index, jbyteArray arr, jint sz)
{
	char *theBytes;
	a_tuple theTuple = getTuple(env,obj);
	if(theTuple==NULL) return;
	
	theBytes = (char *)env->GetByteArrayElements(arr, FALSE);

	Trace("putBLOBelem");
	a_blob theBLOB = a_initBLOB();
	a_newBLOB(theBLOB, sz, FALSE);
	a_putBLOBbytes(theBLOB, 0, sz, theBytes, FALSE);
	a_putBLOBelem(theTuple, index, theBLOB, FALSE);
	a_freeBLOB(theBLOB, FALSE);

	env->ReleaseByteArrayElements(arr, (signed char *)theBytes, JNI_ABORT); 
	if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    addElem
 * Signature: (I[BI)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_addElem__I_3BI
  (JNIEnv *env, jobject obj, jint index, jbyteArray arr, jint sz)
{
  char *theString; 

  a_tuple theTuple = getTuple(env, obj);
  if(theTuple==NULL) return;

  theString = (char *)env->GetByteArrayElements(arr, FALSE);
                                                  //get the byte array
  Trace("addbyteselem");
  a_addbyteselem(theTuple, index, sz, theString, TRUE);
  env->ReleaseByteArrayElements(arr, (signed char *)theString, JNI_ABORT); 
  if(a_errorflag) ThrowAmosError(env);
}


JNIEXPORT void JNICALL Java_callin_Tuple_addElem__ILjava_lang_String_2
(JNIEnv *env, jobject obj, jint index, jstring str)
{
  char *theString;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;

  // Get the string
  check(theString = (char *)env->GetStringUTFChars(str, NULL),
	"Tuple.addElem(String): Failed to get string argument");

  // Add the string element
  Trace("addstringelem");
  a_addstringelem(theTuple, index, theString, TRUE); 
  env->ReleaseStringUTFChars(str, theString);
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (II)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__II
(JNIEnv *env, jobject obj, jint index, jint value)
{
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;

  Trace("setintelem");
  a_setintelem(theTuple, index, value, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (ID)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__ID
(JNIEnv *env, jobject obj, jint index, jdouble value)
{
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;
  Trace("setdoubleelem");
  a_setdoubleelem(theTuple, index, value, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (IZ)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__IZ
(JNIEnv *env, jobject obj, jint index, jboolean value)
{
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;
  Trace("setobjectelem");
  if(value==JNI_TRUE) a_setobjectelem(theTuple, index, truesymbol, TRUE);
  else a_setobjectelem(theTuple, index, falsesymbol, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (ILcallin/Oid;)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__ILcallin_Oid_2
(JNIEnv *env, jobject obj, jint index, jobject oid)
{
  oidtype tmpOid;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return;

  tmpOid = getOidObject(env, oid);
  Trace("setobjectelem2");
  a_setobjectelem(theTuple, index, tmpOid, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (ILcallin/Tuple;)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__ILcallin_Tuple_2
(JNIEnv *env, jobject obj, jint index, jobject seq)
{
  a_tuple theTuple = getTuple(env, obj);
  a_tuple subTuple = getTuple(env,seq);

  if(theTuple==NULL || subTuple==NULL ) return;
  Trace("setseqelem");
  a_setseqelem(theTuple, index, subTuple, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Tuple
 * Method:    setElem
 * Signature: (ILjava/lang/Object;)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_setElem__ILjava_lang_Object_2
(JNIEnv *env, jobject obj, jint index, jobject theObject)
{
  jclass tmpCls;

  if(CheckNullPointer(env,theObject)) return;
  // Integer??
  check(tmpCls = env->FindClass("java/lang/Integer"),
	"Tuple.setElem(Object): Couldn't find class java.lang.Integer");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      // Yes, Integer
      jint tmpInt;
      static jmethodID tmpMid=NULL;

      a_tuple theTuple = getTuple(env, obj);

      if(theTuple==NULL) return;

      if(tmpMid==NULL)
           check(tmpMid = env->GetMethodID(tmpCls, "intValue", "()I"),
            "Tuple.setElem(Object): Couldn't find java.lang.Integer.intValue()");
      tmpInt = env->CallIntMethod(theObject, tmpMid);
      if (env->ExceptionOccurred())
	{
	  env->ExceptionDescribe();
	  env->ExceptionClear();
	  return;
	}
      Trace("setintelem2");
      a_setintelem(theTuple, index, tmpInt, TRUE); 
      if(a_errorflag) ThrowAmosError(env);
      return;
    }

  // Double??
  check(tmpCls = env->FindClass("java/lang/Double"),
	"Tuple.setElem(Object): Couldn't find class java.lang.Double");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      // Yes, Double
      jdouble tmpDouble;
      static jmethodID tmpMid=NULL;

      a_tuple theTuple = getTuple(env, obj);

      if(theTuple==NULL) return;

      if(tmpMid==NULL)
         check(tmpMid = env->GetMethodID(tmpCls, "doubleValue", "()D"),
            "Tuple.setElem(Object): Couldn't find java.lang.Double.doubleValue()");
      tmpDouble = env->CallDoubleMethod(theObject, tmpMid);
      if (env->ExceptionOccurred())
	{
	  env->ExceptionDescribe();
	  env->ExceptionClear();
	  return;
	}
      Trace("setdoubleelem2");
      a_setdoubleelem(theTuple, index, tmpDouble, TRUE); 
      if(a_errorflag) ThrowAmosError(env);
      return;
    }

  // String??
  check(tmpCls = env->FindClass("java/lang/String"),
	"Tuple.setElem(Object): Couldn't find class java.lang.String");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      // Yes, String
      char *tmpStr;
      a_tuple theTuple = getTuple(env, obj);

      if(theTuple==NULL) return;

      check(tmpStr = (char *)env->GetStringUTFChars((jstring)theObject, NULL),
	    "Tuple.setElem(Object): Failed to get string argument");
      Trace("setstringelem2");
      gbc(FALSE);
      a_setstringelem(theTuple, index, tmpStr, TRUE); 
      env->ReleaseStringUTFChars((jstring)theObject, tmpStr);
      if(a_errorflag) ThrowAmosError(env);
      return;
    }

  // Tuple??
  check(tmpCls = env->FindClass("callin/Tuple"),
	"Tuple.setElem(Object): Couldn't find class callin.Tuple");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      a_tuple theTuple = getTuple(env, obj);
      a_tuple subTuple = getTuple(env, theObject);

      if(theTuple==NULL || subTuple==NULL) return;
      Trace("setseqelem2");
      a_setseqelem(theTuple, index, subTuple, TRUE); 
      if(a_errorflag) ThrowAmosError(env);
      return;
    }

  // Oid??
  check(tmpCls = env->FindClass("callin/Oid"),
	"Tuple.setElem(Object): Couldn't find class callin.Oid");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      a_tuple theTuple = getTuple(env, obj);

      if(theTuple==NULL) return;
      Trace("setobjectelem2");
      a_setobjectelem(theTuple, index, getOidObject(env,theObject),TRUE); 
      if(a_errorflag) ThrowAmosError(env);
      return;
    }
  // Boolean??
  check(tmpCls = env->FindClass("java/lang/Boolean"),
	"Tuple.setElem(Object): Couldn't find class java.lang.Boolean");
  if (env->IsInstanceOf(theObject, tmpCls))
    {
      a_tuple theTuple = getTuple(env, obj);
      int tmpInt;
      static jmethodID tmpMid=NULL;

      if(theTuple == NULL) return;
      if(tmpMid==NULL)
        check(tmpMid = env->GetMethodID(tmpCls, "booleanValue", "()Z"),
            "Tuple.setElem(Object): Couldn't find java.lang.Boolean.booleanValue()");
      tmpInt = env->CallBooleanMethod(theObject, tmpMid);
      if (env->ExceptionOccurred())
        {
          env->ExceptionDescribe();
          env->ExceptionClear();
          return;
        }
      Trace("setobjectelem3");
        
      if(tmpInt == JNI_TRUE) a_setobjectelem(theTuple, index, truesymbol, TRUE);
      else a_setobjectelem(theTuple, index, falsesymbol, TRUE);
        
      if(a_errorflag) ThrowAmosError(env);
      return;
    }
}

// ---------- Type testing ----------
/*
 * Class:     callin_Tuple
 * Method:    isString
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isString
(JNIEnv *env, jobject obj, jint pos)
{
  jboolean result;

  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;
  result = a_getelemtype(theTuple, pos, TRUE) == STRINGTYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

/*
 * Class:     callin_Tuple
 * Method:    isInteger
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isInteger
(JNIEnv *env, jobject obj, jint pos)
{
  jboolean result;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;

  result = a_getelemtype(theTuple, pos, TRUE) == INTEGERTYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

/*
 * Class:     callin_Tuple
 * Method:    isDouble
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isDouble
(JNIEnv *env, jobject obj, jint pos)
{
  jboolean result;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;

  result = a_getelemtype(theTuple, pos, TRUE) == REALTYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

/*
 * Class:     callin_Tuple
 * Method:    isBinary
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isBinary //AA
  (JNIEnv *env, jobject obj, jint pos)
{
	jboolean result;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;

  result = a_getelemtype(theTuple, pos, TRUE) == BINARYTYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

/*
 * Class:     callin_Tuple
 * Method:    isObject
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isObject
(JNIEnv *env, jobject obj, jint pos)
{
  jboolean result;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;
  result = a_getelemtype(theTuple, pos, TRUE) == SURROGATETYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

/*
 * Class:     callin_Tuple
 * Method:    isTuple
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Tuple_isTuple
(JNIEnv *env, jobject obj, jint pos) {

  jboolean result;
  a_tuple theTuple = getTuple(env, obj);

  if(theTuple==NULL) return JNI_FALSE;

  // Check if the element in position pos is a tuple
  result = a_getelemtype(theTuple, pos, TRUE) == ARRAYTYPE;
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return JNI_FALSE;
    }
  return (result);
}

// ---------- Setup and termination ----------
/*
 * Class:     callin_Tuple
 * Method:    init
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_init__
(JNIEnv *env, jobject obj)
{
  a_tuple theTuple;
  jfieldID fid;
  jclass cls;

  // Store theTuple in the Java object
  cls = env->GetObjectClass(obj);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return;
    }

  check(fid = env->GetFieldID(cls, "tuplePointer", "I"),
	"Tuple.init: Couldn't get fieldID for tuplePointer");
  Trace("tupleinit");
  theTuple = a_init_tuple(); 
  env->SetIntField(obj, fid, (int)theTuple);
}

/*
 * Class:     callin_Tuple
 * Method:    init
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_init__I
(JNIEnv *env, jobject obj, jint arity)
{
  a_tuple theTuple;
  jfieldID fid;
  jclass cls;

  // Set arity
  Trace("tupleinit2");
  theTuple = a_init_tuple();
  a_setarity(theTuple, arity); 
  // Store theTuple in the Java object
  cls = env->GetObjectClass(obj);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return;
    }
  check(fid = env->GetFieldID(cls, "tuplePointer", "I"),
	"Tuple.init: Couldn't get fieldID for tuplePointer");
  env->SetIntField(obj, fid, (int)theTuple);
}

/*
 * Class:     callin_Tuple
 * Method:    destroy
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Tuple_destroy
(JNIEnv *env, jobject obj)
{
  a_tuple theTuple = getTuple(env, obj);
  // printf("Destroying tuple %d\n",(int)theTuple);
  if(theTuple==NULL) return;
  Trace("freetuple");
  free_tuple(theTuple); 
}

//
// ===== Native Java Connection functions ======================================
//

// ---------- Embedded queries ----------
/*
 * Class:     callin_Connection
 * Method:    execute
 * Signature: (Ljava/lang/String;)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_execute__Ljava_lang_String_2
(JNIEnv *env, jobject obj , jstring str)
{
  a_scan theScan;
  char *theQuery;

  // Get the query
  check(theQuery = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.execute(String): Failed to get string argument");

  // Execute the query
  Trace("execute");
  theScan = a_init_scan();
  a_execute(getConnection(env, obj), theScan, theQuery, TRUE);
  env->ReleaseStringUTFChars(str, theQuery);
  if(a_errorflag){ return ThrowAmosError(env);}
    
  return makeScanObject(env, obj, theScan);
}

/*
 * Class:     callin_Connection
 * Method:    execute
 * Signature: (Ljava/lang/String;I)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_execute__Ljava_lang_String_2I
(JNIEnv *env, jobject obj , jstring str, jint stopAfter) {
  a_scan theScan;
  char *theQuery;

  // Get the query
  check(theQuery = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.execute(String, int): Failed to get string argument");

  // Limit the Scan length
  Trace("execute2");
  theScan = a_init_scan();
  theScan->stopafter = stopAfter;

  // Execute the query
  a_execute(getConnection(env, obj), theScan, theQuery, TRUE);
  env->ReleaseStringUTFChars(str, theQuery);
  if(a_errorflag) { return ThrowAmosError(env);}
    
  return makeScanObject(env, obj, theScan);
}

/*
 * Class:     callin_Connection
 * Method:    executeCustom
 * Signature: (Ljava/lang/String;Ljava/lang/String;)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_executeCustom
(JNIEnv *env, jobject obj, jstring str, jstring options)
{
  a_scan theScan;
  char *theQuery, *theOptions;

  // Get the query
  check(theQuery = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.executeCustom(String, String): Failed to get string argument");
  check(theOptions = (char *)env->GetStringUTFChars(options, NULL),
	"Connection.executeCustom(String, String): Failed to get options argument");

  // Execute the query
  Trace("execute");
  theScan = a_init_scan();
  a_execute_custom(getConnection(env, obj), theScan, theQuery, theOptions, TRUE);
  env->ReleaseStringUTFChars(str, theQuery);
  env->ReleaseStringUTFChars(options, theOptions);
  if(a_errorflag){ return ThrowAmosError(env);}
    
  return makeScanObject(env, obj, theScan);
}

// ---------- Top-loop ----------
/*
 * Class:     callin_Connection
 * Method:    amosTopLoop
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_amosTopLoop
(JNIEnv *env, jobject obj, jstring str)
{
  char *prompt;

  // Get the prompt
  check(prompt = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.amosTopLoop: Failed to get string argument");
  Trace("toploop"); 
  amos_toploop(prompt);
  env->ReleaseStringUTFChars(str, prompt);
}

// ---------- Transaction control ----------
/*
 * Class:     callin_Connection
 * Method:    commit
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Connection_commit
(JNIEnv *env, jobject obj)
{
  Trace("commit");
  a_commit(getConnection(env, obj), TRUE);
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Connection
 * Method:    rollback
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Connection_rollback
(JNIEnv *env, jobject obj)
{

  Trace("rollback");
  a_rollback(getConnection(env, obj), TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

// ---------- Fast-path ----------
/*
 * Class:     callin_Connection
 * Method:    getFunctionInternal
 * Signature: (Ljava/lang/String;)Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_getFunctionInternal
(JNIEnv *env, jobject obj, jstring str)
{
  dcl_oid(fnObj);
  char *fnName;

  // Get the query
  check(fnName = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.getFunction: Failed to get string argument");

  // Get the function
  Trace("getfunction");
  a_assign(fnObj, a_getfunction(getConnection(env, obj), fnName, TRUE));
  env->ReleaseStringUTFChars(str, fnName);
  if(a_errorflag){return ThrowAmosError(env);}
  return makeOidObject(env, obj, fnObj);
}

/*
 * Class:     callin_Connection
 * Method:    callFunction
 * Signature: (Lcallin/Oid;Lcallin/Tuple;)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_callFunction__Lcallin_Oid_2Lcallin_Tuple_2
(JNIEnv *env, jobject obj, jobject fnObj, jobject fnArgs)
{
  a_scan theScan;
  a_tuple theTuple = getTuple(env, fnArgs);
  jobject res;

  if(theTuple==NULL) return NULL;
  Trace("->callfunction");
  theScan = a_init_scan();
  a_callfunction(getConnection(env, obj), theScan, getOidObject(env, fnObj),
		 theTuple, TRUE);
  Trace("<-callfunction");
  if(a_errorflag){ return ThrowAmosError(env);}
    
  res =  makeScanObject(env, obj, theScan);
  return res;
}

/*
 * Class:     callin_Connection
 * Method:    callFunction
 * Signature: (Lcallin/Oid;Lcallin/Tuple;I)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_callFunction__Lcallin_Oid_2Lcallin_Tuple_2I
(JNIEnv *env, jobject obj, jobject fnObj, jobject fnArgs, jint stopAfter)
{
  a_scan theScan;
  a_tuple theTuple = getTuple(env, fnArgs);

  if(theTuple==NULL) return NULL;
  // Limit the Scan length
  Trace("->callfunction2");
  theScan = a_init_scan();
  theScan->stopafter = stopAfter;
  a_callfunction(getConnection(env, obj), theScan, getOidObject(env, fnObj),
		 theTuple, TRUE);
  Trace("<-callfunction2");
  if(a_errorflag) { return ThrowAmosError(env);}
    
  return makeScanObject(env, obj, theScan);
}

/*
 * Class:     callin_Connection
 * Method:    callFunctionCustom
 * Signature: (Lcallin/Oid;Lcallin/Tuple;Ljava/lang/string;)Lcallin/Scan;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_callFunctionCustom
(JNIEnv *env, jobject obj, jobject fnObj, jobject fnArgs, jstring options)
{
  a_scan theScan;
  a_tuple theTuple = getTuple(env, fnArgs);
  jobject res;
  char *theOptions;

  if(theTuple==NULL) return NULL;
  check(theOptions = (char *)env->GetStringUTFChars(options, NULL),
	"Connection.callFunctionCustom(Obj, args, String): Failed to get options argument");

  Trace("->callfunction");
  theScan = a_init_scan();
  a_callfunction_custom(getConnection(env, obj), theScan, getOidObject(env, fnObj),
		 theTuple, theOptions, TRUE);
  Trace("<-callfunction");
  env->ReleaseStringUTFChars(options, theOptions);
  if(a_errorflag){ return ThrowAmosError(env);}
    
  res =  makeScanObject(env, obj, theScan);
  return res;
}

// ---------- Create objects ----------
/*
 * Class:     callin_Connection
 * Method:    createObject
 * Signature: (Lcallin/Oid;)Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_createObject
(JNIEnv *env, jobject obj, jobject typeObj)
{
  dcl_oid(newObject);
  oidtype typeOid;
  a_connection conn;

  typeOid = getOidObject(env, typeObj);
  conn = getConnection(env, obj);
  Trace("createobject");
  a_assign(newObject, a_createobject(conn, typeOid, TRUE)); 
  if(a_errorflag){return ThrowAmosError(env);}
  return makeOidObject(env, obj, newObject);
}

/*
 * Class:     callin_Connection
 * Method:    getType
 * Signature: (Ljava/lang/String;)Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_getType
(JNIEnv *env, jobject obj, jstring str)
{
  dcl_oid(typeOid);
  char *typeName;

  // Get typeName
  check(typeName = (char *)env->GetStringUTFChars(str, NULL),
	"Connection.getType: Failed to get string argument");

  // Get the type object
  Trace("gettype");
  a_assign(typeOid, a_gettype(getConnection(env, obj), typeName, TRUE));
  env->ReleaseStringUTFChars(str, typeName);
  if(a_errorflag) {return ThrowAmosError(env);}

  return makeOidObject(env, obj, typeOid);
}

// ---------- Deleting ----------
/*
 * Class:     callin_Connection
 * Method:    deleteObject
 * Signature: (Lcallin/Oid;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_deleteObject
(JNIEnv *env, jobject obj, jobject oidObj)
{
  Trace("deleteobject");
  a_deleteobject(getConnection(env, obj), getOidObject(env, oidObj), TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

// ---------- Stored functions ----------
/*
 * Class:     callin_Connection
 * Method:    setFunction
 * Signature: (Lcallin/Oid;Lcallin/Tuple;Lcallin/Tuple;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_setFunction
(JNIEnv *env, jobject obj, jobject fnObj, jobject argObj, jobject resObj)
{
  a_tuple argTuple = getTuple(env, argObj);
  a_tuple resTuple = getTuple(env, resObj);

  if(argTuple==NULL || resTuple==NULL) return;
  Trace("setfunction");
  a_setfunction(getConnection(env, obj), getOidObject(env, fnObj),
		argTuple, resTuple, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Connection
 * Method:    addFunction
 * Signature: (Lcallin/Oid;Lcallin/Tuple;Lcallin/Tuple;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_addFunction
(JNIEnv *env, jobject obj, jobject fnObj, jobject argObj, jobject resObj)
{
  a_tuple argTuple = getTuple(env, argObj);
  a_tuple resTuple = getTuple(env, resObj);

  if(argTuple==NULL || resTuple==NULL) return;
  Trace("addfunction");
  a_addfunction(getConnection(env, obj), getOidObject(env, fnObj),
		argTuple, resTuple, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Connection
 * Method:    remFunction
 * Signature: (Lcallin/Oid;Lcallin/Tuple;Lcallin/Tuple;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_remFunction
(JNIEnv *env, jobject obj, jobject fnObj, jobject argObj, jobject resObj)
{
  a_tuple argTuple = getTuple(env, argObj);
  a_tuple resTuple = getTuple(env, resObj);

  if(argTuple==NULL || resTuple==NULL) return;
  Trace("remfunction");
  a_remfunction(getConnection(env, obj), getOidObject(env, fnObj),
		argTuple, resTuple, TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

// ---------- Object retrieval ----------
/*
 * Class:     callin_Connection
 * Method:    getObjectNumbered
 * Signature: (I)Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Connection_getObjectNumbered
(JNIEnv *env, jobject obj, jint idno)
{
  dcl_oid(oid);

  Trace("getobjectno");
  a_assign(oid, a_getobjectno(getConnection(env, obj), idno, TRUE)); 
  // Increases refcnt
  if(a_errorflag){return ThrowAmosError(env);}
  return makeOidObject(env, obj, oid);
}

/*
 * Class:     callin_Connection
 * Method:    printErrForm
 * Signature: ()V;
 */
JNIEXPORT void JNICALL Java_callin_Connection_printErrForm
(JNIEnv *env, jobject obj)
{
  a_print(a_errform);
}

// ---------- Setup and termination ----------

/*
 * Class:     callin_Connection
 * Method:    AmosError
 * Signature: (ILjava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_AmosError
(JNIEnv *env, jclass cls, jint no, jstring msg, jobject obj)
{
  char *str;
  oidtype o;
  //extern int AmosExceptionRaised;

  // Pick up error message
  check(str = (char *)env->GetStringUTFChars(msg, NULL),
	"Connection.AmosError: Failed to get message string");
  if(no<0) a_errstr = str;
  if(obj==NULL) o=nil;
  else o = getOidObject(env, obj);
  if(o==0) return;
  a_error(no,o,TRUE);
  //AmosExceptionRaised = TRUE;
  env->ReleaseStringUTFChars(msg, str);
  return;
}
/*
 * Class:     callin_Connection
 * Method:    initializeAmos0
 * Signature: (I[Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_initializeAmos0
(JNIEnv *env, jclass cls, jstring imageName)
{
  char *str;
  int err;

  // Pick up image name
  check(str = (char *)env->GetStringUTFChars(imageName, NULL),
	"Connection.initializeAmos0: Failed to get string argument");

  // Initialize AMOS2
  a_initialize(str, TRUE);
  err = a_errorflag;
  env->ReleaseStringUTFChars(imageName, str);
  init_java();
  if (err) ThrowAmosError(env);
}

/*
 * Class:     callin_Connection
 * Method:    amosInit
 * Signature: (Ljava/lang/String;[Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_callin_Connection_amosInit
  (JNIEnv *env, jclass jcl, jstring lib, jobjectArray args)
{
  jsize argc;
  jstring arg;
  char **argv, *str;
  int i;
  const char *dll;

  /* Variable dll contains dynamic link library file loaded by Java */
  check(dll = (char *)env->GetStringUTFChars(lib, NULL),
	     "Connection.amosInit: Failed to access loadLibrary name");

  /* Construct argc and argv for starting embedded Amos II */
  argc = env->GetArrayLength(args);
  argv = (char**)malloc(sizeof(*argv)*(1+argc));
  /* Put full path name for loaded DLL in argv[0] so that init_amos
     can use the path for finding the .dmp file */
  argv[0]= (char *)malloc(strlen(dll)+1);
  strcpy(argv[0],dll);

  /* Make Windows path name into Unix style */
  for(i=0;i<(int)strlen(argv[0]);i++) 
    if(argv[0][i]=='\\')argv[0][i]='/';

  /* Copy argv[1] etc. from Java command line args */
  for(i=0;i<argc;i++)
    {
      check(arg = (jstring)env->GetObjectArrayElement(args,i),
	    "Connection.amosInit: Failed to access array element");
      check(str = (char *)env->GetStringUTFChars(arg, NULL),
	    "Connection.amosInit: Failed to get string argument");
      argv[i+1] = (char *)malloc(strlen(str)+1);
      strcpy(argv[i+1],str);
    }

  /* Start Amos II with constructed command line arguments */
  init_amos(argc+1, argv);

  for(i=0;i<argc;i++) free(argv[i]);
  free(argv);

  /* Initialize interface between Amos II and Java */
  init_java();
}

/*
 * Class:     callin_Connection
 * Method:    init
 * Signature: (Ljava/lang/String;)V
 *
 * Called from Connection.Connection(String)
 */
JNIEXPORT void JNICALL Java_callin_Connection_init
(JNIEnv *env, jobject obj, jstring dataBaseName)
{
  char *str;

  check(str = (char *)env->GetStringUTFChars(dataBaseName, NULL),
	"Connection.init: Failed to get string argument");

  Trace("Initializeconnection");
  initializeConnectionObject(env, obj, str);
  env->ReleaseStringUTFChars(dataBaseName, str);
}

/*
 * Class:     callin_Connection
 * Method:    destroy
 * Signature: ()V
 *
 * Called from Connection.finalize(). This function is never called more
 * than once. It's no use throwing exceptions here because the system will
 * ignore unhandled exceptions in finalizers.
 */
JNIEXPORT void JNICALL Java_callin_Connection_destroy
(JNIEnv *env, jobject obj)
{
  // Release the connection to AMOS
  Trace("freeconnection");
  free_connection(getConnection(env, obj)); 
}

/*
 * Class:     callin_Connection
 * Method:    disconnect
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Connection_disconnect
(JNIEnv *env, jobject obj)
{
  // Release the connection to AMOS
  Trace("disconnect");
  a_disconnect(getConnection(env, obj), TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

//
// ===== Native Java Scan functions ===========================================
//

// ---------- Tuple handling ----------
/*
 * Class:     callin_Scan
 * Method:    getRow
 * Signature: ()Lcallin/Tuple;
 */
JNIEXPORT jobject JNICALL Java_callin_Scan_getRow__
(JNIEnv *env, jobject obj)
{
  a_tuple theTuple;
  a_scan scan;

  // Get current tuple in the scan
  scan = getScan(env, obj);
  if(scan==NULL) return NULL;
  theTuple = a_init_tuple();
  a_getrow(getScan(env, obj), theTuple, TRUE);
  if(a_errorflag)
    {
      free_tuple(theTuple); 
      return ThrowAmosError(env);
    }
  return makeTupleObject(env, getConnectionObject(env, obj), theTuple);
}

/*
 * Class:     callin_Scan
 * Method:    getRow
 * Signature: (Lcallin/Tuple;)Lcallin/Tuple;
 */
JNIEXPORT void JNICALL Java_callin_Scan_getRow__Lcallin_Tuple_2
(JNIEnv *env, jobject obj, jobject preAlloc)
{
  a_scan theScan = getScan(env, obj);
  a_tuple theTuple = getTuple(env, preAlloc);

  if(theScan==NULL || theTuple==NULL) return; // error
  a_getrow(theScan, theTuple, TRUE);
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Scan
 * Method:    nextRow
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Scan_nextRow
(JNIEnv *env, jobject obj)
{
  a_scan theScan =  getScan(env, obj);

  if(theScan==NULL) return;

  Trace("nextrow");
  a_nextrow(theScan, TRUE);
  if(a_errorflag) ThrowAmosError(env);
}

/*
 * Class:     callin_Scan
 * Method:    eos
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_callin_Scan_eos
(JNIEnv *env, jobject obj)
{
  a_scan theScan = getScan(env, obj);

  if(theScan==NULL) return TRUE;

  return (a_eos(theScan));
}

// ---------- Close secondary scan ----------
/*
 * Class:     callin_Scan
 * Method:    closeScan
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Scan_closeScan
(JNIEnv *env, jobject obj)
{
  a_scan theScan =  getScan(env, obj);

  if(theScan==NULL) return;

  Trace("closescan");
  a_closescan(theScan, TRUE);
  if(a_errorflag) ThrowAmosError(env);
}

// ---------- Setup and termination ----------
/*
 * Class:     callin_Scan
 * Method:    destroy
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Scan_destroy
(JNIEnv *env, jobject obj)
{
  a_scan theScan = getScan(env, obj);

  if(theScan==NULL) return;
  // printf("Destroying scan %d\n",(int)theScan);
  Trace("freescan");
  free_scan(theScan); 
}

//
// ===== Native Java Oid functions =============================================
//

// ---------- Type ----------
/*
 * Class:     callin_Oid
 * Method:    getType
 * Signature: ()Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callin_Oid_getType
(JNIEnv *env, jobject obj)
{
  dcl_oid(tmpOid);

  Trace("gettype");
  a_assign(tmpOid, a_typeof(getOidObject(env, obj), TRUE)); // increase refcnt
  if(a_errorflag){return ThrowAmosError(env);}
  return makeOidObject(env, getConnectionObject(env, obj), tmpOid);
}

// ---------- ID-number ----------
/*
 * Class:     callin_Oid
 * Method:    getID
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_callin_Oid_getID
(JNIEnv *env, jobject obj)
{
  int idno;

  idno = a_getid(getOidObject(env, obj), TRUE);
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return 0;
    }
  return (idno);
}

// ---------- Printing ----------
/*
 * Class:     callin_Oid
 * Method:    print
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Oid_print
(JNIEnv *env, jobject obj)
{
  a_print(getOidObject(env, obj));
}

/*
 * Class:     callin_Oid
 * Method:    toAmosString
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_callin_Oid_toAmosString
(JNIEnv *env, jobject obj)
{
  oidtype o;
  char *str;
  jstring msg;

  o = getOidObject(env,obj);
  Trace("tostring");
  str = a_stringify(o);
  check(msg=env->NewStringUTF(str),
	"toAmosString: Couldn't construct string");
  free(str);
  return msg;
}

// ---------- Deleting ----------
/*
 * Class:     callin_Oid
 * Method:    delete
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Oid_delete
(JNIEnv *env, jobject obj)
{
  Trace("deleteobject");
  a_deleteobject(getConnection(env, getConnectionObject(env, obj)),
		 getOidObject(env, obj), TRUE); 
  if(a_errorflag) ThrowAmosError(env);
}

// ---------- Setup and termination ----------
/*
 * Class:     callin_Oid
 * Method:    init
 * Signature: (Lcallin/Oid;)V
 */
JNIEXPORT void JNICALL Java_callin_Oid_init
(JNIEnv *env, jobject obj, jobject theType)
{
  dcl_oid(tmpOid);
  jfieldID fid;
  jclass cls;
  a_connection theConnection;
  jobject conn;

  conn = getConnectionObject(env, obj);
  theConnection = getConnection(env, conn);
  Trace("initoid");
  a_assign(tmpOid, a_createobject(theConnection, getOidObject(env, theType), 
				  TRUE)); 
  if(a_errorflag)
    {
      ThrowAmosError(env);
      return;
    }
  // Store theOid in the Java object
  cls = env->GetObjectClass(obj);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return;
    }
  check(fid = env->GetFieldID(cls, "oidtypeHandle", "I"),
	"Oid.init(Oid): Couldn't get fieldID for oidtypeHandle");
  env->SetIntField(obj, fid, (int)tmpOid);

  // Store theConnection in the Java object
  cls = env->GetObjectClass(obj);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      env->ExceptionClear();
      return;
    }
  check(fid = env->GetFieldID(cls, "theConnection", "Lcallin/Connection;"),
	"Oid.init(Oid): Couldn't get fieldID for theConnection");
  env->SetObjectField(obj, fid, getConnectionObject(env, theType));
}

/*
 * Class:     callin_Oid
 * Method:    destroy
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_callin_Oid_destroy
(JNIEnv *env, jobject obj)
{
  oidtype tmp;

  tmp = getOidObject(env, obj);
  Trace("freeoid");
  free_oid(tmp); 
}

EXTERN int a_clientflg; 
void register_java_callin(void)
{
  null_pointer_received = a_register_error("Null pointer received from Java");
  not_boolean = a_register_error("Not a Boolean value");
  local_connection = a_init_connection();
  if(!a_clientflg) a_connect(local_connection,"",FALSE);;
}
