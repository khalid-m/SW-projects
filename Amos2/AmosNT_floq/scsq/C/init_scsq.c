/*****************************************************************************
* AMOS2
*
* Author: (c) 2005 Erik Zeitler, UDBL
*
* Description:  Initialization of SCSQ
* Language:     C
* Location:     AmosNT/scsq/C/init_scsq.c
****************************************************************************/

#include <stdio.h>
#include <math.h>
#include "storage.h"
#include "callout.h"
#include "comm.h"
#include "amos.h"
#include "bgsubmit.h"
#include "numarray.h"
#include "fileaccess.h"
#include "bgcommon.h"
#include "twinagg.h"
#include "port.h"
#include "a_fft.h"
#include "udp_src.h"
#include "udpq.h"
#include "lofardata.h"
#include "extract.h"
#include "bgextract.h"
#include "sproc.h"
#include "mathfns.h"
#include "swin.h"
#include "bitwise.h"
#ifndef NT
#include "pipestream.h"
#include "pipemerge.h"
#include "fork.h"
#endif
#ifdef NT
#include "Winsock2.h"
#endif

EXTERN int delay_emit;
EXTERN int materialized_remote_scan;

oidtype stopsymbol;
oidtype emitsymbol;
oidtype eofsym;

void init_scsq_functions() {
	register_twinagg();
	register_bgsubmit();
	register_fileaccess();
	register_extract();
	register_bgextract();

#ifndef NT
	register_fork();
	register_pipestream();
	register_pipemerge();
#endif
	register_port();
	register_bgcommon();
	register_scsq_functions();
	register_numarray();
	register_multina();
	register_lrmultiply();
	register_fft();
	register_udp_packet_functions();
	register_udpq();
	register_lofardata();
	register_mathfns();

    register_swincell();
    register_swinfns();    
    register_bitwise();

    materialized_remote_scan = FALSE;
}

int scsq_initialize(char *path, int catcherror) {
  int error;

  if ((error = a_initialize(path, catcherror)) == 0)
    init_scsq_functions();

  return error;
}

int init_scsq(int argc,char **argv) { 
	dcl_connection(c);
	delay_emit = FALSE;
	init_amos(argc,argv);
	init_scsq_functions();

	return 0;
}
