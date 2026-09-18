/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, Tore Risch, UDBL
 *
 * Exec name:    scsq
 * Description:  Super Computer Stream Queries
 * Language:     C
 * Location:     AmosNT/astro/scsq.c
 ****************************************************************************/

#include <stddef.h>
#include <stdio.h>
#include <math.h>
#include <mpi.h>
#include "mpisproc.h"
#include "mpismerge.h"
#include "storagetypes.h"
#include "coordinator.h"
#include "cnc.h"
#include "fileaccess.h"
#include "amos.h"
#include "bgcommon.h"
#include "mpicomm.h"
#include "mpistream.h"
#include "port.h"
#include "sproc.h"

/* Surrogate BGL personality for NT */
#ifdef NT
#include "bglpersonality.h"
#else
#include <rts.h>
#include <bglpersonality.h>
#endif

#define DEBUG
/* #define TRACE_PACKET */

/*#define PROFILE */
/* #define MPE_LOG */

#ifdef MPE_LOG
#include <mpe.h>
#endif

void bgresultmapper(bindtype env, oidtype tpl, void *xa);
extern void a_print_to_buffer(oidtype obj, void **buffer, unsigned int *length);

struct bgresultmapperstate {
    oidtype counter;
    oidtype rsymbol;
    oidtype sendtofrontsymbol;
    oidtype eof;
    oidtype frontsock;
};

int main(int argc,char **argv) {
    int i, size, rank;
    struct bgresultmapperstate bgr;
    oidtype query_fetcher = nil;
    oidtype cr = nil, qr = nil, profres = nil;
    dcl_connection(c);
    int cnc_rank;
    double tend,tstart,tmapperstart;
    double tickstart, tickend, blask;
    clock_t ctickstart, ctickend, cblask;
    static oidtype stopsymbol = nil;
    BGLPersonality personality;
	
    MPI_Init(&argc, &argv);               /* Initialize MPI               */
    MPI_Comm_size(MPI_COMM_WORLD, &size); /* Get the number of processors */
    MPI_Comm_rank(MPI_COMM_WORLD, &rank); /* Get my number                */

#ifdef MPE_LOG
    MPE_Init_log();
#endif
    printf("argc: %d, argv[1]: %s argv[2]: %s\n", 
	   argc, argv[1], argv[2]);
    rts_get_personality(&personality, sizeof(personality));
	
    init_amos(argc,argv); 
    /* Between init and a_connect: register C functions */
#ifndef NT
    dr(stdoutstream,streamcell)->autoflush=FALSE;
#endif
    register_fileaccess();
    register_mpi_smerge();
    register_mpicomm();
    register_mpi_stream();
    register_bgcommon();
    register_port();

    a_connect(c,"",FALSE); /* read osql given on command line */
    if (stopsymbol == nil) stopsymbol = mksymbol("STOP");
#ifdef DEBUG
    printf("scsq@(%d): init-bg-node\n", rank);
    fflush(stdout);
#endif
    call_lisp(mksymbol("init-bg-node"),varstack,2,mkinteger(rank),mkinteger(size));
    /* Where is cnc */
    cr = globval(mksymbol("_cnc-rank_"));
    cnc_rank = getinteger(cr);
	
#ifdef MPE_LOG
    MPE_Start_log();
#endif
    { unwind_protect_begin;
#ifdef PROFILE
    call_lisp(mksymbol("start-profile"), varstack, 0);
#endif
    if (rank == cnc_rank) {
#ifdef DEBUG
	printf("scsq main: I am cnc_rank=%d\n",cnc_rank);
	printf("_mpistreambufsize_=");
	a_print(globval(mksymbol("_mpistreambufsize_")));
	fflush(stdout);
#endif
		
	while(cnc(size)) {
	    fflush(stdout);
	}
#ifdef DEBUG
	printf("scsq main@(%d): cnc signing off\n",rank);
	fflush(stdout);
#endif
    } else {
		
	/* EZ 060125: Coordinator on all nodes. */
	/*     while(coordinator(size)) { */
	/*       fflush(stdout); */
	/*     } */
		
	while(sproc(MPIPROTOCOL)) {
#ifdef PROFILE
	    a_setf(profres, call_lisp(mksymbol("profile"), varstack, 0));
	    printf("profiler@(%d): ", rank);
	    a_print(profres);
	    fflush(stdout);
#endif
			
#ifdef DEBUG
	    printf("scsq main@(%d): Restarting mpisproc\n", rank);
	    fflush(stdout);
#endif
	}
    }
	
    unwind_protect_catch;
#ifdef DEBUG
    printf("scsq main@(%d): Reached catch region\n",rank); 
    fflush(stdout);
#endif
    if (rank == cnc_rank) {
	MPI_Request* reqs;
	reqs = malloc(size*sizeof(MPI_Request));
	if (unwind_reset) {
	    printf("Sending error to front: ");
	    a_print(globval(mksymbol("_error-condition_")));
	    fflush(stdout);
	    printfn(varstack, globval(mksymbol("_error-condition_")), bgr.frontsock);
	    flushfn(varstack, bgr.frontsock);
	}
		
	/* NB: qm_rank must be set to 0 (in scsq.lsp) 
	   for interactivity in amos_toploop */
	/*#ifdef NT
	  amos_toploop("[scsq@PC]");
	  #endif*/
#ifdef DEBUG
	printf("scsq main@(%d): Killing nodes\n", rank); 
	fflush(stdout);
#endif

/*    for (i=0; i<size; i++) {
      if (i != qm_rank) {
      a_mpi_send_noblock(stopsymbol, i, 0, &reqs[i]);
      }
      }
      for (i=0; i<size; i++) {
      if (i != qm_rank) {
      MPI_Request_free(&reqs[i]);
      }
      }
      free(reqs);*/
    }

    /*   MPE_Finish_log("commlog"); */
    free_connection(c);
#ifdef DEBUG
    printf("scsq (%d): Arriving @ barrier\n", rank);
    fflush(stdout);
#endif
    MPI_Barrier(MPI_COMM_WORLD); /* Wait for all other nodes */
#ifdef DEBUG
    printf("scsq (%d): Calling finalize\n", rank); 
    fflush(stdout);
#endif
    MPI_Finalize();
    exit(0);
    unwind_protect_end; }
    return 0;
}

void bgresultmapper(bindtype env, oidtype tpl, void *xa) {
    struct bgresultmapperstate *state;
    oidtype result = nil;
    oidtype servercode = nil;
    state = (struct bgresultmapperstate *)xa;
	
#ifdef TRACE_PACKET
/*   a_message("scsq: bgresultmapper gives tpl "); */
/*   a_print(tpl); */
/*   fflush(stdout); */
#endif
    printfn(env, tpl, state->frontsock);
}
