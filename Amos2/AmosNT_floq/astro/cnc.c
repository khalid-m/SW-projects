/*****************************************************************************
* AMOS2
*
* Author: (c) 2005 Erik Zeitler, UDBL
*
* Description: CNC: compute node coord. Fetch queries from an outside coord.
* Language:	  C
* Location:	  AmosNT/astro/cnc.c
****************************************************************************/

#include <stddef.h>
#include <stdio.h>
#include <mpi.h>
#include <time.h>
#include "amos.h"
#include "mpicomm.h"
#include "cnc.h"

/*#define DEBUG*/
/*#define TRACE_PACKET*/

int cnc(int size) {
	oidtype qq=nil, q=nil;
	static oidtype stopsymbol=nil;
	double time = MPI_Wtime();
	oidtype result=nil;
	if (stopsymbol == nil) stopsymbol = mksymbol("STOP");
	
	while (1) {
		do {
			call_lisp(mksymbol("sleep"),varstack,1, mkreal(0.1));
		} while (MPI_Wtime() < time + 1.0);
		
		time = MPI_Wtime();
		a_setf(qq, call_lisp(mksymbol("cnc-retrieve-bgrequests"),varstack,0));
		for (q=qq;listp(q);q=tl(q)) {
			{
				unwind_protect_begin; /* Errors could occur when doing evalfn */
				a_setf(result,evalfn(varstack, hd(q)));
				unwind_protect_catch;
			}
#ifdef DEBUG
			a_message("cnc: Result is ");
			a_print(result); fflush(0);
#endif
		}
	}
}

