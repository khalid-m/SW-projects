/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: threadbarrier.c,v $
 * $Revision: 1.2 $ $Date: 2011/05/20 16:10:04 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Barrier function for thread rendez-vous.
 * ===========================================================================
 * $Log: threadbarrier.c,v $
 * Revision 1.2  2011/05/20 16:10:04  larme597
 * More versatile thread barrier.
 *
 * Revision 1.1  2011/05/17 10:38:14  larme597
 * Barrier function for thread rendez-vous.
 *
 ****************************************************************************/

#include "threadbarrier.h"

BARRIER barrier_create()
{
  BARRIER barrier = malloc(sizeof(struct t_barrier));
  InitializeCriticalSection(&barrier->sec);
  barrier->event = CreateEvent(NULL, TRUE, FALSE, NULL);
  barrier->counter = barrier->init = 2;
  barrier->close = FALSE;

  return barrier;
}

void barrier_init(BARRIER barrier, int cnt)
{
  barrier->counter = barrier->init = cnt;
  barrier->close = FALSE;
}

int barrier_wait(BARRIER barrier)
{
  EnterCriticalSection(&barrier->sec);
  if (barrier->close)
    {
      LeaveCriticalSection(&barrier->sec);
      return TRUE;
    }
  
  if (--barrier->counter == 0)
    {
      barrier->counter = barrier->init;
      SetEvent(barrier->event);
      LeaveCriticalSection(&barrier->sec);
    }
  else
    {
      ResetEvent(barrier->event);
      LeaveCriticalSection(&barrier->sec);
      WaitForSingleObject(barrier->event, INFINITE);
      if (barrier->close)
	return TRUE;
    }

  return FALSE;
}

void barrier_close(BARRIER barrier)
{
  EnterCriticalSection(&barrier->sec);
  barrier->close = TRUE;
  SetEvent(barrier->event);
  LeaveCriticalSection(&barrier->sec);
}

void barrier_destroy(BARRIER barrier)
{
  DeleteCriticalSection(&barrier->sec);
  CloseHandle(barrier->event);
  free(barrier);
}
