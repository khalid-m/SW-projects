/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 * $RCSfile: winagg.c,v $
 * $Revision: 1.7 $ $Date: 2014/01/12 20:32:25 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Window aggregation functions
 * ===========================================================================
 * $Log: winagg.c,v $
 * Revision 1.7  2014/01/12 20:32:25  torer
 * Missing {..}
 *
 * Revision 1.6  2014/01/12 16:28:24  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.5  2010/12/26 17:10:29  torer
 * 1. Not using a_global_callcontext
 * 2. Mappers now return oidtype
 *
 * Revision 1.4  2010/06/09 09:27:43  chexu484
 * *** empty log message ***
 *
 * Revision 1.3  2007/11/07 15:14:50  torer
 * Amos II version 10 with faster basic OjectLog interface to C
 * Aggregation operators can now be defined in C
 *
 ****************************************************************************/

#include "amos.h"
#include <stdio.h>

struct winaggstate {
  int bufsize;
  int bufpos;
  int step;
  int steppos;
  int emit_flag;
  oidtype* buf;
  a_callcontext cxt;
};

oidtype winaggbf_mapper(a_callcontext cxt, int arity, oidtype *tpl, void *xa) {
  struct winaggstate *state;
  oidtype em;
  int i,j;
  state = (struct winaggstate*)xa;

  /* Add element to buffer */
  a_setf(state->buf[state->bufpos], *tpl);

  state->bufpos++;
  state->steppos++;

  if (state->bufpos == state->bufsize) {
    state->bufpos=0;
    state->emit_flag=TRUE;  
  }

  if (state->steppos == state->step) {
    state->steppos=0;
    if (state->emit_flag==TRUE) {
      em = new_array(state->bufsize, nil);
      j=0;
      for (i=state->bufpos; i<state->bufsize; i++) {
		  a_seta(em,j++,state->buf[i]);
      }
      for (i=0; i<state->bufpos; i++) {
		  a_seta(em,j++,state->buf[i]);
      }

      a_bind(state->cxt, 4, em);
      a_result(state->cxt);
    }
  }
  return nil;
}

oidtype winaggbf(a_callcontext cxt) {
  struct winaggstate state;
  int i;
  oidtype bag = a_arg(cxt, 1);
  oidtype bufsize = a_arg(cxt, 2);
  oidtype step = a_arg(cxt, 3);

  IntoInteger(bufsize,state.bufsize, a_env(cxt));
  IntoInteger(step,state.step, a_env(cxt));
  state.steppos=0;
  state.bufpos=0;
  state.emit_flag=FALSE;


  {
    state.cxt=cxt;
    state.buf=(oidtype*)malloc((state.bufsize)*sizeof(oidtype));
    for(i=0; i<state.bufsize; i++) {
      state.buf[i]=nil;
    }
    {unwind_protect_begin;
    a_mapbag(cxt, bag, winaggbf_mapper, (void*)&state);
    unwind_protect_catch;
    /*    if (unwind_reset)
	  fprintf(stderr, "Oops -- unwind reset in winagg\n");*/
    for(i=0; i<state.bufsize; i++) {
      a_free(state.buf[i]);
    }
    free(state.buf);
    unwind_protect_end;}
    return nil;
  }
}

void register_winagg(void) {
    a_extimpl("WINAGGBF",winaggbf);
}
