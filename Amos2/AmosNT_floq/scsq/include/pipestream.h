/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Pipes for Unix inter process streams
 * Language:     C
 ****************************************************************************/


#ifndef _pipestream_h_
#define _pipestream_h_

#define PIPE_BUFSIZ 65536


struct pipecell2 {
  objtags tags;
  short int bytes;             /* Total size of object in bytes, incl. header */
  char autoflush;                       /* Flush after each item and new line */
  char filler[3];                                             /* Unused flags */
  int line_num;                                        /* Current line number */
  oidtype logstream;                    /* Stream to copy input to if non-NIL */
  /*** end of stream header ***/
  int closed;                                    /* FALSE while stream opened */
  int pfd[2];
  oidtype inbuff;
  oidtype outbuff;
  int maxbs;
  int buffsize, inpos, outpos;
  int receivedbytes, receivedpackets;
  int sentbytes, sentpackets, forcedflush, auflush;
};


int pipe_errnum;
int pipetype;
int pipestreamkind;

oidtype new_pipestream(bindtype env, oidtype bs);
int pipe_getc(oidtype pipe);
int pipe_ungetc(int c, oidtype pipe);
int pipe_feof(oidtype pipe);
int pipe_puts(char* s, oidtype pipe);
int pipe_putc(int c, oidtype pipe);
int pipe_fflush(oidtype pipe);
int pipe_fclose(oidtype pipe);
void register_pipestream(void);
void init_pipestat(struct pipecell2*);

int pipe_closed;
int receive_pipe(struct pipecell2* pc);

#endif
