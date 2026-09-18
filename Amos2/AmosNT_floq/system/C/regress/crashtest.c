/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Lars Melander, UDBL
 * $RCSfile: crashtest.c,v $
 * $Revision: 1.1 $ $Date: 2010/06/23 17:53:28 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Lisp function that tries to call system from background
 *              coroutine.
 * ===========================================================================
 * $Log: crashtest.c,v $
 * Revision 1.1  2010/06/23 17:53:28  larme597
 * Testing coroutine background check for Linux.
 *
 ****************************************************************************/

#include "alisp.h"

extern void co_enterbg0();
extern void co_leavebg0();

oidtype coroutine_crashfn(bindtype env)
{
  dcl_connection(conn);
  dcl_scan(s);

  co_enterbg0();

  a_connect(conn, "", FALSE);
  a_execute(conn, s, ";", FALSE); // Should crash here

  co_leavebg0();

  free_scan(s);
  free_connection(conn);

  return nil;
}

int main(int argc, char **argv)
{
  dcl_connection(conn);
  dcl_scan(s);
  char *dmpfile, *osql;

  if (argc != 3)
    {
      printf("Wrong number of arguments in call to crashtest!\n");
      return 1;
    }
  dmpfile = argv[1];
  osql = argv[2];

  a_initialize(dmpfile, FALSE);
  extfunction0("coroutine-crash", coroutine_crashfn);

  a_connect(conn, "", FALSE);
  a_execute(conn, s, osql, FALSE); // Load lsp test
  free_scan(s);
  free_connection(conn);

  return 0;
}
