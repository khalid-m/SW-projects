/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 * $RCSfile: udpq.h,v $
 * $Revision: 1.8 $ $Date: 2010/12/06 23:16:09 $
 * $State: Exp $ $Locker:  $
 *
 * Description: UDP data queue
 *
 ***************************************************************************/

#include "comm.h"

#ifdef NT
#include <winsock2.h>
#endif
#ifdef LINUX
#include <pthread.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
extern int h_errno;
#define SOCKET int
#define DWORD long int
#define HANDLE pthread_t
#define INLINE inline
#define LPVOID void
extern int errno;
#endif

struct udp_data {
  float x[512];         // data x
  float y[512];         // data y
  float z[512];         // data z
  int number;           // packet number
};

struct udpqcell {
  objtags tags;
  short int status; // queue status: 0-stop, 1-go, 2-change scale, 3-is_stopped
  struct sockaddr_in peer; // key
  double newscale; // if scale is changed
};

extern int UDPQTYPE;
oidtype new_udpq(char* hostname, int length);
oidtype make_udpqfn(bindtype env, oidtype host, oidtype length);
void dealloc_udpq(oidtype q);
void register_udpq(void);
oidtype udpq_getaddrfn(bindtype env, oidtype q);

/* Private cell */

struct udpq_priv {
	double freq;
	double scale;
	int status;			// queue status: 0-stop, 1-go
  int head;       // first element
  int tail;       // first free location for a newly arriving element
  int length;
  struct sockaddr_in peer;
  void (*encoder) (short*, struct udpq_priv*);  // data encoder
  struct udp_data *data;  // data
};

struct udpqs {
	SOCKET my_listensock;
	int numqs;
	int active;
	DWORD threadID;
	HANDLE hThread;
	struct udpq_priv* qarray;
};

void init_priv_udpqs();
void init_priv_udpq(struct udpq_priv* qp, int length, char* hostname);
void UdpRadioEncoder (short *sbuf, struct udpq_priv* q);
SOCKET udp_bind_listensocket(u_short listenport);

void udp_startstop(SOCKET mysock, struct sockaddr_in remotesockaddr, int flag);
void udp_identusr(SOCKET sockfd, struct sockaddr_in remotesockaddr);
void udp_scale(SOCKET sockfd, struct sockaddr_in remotesockaddr, double newscale);

#ifdef LINUX
static void *udp_thread_proc(void *arg);
#endif
#ifdef NT
DWORD udp_thread_proc(LPVOID* arg);
#endif


// UDP sensor specific constants
#define UDP_FOFFS	  1.0000086 // Freq calibration
#define UDP_SFRQ	  6120.0    // Starting Frequency KHz
#define UDP_SENSORPORT 4096
#define UDP_DEFAULTSCALE
#define MAXBUFLEN 2048			// Max packet size
#define QLEN 2000

// Global UDP sensor data
extern struct udpqs Q;
extern int unknown_host, unknown_sensor_host, sock_nobind;

void start_udpq_thread_ext(a_callcontext cxt, a_tuple tpl);
void stop_udpq_thread_ext(a_callcontext cxt, a_tuple tpl);
