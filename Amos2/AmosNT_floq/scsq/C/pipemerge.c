/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Merge two streams using unix pipe()
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"
#include <stdio.h>
#include "pipestream.h"

#ifndef NT
#include <unistd.h>
#endif

#define MERGE_BUF 1

//extern oidtype new_pipestream(bindtype env);

oidtype emitsymbol;

struct pipemergestate {
  int child_id;
  oidtype uppipe;
  oidtype downpipe;
  int pos;
  int emit_flag;

  a_callcontext cxt;
  a_tuple params;
};

oidtype pipemerge_mapper(a_callcontext cxt, int width, oidtype *restpl,
			 void *xa) {
  struct pipemergestate *state;
  oidtype rd = nil;
  oidtype tpl = a_resultarray(width, restpl);
  bindtype env = cxt->env;

  state = (struct pipemergestate *)xa;

  if (state->pos == 0) {
    state->emit_flag = FALSE;
    flushfn(env, state->uppipe);
    a_setf(rd, readfn(env, state->downpipe));
    if(rd == emitsymbol) {
      state->emit_flag = TRUE;
      /*fprintf(stderr, "child_id %d has set emit_flag\n", state->child_id);*/
    }
  }

  if (state->emit_flag == TRUE) {
    printfn(env, (a_arraysize(tpl) == 1 ? a_elt(tpl,0) : tpl), state->uppipe);
    state->pos++;
    /*fprintf(stderr, "child_id %d; pos %d\n", state->child_id, state->pos);*/
    if (state->pos == MERGE_BUF) {
      state->pos = 0;
    }
  }
}

void pipemergebbff(a_callcontext cxt, a_tuple params) {
  struct pipemergestate state;
  int i, child_id;
  int pos;
  int forkstate;

  oidtype eofsym = mksymbol("EOF");
  emitsymbol = mksymbol("emit");

  oidtype bag[2] = {nil, nil};
  oidtype uppipe[2] = {nil, nil};
  oidtype downpipe[2] = {nil, nil};
  oidtype *rd;
  oidtype lard = nil;
  rd = (oidtype*)malloc(MERGE_BUF*sizeof(oidtype));
  for (i = 0; i<MERGE_BUF; i++) {
    rd[i] = nil;
  }

  /* Init call context and bag data to children */
  a_setf(bag[0], a_getelem(params, 0, FALSE));
  a_setf(bag[1], a_getelem(params, 1, FALSE));
  state.params = params;
  state.cxt = cxt;

  /* Launch children */
  for (child_id = 0; child_id<2; child_id++) {
    a_setf(uppipe[child_id], new_pipestream(cxt->env, BUFSIZ));
    a_setf(downpipe[child_id], new_pipestream(cxt->env, BUFSIZ));
    state.uppipe = uppipe[child_id];
    state.downpipe = downpipe[child_id];

    state.child_id = child_id;
    state.pos = 0;
    state.emit_flag = FALSE;
    forkstate = fork();
    if(forkstate < 0) {
      perror("fork");
      exit(1);
    } else if (forkstate == 0) {
      {
	/* unwind_protect_{begin|catch (is ALWAYS executed)|end} */
	unwind_protect_begin;
	a_mapbag(cxt, bag[child_id], pipemerge_mapper, (void*)&state);
	unwind_protect_catch;
	printfn(cxt->env, eofsym, state.uppipe);
	flushfn(cxt->env, state.uppipe);
	/* No dealloc needed -- we exit anyway */
	exit(0);
	unwind_protect_end;
      }
    }
  }

  /* Parent section */
  for(;;) {
    /* Request data from children */
    for (child_id = 0; child_id<2; child_id++) {
      printfn(cxt->env, emitsymbol, downpipe[child_id]);
      flushfn(cxt->env, downpipe[child_id]);
    }

    /* Fill buffers w/ emitted elements from children */
    for (child_id = 0; child_id<1; child_id++) {
      for (pos = 0; pos<MERGE_BUF; pos++) {
	a_setf(rd[pos], readfn(cxt->env, uppipe[child_id]));
	if(rd[pos] == eofsym) {
	  for (i = 0; i<2;i++) {
	    a_free(bag[i]);
	    a_free(uppipe[i]);
	    a_free(downpipe[i]);
	  }
	  for (i = 0; i<MERGE_BUF; i++) {
	    a_free(rd[i]);
	  }
	  free(rd);
	  return;
	}
      }
    }

    /* Read from last child, and emit at the same time */
    for (pos = 0; pos<MERGE_BUF; pos++) {
      a_setf(lard, readfn(cxt->env, uppipe[child_id]));
      if(lard == eofsym) {
	for (i = 0; i<2;i++) {
	  a_free(bag[i]);
	  a_free(uppipe[i]);
	  a_free(downpipe[i]);
	}
	for (i = 0; i<MERGE_BUF; i++) {
	  a_free(rd[i]);
	}
	a_free(lard);
	free(rd);
	return;
      }
      for (child_id = 0; child_id<1; child_id++) {
	a_setelem(params, 2+child_id, rd[pos]);
      }
      a_setelem(params, 2+child_id, lard);
      a_emit(cxt, params, FALSE);
    }
  }
}

void register_pipemerge(void) {
  a_extfunction("PIPEMERGEBBFF", pipemergebbff);
}
