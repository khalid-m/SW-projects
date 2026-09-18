/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: lock.h,v $
 * $Revision: 1.4 $ $Date: 2013/03/01 12:59:56 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II locking primitives
 * ===========================================================================
 * $Log: lock.h,v $
 * Revision 1.4  2013/03/01 12:59:56  torer
 * Asserting return codes from calls
 *
 * Revision 1.3  2013/02/28 04:44:40  torer
 * Asserting lock legality
 *
 ****************************************************************************/

#ifdef NT
#include <windows.h>
#include <process.h>    /* _beginthread, _endthread */
extern CRITICAL_SECTION cs, release_cs;    /* System locks */
extern CRITICAL_SECTION callin_cs;
#define ECS(nm) EnterCriticalSection(&nm);
#define LCS(nm) LeaveCriticalSection(&nm);

#else

#ifndef _MULTI_THREADED
#define _MULTI_THREADED
#endif
#include <pthread.h>
extern pthread_mutex_t cs, release_cs;
extern pthread_mutexattr_t cs_attr, release_cs_attr;
extern pthread_mutex_t callin_cs;
extern pthread_mutexattr_t callin_cs_attr;

#define ECS(nm) a_check_rc(pthread_mutex_lock(&nm));
#define LCS(nm) a_check_rc(pthread_mutex_unlock(&nm));
#endif
