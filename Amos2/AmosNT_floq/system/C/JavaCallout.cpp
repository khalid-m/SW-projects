/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2001 Daniel Elin, Tore Risch, UDBL
 * $RCSfile: JavaCallout.cpp,v $
 * $Revision: 1.39 $ $Date: 2011/07/06 20:29:57 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface when calling Java from Amos II
 * ===========================================================================
 * $Log: JavaCallout.cpp,v $
 * Revision 1.39  2011/07/06 20:29:57  torer
 * Caching Java class objects
 *
 * Revision 1.38  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.37  2010/12/29 20:32:33  torer
 * Java as a foreign language
 *
 * Revision 1.36  2010/06/15 20:21:34  torer
 * Graceful CTRL-C under Java
 *
 * Revision 1.35  2009/11/09 09:24:24  larme597
 * Removing #ifdef:s to include UNIX
 *
 * Revision 1.34  2009/02/11 15:40:55  torer
 * *** empty log message ***
 *
 * Revision 1.33  2009/01/06 14:54:45  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.32  2008/12/14 16:43:16  torer
 * Added interface to a_callback_connection
 *
 *
 * Revision 1.30  2008/11/25 16:24:09  torer
 * Added debug printings
 *
 * Revision 1.29  2008/11/25 07:16:28  torer
 * Support for multi-threaded C applications
 *
 * Revision 1.28  2008/11/24 22:08:49  torer
 * Fixed bug making calling foreign Java functions in different threads crash sometimes
 *
 * Revision 1.27  2008/11/19 21:10:00  torer
 * Calling JVM from coroutine thread
 *
 * Revision 1.26  2008/07/08 17:48:12  torer
 * Linux setting
 *
 ****************************************************************************/

#include <jni.h>
#include "environ.h"
#include "callout.h"
#include "alisp.h"
#include "language.h"

#include "JavaAmos.h"
#include "callout_CallContext.h"
EXTERN int AmosInitialized(void);
extern oidtype getOidObject(JNIEnv *env, jobject oid); /* In JavaCallin.cpp */
extern jobject ThrowAmosError(JNIEnv *env); /* In JavaCallin.cpp */
extern jobject NewJavaOid(JNIEnv *env, oidtype o); /* In JavaCallin.cpp */
extern int JavaAmosError(JNIEnv *env, int err, oidtype form); /* JavaCallin */
EXTERN a_connection a_callback_connection; /* In cinterf.c */
EXTERN oidtype co_insidefn(bindtype);
EXTERN void co_enterbg(oidtype);
EXTERN void co_leavebg(oidtype);
EXTERN void *co_thread_finalizer;

#define JAVA_VM_VERSION 0x00010001    // Use default JavaVM

#define DEFAULT_CLASSPATH "."
jobject AmosLock=NULL;

/*
 * bindJava() uses the following struct to cache the parameters used to call the
 * Java-method corresponding to the name bindJava() is called with. We do
 * this because finding these parameters is rellatively expensive.
 */
typedef struct {
  // Parameters for calling the foreign function
  jobject   obj;
  jmethodID mid;
  // Parameters for constructing a CallContext object
  jclass    cxtCls;
  jmethodID cxtMid;
  // Parameters for constructing a Tuple object
  jclass    tplCls;
  jmethodID tplMid;
} callInfo;

//
// ========== Forwarded exported functions =====================================
//

EXPORT extern int bindJava(char *);
EXPORT extern void callJava(a_callcontext, a_tuple);
EXPORT int javaStarted();

//
// ========== Forwarded Private functions ======================================
//

int parseForeignName(char *, char *, char *);
int loadSystemClasses();
oidtype bind_javafn(bindtype, oidtype);

/*
 * Keeps track of if the JavaVM is started or not.
 */
static int javaVMStarted = FALSE;

/*
 * The following variables must be globals because they must retain their
 * values between successive calls to bindJava().
 */

static JavaVM *jvm;
static jclass cxtCls, tplCls;
static jmethodID cxtMid, tplMid;
int java_exception; // error code

//
// ========== Exported functions ==============================================
//

JNIEnv* JNI_getenv()
{
  JNIEnv* env;
  jint jniError = 0;

#ifdef NT
  jniError = jvm->AttachCurrentThread((JNIEnv_ **)&env, (void *)NULL);
#else
  jniError = jvm->AttachCurrentThread((void **)&env, (void *)NULL);
#endif
  if (jniError == JNI_OK) return env;
  else fprintf(stderr, "%s: AttachCurrentThread failed, returned %d\n",
	       (long)jniError);
  return NULL;
}

void JNI_thread_detach(void)
{
  jvm->DetachCurrentThread();
}

EXPORT int startJavaVM(void)
  /* Start the Java virtual machine */
{
  jint numVMs;
  debug("     Starting for JavaVM");
  if (!javaVMStarted)
    {
      debug("  -->> JNI_GetCreatedJavaVMs()");
      if (JNI_GetCreatedJavaVMs(&jvm, 1, &numVMs) != 0)
	{
	  // Panic! Check failed.
	  fprintf(stderr, "bindJava: Couldn't check for JavaVMs.\n");
	  return (FALSE);
	}
      debug("  <<-- JNI_GetCreatedJavaVMs()");
      if (numVMs>0) // Other Java VM already started
	{
	  // In JDK1.1 there can be only one JavaVM in a single process.
	  /*JNI_GetDefaultJavaVMInitArgs(&dummy_thr_args); */
	  // Load CallContext and Tuple classes
	  if (!loadSystemClasses()) return FALSE;
	  debug("     Loaded CallContext and Tuple classes");
	  javaVMStarted = TRUE;
          debug("     JVM started OK");
	}
    }
  return javaVMStarted;
}

/*
 * Called when a foreign Java-function is declared. Starts the Java-VM (nop
 * if the VM is started). The argument foreignName is of the form:
 *    JAVA:packetname.classname/methodname
 * This function checks that the .class-file associated with the classname
 * exists and loads that file (if it hasn't been loaded by some previous
 * call to this function). It checks for the method methodname in the class
 * and then instantiates one object. Then it registrates foreignName with
 * callJava() using a_extfunction(). Then a callInfo struct is built and saved
 * with foreignName using a_setpredparam().
 * If nothing fails, return TRUE, otherwise return FALSE.
 */
 
EXPORT int bindJava(char *foreignName) 
{
  jclass cls;
  jobject obj;
  jmethodID mid, constrMid;
  char className[1024];     // CRASH AND BURN if strlen(className) > 1024!!!
  char functionName[1024];  // CRASH AND BURN if strlen(functionName) > 1024!!!
  char fname[1024];
  callInfo *cInfo;
  jint numVMs;
  JNIEnv* env;

  debug("\n-->> bindJava()");

  // Check if the JavaVM is already started.
  // This check is nescesary because the JavaVM can have been started before
  // calling this function for the first time. (eg. a Java driver-program has
  // been used)
  debug("     Checking for JavaVMs...");
  if (!javaVMStarted)
    {
      debug("  -->> JNI_GetCreatedJavaVMs()");
      if (JNI_GetCreatedJavaVMs(&jvm, 1, &numVMs) != 0)
	{
	  // Panic! Check failed.
	  fprintf(stderr, "bindJava: Couldn't check for JavaVMs.\n");
	  return (FALSE);
	}
      debug("  <<-- JNI_GetCreatedJavaVMs()");
      if (numVMs>0) // Other Java VM already started
	{
	  // In JDK1.1 there can be only one JavaVM in a single process.
	  /*JNI_GetDefaultJavaVMInitArgs(&dummy_thr_args); */
	  javaVMStarted = TRUE;
	  // Load CallContext and Tuple classes
	  if (!loadSystemClasses())
	    {
	      //Panic! Couldn't load the system classes
	      return (FALSE);
	    }
	  debug("     Loaded CallContext and Tuple classes");
	}
    }

  // JavaVM started?
  if (!javaVMStarted)
    {
      fprintf(stderr,"No JVM started\n");
      return FALSE;
    }

  env = JNI_getenv();
  // Parse foreignName into className and functionName
  strcpy(fname,foreignName);
  if (!parseForeignName(fname, className, functionName))
    {
      // Malformed foreignName
      fprintf(stderr, "bindJava: Malformed foreign function name.\n");
      return (FALSE);
    }
  debug("     Parsed foreignName");

  // Load className
  cls = env->FindClass(className);
  if (env->ExceptionOccurred())
    {
      env->ExceptionDescribe();
      fprintf(stderr, "bindJava: Couldn't find class %s\n.", className);
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Loaded className");

  // Find methodID of the foreign function
  mid = env->GetMethodID(cls, functionName, 
			 "(Lcallout/CallContext;Lcallin/Tuple;)V");
  if (env->ExceptionOccurred())
    {
      // Panic!
      env->ExceptionDescribe();
      fprintf(stderr, 
	      "bindJava: Couldn't find method %s in %s.\n", 
	      functionName, className);
      env->ExceptionDescribe();
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Found methodID of foreign function");

  // Find methodID of the default constructor of className
  constrMid = env->GetMethodID(cls, "<init>", "()V");
  if (env->ExceptionOccurred())
    {
      // Panic!
      env->ExceptionDescribe();
      fprintf(stderr, 
	      "bindJava: Couldn't find default constructor in %s.\n", 
	      className);
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Found methodID of default constructor in className");

  // Instantiate one instance of className
  obj = env->NewObject(cls, constrMid);
  if (env->ExceptionOccurred())
    {
      // Panic!
      env->ExceptionDescribe();
      fprintf(stderr, "bindJava: Couldn't instantiate %s.\n", className);
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Instantiated className");
  if ((obj = env->NewGlobalRef(obj)) == NULL)
    {
      // Panic! Out of memory.
      fprintf(stderr, "bindJava: No memory for obj\n");
      return (FALSE);
    }
  debug("     Created global reference to obj");

  // Build a callInfo struct
  if ((cInfo = (callInfo *)malloc(sizeof(callInfo))) == NULL)
    {
      // Panic!
      fprintf(stderr, 
	      "bindJava: No memory to build callInfo-struct for %s.\n", 
	      functionName);
      return (FALSE);
    }
  cInfo->obj = obj;
  cInfo->mid = mid;					// The foreign-function
  cInfo->cxtCls = cxtCls;
  cInfo->cxtMid = cxtMid;
  cInfo->tplCls = tplCls;
  cInfo->tplMid = tplMid;
  debug("     Built callInfo structure");

  // Register foreignName with callJava()
  a_extfunction(foreignName, callJava);
  debug("     Registred foreignName with callJava()");

  // Save callInfo struct
  a_setpredparam(foreignName, (char *)cInfo);
  debug("     Saved callInfo with foreignName");

  // Return to AMOS2
  debug("<<-- bindJava()\n");
  return (TRUE);
}

/*
* A foreign Amos II C function used for calling a foreign Java-function.
 * When AMOS2 wants to call some foreign Java-function it calls this function
 * which in turn calls the Java-function via an argument in the a_callcontext.
 */
EXPORT void callJava(a_callcontext cxt, a_tuple tpl) {

  JNIEnv *env;
  jobject cxtObj, tplObj, exc;
  dcl_tuple(newtpl);
  callInfo *cinfo;

  debug("-->> callJava()");
  a_setf(newtpl->tpl,tpl->tpl);
  cinfo = (callInfo *)a_extpredparam(cxt);
  env = JNI_getenv();

  // Build a Java CallContext-object
  if ((cxtObj = env->NewObject(cinfo->cxtCls, cinfo->cxtMid, cxt)) == NULL)
    {
      fprintf(stderr, "callJava: Couldn't construct the CallContext object.\n"
	      );
      exit(1);
    }
  debug("     Built CallContext-object");

  // Build a Java Tuple-object
  if ((tplObj = env->NewObject(cinfo->tplCls, cinfo->tplMid, newtpl,
			       (jobject)NULL)) == NULL)
    {
      fprintf(stderr, "callJava: Couldn't construct the Tuple object.\n");
      exit(1);
    }
  debug("     Built Tuple-object");

  // Call the foreign function
#ifdef DEBUG_ON
  printf("     --->");
  a_print(cxt->fno);
#endif
  env->CallVoidMethod(cinfo->obj, cinfo->mid, cxtObj, tplObj);
#ifdef DEBUG_ON
  printf("     <---");
  a_print(cxt->fno);
#endif
  if (cxt->done)
    {
      // Amos throw, i.e. no more tuples in iteration
      env->ExceptionClear();

      goto end;
    }
  else if (exc=env->ExceptionOccurred())
    {
      jclass JavaException, AmosException;
      jmethodID mid;
      jobject mess;
      char *str;

      // Exception thrown in foreign Java function

      /* Dispatch between Amos II error and other Java errors */
      check(AmosException = env->FindClass("callin/AmosException"),
	    "callJava: Couldn't find class callin/AmosException");
      if(env->IsInstanceOf(exc,AmosException))
	{
	  /* Pick upp the error number */
	  jfieldID errnoField, errformField;
	  int ErrorNumber;
	  oidtype ErrorForm;

	  check(errnoField = env->GetFieldID(AmosException,"errno","I"),
		"callJava: Couldn't find attribute errno");
	  ErrorNumber = env->GetIntField(exc,errnoField);
          if(ErrorNumber==0)
	    {
              cxt->done = TRUE;
              goto end;
            }
          env->ExceptionDescribe();  // backtrace on console
          env->ExceptionClear(); // No Java exception any more
	  if(ErrorNumber == -1)
	    /* AmosError(msg) raised in Java. Work-around for no Java 
               encoding of strings as Java Oid */
	    {
	      jfieldID errstrField;

	      check(errstrField = env->GetFieldID(AmosException,"errstr",
						  "Ljava/lang/String;"),
		    "CallJava: Couldn't find field errstr");
	      mess = env->GetObjectField(exc, errstrField);
	      str = (char *)env->GetStringUTFChars((jstring)mess, 0);
	      a_errstr = str;
	      a_error(ErrorNumber,nil,TRUE);
	    }
	  else  // Normal amos error raised
	    {
	      check(errformField = env->GetFieldID(AmosException,"errform",
						   "Lcallin/Oid;"),
		    "callJava: Couldn't find attribute errform");
	      ErrorForm = getOidObject(env, 
				       env->GetObjectField(exc,errformField));
	      a_error(ErrorNumber,ErrorForm,TRUE);
	    }
	}
      else   // Java internal error
	{
          env->ExceptionDescribe();  // backtrace on console
          env->ExceptionClear(); // No Java exception any more
	  /* Pick up the error message from java and make an Amos II error */
	  check(JavaException = env->FindClass("java/lang/Exception"),
		"callJava: Couldn't find class java/lang/Exception");
	  check(mid= env->GetMethodID(JavaException,
				      "getMessage",
				      "()Ljava/lang/String;"),
		"callJava: Couldn't find method getMessage");
	  mess = env->CallObjectMethod(exc, mid);
	  str = (char *)env->GetStringUTFChars((jstring)mess, 0); 
	  a_error(java_exception,mkstring(str),TRUE);
	}
      cxt->done = TRUE;
      // caller will print exception
    }
 end:
  env->DeleteLocalRef(tplObj);
  env->DeleteLocalRef(cxtObj);
  signal(SIGINT,a_interrupt_handler);
  debug("     Done.\n<<-- callJava()");
}

/*
 * Returns TRUE if the JavaVM is started.
 */
EXPORT int javaStarted()
{
  return (javaVMStarted);
}

//
// ========== Private functions ===============================================
//

/*
 * Loads the CallContext and Tuple classes and stores the methodID of their
 * constructors.
 */
int loadSystemClasses(void)
{
  // Load the CallContext and Tuple classes
  JNIEnv *env = JNI_getenv();
  cxtCls = env->FindClass("callout/CallContext");
  AmosLock = env->NewGlobalRef(cxtCls);
  if (env->ExceptionOccurred())
    {
      fprintf(stderr, 
	      "loadSystemClasses: Couldn't load class callout.CallContext.\n");
      env->ExceptionDescribe();
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Loaded callout.CallContext");
  if ((cxtCls = (jclass)env->NewGlobalRef(cxtCls)) == NULL)
    {
      // Panic! Out of memory.
      fprintf(stderr, "loadSystemClasses: No memory for cxtCls\n");
      return (FALSE);
    }
  debug("     Created global reference to callout.CallContext");
  tplCls = env->FindClass("callin/Tuple");
  if (env->ExceptionOccurred())
    {
      fprintf(stderr, 
	      "loadSystemClasses: Couldn't load class callin.Tuple.\n");
      env->ExceptionDescribe();
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Loaded callin.Tuple");
  if ((tplCls = (jclass)env->NewGlobalRef(tplCls)) == NULL)
    {
      // Panic! Out of memory.
      fprintf(stderr, "loadSystemClasses: No memory for tplCls\n");
      return (FALSE);
    }
  debug("     Created global reference to callin.Tuple");

  // Find the methodID's of the constructors of CallContext and Tuple classes
  cxtMid = env->GetMethodID(cxtCls, "<init>", "(I)V");
  if (env->ExceptionOccurred())
    {
      fprintf(stderr, 
	      "loadSystemClasses: Couldn't find (I)V constructor in callout.CallContext.\n");
      env->ExceptionDescribe();
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Found methodID of constructor in callout.CallContext");
  tplMid = env->GetMethodID(tplCls, "<init>", "(ILcallin/Connection;)V");
  if (env->ExceptionOccurred())
    {
      fprintf(stderr, 
	      "loadSystemClasses: Couldn't find (ILcallin/Connection;)V constructor in callin.Tuple.\n");
      env->ExceptionDescribe();
      env->ExceptionClear();
      return (FALSE);
    }
  debug("     Found methodID of constructor in callin.Tuple\n");
  signal(SIGINT,a_interrupt_handler);
  return (TRUE);
}

/*
 * Parses foreign function name of the form:
 *    JAVA:packetname.classname/methodname
 * into two strings, className and functionName, where className is of the
 * form packetname/classname and functionName is equal to methodname.
 * SegFault if strlen(className) > 1024 or strlen(functionName) > 1024.
 * Returns: TRUE on success, FALSE otherwise.
 */
int parseForeignName(char *foreignName, char *className, char *functionName)
{
  char *tmp;
  char *delim = ":/";

  tmp = strtok(foreignName, delim);
  if (strcmp(tmp, "JAVA") != 0)
  {
    return (FALSE);
  }
  if ((tmp = strtok(NULL, delim)) == NULL)
  {
    return (FALSE);
  }
  strcpy(className, tmp);
  if ((tmp = strtok(NULL, delim)) == NULL)
  {
    return (FALSE);
  }
  strcpy(functionName, tmp);
  if (strtok(NULL, "delim") != NULL)
  {
    return (FALSE);
  }
  while ((tmp = strchr(className, '.')) != NULL)
  {
   *tmp = '/';
  }
  return (TRUE);
}

/*
 * Binds a declared Java foreign-function to an external predicate.
 */
oidtype bind_javafn(bindtype env, oidtype name)
{
  char *thename, *copyname;
  int res;

  IntoString(name,thename,env);
  copyname = strdup(thename);
  res = bindJava(copyname);
  free(copyname);
  if (res)  return t;
  return nil;
}

//
// ===== Exported native Java function ==================================================
//

// ---------- Emitting results ----------
/*
 * Class:     callout_CallContext
 * Method:    emit
 * Signature: (Lcallin/Tuple;)V
 */
JNIEXPORT void JNICALL Java_callout_CallContext_emit
  (JNIEnv *env, jobject obj, jobject tpl) {
    static jfieldID fid=NULL,fid2=NULL;
    static jclass cls=NULL,cls2=NULL;
    a_callcontext cxt;
    a_tuple theTuple;

    debug("-->> Java_callout_CallContext_emit");

    // Get the pointer to the callcontext stored in this Java-object
    cache_class(cls,env->GetObjectClass(obj));
    if(fid==NULL)check(fid=env->GetFieldID(cls, "cxtPointer", "I"),
          "CallContext.emit: Couldn't get fieldID for cxtPointer");
    debug("     Got fieldID for cxtPointer");
    cxt = (a_callcontext)env->GetIntField(obj, fid);
    debug("     Got cxtPointer");

    // Get the Tuple stored in the Java-object tpl
    cache_class(cls2,env->GetObjectClass(tpl));
    if(fid2==NULL)check(fid2=env->GetFieldID(cls2, "tuplePointer", "I"),
          "CallContext.emit: Couldn't get fieldID for tuplePointer");
    debug("     Got fieldID for tuplePointer");
    theTuple = (a_tuple)env->GetIntField(tpl, fid2);
    debug("     Got tuplePointer");

    {unwind_protect_begin;
       a_emit(cxt, theTuple, FALSE); // Don't trap errors for highest performance.
    unwind_protect_catch;
       if(unwind_reset) // error or throw
       {
          cxt->done = TRUE;
          if(a_errorflag) // error
          {
            debug("     Amos II exception passed to Java");
            ThrowAmosError(env);  // Throw AmosException
            return;
          }
          else  // End of iteration exception. Throw NoMoreData exceptiom
          {
            jclass excCls=NULL;

            debug("     NoMoreData exception raised");
            check(excCls=env->FindClass("callout/NoMoreData"),
                  "CallContext.emit: Couldn't find class callout.NoMoreData");
            env->ThrowNew(excCls, "");
            return;
          }
        }
     unwind_protect_end;}
    debug("<<-- Java_callout_CallContext_emit");

  }

/*
 * Class:     callout_CallContext
 * Method:    getBG
 * Signature: ()Lcallin/Oid;
 */
JNIEXPORT jobject JNICALL Java_callout_CallContext_getBG
(JNIEnv *env, jobject obj)
{
  oidtype res = nil;
  res = co_insidefn(varstack);
  return NewJavaOid(JNI_getenv(), res);
}

/*
 * Class:     callout_CallContext
 * Method:    enterBG
 * Signature: (Lcallin/Oid;)V
 */
JNIEXPORT void JNICALL Java_callout_CallContext_enterBG
(JNIEnv *env, jobject obj, jobject co)
{
  oidtype coro=nil;
  coro= getOidObject(env, co);
  co_enterbg(coro);
}

/*
 * Class:     callout_CallContext
 * Method:    leaveBG
 * Signature: (Lcallin/Oid;)V
 */
JNIEXPORT void JNICALL Java_callout_CallContext_leaveBG
  (JNIEnv *env, jobject obj, jobject co)
{
  oidtype coro=nil;
  coro= getOidObject(env, co);
  co_leavebg(coro);
  JNI_getenv();
  return;
}

oidtype java_enabledfn(bindtype env)
{
  if(javaStarted()) return t;
  return nil;
}

void init_java(void) 
{
  extern void register_java_callin(void);
  static int called=FALSE;
  int vm_not_started;

  if(!AmosInitialized()) return;
  if(!called)
    {
      debug("-->> init_java()");
      called=TRUE;

      /* Error codes */
      java_exception = a_register_error("Exception in call to Java");
      vm_not_started = a_register_error("Java Virtual Machine did not start");

      if(!startJavaVM()) a_error(vm_not_started, nil, FALSE);

      /* Interface functions: */
      extfunction1("bind-java",bind_javafn); /* foreign function loader */
      extfunction0("java-enabled",java_enabledfn);
  
      a_register_enabled("java","java-enabled");
      a_register_loader("java","bind-java");

      register_java_callin();

      /* Called when switching coroutine thread: */
      co_thread_finalizer = (void*)JNI_thread_detach;
      debug("<<-- init_java()");
    }
}
