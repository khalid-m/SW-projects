/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Pipes for Unix inter process streams
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "storage.h"
#include "amos.h"
#include <stdio.h>
#include <unistd.h>

int pipe_errnum;
int pipetype;
int pipestreamkind;

/* TODO:
   1. implement bulk copy using read&write
*/

oidtype new_pipestream(bindtype env) {
  oidtype res = new_object(sizeof(struct pipecell),pipetype);
  int pfd[2];
  FILE** handle;

  if (pipe(pfd) < 0) {
    fprintf(stderr, "Pipe error\n");
    return lerror(pipe_errnum, nil, env);
  }
  handle = dr(res,pipecell)->fh;

  handle[0] = fdopen(pfd[0],"r");
  if (handle[0] == NULL) {
    fprintf(stderr, "fdopen error in end [0]\n");
    return lerror(pipe_errnum, nil, env);
  }
  handle[1] = fdopen(pfd[1],"a");
  if (handle[1] == NULL) {
    fprintf(stderr, "fdopen error in end [1]\n");
    return lerror(pipe_errnum, nil, env);
  }

  dr(res,pipecell)->opened = TRUE;
  return res;
}

int pipe_getc(oidtype pipe) {
  return fgetc(dr(pipe,pipecell)->fh[0]);
}

int pipe_ungetc(int c, oidtype pipe) {
  return ungetc(c, dr(pipe,pipecell)->fh[0]);
}

int pipe_feof(oidtype pipe) {
  return feof(dr(pipe,pipecell)->fh[0]);
}

int pipe_puts(char* s, oidtype pipe) {
  return fputs(s, dr(pipe,pipecell)->fh[1]);
}

int pipe_putc(int c, oidtype pipe) {
  return fputc(c, dr(pipe,pipecell)->fh[1]);
}

int pipe_fflush(oidtype pipe) {
  return fflush(dr(pipe,pipecell)->fh[1]);
}

int pipe_fclose(oidtype pipe) {
  dr(pipe,pipecell)->opened = FALSE;
  return (fclose(dr(pipe,pipecell)->fh[0]) | fclose(dr(pipe,pipecell)->fh[1]));
}

void register_pipestream(void) {
  extfunction0("NEW-PIPESTREAM",new_pipestream);
  pipe_errnum = a_register_error("Pipe creation failed");
  pipetype = a_definetype("pipe",NULL,NULL);
  pipestreamkind = a_define_stream_implementation(pipetype,
						  pipe_getc,
						  pipe_ungetc,
						  pipe_feof,
						  pipe_puts,
						  pipe_putc,
						  pipe_fflush,
						  pipe_fclose);
  typefns[pipetype].is_stream = pipestreamkind;
}
