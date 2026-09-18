/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Lars Melander, UDBL
 * $RCSfile: tls.c,v $
 * $Revision: 1.6 $ $Date: 2012/06/19 16:31:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Simple wrapper for coroutine thread local storage
 * ===========================================================================
 * $Log: tls.c,v $
 * Revision 1.6  2012/06/19 16:31:05  larme597
 * Updates.
 *
 * Revision 1.5  2012/06/14 08:51:52  torer
 * Revert to old lock method
 *
 * Revision 1.2  2010/06/19 19:12:48  larme597
 * Removed locks from tls. Tls now is initialized at startup.
 *
 * Revision 1.1  2009/11/27 09:49:40  larme597
 * Thread local storage for XP, Vista and Unix
 *
 * Revision 1.1  2009/11/03 13:44:35  larme597
 * Created file
 *
 ****************************************************************************/

#include "tls.h"
#include "alisp.h"

#ifdef WIN32

#include <windows.h>

DWORD __tls_co_index;

#else

#ifndef _MULTI_THREADED
#define _MULTI_THREADED
#endif
#include <pthread.h>

pthread_key_t __tls_co_index;

#endif

void tls_init()
{
#ifdef WIN32
  if ((__tls_co_index = TlsAlloc()) == TLS_OUT_OF_INDEXES)
#else
  if (pthread_key_create(&__tls_co_index, NULL) != 0)
#endif
    printf("ERROR! Could not create thread local storage!\n");
}

void tls_save_co(oidtype cr)
{
#ifdef WIN32
  if (!TlsSetValue(__tls_co_index, (void *) cr))
    printf("ERROR! Could not store to thread local storage!\n");
#else
  pthread_setspecific(__tls_co_index, (void *) cr);
#endif
}

oidtype tls_get_co()
{
#ifdef WIN32
  void *val;
  DWORD error;

  val = TlsGetValue(__tls_co_index);
  if ((error = GetLastError()) != 0)
    printf("Thread local storage returned error: %d\n", error);
  return (oidtype) val;
#else
  return (oidtype) pthread_getspecific(__tls_co_index);
#endif
}
