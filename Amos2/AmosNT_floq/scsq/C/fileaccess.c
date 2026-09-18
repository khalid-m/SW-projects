/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  File system access primitives
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"
#include <stdio.h>
#include <math.h>
#include <sys/types.h>

#ifdef NT
#define popen _popen
#define pclose _pclose
#endif

/*#define DEBUG*/

#define fa_bufsize 65536


void readlofarvectorfile(a_callcontext cxt, a_tuple tpl) {
  FILE* fptr;
  char buf[BUFSIZ];
  char cmd[2*BUFSIZ];

  /* Get file name */
  a_getstringelem(tpl, 0, buf, BUFSIZ, FALSE);

  strcpy(cmd, "od -t d2 ");
  strcat(cmd, buf);

  if ((fptr = popen(cmd, "r")) != NULL) {
    while (fgets(buf, BUFSIZ, fptr) != NULL && !cxt->done) {
      /* Format output for Amos internals */
      sprintf(cmd,"#(%s)", buf+8);
      a_setobjectelem(tpl, 1, a_read_from_string(cmd), FALSE);
      a_emit(cxt, tpl, FALSE);
    }
    (void) pclose(fptr);
  }
}



void readtextvectorfile(a_callcontext cxt, a_tuple tpl) {
  FILE* fptr;
  char buf[BUFSIZ];
  char cmd[2*BUFSIZ];

  /* Get file name */
#ifdef DEBUG
	printf("Entering readtextvectorfile\n");
	fflush(stdout);
#endif
  a_getstringelem(tpl, 0, buf, BUFSIZ, FALSE);
  /*  fprintf(stderr, "%s\n", buf);*/
  if ((fptr = fopen(buf, "r")) != NULL) {
    while (fgets(buf, BUFSIZ, fptr) != NULL && !cxt->done) {
      /* Format output for Amos internals */
      sprintf(cmd,"#(%s)", buf);
      a_setobjectelem(tpl, 1, a_read_from_string(cmd), FALSE);
      a_emit(cxt, tpl, FALSE);
    }
#ifdef DEBUG
		if (cxt->done) {
			printf("cxt->done\n");
			fflush(stdout);
		} else {
			printf("EOF");
			fflush(stdout);
		}
#endif
    (void) pclose(fptr);
  }
}

/* readfile moved to AmosNT/system/C/filefns.c */

void readbinaryvectorfile(a_callcontext cxt, a_tuple tpl) {
  FILE* fptr;
  int hi;
  int lo;
  int res;
  char buf[BUFSIZ];

  /* Get file name */
  a_getstringelem(tpl, 0, buf, BUFSIZ, FALSE);
  /*  fprintf(stderr, "%s\n", buf);*/
  if ((fptr = fopen(buf, "r")) != NULL) {
    while (!cxt->done) {
      lo=fgetc(fptr);
      if (lo == EOF) break;
      hi=fgetc(fptr);
      if (hi == EOF) break;
      res = (lo + 256*hi);
      if (res > 32768) 
	res -=65536;
      /* Format output for Amos internals */
      sprintf(buf,"%d", res);
      a_setobjectelem(tpl, 1, a_read_from_string(buf), FALSE);
      a_emit(cxt, tpl, FALSE);
    }
    (void) pclose(fptr);
  }
}

void register_fileaccess(void) {
  a_extfunction("READTEXTVECTORFILE",readtextvectorfile);
  a_extfunction("READLOFARVECTORFILE",readlofarvectorfile);
  a_extfunction("READBINARYVECTORFILE",readbinaryvectorfile);
}
