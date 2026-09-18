/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, Tore Risch, UDBL
 *
 * Description:  coordinator: Keeps track of free nodes
 * Language:	 C
 * Location:	 AmosNT/astro/coordinator.c
 ****************************************************************************/

#include <stddef.h>
#include <stdio.h>
#include <math.h>
#include <mpi.h>
#include "amos.h"
#include "bgcommon.h"
#include "mpicomm.h"

#define DEBUG 0 /* 0, 1 or 2 */
/* DEBUG level 2 also prints out expressions sent to/from coordinator */

extern void a_print_to_buffer(oidtype obj, void **buffer,  int *length);
extern void a_message(char *msg);


int coordinator(int size) {
	int client, tag;
	oidtype rd=nil, result=nil;
	static oidtype stopsymbol=nil;
	if (stopsymbol == nil) stopsymbol = mksymbol("STOP");

	while (1) {
	  if(DEBUG>0) {a_message("coordinator: waiting for message\n"); fflush(stdout);}
		a_setf(rd, a_mpi_proberecv_any_block(&client, &tag));
		if(2==DEBUG) {
			a_message("coordinator: received rd = ");
			a_print(rd); fflush(0);
		}
		if (rd == stopsymbol) {
			if(DEBUG>0) {
				a_message("coordinator: STOP");fflush(0);
			}
			return 0; /* Tell coordinator loop to quit */
		}

		{
			unwind_protect_begin; /* Errors could occur when doing evalfn */
			a_setf(result,evalfn(varstack, rd));
			unwind_protect_catch;
			/* unwind_protect_end is omitted,
			since we catch all errors and print them on stdout */
		}
		if(2==DEBUG) {
			a_message("coordinator: Result is ");
			a_print(result); fflush(0);
		}
		if (0==tag) {
			/* request tag==0 --> send answer back */
			a_mpi_send_block(result, client, 0);
			if(DEBUG>0) {
				a_message("coordinator: result sent.");
				fflush(0);
			}
		}
	} /* while (1) */
}
