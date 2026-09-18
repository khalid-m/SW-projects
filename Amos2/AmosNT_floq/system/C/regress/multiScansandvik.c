
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

unsigned __stdcall validateMillThread(void *ptr)
{
  oidtype b = (oidtype) ptr;
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  oidtype o;

  a_connect(conn, "svali", FALSE);
  a_openstream_custom(conn, s, b, "(:timeout 0.1)", FALSE);

  while (!a_eos(s))
    {
      a_getrow(s, tpl, FALSE);
      o = a_getelem(tpl, 0, FALSE);
      printf("!validateMill: ");
      a_print(o);
      a_nextrow(s, FALSE);
    }
  printf("Stopping thread validateMill .. \n");

  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);
  printf("<Thread validateMill\n");
  return 0;
}

unsigned __stdcall millAlertThread(void *ptr)
{
  oidtype b = (oidtype) ptr;
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  oidtype o;

  a_connect(conn, "svali", FALSE);
  a_openstream_custom(conn, s, b, "(:timeout 0.1)", FALSE);

  while (!a_eos(s))
    {
      a_getrow(s, tpl, FALSE);
      o = a_getelem(tpl, 0, FALSE);
      printf("!millAlert: ");
      a_print(o);
      a_nextrow(s, FALSE);
    }
  printf("Stopping thread millAlert .. \n");

  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);
  printf("<Thread millAlert\n");
  return 0;
}

int main(int argc, char **argv)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  oidtype o;
  char *dmpfile;
  int validateMill;
  int millAlert;

  if (argc != 2)
    {
      printf("Wrong number of arguments in call to localThreads!\n");
      return 1;
    }
  dmpfile = argv[1];

  a_initialize(dmpfile, FALSE); // Initialize embedded Amos
  //eval_forms(varstack, "(setq _batch_ t) (debugging t) (trace open-port-to print&read)");
  //eval_forms(varstack, "(trace-packets t)");
  //eval_forms(varstack, "(debugging t)");

  a_connect(conn, "SVALI", FALSE);

  a_execute(conn, s, "validateStreams(\"A\");", FALSE);
  a_getrow(s, tpl, FALSE);
  o = a_getelem(tpl, 0, FALSE);

  validateMill = _beginthreadex(NULL, 0, validateMillThread, (void *) a_elt(o, 0), 0, NULL);
  millAlert = _beginthreadex(NULL, 0, millAlertThread, (void *) a_elt(o, 1), 0, NULL);

  WaitForSingleObject((HANDLE) validateMillThread, INFINITE);
  CloseHandle((HANDLE) validateMillThread);
  WaitForSingleObject((HANDLE) millAlertThread, INFINITE);
  CloseHandle((HANDLE) millAlertThread);

  printf("Finished!\n"); fflush(stdout);
  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);

  return 0;
}
