/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  MPI_SMerge: Merge any num of streams using MPI communication
 * Language:     C
 * Location:     AmosNT/astro/mpismerge.c
 ****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "amos.h"
#include "mpistream.h"
#include "mpicomm.h"
#include <stdio.h>
#include <mpi.h>
#include "storagetypes.h"
#include "mpisproc.h"

/*#define DEBUG */
/* #define TRACE_PACKET */

#define USE_MPI_STREAMS
#define MPI_STREAMBUFSIZE getinteger(globval(mksymbol("_mpistreambufsize_")))

#ifndef max
#define max(a,b) ( (a) > (b) ? a : b)
#endif
#ifndef min
#define min(a,b) ( (a) < (b) ? a : b)
#endif

double recv_time, send_time, total_time, emit_time;
clock_t recv_c, send_c, total_c, emit_c;

extern oidtype stopsymbol;
extern oidtype emitsymbol;
extern oidtype eofsym;

/* Smergebf is called by the parent proc. */
void mpi_smergebf(a_callcontext cxt, a_tuple params) {
  int i, j, child, pos, rank, eofflag, pollcount, poll_max, cont_period;
  int nchildren = 0;
  oidtype argarray = nil;
  oidtype resultarray = nil;
  int coord_rank;
  double tstart;
  clock_t cstart;
  oidtype* cstream;
	
  /* child_id is the list of child node ranks */
  int* child_id;
  int* chpoll;
  int chleft;
  oidtype* rd;
  oidtype* bag;
	
  total_time=MPI_Wtime();
  total_c = clock();
  eofflag = 0;
	
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  stopsymbol = mksymbol("stop");
  emitsymbol = mksymbol("emit");
  eofsym  = mksymbol("eof");
  /* Where is the node coordinator */
  coord_rank  = getinteger(globval(mksymbol("_coord-rank_")));
  poll_max    = getinteger(globval(mksymbol("_mpismergemaxpoll_")));
  cont_period = getinteger(globval(mksymbol("_continuation-period_")));

  printf("mpismergebf: poll_max=%d\n", poll_max);
  printf("mpismergebf: coord_rank=%d\n", coord_rank);

  /* Pick up num children */
  argarray = a_getobjectelem(params,0,FALSE);
  if (!arrayp(argarray)) {
    printf("mpi_smergebf@(%d): Not an array argument\n", rank);
    fflush(stdout);
    /* TODO: Raise error if input type is not an array */
  }
  nchildren = a_arraysize(argarray);
#ifdef DEBUG
  printf("mpi_smergebf@(%d): Argarray: ",rank);
  a_print(argarray);
  printf("mpi_smergebf@(%d): nchildren=%d. Now waiting\n", rank, nchildren);
  fflush(stdout);
#endif
  rd = (oidtype*)malloc(nchildren*sizeof(oidtype));
  bag = (oidtype*)malloc(nchildren*sizeof(oidtype));
  child_id = (int*)malloc(nchildren*sizeof(int));
  chpoll = (int*)malloc(nchildren*sizeof(int));
  chleft = nchildren;
  cstream = (oidtype*)malloc(nchildren*sizeof(oidtype));
	
  for (j=0; j<nchildren; j++) {
    rd[j] = nil;
    bag[j] = nil;
    cstream[j] = nil;
  }
  a_setf(resultarray, new_array(nchildren, nil));
	
  /* Request work nodes from coordinator */
  for (j=0; j<nchildren; j++) {
    a_mpi_send_block(mksymbol("(get-freenode)"), coord_rank, 0);
    a_setf(rd[0], a_mpi_proberecv_block(coord_rank));
    child_id[j] = getinteger(rd[0]);
#ifdef DEBUG
    printf ("mpi_smergebf@(%d): nchildren=%d. Coordinator gave child %d\n", rank, nchildren, child_id[j]);
#endif
#ifdef USE_MPI_STREAMS
    a_setf(cstream[j],new_mpistream(child_id[j],2,MPI_STREAMBUFSIZE));
#endif
  }
	
  for (i=0; i<nchildren; i++) {
    /* Init child by sending function closure */
    a_setf(bag[i], a_elt(argarray,i));
#ifdef DEBUG
    printf("bag[%d]: ",i); a_print(bag[i]);
    printf("(inspect-generator): ");
    inspect_generatorfn(cxt->env,bag[i]);
    fflush(stdout);
#endif
    a_mpi_send_block(bag[i], child_id[i], 0);
  }
	
  for (;;) {
    /* Request data from children */
    for (i=0; i<nchildren; i++) {
      tstart = MPI_Wtime();
      cstart = clock();
#ifdef USE_MPI_STREAMS
      printfn(cxt->env, emitsymbol, cstream[i]);
      flushfn(cxt->env, cstream[i]);
#else
      a_mpi_send_block(emitsymbol, child_id[i], 0);
#endif
      send_time += MPI_Wtime() - tstart;
      send_c += clock() - cstart;
    }
		
    for (pos=0; pos<cont_period; pos++) {
      for (i=0; i<nchildren; i++) {
	chpoll[i] = 1;
      }
      chleft = nchildren;
      pollcount = 0;
			
      while(!eofflag && chleft) {
	pollcount++;
#ifdef DEBUG
	printf("%d ",chleft);
#endif
	chleft=0;
	for (child=0; child<nchildren; child++) {
	  tstart = MPI_Wtime();
	  cstart = clock();
#ifdef USE_MPI_STREAMS
	  if (pollcount < poll_max) {
	    if (1 == chpoll[child]) {
	      if (mpistream_poll(cstream[child])) {
		a_setf(rd[child], readfn(cxt->env, cstream[child]));
		chpoll[child] = 0;
#ifdef DEBUG
		printf("mpi_smergebf@(%d): polling %d succeeded. Receiving data: ", rank, child_id[child]);
#ifdef TRACE_PACKET
		a_print(rd[child]);
#endif
		fflush(stdout);
#endif
	      } else {
		chleft++;
	      }
	    }
	  } else { /* pollcount expired => Force recv */
	    if (1 == chpoll[child]) {
	      a_setf(rd[child], readfn(cxt->env, cstream[child]));
#ifdef TRACE_PACKET
	      printf("mpi_smergebf@(%d): Force recv from %d. Receiving data: ", rank, child_id[child]);
	      a_print(rd[child]);
	      fflush(stdout);
#endif
	    }
	  }
#else
	  a_setf(rd[child],a_mpi_proberecv_block(child_id[child]));
#endif
	  recv_time += MPI_Wtime() - tstart;
	  recv_c += clock() - cstart;
	  if(rd[child] == eofsym) {
	    eofflag=1;
	    break;
	  }
	} /* for (child=0; child<nchildren; child++) */
      } /* while(!eofflag && chleft) */
			
      if (!eofflag) {
	tstart = MPI_Wtime();
	cstart = clock();
	for (i=0; i<nchildren; i++) {
	  a_seta(resultarray, i, rd[i]);
	}
	a_setelem(params, 1, resultarray);
	a_emit(cxt, params, FALSE);
	emit_time += MPI_Wtime() - tstart;
	emit_c += clock() - cstart;
      } else {
	/* EOF cleanup: stop children, receive inflight messages, give children back to coord, de-allocate */
	for(i=nchildren-1; i>=0; i--) {
#ifdef USE_MPI_STREAMS
	  printfn(cxt->env, stopsymbol, cstream[i]);
	  flushfn(cxt->env, cstream[i]);
#else
	  a_mpi_send_block(stopsymbol, child_id[i], 0);
#endif
	}
	for(i=nchildren-1; i>=0; i--) {
	  if (i != child) { /* all except EOF sender */
#ifdef DEBUG
	    printf("mpi_smergebf@(%d): Empty incoming buffers from child %d (i=%d, child=%d)\n",rank, child_id[i], i,child);
	    fflush(stdout);
#endif
	    do {
#ifdef USE_MPI_STREAMS
	      a_setf(rd[i], readfn(cxt->env, cstream[i]));
#else
	      a_setf(rd[i], a_mpi_proberecv_block(child_id[i]));
#endif
#ifdef TRACE_PACKET
	      printf("mpi_smergebf@(%d): gOT RUBBISH FROM child %d:\n",rank, i);
	      a_print(rd[i]);
	      fflush(stdout);
#endif
	    } while(rd[i] != eofsym);
	  }
	  rd[i] = a_list(mksymbol("return-freenode"),mkinteger(child_id[i]), NULL);
	  a_mpi_send_block(rd[i], coord_rank, 0);
	  a_mpi_proberecv_block(coord_rank);
	}
#ifdef DEBUG
	printf("mpi_smergebf@(%d): EOF cleanup\n",rank); 
	fflush(stdout);
#endif
	a_free(resultarray);
	for (i=0; i<nchildren; i++) {
	  a_free(bag[i]);
	}
	free(bag);
	free(child_id);
	free(chpoll);
	for (i=0; i<nchildren; i++) {
	  a_free(rd[i]);
	}
	free(rd);
	total_time = MPI_Wtime() - total_time;
	total_c = clock() - total_c;
	/*for (i=0; i<nchildren; i++) {
	  mpistream_printstat(cstream[i]);
	  }*/
				
	for (i=0; i<nchildren; i++) {
	  a_free(cstream[i]);
	}
	free(cstream);
	/*printstats(rank);*/
	/*a_printstat();*/
	return;
      } /* EOF cleanup */
    } /* pos = 0...cont_period */
  } /* Forever */
}

void register_mpi_smerge(void) {
  a_extfunction("SMERGEBF",mpi_smergebf);
}
