#include "../C/callout.h"
#include "../C/complex.h"
#include "fftcomplex.h"
#include "numarray.h"
#include "comm.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "udpq.h"
#ifdef NT
#include <dos.h>
#include <winsock2.h>
#include <winbase.h>
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
#define HANDLE pthread_t
#define DWORD long int
#define SOCKET int
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1
#define INLINE inline
#define LPVOID void
extern int errno;
#endif

#define QUEUESIZE 2000
#define REMPORT 4096
#define MAXBUFLEN 2048			// Max packet size


#ifdef LINUX
static void *udpproc(void *arg)
#endif
#ifdef NT
DWORD udpproc(LPVOID* arg)
#endif
{
	DWORD sockfd = *(DWORD*)arg;
	int numbytes,   // number of bytes recieved
		buflen;     // length of the buffer
	short sbuf[MAXBUFLEN];  // buffer
	struct sockaddr_in from;
	int fromlen = sizeof(from);
	oidtype udpqs = mksymbol("_udp-qs_");
	oidtype q=nil;
	struct udpqcell *dq;
	
	buflen=sizeof(sbuf);
	/*sockfd = connecttoserv();
	identusr(sockfd);
	scale(sockfd);
	startstop(sockfd, 1);*/
	
	while (1) {
		if (nil != globval(udpqs)) {
			numbytes=recvfrom(sockfd, (char *) sbuf, MAXBUFLEN-1 , 0, (struct sockaddr *)&from, &fromlen);
			if (numbytes == SOCKET_ERROR) sockerror("Recvfrom error\n");
			q = getqueue(from);
			dq = dr(q,udpqcell);
			if (dq->head!=(dq->tail+1)%dq->length) // if queue not full, encode
				decode_radio_buffer(dq, sbuf);
		}
		if (2 == dq->status) {
			scale(sockfd);     // changes the scale
			dq->status = 1;
		}
	}
	/* clean up */
	for (q=globval(udpqs); q != nil; q=tl(q)) {
		startstop(sockfd, 0);
#ifdef LINUX
		close(sockfd);
		return arg;
#endif
#ifdef NT
		closesocket(sockfd);
		return TRUE;
#endif
	}
}

oidtype getqueue((struct sockaddr *)&from) {
}

void decode_radio_buffer() {
}

void udp_sleep (int delay) { // udp_sleeps for delay ms
  clock_t time;
  time=clock();  // gets the tics since program started
  while((clock()-time)*1000/CLOCKS_PER_SEC<delay);  // waits for delay ms
}

void startstop(SOCKET sockfd, struct sockaddr *, int i) {
  unsigned char txbuf[16];

  txbuf[0]='S';
  if(i) txbuf[1]='A';
  else txbuf[1]='C';
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
  udp_sleep(10);
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
  udp_sleep(10);
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));

}
