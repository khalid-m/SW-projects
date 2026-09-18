/*****************************************************************************
* AMOS2
*
* Author: (c) 2006 Erik Zeitler, UDBL
*
* Description:  statistics computations
* Language:     C
* Location:     AmosNT/astro/stat.c
****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "amos.h"
#include "stat.h"

/*#define DEBUG */

void avgstdevbff(a_callcontext cxt, a_tuple tpl) {
	oidtype v = nil, el=nil;
	double sum=0.0, sum2=0.0, elem, cnt, oneovercnt, n_oneovercnt;
	int count=0, i;
	
	a_setf(v,a_getobjectelem(tpl,0,FALSE));
	count = a_arraysize(v);
	if (0 == count) {
		a_setelem(tpl, 1, nil);
		a_setelem(tpl, 2, nil);
		a_emit (cxt,tpl,FALSE);
	} else {		
		cnt = (double) count;
		oneovercnt = 1.0/cnt;
		n_oneovercnt = 1.0/(cnt-1.0);
		for (i=0; i<count; i++) {
			a_setf(el, a_elt(v,i));
			if (realp(el)) {
				elem = getreal(el);
			} else if (integerp(el)) {
				elem = (double)getinteger(el);
			}
#ifdef DEBUG
			printf("%f ", elem);
#endif
			sum += elem;
			sum2 += elem*elem;
		}
#ifdef DEBUG
		printf("; sum=%f, sum2=%f; avg=%f, stdev=%f\n", sum, sum2, sum/cnt, 
			sqrt((sum2-sum*sum/cnt)/(cnt-1.0)));
#endif
		
		a_setdoubleelem(tpl, 1, sum*oneovercnt, FALSE);
		a_setdoubleelem(tpl, 2, sqrt((sum2-sum*sum*oneovercnt)*n_oneovercnt), FALSE);
		a_emit(cxt,tpl, FALSE);
	}
	a_free(v);
	a_free(el);
}

void register_statfunctions(void) {
	a_extfunction("avgstdevbff", avgstdevbff);
}
