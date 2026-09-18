/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  Time window aggregation
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"
#include "a_time.h"
#include "twinagg.h"
#include <stdio.h>

#define TWINAGGBUFSIZ 10

//#define DEBUG
//#define TRACE_PACKET
//#define DEBUG_REALLOC

int compare_tv(const struct timeval* tv1, const struct timeval* tv2) {
  int cmp;
  cmp = COMPARE(tv1->tv_sec,tv2->tv_sec);
  if(cmp) return cmp;
  return COMPARE(tv1->tv_usec,tv2->tv_usec);
}


/* =========================================================================================================== */
oidtype twinaggbf_mapper(a_callcontext cxt, int width, oidtype *restpl, void *xa) {
  struct twinaggstate *state;
  oidtype tpl = a_resultarray(width, restpl);
  bindtype env = cxt->env;

  state = (struct twinaggstate*)xa;
	
  /* Add element to buffer */
#ifdef TRACE_PACKET
  printf("incoming: "); a_prin1(tpl, stdoutstream, FALSE); fflush(stdout);
#endif
  a_setf(state->buf[state->bufpos], tpl);
  state->count++;
  twin_get_timestamp(&state->now, state->buf[state->bufpos]);
#ifdef TRACE_PACKET
  printf("; ts "); printf("%f\n", (double)state->now.tv_sec+(double)state->now.tv_usec/1.0e6);
  fflush(stdout);
#endif
	
  if(state->firsttime) {
    state->tstart.tv_sec  = state->now.tv_sec;
    state->tstart.tv_usec = state->now.tv_usec;
    add_duration(&state->tend,&state->tstart,state->winlength);
    state->firsttime=0;
  }
	
  if(-1 == state->bufstart) {
    if(compare_tv(&state->now,&state->tstart) >= 0) {
      state->bufstart = 0;
    }
  }
	
  // Can we emit a window, i.e., is *state->now* beyond state->tend?
  while(compare_tv(&state->now,&state->tend) >= 0) {
    twin_emit(state);
    twin_set_ends(state, &state->now);
  }

  if (state->bufstart != -1) { // -1: We still wait for an element to start the window
    state->bufpos++;
  }
  if (state->bufpos == state->bufsize) { // Cyclic buffer!
    state->bufpos = 0;
  }
  if (state->bufpos == state->bufstart) { // Buffer has filled up. Need more space.
    twin_realloc_buf(state);
  }
  return nil;
}

/* =========================================================================================================== */


void twin_get_timestamp(struct timeval* t, oidtype timestamped) {
	oidtype tmp;
	if (timestamped==nil) printf("NILt\n"); fflush(stdout);
  tmp = a_elt(a_elt(timestamped, 0),0);
  t->tv_sec  = gettimeval(tmp).tv_sec;
  t->tv_usec = gettimeval(tmp).tv_usec;
}

void twin_realloc_buf(struct twinaggstate* state) {
  int newbufsize = 2*state->bufsize;
  oidtype* newbuf = NULL;
  int i,j=0;
		
#ifdef DEBUG_REALLOC
  printf("Realloc: ");
#endif
  /* Buffer is full => allocate a bigger one */
  newbuf = (oidtype*)malloc(newbufsize*sizeof(oidtype));
  for (i=0; i<newbufsize; i++) {
    newbuf[i] = nil;
  }
	
  for (i=state->bufstart; i<state->bufsize; i++) {
    newbuf[j++] = state->buf[i];
  }
  for (i=0; i<state->bufpos; i++) {
    newbuf[j++] = state->buf[i];
  }
	
#ifdef DEBUG_REALLOC
  printf("newbuf: ");
  for (i=0; i<newbufsize; i++) {
    a_prin1(newbuf[i], stdoutstream, FALSE); printf(" "); fflush(stdout);
  }
#endif
	
  free(state->buf);
  state->buf = newbuf;
  state->bufstart = 0;
  state->bufsize = newbufsize;
  state->bufpos = j;
#ifdef DEBUG_REALLOC
  printf("bufsize %d, bufpos %d\n", state->bufsize, state->bufpos); fflush(stdout);
#endif
}

void twin_emit(struct twinaggstate* state) {
  oidtype em, timestamps = nil;
	oidtype concat = nil;
  int i, j=0;

  if (state->bufstart > state->bufpos) {
    em = new_array(state->bufpos + state->bufsize - state->bufstart, nil);
	} else {
    em = new_array(state->bufpos - state->bufstart, nil);
	}

	timestamps = new_array(2,nil);
	concat = new_array(2,nil);
	a_seta(timestamps,0,mktimeval(state->tstart.tv_sec,state->tstart.tv_usec));
	a_seta(timestamps,1,mktimeval(state->tend.tv_sec,state->tend.tv_usec));

  if (state->bufstart > state->bufpos) {
    for (i=state->bufstart; i<state->bufsize; i++) {
			if (state->buf[i]==nil) printf("NIL1"); fflush(stdout);
      a_seta(em,j++,a_elt(state->buf[i],0));
    }
    for (i=0; i<state->bufpos; i++) {
			if (state->buf[i]==nil) printf("NIL2"); fflush(stdout);
      a_seta(em,j++,a_elt(state->buf[i],0));
    }
  } else {
    for (i=state->bufstart; i<state->bufpos; i++) {
      if (state->buf[i]==nil) printf("NIL3"); fflush(stdout);
			a_seta(em,j++,a_elt(state->buf[i],0));
    }
  }
	a_seta(concat,0,timestamps);
	a_seta(concat,1,em);
  a_setobjectelem(state->params, 5, concat, FALSE);

	if (a_arraysize(em) == 0) {
		if (!state->emit_empty_intervals) {
			return;
		}
	}
  a_emit(state->cxt, state->params, FALSE);
}


void twin_set_ends(struct twinaggstate* state, struct timeval *now) {
  struct timeval probe;
  int i;
	
  /* After emit: Set new end points */
  add_duration2(&state->tstart,state->stride);
  add_duration2(&state->tend,state->stride);
#ifdef DEBUG
  printf("twin_set_ends: tstart= %d.%d ; tend= %d.%d ; ",
	 state->tstart.tv_sec,state->tstart.tv_usec,
	 state->tend.tv_sec,state->tend.tv_usec);
  printf("now= %f\n", (double)now->tv_sec+(double)now->tv_usec/1.0e6);
  fflush(stdout);
#endif
	
  /* Sampling window => next tstart might be after now */
  if (compare_tv(now, &state->tstart) < 0) {
    state->bufstart = -1;
    state->bufpos = 0;
#ifdef DEBUG
    printf("twin_set_ends: time of next state->bufstart is beyond last incoming elem. \n");
#endif
    return;
  }
	
  /* Next tuple is exactly on the limit */
  /*if(compare_tv(now, &state->tstart) == 0) {
    state->bufstart = state->bufpos;
  }*/
	/* Linear Scan through buffer to find next bufstart */
  for (i=state->bufstart; i<state->bufsize; i++) {
    twin_get_timestamp(&probe, state->buf[i]);
#ifdef DEBUG
    printf("twin_set_ends: %f#%d ", (double)probe.tv_sec+(double)probe.tv_usec/1.0e6,i);
#endif
    if(compare_tv(&probe, &state->tstart) >= 0) {
      state->bufstart = i;
#ifdef DEBUG
      printf("twin_set_ends: NEW state->bufstart=%d\n", state->bufstart);
#endif
      return;
    }
  }
  for (i=0; i<state->bufpos; i++) {
    twin_get_timestamp(&probe, state->buf[i]);
#ifdef DEBUG
    printf("twin_set_ends: %f#%d ", (double)probe.tv_sec+(double)probe.tv_usec/1.0e6, i);
#endif
    if(compare_tv(&probe, &state->tstart) >= 0) {
      state->bufstart = i;
#ifdef DEBUG
      printf("twin_set_ends: NEW state->bufstart=%d (looped)\n", state->bufstart);
#endif
      return;
    }
  }
  state->bufstart = state->bufpos;
#ifdef DEBUG
  printf("twin_set_ends: NEW state->bufstart=%d\n", state->bufstart);
#endif
}

void twinaggbf(a_callcontext cxt, a_tuple params) {
  struct twinaggstate state;
  int i;
  oidtype bag = a_getelem(params, 0, FALSE);
	
  state.vsymb     = mksymbol("value");
  state.winlength = a_getdoubleelem(params, 1, FALSE);
  state.stride    = a_getdoubleelem(params, 2, FALSE);
  state.emit_empty_intervals = a_getintelem(params, 3, FALSE);
  state.emit_tail = a_getintelem(params, 4, FALSE);
  state.bufpos    = 0;
  state.firsttime = 1;
  state.bufsize   = TWINAGGBUFSIZ;
  state.bufstart  = 0;
  state.bufpos    = 0;
  state.count     = 0;
	
  {
    /* unwind_protect_{begin|catch (is ALWAYS executed)|end} */
    unwind_protect_begin;
    state.params=params;
    state.cxt=cxt;
    state.buf=(oidtype*)malloc((state.bufsize)*sizeof(oidtype));
    for(i=0; i<state.bufsize; i++) {
      state.buf[i]=nil;
    }
    a_mapbag(cxt, bag, twinaggbf_mapper, (void*)&state);
    /* Emit remaining non-emitted tuples */
    if(state.bufstart >= 0) {
#ifdef DEBUG
			printf("Emitting remaining elements\n");
			printf("state.now %f ", (double)state.now.tv_sec+(double)state.now.tv_usec/1.0e6);
			printf("tstart %f\n ", (double)state.tstart.tv_sec+(double)state.tstart.tv_usec/1.0e6);
#endif
			twin_emit(&state);
			twin_set_ends(&state, &state.now);
			if(state.emit_tail) {
				while(compare_tv(&state.now,&state.tstart) >= 0) {
					twin_emit(&state);
					twin_set_ends(&state, &state.now);
				}
			}
    }
		
    unwind_protect_catch;
    /*    if (unwind_reset)
	  fprintf(stderr, "Oops -- unwind reset in twinagg\n");*/
    for(i=0; i<state.bufsize; i++) {
      a_free(state.buf[i]);
    }
    free(state.buf);
    unwind_protect_end;
  }
}

oidtype tsamapper(a_callcontext cxt, int width, oidtype *restpl, void *xa) {
  struct twinaggstate *state;
  oidtype em;
  struct timeval now;
  oidtype tpl = a_resultarray(width, restpl);
  bindtype env = cxt->env;

  state = (struct twinaggstate*)xa;
  state->count++;

  printf("mapfcn: tpl= "); fflush(stdout);
  a_print(tpl); fflush(stdout);
  twin_get_timestamp(&now,tpl);
  printf("; ts "); printf("%f\n", (double)now.tv_sec+(double)now.tv_usec/1.0e6);
  em = mkinteger(state->count);
  a_setobjectelem(state->params, 4, em, FALSE);
  a_emit(state->cxt, state->params, FALSE);
  return nil;
}

void tsattrbf(a_callcontext cxt, a_tuple params) {
  struct twinaggstate state;
  oidtype o = nil;
  oidtype bag = a_getelem(params, 0, FALSE);
  state.params = params;
  state.cxt = cxt;

  state.count=0;

  printf("getelem: ");
  a_setf(o,a_getelem(params, 0, FALSE));
  a_print(o);
  a_mapbag(cxt, bag, tsamapper, (void*)&state);
}

void register_twinagg(void) {
  a_extfunction("TWINAGGBF",twinaggbf);
  a_extfunction("TSATTR",tsattrbf);
}
