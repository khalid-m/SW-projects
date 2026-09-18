/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  MPISProc: MPI Stream Processor
 *                      - mpisproc: Installs generators on SPs
 *                      - mpi_generator_mapper:   Iterates over generator output
 * Language:		 C
 * Location:		 AmosNT/astro/mpisproc.c
 ****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "amos.h"
#include "mpicomm.h"
#include "mpisproc.h"
#include <stdio.h>
#include <mpi.h>
#include "storagetypes.h"
#include "bgcommon.h"
#include "mpistream.h"

#define DEBUG 2 /* 0, 1 or 2 */
#define USE_MPI_STREAMS 1 /* 0 or 1 */
#define MPI_STREAMBUFSIZE getinteger(globval(mksymbol("_mpistreambufsize_")))
/*#define PRINTSTAT*/

#ifndef max
#define max(a,b) ( (a) > (b) ? a : b)
#endif
#ifndef min
#define min(a,b) ( (a) < (b) ? a : b)
#endif

extern void a_print_to_buffer(oidtype obj, void **buffer,  int *length);
extern void a_message(char *msg);

struct evalstate {
  int me, parent;
  int stop_flag;

  a_callcontext cxt;
  a_tuple params;
  int pos, cont_period;
  oidtype pstream;
	double recv_time, send_time, total_time, emit_time;
	clock_t recv_c, send_c, total_c, emit_c;
};

extern oidtype stopsymbol;
extern oidtype emitsymbol;
extern oidtype eofsym;

void mpi_generator_mapper(bindtype env, oidtype tpl, void *xa) {
  struct evalstate *mapperstate;
  oidtype rd=nil;
  double tstart;
  clock_t cstart;
	
  mapperstate = (struct evalstate *)xa;
  if(2==DEBUG) {
    printf("mpi_generator_mapper@(%d): entering-\n", mapperstate->me);
		fflush(stdout);
  }
	
  /* At bufferpos 0 (cold start or \cont_period\ elements emitted),
     await command from parent */
  if (mapperstate->pos == 0) {
    if(2==DEBUG) {
      printf("mpi_generator_mapper@(%d): mapperstate->pos=0", mapperstate->me);
			fflush(stdout);
    }
    tstart = MPI_Wtime();
    cstart = clock();
		
    if (USE_MPI_STREAMS) {
      flushfn(env,mapperstate->pstream);
      a_setf(rd,readfn(env, mapperstate->pstream));
    } else {
      rd = a_mpi_proberecv_block(mapperstate->parent);
    }
    mapperstate->recv_time += MPI_Wtime() - tstart;
    mapperstate->recv_c += clock() - cstart;
		if (2 == DEBUG) {
			printf("mpi_generator_mapper@(%d): rd=", mapperstate->me);
			a_print(rd);
			printf("\n");
			fflush(stdout);
		}
    if (rd == emitsymbol) {
    } else if (rd == stopsymbol) {
      mapperstate->stop_flag = 1;
			if (DEBUG) {
				printf("mpi_generator_mapper@(%d): STOP-symbol received from parent => hammer hit\n",
					mapperstate->me);
				fflush(stdout);
			}
      resetfn(env); /* Hammer hit! */
      printf("After resetfn(env);\n");
      fflush(stdout);
      return;
    } else {
      printf("mpi_generator_mapper@(%d): The received symbol was not understood: ", mapperstate->me);
      a_print(rd);
      fflush(stdout);
    }
  }
	
  /* This is the actual emit: MPI_Send + decrease buffer counter */
	if (2==DEBUG) {
		printf("mpi_generator_mapper@(%d): tpl=", mapperstate->me);
		a_print(tpl);
		fflush(stdout);
	}
	tstart = MPI_Wtime();
	cstart = clock();
	if (USE_MPI_STREAMS) {
		printfn(env, a_elt(tpl,0), mapperstate->pstream);
	} else {
		a_mpi_send_block(a_elt(tpl,0), mapperstate->parent, 0);
	}
	mapperstate->send_time += MPI_Wtime() - tstart;
	mapperstate->send_c += clock() - cstart;
	mapperstate->pos++;
	if (mapperstate->pos == mapperstate->cont_period) {
		mapperstate->pos=0;
	}
}

int mpisproc() {
  struct evalstate mapperstate;
  int incoming_tag;
  oidtype rd=nil;
  double sl_starttime;
  clock_t sl_startc;

	stopsymbol = mksymbol("stop");
	emitsymbol = mksymbol("emit");
	eofsym  = mksymbol("eof");
  mapperstate.pos=0;
  mapperstate.stop_flag=0;
  mapperstate.pstream=nil;
	mapperstate.cont_period = getinteger(globval(mksymbol("_continuation-period_")));

  MPI_Comm_rank(MPI_COMM_WORLD, &mapperstate.me);
	
  if(DEBUG) {
    printf("mpisproc@(%d): Entering. Waiting for form...\n",mapperstate.me);
    fflush(stdout);
  }
  rd = a_mpi_proberecv_any_block(&(mapperstate.parent), &incoming_tag);
	
  if(DEBUG) {
    printf("mpisproc@(%d): received rd = ",mapperstate.me);
    a_print(rd); 
  }
	
  if (rd == stopsymbol) {
    if(DEBUG) {
      printf("mpisproc@(%d): received stopsymbol. Quit!\n",mapperstate.me);
    }
    return 0; /* Tell server loop to quit */
  }
	
  if(DEBUG) {
    printf("mpisproc@(%d): (inspect-generator): ",mapperstate.me);
    inspect_generatorfn(varstack,rd);
    fflush(stdout);
    printf("mpisproc@(%d): generator-fn: ",mapperstate.me);
    a_print(generator_functionfn(varstack, rd));
    printf("mpisproc@(%d): args: ",mapperstate.me);
    a_print(generator_paramsfn(varstack,rd));
    fflush(stdout);
  }
  /* Set up MPI streams if they are used */
  if (USE_MPI_STREAMS) {
    a_setf(mapperstate.pstream,new_mpistream(mapperstate.parent,2,MPI_STREAMBUFSIZE));
  }
  /* evalfn calls lisp function eval. (Arguments: env + function.) */
  /* ALisp Manual, pp 35 and on */
  {
    unwind_protect_begin;
    sl_starttime = MPI_Wtime();
    sl_startc = clock();
    mapfunction(varstack, generator_functionfn(varstack, rd), generator_paramsfn(varstack,rd),
			mpi_generator_mapper, (void*)&mapperstate);
    mapperstate.total_time  = MPI_Wtime() - sl_starttime;
    mapperstate.total_c = clock() - sl_startc;
#ifdef PRINTSTAT
    mpistream_printstat(mapperstate.pstream);
    printstats(&mapperstate);
    a_printstat();
    fflush(stdout);
#endif
    unwind_protect_catch;
    if (unwind_reset) {
      if (1==mapperstate.stop_flag) {
				mapperstate.total_time  = MPI_Wtime() - sl_starttime;
				mapperstate.total_c = clock() - sl_startc;
#ifdef PRINTSTAT
				mpistream_printstat(mapperstate.pstream);
				printstats(&mapperstate);
				a_printstat();
				fflush(stdout);
#endif
				if (USE_MPI_STREAMS) {
					printfn(varstack, eofsym, mapperstate.pstream);
					flushfn(varstack,mapperstate.pstream);
				} else {
					a_mpi_send_block(eofsym, mapperstate.parent, 0);
				}
				if(DEBUG) {
					printf("mpisproc@(%d) in unwind_reset: I was hit by a hammer! EOF sent. Exiting to main loop\n",
						mapperstate.me);
					fflush(stdout);
				}
      } else {
				/* TODO: Write more code here */
				oidtype errcond=nil;
				printf("mpisproc@(%d) in unwind_reset: Error raised. Sending err to parent\n",mapperstate.me);
				fflush(stdout);
				errcond = globval(mksymbol("_error-condition_"));
				a_mpi_send_block(errcond, mapperstate.parent, 0);
      }
		} else { /* Normal termination after mapfunction (no more tuples) */
			if (USE_MPI_STREAMS) {
				printfn(varstack, eofsym, mapperstate.pstream);
				flushfn(varstack,mapperstate.pstream);
			} else {
				a_mpi_send_block(eofsym, mapperstate.parent, 0);
			}
      do {
				    if (USE_MPI_STREAMS) {
							a_setf(rd,readfn(varstack, mapperstate.pstream));
						} else {
							rd = a_mpi_proberecv_block(mapperstate.parent);
						}
						if(DEBUG) {
							printf("mpisproc@(%d): Awaiting STOP. Received ",mapperstate.me); a_print(rd); fflush(stdout);
						}
			} while (rd != stopsymbol);
    } /* Normal termination after mapfunction (no more tuples) */
		a_free(mapperstate.pstream);
    a_free(rd);
    /* NB: No unwind_protect_end since we are at top level. */
  }
  return 1; /* Return true */
}

void printstats(struct evalstate *ms) {
	fprintf(stderr,"streamproc@(%d): recv_time  %f \t%f%\n",
		ms->me, ms->recv_time, 100*ms->recv_time/ms->total_time);
	fprintf(stderr,"streamproc@(%d): recv cpu   %f \t%f%\n",
		ms->me, (double)ms->recv_c/CLOCKS_PER_SEC, 100.0*ms->recv_c/ms->total_c);
	fprintf(stderr,"streamproc@(%d): send_time: \t%f \t%f%\n",
		ms->me, ms->send_time, 100*ms->send_time/ms->total_time);
	fprintf(stderr,"streamproc@(%d): send cpu   %f \t%f%\n",
		ms->me, (double)ms->send_c/CLOCKS_PER_SEC, 100.0*ms->send_c/ms->total_c);
	fprintf(stderr,"streamproc@(%d): send+recv: %f \t%f\n",
		ms->me, ms->send_time + ms->recv_time,
		100*(ms->send_time + ms->recv_time)/ms->total_time);
	fprintf(stderr,"streamproc@(%d): se+re cpu  %f \t%f%\n",
		ms->me, (double)(ms->recv_c+ms->send_c)/CLOCKS_PER_SEC, 100.0*(ms->recv_c+ms->send_c)/ms->total_c);
	fprintf(stderr,"streamproc@(%d): emit_time: %f \t%f%\n",
		ms->me, ms->emit_time, 100*ms->emit_time/ms->total_time);
	fprintf(stderr,"streamproc@(%d): emit cpu   %f \t%f%\n",
		ms->me, (double)ms->emit_c/CLOCKS_PER_SEC, 100.0*ms->emit_c/ms->total_c);
	fprintf(stderr,"streamproc@(%d): total time %f\n",
		ms->me, ms->total_time);
	fprintf(stderr,"streamproc@(%d): total cpu  %f\n",
		ms->me, (double)ms->total_c/CLOCKS_PER_SEC);
	fprintf(stderr,"streamproc@(%d): Efficiency %f%\n",
		ms->me, 100.0*((double)ms->total_c/CLOCKS_PER_SEC)/ms->total_time);
	fflush(stderr);
}
