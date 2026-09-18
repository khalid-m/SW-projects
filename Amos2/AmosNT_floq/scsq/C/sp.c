/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Preparator node code: An Amos driver that executes sproc(tcp).
 * Language:     C
 * Location:     AmosNT/astro/prep.c
 ****************************************************************************/

#include "amos.h"
#include <stdio.h>
#include <math.h>
#include "comm.h"
#include "fileaccess.h"
#include "bgcommon.h"
#include "sproc.h"
#include "port.h"
#include "numarray.h"
#include "a_fft.h"
#include "udpq.h"
#ifndef NT
#include "pipestream.h"
#include "pipemerge.h"
#endif

//#define DEBUG
//#define PROFILE 

#define prlen 100
char prstr[prlen];

void register_mpi_functions(void);

int main(int argc,char **argv) {
  oidtype profres = nil;
  char *str;
  dcl_connection(c);
  init_amos(argc,argv);
  register_fileaccess();
	register_port();
	register_numarray();
	register_fft();
	register_udpq();
#ifndef NT
  register_pipestream();
  register_pipemerge();
#endif
  register_bgcommon();
	register_sproc();
  register_mpi_functions();
  register_twinagg();
  register_mathfns();
  a_connect(c,"",FALSE);
  IntoString(globval(mksymbol("_amosid_")), str, varstack);
  strncpy(prstr,str,prlen);
  printf("prep[%s]: ",prstr);
  eval_forms(varstack, "(print-timeval (gettimeofday))");
  { unwind_protect_begin;
#ifdef PROFILE
  call_lisp(mksymbol("start-profile"), varstack, 0);
#endif
#ifdef DEBUG
  printf("prep[%s]: (start-preparator) ...\n",prstr); fflush(stdout);
#endif
  /* Tell coord about my listen sock */
  call_lisp(mksymbol("start-preparator"), varstack, 0);

#ifdef DEBUG
  printf("prep[%s]: while(sproc(TCPPROTOCOL)) ...\n", prstr);
	fflush(stdout);
#endif
  sproc(TCPPROTOCOL);
#ifdef PROFILE
    a_setf(profres, call_lisp(mksymbol("profile"), varstack, 0));
	printf("prep[%s]: profiler\n", prstr);
	a_print(profres);
	fflush(stdout);
#endif
#ifdef DEBUG
	printf("prep[%s]: Restarting prep main loop\n", prstr); fflush(stdout);
#endif
	
  unwind_protect_catch;
#ifdef DEBUG
  /*  amos_toploop("[prep@PC]");*/
#endif
  /*		if(DEBUG) {
		printf("prep(");
		a_print(globval(mksymbol("_amosid_")));
		printf(") reaching catch region\n");
		fflush(stdout);
		}*/
  unwind_protect_end;
  }
  CloseAllDescriptors();
  free_connection(c);
  return 0;
}

/* 
MPI functions are defined dummy on non-MPI platforms.
If they are not defined at all, Amos will beleive that 
the functions is not defined on any other nodes either
and generate errors as a result.
*/
void mpi_mergebbff(a_callcontext cxt, a_tuple params) {
}

void mpi_smergebf(a_callcontext cxt, a_tuple params) {
}

oidtype mpi_revalfn(bindtype env, oidtype form, oidtype nodenum) {
  oidtype rd = nil;
  return rd;
}

oidtype mpi_sendfn(bindtype env, oidtype form, oidtype nodenum) {
  oidtype rd = nil;
  return rd;
}

oidtype open_mpifn(bindtype env, oidtype peer, oidtype tag, oidtype bufsize) {
  oidtype rd = nil;
  return rd;
}

void register_mpi_functions(void) {
  a_extfunction("MERGEBBFF",mpi_mergebbff);
  a_extfunction("SMERGEBF",mpi_smergebf);
  extfunction2("mpi-reval", mpi_revalfn);
  extfunction2("mpi-send-form", mpi_sendfn);
  extfunction3("open-mpi", open_mpifn);
}
