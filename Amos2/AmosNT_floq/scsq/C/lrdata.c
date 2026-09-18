#include "callout.h"
#include "amos.h"
#include "numarray.h"

//#define DEBUG

extern int lrinit(char* filename, int maxtpls, FILE* fhinit);
extern int lrdata(int* num);
extern void lrfinalize();

int maxnum = 1000;
FILE* fh[2];

void a_lrdata(a_callcontext cxt, a_tuple tpl) {
  static int initialized=0;
  struct numarraycell* dx;
  int i,j, num;
  int pfd[2];

  if (!initialized) {
    char str[1024];
    // Init pipe & fh
    if (pipe(pfd) < 0) {
      fprintf(stderr, "Pipe error\n");
      a_setobjectelem(tpl,1,nil,FALSE);
      a_emit(cxt, tpl,FALSE);
      return;
    }
    fh[0] = fdopen(pfd[0],"r");
    if (fh[0] == NULL) {
      fprintf(stderr, "fdopen error in end [0]\n");
      return;
    }
    fh[1] = fdopen(pfd[1],"a");
    if (fh[1] == NULL) {
      fprintf(stderr, "fdopen error in end [1]\n");
      return;
    }
    a_getstringelem(tpl,0,str,sizeof(str),FALSE);
    if (!lrinit(str, maxnum, fh[1])) {
      a_setobjectelem(tpl,1,nil,FALSE);
      a_emit(cxt, tpl,FALSE);
      return;
    } else {
      initialized = 1;
      sleep(1);
    }
  }

  do {
    if (lrdata(&num)) {
      oidtype tmp;
#ifdef DEBUG
      printf("lrdata: num=%d\n", num);
#endif
      for (i=0; i<num; i++) {
	a_setf(tmp, make_iarrayfn(cxt->env, mkinteger(15)));
	dx = dr(tmp,numarraycell);
	fread(dx->cont, sizeof(int), 15, fh[0]);
	a_setobjectelem(tpl,1,tmp,FALSE);
	a_emit(cxt,tpl,FALSE);
	a_free(tmp);
      }
    } else {
      lrfinalize();
      initialized=0;
      return;
    }
  } while (num == maxnum);
  return;
}

void register_lrdata() {
  a_extfunction("LRDATA",a_lrdata);
}
