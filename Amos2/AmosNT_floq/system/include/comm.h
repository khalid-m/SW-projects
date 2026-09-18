/*****************************************************************************
 * AMOS
 * 
 * Author: (c) 1993, 1997, 2010
 *         Tore Risch, Magnus Werner, Erik Zeitler, EDSLAB, UDBL
 * Include file for communication package
 *
 */

#ifndef _comm_h_
#define _comm_h_  1

#include "environ.h"

#if defined(NT)
  #define FD_SETSIZE 10000
  #include <winsock2.h>
  #define ECONNREFUSED WSAECONNREFUSED
  #define AWOULDBLOCK WASEWOULDBLOCK
  #define ETIMEDOUT WSAETIMEDOUT
  #define sockerrno WSAGetLastError()
#endif

#include <sys/types.h>

#if defined(UNIX)
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <netdb.h>
  typedef unsigned int           SOCKET;
  #define AWOULDBLOCK WOULDBLOCK
  #define SOCKET_ERROR            (-1)
  #define SD_BOTH         0x02
  #define INVALID_SOCKET  (SOCKET)(~0)
  #define sockerrno errno
  #define HANDLE pthread_t
#endif

#ifndef SOMAXCONN
  #define SOMAXCONN 1000
#endif 

#define MonitorDescriptor(fd) FD_SET((fd), &monitored_descriptors)
#define UnMonitorDescriptor(fd) FD_CLR((fd), &monitored_descriptors)
#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define PACKET_SIZE 16384

#if defined(_MSC_VER) || defined(__BORLANDC__)
typedef unsigned __int64 ulong64;
typedef signed __int64 long64;
typedef signed __int32 long32;
#else
typedef unsigned long long ulong64;
typedef signed long long long64;
typedef signed long long32;
#endif

typedef void (*handler_func)(SOCKET descr,char *arg);
extern void SetIOHandler(int portid, SOCKET,handler_func,char *arg);
extern void RemoveIOHandler(SOCKET);
extern handler_func SetIOHandlerHook;
extern handler_func RemoveIOHandlerHook;
extern int check_descriptors_hang(void);
extern int check_descriptors_nohang(double);
extern fd_set monitored_descriptors;
extern char *sockerrorstring(int err);
extern void init_sockets(void);
EXTERN oidtype sockerror(char *tag);
EXTERN int open_socket(char *hostname, int portno, double timeout);
EXTERN oidtype open_socket_blockfn(bindtype env, oidtype host, oidtype port,
			    oidtype to, oidtype bgrecv, oidtype nb);
EXTERN oidtype accept_socket_blockfn(bindtype env, oidtype s);
EXTERN oidtype close_socketfn(bindtype env, oidtype s);
oidtype new_socket(oidtype host,int portno, SOCKET s, int bg, int nb, 
                   int listensock, oidtype destination);
oidtype socket_closedfn(bindtype env, oidtype s);
EXTERN oidtype poll_sockets_blockfn(bindtype env, oidtype sockarr, oidtype to,
							 oidtype writesock);
EXTERN oidtype lreadfn(bindtype env, oidtype str);
EXTERN oidtype lprintfn(bindtype env, oidtype x, oidtype str);

struct socketcell
{
  objtags tags;
  struct streamheader header;
  int closed;
  oidtype hostname;
  int portno;
  SOCKET socket;
  char* inbuff;
  int inpos;
  int inbuffsize;
  int outbuffsize;
  oidtype outbuff;
  int outpos;
  long64 sentbytes;
  int sentpackets;
  long64 receivedbytes;
  int receivedpackets;
  int bg;
  int bgbufnum;
  int ugc;
  char ugf;

  int nb;                   /* Flag indicates blocking or not */

};

// added peek bytes in the socket
EXTERN int socket_peekbytes(oidtype stream, void* buff, int len);
EXTERN int socket_inbytes(struct socketcell* stream);

struct bgrecv {
  SOCKET s;
  int close_req; /* 0 none, 1 close requested */
  int recvstate; /* 0 un-init, 1 recvable, 2 closed, 3 error */
  int readpos;
  int recvpos;
  int inbuffsize;
  int maxinbuffsize;
  int error;
  int loopt;
  long64 receivedbytes;
  int receivedpackets;
  char* inbuff;
  int required;
} rcv[FD_SETSIZE];

int getnumbgs();
int getfreebgnum();
int bgreceive(struct bgrecv* r);
int bgrecvnum(oidtype s);
void pollrecv(int numbgs);
int close_bgsock(struct bgrecv* r);
void print_bgr(struct bgrecv *r);

int recvstate(struct bgrecv *r);

extern oidtype CLOSING;
EXTERN int sockettype;
extern int trace_packet;   /* Will print packets sent/received when TRUE */

#ifdef NT
DWORD recv_thread_id;
DWORD recv_thread_fn(LPVOID* arg);
#else
static void *recv_thread_fn(void *arg);
#endif

# endif 
