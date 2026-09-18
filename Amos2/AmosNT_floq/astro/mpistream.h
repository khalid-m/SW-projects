/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 * $RCSfile: mpistream.h,v $
 * $Revision: 1.21 $ $Date: 2006/05/05 16:10:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos stream abstraction on top of MPI
 ****************************************************************************/
#include <mpi.h>

#define MPI_PACKETS_PER_BUF 1

struct mpicell {
  objtags tags;
  short int bytes;            /* Total size of object in bytes, incl. header */
  char autoflush;                      /* Flush after each item and new line */
  char filler[3];                                            /* Unused flags */
  int streamtype;                                       /* Always MPI_STREAM */
  int line_num;                                       /* Current line number */
  oidtype logstream;
  /*** end of stream header ***/
  int opened;                                    /* TRUE while stream opened */
	int closed;                                     /* FALSE while stream open */
  int tag;
  int peer;
  int rank;

  oidtype inbuf[2];
  int inpos, inbufno, inbufsize[2], maxinbufsize[2];
  MPI_Request inrequest[2];
	int recv_started[2];

  oidtype outbuf[2];
	int outbufno;
  int outpos, outbufsize;
  MPI_Request outrequest[2];
	int sentbytes;
	int sentpackets;
	int recvbytes;
	int recvpackets;
	int prefetch_recvbytes;
	int prefetch_recvpackets;
};


/* MPI stream primitives */

oidtype new_mpistream(int peer, int tag, int bufsiz);
oidtype open_mpifn(bindtype env, oidtype peer, oidtype tag, oidtype bufsize);
int mpistream_getc(oidtype mpistream);
int mpistream_ungetc(int c, oidtype mpistream);
int mpistream_feof(oidtype mpistream);
int mpistream_putc(int c, oidtype mpistream);
int mpistream_fflush(oidtype mpistream);
int mpistream_fclose(oidtype mpistream);
int mpistream_poll(oidtype stream);

void mpistream_send_packet(struct mpicell *dstream);
void mpistream_recv_packet(oidtype stream);

int mpistream_writebytes(oidtype stream, void *inbuff, unsigned int len);
int mpistream_readbytes(oidtype stream, void *outbuff, unsigned int len);
void mpistream_try_recv_init(oidtype stream, int bufno);

void register_mpi_stream();
void mpistream_printstat(oidtype stream);
