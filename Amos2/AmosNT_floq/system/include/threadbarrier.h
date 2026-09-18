/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: threadbarrier.h,v $
 * $Revision: 1.2 $ $Date: 2011/05/20 16:10:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Barrier function for thread rendez-vous.
 * ===========================================================================
 * $Log: threadbarrier.h,v $
 * Revision 1.2  2011/05/20 16:10:02  larme597
 * More versatile thread barrier.
 *
 * Revision 1.1  2011/05/17 10:38:12  larme597
 * Barrier function for thread rendez-vous.
 *
 ****************************************************************************/

#ifndef __threadbarrier__
#define __threadbarrier__

#include <windows.h>

typedef struct t_barrier
{
  HANDLE event;
  CRITICAL_SECTION sec;
  int init;
  int counter;
  int close;
} *BARRIER;

BARRIER barrier_create();

void barrier_init(BARRIER, int);

int barrier_wait(BARRIER barrier);

void barrier_close(BARRIER barrier);

void barrier_destroy(BARRIER barrier);

#endif
