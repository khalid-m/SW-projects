/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Lars Melander, UDBL
 * $RCSfile: remoteThreads.c,v $
 * $Revision: 1.2 $ $Date: 2013/08/02 10:20:09 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Testing remote interface with scans
 * ===========================================================================
 * $Log: remoteThreads.c,v $
 * Revision 1.2  2013/08/02 10:20:09  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2012/06/08 16:25:02  larme597
 * *** empty log message ***
 *
 ****************************************************************************/

#ifdef WIN32
#include <windows.h>
#include <process.h>
#else
#ifndef _MULTI_THREADED
#define _MULTI_THREADED
#endif
#include <pthread.h>
#endif

#include "callout.h"

int loops;

#ifdef WIN32
unsigned __stdcall myRemoteThread(void *count)
#else
void myRemoteThread(void *count)
#endif
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(arg);
  dcl_tuple(tpl);
  int i;
  char str[1024];

  a_newtuple(arg, 1, FALSE);
  a_connect(conn, "FOO", FALSE);

  for (i = 1; i <= loops; ++i)
    {
      sprintf(str, "t%d:%d", (int) count, i);
      a_setstringelem(arg, 0, str, FALSE);
      printf(">>Call #%d to ID in thread #%d\n", i, (int) count);

      a_callfunction(conn, s,
		     a_getfunction(conn, "OBJECT.ID->OBJECT", FALSE),
		     arg, FALSE);
      printf(">>Call #%d to ID in thread #%d finished\n", i, (int) count);

      while (!a_eos(s))
	{
	  printf("<<Call #%d to ID in thread #%d before getRow\n", i, (int) count);
	  a_getrow(s, tpl, FALSE);
	  a_getstringelem(tpl, 0, str, 1024, FALSE);
	  printf("<<Result from call #%d to ID in thread #%d: %s\n",
		 i, (int) count, str);
	  a_nextrow(s, FALSE);
	}
    }

  free_tuple(arg);
  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);

  printf("<Ending thread #%d\n", (int) count);

  return 0;
}

int main(int argc, char **argv)
{
  char *dmpfile;
  int i, threads, threadcount;
#ifdef WIN32
  int *thread_array;
#else
  pthread_t *thread_array;
  pthread_attr_t attr;
#endif

  if (argc != 4)
    {
      printf("Wrong number of arguments in call to remoteThreads!\n");
      return 1;
    }
  dmpfile = argv[1];
  threads = atoi(argv[2]);
  loops = atoi(argv[3]);
  threadcount = 0;
  printf("Testing multi-treaded client-server calls ...\n");

#ifdef WIN32
  thread_array = malloc(threads * sizeof(int));
#else
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
  thread_array = malloc(threads * sizeof(pthread_t));
#endif
  a_initialize(dmpfile, FALSE); // Initialize embedded Amos

  //eval_forms(varstack, "(setq _batch_ t) (debugging t) (trace open-port-to print&read)");
  eval_forms(varstack, "(debugging t)");

  for (i = 0; i < threads; ++i)
#ifdef WIN32
    if ((thread_array[threadcount] =
	 _beginthreadex(NULL, 0, myRemoteThread, (void *) (i + 1), 0, NULL)) != 0)
#else
    if (pthread_create(&thread_array[threadcount], &attr,
		       (void *) myRemoteThread, (void *) (i + 1)) == 0)
#endif
      {
	//printf("Initializing thread %d\n", i);
	++threadcount;
      }

  for (i = 0; i < threadcount; ++i)
#ifdef WIN32
    {
      WaitForSingleObject((HANDLE) thread_array[i], INFINITE);
      CloseHandle((HANDLE) thread_array[i]);
    }
#else
    pthread_join(thread_array[i], NULL);
  pthread_attr_destroy(&attr);
#endif

  if (threadcount < threads)
    printf("WARNING! Meant to start %d threads. Only started %d!\n",
	   threads, threadcount);
  free(thread_array);

  return 0;
}
