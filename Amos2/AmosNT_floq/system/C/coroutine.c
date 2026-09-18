/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Tore Risch, UDBL
 * $RCSfile: coroutine.c,v $
 * $Revision: 1.61 $ $Date: 2014/01/09 19:12:08 $
 * $State: Exp $ $Locker:  $
 *
 * Description: ALisp coroutines
 * ===========================================================================
 * $Log: coroutine.c,v $
 * Revision 1.61  2014/01/09 19:12:08  torer
 * Removed declaration of a_backtrace()
 *
 * Revision 1.60  2013/10/27 10:08:47  torer
 * Added more trace prints
 *
 * Revision 1.59  2013/06/26 17:45:28  torer
 * Reverting (CO-SLEEP)
 *
 * Revision 1.57  2013/03/23 14:44:07  torer
 * playback() hanged when timestamp decreased
 *
 * Revision 1.56  2013/02/28 08:44:48  larme597
 * Bugfix in co_kill_on_resumefn.
 *
 * Revision 1.55  2012/12/21 12:23:40  larme597
 * moved globals struct to h file. Bug fix for co-kill-on-resume.
 *
 * Revision 1.54  2012/12/21 12:03:17  torer
 * OS independence
 *
 * Revision 1.53  2012/08/22 16:16:43  larme597
 * Function (co-kill-on-resume) can take an optional label. Coroutine
 * leaving co-yield or background will throw label.
 *
 * Revision 1.52  2012/08/21 15:32:50  larme597
 * New function (co-kill-on-resume co) sets kill flag but does not kill
 * coroutine.
 *
 * Revision 1.51  2012/07/31 16:27:38  larme597
 * Adding error checking. Can't run coroutine that's loaded from dmp file.
 *
 * Revision 1.50  2012/07/30 15:12:56  larme597
 * Function co-list-wait can now take a timeout value.
 *
 * Revision 1.49  2012/06/27 08:43:40  larme597
 * New function coroutinep to check if object is coroutine.
 * New function co-list-wait to wait for list of coroutines and scans.
 *
 * Revision 1.48  2012/06/19 16:18:51  larme597
 * Updates.
 *
 * Revision 1.47  2012/06/14 08:51:52  torer
 * Revert to old lock method
 *
 * Revision 1.44  2012/01/09 16:04:05  larme597
 * Memory leaked fixed by having none of the C functions touch the reference
 * counter for message and result variables.
 *
 * Revision 1.43  2011/11/15 15:06:03  larme597
 * New lisp function co-resumet that adds timeout to a coroutine call.
 * Used for scans.
 *
 * Revision 1.42  2011/10/19 08:29:08  larme597
 * Changed structure, more like original; no more deallocation in background.
 * Callback removed, superfluous.
 *
 * Revision 1.41  2011/08/23 12:03:15  larme597
 * New functions: co-anyterminatedv and co-vresumev. Added cleanup callback.
 *
 * Revision 1.40  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.39  2010/11/18 13:29:53  zeitler
 * Added coroutine header file
 *
 * Revision 1.38  2010/11/04 21:54:38  zeitler
 * Added (co-select covector timeout msg),
 * returning the list of tuples from all non-busy coroutines in covector
 *
 * Revision 1.37  2010/06/21 16:53:31  larme597
 * co_enterbg0/co_leavebg0, argument-less versions of co_enterbg/co_leavebg.
 *
 * Revision 1.36  2010/06/19 19:12:48  larme597
 * Removed locks from tls. Tls now is initialized at startup.
 *
 * Revision 1.35  2010/04/14 15:49:23  torer
 * Re-checked in
 *
 * Revision 1.34  2010/04/02 15:23:41  torer
 * Added function to test whether in background thread
 *
 * Revision 1.33  2009/11/27 09:52:36  larme597
 * Going forward again
 *
 * Revision 1.31  2009/11/03 13:48:18  larme597
 * Fixed killing and deallocating coroutines, added thread local storage
 *
 * Revision 1.30  2009/09/28 14:47:02  torer
 * Reverted back to old version
 *
 * Revision 1.29  2009/09/25 16:14:04  larme597
 * *** empty log message ***
 *
 * Revision 1.28  2009/09/25 14:12:11  larme597
 * Coroutines can now be killed or deallocated while still running in 
 * the background
 *
 * Revision 1.27  2009/09/21 08:04:20  larme597
 * Fixing memory leaks and unix crash. Cancelling background coroutine
 * not yet working 
 *
 * Revision 1.26  2009/09/02 18:17:33  torer
 * Fixed memory leak
 *
 * Revision 1.25  2009/08/05 14:56:54  fred2431
 * Compile fix: do not include header files inside function definitions
 *
 * Revision 1.20  2009/06/22 07:29:19  larme597
 * Bugfix for state save in co-resumev.
 *
 * Revision 1.19  2009/06/16 15:05:52  larme597
 * C implementation of co-resumev function.
 *
 * Revision 1.18  2009/06/11 16:33:13  torer
 * Bug in CO-SLEEP
 *
 * Revision 1.16  2009/05/28 19:14:09  torer
 * Fixed memory leak
 * New function: (CO-PRINT CO) to inspect coroutine state
 *
 * Revision 1.15  2009/05/28 15:25:15  torer
 * Concurrency problem with interruptable a_sleep in coroutine thread
 *
 * Revision 1.14  2009/03/20 08:28:21  torer
 * co-args to puck up coroutine arguments
 *
 * Revision 1.13  2009/01/08 21:23:47  torer
 * Deallocation bug
 *
 * Revision 1.12  2009/01/06 14:54:45  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.11  2009/01/03 12:50:31  torer
 * CO-SLEEP and CO-BUSY in C
 *
 * Revision 1.10  2009/01/01 22:54:17  torer
 * Saved error information in coroutine state record
 *
 * Revision 1.9  2009/01/01 21:31:33  torer
 * Error suppression state saved
 *
 * Revision 1.8  2008/12/14 16:45:53  torer
 * a_locked removed
 *
 * Revision 1.7  2008/12/02 20:48:43  torer
 * Lock migration through coroutine threads
 *
 * Revision 1.6  2008/11/19 21:10:00  torer
 * Calling JVM from coroutine thread
 *
 * Revision 1.5  2008/09/29 16:13:48  torer
 * Error check added
 *
 * Revision 1.4  2008/09/29 14:29:52  torer
 * introduced resumeCoroutine and resumeCaller
 *
 * Revision 1.3  2008/09/27 16:43:21  torer
 * 'Java-safe' (and thread-safe) coroutines
 *
 * Revision 1.2  2008/09/24 05:28:38  torer
 * Default system stack size in coroutines
 *
 * Revision 1.1  2008/09/23 21:05:06  torer
 * Added coroutines to ALisp. See regress/coroutines.lsp.
 *
 ****************************************************************************/

#include "alisp.h"
#include "coroutine.h"
#include "scan.h"
#include "a_time.h"
#ifdef WIN32
#include <windows.h>
#include <process.h> // _beginthread, _endthread
#endif
#include <stddef.h>
#include <stdlib.h>

#ifdef UNIX
#include "event_objects_ux.h"
#endif

#include "tls.h"

#define PRINT(x) //printf("--co- id: %s thread: %d\n", x, (int)pthread_self()); fflush(stdout)

extern void initvarstack(int);

oidtype busysymbol;
int coroutinetype;

// Global state variables
extern bindtype varstackslack;
extern void *current_contdata; // Data for ObjecLog continuation function
oidtype co_thiscr;
EXPORT void (*co_thread_finalizer)();
extern oidtype _suppress_error_;

void SaveGlobals(struct globals *gl)
{
  gl->varstack = varstack;
  gl->varstacksize = varstacksize;
  gl->varstacktop = varstacktop;
  gl->varstackslack = varstackslack;
  gl->topenv = topenv;
  gl->resetlabelp = resetlabelp;
  gl->current_contdata = current_contdata;
  gl->thiscr = co_thiscr;
  gl->suppress_error = (globval(_suppress_error_) != nil);
  gl->a_errno = a_errno;
  gl->errorflag = a_errorflag;
  gl->errform = a_errform;
};

void RestoreGlobals(struct globals *gl)
{
  varstack = gl->varstack;
  varstacksize = gl->varstacksize;
  varstacktop = gl->varstacktop;
  varstackslack = gl->varstackslack;
  topenv = gl->topenv;
  resetlabelp = gl->resetlabelp;
  current_contdata = gl->current_contdata;
  co_thiscr = gl->thiscr;
  a_setf(globval(_suppress_error_), gl->suppress_error? t : nil);
  a_errorflag = gl->errorflag;
  a_errno = gl->a_errno;
  a_errform = gl->errform;
};

struct coroutine
{
  objtags tags;
  bindtype varstack;
  int thid;
  int terminated;
  int reset;
  int kill;
  oidtype throwlabel;
  int busy;
  oidtype function;
  oidtype args;
  oidtype message;
  oidtype result;
  HANDLE callersemaphore;
  HANDLE cosemaphore;
  HANDLE bgsemaphore;
  struct globals mglobals;
  struct globals cglobals;
};

// Error values
int coroutine_terminated;
int yield_outside_coroutine;
int waitformultipleobjects_error;
int waitforsingleobject_error;

int resumeCoroutine(oidtype cr);
void kill_coroutine(oidtype cr)
{
  PRINT("kill_coroutine");
  dr(cr, coroutine)->kill = TRUE;
  WaitForSingleObject(dr(cr, coroutine)->bgsemaphore, INFINITE);
  resumeCoroutine(cr);
}

void free_coroutine(oidtype cr)
{
  PRINT("free_coroutine");
  if (!dr(cr, coroutine)->terminated)
    // coroutine still running, not terminated
    kill_coroutine(cr);
  a_free(dr(cr, coroutine)->function);
  a_free(dr(cr, coroutine)->args);
  a_free(dr(cr, coroutine)->throwlabel);
  CloseHandle(dr(cr, coroutine)->callersemaphore);
  CloseHandle(dr(cr, coroutine)->cosemaphore);
  CloseHandle(dr(cr, coroutine)->bgsemaphore);
  dealloc_object(cr);
}

void suicideCoroutine(oidtype cr)
{
  PRINT("suicideCoroutine");
  if (varstack != NULL)
    {
      clearstack(varstack);
      free(varstack);
      dr(cr, coroutine)->varstack = NULL;
      varstack = NULL;
    }

  dr(cr, coroutine)->terminated = TRUE;
  SetEvent(dr(cr, coroutine)->callersemaphore); // let main thread continue
  if (co_thread_finalizer != NULL)
    (*co_thread_finalizer)();

  _endthread();
}

int waitForSemaphore(HANDLE semaphore)
{
  DWORD dwRetCode;

  PRINT("waitForSemaphore");
  dwRetCode = WaitForSingleObject(semaphore, INFINITE);
  if (dwRetCode == WAIT_OBJECT_0)
    return TRUE;
  return FALSE;
}

void resumeCaller(oidtype cr)
{
  PRINT("resumeCaller");
  SaveGlobals(&dr(cr, coroutine)->cglobals); // Save my state
  ResetEvent(dr(cr, coroutine)->cosemaphore); // I will wait soon
  SetEvent(dr(cr, coroutine)->callersemaphore); // Make caller run
  waitForSemaphore(dr(cr, coroutine)->cosemaphore);
  RestoreGlobals(&dr(cr, coroutine)->cglobals); // Restore my state
}

int resumeCoroutine(oidtype cr)
{
  PRINT("resumeCoroutine");
  SaveGlobals(&dr(cr, coroutine)->mglobals); // Save my state
  if (ResetEvent(dr(cr, coroutine)->callersemaphore) == 0) // I will wait soon
    return 1; // Error!
  SetEvent(dr(cr, coroutine)->cosemaphore); // Make coroutine run
  waitForSemaphore(dr(cr, coroutine)->callersemaphore);
  RestoreGlobals(&dr(cr, coroutine)->mglobals); // Restore my state
  return 0;
}

oidtype co_resumefn(bindtype env, oidtype cr, oidtype msg)
{
  PRINT("co_resumefn");
  OfType(cr, coroutinetype, env);
  dr(cr, coroutine)->message = msg;
  if (dr(cr, coroutine)->terminated) // terminated
    return lerror(coroutine_terminated, cr, env);
  if (dr(cr, coroutine)->busy)
    return busysymbol;
  if (resumeCoroutine(cr))
    return lerror(coroutine_terminated, cr, env);
  if (dr(cr, coroutine)->reset)
    resetfn(env);
  if (dr(cr, coroutine)->busy)
    return busysymbol;
  return dr(cr, coroutine)->result;
}

oidtype co_resumetfn(bindtype env, oidtype cr, oidtype timeout, oidtype msg)
{
  oidtype return_value = nil;
  DWORD dwRetCode;
  double timeout_real;
  double time_elapsed = 0;
  double current_time;

  PRINT("co_resumetfn");
  if (timeout != nil)
    IntoDouble(timeout, timeout_real, env);

  while (TRUE)
    {
      return_value = co_resumefn(env, cr, msg);
      if (return_value != busysymbol)
	return return_value;

      if (timeout == nil || timeout_real < 0)
	dwRetCode = WaitForSingleObject(dr(cr, coroutine)->bgsemaphore, 
                                        INFINITE);
      else
	{
	  if (time_elapsed < timeout_real)
	    {
	      current_time = rnow();
	      dwRetCode = WaitForSingleObject(dr(cr, coroutine)->bgsemaphore,
					      (DWORD) ((timeout_real - 
                                                        time_elapsed) * 1000));
	      time_elapsed += rnow() - current_time;
	    }
	  else
	    dwRetCode = WAIT_TIMEOUT;
	}

      if (dwRetCode == WAIT_TIMEOUT)
	return nil;
      else if (dwRetCode == WAIT_FAILED)
	; // Could not wait, just start over
      else if (dwRetCode >= WAIT_ABANDONED_0)
	return lerror(waitforsingleobject_error, mkinteger(dwRetCode), env);
    }

  return nil;
}

oidtype co_resumevfn(bindtype env, oidtype crv, oidtype timeout, oidtype msg)
{
  int i, array_size, semaphore_count;
  oidtype cr = nil, return_value = nil;
  BOOL all_terminated = TRUE, stop = FALSE;
  HANDLE *semaphores;
  DWORD dwRetCode, timeout_ms;
  double timeout_real;

  PRINT("co_resumevfn");
  OfType(crv, ARRAYTYPE, env);
  OfType(a_elt(crv, 0), coroutinetype, env);
  if (timeout != nil)
    {
      OfType(timeout, REALTYPE, env);
      timeout_real = getreal(timeout);
    }
  array_size = a_arraysize(crv);
  semaphores = _alloca(array_size * sizeof (HANDLE));
  while (TRUE)
    {
      for (i = 0, semaphore_count = 0; i < array_size && !stop; ++i)
	{
	  cr = a_elt(crv, i);
	  if (!dr(cr, coroutine)->terminated) // not terminated
	    {
	      all_terminated = FALSE;
	      if (!dr(cr, coroutine)->busy)
		{
		  return_value = co_resumefn(env, cr, msg);
		  if (return_value != busysymbol)
		    stop = TRUE;
		}
	      if (!stop)
		semaphores[semaphore_count++] = dr(cr, coroutine)->bgsemaphore;
	    }
	}
      if (all_terminated)
	return nil;
      if (stop)
	return return_value;

      if (timeout == nil)
	dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE, 
                                           INFINITE);
      else
	{
	  timeout_ms = (DWORD) (timeout_real * 1000);
	  dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE,
                                             timeout_ms);
	}

      if (dwRetCode == WAIT_TIMEOUT)
	return busysymbol;
      else if (dwRetCode == WAIT_FAILED)
	; // Could not wait, just start over
      else if (dwRetCode >= WAIT_ABANDONED_0)
	return lerror(waitformultipleobjects_error, mkinteger(dwRetCode), env);
    }
  return nil;
}

oidtype co_list_waitfn(bindtype env, oidtype crl, oidtype timeout)
{
  int semaphore_count;
  oidtype cr = nil;
  HANDLE *semaphores;
  DWORD dwRetCode, timeout_ms;
  double timeout_real;

  PRINT("co_list_waitfn");
  OfType(crl, LISTTYPE, env);
  semaphores = _alloca(a_length(crl) * sizeof (HANDLE));
  if (timeout != nil)
    IntoDouble(timeout, timeout_real, env);

  for (semaphore_count = 0; listp(crl); crl = tl(crl))
    {
      cr = hd(crl);
      if (a_datatype(cr) == coroutinetype)
	semaphores[semaphore_count++] = dr(cr, coroutine)->bgsemaphore;
      else if (a_datatype(cr) == scantype)
	semaphores[semaphore_count++] =
	  dr(dr(cr, scancell)->coroutine, coroutine)->bgsemaphore;
      else
	return lerror(waitformultipleobjects_error, cr, env);	  
    }

  while (TRUE)
    {
      if (timeout == nil)
	dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE, 
                                           INFINITE);
      else
	{
	  timeout_ms = (DWORD) (timeout_real * 1000);
	  dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE,
                                             timeout_ms);
	}

      if (dwRetCode == WAIT_TIMEOUT)
	return busysymbol;
      else if (dwRetCode == WAIT_FAILED)
	; // Could not wait, just start over
      else if (dwRetCode >= WAIT_ABANDONED_0)
	return lerror(waitformultipleobjects_error, mkinteger(dwRetCode), env);
      else
	break;
    }
  return nil;
}

oidtype co_selectfn(bindtype env, oidtype crv, oidtype timeout, oidtype msg) {
  int i, array_size, semaphore_count;
  oidtype cr = nil, return_value = nil, retlist = nil;
  BOOL all_terminated = TRUE, stop = FALSE;
  HANDLE *semaphores;
  DWORD dwRetCode, timeout_ms;
  double timeout_real;

  PRINT("co_selectfn");
  OfType(crv, ARRAYTYPE, env);
  OfType(a_elt(crv, 0), coroutinetype, env);
  if (timeout != nil) {
    OfType(timeout, REALTYPE, env);
    timeout_real = getreal(timeout);
  }
  array_size = a_arraysize(crv);
  semaphores = _alloca(array_size * sizeof (HANDLE));
  while (TRUE) {
    for (i = 0, semaphore_count = 0; i < array_size; ++i) {
      cr = a_elt(crv, i);
      if (!dr(cr, coroutine)->terminated) { // not terminated
	all_terminated = FALSE;
	if (!dr(cr, coroutine)->busy) {
	  return_value = co_resumefn(env, cr, msg);
	  if (return_value != busysymbol) {
	    push(return_value, retlist);
	    stop = TRUE;
	  }
	}
	if (!stop)
	  semaphores[semaphore_count++] = dr(cr, coroutine)->bgsemaphore;
      }
    }
    if (all_terminated)
      return nil;
    if (stop)
      a_return(retlist);
    //SaveGlobals(&dr(cr, coroutine)->mglobals); // Save my state
    if (timeout == nil) {
      dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE,
					 INFINITE);
    } else {
      timeout_ms = (DWORD) (timeout_real * 1000);
      dwRetCode = WaitForMultipleObjects(semaphore_count, semaphores, FALSE,
					 timeout_ms);
    }
    //RestoreGlobals(&dr(cr, coroutine)->mglobals); // Restore my state
    if (dwRetCode == WAIT_TIMEOUT)
      return busysymbol;
    else if (dwRetCode == WAIT_FAILED)
      ; // Could not wait, just start over
    else if (dwRetCode >= WAIT_ABANDONED_0)
      return lerror(waitformultipleobjects_error, mkinteger(dwRetCode), env);
  }
  return nil;
}

oidtype co_vresumevfn(bindtype env, oidtype crv, oidtype msg)
{
  int i, array_size;
  oidtype cr, return_value, return_vector = nil;
  BOOL all_terminated = TRUE, stop = FALSE;
  HANDLE *semaphores;
  DWORD dwRetCode;

  PRINT("co_vresumefn");
  OfType(crv, ARRAYTYPE, env);
  OfType(a_elt(crv, 0), coroutinetype, env);

  array_size = a_arraysize(crv);
  semaphores = _alloca(array_size * sizeof (HANDLE));
  a_let(return_vector, new_array(array_size, nil));

  while (TRUE)
    {
      for (i = 0; i < array_size; ++i)
	{
	  cr = a_elt(crv, i);
	  if (!dr(cr, coroutine)->terminated) // not terminated
	    {
	      all_terminated = FALSE;
	      if (!dr(cr, coroutine)->busy)
		{
		  return_value = co_resumefn(env, cr, msg);
		  if (return_value != busysymbol)
		    {
		      a_seta(return_vector, i, return_value);
		      stop = TRUE;
		    }
		}
	      if (!stop)
		semaphores[i] = dr(cr, coroutine)->bgsemaphore;
	    }
	}

      if (all_terminated)
	{
	  a_free(return_vector);
	  return nil;
	}
      if (stop)
	a_return(return_vector);

      dwRetCode = WaitForMultipleObjects(array_size, semaphores, FALSE, 
                                         INFINITE);

      if (dwRetCode == WAIT_FAILED)
	; // Could not wait, just start over
      else if (dwRetCode >= WAIT_ABANDONED_0)
	return lerror(waitformultipleobjects_error, mkinteger(dwRetCode), env);
    }

  return nil;
}

EXPORT oidtype co_yieldfn(bindtype env, oidtype result)
{
  oidtype cr = co_thiscr;

  PRINT("co_yieldfn");
  if (cr != nil)
    {
      dr(cr, coroutine)->result = result;
      resumeCaller(cr);
      if (dr(cr, coroutine)->throwlabel != nil)
	a_throw(env, dr(cr, coroutine)->throwlabel, nil);
      if (dr(cr, coroutine)->kill)
	resetfn(env);
      return dr(cr, coroutine)->message;
    }
  else
    return lerror(yield_outside_coroutine, result, env);
}

oidtype co_killfn(bindtype env, oidtype cr)
{
  PRINT("co_killfn");
  OfType(cr, coroutinetype, env);
  if (dr(cr, coroutine)->terminated)
    return cr;
  kill_coroutine(cr);
  return cr;
}

oidtype co_kill_on_resumefn(bindtype env, oidtype cr, oidtype label)
{
  PRINT("co_kill_on_resumefn");
  // This function is usually called from a separate thread,
  // therefore coroutine might not exist anymore
  if (cr == nil)
    return cr;
  OfType(cr, coroutinetype, env);
  if (label != nil)
    {
      a_setf(dr(cr, coroutine)->throwlabel, label);
    }
  else
    dr(cr, coroutine)->kill = TRUE;
  return cr;
}

oidtype co_terminatedfn(bindtype env, oidtype cr)
{
  PRINT("co_terminatedfn");
  OfType(cr, coroutinetype, env);
  if (dr(cr, coroutine)->terminated)
    return t;
  return nil;
}

oidtype co_anyterminatedvfn(bindtype env, oidtype crv)
{
  int i;
  int size;

  PRINT("co_anyterminatedvfn");
  OfType(crv, ARRAYTYPE, env);
  OfType(a_elt(crv, 0), coroutinetype, env);
  size = a_arraysize(crv);

  for (i = 0; i < size; ++i)
    if (dr(a_elt(crv, i), coroutine)->terminated)
      return t;
  return nil;
}

EXPORT oidtype co_insidefn(bindtype env)
{
  PRINT("co_insidefn");
  return co_thiscr;
}

oidtype co_busypfn(bindtype env, oidtype cr)
{
  PRINT("co_busypfn");
  OfType(cr, coroutinetype, env);
  if (dr(cr, coroutine)->terminated) // terminated
    return lerror(coroutine_terminated, cr, env);
  if (dr(cr, coroutine)->busy)
    return t;
  return nil;
}

EXPORT void co_enterbg0()
{
  oidtype cr;

  PRINT("co_enterbg0");
  if (co_thiscr == nil)
    return;
  cr = co_thiscr;
  dr(cr, coroutine)->result = busysymbol;
  SaveGlobals(&dr(cr, coroutine)->cglobals); // Save my state
  dr(cr, coroutine)->busy = TRUE;
  ResetEvent(dr(cr, coroutine)->cosemaphore); 
                           // I will resume main computation later
  ResetEvent(dr(cr, coroutine)->bgsemaphore); // Entering background
  SetEvent(dr(cr, coroutine)->callersemaphore); // Make caller run before that
}

EXPORT void co_enterbg(oidtype cr)
{
  PRINT("co_enterbg");
  if (cr != co_thiscr)
    { 
      a_error(ILLEGAL_ARGUMENT, cr, FALSE);
      return;
    }
  co_enterbg0();
}

EXPORT int co_this_thread_busy()
{
  oidtype cr;

  PRINT("co_this_thread_busy");
  cr = tls_get_co();
  if ((void *) cr == NULL)
    return FALSE;
  if (dr(cr, coroutine)->busy)
    return TRUE;
  return FALSE;
}

EXPORT void co_leavebg0()
{
  oidtype cr;

  PRINT("co_leavebg0");
  cr = tls_get_co();
  if ((void *) cr == NULL)
    return;
  dr(cr, coroutine)->busy = FALSE;
  SetEvent(dr(cr, coroutine)->bgsemaphore); // Leaving background
  waitForSemaphore(dr(cr, coroutine)->cosemaphore);
  RestoreGlobals(&dr(cr, coroutine)->cglobals); // Restore my state
  if (dr(cr, coroutine)->throwlabel != nil)
    a_throw(varstack, dr(cr, coroutine)->throwlabel, nil);
  if (dr(cr, coroutine)->kill)
    resetfn(topenv);
}

EXPORT void co_leavebg(oidtype cr)
{
  PRINT("co_leavebg");
  if (cr == nil)
    return;
  if (typetag(dr(cr, coroutine)) != coroutinetype)
    {
      printf("ERROR, illegal object passed to co_leavebg.");
      return;
    }
  co_leavebg0();
}

#ifdef UNIX
#include <unistd.h>
#endif
EXPORT void a_sleep0(double s)
{
  if(s<0) return;
#ifdef UNIX
  usleep(s * 1000000);
#else
  // This sleep cannot be interrupted!
  Sleep((DWORD) (s * 1000));
#endif
}

oidtype co_sleepfn(bindtype env, oidtype s)
{
  double sec = coerce_real(env, s);
  oidtype cr;

  PRINT("co_sleepfn");
  cr = co_thiscr;
  co_enterbg(cr);
  a_sleep0(sec); // The Amos II kernel must not be called here
  co_leavebg(cr);
  return s;
}

oidtype co_argsfn(bindtype env, oidtype cr)
{
  OfType(cr, coroutinetype, env);
  return dr(cr, coroutine)->args;
}

oidtype co_printfn(bindtype env, oidtype cr)
{
  OfType(cr, coroutinetype, env);
  printf("Coroutine cell at %d\n", (int)cr);
  printf("thid: %d\nreset: %d\nkill: %d\nbusy:%d\n",
	 dr(cr, coroutine)->thid, dr(cr, coroutine)->reset,
	 dr(cr, coroutine)->kill, dr(cr, coroutine)->busy);
  printf("function: "); a_print(dr(cr, coroutine)->function);
  printf("args: "); a_print(dr(cr, coroutine)->args);
  printf("message: "); a_print(dr(cr, coroutine)->message);
  printf("result: "); a_print(dr(cr, coroutine)->result);
  if (dr(cr, coroutine)->terminated) 
    {
      printf("Stack empty\n");
      return nil;
    }
  printf("Stack: \n");
  a_backtrace(dr(cr, coroutine)->cglobals.varstack,
	      dr(cr, coroutine)->cglobals.topenv);
  return nil;
}

oidtype coroutinepfn(bindtype env, oidtype cr)
{
  if (a_datatype(cr) == coroutinetype)
    return t;
  return nil;
}

void CoroutineHandler(void *arg)
{
  oidtype cr = (oidtype) arg;
  HANDLE mysem;

  PRINT("CoroutineHandler");
  initvarstack(a_stacksize);
  dr(cr, coroutine)->varstack = varstack;
  co_thiscr = cr;
  tls_save_co(cr);
  mysem = CreateEvent(NULL, TRUE, FALSE, NULL);
  dr(cr, coroutine)->cosemaphore = mysem;
  dr(cr, coroutine)->bgsemaphore = CreateEvent(NULL, TRUE, TRUE, NULL);
  SaveGlobals(&dr(cr, coroutine)->cglobals);
  SetEvent(dr(cr, coroutine)->callersemaphore);
  waitForSemaphore(mysem);
  RestoreGlobals(&dr(cr, coroutine)->cglobals);
  if (dr(cr, coroutine)->kill)
    suicideCoroutine(cr);
  // First resume goes here
  {
    unwind_protect_begin;
    dr(cr, coroutine)->result =
      applyfn(varstack, dr(cr, coroutine)->function, dr(cr, coroutine)->args);
    unwind_protect_catch;
    if (unwind_reset && !dr(cr, coroutine)->kill)
      {
	//printf("RESET!\n"); fflush(stdout);
	dr(cr, coroutine)->reset = TRUE;
      }
    suicideCoroutine(cr);
  }
}

oidtype coroutinefn(bindtype env, oidtype function, oidtype args)
{
  int id;
  oidtype cr;
  HANDLE mysem;
  PRINT("coroutinefn");
  cr = new_object(sizeof (struct coroutine), coroutinetype);
  mysem = CreateEvent(NULL,   // no security attributes
		      TRUE,   // manual reset event
		      FALSE,  // initially set to non signaled state
		      NULL);
  a_let(dr(cr, coroutine)->function, function);
  a_let(dr(cr, coroutine)->args, args);
  dr(cr, coroutine)->message = nil;
  dr(cr, coroutine)->result = nil;
  dr(cr, coroutine)->callersemaphore = mysem;
  dr(cr, coroutine)->reset = FALSE;
  dr(cr, coroutine)->busy = FALSE;
  dr(cr, coroutine)->varstack = NULL;
  dr(cr, coroutine)->kill = FALSE;
  dr(cr, coroutine)->throwlabel = nil;
  dr(cr, coroutine)->terminated = FALSE;
  SaveGlobals(&dr(cr, coroutine)->mglobals);
  if ((id = (int)_beginthread(CoroutineHandler, 0, (void *) cr)) == -1)
    {
      printf("Error! Cannot start new thread!\n");
      a_free(dr(cr, coroutine)->function);
      a_free(dr(cr, coroutine)->args);
      CloseHandle(mysem);
      dealloc_object(cr);
      return nil;
    }
  waitForSemaphore(mysem); // Wait for coroutine initialization
  RestoreGlobals(&dr(cr, coroutine)->mglobals);
  dr(cr, coroutine)->thid = id;
  return cr;
}

void register_coroutine(void)
{
  coroutinetype = a_definetype("coroutine", free_coroutine, NULL);
  coroutine_terminated = a_register_error("Coroutine terminated");
  waitformultipleobjects_error =
    a_register_error("WaitForMultipleObjects() returned an error");
  waitforsingleobject_error =
    a_register_error("WaitForSingleObject() returned an error");
  yield_outside_coroutine = a_register_error("CO-YIELD outside coroutine");
  busysymbol = mksymbol("*busy*");
  extfunction2("coroutine", coroutinefn);
  extfunction2("co-resume", co_resumefn);
  extfunction3("co-resumet", co_resumetfn);
  extfunction3("co-resumev", co_resumevfn);
  extfunction2("co-list-wait", co_list_waitfn);
  extfunction3("co-select", co_selectfn);
  extfunction2("co-vresumev", co_vresumevfn);
  extfunction1("co-kill", co_killfn);
  extfunction2("co-kill-on-resume", co_kill_on_resumefn);
  extfunction1("co-terminated", co_terminatedfn);
  extfunction1("co-anyterminatedv", co_anyterminatedvfn);
  extfunction1("co-yield", co_yieldfn);
  extfunction0("co-inside", co_insidefn);
  extfunction1("co-busyp", co_busypfn);
  extfunction1("co-sleep", co_sleepfn);
  extfunction1("co-args", co_argsfn);
  extfunction1("co-print", co_printfn);
  extfunction1("coroutinep", coroutinepfn);
  co_thiscr = nil;
  co_thread_finalizer = NULL;

  tls_init();
}
