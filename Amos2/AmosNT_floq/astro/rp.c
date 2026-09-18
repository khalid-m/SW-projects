/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 *
 * Description:  rp: Running Processor
 * Language:		 C
 * Location:		 AmosNT/astro/rp.c
 ****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "amos.h"
#include "comm.h"
#include "rp.h"
#include "udpq.h"
#include <stdio.h>
#include "storagetypes.h"

//#define DEBUG
//#define TRACE_PACKET
//#define PRINTSTAT

#ifndef max
#define max(a,b) ( (a) > (b) ? a : b)
#endif
#ifndef min
#define min(a,b) ( (a) < (b) ? a : b)
#endif

struct sensorstate {
  int stop_flag, pos;
  struct sockaddr_in id;
  double lastpoll;
};

struct gwstate {
  int n_sensors, cont_period, stop;
  a_callcontext cxt;
  a_tuple params;
  struct sensorstate* s;
};

int getoutbox(const struct gwstate* gws, const struct sockaddr_in *sensorid) {
  int i;
  for (i=0; i<gws->n_sensors; i++) {
    if (gws->s[i].id.sin_addr.s_addr == sensorid->sin_addr.s_addr) {
      return i;
    }
  }
  return -1; // No matching outbox
}

oidtype stopsymbol=nil;
oidtype emitsymbol=nil;
oidtype eofsym=nil;
oidtype gw_subscribers=nil;
oidtype gw_poll=nil;
oidtype gw_add=nil;
oidtype sensor_ids=nil;

void sensorgw_mapper(bindtype env, oidtype tpl, void *xa) {
  int outbox;
  struct gwstate *state;
  struct sockaddr_in from;
  oidtype socklist, sensor_id;
  state = (struct gwstate *)xa;

  sensor_id = a_elt(a_elt(tpl,0),0);
#ifdef TRACE_PACKET
  printf("sensor id="); a_print(sensor_id); fflush(stdout);
#endif

  from.sin_addr.s_addr = inet_addr(getstring(sensor_id));
  outbox = getoutbox(state, &from);
  if (-1 == outbox) {
    a_error(unknown_sensor_host,sensor_id,FALSE);
    return;
  }

  if (state->s[outbox].pos == 0) {
    if (run_time() > state->s[outbox].lastpoll + 2.0) {
#ifdef DEBUG
      printf("retrieving %d from coo\n", outbox);
      fflush(stdout);
#endif
      call_lisp(gw_add, env, 1, sensor_id);
      state->s[outbox].lastpoll = run_time();
    }

#ifdef DEBUG
    printf("poll %d\n", outbox);
    fflush(stdout);
#endif
    call_lisp(gw_poll, env, 1, sensor_id);
  }

  for(socklist=call_lisp(mksymbol("gethash"), env, 2, sensor_id, globval(gw_subscribers)); a_length(socklist)!=0; socklist=tl(socklist)) {
    printfn(env, a_elt(a_elt(tpl,0),1), hd(socklist));
  }
  state->s[outbox].pos++;

  /* flush */
  if (state->s[outbox].pos == state->cont_period) {
    state->s[outbox].pos = 0;
    for(socklist=call_lisp(mksymbol("gethash"), env, 2, sensor_id, globval(gw_subscribers)); a_length(socklist)!=0; socklist=tl(socklist)) {
      flushfn(env, hd(socklist));
    }
  }
}

void udpgw(a_callcontext cxt, a_tuple params) {
  struct gwstate state;
  int j=0;
  clock_t sl_startc;
  oidtype q;
  oidtype rd = a_getelem(params, 0, FALSE);
  struct hostent *pp;
  struct sockaddr_in *idp;

  stopsymbol = mksymbol("stop");
  emitsymbol = mksymbol("emit");
  eofsym  = mksymbol("eof");
  gw_subscribers = mksymbol("_gw-subscribers_");
  gw_poll = mksymbol("gw-poll");
  gw_add = mksymbol("gw-add");
  sensor_ids = mksymbol("_sensor-ids_");

  state.cont_period = getinteger(globval(mksymbol("_continuation-period_")));
  state.n_sensors = a_length(globval(sensor_ids));
  state.s=malloc(state.n_sensors*sizeof(int));
  state.stop = 0;
  for (q=globval(sensor_ids); q!=nil; q=tl(q)) {

    /*
      pp = gethostbyname(getstring(hd(q)));
      a_print(hd(q));
      if (pp == NULL) {
      a_error(unknown_host,hd(q),FALSE); // leak!
      return;
      }
      idp = &(state.s[j].id);
      memcpy((char *)&(idp->sin_addr),(char *)pp->h_addr,pp->h_length);
      strncpy((char*)&(state.s[j].id), getstring(hd(q)), sizeof(state.s[j].id));
    */

    memset(&(state.s[j].id.sin_zero), '\0', 8);  // zero the rest of the struct
    state.s[j].id.sin_family = AF_INET;
    state.s[j].id.sin_port = htons(UDP_SENSORPORT);
    state.s[j].id.sin_addr.s_addr = inet_addr(getstring(hd(q)));
    state.s[j].pos = 0;
    state.s[j].stop_flag = 0;
    state.s[j].lastpoll = run_time();
    j++;
  }
#ifdef DEBUG
  printf("rp: rd=");
  a_print(rd); fflush(stdout);
#endif
  /* Do it */
  {
    unwind_protect_begin;
    sl_startc = clock();
    mapfunction(varstack, generator_functionfn(varstack, rd), generator_paramsfn(varstack,rd),
		sensorgw_mapper, (void*)&state);
    unwind_protect_catch;
    free(state.s);
    if (unwind_reset) {
      if (0==state.stop) {
	/* Error */
	oidtype errcond=nil;
	printf("udpgw in unwind_reset: \n");
	fflush(stdout);
	errcond = globval(mksymbol("_error-condition_"));
	a_print(errcond);

	/*for(vs=globval(gw_subscribers); vs!=nil ; vs=tl(vs)) {
	  printfn(varstack, errcond, vs);
	  flushfn(varstack, vs);
	  }*/

      } /* 0==stop_flag () */
    } /* unwind_reset */
    call_lisp(mksymbol("gw-close-all-sockets"), cxt->env, 0);
  }
  return;
}

void register_rp(void) {
  a_extfunction("UDPGW", udpgw);
}
