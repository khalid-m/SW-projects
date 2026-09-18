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
#include "../system/C/filefns.h"

#include "mpisproc.h"
#include "mpismerge.h"
#include "tcpsmerge.h"
#include "coordinator.h"
#include "fileaccess.h"
#include "amos.h"
#include "bgcommon.h"
#include "mpicomm.h"
#include "mpistream.h"
#include "stat.h"
#include "sproc.h"
#include "port.h"

//#define DEBUG

extern void a_print_to_buffer(oidtype obj, void **buffer, unsigned int *length);


int main(int argc,char **argv) {
	oidtype stopsymbol = nil;
	oidtype emitsymbol = nil;
	oidtype eofsym = nil;
	oidtype profres = nil;
  int i, size, rank;
  dcl_connection(c);
  int coord_rank;
	/*  double tend,tstart,tmapperstart;*/
  MPI_Init(&argc, &argv);               /* Initialize MPI               */
  MPI_Comm_size(MPI_COMM_WORLD, &size); /* Get the number of processors */
  MPI_Comm_rank(MPI_COMM_WORLD, &rank); /* Get my number                */
	
  printf("argc: %d, argv[1]: %s argv[2]: %s\n", 
		argc, argv[1], argv[2]); fflush(stdout);
	
  init_amos(argc,argv); 
  /* Between init and a_connect: register C functions */
	
	/* First thing: Define the symbols so that they are hashed in correct order */
	stopsymbol= mksymbol("stop");
	emitsymbol= mksymbol("emit");
	eofsym = mksymbol("eof");

	register_mpi_stream();
  register_mpicomm();
  register_fileaccess();
	register_mpi_smerge();
	register_bgcommon();
	register_port();
  a_connect(c,"",FALSE);
	


	call_lisp(mksymbol("init-bg-node"),varstack,2,mkinteger(rank),mkinteger(size));
  coord_rank = getinteger(globval(mksymbol("_coord-rank_")));
	call_lisp(mksymbol("start-profile"), varstack, 0);
	
	if (rank == coord_rank) {
		printf("I'm coordinator@(%d)\n", rank); fflush(stdout);
		while(coordinator(size)) {
      fflush(stdout);
    }
  } else if (rank == 0) { 
		printf("Hi, I'm Mr. QM@(%d)\n", rank); fflush(stdout);
		amos_toploop("[scsq@PC]");
			a_setf(profres, call_lisp(mksymbol("profile"), varstack, 0));
			printf("profiler@(%d): ", rank);
			a_print(profres);
			fflush(stdout);
			a_mpi_send_block(stopsymbol, coord_rank,0);
  } else {
		printf("I'm another work node@(%d)\n", rank); fflush(stdout);
    while(mpisproc()) {
			a_setf(profres, call_lisp(mksymbol("profile"), varstack, 0));
			printf("profiler@(%d): ", rank);
			a_print(profres);
			fflush(stdout);
#ifdef DEBUG
			a_message("scsq main: Restarting mpisproc\n");
			fflush(stdout);
#endif
    }
  }
	
  printf("scsq main@(%d): Reached catch region\n", rank); fflush(stdout);
  if (coord_rank == rank) {
		MPI_Request* reqs;
		reqs = malloc(size*sizeof(MPI_Request));
#ifdef DEBUG
		a_message("scsq main: Killing nodes\n"); fflush(stdout);
#endif
		for (i=1; i<size; i++) {
			if (i != coord_rank) {
				printf("Sending to %d\n", i);
				fflush(stdout);
				a_mpi_send_noblock(stopsymbol, i, 0, &reqs[i]);
			}
		}
#ifdef DEBUG
		a_message("scsq main: Stopsymbol sent to all nodes\n"); fflush(stdout);
#endif
		/* All nodes w/ outside (TCP) communication should do this. */
		/*CloseAllDescriptors();*/
		free(reqs);
  }
  free_connection(c);
	printf("Calling finalize@(%d)\n", rank); fflush(stdout);
  MPI_Finalize();
  return 0;
}

