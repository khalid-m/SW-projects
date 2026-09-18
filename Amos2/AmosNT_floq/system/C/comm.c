/*****************************************************************************
 * AMOS
 *
 * Author: (c) 1995, 1997, 1999, 2003, 2010
 *      Magnus Werner, Tore Risch, Martin Skold, Erik Zeitler, EDSLAB, UDBL
 * $RCSfile: comm.c,v $
 * $Revision: 1.87 $ $Date: 2013/12/31 11:27:03 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Communication primitives.
 *
 * Requirements:
 * ===========================================================================
 * $Log: comm.c,v $
 * Revision 1.87  2013/12/31 11:27:03  torer
 * No call to free() when communication initialized!
 *
 * Revision 1.86  2013/10/27 18:43:08  torer
 * opensocket retries works under OSX
 *
 * Revision 1.85  2013/10/27 10:21:32  torer
 * Apple background socket reading now connected
 *
 * Revision 1.84  2013/05/16 20:02:13  torer
 * Propagation of enter systen times for events added
 *
 * Revision 1.83  2013/04/29 19:18:21  torer
 * select() breaks WaitForMultipleObjects() waiting under OSX.
 *
 * Revision 1.82  2013/04/18 14:01:28  torer
 * Very unlikely image movement bug
 *
 * Revision 1.81  2013/04/12 12:17:17  sobso953
 * fixing another image-move bug.
 *
 * Revision 1.80  2012/06/28 20:00:32  torer
 * Global variables EXPORTTO and IMPORTFROM removed
 * New stream headers in C
 *
 * Revision 1.79  2012/06/22 13:38:00  torer
 * Client server callin interface completely in terms of bare bone
 * socket client interface
 *
 * Revision 1.78  2012/04/12 14:12:39  larme597
 * Bugfix. May have lost a reference.
 *
 * Revision 1.77  2011/12/30 16:48:48  torer
 * *** empty log message ***
 *
 * Revision 1.76  2011/12/12 11:33:22  larme597
 * Tweaks and bugfixes.
 *
 * Revision 1.75  2011/11/25 04:39:13  larme597
 * Bug fix. Error checking immediately after the concerned function call.
 *
 * Revision 1.74  2011/11/05 11:42:34  larme597
 * Added coroutine background to receive_packet() function.
 *
 * Revision 1.73  2011/10/25 11:29:55  larme597
 * Reading enters background if in a coroutine.
 *
 * Revision 1.72  2011/04/05 10:08:11  chexu484
 * error message if failed to set nonblocking
 *
 * Revision 1.70  2011/04/01 09:12:35  chexu484
 * non blocking print/read
 *
 * Revision 1.69  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.68  2011/01/12 00:33:26  zeitler
 * print_bgrfn gives state of circular buffer
 *
 * Revision 1.67  2011/01/06 17:10:17  zeitler
 * bug fix: close bg socket when deallocating
 *
 * Revision 1.66  2011/01/05 14:33:37  zeitler
 * lreadfn: richer error message when required > maxinbuffsize
 *
 * Revision 1.65  2010/12/30 19:00:46  zeitler
 * single threaded lread
 *
 * Revision 1.64  2010/12/27 08:58:04  torer
 * htons(x) takes unsigned short as arg. Alt. is htonl(x)
 *
 * Revision 1.63  2010/12/25 13:15:28  torer
 * removed CR
 *
 * Revision 1.62  2010/12/20 17:58:48  zeitler
 * init_socketstat bug fix
 *
 * Revision 1.61  2010/12/18 16:49:47  torer
 * Removed dead code
 *
 * Revision 1.60  2010/12/17 13:51:07  zeitler
 * Remove separators
 * Introduce lprintfn + lreadfn
 *
 * Revision 1.59  2010/12/13 14:09:54  torer
 * Non-blocking print
 *
 * Revision 1.58  2010/12/07 18:41:18  zeitler
 * excess free() eliminated
 *
 * Revision 1.57  2010/12/06 23:34:45  zeitler
 * socket_readpsfn()
 *
 * Revision 1.56  2010/12/06 17:51:48  zeitler
 * Added cases for closed and closing bgsockets
 *
 * Revision 1.55  2010/11/26 14:04:25  zeitler
 * bg recv thread fixes
 *
 * Revision 1.54  2010/11/24 13:04:34  zeitler
 * Bug fix in getc on bg recv
 *
 * Revision 1.53  2010/11/23 23:13:49  zeitler
 * bg recv thread handles binary data
 *
 * Revision 1.52  2010/11/19 18:54:32  zeitler
 * de/alloc of bgrecv buffers
 * start/stop of bgrecv thread
 * bgrecv readbytes
 *
 * Revision 1.51  2010/11/18 13:31:58  zeitler
 * a_sleep0 utilized by bg recv thread
 *
 * Revision 1.50  2010/11/18 13:23:15  zeitler
 * BG recv thread on Linux
 *
 * Revision 1.49  2010/11/18 12:16:25  zeitler
 * Background recv thread
 *
 * Revision 1.48  2010/11/05 20:26:35  zeitler
 * removed double assignment
 *
 * Revision 1.47  2010/11/05 20:14:31  zeitler
 * inbuff malloc()ed
 *
 * Revision 1.46  2010/10/27 12:18:13  zeitler
 * rand_sockets_blockfn() made Linux compatible
 *
 * Revision 1.45  2010/10/27 09:39:19  zeitler
 * optimizing rand_sockets_blockfn()
 *
 * Revision 1.44  2010/10/26 14:30:28  zeitler
 * Fixing rand() in rand_sockets_blockfn()
 *
 * Revision 1.43  2010/10/25 09:53:59  zeitler
 * Improved debug print in sendbytes()
 *
 * Revision 1.42  2010/10/18 21:19:11  torer
 * poll-sockets-block and rand-sockets-block have optional flag for testing 
 * for writing
 *
 * Revision 1.41  2010/08/26 14:29:55  zeitler
 * integer conversion bug fix in poll_sockets and check_descriptors_nohang
 *
 * Revision 1.40  2010/06/24 15:08:57  torer
 * FD_SETSIZE set to 2000
 *
 * Revision 1.39  2010/06/18 14:29:27  zeitler
 * sentbytes and receivedbytes are counted using int64
 *
 * Revision 1.38  2010/06/09 22:59:50  zeitler
 * rand-sockets is an alternative to poll-sockets
 *
 * Revision 1.37  2010/06/09 17:00:42  zeitler
 * coerce timeout in poll-sockets only when needed
 *
 * Revision 1.36  2010/06/03 07:23:10  torer
 * Using IntoStacKString instead of IntoString
 *
 * Revision 1.35  2010/05/25 14:56:11  fred2431
 * Compile under Linux
 *
 * Revision 1.34  2010/05/25 12:25:31  zeitler
 * WSAECONNRESET also closes stream
 *
 * Revision 1.33  2010/05/19 20:01:37  zeitler
 * Mark stream as closed if WSAECONNABORTED in sendbytes()
 *
 * Revision 1.32  2010/01/19 19:23:01  zeitler
 * Timeout parameter (open-socket host port &optional timeout)
 * useful when waiting for peers or nameservers to listen().
 *
 * Revision 1.31  2009/09/02 07:50:51  torer
 * listen_sock local
 *
 * Revision 1.30  2009/04/14 15:26:58  zeitler
 * Linux close(socket) in CloseDescriptor
 *
 * Revision 1.29  2008/04/18 11:16:40  zeitler
 * Removed print of EINTR in poll_socket
 *
 * Revision 1.28  2008/01/15 20:36:10  torer
 * Introduced (POLL-SOCKETS array-of-sockets timeout)
 *
 * Revision 1.27  2008/01/15 16:09:35  torer
 * Bug in server loop
 *
 * Revision 1.26  2007/09/27 16:37:39  torer
 * multicast-receive with sockets
 * (socket-closed s) tests if socket closed
 *
 * Revision 1.25  2007/09/27 14:37:18  torer
 * Removed trapping of "socket closed by peer" so that error generated instead
 *
 * Revision 1.24  2007/06/04 19:06:12  torer
 * Buffer-sensitive poll-socket
 *
 * Revision 1.23  2006/10/21 13:54:29  torer
 * (trace-packets t) now gives time stamped socket communication logging
 *
 * Revision 1.22  2006/10/20 17:20:43  torer
 * 1. Tries to reopens socket on 'socket rest by peer'
 * 2. Prints more information when (trace-packets t)
 *
 * Revision 1.21  2006/09/28 15:19:02  zeitler
 * Added (socket-hostname), which works analogously to (socket-portno)
 *
 * Revision 1.20  2006/09/26 09:09:54  zeitler
 * Bug fix in accept_socket_blockfn: Input data was destroyed.
 *
 * Revision 1.19  2006/09/21 20:55:00  zeitler
 * accept_socket_blockfn() now saves ip address (hostname) and tcp port 
 * (portno) of peer in socketcell.
 *
 * Revision 1.18  2006/08/30 15:23:32  zeitler
 * Added EINTR handler in poll_socket
 *
 * Revision 1.17  2006/08/29 13:39:35  zeitler
 * Bug fix of select() call in poll_socket
 *
 * Revision 1.15  2005/09/30 15:28:04  torer
 * Added primitives for basic socket communication
 *
 * Revision 1.12  2005/09/14 19:36:40  torer
 * autoflush flag introduced on streams to enforce automatic flushing.
 * By default stdoutstream has autoflush=TRUE
 *
 * Revision 1.11  2005/08/09 16:43:24  torer
 * 1. New optional stream methods for fast bulk encode/decode of
 *    binary data (in storage.h): writebytes and readbytes
 * 2. Memory corruption bug when allocating binary objects fixed.
 * 3. Textstreams can now handle also objects of type BINARY
 *
 * Revision 1.10  2005/03/22 20:29:26  torer
 * Release 7: Mostly minor changes to make documentation conform with code
 * Change: definetype in C renamed to a_definetype for consistent naming.
 *
 * Revision 1.9  2005/03/12 09:11:01  torer
 * Signatures of Amos II stream interface functions now analogous to C standard
 *
 * Revision 1.8  2004/10/18 21:08:36  torer
 * 1. Memory leak on server fixed
 * 2. Bug fixed that could make system crash sometimes
 * 3. More readable trace messages
 * Still problem that server loops when > 60 connections open.
 *
 * Revision 1.7  2004/10/15 14:50:08  torer
 * DEBUGFLG turned off
 *
 * Revision 1.6  2004/10/15 14:34:39  jope6369
 * Communication  between sockets.
 *
 * Revision 1.5  2004/08/20 15:24:19  torer
 * 1. The options to amos2.exe cleaned up. Now possible to have unnamed 
 *    clients and name servers.
 * 2. Dynamic redirection of standard input and output from Lisp possible
 *
 * Revision 1.4  2004/01/10 15:39:32  torer
 * 1. Removed 'socket reset by peer' error in communication package
 * 2. Communication error messages shorter
 *
 * Revision 1.3  2003/12/20 10:24:36  torer
 * Design error in streamed socket reader
 *
 * Revision 1.2  2003/12/15 22:45:44  torer
 * Messy communication problem fixed:
 * If several one-way messages sent too fast the system could loose messages.
 *
 * Revision 1.1  2003/08/05 14:26:40  torer
 * Source code in C for Amos II communication primitives now available
 *
 *
 *
 * Rewritten for Windows Sockets 2 by Tore Risch
 * Fully streamed reader.
 */

#include <errno.h>
#include "kernel.h"
#include "comm.h"
#include "coroutine.h"
#include "binary.h"
#include "storagetypes.h"
#include <stdio.h>
#include "a_time.h"
#include "wproctime.h"

#ifdef UNIX
#include <unistd.h>
#include <fcntl.h>
#define WSAECONNABORTED ECONNABORTED
#define WSAECONNRESET ECONNRESET
#define WSAEWOULDBLOCK EWOULDBLOCK
#define WSAEFAULT EFAULT
#endif

#ifdef NT
#define ECONNRESET WSAECONNRESET
#endif 

// Standard communication
//#define DEBUGFLG 1

// Main thread bgrecv related functions
//#define DEBUGBG 1

// bgrecv thread
//#define DEBUGBGT 1

// bgrecv thread, recv function + buffer ptrs
//#define DEBUGBGRECV 1

// print arriving packet content of bgrecv thread
//#define BGTRACE_PACKET

/* Error numbers: */
int illegal_descriptor, unknown_host, no_response, socket_closed,
  no_socket_selected, no_buffers_left, non_readable, no_thread,
  bg_socket_premat_closed, bg_uninit, form_too_big, set_nonblock_fail;

int bgrecv_running = 0; /* 1 if receive thread running */
int bgrecvt = 0; /* 1 if receive thread wanted */
int bgrecv_count = 0;
double bgrecv_time = 0.0, bgpr_time = 0.0;

struct sockaddr_in name_server;                   /* The name server address */
fd_set monitored_descriptors;              /* Array of monitored descriptors */
/*    Array of handler routines and arguments for the monitored descriptors: */
struct {handler_func fn; char *arg; oidtype socket;}Handler[FD_SETSIZE];
struct timeval immediate_ret = {(unsigned int)0, (unsigned int)0};
oidtype serv_eval;                                     /* Symbol SERVER-EVAL */
oidtype _socket_systime_;   /* Flag indicating that systime should be 
                               propagated on all socket streams */
fd_set rcv_descr;                   /* Socket descriptors for receive thread */
HANDLE recv_thread_h;                            /* Handle to receive thread */
int trace_packet = FALSE;                      /* Trace send/receive packets */
EXPORT int sockettype;                 /* Identifier for storage type SOCKET */
int bgbufsz;                     /* Size of background thread receive buffer */

// Coroutine stuff
extern void co_enterbg0();
extern void co_leavebg0();
#define ENTERBG co_enterbg0()
#define LEAVEBG co_leavebg0()

oidtype sockerror(char *tag)
{
  a_printerror(topframe(),sockerrno,sockerrorstring(sockerrno),mkstring(tag));
  return nil;
}

oidtype bgsockerror(int bgerrno, char *tag) {
  a_printerror(topframe(),bgerrno,sockerrorstring(sockerrno),mkstring(tag));
  return nil;
}

void RemoveInvalidDescriptor(fd_set *dset)
{
  fd_set fds;
  unsigned int i;

#ifdef DEBUGFLG
  a_message("RemoveInvalidDescriptor -->\n");
#endif
  for(i=0; i<FD_SETSIZE; i++)
    {
      if (FD_ISSET(i, dset))
        {
	  FD_ZERO(&fds);
	  FD_SET(i, &fds);
	  if (select(FD_SETSIZE, &fds, NULL, NULL, &immediate_ret) 
	      == SOCKET_ERROR)
	    switch (errno)
	      {
	      case EBADF:
		FD_CLR(i, dset); /* Do not monitor descriptor i */
#ifdef DEBUGFLG
		printf("RemoveInvalidDescriptor: Killing descriptor %i\n", i);
                fflush(stdout);
#endif
		break;
	      default:
		perror("RemoveInvalidDescriptor");
		break;
	      }
	}
    }
#ifdef DEBUGFLG
  a_message("<-- RemoveInvalidDescriptor\n");
#endif
}
int CloseDescriptor(SOCKET socket);

void CloseAllDescriptors(void)
{
  unsigned int i;
  fd_set *dset = &monitored_descriptors;

  for(i=0; i<FD_SETSIZE; i++)
    {
      if (FD_ISSET(i, dset))
	{
	  CloseDescriptor(i);
#ifdef DEBUGFLG
	  { char buffer[100];
	  sprintf(buffer, "CloseAllDescriptors: Killing descriptor %i\n", i);
	  a_message(buffer);
          }
#endif
	}
    }
  return;
}

void SetIOHandler(
		  int portid,
		  SOCKET fd
                  /* The descriptor */,
		  handler_func func
                  /* The handler to be associated with the descriptor */,
		  char *arg
                  /* argument passed to handler */)
{
  if (fd == INVALID_SOCKET || fd >= FD_SETSIZE)
    {
      a_error(illegal_descriptor,mkinteger(fd),FALSE);
      return;
    };
  Handler[fd].fn = func;
  Handler[fd].arg = arg;
  a_let(Handler[fd].socket, new_socket(mkstring(""), portid,fd,0,0,0,nil));
  MonitorDescriptor(fd);
}

void RemoveIOHandler(SOCKET fd)
{
  oidtype s;

  if ((fd > FD_SETSIZE)) /* Too large => not active */
    return;
  s = Handler[fd].socket;
  if(s==nil) return;
  if(dr(s,socketcell)->closed) return;
  dr(s,socketcell)->closed = TRUE;
  UnMonitorDescriptor(fd);
  Handler[fd].fn = NULL;
  rem_hashtable(globval(mksymbol("_server-ports_")),
                Handler[fd].socket); /* Temporary fix */
  a_free(Handler[fd].socket);
}

int check_descriptors(struct timeval *timeout)
     /**********************************************************
      Check if there is any thing on monitored file descriptors
      and return the filedescriptor that contains data or -1 
     **********************************************************/
{
  int cur_desc = 1;
  static fd_set descriptors;
  int r_descs, r_descs_count, check_error;

  descriptors = monitored_descriptors;
  ENTERBG;
#ifdef DEBUGFLG
    fprintf(stderr,"select->\n");
#endif
  r_descs = select(FD_SETSIZE,  &descriptors, NULL, NULL, timeout);
  check_error = errno;
#ifdef DEBUGFLG
    fprintf(stderr,"<-select %i\n",r_descs);
#endif
  LEAVEBG;
  switch (r_descs)
    {
    case SOCKET_ERROR:
      switch (check_error)
        {
	case EBADF:
	  RemoveInvalidDescriptor(&monitored_descriptors);
	default:
	  sockerror("Check descriptors");
	}
      break;

    case 0: /* Time out */
      return -1;

    default: /* Something to be read */
      {
        int i;

	r_descs_count = r_descs;
        for(i=0;i<FD_SETSIZE;i++)
	  {
	    if (FD_ISSET(i, &descriptors))
	      {
		/* Pass the descriptor and argument to the handler called */
		Handler[i].fn(i,Handler[i].arg);
		// Don't check more sockets than needed
		if (--r_descs_count == 0)
		  break;
	      }
          }
      };
      return cur_desc;
    };
  return -1;
}

int check_descriptors_hang()
{
  return check_descriptors(NULL);
}

int check_descriptors_nohang(double to)
{
  struct timeval timeout;
  int res, sec,usec;

  sec=(int)floor(to);
  usec=(int)((to-sec)*1000000);

  timeout.tv_sec = sec;
  timeout.tv_usec = usec;
  res = check_descriptors(&timeout);
#ifdef DEBUGFLG
    fprintf(stderr,"check descriptors returned %d\n",res);
#endif
  return res;
}

int sendbytes(struct socketcell *dstream)
{
  int i, wrote, size=dstream->outpos;
  char *buff = getstring(dstream->outbuff);
  SOCKET sock = dstream->socket;

  for(i=0; i<size;)
    {
      wrote = send(sock, buff + i, size-i, 0);
      if (wrote == SOCKET_ERROR)
	switch (sockerrno)
	  {
	  case EINTR:  /* User Interrupt */
	    DoInterrupt();
	    break;
	  case WSAEWOULDBLOCK: /* Nonblocking */
	    dstream->sentbytes += i;
	    dstream->outpos -= i;
	    return EOF;
	    break;
	  case WSAECONNABORTED:
	  case WSAECONNRESET:
	    dstream->closed = TRUE;
	  default:
	    sockerror("SEND");
	    return FALSE;
	  }
      else
	{
#ifdef DEBUGFLG
          char buffer[100];

	  sprintf(buffer, "sendfn: Wrote %i remaining %i on %i\n", wrote,
		  (size-(i+wrote)), sock);
          a_message(buffer);
#endif
	  i += wrote;
	}
    }
  dstream->sentbytes += size; // really should be here instead of in send_packet
  dstream->outpos = 0;
  return TRUE; /* OK */
}

EXPORT int poll_sockets(SOCKET socks[], int sockets, double to, int writesock)
{
  fd_set fds;
  int r_descs, r_descs_count, sec, usec, i;
  struct timeval timeout;
  int check_error;

  sec=(int)floor(to);
  usec=(int)((to-sec)*1000000);
  timeout.tv_sec = sec;
  timeout.tv_usec = usec;
  FD_ZERO(&fds);
  for(i=0; i<sockets; i++)
    FD_SET(socks[i], &fds);
  for(;;)
    {
      ENTERBG;
      if(writesock) r_descs = select(FD_SETSIZE, NULL, &fds, NULL, &timeout);
      else r_descs = select(FD_SETSIZE, &fds, NULL, NULL, &timeout);
      check_error = sockerrno;
      LEAVEBG;
      switch (r_descs)
        {
	case SOCKET_ERROR:
	  switch (check_error)
	    {
	    case EINTR:  /* User Interrupt */
#ifdef DEBUGFLG
	      a_message("poll_sockets: Interrupt occurred\n");
#endif
	      DoInterrupt();
	      return FALSE;
	    default:
	      sockerror("poll-socket");
	      return FALSE;
	    }
	case 0: /* Time out */
	  CheckInterrupt;
	  return FALSE;
	default: /* Something arrived or allowed to be written */
	  CheckInterrupt;
	  r_descs_count = r_descs;
          for(i=0; i<sockets; i++)
	    { 
              if (FD_ISSET(socks[i], &fds))
		{
		  socks[i] = -1; /* Mark as active */
		  // Don't check more sockets than needed
		  if (--r_descs_count == 0)
		    break;
		}
            }
	  return r_descs; 
        }
    }
}

int poll_socket(SOCKET sock, double to, int writesock)
{
  SOCKET socks[1];

  socks[0] = sock;
  return poll_sockets(socks, 1, to, writesock);
}

int CloseDescriptor(SOCKET socket)
{
#ifdef DEBUGFLG
  printf("CloseDescriptor: closing socket %d\n",socket); fflush(stdout);
#endif
  RemoveIOHandler(socket);
  shutdown(socket,SD_BOTH);
#ifdef NT
  return closesocket(socket);
#else
  return close(socket);
#endif
}

int receive_packet(oidtype s);
int socket_eod(oidtype); /* Forward declaration */

void ProcessRemoteReqError(SOCKET descriptor,char *arg)
{unwind_protect_begin; /* Catch errors in error handler */
 release(call_lisp(mksymbol("server-errorhandler"), varstack, 1, 
		   Handler[descriptor].socket));
 unwind_protect_catch;
 if(unwind_reset && a_errorflag) 
   {
     char buffer[100];
     a_message("Error caught from SERVER-ERRORHANDLER:\n");
     sprintf(buffer,"Error %d: %s ",a_errno,a_errstr);
     a_message(buffer);
     a_print(a_errform);
   }
 CloseDescriptor(descriptor);
}

void ProcessRemoteReq(SOCKET descriptor,char *arg)
     /****************************************************************
      Evaluate a remote request present at DESCRIPTOR 
      by calling SERVER-EVAL. SERVER-EVAL will get message by calling
      (READ s) and return eventual result by (PRINT s)(FLUSH s) 
     ****************************************************************/

{
#ifdef DEBUGFLG
  char buffer[100];

  sprintf(buffer, "ProcessRemoteReq: Incoming on descriptor %i\n",
	  descriptor);
  a_message(buffer);
#endif
  { unwind_protect_begin;
  if(receive_packet(Handler[descriptor].socket))
    {
      while(!socket_eod(Handler[descriptor].socket))
	{
	  release(call_lisp(serv_eval, varstack, 1, 
			    Handler[descriptor].socket));
	}
    }
  else CloseDescriptor(descriptor); /* Other side closed */
  unwind_protect_catch;
  if(unwind_reset) ProcessRemoteReqError(descriptor, arg);
  }
}

void NewConnectionHandler(SOCKET ls,char *arg)
     /*******************************************************************
      Accept connections on ls creating a new socket which will
      be monitored for incoming messages.
      Register the new socket with ProcessRemoteReq which
      will be called when something is available at the socket.
     *******************************************************************/
{
  SOCKET newsock;

  newsock = accept(ls, NULL, NULL);
  if (newsock ==  INVALID_SOCKET)
    sockerror("NewConnectionHandler: ");
#ifdef DEBUGFLG
  { char buffer[100];
  sprintf(buffer, "NewConnectionHandler: New descriptor %i\n", newsock);
  a_message(buffer);}
#endif
  SetIOHandler(-1,newsock, ProcessRemoteReq, arg);
  return;
}

int listensocket(int port, SOCKET *sock)
     /*******************************************
      Open listen socket on given port.
      Return socket id in *sock.
      port == 0 => System assigns free port.
      Port number returned.
     *******************************************/
{
  int length = 0;
  unsigned short p = port;
  SOCKET  temp;
  SOCKET portno;
  struct sockaddr_in me; /* My address */

  portno = htons(p);
  temp = socket(AF_INET, SOCK_STREAM, 0);
  if (temp == INVALID_SOCKET) sockerror("Cannot open listening socket");
  *sock = temp;

  /* Name socket using wildcards: */
  me.sin_family = AF_INET;
  me.sin_addr.s_addr = INADDR_ANY;
  me.sin_port = portno;
  if (bind(*sock, (struct sockaddr *)&me, sizeof(me)) == SOCKET_ERROR)
    sockerror("Cannot bind listening socket");

#ifdef DEBUGFLG
  printf("Socket %d to listen on port %d\n",temp,portno); fflush(stdout);
#endif

  /* establish a socket to listen for an incoming connection */
  listen(*sock, SOMAXCONN);

  /* Find out assigned port number */
  length = sizeof(me);
  if (getsockname(*sock, (struct sockaddr *)&me, &length)
      == SOCKET_ERROR)
    sockerror("Cannot get listening socket name");
  /* convert port from TCP/IP network byte order to host byte order: */
  return ntohs(me.sin_port); /* Return our port */
}

int startlisten(int pno, handler_func receivefn)
     /****************************************************************** 
      Make this peer act as a server accepting connection calls and
      calls for remote evaluation by ProcessRemoteReq.
      Returns the port number on which it is listening for connections. 
     *******************************************************************/
{
  int portno;
  SOCKET ls;

  portno = listensocket(pno, &ls);
  SetIOHandler(portno, ls, NewConnectionHandler, (char *)receivefn);
  return portno;
}

oidtype startlistenfn(bindtype env, oidtype port)
{
  int portno=0;

  if(port != nil) IntoInteger(port,portno,env);
  return mkinteger(startlisten(portno,ProcessRemoteReq));
}

int open_socket(char *hostname, int pno, double timeout)
/******************************************************************
      Open new socket to host listening on given port number.
      hostname == NULL => server socket listening for connections.
      hostname == NULL && portno == 0 => system assigns port number 
******************************************************************/
{
  SOCKET sock;
  int retry = 2;
  const int retries = retry;
  struct sockaddr peer;
  struct sockaddr_in *peerp = (struct sockaddr_in *)&peer;
  struct hostent *pp;
  int portno;
  unsigned short p=pno;

  do
    {
      portno = htons(p);
      sock = socket(AF_INET, SOCK_STREAM, 0);
      if (sock == INVALID_SOCKET) sockerror("Cannot create socket");
#ifdef DEBUGFLG
      { char buffer[100];
	sprintf(buffer, "open_socket: Socket descriptor is %i\n", sock);
	a_message(buffer);
      }
#endif
      peerp->sin_family = AF_INET;
      peerp->sin_port = portno;
      pp = gethostbyname(hostname);
      if (pp == NULL)
	{
	  CloseDescriptor(sock);
	  a_error(unknown_host,mkstring(hostname),FALSE); /* leak! */
	  return 0;
	}
      memcpy((char *)&peerp->sin_addr,(char *)pp->h_addr,pp->h_length);
#ifdef DEBUGFLG
      {char buffer[100];
	sprintf(buffer, "gethostbyname: name: %s sin_addr: %i h_addr: %i\n",
		pp->h_name, peerp->sin_addr, pp->h_addr);
	a_message(buffer);
	sprintf(buffer, "open_socket: calling connect on port %i\n",
		peerp->sin_port);
	a_message(buffer);}
#endif
	if (connect(sock, &peer, sizeof(peer)) == SOCKET_ERROR) {
	  switch (sockerrno) {
	  case EINTR:
#ifdef DEBUGFLG
	    a_message("open_socket: Interrupt occurred\n");
#endif
	    DoInterrupt();
	    break;
	  case ECONNREFUSED:
#ifdef DEBUGFLG
	    printf("Connection refused %d retries left\n", retry);
#endif
	    a_sleep(timeout / retries);
	    if (!(retry--))
	      {
		sockerror("Connection refused in open_socket");
	      }
	    break;
	  case ETIMEDOUT:
	    if (!(retry--))
	      {
		sockerror("Connection timed out in open_socket");
	      }
	    break;
	  default:
	    printf("Error %d\n", sockerrno);
	    sockerror("Error in connect called from open_socket");
	    break;
	  }
	} else {
	  retry = -1;
	}
      }
      while (retry >= 0);
      return sock;
    }

void init_socketstat(struct socketcell *s)
{
  s->sentbytes = 0;
  s->sentpackets = 0;
  s->receivedbytes = 0;
  s->receivedpackets = 0;
  if (s->bg) {
    rcv[s->bgbufnum].receivedpackets = 0;
    rcv[s->bgbufnum].receivedbytes = 0;
  }
}

int getfreebgnum() { // return a free bg socket inbuffer
  int ret;
  for (ret = 0; ret < FD_SETSIZE; ret++) {
#ifdef DEBUGBG
    printf("[getfreebgnum %d: size %d]", ret, rcv[ret].maxinbuffsize);
#endif
    if (0 == rcv[ret].maxinbuffsize) {
      return ret;
    }
  }
  a_error(no_buffers_left, nil, FALSE);
  return -1;
}

int getnumbgs() { // number of active bg sockets
  int i, ret = 0;
  for (i = 0; i < FD_SETSIZE; i++) {
    if (rcv[i].recvstate == 1) {
      ret++;
    }
  }
  return ret;
}

void start_bgrecv_thread() {
  if (bgrecv_running) {
    printf("Thread already running. Won't start another one.\n");
  } else {
#ifdef NT
    recv_thread_h = CreateThread(NULL, 0,
				 (LPTHREAD_START_ROUTINE) recv_thread_fn, 
				 NULL, 0, &recv_thread_id);
#else
    if (pthread_create(&recv_thread_h, NULL, &recv_thread_fn, NULL) !=0 ) {
      a_error(no_thread, nil, FALSE);
    }
#endif
  }
}


oidtype new_socket(oidtype host, int portno, SOCKET s, int bg, int nb, 
                   int listensock, oidtype destination)
     /***********************************
      Allocate new socket stream object 
     ***********************************/
{
  oidtype res;
  int outbuffsize = PACKET_SIZE+1, i, inbuffsize = 2*outbuffsize, nbres;
  struct socketcell *dres;

  res = new_object(sizeof(*dres),sockettype);
  init_streamheader(&dr(res,socketcell)->header);
  a_let(dr(res,socketcell)->outbuff,new_string(outbuffsize,""));
  dres = dr(res,socketcell);
  a_let(dres->hostname,host);
  a_setf(dres->header.destination, destination);
  getstring(dres->outbuff)[outbuffsize-1]='\0';
  dres->portno = portno;
  
  // setting socket to be nonblocking
  if (nb)
    {
#ifdef NT
      nbres = ioctlsocket(s, FIONBIO, &nb);
      if (nbres != NO_ERROR)
	return a_error(set_nonblock_fail, nil, FALSE);
      printf("set nonblocking socket!\n");
#else
      fcntl(s, F_SETFL, O_NONBLOCK);
      printf("set nonblocking socket!\n");      
#endif     
    }
  dres = dr(res,socketcell);
  dres->socket = s;
  dres->inpos = 0;
  dres->inbuffsize = 0;
  dres->outbuffsize = 0;
  dres->closed = FALSE;
  dres->outpos = 0;
  dres->bgbufnum = -1;
  dres->ugc = 0;
  dres->ugf = 0;
  dres->bg = bg;
  dres->nb = nb;
  if(globval(_socket_systime_)!= nil) dres->header.systime=TRUE;
  if (bg) {
    struct bgrecv* r;
    dres->bgbufnum = getfreebgnum();
#ifdef DEBUGFLG
    printf("[new_socket: init bgbufnum %d]\n", dres->bgbufnum);
#endif
    init_socketstat(dres);
    r = &rcv[dres->bgbufnum];
    r->maxinbuffsize = bgbufsz;
    r->inbuffsize = r->maxinbuffsize;
    r->inbuff = malloc(sizeof(char) * r->maxinbuffsize);
    memset(r->inbuff, ' ', sizeof(char) * r->maxinbuffsize);
    FD_SET(s, &rcv_descr);
    r->s = s;
    if (bgrecvt && !getnumbgs()) {
      start_bgrecv_thread();
      while (!bgrecv_running) {
	a_sleep0(0.01);
      }
    }
    r->recvstate = 1;
  } else {
    dres->inbuff = malloc(sizeof(char) * inbuffsize);
    for (i=0; i < inbuffsize; i++) {
      dres->inbuff[i] = ' ';
    }
    dres->inbuff[inbuffsize-1]='\0';
    init_socketstat(dres);
  }
#ifdef DEBUGFLG
  printf("New socket %d on port %d\n",s,portno); fflush(stdout);
#endif
  return res;
}

void init_bgbuf(struct bgrecv* r) {
  r->s = 0;
  r->close_req = 0;
  r->readpos = 0;
  r->recvpos = 0;
  r->required = 0;
  r->inbuff = NULL;
  r->inbuffsize = 0;
  r->maxinbuffsize = 0;
  r->recvstate = 0;
  r->error = 0;
  r->loopt = 0;
}

void free_bgbuf(struct bgrecv* r) {
  free(r->inbuff);
  init_bgbuf(r);
}

void request_close_bgsocket(struct socketcell* ds) {
  struct bgrecv* r;
  int recvstate;
#ifdef DEBUGFLG
  printf("[request_close_bgsocket: bgbufnum %d]\n", ds->bgbufnum);
#endif
  r = &rcv[ds->bgbufnum];
  recvstate = r->recvstate;
  switch(recvstate) {
  case 0: // non-initialized
    return;
  case 1:
    r->close_req = 1;
    if (bgrecv_running) {
      while (r->recvstate == 1) {
	printf(".");
	a_sleep0(1.0); // wait until bg recv t has closed
      }
    } else { // No bg thread running: Call close_bgsock from main thread
      close_bgsock(r);
    }
    if (r->recvstate == 3) {
      char buffer[100];
      sprintf(buffer, "when attempting to close bgbufnum %d desc %d", 
	      ds->bgbufnum, r->s);
      bgsockerror(r->error, buffer);
      break;
    } // TODO: Test readp and socket_eod. Close and deallocate.
    break;
  case 2: // descriptor is closed but data might be in buffer. Do nothing.
    if (bgrecv_running) {
      printf("[request_close_bgsocket: bgbufnum %d recvstate 2 (closing)]\n",
	     ds->bgbufnum);
    }
    break;
  case 3: {
    char buffer[100];
    sprintf(buffer, "when attempting to close bgbufnum %d desc %d", 
	    ds->bgbufnum, r->s);
    bgsockerror(r->error, buffer);
    break;
  }
  }
}
extern int image_loaded;
void deallocsocket(oidtype s) {
  struct socketcell *ds = dr(s,socketcell);

#ifdef DEBUGBG
  printf("deallocsocket bgbufnum %d", ds->bgbufnum);
#endif
  if(!image_loaded);
  else if (ds->bg) {
    struct bgrecv* r;
    r = &rcv[ds->bgbufnum];
    request_close_bgsocket(ds);
      free_bgbuf(r);
  } else {
    free(ds->inbuff);
  }
  free_streamheader(&ds->header);
  a_free(ds->outbuff);
  a_free(ds->hostname); 
  if(!ds->closed && image_loaded) CloseDescriptor(ds->socket);
  dealloc_object(s);
  return;
}

void printsocket(oidtype s, oidtype stream, int flg)
{
  a_puts("#[socket ",stream);
  a_prin1(dr(s,socketcell)->hostname,stream,FALSE);
  a_putc(' ',stream);
  a_puts(IntegerToString(dr(s,socketcell)->portno),stream);
  a_putc(' ',stream);
  a_puts(IntegerToString(dr(s,socketcell)->socket),stream);
  a_putc(']',stream);
  return;
}

oidtype open_socket_blockfn(bindtype env, oidtype host, oidtype port,
			    oidtype to, oidtype bg, oidtype nb)
     /****************************************************************
      Lisp function to open socket to host on given port.
      If  host == nil a port listening for connections is opened.
      If  host == nil and port == 0 a new listening port is assigned 
     ****************************************************************/
{
  int  portno;
  double timeout;
  SOCKET sock;
  oidtype res;
  char *hostname;

  IntoInteger(port, portno, env);
  IntoStackString(host, hostname, env);
  timeout = coerce_real(env, to);

  if(host!=nil)sock = open_socket(hostname,(short int)portno, timeout);
  else /* Make socket listening for connections */
    {
      host = nil;
      portno = listensocket(portno,&sock);
    }
  res = new_socket(host, portno, sock, bg != nil, nb != nil, host == nil, nil);
  return res;
}

EXPORT oidtype open_socket_to_serverfn(bindtype env, oidtype servername, 
                                       oidtype host, oidtype port,
			               oidtype to)
     /****************************************************************
      Lisp function to open socket to named server 
      running on given host listening on given port.
     ****************************************************************/
{
  int  portno;
  double timeout;
  SOCKET sock;
  oidtype res;
  char *hostname;

  IntoInteger(port, portno, env);
  IntoStackString(host, hostname, env);
  IntoDouble(to,timeout,env);

  sock = open_socket(hostname,(short int)portno, timeout);
  res = new_socket(host, portno, sock, FALSE, FALSE, FALSE, servername);
  return res;
}

oidtype socket_destinationfn(bindtype env, oidtype s)
{
  OfType(s,sockettype,env);
  return dr(s, socketcell)->header.destination;
}

EXPORT oidtype close_socketfn(bindtype env, oidtype s)
{
  SOCKET sock;
  struct socketcell *ds = dr(s,socketcell);

  OfType(s,sockettype,env);
  sock = ds->socket;

#ifdef DEBUGFLG
  printf("close_socketfn: closing socket %d\n",sock); fflush(stdout);
#endif

  if (ds->bg) {
    request_close_bgsocket(ds);
  } else {
    CloseDescriptor(sock);
    ds->closed = TRUE;
  }
  return s;
}

oidtype socket_closedfn(bindtype env, oidtype s) {
  struct socketcell *ds;
  struct bgrecv *r;
  int recvstate;

  OfType(s, sockettype, env);
  ds = dr(s, socketcell);
  if (!(ds->bg)) {
    if(ds->closed)
      return t;
    return nil;
  }
  r = &rcv[ds->bgbufnum];
  recvstate = r->recvstate;
#ifdef DEBUGBG
  printf("[socket_closedfn: desc %d, recvstate %d]\n", r->s, recvstate);
#endif
  switch (recvstate) {
  case 0:
    return t;
  case 1:
    return nil;
  case 2:
    if (ds->bg) {
      if (!socket_eod(s))
	return mksymbol("closing");
      else
	return t;
    }
  case 3: // socket error
    {
      char buffer[100];
      sprintf(buffer, "bg recv thread when closing descriptor %d", r->s);
      bgsockerror(r->error, buffer);
    }
  }
  return t;
}

int recvstate(struct bgrecv *r) {
  return r->recvstate;
}

oidtype socket_recvstatefn(bindtype env, oidtype s) {
  struct socketcell *ds;
  OfType(s,sockettype,env);
  ds = dr(s,socketcell);
  if (ds->bg) {
    int state = recvstate(&rcv[ds->bgbufnum]);
    if (state) {
      return mkinteger(state);
    } else {
      return nil;
    }
  }
  return nil; // non bg socket has no recvstate
}

void print_bgr(struct bgrecv *r) {
  printf("[recvst %d, readpos %d, recvpos %d, bsz %d]\n", 
	 r->recvstate, r->readpos, r->recvpos, r->inbuffsize);
}

oidtype print_bgrfn(bindtype env, oidtype s) {
  struct socketcell *ds;
  ds = dr(s, socketcell);
  if (ds->bg) {
    print_bgr(&rcv[ds->bgbufnum]);
  }
  return nil;
}

void socket_printcont(struct bgrecv *r, int limit) {
  int pos;
  char* buff = r->inbuff;
  printf("[socket_printcont: recvpos %d, readpos %d, bsz %d]\n", r->recvpos,
	 r->readpos, r->inbuffsize);
  printf("[");
  for (pos=0; pos < limit; pos++) {
    if (buff[pos] == 10)
      printf(" ");
    else 
      a_putc(buff[pos],stdoutstream);
    printf("|");
  }
  printf("]\n[");
  for (pos=0; pos < limit; pos++) {
    if (pos == r->recvpos)
      printf("r");
    else if (pos == r->readpos)
      printf("R");
    else 
      printf(" ");
    printf("|");
  }
  printf("]\n");
}

oidtype socket_printcontfn(bindtype env, oidtype s) {
  struct socketcell *ds;
  struct bgrecv *r;
  OfType(s,sockettype,env);
  ds = dr(s,socketcell);
  if (!(ds->bg)) {
    return nil;
  }
  r = &rcv[ds->bgbufnum];
  socket_printcont(r, r->inbuffsize);
  return nil;
}

int bgrecvnum(oidtype s) {
  struct socketcell* ds;
  ds = dr(s, socketcell);
  if(!(ds->bg))
    return -1;
  return ds->bgbufnum;
}

oidtype bgrecvnumfn(bindtype env, oidtype s) {
  OfType(s, sockettype, env);
  return mkinteger(bgrecvnum(s));
}

oidtype accept_socket_blockfn(bindtype env, oidtype s)
     /**************************************************
      Wait for connection on socket. Blocks. 
      Return new listening socket when connection done. 
     **************************************************/
{
  SOCKET newsock;
  struct socketcell *ds;
  int c_len = 0, portno = 0, bg = 0, nb = 0;
  oidtype hostname = nil;
  struct sockaddr_in c_addr;
  char *hn;

  OfType(s,sockettype,env);
  ds = dr(s,socketcell);
  bg = ds->bg;
  nb = ds->nb;
  c_len = sizeof(c_addr);
  memset((void*)&c_addr, 0, c_len);
  newsock = accept(ds->socket, (struct sockaddr*)&c_addr, &c_len);
  hn = (char *)inet_ntoa(c_addr.sin_addr);
  a_setf(hostname,mkstring(hn));
  portno = ntohs(c_addr.sin_port);
#ifdef DEBUGFLG
  printf("Client ");
  a_print(ds->hostname);
  printf(", port %d connected.\n", ds->portno); fflush(stdout);
#endif
  if(newsock == SOCKET_ERROR) {sockerror("ACCEPT-SOCKET"); return nil;}
  return new_socket(hostname, portno, newsock, bg, nb, FALSE, nil);
}

oidtype poll_sockets_blockfn(bindtype env, oidtype sockarr, oidtype to,
                             oidtype writesock)
{
  double timeout;
  int sockets, i, j=0, active, *hasbuffcont;
  SOCKET *socks;
  oidtype s, res;

  sockets = a_arraysize(sockarr);
  hasbuffcont = alloca(sockets*sizeof(*socks));

  if (writesock == nil) {
    for(i=0; i<sockets; i++)
      {
	if(!socket_eod(a_elt(sockarr, i)))
	  { 
	    hasbuffcont[i]=TRUE;
	    j++;
	  }
	else hasbuffcont[i]=FALSE;
      }
    if(j>0)
      {
	res = new_array(j, nil);
	j = 0;
	for(i=0; i<sockets; i++)
	  {
	    if(hasbuffcont[i])
	      {
		a_seta(res, j, a_elt(sockarr, i));
		j++; 
	      }
	  }
	return res;
      }
  }

  socks = alloca(sizeof(SOCKET)*sockets);
  for(i=0; i<sockets; i++)
    {
      s = a_elt(sockarr, i);
      socks[i] = dr(s, socketcell)->socket;
    }
  timeout = coerce_real(env,to);
  if(!(active=poll_sockets(socks, sockets, timeout, writesock!=nil))) 
    return nil;
  res = new_array(active, nil);
  for(i=0; i<sockets; i++)
    {
      if(socks[i]==-1)
        {
          a_seta(res, j, a_elt(sockarr, i));
          j++;
        }
    }
  return res;
}

oidtype rand_sockets_blockfn(bindtype env, oidtype sockarr, oidtype to,
                             oidtype writesock) 
{
  double timeout;
  int sockets, i, j, active, *cumul;
  SOCKET *socks;
  oidtype s;

  sockets = a_arraysize(sockarr);
  cumul = alloca(sockets*sizeof(int));

  if (writesock == nil) {
    if (!socket_eod(a_elt(sockarr, 0)))
      cumul[0] = 1;
    else
      cumul[0] = 0;
    for(i=1; i < sockets; i++) {
      if(!socket_eod(a_elt(sockarr, i)))
	cumul[i] = cumul[i-1] + 1;
      else
	cumul[i] = cumul[i-1];
    }
    if (cumul[sockets - 1] > 0) {
      double rnd = ((double)cumul[sockets - 1]) * rand()/(RAND_MAX+1.0);
      j = 1 + (int) rnd;
      for (i=0; i<sockets; i++) {
	if (cumul[i] >= j) {
	  return a_elt(sockarr, i);
	}
      }
      // This should be unreachable
      a_error(no_socket_selected, nil, FALSE);
    }
  }

  socks = alloca(sizeof(SOCKET)*sockets);
  for(i=0; i<sockets; i++) {
    s = a_elt(sockarr, i);
    socks[i] = dr(s, socketcell)->socket;
  }
  timeout = coerce_real(env, to);
  if (!(active = poll_sockets(socks, sockets, timeout, writesock!=nil)))
    return nil;
  if (socks[0] == -1)
    cumul[0] = 1;
  else
    cumul[0] = 0;
  for(i=1; i<sockets; i++) {
    if(socks[i] == -1)
      cumul[i] = cumul[i-1] + 1;
    else
      cumul[i] = cumul[i-1];
  }
  if (cumul[sockets - 1] > 0) {
    double rnd = ((double)cumul[sockets - 1]) * rand()/(RAND_MAX+1.0);
    j = 1 + (int) rnd;
    for (i=0; i<sockets; i++) {
      if (cumul[i] >= j) {
	return a_elt(sockarr, i);
      }
    }
    // This should be unreachable
    a_error(no_socket_selected, nil, FALSE);
  }
  return nil;
}

oidtype socket_portnofn(bindtype env, oidtype s)
{
  OfType(s,sockettype,env);
  return mkinteger(dr(s,socketcell)->portno);
}

oidtype socket_hostnamefn(bindtype env, oidtype s)
{
  OfType(s,sockettype,env);
  return dr(s,socketcell)->hostname;
}

oidtype gethostaddressfn(bindtype env, oidtype hostnm)
     /* Get host address as integer */
{
  struct hostent *he;
  char *host, buffer[100];

  IntoStackString(hostnm, host, env);
  he = gethostbyname(host);
  if (he == NULL)
    sockerror("GETHOSTADDRESS");
  if (sizeof(int)!=he->h_length)
    {
      a_message("gethostaddressfn: address length no equal to size of int\n");
      sprintf(buffer, "Address length is %i\n", he->h_length);
      a_message(buffer);
      return nil;
    }
#ifdef DEBUGFLG
  sprintf(buffer, "Address is %x\n",
	  ((struct in_addr *)(he->h_addr))->s_addr);
  a_message(buffer);
#endif
  return mkinteger(((struct in_addr *)(he->h_addr))->s_addr);
}

oidtype gethostnamefn(bindtype env)
     /* Get host name as string */
{
  char            name[50];
  int             namelen = sizeof(name);
  struct hostent *he;

  if (!gethostname(name, namelen))
    {
      he = gethostbyname(name);
      if(he!=NULL) return (mkstring(he->h_name));
    }
  return sockerror("GETHOSTNAME");
}

oidtype check_descriptorsfn(bindtype env, oidtype to)
     /***********************************************************
      Check currently active descriptors for callbacks.
      'to' is optional timeout
     ***********************************************************/
{
  double timeout;

  if(to == nil) {check_descriptors_hang(); return nil;}
  timeout = coerce_real(env,to);
  check_descriptors_nohang(timeout);
  return nil;
}

oidtype close_all_socketsfn(bindtype env)
{
  CloseAllDescriptors();
  return nil;
}

oidtype nameserverhostfn(bindtype env)
{
  oidtype nsh=mksymbol("_nameserverhost_");

  if(globval(nsh)!=nil) return globval(nsh);
  if(getenv("amos-nameserverhost")!=NULL)
    {
      a_setf(globval(nsh),
             mkstring(getenv("amos-nameserverhost")));
      return globval(nsh);
    }
  a_setf(globval(nsh),gethostnamefn(env));
  return globval(nsh);
}

oidtype bigint(long64 x) {
  if (x < 2147483647)
    return mkinteger((int)x);
  else
    return mkreal(x + 0.0);
}

oidtype socketstatfn(bindtype env, oidtype socket)
{
  struct socketcell *s;

  OfType(socket,sockettype,env);
  s = dr(socket,socketcell);
  return a_list(bigint(s->sentbytes), mkinteger(s->sentpackets),
		bigint(s->receivedbytes), mkinteger(s->receivedpackets),
		NULL);
}

oidtype socketstat_clearfn(bindtype env, oidtype socket)
{
  OfType(socket,sockettype,env);
  init_socketstat(dr(socket,socketcell));
  return socket;
}

/***************  Socket stream primitives **********************/

int close_socket_stream(oidtype stream)
{
  close_socketfn(topframe(),stream);
  return 0;
}

void send_packet(struct socketcell *dstream)
{
  if(trace_packet)
    {
      char *buff = getstring(dstream->outbuff);
      int i;
      char msgbuff[100];

      sprintf(msgbuff,"%s Sending on socket %d, port %d:\n",a_now(),
              dstream->socket, dstream->portno);
      a_message(msgbuff);
      for(i=0;i<dstream->outpos;i++)
	a_putc(buff[i],stdoutstream);
      a_message("|\n");
    }
  if (EOF != sendbytes(dstream))
    dstream->sentpackets++;
}

int receive_packet(oidtype stream)
{
  int rdc;
  struct socketcell *dstream = dr(stream, socketcell);
  char *buff = dstream->inbuff;
  int check_error;

  CheckInterrupt;
#ifdef DEBUGFLG
  { char buffer[100];
  sprintf(buffer,"recieve_packet will read %d bytes on socket %d port %d\n",  
	  PACKET_SIZE,dstream->socket, dstream->portno);
  a_message(buffer);}
#endif
  ENTERBG;
  rdc = recv(dr(stream, socketcell)->socket,buff,PACKET_SIZE,0);
  check_error = sockerrno;
  LEAVEBG;
  dstream = dr(stream, socketcell);
  dstream->inpos = 0;
  dstream->inbuffsize=0;
  CheckInterrupt;
#ifdef DEBUGFLG
  {char buffer[100];
  sprintf(buffer,"recv returned %d \n",rdc);
  a_message(buffer);
  }
#endif
  if(rdc==0) return FALSE; /* Other side closed */
  if(rdc==SOCKET_ERROR)
    {
      switch (check_error)
	{
	case EINTR:
	  DoInterrupt();
	  break;
	case WSAEWOULDBLOCK:
	  return FALSE;  // nothing to be received RETURN EOF?
        case ECONNRESET:
          return FALSE; /* Other side closed down */
	default:
	  sockerror("receive_packet");
	  break;
	}
    }
  if(rdc<0) return FALSE; /* Other side closed down */
  dstream = dr(stream, socketcell);
  dstream->receivedbytes = dstream->receivedbytes + rdc;
  dstream->inbuffsize = rdc;
  dstream->receivedpackets++;
  if(trace_packet)
    {
      int i;
      char msgbuff[100];

      sprintf(msgbuff, "%s Received on socket %d, port %d:\n", a_now(),
              dstream->socket, dstream->portno);
      a_message(msgbuff);
      for(i=0;i<rdc;i++)
	a_putc(buff[i],stdoutstream);
      a_message("|\n");
    }
  return TRUE;
}

oidtype trace_packetsfn(bindtype env, oidtype flg)
{
  if(flg==nil) trace_packet = FALSE;
  else trace_packet = TRUE;
  return flg;
}

int socket_eod(oidtype stream) {
  if(stream==nil) return TRUE; /* Closed socket */
  {
    struct socketcell *dstream = dr(stream,socketcell);
    char *buff = dstream->inbuff;
    int i, buffsize = dstream->inbuffsize;

    if(dstream->closed) return TRUE;
    for(i=dstream->inpos;i<buffsize;i++) {
      if (!whitespace(buff[i])) {
	dstream->inpos = i; /* Skip whitespace */
	return FALSE; /* More to read on socket */
      }
    }
    dstream->inpos = buffsize;
    return TRUE; /* Nothing more to read */
  }
}

oidtype socket_bgrecvpfn(bindtype env, oidtype socket) {
  struct socketcell *ds;
  OfType(socket, sockettype, env);
  ds = dr(socket, socketcell);
  if (ds->bg) return t;
  return nil;
}

oidtype socket_bgbufnum(bindtype env, oidtype socket) {
  struct socketcell *ds;
  OfType(socket, sockettype, env);
  ds = dr(socket, socketcell);
  if (ds->bg) {
    return mkinteger(ds->bgbufnum);
  }
  return nil;
}

oidtype socket_getbgbufsz(bindtype env) {
  return mkinteger(bgbufsz);
}

oidtype socket_setbgbufsz(bindtype env, oidtype size) {
  int sz = getinteger(size);
  bgbufsz = sz;
  return size;
}

oidtype bgrecvpfn(bindtype env) {
  if (bgrecvt)
    return t;
  return nil;
}

oidtype set_bgrecvfn(bindtype env, oidtype flag) {
  if (flag != nil)
    bgrecvt = 1;
  else
    bgrecvt = 0;
  return bgrecvpfn(env);
}

int socket_getc(oidtype stream) {
  struct socketcell *dstream = dr(stream,socketcell);
  char *buffer;
  int res;

  if (dstream->ugf) {
    dstream->ugf = 0;
    return dstream->ugc;
  }

  if (!dstream->bg) {
    buffer = dstream->inbuff;
    if(dstream->inpos >= dstream->inbuffsize) {
      int ok = receive_packet(stream);
      if(!ok) {
	a_error(socket_closed,stream,FALSE);
	return EOF;
      }
    }
    dstream = dr(stream, socketcell); // May have lost ref
    res = buffer[dstream->inpos];
    dstream->inpos++;
  } else {
    struct bgrecv *r = &rcv[dstream->bgbufnum];
    if (r->readpos == r->recvpos) {
      a_error(non_readable, stream, FALSE);
    }
    if (r->readpos >= r->inbuffsize) {
      if (r->recvpos == r->readpos) {
	a_error(non_readable, stream, FALSE);
      }
      r->readpos = 0;
    }
    buffer = r->inbuff;
    res = buffer[r->readpos];
    r->readpos++;
    if (r->readpos >= r->inbuffsize) {
      r->readpos = 0;
    }
  }
  return res;
}

int socket_ungetc(int c, oidtype stream) {
  struct socketcell *dstream = dr(stream,socketcell);
  dstream->ugf = 1;
  dstream->ugc = c;
  return c;
}

size_t socket_readbytes(oidtype stream, void *outbuff, unsigned int len)
{
  struct socketcell *dstream = dr(stream,socketcell);
  char *inbuff;
  char *op = (char *)outbuff;
  int rem = len;
  int inspace;
  int ok;

  if (!(dstream->bg)) {
    inbuff = dstream->inbuff;
    while(rem >= (inspace = dstream->inbuffsize - dstream->inpos))
      {
	memcpy(op, inbuff + dstream->inpos, inspace);
	dstream->inpos = dstream->inpos + inspace;
	rem = rem - inspace;
	op = op + inspace;
	ok = receive_packet(stream);
	dstream = dr(stream, socketcell); // May have lost ref
	if(!ok)
	  {
	    a_error(socket_closed,stream,FALSE);
	    return EOF;
	  }
      }
    memcpy(op, inbuff + dstream->inpos, rem);
    dstream->inpos = dstream->inpos + rem;
    return TRUE;
  } else {
    struct bgrecv* r = &rcv[dstream->bgbufnum];
    if (r->readpos < r->recvpos) { // Must have received beyond the binary
      if (rem > r->recvpos - r->readpos) {
	if (r->recvstate == 2)
	  a_error(bg_socket_premat_closed, stream, FALSE);
	a_error(non_readable, stream, FALSE);
      }
    } else { // wrap-around
      if (rem > r->recvpos + r->inbuffsize - r->readpos) {
	if (r->recvstate == 2)
	  a_error(bg_socket_premat_closed, stream, FALSE);
	a_error(non_readable, stream, FALSE);
      }
    }
    inbuff = r->inbuff;
    if (r->readpos < r->recvpos) {
      memcpy(op, inbuff + r->readpos, len);
      r->readpos += len;
    } else { // wrap-around: copy up to inbuffsize + remaining, move readpos
      inspace = r->inbuffsize - r->readpos;
      if (inspace > rem) {
	memcpy(op, inbuff + r->readpos, len);
	r->readpos += len;
      } else {
	memcpy(op, inbuff + r->readpos, inspace);
	op = op + inspace;
	rem = rem - inspace;
	memcpy(op, inbuff, rem);
	r->readpos = rem;
      }
    }
    return TRUE;
  }
}

int feof_socket_stream(oidtype stream)
{
  return dr(stream,socketcell)->closed;
}

int socket_putc(int c, oidtype stream)
{
  struct socketcell *dstream = dr(stream,socketcell);
  char *buff;

  buff = getstring(dstream->outbuff);

  // checking the buffer first?
  buff[dstream->outpos] = (char)c;
  dstream->outpos++;
  if(dstream->outpos >= PACKET_SIZE)
    send_packet(dstream);
  return c;
}

size_t socket_writebytes(oidtype stream, void *inbuff, unsigned int len)
{
  struct socketcell *dstream = dr(stream,socketcell);
  char *outbuff = getstring(dstream->outbuff);
  char *ip = (char *)inbuff;
  int rem = len;
  int outspace = PACKET_SIZE - dstream->outpos;

  if (dstream->nb)  // nonblocking and atomic write
    {
      // trying to send if data to be sent couldnot fit in the outbuffer
      while (rem > outspace) {
	send_packet(dstream);
	if (outspace == PACKET_SIZE - dstream->outpos)  // didn't send anything
	  return EOF;
	else
	  outspace = PACKET_SIZE - dstream->outpos;  // sent something
      }
      memcpy(outbuff + dstream->outpos, ip, len);
      dstream->outpos += len;
      return TRUE;
    }
  else
    {
      while(rem >= outspace)
	{
	  memcpy(outbuff + dstream->outpos, ip, outspace);
	  dstream->outpos = PACKET_SIZE;
	  send_packet(dstream);
	  rem = rem - outspace;
	  ip = ip + outspace;
	  outspace = PACKET_SIZE;
	}
      memcpy(outbuff + dstream->outpos, ip, rem);
      dstream->outpos = dstream->outpos + rem;
      return TRUE;
    }
}


int fflush_socket_stream(oidtype stream)
{
  struct socketcell *dstream = dr(stream,socketcell);

#ifdef DEBUGFLG
  a_message("fflush\n");
#endif
  send_packet(dstream);
  return 0;
}

int socket_inbytes(struct socketcell* stream) {
  return stream->inbuffsize - stream->inpos;
}

int socket_peekbytes(oidtype stream, void* buff, int len)
     /****** peek if there are enough bytes *******/
     /********** if true fill the buff ************/
     /********* return EOF otherwise *************/
{
  char *inbuff;
  int inbuffsize, inpos, rdc;
  char *ip = (char*)buff;
  struct socketcell *dstream;
  int check_error;

  dstream = dr(stream, socketcell);
  inbuff = dstream->inbuff;
  inpos = dstream->inpos;
  inbuffsize = dstream->inbuffsize;

  if (inbuffsize - inpos >= len)
    {
      memcpy(ip, inbuff + inpos, len);
      return 1;
    }
  else
    {
      ENTERBG;
      rdc = recv(dr(stream, socketcell)->socket, inbuff + inbuffsize, PACKET_SIZE, 0);
      check_error = sockerrno;
      LEAVEBG;
      if(rdc==SOCKET_ERROR)
	{
	  switch (check_error)
	    {
	    case WSAEWOULDBLOCK:
	      return 0;   // has nothing to read
	      break;
	      case WSAEFAULT:
	      return 0;
	      break;
	    default:
	      sockerror("peekbytes");
	      break;
	    }
	}
      if (rdc < 0) return 0;   // closed down?
      dstream = dr(stream, socketcell);
      dstream->receivedbytes += rdc;
      dstream->inbuffsize += rdc;
      if (dstream->inbuffsize - inpos >= len)
	{
	  memcpy(ip, inbuff + inpos, len);
	  return 1;
	} else
	  return 0; // try again?
    }
}


int close_bgsock(struct bgrecv* r) {
  int ret;
#ifdef DEBUGBGT
  printf("--> [close_bgsock: desc %d recvstate %d ...]\n", r->s, r->recvstate);
#endif
  FD_CLR(r->s, &rcv_descr);
  ret = shutdown(r->s, SD_BOTH);
  if (ret == 0) {
    r->recvstate = 2;
#ifdef DEBUGBGT
    printf("<-- [close_bgsock: desc %d ok recvstate %d]\n", r->s, 
	   r->recvstate);
#endif
    return 0;
  }
#ifdef DEBUGBGT
  printf("<-- [close_bgsock: error %d desc %d]\n", sockerrno, r->s);
#endif
  r->error = sockerrno;
  r->recvstate = 3;
  return -1;
}

void pollrecv(int numbgs) {
  struct timeval timeout;
  int ready, ready_count, bufnum, receive_result, fullcount, recvcount;
  fd_set rset;
  double rt;
  int check_error;

  timeout.tv_sec = 0;
  timeout.tv_usec = 1;
  rset = rcv_descr;
  ENTERBG;
  ready = select(FD_SETSIZE, &rset, NULL, NULL, &timeout);
  check_error = sockerrno;
  LEAVEBG;
  switch (ready) {
  case SOCKET_ERROR:
    switch (check_error) {
    case EINTR:
      if (bgrecvt) {
	printf("[pollrecv: EINTR]");
      } else {
	DoInterrupt();
      }
      break;
    default:
      printf("[pollrecv: select_error %d, numbgs %d]\n", sockerrno, numbgs);
      a_sleep0(1.0);
      break;
    }
    break;
  case 0: // timeout
    break;
  default:
    fullcount = 0;
    recvcount = 0;
    ready_count = ready;
    for (bufnum=0; bufnum < FD_SETSIZE; bufnum++) {
      if (FD_ISSET(rcv[bufnum].s, &rset)) {
	if (rcv[bufnum].recvstate == 1) {
	  recvcount++;
	  bgrecv_count++;
	  rt = run_time();
	  receive_result = bgreceive(&rcv[bufnum]);
	  bgrecv_time += run_time() - rt;
	  switch (receive_result) {
	  case 0:
	    fullcount++;
	    break;
	  case -1:
	    printf("[pollrecv: error on bgsocket %d, desc %d]\n", bufnum, 
		   rcv[bufnum].s);
	    break;
	  }
	} else {
	  printf("[pollrecv: data on bgsocket %d, recvstate %d]\n", bufnum, 
		 rcv[bufnum].recvstate);
	  a_sleep0(1.0);
	}
	// Don't check more sockets than needed
	if (--ready_count == 0)
	  break;
      }
    }
    break;
  }
  if (fullcount == recvcount) {
#ifdef DEBUGBGT
    printf("[pollrecv: %d buffers full, %d recv (%d total) => sleep]\n", 
	   fullcount, recvcount, numbgs);
#endif
    //a_sleep0(0.001); // sleep some if buffer is full
  }
  // purge sockets to close
  for (bufnum = 0; bufnum < numbgs; bufnum++) {
    if (rcv[bufnum].close_req) {
      struct bgrecv* r = &rcv[bufnum];
      if (r->recvstate == 2) {
      } else {
	close_bgsock(r);
      }
      r->close_req = 0;
    }
  }
}

#ifdef NT
DWORD recv_thread_fn(LPVOID* arg)
#else
     static void *recv_thread_fn(void *arg)
#endif
{
  int numbgs;

#ifdef DEBUGBGT
  printf("[bgt: start]\n");
#endif

  bgrecv_running = 1;
  while(getnumbgs() == 0) {
    a_sleep0(0.02);
  }

  while((numbgs = getnumbgs()) && (numbgs > 0)) {
    pollrecv(numbgs);
  }

  FD_ZERO(&rcv_descr); // just to make sure
  bgrecv_running = 0;
  printf("[bgrecv_count %d, bgrecv_time %f, bgpr_time %f]\n", bgrecv_count,
	 bgrecv_time, bgpr_time);
#ifdef DEBUGBGT
  printf("[bgt: stop]\n");
#endif
#ifdef NT
  return TRUE;
#else
  return NULL;
#endif
}

int bgreceive(struct bgrecv* r) {
  int rdc, pos, readpos, recvpos;
  int spaceleft = 0;

  readpos = r->readpos;
  recvpos = r->recvpos;
  if (readpos > recvpos) {
    spaceleft = readpos - recvpos - 1; // recvpos must never reach readpos
#ifdef DEBUGBGRECV
    printf("--> [bgrecv: readpos %d > recvpos %d spaceleft=%d]\n", readpos,
	   recvpos, spaceleft);
#endif
  } else if (readpos < recvpos) {
    spaceleft = r->maxinbuffsize - recvpos;
#ifdef DEBUGBGRECV
    printf("--> [bgrecv: readpos %d < recvpos %d spaceleft=%d]\n", readpos,
	   recvpos, spaceleft);
#endif
    if(spaceleft < 1) {
      if (readpos > 0) { // we can loop recvpos
	r->loopt++;
	recvpos = 0;
	spaceleft = readpos - recvpos - 1;
#ifdef DEBUGBGRECV
	printf("[bgrecv: looped recv spaceleft=%d]\n", spaceleft);
#endif
      }
    }
  } else if (recvpos == readpos) { 
    // readpos has reached recvpos => we can recv a full buffer
    spaceleft = r->maxinbuffsize - recvpos;
#ifdef DEBUGBGRECV
    printf("--> [bgrecv: readpos %d == recvpos %d spaceleft=%d]\n", readpos,
	   recvpos, spaceleft);
#endif
    if (spaceleft < 1) { // readpos == recvpos == maxinbuffsize => loop
      if (readpos > 0) {
	r->loopt++;
	recvpos = 0;
	spaceleft = readpos - recvpos - 1;
#ifdef DEBUGBGRECV
	printf("[bgrecv: looped recv spaceleft=%d]\n", spaceleft);
#endif
      }
    }
  } else {
#ifdef DEBUGBGRECV
    printf("--> [bgrecv: readpos != recvpos && readpos == recvpos] ???\n");
#endif
  }
  if (spaceleft < 1) {
#ifdef DEBUGBGRECV
    printf("[bgrecv: spaceleft %d give up ", spaceleft);
#endif
    return 0;
  }
#ifdef DEBUGBGRECV
  printf("[bgrecv: recv %d B on pos %d:", spaceleft, recvpos);
#endif
  rdc = recv(r->s, &r->inbuff[recvpos], spaceleft, 0);
#ifdef DEBUGBGRECV
#ifdef BGTRACE_PACKET
  printf(" got %d |", rdc);
#else
  printf(" got %d]\n", rdc);
#endif
#endif
#ifdef BGTRACE_PACKET
  printf("|", rdc, r->s);
  for (pos=recvpos; pos < recvpos + rdc; pos++) {
    a_putc(r->inbuff[pos], stdoutstream);
  }
  printf("|]\n");
#endif
  if (rdc == 0) { // other end closed
#ifdef DEBUGBGRECV
    printf("[bgrecv: other end closed descr %d => close_bgsock()]\n", r->s);
#endif
    return close_bgsock(r);
  } else if (rdc == SOCKET_ERROR) {
    switch (sockerrno) {
    case WSAECONNABORTED:
    case WSAECONNRESET:
#ifdef DEBUGBGRECV
      printf("[bgrecv: conn reset descr %d => close_bgsock()]\n", r->s);
#endif
      return close_bgsock(r);
    default:
      printf("[bgrecv: socket error %d on recv descr %d]\n", sockerrno, r->s);
      r->error = sockerrno;
      r->recvstate = 3;
      return -1;
    }
  } else if (rdc < 0) {
    printf("[bgrecv: (rdc=%d) other side closed? errno %d]", rdc, sockerrno);
    r->error = sockerrno;
    r->recvstate = 3;
    return -1;
  }
  r->receivedbytes += rdc;
  r->receivedpackets++;
  pos = recvpos + rdc;
#ifdef DEBUGBGRECV
  printf("<-- [bgrecv: recvpos %d, rdc %d, new recvpos %d]\n", recvpos, rdc,
	 pos);
#endif
  if (pos == r->maxinbuffsize) {
    if (readpos > 0) {
      pos = 0;
      r->loopt++;
    }
  }
  r->recvpos = pos;
  return 1;
}


#define LREADHSIZE 4

int lreadlen(oidtype str) {
  long32 size = 0;
  a_readbytes(str, &size, LREADHSIZE);
  return size;
}

int require_inbuff(struct bgrecv* r, int size) {
  int recvpos, readpos;
  recvpos = r->recvpos;
  readpos = r->readpos;
#ifdef DEBUGFLG
  {
    int i;
    printf("[require_inbuff: readpos %d, recvpos %d, size %d", readpos,
	   recvpos, size);
    if (size == LREADHSIZE) {
      a_putc('|', stdoutstream);
      for (i = readpos; i < readpos + 4; i++) {
	a_putc(r->inbuff[i], stdoutstream);
      }
      a_putc('|', stdoutstream);
    }
    printf("]\n");
  }
#endif
  if (recvpos == readpos) { // readpos has reached recvpos
    return 0; // wait until new data is recv'd
  }
  if (recvpos >= readpos + size) { // enough size
    return 1;
  }
  if (recvpos < readpos) {
    if (r->maxinbuffsize + recvpos >= readpos + size) {
      return 1;
    }
  }
  return 0;
}

EXPORT oidtype lreadfn(bindtype env, oidtype str) {
	static oidtype busy_s = nil;
  oidtype tpl = nil;
  struct socketcell *ds;
  int formsize = 0, numbgs;

  if (busy_s == nil) {
    busy_s = mksymbol("*BUSY*");
  }

  if (a_datatype(str) == sockettype) {
    ds = dr(str, socketcell);
    if (ds->bg) {
      struct bgrecv* r = &rcv[ds->bgbufnum];
      if (!r->required) {
	if (!require_inbuff(r, LREADHSIZE)) {
	  numbgs = getnumbgs();
	  pollrecv(numbgs);
	  return busy_s;
	}
	r->required = lreadlen(str);
	if (r->required > r->maxinbuffsize) {
    int i;
    char* szp;
    szp = (char*)&r->required;
		printf("[length content |");
    for (i = 0; i < 4; i++) {
			a_putc(szp[i], stdoutstream);
    }
		printf("|]\n");
		print_bgr(r);
		a_error(form_too_big, a_list(mkinteger(r->required), mkstring(">"),
			mkinteger(r->maxinbuffsize), 
			a_list(mkinteger(szp[0]), mkinteger(szp[1]), mkinteger(szp[2]), 
			mkinteger(szp[3]), NULL), NULL), FALSE);
	}
#ifdef DEBUGFLG
	printf("[lreadfn: setting required %d]\n", r->required);
#endif
			}
      if (!require_inbuff(r, r->required)) {
				numbgs = getnumbgs();
	pollrecv(numbgs);
	return busy_s;
      }
      tpl = a_read(str);
      r->required = 0; // read successful => uncache required len
      return tpl;
    } else {
      formsize = lreadlen(str);
      // TODO: assure header is complete and readable
      if (ds->inbuffsize - ds->inpos >= formsize) {
	return a_read(str);
      } else {
	// TODO: wait for buffer to be refilled (loop select..recv)
      }
      return busy_s;
    }
  } else {
    return a_read(str);
  }
}

oidtype lprintfn(bindtype env, oidtype x, oidtype str)
{
  static oidtype pb=nil;
  oidtype pbuff;
  int sz;

  if(pb==nil)
    {
      pb = mksymbol("_nb-printbuff_");
    }
  if(a_datatype(globval(pb))!=TEXTSTREAMTYPE)
    {
      a_setf(globval(pb),new_textstream(PACKET_SIZE));
    }
  pbuff = globval(pb);
  dr(pbuff,textstreamcell)->pos = 0;
  printfn(env, x, pbuff);
  sz = dr(pbuff,textstreamcell)->pos-1;
#ifdef DEBUGFLG
  printf("[lprintfn: sz %d]\n", sz);
#endif
  if (sz > PACKET_SIZE) {
    a_error(form_too_big, x, FALSE);
    return nil;
  }
  a_writebytes(str, &sz, 4);
  a_writebytes(str, textstreambuffer(pbuff), sz);
  return x;
}

oidtype printtofn(bindtype env, oidtype form, oidtype socket, 
                  oidtype destination)
{
  OfType(socket, sockettype, env);

  a_setf(dr(socket,socketcell)->header.destination, destination);
  printfn(env, form, socket);
  return flushfn(env, socket);
}

oidtype readfromfn(bindtype env, oidtype socket, oidtype origin)
{
  OfType(socket, sockettype, env);
  a_setf(dr(socket,socketcell)->header.origin, origin);
  return readfn(env, socket);
}

void register_comm_functions(void) {
  int i;
  bgrecv_running = 0;
  bgrecvt = 0;
  bgbufsz = 65536;
#ifdef DEBUGBG
  printf("PACKET_SIZE %d, FD_SETSIZE %d, bgbufsz %d\n", PACKET_SIZE,
	 FD_SETSIZE, bgbufsz);
#endif

  illegal_descriptor = a_register_error("SetHandler: descriptor out of range");
  no_thread = a_register_error("Could not start bg recv thread");
  no_response = a_register_error("Server not responding");
  unknown_host = a_register_error("Unknown host");
  socket_closed = a_register_error("Socket closed by peer");
  no_socket_selected =
    a_register_error("Failed to select a socket in rand-socket");
  no_buffers_left = a_register_error("No background recv buffers left");
  non_readable = a_register_error("Socket not readable");
  bg_socket_premat_closed = a_register_error("BG socket closed prematurely");
  bg_uninit = a_register_error("BG socket uninitialized");
  form_too_big = a_register_error("Form too big for socket buffer size");
  set_nonblock_fail = a_register_error("Failed to set the socket nonblocking");

  serv_eval = mksymbol("server-eval");
  init_sockets();
  for (i=0; i < FD_SETSIZE; i++) {
    Handler[i].socket = nil;
    init_bgbuf(&rcv[i]);
  }
  FD_ZERO(&rcv_descr);
  _socket_systime_ = mksymbol("_socket-systime_");
  globval(_socket_systime_) = nil;

  sockettype = a_definetype("socket",deallocsocket,printsocket);
  a_define_stream_implementation(sockettype,socket_getc, socket_ungetc,
                                 feof_socket_stream,
                                 NULL, socket_putc, fflush_socket_stream,
                                 close_socket_stream);
  stream_implementations[sockettype].writebytes = socket_writebytes;
  stream_implementations[sockettype].readbytes = socket_readbytes;
  extfunction0("gethostname", gethostnamefn);
  extfunction1("gethostaddress", gethostaddressfn);
  extfunction1("startlisten", startlistenfn);
  extfunction5("open-socket-block", open_socket_blockfn);
  extfunction4("open-socket-to-server", open_socket_to_serverfn);
  extfunction1("close-socket",close_socketfn);
  extfunction1("socket-destination", socket_destinationfn);
  extfunction1("socket-recvstate",socket_recvstatefn);
  extfunction1("socket-closed",socket_closedfn);
  extfunction1("accept-socket-block",accept_socket_blockfn);
  extfunction3("poll-sockets-block",poll_sockets_blockfn);
  extfunction3("rand-sockets-block",rand_sockets_blockfn);
  extfunction1("socket-portno",socket_portnofn);
  extfunction1("socket-hostname",socket_hostnamefn);
  extfunction1("check-descriptors",check_descriptorsfn);
  extfunction0("close-all-sockets",close_all_socketsfn);
  extfunction0("nameserverhost",nameserverhostfn);
  extfunction1("socketstat",socketstatfn);
  extfunction1("socketstat-clear",socketstat_clearfn);
  extfunction1("trace-packets",trace_packetsfn);
  extfunction1("socket-printcont", socket_printcontfn);
  extfunction1("socket-bgrecvp", socket_bgrecvpfn);
  extfunction1("socket-bgbufnum", socket_bgbufnum);
  extfunction0("get-bgbufsize", socket_getbgbufsz);
  extfunction1("set-bgbufsize", socket_setbgbufsz);
  extfunction1("bgrecv", set_bgrecvfn);
  extfunction0("bgrecvp", bgrecvpfn);
  extfunction1("socket-printbgr", print_bgrfn);
  extfunction2("lprint", lprintfn);
  extfunction1("lread", lreadfn);
  extfunction3("printto", printtofn);
  extfunction2("readfrom", readfromfn);
  atexit(CloseAllDescriptors);
}
