
#ifdef WIN32
#include <windows.h>
#include <process.h>
#else
#ifndef _MULTI_THREADED
#define _MULTI_THREADED
#endif
#include <pthread.h>
#endif

#include "scsq.h"

unsigned __stdcall multiScanThread(void *ptr)
{
  oidtype b = (oidtype) ptr;
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  oidtype res;

  a_connect(conn, "debs", FALSE);
  a_openstream_custom(conn, s, b, "(:timeout 0.1)", FALSE);

  while (!a_eos(s))
    {
      a_getrow(s, tpl, FALSE);
      res = a_getelem(tpl, 0, FALSE);
      printf("!Thread %d: ", GetCurrentThreadId());
      a_print(res);
      a_nextrow(s, FALSE);
    }
  printf("Stopping thread %d .. \n", GetCurrentThreadId()); fflush(stdout);

  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);
  printf("<Thread %d\n", GetCurrentThreadId()); fflush(stdout);
  return 0;
}

int main(int argc, char **argv)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  oidtype o;
  char *dmpfile;
  int i;
  int threads;
  int *thread_array;

  if (argc != 2)
    {
      printf("Wrong number of arguments in call to multiScan!\n");
      return 1;
    }
  dmpfile = argv[1];
  printf("Test threads accessing remote db;\n");

  scsq_initialize(dmpfile, FALSE); // Initialize embedded Amos
  eval_forms(varstack, "(setq _batch_ t) (debugging t) (trace open-port-to print&read)");
  eval_forms(varstack, "(trace-packets t)");
  eval_forms(varstack, "(debugging t)");

  a_connect(conn, "debs", FALSE);
  //eval_forms(varstack, "(socket-send '(debugging t) (open-socket-to 'debs))");
  eval_forms(varstack, "(socket-send '(trace-packets t) (open-socket-to 'debs))");
  printf("1\n"); fflush(stdout);
  threads = 4;
  thread_array = malloc(threads * sizeof(int));
  //a_execute(conn, s, "simple_test('../data/full-game');", FALSE);
  a_execute(conn, s, "test_possession_vector('../data/full-game');", FALSE);
  printf("2\n"); fflush(stdout);
  a_getrow(s, tpl, FALSE);
  printf("3\n"); fflush(stdout);
  o = a_getelem(tpl, 0, FALSE);
  a_print(o);

  for (i = 0; i < threads; ++i)
    {
      thread_array[i] = _beginthreadex(NULL, 0, multiScanThread,
				       (void *) a_elt(o, i), 0, NULL);
    }

  for (i = 0; i < threads; ++i)
    {
      WaitForSingleObject((HANDLE) thread_array[i], INFINITE);
      CloseHandle((HANDLE) thread_array[i]);
    }

  printf("Finished!\n"); fflush(stdout);
  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);
  free(thread_array);

  return 0;
}
