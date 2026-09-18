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
#include "pipestream.h"
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <poll.h>

int trace_pipe = FALSE;

/* TODO:
   1. implement bulk copy using read&write
   2. implement poll
*/

//#define DEBUGFLG

oidtype new_pipestream(bindtype env, oidtype bs) {
  struct pipecell2 *dp;
  oidtype res;
  int maxbs;

  maxbs = getinteger(bs);
  res = new_object(sizeof(*dp), pipetype);
  a_let(dr(res, pipecell2)->inbuff, new_string(maxbs + 1, ""));
  a_let(dr(res, pipecell2)->outbuff, new_string(maxbs + 1, ""));
  dp = dr(res, pipecell2);
  getstring(dp->inbuff)[maxbs] = '\0';
  getstring(dp->outbuff)[maxbs] = '\0';
  dp->autoflush = FALSE;
  dp->inpos = 0;
  dp->buffsize = 0;
  dp->maxbs = maxbs;
  dp->outpos = 0;
  init_pipestat(dp);

  if (pipe(dp->pfd) < 0) {
    fprintf(stderr, "Pipe error\n");
    return lerror(pipe_errnum, nil, env);
  }

  dr(res,pipecell2)->closed = FALSE;
  return res;
}

int pipe_getc(oidtype stream) {
  struct pipecell2 *dstream = dr(stream, pipecell2);
  char *buffer = getstring(dstream->inbuff);
  int res;

  if(dstream->inpos >= dstream->buffsize) {
    int ok = receive_pipe(dstream);
    if(!ok) {
      a_error(pipe_closed, stream, FALSE);
      return EOF;
    }
  }
  res = buffer[dstream->inpos];
  dstream->inpos++;
  return res;
}

int pipe_ungetc(int c, oidtype stream) {
  struct pipecell2 *dstream = dr(stream, pipecell2);

  if(dstream->inpos == 0) return -1;
  dstream->inpos--;
  getstring(dstream->inbuff)[dstream->inpos] = (char)c;
  return c;
}

int receive_pipe(struct pipecell2 *pc) {
  int rdc;
  char *buff = getstring(pc->inbuff);

  CheckInterrupt;
#ifdef DEBUGFLG
  { char buffer[100];
    sprintf(buffer, "recieve_packet will read %d bytes on pipe %d\n",
	    pc->maxbs, pc->pfd[0]);
    a_message(buffer);}
#endif
  rdc = read(pc->pfd[0], buff, pc->maxbs);
  pc->inpos = 0;
  pc->buffsize=0;
  CheckInterrupt;
#ifdef DEBUGFLG
  {char buffer[100];
    sprintf(buffer,"recv returned %d \n",rdc);
    a_message(buffer);
  }
#endif

  if(rdc == 0) return FALSE; // Other side closed
  if(rdc == -1) {
    switch (errno) {
    case EINTR:
      DoInterrupt();
      break;
    default:
      sockerror("receive_packet");
      break;
    }
  }
  if(rdc < 0) return FALSE;

  pc->receivedbytes = pc->receivedbytes + rdc;
  pc->buffsize = rdc;
  pc->receivedpackets++;

  if (trace_pipe) {
    int i;
    char msgbuff[100];
    sprintf(msgbuff, "%s Received on pipe %d\n", a_now(), pc->pfd[0]);
    a_message(msgbuff);
    for(i=0; i<rdc; i++)
      a_putc(buff[i], stdoutstream);
    a_message("|\n");
  }

  return TRUE;
}

int pwritebytes(struct pipecell2 *dstream) {
  int i, wrote, size=dstream->outpos;
  char *buff = getstring(dstream->outbuff);
  int p = dstream->pfd[1];

  for(i=0; i<size;) {
    wrote = write(p, buff + i, size-i);
    if (wrote == -1) {
      switch (errno) {
      case EINTR:  /* User Interrupt */
	DoInterrupt();
	break;
      case EAGAIN: /* Try again */
	break;
      default:
	return FALSE;
      }
    } else {
#ifdef DEBUGFLG
      char buffer[100];
      sprintf(buffer, "sendfn: Wrote %i remaining %i\n", wrote,
	      (size-(i+wrote)));
      a_message(buffer);
#endif
      i += wrote;
    }
  }
  return TRUE; /* OK */
}

void send_pipe(struct pipecell2 *dstream) {
  if(trace_pipe) {
    char *buff = getstring(dstream->outbuff);
    int i;
    char msgbuff[100];

    a_message(msgbuff);
    for(i=0; i<dstream->outpos; i++)
      a_putc(buff[i], stdoutstream);
    a_message("|\n");
  }
  pwritebytes(dstream);
  dstream->sentbytes = dstream->sentbytes + dstream->outpos;
  dstream->sentpackets++;
  dstream->outpos = 0;
}


int pipe_putc(int c, oidtype stream) {
  struct pipecell2 *dstream = dr(stream, pipecell2);
  char *buff;

  buff = getstring(dstream->outbuff);
  buff[dstream->outpos] = (char)c;
  dstream->outpos++;
  if(dstream->outpos >= dstream->maxbs) {
    dstream->auflush++;
    send_pipe(dstream);
  }
  return c;
}

int pipe_fflush(oidtype stream) {
  struct pipecell2 *dstream = dr(stream, pipecell2);
  dstream->forcedflush++;
  send_pipe(dstream);
  return 0;
}

int pipe_feof(oidtype pipe) {
  return dr(pipe, pipecell2)->closed;
}

int pipe_writebytes(oidtype stream, void *inbuff, unsigned int len) {
  struct pipecell2 *dstream = dr(stream, pipecell2);
  char *outbuff = getstring(dstream->outbuff);
  char *ip = (char *)inbuff;
  int rem = len;
  int outspace = dstream->maxbs - dstream->outpos;
  while(rem >= outspace) {
    memcpy(outbuff + dstream->outpos, ip, outspace);
    dstream->outpos = dstream->maxbs;
    dstream->auflush++;
    send_pipe(dstream);
    rem = rem - outspace;
    ip = ip + outspace;
    outspace = dstream->maxbs;
  }
  memcpy(outbuff + dstream->outpos, ip, rem);
  dstream->outpos = dstream->outpos + rem;
  return TRUE;
}

int pipe_readbytes(oidtype stream, void *outbuff, unsigned int len) {
  struct pipecell2 *dstream = dr(stream, pipecell2);
  char *inbuff = getstring(dstream->inbuff);
  char *op = (char *)outbuff;
  int rem = len;
  int inspace;
  int ok;

  while(rem >= (inspace = dstream->buffsize - dstream->inpos)) {
    memcpy(op, inbuff + dstream->inpos, inspace);
    dstream->inpos = dstream->inpos + inspace;
    rem = rem - inspace;
    op = op + inspace;
    ok = receive_pipe(dstream);
    if(!ok) {
      a_error(pipe_closed,stream,FALSE);
      return EOF;
    }
  }
  memcpy(op, inbuff + dstream->inpos, rem);
  dstream->inpos = dstream->inpos + rem;
  return TRUE;
}

int pipe_fclose(oidtype pipe) {
  struct pipecell2 *dp = dr(pipe, pipecell2);
  dp->closed = TRUE;
  a_free(dp->inbuff);
  a_free(dp->outbuff);
  return (close(dp->pfd[0]) | close(dp->pfd[1]));
}

int poll_pipes(int fh, double to) {
  fd_set fds;
  struct timeval timeout;
  int sec, usec, r_descs;

  sec = (int)floor(to);
  usec = (int)(to - sec)*1000000;
  timeout.tv_sec = sec;
  timeout.tv_usec = usec;
  FD_ZERO(&fds);
  FD_SET(fh, &fds);

  r_descs = select(fh + 1, &fds, NULL, NULL, &timeout);
}

oidtype poll_pipesfn(bindtype env, oidtype pipearr, oidtype to) {
  int r_descs, res;
  double timeout = coerce_real(env, to);

  // TODO

  return mkinteger(res);
}

oidtype pipestatfn(bindtype env, oidtype pipe) {
  struct pipecell2 *s;
  OfType(pipe, pipetype, env);
  s = dr(pipe, pipecell2);
  return a_list(mkinteger(s->sentbytes), mkinteger(s->sentpackets),
		mkinteger(s->auflush), mkinteger(s->forcedflush),
		mkinteger(s->receivedbytes), mkinteger(s->receivedpackets), 
		NULL);
}

oidtype pipestat_clearfn(bindtype env, oidtype pipe) {
  OfType(pipe, pipetype, env);
  init_pipestat(dr(pipe, pipecell2));
  return pipe;
}

void init_pipestat(struct pipecell2 *s) {
  s->sentbytes = 0;
  s->sentpackets = 0;
  s->forcedflush = 0;
  s->auflush = 0;
  s->receivedbytes = 0;
  s->receivedpackets = 0;
}

void register_pipestream(void) {
  extfunction1("NEW-PIPESTREAM0", new_pipestream);
  pipe_errnum = a_register_error("Pipe creation failed");
  pipe_closed = a_register_error("Pipe closed");
  pipetype = a_definetype("pipe", NULL, NULL);
  pipestreamkind = a_define_stream_implementation(pipetype,
						  pipe_getc,
						  pipe_ungetc,
						  pipe_feof,
						  NULL,
						  pipe_putc,
						  pipe_fflush,
						  pipe_fclose);
  typefns[pipetype].is_stream = pipestreamkind;
  extfunction2("POLL-PIPESTREAMS", poll_pipesfn);
  extfunction1("pipestat", pipestatfn);
  extfunction1("pipestat-clear", pipestat_clearfn);

  stream_implementations[pipetype].writebytes = pipe_writebytes;
  stream_implementations[pipetype].readbytes = pipe_readbytes;

}
