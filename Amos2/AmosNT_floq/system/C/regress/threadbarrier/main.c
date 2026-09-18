/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: main.c,v $
 * $Revision: 1.2 $ $Date: 2011/05/20 16:12:00 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Testing thread rendez-vous.
 * ===========================================================================
 * $Log: main.c,v $
 * Revision 1.2  2011/05/20 16:12:00  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2011/05/17 10:43:53  larme597
 * Testing thread rendez-vous.
 *
 ****************************************************************************/

#include <windows.h>
#include <stdio.h>
#include "threadbarrier.h"

#define THREADNUM 50
int arr[THREADNUM];
HANDLE thread[THREADNUM];
CRITICAL_SECTION sec;

BARRIER barrier;

DWORD WINAPI threadfunc(void *num)
{
	int i, j;

	for (i = 1; i < 4; ++i)
	{
		Sleep((unsigned long) (1000 * (float) rand() / RAND_MAX));
		arr[(int) num] = i;

		barrier_wait(barrier);
		EnterCriticalSection(&sec);
		for (j = 0; j < THREADNUM; ++j)
		{
			if (arr[j] != i)
				printf("Thread %d detected error! Thread %d had error!\n", num, j);
		}
		LeaveCriticalSection(&sec);
		barrier_wait(barrier);
		printf("Thread %d finished round %d.\n", num, i);
	}

	return 0;
}

int main(void)
{
	int i;

	barrier = barrier_create();
	barrier_init(barrier, THREADNUM);
	InitializeCriticalSection(&sec);

	for (i = 0; i < THREADNUM; ++i)
		arr[i] = 0;

	for (i = 0; i < THREADNUM; ++i)
		if ((thread[i] = CreateThread(NULL, 0, threadfunc, (void *) i, 0, NULL)) == NULL)
			printf("Thread %d failed to start!\n", i);

	WaitForMultipleObjects(THREADNUM, thread, TRUE, INFINITE);
	barrier_destroy(barrier);
	DeleteCriticalSection(&sec);

	return 0;
}