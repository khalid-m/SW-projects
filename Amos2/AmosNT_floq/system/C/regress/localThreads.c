/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Lars Melander, UDBL
 * $RCSfile: localThreads.c,v $
 * $Revision: 1.8 $ $Date: 2012/06/14 08:51:53 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Testing coroutines and multiple threads in C
 * ===========================================================================
 * $Log: localThreads.c,v $
 * Revision 1.8  2012/06/14 08:51:53  torer
 * Revert to old lock method
 *
 * Revision 1.4  2011/03/09 12:33:43  torer
 * Amos as DLL!
 *
 * Revision 1.3  2010/06/22 15:22:30  larme597
 * Win32 version of localThreads now running.
 *
 * Revision 1.2  2010/06/21 16:58:48  larme597
 * Linux localThreads test.
 *
 * Revision 1.1  2010/06/16 17:24:14  larme597
 * Created file
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
char *fname;

void myLocalThread(void *count)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(arg);
  dcl_tuple(t);
  int res;

  //printf(">Thread %d\n", count);
  a_newtuple(arg, 1, FALSE);
  a_setintelem(arg, 0, loops, FALSE);
  a_connect(conn, "", FALSE); // name "" indicates connect to embedded Amos
  //printf("Calling %s ...\n", fname);
  a_callfunction(conn, s, a_getfunction(conn, fname, FALSE), arg, FALSE);

  while (!a_eos(s))
    {
      a_getrow(s, t, FALSE);
      res = a_getintelem(t, 0, FALSE);
      //printf("!%d\n", res);
      a_nextrow(s, FALSE);
    }
  //printf("Disconnecting .. %d\n", count);
  if (res != loops)
    printf("Wrong res: %d for call: %d in thread: %d\n", res, loops, count); 

  free_tuple(arg);
  free_tuple(t);
  free_scan(s);
  free_connection(conn);
  //printf("<Thread %d\n", count);
}

extern void co_enterbg0();
extern void co_leavebg0();
extern void a_sleep0(double);

void backgroundbf(a_callcontext cxt, a_tuple t)
{
  int w = a_getintelem(t, 0, FALSE);
  a_setelem(t, 1, mkinteger(w));
  printf("About to sleep %d\n", w);
  co_enterbg0();
  a_sleep0(w);
  printf("Woke up\n");
  co_leavebg0();
  a_emit(cxt, t, FALSE);
}

int main(int argc, char **argv)
{
  dcl_connection(conn);
  dcl_scan(s);
  char *dmpfile, *osql;
  int i, threads, threadcount;
#ifdef WIN32
  int *thread_array;
#else
  pthread_t *thread_array;
  pthread_attr_t attr;
#endif
  if (argc != 6)
    {
      printf("Wrong number of arguments in call to localThreads!\n");
      return 1;
    }
  dmpfile = argv[1];
  osql = argv[2];
  threads = atoi(argv[3]);
  loops = atoi(argv[4]);
  fname = argv[5];
  threadcount = 0;
  printf("Testing %d threads accessing local db calling %s(%d);\n", threads, fname, loops);

#ifdef WIN32
  thread_array = malloc(threads * sizeof(int));
#else
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
  thread_array = malloc(threads * sizeof(pthread_t));
#endif
  a_initialize(dmpfile, FALSE); // Initialize embedded Amos
  a_extfunction("backgroundbf", backgroundbf);
  a_connect(conn, "", FALSE);
  a_execute(conn, s, osql, FALSE); // Load local amosql functions
  free_scan(s);
  free_connection(conn);

  for (i = 0; i < threads; ++i)
#ifdef WIN32
    if ((thread_array[threadcount] = _beginthread(myLocalThread, 0, (void *)i)) != -1)
#else
    if (pthread_create(&thread_array[threadcount], &attr, (void *)myLocalThread, (void *)i) == 0)
#endif
      {
	//printf("Initializing thread %d\n", i);
	++threadcount;
      }

#ifdef WIN32
  WaitForMultipleObjects(threadcount, (HANDLE *)thread_array, TRUE, INFINITE);
#else
  for (i = 0; i < threadcount; ++i)
    pthread_join(thread_array[i], NULL);
  pthread_attr_destroy(&attr);
#endif

  if (threadcount < threads)
    printf("WARNING! Meant to start %d threads. Only started %d!\n", threads, threadcount);
  free(thread_array);

  return 0;
}
