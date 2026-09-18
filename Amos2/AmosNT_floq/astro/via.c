/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Via
 * Language:     C
 * Location:     AmosNT/astro/front.c
 ****************************************************************************/

#include "amos.h"
#include "rp.h"
#include <stdio.h>
#include <math.h>
#include "numarray.h"
#include "fileaccess.h"
#include "storage.h"
#include "udpq.h"
#ifndef NT
#include "pipestream.h"
#include "pipemerge.h"
#endif

extern int CloseAllDescriptors();

oidtype stopsymbol;
oidtype emitsymbol;
oidtype eofsym;
int main(int argc,char **argv) {
  dcl_connection(c);
  dcl_scan(s);
  char *str;
  init_amos(argc,argv);
#ifndef NT
  register_pipestream();
  register_pipemerge();
#endif
  register_numarray();
  register_fileaccess();
  register_rp();
  register_udpq();
  init_priv_udpqs();
  a_connect(c,"",FALSE);

  /* Wait for subscribers */

  printf("Via starting with the following queues: ");
  a_print(globval(mksymbol("_sensor-ids_"))); fflush(stdout);

  call_lisp(mksymbol("gw-init"), varstack, 0);
  a_execute(c,s,"udp_start();",FALSE);

  call_lisp(mksymbol("gw-print-hash"), varstack, 0);

  /*
  {
    unwind_protect_begin;
    do {
      a_execute(c,s,"udpgw(streamof(get_all_udp_carrays()));",FALSE);
    } while (1);
    unwind_protect_catch;
    a_execute(c,s,"udp_stop();",FALSE);
    unwind_protect_end;
  }
  */
  amos_toploop("[scsq]");

	
  CloseAllDescriptors();
  free_scan(s);
  free_connection(c);
  return 0;
}

