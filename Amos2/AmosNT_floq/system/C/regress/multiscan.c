
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
  dcl_scan(s);
  dcl_tuple(tpl);
  int res;

  a_init_singlescan(s, (oidtype) ptr, FALSE);

  while (!a_eos(s))
    {
      a_getrow(s, tpl, FALSE);
      res = a_getintelem(tpl, 0, FALSE);
      printf("!Thread %d: %d\n", GetCurrentThreadId(), res); fflush(stdout);
      a_nextrow(s, FALSE);
    }
  printf("Stopping thread %d .. \n", GetCurrentThreadId()); fflush(stdout);

  free_tuple(tpl);
  free_scan(s);
  printf("<Thread %d\n", GetCurrentThreadId()); fflush(stdout);
  return 0;
}

int main(int argc, char **argv)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
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
  //eval_forms(varstack, "(setq _batch_ t) (debugging t) (trace open-port-to print&read)");
  //eval_forms(varstack, "(trace-packets t)");
  //eval_forms(varstack, "(debugging t)");

  a_connect(conn, "FOO", FALSE);

  threads = 2;
  thread_array = malloc(threads * sizeof(int));
  a_execute(conn, s, "create function twostream(Number l, number u) \
    -> Vector of Stream of Number \
    as {diota(0.5,l,u),diota(1,10*l,10*l+u)};", FALSE);
  a_openmultiscan_custom(conn, s, "twostream(1, 5);", "(:timeout 0.1)", FALSE);
  a_getrow(s, tpl, FALSE);

  for (i = 0; i < threads; ++i)
    {
      thread_array[i] = _beginthreadex(NULL, 0, multiScanThread,
				       (void *) a_getelem(tpl, i, FALSE), 0, NULL);
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
