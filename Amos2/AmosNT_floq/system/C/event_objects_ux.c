/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Lars Melander, UDBL
 * $RCSfile: event_objects_ux.c,v $
 * $Revision: 1.6 $ $Date: 2013/10/27 10:20:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Event objects for Unix
 * ===========================================================================
 * $Log: event_objects_ux.c,v $
 * Revision 1.6  2013/10/27 10:20:40  torer
 * Wrong number of arguments in gettimeofday()
 *
 * Revision 1.5  2013/10/26 16:04:53  torer
 * Error checking of pthread code
 *
 * Revision 1.4  2013/04/29 18:26:48  torer
 * Added return code checks
 *
 * Revision 1.3  2013/03/14 15:01:19  torer
 * 32/64 bits neutral code
 *
 * Revision 1.2  2012/07/31 16:28:31  larme597
 * Error checking.
 *
 * Revision 1.1  2009/11/27 09:50:26  larme597
 * Event objects in Unix
 *
 ****************************************************************************/

#include "event_objects_ux.h"
#include "alisp.h"
#include "intstorage.h"

#define PRINT(x) // printf("--co- id: %s thread: %d\n", x, (int)pthread_self()); fflush(stdout)

void AddElement(HANDLE semaphore, list_element le)
{
  PRINT("AddElement");
  if (semaphore->start == NULL)
    semaphore->start = semaphore->end = le;
  else
    {
      semaphore->end->next = le;
      le->prev = semaphore->end;
      semaphore->end = le;
    }
}

void RemoveElement(HANDLE semaphore, list_element le)
{
  list_element ptr;

  PRINT("RemoveElement");
  if (semaphore->start == semaphore->end)
    semaphore->start = semaphore->end = NULL;
  else if (le == semaphore->start)
    semaphore->start = semaphore->start->next;
  else if (le == semaphore->end)
    semaphore->end = semaphore->end->prev;
  else
    for (ptr = semaphore->start->next; ; ptr = ptr->next)
      if (ptr == le)
	{
	  ptr->prev->next = ptr->next;
	  ptr->next->prev = ptr->prev;
	  break;
	}
}

pthread_t _beginthread(void (*start_address)(void *), unsigned stack_size, 
                       void *arg)
{
  pthread_t t;
  pthread_attr_t attr;

  PRINT("_beginthread");
  a_check_rc(pthread_attr_init(&attr));
  a_check_rc(pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED));
  a_check_rc(pthread_create(&t, &attr, (void *)start_address, arg));
  a_check_rc(pthread_attr_destroy(&attr));
  return t;
}

void _endthread()
{
  void *dummy;

  PRINT("_endthread");
  pthread_exit(dummy);
}

// attribute not used, name not used
// manual_reset is ignored, always treated as true
HANDLE CreateEvent(void *attribute, BOOL manual_reset, BOOL initial_state, 
                   void *name)
{
  HANDLE semaphore = malloc(sizeof (struct t_HANDLE));

  PRINT("CreateEvent");
  semaphore->start = semaphore->end = NULL;
  a_check_rc(pthread_mutex_init(&semaphore->mutex, NULL));
  semaphore->flag = initial_state;
  return semaphore;
}

int SetEvent(HANDLE semaphore)
{
  list_element ptr;

  PRINT("SetEvent");
  a_check_rc(pthread_mutex_lock(&semaphore->mutex));
  semaphore->flag = TRUE;
  for (ptr = semaphore->start; ptr != NULL; ptr = ptr->next)
    {
      a_check_rc(pthread_mutex_lock(&ptr->mutex));
      a_check_rc(pthread_cond_signal(&ptr->cond));
      a_check_rc(pthread_mutex_unlock(&ptr->mutex));
      if (ptr == semaphore->end)
	break;
    }
  a_check_rc(pthread_mutex_unlock(&semaphore->mutex));
  return 1;
}

int ResetEvent(HANDLE semaphore)
{
  PRINT("ResetEvent");
  a_check_rc(pthread_mutex_lock(&semaphore->mutex));
  semaphore->flag = FALSE;
  a_check_rc(pthread_mutex_unlock(&semaphore->mutex));
  return 1;
}

BOOL CloseHandle(HANDLE semaphore)
{
  PRINT("CloseHandle");
  if (semaphore->start != NULL)
    return FALSE;
  a_check_rc(pthread_mutex_destroy(&semaphore->mutex));
  free(semaphore);
  return TRUE;
}

DWORD WaitForSingleObject(HANDLE semaphore, int timeout_ms)
{
  return WaitForMultipleObjects(1, &semaphore, FALSE, timeout_ms);
}

DWORD WaitForMultipleObjects(DWORD count, HANDLE *semaphore, BOOL wait_all, 
                             int timeout_ms)
{
  struct t_list_element le;
  DWORD i, return_value;
  int check_value = -1;
  struct timespec t; 
  struct timeval tv; 
  int tzpp[5]; // should be struct timezone tzpp;    

  PRINT("WaitForMultipleObjects");

  if(count == 0) return WAIT_FAILED;

  for (i = 0; i < count; ++i)
    a_check_rc(pthread_mutex_lock(&semaphore[i]->mutex));

  a_check_rc(pthread_mutex_init(&le.mutex, NULL));
  a_check_rc(pthread_cond_init(&le.cond, NULL));
  le.next = NULL; 
  le.prev = NULL;
  for (i = 0; i < count; ++i)
    {
      AddElement(semaphore[i], &le);
      if (semaphore[i]->flag) check_value = 1;
    }
  if (check_value == -1)
    {
      a_check_rc(pthread_mutex_lock(&le.mutex));
      if (timeout_ms != INFINITE)
	{ 
	  gettimeofday(&tv,&tzpp); 
	  t.tv_nsec = tv.tv_usec * 1000  + ((long) timeout_ms) * MIL;
	  t.tv_sec = tv.tv_sec;
	  if (t.tv_nsec >= BIL)
	    {
	      t.tv_sec += t.tv_nsec / BIL;
	      t.tv_nsec %= BIL;
	    }
	}
      for (i = 0; i < count; ++i)
	a_check_rc(pthread_mutex_unlock(&semaphore[i]->mutex));
      if (timeout_ms == INFINITE)
	check_value = pthread_cond_wait(&le.cond, &le.mutex);
      else
	check_value = pthread_cond_timedwait(&le.cond, &le.mutex, &t);
      if (check_value == ETIMEDOUT)
      	return_value = WAIT_TIMEOUT;
      else if(check_value) return_value = WAIT_FAILED;

      a_check_rc(pthread_mutex_unlock(&le.mutex));

      for (i = 0; i < count; ++i)
	a_check_rc(pthread_mutex_lock(&semaphore[i]->mutex));
    }

  for (i = 0; i < count; ++i)
    {
      RemoveElement(semaphore[i], &le);
      if (semaphore[i]->flag) return_value = i;
    }

  for (i = 0; i < count; ++i)
    a_check_rc(pthread_mutex_unlock(&semaphore[i]->mutex));

  a_check_rc(pthread_cond_destroy(&le.cond));
  a_check_rc(pthread_mutex_destroy(&le.mutex));

  return return_value;
}
