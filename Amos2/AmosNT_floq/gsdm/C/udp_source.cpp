#include "../../C/callout.h"

#include "../../C/complex.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <dos.h>
#include <time.h>
#include <winsock2.h>
#include <winbase.h>

//***************************************************************************
// Network app from IRFU receiving radio signals as UDP packets
// by Mantas Kaulakys
//***************************************************************************


//#define HOSTNAME "130.238.30.208"     	// IP adr.
#define MYPORT 4096    			// Port to use
#define MAXBUFLEN 2048			// Max packet size

#define Foffs	  1.0000086		// Freq calibration
#define Sfrq	  6120.0		// Starting Frequency KHz
#define sockerrno WSAGetLastError()

#define QUEUESIZE 2000         // queue size

char hostname[50];

double	Freq=Sfrq;
long	DFreq;
float	red=12;                // scale


struct sockaddr_in my_addr;    // my address information
struct sockaddr_in their_addr; // connector's address information
struct hostent *he;

int msTimout = 5000;    // thread timeout
DWORD threadID;         // thread ID
HANDLE hThread;         // thread handle




typedef struct
                {
                float x[512];         // data x
                float y[512];         // data y
                float z[512];         // data z
                int number;           // packet number
                } data_type;

typedef struct
                {
                data_type data[QUEUESIZE];  // data
                void (*encoder) (short[]);  // data encoder
                int head;       // first element
                int tail;       // first free location for a newly arriving element
                int status;     // queue status: 0-stop, 1-go, 2-change scale
                } queue_type;

queue_type queue;


//***************************************************************************
//---------------------------------------------------------------------------

int sockerror(char * msg)
{       printf("%s %u \n", msg, sockerrno);
     /*   exit(1);*/
        return 0;
}

void udp_sleep (int delay)  // udp_sleeps for delay ms
{
  clock_t time;
  time=clock();  // gets the tics since program started
  while((clock()-time)*1000/CLOCKS_PER_SEC<delay);  // waits for delay ms
}



void identusr(SOCKET sockfd) // identifies
{
  unsigned char txbuf[16];

  txbuf[0]='I';
  txbuf[1]='D';
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
  udp_sleep(10);
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
  udp_sleep(10);
  sendto(sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
}

void startstop(SOCKET sockfd, int i)  // start or stop stream
{
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

void scale(SOCKET sockfd)        // change the scale
{
  unsigned char txbuf[16];
  unsigned int HDFdcp,HDFg,r;

  if(red<6.25)red=6.25;
  if(red>12)red=12;
  r=pow(2.0,red);

  HDFdcp=r-1;
  HDFg=32768.0*pow(2.0,ceil(16.60964*log10((double)r))-16.60964*log10((double)r));

  txbuf[0]='M';
  txbuf[1]='S';
  txbuf[2]=0x01|(((char)(75-ceil(5.0*3.32*log10(r))))<<1);
  txbuf[3]=0x00;
  txbuf[4]=0x00;
  txbuf[5]=0x00;
  txbuf[6]=0x91;
  sendto(sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
  udp_sleep(10);

  txbuf[0]='M';
  txbuf[1]='S';
  txbuf[2]=0x01|(HDFg<<5);
  txbuf[3]=HDFg>>3;
  txbuf[4]=(HDFg>>11)|(HDFdcp<<5);
  txbuf[5]=HDFdcp>>3;
  txbuf[6]=0xb0|(HDFdcp>>11);
  sendto(sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
}


void setfreq(SOCKET sockfd)     // sets frequency
{
  char txbuf[16];

  if(Freq>12499.0) Freq=12499.0;
  if(Freq<1.0) Freq=1.0;
  DFreq=(long)((double)Freq*(double)Foffs*(double)1342.17728);

  txbuf[0]='M';
  txbuf[1]='S';
  txbuf[2]=1;
  txbuf[3]=DFreq<<4;
  txbuf[4]=DFreq>>4;
  txbuf[5]=DFreq>>12;
  txbuf[6]=((DFreq>>20)&0xF)|0x30;
  send(sockfd, txbuf, 16,0);

}

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

void RadioEncoder (short sbuf[])    // data encoder
{
int shift, i;

        if (sbuf[0]%2) shift = 244;
                else shift = 0;

	for(i=0;i<122;i++)
		{
		queue.data[queue.tail].x[i*2+12+shift]=(float)(sbuf[i*6+1]);
		queue.data[queue.tail].x[i*2+13+shift]=(float)(sbuf[i*6+2]);
		queue.data[queue.tail].y[i*2+12+shift]=(float)(sbuf[i*6+3]);
		queue.data[queue.tail].y[i*2+13+shift]=(float)(sbuf[i*6+4]);
		queue.data[queue.tail].z[i*2+12+shift]=(float)(sbuf[i*6+5]);
		queue.data[queue.tail].z[i*2+13+shift]=(float)(sbuf[i*6+6]);
		}


        if ((queue.data[queue.tail].number + 1 == sbuf[0])&&(shift)) {
//              Zero pad
	        for(i=0;i<12;i++) queue.data[queue.tail].x[i]=queue.data[queue.tail].y[i]=queue.data[queue.tail].z[i]=0.0;
	        for(i=500;i<512;i++) queue.data[queue.tail].x[i]=queue.data[queue.tail].y[i]=queue.data[queue.tail].z[i]=0.0;

                queue.tail++;
        }
        else queue.data[queue.tail].number = sbuf[0];

        queue.tail %= QUEUESIZE;

        return;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


SOCKET connecttoserv () // connects to server
{

SOCKET sockfd;


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

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd == INVALID_SOCKET)
       sockerror("Create socket error\n");

//    he=gethostbyname(HOSTNAME);
	he = gethostbyname(hostname);

    my_addr.sin_family = AF_INET;         // host byte order BIG ENDIAN PÅ NÄTVERK!
    					  // vet inte hur dina packet kommer men dom kan ju alltid castas om sedan.
    my_addr.sin_port = htons(MYPORT);     // short, network byte order
    my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
    memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct

    their_addr.sin_family = AF_INET;     // host byte order
    their_addr.sin_port = htons(MYPORT); // short, network byte order
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(&(their_addr.sin_zero), '\0', 8);  // zero the rest of the struct

    if (bind(sockfd, (struct sockaddr *)&my_addr,sizeof(struct sockaddr)) == SOCKET_ERROR)
       sockerror("Binding server socket");

     return sockfd;

}


////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


DWORD ThreadProc(LPVOID* arg)   // worker thread
{
DWORD sockfd = (DWORD)*arg;

int addr_len,
    numbytes,   // number of bytes recieved
    buflen;     // length of the buffer
short sbuf[MAXBUFLEN];  // buffer

buflen=sizeof(sbuf);


sockfd = connecttoserv();

//******init to right scaling
identusr(sockfd);
scale(sockfd);
startstop(sockfd, 1);


while (queue.status) { // while status

	numbytes=recv(sockfd, (char *) sbuf, MAXBUFLEN-1 , 0);
        if (numbytes == SOCKET_ERROR) sockerror("Recvfrom error\n");

        if (queue.head!=(queue.tail+1)%QUEUESIZE) // if queue not full, encode
                queue.encoder (sbuf);

        if (queue.status==2) {
                scale(sockfd);     // changes the scale
                queue.status = 1;
        }

  }

/* clean up */
startstop(sockfd, 0);
closesocket(sockfd);

  return TRUE;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////



void start_udp_consumer(a_callcontext cxt, a_tuple tpl)   // starts the consumer
{

		SOCKET sockfd;
        DWORD thread_arg = sockfd;

        queue.head = queue.tail = 0;
        queue.encoder = &RadioEncoder;

        a_getstringelem(tpl,0,hostname,sizeof(hostname),FALSE);

		queue.status=1;

        hThread = CreateThread(NULL, 0,
        (LPTHREAD_START_ROUTINE)ThreadProc, &thread_arg, 0, &threadID);

        return;
}


void stop_udp_consumer(a_callcontext cxt, a_tuple tpl)    // stops the consumer
{

        queue.status=0;

        WaitForSingleObject (hThread, msTimout);
        WSACleanup( );

        return;
}

void change_udp_scale(a_callcontext cxt, a_tuple tpl)   // changes the scale
{
        float scale;
        scale = a_getdoubleelem(tpl,0,FALSE);
        red = scale;
        queue.status=2;
        return;
}

void get_udp_packet(a_callcontext cxt, a_tuple tpl)
{
  /* C foreign function to emit a vector of 256 complex numbers to Amos */

  if (!queue.status)
        printf ("start the consumer first\n");
  else if (queue.head == queue.tail) {
/*        printf ("queue empty\n");*/
  }
  else {

   dcl_tuple(xdata);     //sequence of 256 complex numbers
   dcl_tuple(ydata);     //sequence of 256 complex numbers
   dcl_tuple(zdata);     //sequence of 256 complex numbers


   oidtype cn;
   int i;
   a_newtuple(xdata,256, FALSE);
   a_newtuple(ydata,256, FALSE);
   a_newtuple(zdata,256, FALSE);


   for(i=0; i<512; i+=2)
   {
        cn=new_complex(queue.data[queue.head].x[i],queue.data[queue.head].x[i+1]);
        a_setelem(xdata,i/2,cn);
        cn=new_complex(queue.data[queue.head].y[i],queue.data[queue.head].y[i+1]);
        a_setelem(ydata,i/2,cn);
        cn=new_complex(queue.data[queue.head].z[i],queue.data[queue.head].z[i+1]);
        a_setelem(zdata,i/2,cn);
   }


   a_setseqelem(tpl,0,xdata,FALSE);
   a_setseqelem(tpl,1,ydata,FALSE);
   a_setseqelem(tpl,2,zdata,FALSE);

   a_emit(cxt,tpl,FALSE);
   free_tuple(xdata);
   free_tuple(ydata);
   free_tuple(zdata);
   queue.head++;
   queue.head %= QUEUESIZE;

  }

   return;
}


void register_udp_packet_functions(void)
{

  a_extfunction("start_udp_consumer", start_udp_consumer);
  a_extfunction("stop_udp_consumer", stop_udp_consumer);
  a_extfunction("change_udp_scale", change_udp_scale);
  a_extfunction("get_udp_packet", get_udp_packet);
}

/*
void main (int argc, char **argv)
{

        dcl_connection(c);
        dcl_scan(s);
        init_amos(argc,argv);
        a_connect(c,"",FALSE);

//        register_udp_packet_functions();

        a_extfunction("start_udp_consumer", start_udp_consumer);
        a_execute(c,s,"create function start_udp_consumer() -> integer as foreign 'start_udp_consumer';", FALSE);

        a_extfunction("stop_udp_consumer", stop_udp_consumer);
        a_execute(c,s,"create function stop_udp_consumer() -> integer as foreign 'stop_udp_consumer';", FALSE);

        a_extfunction("change_udp_scale", change_udp_scale);
        a_execute(c,s,"create function change_udp_scale() -> integer as foreign 'change_udp_scale';", FALSE);

        a_extfunction("get_udp_packet", get_udp_packet);
        a_execute(c,s,"create function get_udp_packet() -> < vector of complex, vector of complex, vector of complex > as foreign 'get_udp_packet';", FALSE);

        a_execute(c,s,"create function get_udp_stream(integer n) -> vector as for each integer i where i = iota(1,n) result get_udp_packet();", FALSE);

        amos_toploop("Amos");

        free_connection(c);

        return;
}
*/
