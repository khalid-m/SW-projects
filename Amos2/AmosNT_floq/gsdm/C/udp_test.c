/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1997 Tore Risch, EDSLAB
 * $RCSfile: udp_test.c,v $
 * $Revision: 1.8 $ $Date: 2005/12/19 13:45:41 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 driver program
 ****************************************************************************/

#include "../../C/callin.h"
#include "../../C/callout.h"

#include "udp_common.h"
#include "udp_streams.h"
#include "udp_radiosource.h"
#include "udp_producer.h"

#ifndef BROADCASTER_IS_DAEMON


int main(int argc,char **argv)
{ 
  char tmp;

  dcl_connection(c);
  dcl_scan(s);
  init_amos(argc,argv);
    
  printf("Registering udp streams functions...\n");
  udp_register_stream_functions();
  
  printf("Registering udp radio-source functions...\n");
  udp_register_radiosource_functions();

  printf("Registering udp producer functions...\n");
  udp_register_producer_functions();

  fflush(stdout);
  fflush(stdin);
  a_connect(c,"",FALSE);
  amos_toploop("Amos");
  return 0;
}

#endif








