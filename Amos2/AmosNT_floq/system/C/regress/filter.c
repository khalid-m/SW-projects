/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Lars Melander, UDBL
 * $RCSfile: filter.c,v $
 * $Revision: 1.4 $ $Date: 2013/08/05 10:42:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Testing remote interface with scans
 * ===========================================================================
 * $Log: filter.c,v $
 * Revision 1.4  2013/08/05 10:42:14  larme597
 * *** empty log message ***
 *
 * Revision 1.3  2013/08/02 10:20:06  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2012/06/11 15:19:43  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2012/06/08 16:25:01  larme597
 * *** empty log message ***
 *
 ****************************************************************************/

#include <windows.h>
#include <process.h>

#include "callout.h"

unsigned __stdcall myFilterThread(void *n)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);
  double d;

  a_connect(conn, "FOO", FALSE);

  a_execute_custom(conn, s, "filter1();", "", FALSE);

  while (!a_eos(s))
    {
      //printf("<<Call #%d to ID in thread #%d before getRow\n", i, (int) count);
      a_getrow(s, tpl, FALSE);
      d = a_getdoubleelem(tpl, 0, FALSE);
      printf("<< %f\n", d); fflush(stdout);
      a_nextrow(s, FALSE);
    }

  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);

  return 0;
}

unsigned __stdcall myControlThread(void *n)
{
  dcl_connection(conn);
  dcl_scan(s);
  dcl_tuple(tpl);

  a_connect(conn, "FOO", FALSE);

  Sleep(10000);
  printf("set threshold() = 0;\n");
  a_execute(conn, s, "set threshold() = 0;", FALSE);
  Sleep(10000);
  printf("set threshold() = 0.5;\n");
  a_execute(conn, s, "set threshold() = 0.5;", FALSE);

  free_tuple(tpl);
  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);

  return 0;
}

int main(int argc, char **argv)
{
  char *dmpfile;
  dcl_connection(conn);
  dcl_scan(s);

  int filterThread;
  int controlThread;

  if (argc != 2)
    {
      printf("Wrong number of arguments in call to filter: %d!\n", argc);
      return 1;
    }
  dmpfile = argv[1];
  printf("Testing filter ...\n");

  a_initialize(dmpfile, FALSE); // Initialize embedded Amos

  a_connect(conn, "FOO", FALSE);

  a_execute(conn, s, "create function threshold() -> number as stored;", FALSE);
  a_execute(conn, s, "set threshold() = -1;", FALSE);

  a_execute(conn, s, "create function filter1() -> bag of number \
    as for each number x where x in sin(heartbeat(0.5)) \
      if x > threshold() then return x;", FALSE);

  //eval_forms(varstack, "(setq _batch_ t) (debugging t) (trace open-port-to print&read)");
  //eval_forms(varstack, "(trace-packets t) (trace open-query-scan)");

  filterThread = _beginthreadex(NULL, 0, myFilterThread, NULL, 0, NULL);
  controlThread = _beginthreadex(NULL, 0, myControlThread, NULL, 0, NULL);

  WaitForSingleObject((HANDLE) filterThread, INFINITE);
  CloseHandle((HANDLE) filterThread);
  WaitForSingleObject((HANDLE) controlThread, INFINITE);
  CloseHandle((HANDLE) controlThread);

  free_scan(s);
  a_disconnect(conn, FALSE);
  free_connection(conn);

  return 0;
}
