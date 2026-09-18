/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 * $RCSfile: mpistream.c,v $
 * $Revision: 1.34 $ $Date: 2006/11/20 18:03:48 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos stream abstraction on top of MPI
 *
 ****************************************************************************/

#include "storage.h"
#include "amos.h"
#include "mpistream.h"
#include <mpi.h>

int mpitype;
int mpistreamtype;

/*#define BLOCKING_SEND
#define BLOCKING_RECV*/

/*#define DEBUG*/
/*#define TRACE_PACKET*/

oidtype new_mpistream(int peer, int tag, int bsz) {
  oidtype res;
  struct mpicell *dres;
  int buffsize = bsz +1;
	
  res = new_object(sizeof(*dres),mpitype);
  dr(res,mpicell)->autoflush=FALSE;
  a_let(dr(res,mpicell)->inbuf[0],new_string(buffsize,""));
  a_let(dr(res,mpicell)->inbuf[1],new_string(buffsize,""));
  a_let(dr(res,mpicell)->outbuf[0],new_string(buffsize,""));
  a_let(dr(res,mpicell)->outbuf[1],new_string(buffsize,""));
  dres = dr(res,mpicell);
  getstring(dres->inbuf[0])[bsz]='\0';
  getstring(dres->inbuf[1])[bsz]='\0';
  getstring(dres->outbuf[0])[bsz]='\0';
  getstring(dres->outbuf[1])[bsz]='\0';
  dres->tag = tag;
  dres->peer = peer;
  dres->opened = 1;
  dres->closed = 0;
  dres->inpos = bsz;
  dres->outpos = 0;
  dres->recv_started[0] = 0;
  dres->recv_started[1] = 0;
  dres->inbufsize[0] = bsz;
  dres->inbufsize[1] = bsz;
  dres->maxinbufsize[0] = bsz;
  dres->maxinbufsize[1] = bsz;
  dres->outbufsize = bsz;
  dres->outbufno = 0;
  dres->inbufno = 0;
  dres->outrequest[0] = MPI_REQUEST_NULL;
  dres->outrequest[1] = MPI_REQUEST_NULL;
  dres->inrequest[0] = MPI_REQUEST_NULL;
  dres->inrequest[1] = MPI_REQUEST_NULL;
  dres->sentbytes=0;
  dres->sentpackets=0;
  dres->recvbytes=0;
  dres->recvpackets=0;
  dres->prefetch_recvbytes=0;
  dres->prefetch_recvpackets=0;

  MPI_Comm_rank(MPI_COMM_WORLD, &dres->rank);
#ifndef BLOCKING_RECV
  /* "PRE-FETCH" packet on the other buffer */
  mpistream_try_recv_init(res,1-dres->inbufno);
	dres = dr(res,mpicell);
  dres->inpos = bsz;
#endif
#ifdef DEBUG
  printf("##new_mpistream@(%d): recv_started=%d\n",dres->rank,
		dres->recv_started[1-dres->inbufno]);

  fflush(stdout);
#endif
  return res;
}

void mpistream_printstat(oidtype stream) {
  struct mpicell *dres = dr(stream,mpicell);
  printf("mpistream@(%d)<->%d: SentB %d, sentpkt %d, recvB %d, recvpkt %d, p_recvB %d, p_recvpkt %d\n",
	 dres->rank, dres->peer, dres->sentbytes, dres->sentpackets, 
	 dres->recvbytes, dres->recvpackets, 
	 dres->prefetch_recvbytes, dres->prefetch_recvpackets);
  fflush(stdout);
}

void destroy_mpistream(oidtype stream) {
  struct mpicell *dres = dr(stream,mpicell);
#ifdef DEBUG
  printf("##destroy_mpistream@(%d)\n", dres->rank);
  fflush(stdout);
#endif
  mpistream_fclose(stream);
  /*mpistream_printstat(stream);*/
  a_free(dres->inbuf[0]);
  a_free(dres->inbuf[1]);
  a_free(dres->outbuf[0]);
  a_free(dres->outbuf[1]);
  dealloc_object(stream);
}

oidtype open_mpifn(bindtype env, oidtype peer, oidtype tag, oidtype bufsize) {
  int  tagno, peerno, bsz;
  oidtype res;
		
  IntoInteger(tag, tagno, env);
  IntoInteger(peer, peerno, env);
  IntoInteger(bufsize, bsz, env);
  res = new_mpistream(peerno, tagno, bsz);
  return res;
}

int mpistream_feof(oidtype stream) {
  struct mpicell *dstream = dr(stream,mpicell);
#ifdef DEBUG
  printf("mpistream_feof@(%d):\n", dstream->rank);
  fflush(stdout);
#endif
  return dstream->closed;
}

int mpistream_putc(int c, oidtype stream) {
  struct mpicell *dstream = dr(stream,mpicell);
  char *buff = getstring(dstream->outbuf[dstream->outbufno]); /* Buffer base address */
  if (0 == dstream->outpos) {
    MPI_Status status;
    MPI_Wait(&dstream->outrequest[dstream->outbufno], &status);
  }
	
  buff[dstream->outpos] = (char)c;
  dstream->outpos++;
  if(dstream->outpos >= dstream->outbufsize) {
    mpistream_send_packet(dstream);
  }
  return c;
}

void mpistream_send_packet(struct mpicell *dstream) {
  char *buff = getstring(dstream->outbuf[dstream->outbufno]);
#ifdef BLOCKING_SEND
  MPI_Status status;
#endif
	
#ifdef TRACE_PACKET
  int i;
  if (0 == dstream->outpos) {
    printf("mpistream_send_packet@(%d) sends nothing. outpos = 0", dstream->rank);
  } else {
    printf("mpistream_send_packet@(%d) sends:\n", dstream->rank);
    for(i=0;i<dstream->outpos;i++)
      a_putc(buff[i],stdoutstream);
    printf("| to %d\n",dstream->peer);
  }
  fflush(stdout);
#endif

  if (0 != dstream->outpos) {
    MPI_Isend(buff, dstream->outpos, MPI_BYTE, dstream->peer, dstream->tag,
	      MPI_COMM_WORLD, &dstream->outrequest[dstream->outbufno]);
#ifdef BLOCKING_SEND
    MPI_Wait(&dstream->outrequest[dstream->outbufno], &status);
#else
    dstream->outbufno= 1 - dstream->outbufno;
#endif
    dstream->sentbytes += dstream->outpos;
    dstream->sentpackets++;
    dstream->outpos=0;
  }
}

int mpistream_fflush(oidtype mpistream) {
  struct mpicell *dstream = dr(mpistream,mpicell);
#ifdef DEBUG
  printf("mpistream_fflush@(%d), pos %d:\n", dstream->rank, dstream->outpos);
  fflush(stdout);
#endif
	
  if (0 == dstream->outpos) {
    return 0;
  } else {
    mpistream_send_packet(dstream);
  }
  return 0;
}

int mpistream_fclose(oidtype stream) {
  struct mpicell *dstream = dr(stream,mpicell);
  mpistream_fflush(stream);
  dstream->closed=1;
#ifdef DEBUG
  printf("mpistream_fclose@(%d): Done.\n", dstream->rank);
  fflush(stdout);
#endif
  return 0;
}

int mpistream_getc(oidtype stream) {
  struct mpicell *dstream = dr(stream,mpicell);
  int res;
  char *buffer;
#ifdef DEBUG
	printf("mpistream_getc@(%d): inpos=%d inbufno=%d\n", dstream->rank, dstream->inpos, dstream->inbufno);
	fflush(stdout);
#endif
  if (dstream->inpos >= dstream->inbufsize[dstream->inbufno]) {
    mpistream_recv_packet(stream);
    dstream = dr(stream,mpicell);
  }
  buffer = getstring(dstream->inbuf[dstream->inbufno]);
  res = buffer[dstream->inpos];
  dstream->inpos++;
  /* Trying to start recv this often doesn't pay off */
  /*#ifndef BLOCKING_RECV
    if (!dstream->recv_started[1-dstream->inbufno]) {
    mpistream_try_recv_init(stream,1-dstream->inbufno);
    }
    #endif*/
  return res;
}

int mpistream_ungetc(int c, oidtype stream) {
  struct mpicell *dstream = dr(stream,mpicell);
  if(dstream->inpos == 0) return -1;
  dstream->inpos--;
  getstring(dstream->inbuf[dstream->inbufno])[dstream->inpos] = (char)c;
  return c;
}

int mpistream_poll(oidtype stream) {
/* Returns true if there is data to read in the buffers. 
	 Only applicaple to nonblocking recv. */
#ifndef BLOCKING_RECV
  MPI_Status commstatus;
  int flag=0;
  struct mpicell *dstream = dr(stream,mpicell);

	if (dstream->inpos < dstream->inbufsize[dstream->inbufno]) {
		return 1;
	}
	if (dstream->recv_started[1-dstream->inbufno]) {
		MPI_Test(&dstream->inrequest[1-dstream->inbufno],&flag, &commstatus);
		return flag;
	} else {
		mpistream_try_recv_init(stream, 1-dstream->inbufno);
		return 0;
	}
#else
	return 1;
#endif
}

void mpistream_try_recv_init(oidtype stream, int bufno) {
  /* Attempt to start a non blocking recv on buffer bufno */
  MPI_Status commstatus;
  oidtype temp = nil;
  int success=0, incoming_count;
  struct mpicell *dstream = dr(stream,mpicell);
	
  MPI_Iprobe(dstream->peer, dstream->tag, MPI_COMM_WORLD, &success, &commstatus);
  if (success) {
    MPI_Get_count(&commstatus, MPI_BYTE, &incoming_count);
    dstream->inbufsize[bufno] = incoming_count;
    if (dstream->inbufsize[bufno] > dstream->maxinbufsize[bufno]) {
#ifdef DEBUG
      printf("Bump: %d -> %d\n", dstream->maxinbufsize[bufno], dstream->inbufsize[bufno]);
      fflush(stdout);
#endif
      dstream->maxinbufsize[dstream->inbufno] = dstream->inbufsize[dstream->inbufno];
      temp = new_string(incoming_count,"");
      a_setf(dr(stream,mpicell)->inbuf[dstream->inbufno], temp);
      dstream = dr(stream,mpicell);
    }
    MPI_Irecv(getstring(dstream->inbuf[bufno]), dstream->inbufsize[bufno], 
	      MPI_BYTE, dstream->peer, dstream->tag, MPI_COMM_WORLD, &dstream->inrequest[bufno]);
		dstream = dr(stream,mpicell);
    dstream->prefetch_recvpackets++;
    dstream->prefetch_recvbytes += dstream->inbufsize[bufno];
    dstream->recv_started[bufno] = 1;
#ifdef DEBUG
    printf("mpistream_try_recv_init@(%d): success! dstream->recv_started[%d]=%d (addr=%d)\n", dstream->rank,
			bufno, dstream->recv_started[bufno], dstream->recv_started);
    fflush(stdout);
#endif
  }
}

void mpistream_recv_packet(oidtype stream) {
  oidtype temp = nil;
  int incoming_count=0;
  MPI_Status commstatus;
  struct mpicell *dstream = dr(stream,mpicell);
#ifdef TRACE_PACKET
  int i;
#endif
#ifndef BLOCKING_RECV
  /* Flip bufno */
  dstream->inbufno= 1 - dstream->inbufno;
#endif
#ifdef DEBUG
	  printf("mpistream_recv_packet@(%d): inbufno=%d recv_started[%d]=%d (addr=%d)\n", dstream->rank, dstream->inbufno, 
			dstream->inbufno, dstream->recv_started[dstream->inbufno], dstream->recv_started);
		fflush(stdout);
#endif
  /* Have we started recving the new buffer? */
  if (dstream->recv_started[dstream->inbufno]) {
    MPI_Wait(&dstream->inrequest[dstream->inbufno], &commstatus);
  } else { /* If not, force a recv now! */
    MPI_Probe(dstream->peer, dstream->tag, MPI_COMM_WORLD, &commstatus);
    MPI_Get_count(&commstatus, MPI_BYTE, &incoming_count);
    dstream->inbufsize[dstream->inbufno] = incoming_count;
    if (dstream->inbufsize[dstream->inbufno] > dstream->maxinbufsize[dstream->inbufno]) {
#ifdef DEBUG
      printf("Bump: %d -> %d\n", dstream->maxinbufsize, dstream->inbufsize);
      fflush(stdout);
#endif
      dstream->maxinbufsize[dstream->inbufno] = dstream->inbufsize[dstream->inbufno];
      temp = new_string(incoming_count,"");
      a_setf(dr(stream,mpicell)->inbuf[dstream->inbufno], temp);
      dstream = dr(stream,mpicell);
    }
    MPI_Recv(getstring(dstream->inbuf[dstream->inbufno]), dstream->inbufsize[dstream->inbufno], 
	     MPI_BYTE, dstream->peer, dstream->tag, MPI_COMM_WORLD, &commstatus);
  }
#ifndef BLOCKING_RECV
  /* Take the chance to see if we can start recving into the buffer we have left */
  dstream->recv_started[1 - dstream->inbufno] = 0;
  mpistream_try_recv_init(stream, 1 - dstream->inbufno);
#endif
#ifdef TRACE_PACKET
  printf("mpistream_recv_packet@(%d): incoming_count=%d, inbufsize=%d\n",
		dstream->rank, incoming_count, dstream->inbufsize[dstream->inbufno]);
  for(i=0;i<dstream->inbufsize[dstream->inbufno];i++) {
    printf("%d",i%10);
  }
  printf("\n"); fflush(stdout);
  for(i=0;i<dstream->inbufsize[dstream->inbufno];i++) {
    a_putc(getstring(dstream->inbuf[dstream->inbufno])[i],stdoutstream);
  }
  a_message("|\n");
  fflush(stdout);
#endif
  dstream->recvpackets++;
  dstream->recvbytes += dstream->inbufsize[dstream->inbufno];
  dstream->inpos = 0;
}

int mpistream_writebytes(oidtype stream, void *inbuf, unsigned int len) {
  struct mpicell *dstream = dr(stream,mpicell);
  char *outbuf;
  char *ip = (char *)inbuf; /* ip iterates over inbuf */
  int rem = len;
  int outspace = dstream->outbufsize - dstream->outpos;
  while(rem >= outspace) {
    /* The line below is very expensive ;-) */
    outbuf = getstring(dstream->outbuf[dstream->outbufno]);
    if (0 == dstream->outpos) {
      MPI_Status status;
      MPI_Wait(&dstream->outrequest[dstream->outbufno], &status);
    }
    memcpy(outbuf + dstream->outpos, ip, outspace);
    dstream->outpos = dstream->outbufsize;
    mpistream_send_packet(dstream);
    rem = rem - outspace;
    ip = ip + outspace;
    outspace = dstream->outbufsize;
  }
	
  outbuf = getstring(dstream->outbuf[dstream->outbufno]);
  if (0 == dstream->outpos) {
    MPI_Status status;
    MPI_Wait(&dstream->outrequest[dstream->outbufno], &status);
  }
  memcpy(outbuf + dstream->outpos, ip, rem);
  dstream->outpos = dstream->outpos + rem;
  return TRUE;
}

int mpistream_readbytes(oidtype stream, void *outbuf, unsigned int len) {
  struct mpicell *dstream = dr(stream,mpicell);
  char *inbuf;
  char *op = (char *)outbuf; /* op iterates over outbuf */
  int rem = len;
  int inspace;
	
  while(rem >= (inspace = dstream->inbufsize[dstream->inbufno] - dstream->inpos)) {
    inbuf = getstring(dstream->inbuf[dstream->inbufno]);
    memcpy(op, inbuf + dstream->inpos, inspace);
    dstream->inpos = dstream->inpos + inspace;
    rem = rem - inspace;
    op = op + inspace;
    mpistream_recv_packet(stream);
    dstream = dr(stream,mpicell);
  }
  inbuf = getstring(dstream->inbuf[dstream->inbufno]);
  memcpy(op, inbuf + dstream->inpos, rem);
  dstream->inpos = dstream->inpos + rem;

  /* TODO: Investigate whether this really pays off */
  /*#ifndef BLOCKING_RECV
    if (!dstream->recv_started[1-dstream->inbufno]) {
    mpistream_try_recv_init(stream,1-dstream->inbufno);
    }
    #endif*/

  return TRUE;
}

void register_mpi_stream() {
  extfunction3("open-mpi", open_mpifn);
  mpitype = a_definetype("mpi", destroy_mpistream, NULL);
  mpistreamtype = a_define_stream_implementation(mpitype,
						 mpistream_getc,
						 mpistream_ungetc,
						 mpistream_feof,
						 NULL, /* No mpistream_puts */
						 mpistream_putc,
						 mpistream_fflush,
						 mpistream_fclose);
  typefns[mpistreamtype].is_stream = mpistreamtype;
  stream_implementations[mpitype].writebytes = mpistream_writebytes;
  stream_implementations[mpitype].readbytes = mpistream_readbytes;
  /*stream_implementations[mpitype].writebytes = NULL;
    stream_implementations[mpitype].readbytes = NULL;*/
}
