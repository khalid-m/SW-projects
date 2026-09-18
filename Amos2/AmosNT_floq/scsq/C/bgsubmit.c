/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, Tore Risch, UDBL
 *
 * Description:  BGSubmit submits queries to BlueGene
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include <stdio.h>
#include "comm.h"
#include "amos.h"
#include "bgcommon.h"

/* #define DEBUG */

/* This variable is set (=1) when bgsubmitbf is entered 
   -- and reset (=0) when bgsubmitbf finishes. 
   bgsubmitbfd cannot execute if we are already inside bgsubmitbf
   (nesting is not allowed). */
int inside_bgsubmitbf;
int inside_bgsubmitbf_errcode;

void bgsubmitbf(a_callcontext cxt, a_tuple params) {
  /* Submit AmosQL query to be run by SCSQ on BG node */
  oidtype eofsym = nil;
  oidtype readsock = nil;
  oidtype r = nil, temp = nil;
  int ressz, i;
  if (nil == eofsym) {
    a_setf(eofsym, mksymbol("EOF"));
  }

  a_setf(globval(mksymbol("_currentquery_")), a_getelem(params, 0, FALSE));

  a_message("[Opening response socket ... "); fflush(stdout);
  call_lisp(mksymbol("open-fls"),cxt->env,0);
  a_message("OK]\n");
  a_message("[Saving state ... "); fflush(stdout);
  call_lisp(mksymbol("save-bgstate"),cxt->env,0);
  a_message("OK]\n");
  a_message("[Submitting to BG ... ");
  get_varstring(cxt->env,"bghome"); // check if bound
  get_varstring(cxt->env,"bghostid"); // check if bound
  if(system(get_varstring(cxt->env,"bgsubmission")))  {
    a_message("Submission failed!\n");
    inside_bgsubmitbf=0;
    return;
  }
  a_message("OK]\n");

#ifdef DEBUG
  printf("Listening on _front-listen-sock_=");
  a_print(globval(mksymbol("_front-listen-sock_")));
#endif
  a_message("[Waiting for result ... ");

  while(readsock == nil) {
    a_setf(readsock, call_lisp(mksymbol("accept-socket"),cxt->env, 2, 
			       globval(mksymbol("_front-listen-sock_")), mksymbol("1")));
    printf(".");
    fflush(stdout);
  }
  a_message("OK]\n");
  {
    unwind_protect_begin;
    while(1) {
      CheckInterrupt;
      a_setf(r, readfn(cxt->env,readsock));
      if(r == eofsym) {
	printfn(cxt->env, eofsym, readsock);
	flushfn(cxt->env,readsock);
	close_socketfn(cxt->env,readsock);
	a_free(readsock);
	a_free(r);
	return;
      }
      temp = is_errorfn(cxt->env,r);
      if(temp!=nil) { 
	inside_bgsubmitbf=0;
	call_lisp(mksymbol("errcond-raise-error"),cxt->env,2,
		  temp, mksymbol("from-bg")); //will longjmp
      }
      ressz = a_arraysize(r);
      for(i=0;i<ressz;i++)
	a_setelem(params, i+1, a_elt(r,i));
      a_emit(cxt, params, FALSE);
    }
    unwind_protect_catch;
    printf("unwind_protect_catch\n");
    fflush(stdout);
    /* TCP will kill the BG when sock is closed */
    close_socketfn(cxt->env,readsock);
    a_free(readsock);
    a_free(r);
    unwind_protect_end;
  }
}

void register_bgsubmit(void) {
  a_extfunction("BGSUBMITBF",bgsubmitbf);
  inside_bgsubmitbf_errcode = a_register_error("Already inside bg() call");
}
