/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: lock.c,v $
 * $Revision: 1.15 $ $Date: 2013/03/01 12:59:55 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II locking primitives
 * ===========================================================================
 * $Log: lock.c,v $
 * Revision 1.15  2013/03/01 12:59:55  torer
 * Asserting return codes from calls
 *
 * Revision 1.14  2013/02/28 04:47:55  torer
 * Lock assertions added
 *
 * Revision 1.13  2013/01/23 19:55:20  torer
 * Mac-Linux compatible
 *
 * Revision 1.12  2013/01/23 19:24:46  torer
 * *** empty log message ***
 *
 * Revision 1.11  2012/06/19 16:21:25  larme597
 * Debugging stuff.
 *
 * Revision 1.10  2012/06/14 08:51:52  torer
 * Revert to old lock method
 *
 * Revision 1.3  2010/04/02 16:13:18  torer
 * Fatal error when calling kernel in background thread
 *
 * Revision 1.2  2009/11/09 09:22:51  larme597
 * Removing #ifdef:s to include UNIX
 *
 * Revision 1.1  2009/09/10 21:07:03  torer
 * *** empty log message ***
 *
 *
 ****************************************************************************/
#include "intstorage.h"
#include "lock.h"

#ifdef NT
CRITICAL_SECTION cs, release_cs;    /* System locks */
#else
pthread_mutex_t cs, release_cs;
pthread_mutexattr_t cs_attr, release_cs_attr;
#endif

#define PRINT(x) //printf("--l- id: %d %s\n", GetCurrentThreadId(), x); fflush(stdout)

extern oidtype co_thiscr;
extern int co_this_thread_busy(void);

EXPORT void a_lock(void)
{ 
  if (co_this_thread_busy()) 
    {
      printf("ERROR: Calling Amos II from background thread\n");
      printf("Abending...");
      exit(1);
    }

  PRINT("lock");
  if (co_thiscr == t)
    printf("a_lock called in dead coroutine\n");
  if (co_thiscr == nil)
    {ECS(cs);}
  else
    PRINT("In coroutine!");
  PRINT("lock cont");
}

EXPORT void a_unlock(void)
{
  PRINT("unlock");
  if (co_thiscr == t)
    printf("a_lock called in dead coroutine\n");
  if (co_thiscr == nil)
    LCS(cs);
  PRINT("unlock cont");
}

#if !defined(PTHREAD_MUTEX_RECURSIVE_NP) && defined(PTHREAD_MUTEX_RECURSIVE)
#define PTHREAD_MUTEX_RECURSIVE_NP PTHREAD_MUTEX_RECURSIVE
#define pthread_mutexattr_setkind_np pthread_mutexattr_settype
#endif

void register_lock(void)
{
#ifdef NT
  InitializeCriticalSection(&cs);
  InitializeCriticalSection(&release_cs);
#else
  a_check_rc(pthread_mutexattr_init(&cs_attr));
  a_check_rc(pthread_mutexattr_setkind_np(&cs_attr, 
					 PTHREAD_MUTEX_RECURSIVE_NP));
  a_check_rc(pthread_mutex_init(&cs, &cs_attr));
  a_check_rc(pthread_mutexattr_init(&release_cs_attr));
  a_check_rc(pthread_mutexattr_setkind_np(&release_cs_attr, 
					 PTHREAD_MUTEX_RECURSIVE_NP));
  a_check_rc(pthread_mutex_init(&release_cs, &release_cs_attr));
#endif
}
