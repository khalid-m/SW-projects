#include "amos.h"
#include <stdio.h>
#include "lofardata.h"
#include "numarray.h"
#include "fftcomplex.h"

//#define DEBUG

void a_readlofardata(a_callcontext cxt, a_tuple tpl) {
    struct lofarframe bu[50];
    FILE* handle;
    size_t result;
    int i,j;
    oidtype ret = nil;
    struct numarraycell *dres;
    COMPLEX* t;
#ifdef DEBUG
    char separator[9];
#endif
    char* buf = malloc(sizeof(char)*(a_getelemsize(tpl,0,FALSE)+1));
    if (buf == NULL) {
	return;
    }
	
    a_getstringelem(tpl, 0, buf, sizeof(buf), FALSE);
    handle = fopen(buf,"r");
    if (handle ==NULL) {
	free(buf);
	a_setobjectelem(tpl, 1, nil, FALSE);
	a_emit(cxt, tpl, FALSE);
	return;
    }
		
    while(!feof(handle)) {
	result = fread(bu, 1, 4009, handle);
	for (j=0;j<50;j++) {
#ifdef DEBUG
	    printf("aaba %d, ver %d, stn ID %d, sec %u, slice %u\n",
		   bu[j].aaba, bu[j].version, bu[j].stationID, bu[j].sec, bu[j].slice);
#endif
	    a_setf(ret, make_carrayfn(cxt->env, mkinteger(16)));
	    dres = dr(ret,numarraycell);
	    t = (COMPLEX*) dres->cont;
	    for (i=0; i< 16; i++) {
#ifdef DEBUG
		if(!(i%2))
		    printf("|");
		printf("%d ", bu[j].data[2*i]);
		printf("%d ", bu[j].data[2*i+1]);
		fflush(stdout);
#endif
		t[i].re = bu[j].data[2*i];
		t[i].im = bu[j].data[2*i+1];
	    }
#ifdef DEBUG
	    printf("\n");
#endif
	    a_setobjectelem(tpl, 1, ret, FALSE);
	    a_emit(cxt, tpl, FALSE);
	}
		
#ifdef DEBUG
	for (i=0; i<9; i++) {
	    putchar(separator[i]);
	}
	printf("\n");
#endif
    }
    fclose(handle);
    free(buf);
    a_free(ret);
    return;
}


void register_lofardata(void) {
    a_extfunction("READLOFARDATA",a_readlofardata);
}
