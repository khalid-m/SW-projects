/****************************************************************************
* AMOS2
*
* Author: (c) 2007 Erik Zeitler, UDBL
* $RCSfile: udpq.c,v $
* $Revision: 1.6 $ $Date: 2010/12/30 19:44:10 $
* $State: Exp $ $Locker:  $
*
* Description: UDP data queue
*
***************************************************************************/

#include "callout.h"
#include "udpq.h"
#include "comm.h"
#include "amos.h"
#include "fftcomplex.h"
#include "numarray.h"

struct udpqs Q;
int UDPQTYPE;
int unknown_host, unknown_sensor_host, sock_nobind;

//#define DEBUG
//#define TRACE_PACKET

void dealloc_udpq(oidtype q) {
	struct udpqcell *dres;
	dres = dr(q,udpqcell);
	dres->status = 0;
	while(0 == dres->status) { // wait for status to change to 3
		call_lisp(mksymbol("sleep"), varstack, 1, mkreal(0.5));
	}
	/* Wait for status to change to */
	dealloc_object(q);
}

oidtype new_udpq(char* hostname, int qlength) {
	struct udpqcell *dres;
	oidtype res = new_object(sizeof(struct udpqcell), UDPQTYPE);
	
	dres = dr(res,udpqcell);
	dres->status = 2;
	dres->newscale = 12.0;
	return res;
}

oidtype make_udpqfn(bindtype env, oidtype host, oidtype length) {
	int len;
	if (integerp(length)) {
		len = getinteger(length);
	} else {
		len = 2000;
	}
	if (stringp(host)) {
		return(new_udpq(getstring(host), len));
	} else {
		return nil;
	}
}

oidtype udpq_stopfn(bindtype env, oidtype q) {
	struct udpqcell *dq;
	OfType(q, UDPQTYPE, env);
	dq = dr(q,udpqcell);
	dq->status = 0;
	return q;
}

oidtype udpq_scalefn(bindtype env, oidtype q, oidtype scale) {
	OfType(q, UDPQTYPE, env);
	while(dr(q,udpqcell)->status != 2) {
		call_lisp(mksymbol("sleep"), varstack, 1, mkreal(0.5));
	}
	dr(q,udpqcell)->newscale = getreal(scale);
	dr(q,udpqcell)->status = 2;
	return scale;
}

oidtype udpq_showfn(bindtype env, oidtype q) {
	struct udpqcell *dq;
	OfType(q, UDPQTYPE, env);
	dq = dr(q,udpqcell);
#ifdef DEBUG
	printf("address is (hex) %x\n", dq->peer.sin_addr.s_addr);
#endif
	return a_list(mkinteger(dq->status), mkreal(dq->newscale), 
		udpq_getaddrfn(env,q), NULL);
}

udpq_getaddr(struct udpqcell *dq) {
#ifdef DEBUG
	printf("address is (hex) %x\n", dq->peer.sin_addr.s_addr);
#endif
	return dq->peer.sin_addr.s_addr;
}

oidtype udpq_getaddrfn(bindtype env, oidtype q) {
	struct udpqcell *dq;
	OfType(q, UDPQTYPE, env);
	dq = dr(q,udpqcell);
	return mkinteger(udpq_getaddr(dq));
}

/***************************** PRIVATE UDPQS *****************************/

void init_priv_udpqs() { // This function is non-reentrant!
	int i;
	oidtype q, qs = globval(mksymbol("_sensor-ids_"));
	Q.active=0;
	Q.numqs = a_length(qs);
	Q.my_listensock = udp_bind_listensocket(UDP_SENSORPORT);
	if(-1 == Q.my_listensock) {
		  a_error(sock_nobind,nil,FALSE);
	}
	Q.qarray = (struct udpq_priv*)malloc(Q.numqs*sizeof(struct udpq_priv));
	i=0;
	for (q=qs; q!=nil; q=tl(q)) {
		init_priv_udpq(&(Q.qarray[i]), QLEN, getstring(hd(q)));
		i++;
	}
}

void start_udpq_thread() {
	int i;
	SOCKET sockfd = 0;
	DWORD thread_arg = sockfd;
	Q.active = 1;
	for (i=0; i<Q.numqs; i++) {
		udp_identusr(Q.my_listensock, Q.qarray[i].peer);
		udp_scale(Q.my_listensock, Q.qarray[i].peer,Q.qarray[i].scale);
		udp_startstop(Q.my_listensock, Q.qarray[i].peer, 1);
		Q.qarray[i].status=1;
	}
	
#ifdef NT
	Q.hThread = CreateThread(NULL, 0,
		(LPTHREAD_START_ROUTINE)udp_thread_proc, &Q, 0, &(Q.threadID));
#else
	if ( pthread_create(&(Q.hThread), NULL, &udp_thread_proc, &Q) !=0 ) {
		Q.active=0;
		a_message("Couldn't create udp handler thread.\n");
		return;
	}
#endif
	return;
}

void stop_udpq_thread() {
	Q.active = 0;
#ifdef LINUX
  pthread_join(Q.hThread, NULL);
#endif
#ifdef NT
  WaitForSingleObject (Q.hThread, 5000);
  WSACleanup();
#endif
}

void start_udpqs(a_callcontext cxt, a_tuple tpl) {
  start_udpq_thread();
}

void stop_udpqs(a_callcontext cxt, a_tuple tpl) {
  stop_udpq_thread();
}

void init_priv_udpq(struct udpq_priv* qp, int length, char* hostname) {
	struct hostent *pp;
	struct sockaddr_in *peerp;
	
	/* First of all, do stuff that is likely to go wrong... */
	pp = gethostbyname(hostname);
	if (pp == NULL) {
		a_error(unknown_host,mkstring(hostname),FALSE); /* leak! */
		return;
	}
	peerp = &qp->peer;
	memcpy((char *)&(peerp->sin_addr),(char *)pp->h_addr,pp->h_length);
	memset(&(qp->peer.sin_zero), '\0', 8);  // zero the rest of the struct
	qp->peer.sin_family = AF_INET;
	qp->peer.sin_port = htons(UDP_SENSORPORT);
	
	qp->data = (struct udp_data*)malloc(length*sizeof(struct udp_data));
	qp->length = length;
	qp->freq = UDP_SFRQ;
	qp->head = qp->tail = 0;
	qp->status = 0;
	qp->encoder = &UdpRadioEncoder;
}

void udp_msleep (int delay) { // delay ms
	clock_t time;
	time=clock();
	while((clock()-time)*1000/CLOCKS_PER_SEC<delay);
}

void udp_startstop(SOCKET mysock, struct sockaddr_in remotesockaddr, int flag) {  // start or stop stream
	unsigned char txbuf[16];
	txbuf[0]='S';
#ifdef DEBUG
	printf("udp_startstop: %d %s.\n", flag, inet_ntoa(remotesockaddr.sin_addr));
#endif
	if(flag) {
		txbuf[1]='A';
	} else {
		txbuf[1]='C';
	}
	sendto(mysock, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
	udp_msleep(10);
	sendto(mysock, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
	udp_msleep(10);
	sendto(mysock, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
}

void udp_identusr(SOCKET sockfd, struct sockaddr_in remotesockaddr) {
	unsigned char txbuf[16];
	
	txbuf[0]='I';
	txbuf[1]='D';
	sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
	udp_msleep(10);
	sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
	udp_msleep(10);
	sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
}

void udp_scale(SOCKET sockfd, struct sockaddr_in remotesockaddr, double newscale) {       // change the scale
	unsigned char txbuf[16];
	unsigned int HDFdcp,HDFg,r;
	
	if(newscale<6.25)newscale=6.25;
	if(newscale>12)newscale=12;
	r=(unsigned int)pow(2.0,newscale);
	
	HDFdcp=r-1;
	HDFg=(unsigned int) (32768.0*pow(2.0,ceil(16.60964*log10((double)r))-16.60964*log10((double)r)));
	
	txbuf[0]='M';
	txbuf[1]='S';
	txbuf[2]=0x01|(((char)(75-ceil(5.0*3.32*log10(r))))<<1);
	txbuf[3]=0x00;
	txbuf[4]=0x00;
	txbuf[5]=0x00;
	txbuf[6]=0x91;
	sendto(sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
	udp_msleep(10);
	
	txbuf[0]='M';
	txbuf[1]='S';
	txbuf[2]=0x01|(HDFg<<5);
	txbuf[3]=HDFg>>3;
	txbuf[4]=(HDFg>>11)|(HDFdcp<<5);
	txbuf[5]=HDFdcp>>3;
	txbuf[6]=0xb0|(HDFdcp>>11);
	sendto(sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&remotesockaddr, sizeof(struct sockaddr));
}

void udp_setfreq(SOCKET sockfd, double newfreq) {
	char txbuf[16];
	long	DFreq;
	
	if(newfreq>12499.0) newfreq=12499.0;
	if(newfreq<1.0) newfreq=1.0;
	DFreq=(long)((double)newfreq*(double)UDP_FOFFS*(double)1342.17728);
	
	txbuf[0]='M';
	txbuf[1]='S';
	txbuf[2]=1;
	txbuf[3]=DFreq<<4;
	txbuf[4]=DFreq>>4;
	txbuf[5]=DFreq>>12;
	txbuf[6]=((DFreq>>20)&0xF)|0x30;
	send(sockfd, txbuf, 16,0);
	
}

void UdpRadioEncoder (short *sbuf, struct udpq_priv* q) {
	int shift, i;
	
	if (sbuf[0]%2) shift = 244;
	else shift = 0;
	
	for(i=0;i<122;i++) {
		q->data[q->tail].x[i*2+12+shift]=(float)(sbuf[i*6+1]);
		q->data[q->tail].x[i*2+13+shift]=(float)(sbuf[i*6+2]);
		q->data[q->tail].y[i*2+12+shift]=(float)(sbuf[i*6+3]);
		q->data[q->tail].y[i*2+13+shift]=(float)(sbuf[i*6+4]);
		q->data[q->tail].z[i*2+12+shift]=(float)(sbuf[i*6+5]);
		q->data[q->tail].z[i*2+13+shift]=(float)(sbuf[i*6+6]);
	}
	
	if ((q->data[q->tail].number + 1 == sbuf[0])&&(shift)) {
		for(i=0;i<12;i++) {
			q->data[q->tail].x[i]=q->data[q->tail].y[i]=q->data[q->tail].z[i]=0.0;
		}
		for(i=500;i<512;i++) {
			q->data[q->tail].x[i]=q->data[q->tail].y[i]=q->data[q->tail].z[i]=0.0;
		}
		q->tail++;
#ifdef TRACE_PACKET
		printf("radioenc: t=%d\n",q->tail); fflush(stdout);
#endif
	} else {
		q->data[q->tail].number = sbuf[0];
	}
	q->tail %= q->length;
}

SOCKET udp_bind_listensocket(u_short listenport) { // This is done once for the udp-gw
	SOCKET sockfd;
	struct sockaddr_in my_addr;
	
#ifdef NT
	/*Winsock2 specific part */
	WORD wVersionRequested;
	WSADATA wsaData;
	int err;
	
	wVersionRequested = MAKEWORD( 2, 2 );
	
	err = WSAStartup( wVersionRequested, &wsaData );
	if ( err != 0 ) {
		/* Tell the user that we could not find a usable */
		/* WinSock DLL.                                  */
		sockerror("Could not find a usable WinSock DLL\n");
		return -1;
	}
	
	/* Confirm that the WinSock DLL supports 2.2.*/
	if ( LOBYTE( wsaData.wVersion ) != 2 ||
		HIBYTE( wsaData.wVersion ) != 2 ) {
		WSACleanup( );
		sockerror("WinSock DLL does not support 2.2\n");
		return -1;
	}
	/* The WinSock DLL is acceptable. Proceed. */
#endif
	
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd == INVALID_SOCKET)
		sockerror("Create socket error\n");
	my_addr.sin_family = AF_INET;
	my_addr.sin_port = htons(listenport);
	my_addr.sin_addr.s_addr = INADDR_ANY;
	memset(&(my_addr.sin_zero), '\0', 8);  // This should not be needed...
	if (bind(sockfd, (struct sockaddr *)&(my_addr),sizeof(struct sockaddr)) == SOCKET_ERROR)
		sockerror("Binding server socket");
	return sockfd;
}

int getqnum(const struct udpqs* qs, const struct sockaddr_in *peer) {
	int i;
	for (i=0; i<qs->numqs; i++) {
		if (qs->qarray[i].peer.sin_addr.s_addr == peer->sin_addr.s_addr) {
			return i;
		}
	}
	return -1; // No matching queue
}

#ifdef LINUX
static void *udp_thread_proc(void *arg)
#endif
#ifdef NT
DWORD udp_thread_proc(LPVOID* arg)
#endif
{
	struct udpqs* qs = (struct udpqs*)arg;
	struct udpq_priv* qp;
	int numbytes;
	int qnum;
	short rbuf[MAXBUFLEN];
	struct sockaddr_in from;
	int fromlen = sizeof(from);
	
	while (qs->active) {
		numbytes=recvfrom(qs->my_listensock, (char *) rbuf, MAXBUFLEN-1 , 0, (struct sockaddr *)&from, &fromlen);
		if (numbytes == SOCKET_ERROR) sockerror("Recvfrom error\n");
		qnum = getqnum(qs, &from);
		if (qnum == -1) {
			a_error(unknown_sensor_host,mkstring(inet_ntoa(from.sin_addr)),FALSE);
		} else {
			qp = &(qs->qarray[qnum]);
			if ((qp->status) && (qp->head != (qp->tail+1)%(qp->length)))
				qp->encoder(rbuf, qp);
		}
		// From time to time, see if there is any changes to do
		/*
		if (queue.status==2) {
		scale(sockfd);
		queue.status = 1;
		}
		*/
	}
	// clean up
	for (qnum=0; qnum<qs->numqs; qnum++) {
		udp_startstop(qs->my_listensock, qs->qarray[qnum].peer, 0);
	}
#ifdef LINUX
	close(qs->my_listensock);
	return arg;
#endif
#ifdef NT
	closesocket(qs->my_listensock);
	return TRUE;
#endif
}

void get_udp_carray(a_callcontext cxt, a_tuple tpl) {
	char hostname[50];
	int qnum;
	struct sockaddr_in from;
	struct udpq_priv* qp;
	if (!Q.active) {
		a_error(unknown_sensor_host,mkstring(hostname),FALSE);
		return;
	}
	a_getstringelem(tpl,0,hostname,sizeof(hostname),FALSE);
	from.sin_addr.s_addr = inet_addr(hostname);
	qnum = getqnum(&Q, &from);
	if (-1 == qnum) {
		a_error(unknown_sensor_host,mkstring(hostname),FALSE);
		return;
	}
	qp = &(Q.qarray[qnum]);

	if (qp->head != qp->tail) {
		oidtype xdata = make_numarray(256*3,sizeof(COMPLEX),2);
		COMPLEX *x = (COMPLEX*)dr(xdata,numarraycell)->cont;
		int i;
		for(i=0; i<512; i+=2) {
			x[i].re = qp->data[qp->head].x[i];
			x[i].im = qp->data[qp->head].x[i+1];
			x[i+256].re = qp->data[qp->head].y[i];
			x[i+256].im = qp->data[qp->head].y[i+1];
			x[i+512].re = qp->data[qp->head].z[i];
			x[i+512].im = qp->data[qp->head].z[i+1];
		}

		a_setelem(tpl,1,xdata);
		a_emit(cxt,tpl,FALSE);
		qp->head++;
		qp->head %= qp->length;
#ifdef TRACE_PACKET
		printf("get_udp_carray: h=%d; t=%d\n", qp->head, qp->tail); fflush(stdout);
#endif
	}
	return;
}

void register_udpq(void) {
	unknown_host = a_register_error("Unknown host");
	unknown_sensor_host = a_register_error("Unknown sensor host");
	sock_nobind = a_register_error("Could not bind socket");

	UDPQTYPE = a_definetype("udpq", dealloc_udpq, NULL);
	extfunction2("make-udpq", make_udpqfn);
	extfunction1("udpq-stop", udpq_stopfn);
	extfunction2("udpq-scale", udpq_scalefn);
	extfunction1("udpq-show", udpq_showfn);
	extfunction1("udpq-addr", udpq_getaddrfn);
	
	a_extfunction("start_udpqs", start_udpqs);
	a_extfunction("stop_udpqs",  stop_udpqs);
	a_extfunction("get_udp_carray", get_udp_carray);
}
