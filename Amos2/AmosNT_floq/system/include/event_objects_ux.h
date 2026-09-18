/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Lars Melander, UDBL
 * $RCSfile: event_objects_ux.h,v $
 * $Revision: 1.1 $ $Date: 2012/07/31 16:29:41 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Event objects for Unix
 * ===========================================================================
 * $Log: event_objects_ux.h,v $
 * Revision 1.1  2012/07/31 16:29:41  larme597
 * Moved here from C directory.
 *
 * Revision 1.1  2009/11/27 09:50:26  larme597
 * Event objects in Unix
 *
 ****************************************************************************/

#ifndef _event_objects_ux_h_
#define _event_objects_ux_h_

#ifndef _MULTI_THREADED
#define _MULTI_THREADED
#endif

#include <pthread.h>

#define DWORD unsigned int
#define BOOL int
#define _alloca alloca

#define INFINITE -1
#define WAIT_OBJECT_0 0
#define WAIT_TIMEOUT 64
#define WAIT_FAILED 96
#define WAIT_ABANDONED_0 128

typedef struct t_list_element
{
  pthread_mutex_t mutex;
  pthread_cond_t cond;
  struct t_list_element *prev, *next;
} *list_element;

typedef struct t_HANDLE
{
  list_element start, end;
  pthread_mutex_t mutex;
  BOOL flag;
} *HANDLE;

void AddElement(HANDLE, list_element);

void RemoveElement(HANDLE, list_element);

pthread_t _beginthread(void (*)(void *), unsigned, void *);

void _endthread();

HANDLE CreateEvent(void *, BOOL, BOOL, void *);

int SetEvent(HANDLE);

int ResetEvent(HANDLE);

BOOL CloseHandle(HANDLE);

DWORD WaitForSingleObject(HANDLE, int);

#define MIL 1000000L
#define BIL 1000000000L
#ifndef ETIMEDOUT
#define ETIMEDOUT 110 // Timeout value
#endif

DWORD WaitForMultipleObjects(DWORD, HANDLE *, BOOL, int);

#endif
