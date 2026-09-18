
#pragma hdrstop
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <dos.h>
#include <time.h>
#include <winsock2.h>
#include "callout.h"
#include "compl_fns.c"

//---------------------------------------------------------------------------
#pragma argsused

//***************************************************************************
// Network app from IRFU receiving radio signals as UDP packets 
// Ported to Windows network library by M. Koparanova
//
//***************************************************************************


#define HOSTNAME "130.238.30.208"		// IP adr.
#define MYPORT 4096    			// Port to use
#define MAXBUFLEN 2048			// Max packet size

#define Foffs	  1.0000086		// Freq calibration
#define Sfrq	  6120.0		// Starting Frequency KHz
#define sockerrno WSAGetLastError()

double	Freq=Sfrq;
long	DFreq;
float	red=8;

SOCKET my_udp_sockfd;
int opened_udp_socket = 0;
struct sockaddr_in my_addr;    // my address information
struct sockaddr_in their_addr; // connector's address information
struct hostent *he;

//***************************************************************************



//---------------------------------------------------------------------------

int sockerror(char * msg)
{       printf("%s %u \n", msg, sockerrno);
     /*   exit(1);*/
        return 0;
      }

void identusr(void)
{
  unsigned char txbuf[16];

  txbuf[0]='I';
  txbuf[1]='D';
  sendto(my_udp_sockfd, (char *) txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
//  sendto(sockfd, txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
//  sendto(sockfd, txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
}

void startstop(int i)
{
  unsigned char txbuf[16];

  txbuf[0]='S';
  if(i) txbuf[1]='A';
  else txbuf[1]='C';
  sendto(my_udp_sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
//  delay(5000);
//  sendto(sockfd, txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
//  sendto(sockfd, txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
}

void scale(void)
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
  sendto(my_udp_sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  usleep(5000);
//  printf("%d %X %X %X\n",r,HDFdcp,HDFg,txbuf[2]);
//  printf("%02X%02X %02X%02X %02X -- ",txbuf[3],txbuf[2],txbuf[5],txbuf[4],txbuf[6]);
  
  txbuf[0]='M';
  txbuf[1]='S';
  txbuf[2]=0x01|(HDFg<<5);
  txbuf[3]=HDFg>>3;
  txbuf[4]=(HDFg>>11)|(HDFdcp<<5);
  txbuf[5]=HDFdcp>>3;
  txbuf[6]=0xb0|(HDFdcp>>11);
  sendto(my_udp_sockfd, (char *)txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
//  printf("%02X%02X %02X%02X %02X\n",txbuf[3],txbuf[2],txbuf[5],txbuf[4],txbuf[6]);
}

void setfreq(void)
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
  sendto(my_udp_sockfd, txbuf, 16,0,(struct sockaddr *)&their_addr, sizeof(struct sockaddr));
}

void open_udp_socket()
{
 /*Winsock2 specific part */
        WORD wVersionRequested;
        WSADATA wsaData;
        int err;

        wVersionRequested = MAKEWORD( 2, 2 );

        err = WSAStartup( wVersionRequested, &wsaData );
        if ( err != 0 ) {
    /* Tell the user that we could not find a usable */
    /* WinSock DLL.                                  */
            return;
        }
/* Confirm that the WinSock DLL supports 2.2.*/
        if ( LOBYTE( wsaData.wVersion ) != 2 ||
                HIBYTE( wsaData.wVersion ) != 2 ) {
                WSACleanup( );
                return;
        }

/* The WinSock DLL is acceptable. Proceed. */
    my_udp_sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (my_udp_sockfd == INVALID_SOCKET)
        sockerror("Create socket error\n");

    he=gethostbyname(HOSTNAME);

    my_addr.sin_family = AF_INET;         // host byte order BIG ENDIAN PÅ NÄTVERK!
    					  // vet inte hur dina packet kommer men dom kan ju alltid castas om sedan.
    my_addr.sin_port = htons(MYPORT);     // short, network byte order
    my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
    memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct

    their_addr.sin_family = AF_INET;     // host byte order
    their_addr.sin_port = htons(MYPORT); // short, network byte order
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(&(their_addr.sin_zero), '\0', 8);  // zero the rest of the struct

    if (bind(my_udp_sockfd, (struct sockaddr *)&my_addr,sizeof(struct sockaddr)) == SOCKET_ERROR)
       sockerror("Binding server socket error ");
       else opened_udp_socket =1;
}

//******************************************
void receive_udp_packet(float *xdat, int n)
{   //currently

    int addr_len, numbytes, i, buflen;
    int q=1, qmax = 10 ;
//    short
    char sbuf[MAXBUFLEN];
/*    float xdat[1024];*/
    float ydat[1024];
    float zdat[1024];
    FILE *fd;

/* Check the udp socket and open if needed */
    if (! opened_udp_socket)
    {  open_udp_socket();
       if (! opened_udp_socket)
           sockerror(" Can not open UDP socket");
       else {
       //***appl. specific initialization for right scaling
        identusr();
        scale();
        startstop(1);
       }
    }

    buflen=sizeof(sbuf);
    numbytes = -1;
    while((numbytes<0 )&& (q<qmax))
    {
        //******Get UDP packet
	numbytes=recvfrom(my_udp_sockfd, (char *) sbuf, buflen , 0,(struct sockaddr *)&their_addr, &addr_len);
        q++;
    }

    if (numbytes > 0) /* A packet has been received -> encode data */
    {
       printf("\nNew packet 1\n");
       printf("Received bytes %d\n", numbytes);
       for(i=0;i<122;i++)
       {
           xdat[i*2+12]=(float)(sbuf[i*6+1]); /*  printf("%8.2f", xdat[i*2+12]);*/
	   xdat[i*2+13]=(float)(sbuf[i*6+2]);
	   ydat[i*2+12]=(float)(sbuf[i*6+3]);
	   ydat[i*2+13]=(float)(sbuf[i*6+4]);
	   zdat[i*2+12]=(float)(sbuf[i*6+5]);
	   zdat[i*2+13]=(float)(sbuf[i*6+6]);
       }
//******Zero pad
	for(i=0;i<12;i++) xdat[i]=ydat[i]=zdat[i]=0.0;
	for(i=500;i<512;i++) xdat[i]=ydat[i]=zdat[i]=0.0;
    } //if
}

void stop_udp_socket()
{
    startstop(0);
    closesocket(my_udp_sockfd);
    opened_udp_socket=0;
}

void get_udp_packetf(a_callcontext cxt, a_tuple tpl)
{
  /* C foreign function to emit a vector of 256 complex numbers to Amos */

   dcl_tuple(pack);     //sequence of 256 complex numbers
   float xdat[1024];
   oidtype cn;
   int i;
   a_newtuple(pack,256, FALSE);
   receive_udp_packet(xdat,1024);

   for(i=0; i<512; i+=2)
   {
        cn=new_complex(xdat[i],xdat[i+1]);
        a_setobjectelem(pack,i/2,cn,FALSE);
    }

   a_setseqelem(tpl,0,pack,FALSE);
   
   a_emit(cxt,tpl,FALSE);
   return;
}

void get_udp_streamf(a_callcontext cxt, a_tuple tpl)
{
   /*256 complex numbers are emitted as a bag */
   float xdat[1024];
   oidtype cn;
   int i;

   receive_udp_packet(xdat, 1024);

   for(i=0; i<20; i+=2)
   {
        cn=new_complex(xdat[i],xdat[i+1]);
        a_setobjectelem(tpl,0,cn,FALSE);
        a_emit(cxt,tpl,FALSE);
    }

   return;
}


void register_udp_packets(void)
{
  a_extfunction("get_udp_packet", get_udp_packetf);
  a_extfunction("get_udp_stream", get_udp_streamf);
}

/* driver function */
main(int argc,char **argv)
{
  bindtype env;

  init_amos(argc,argv); /* Initialize embedded Amos and ALisp */
  register_udp_packets();

  /*** Enter Amos top loop ***/
  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a')amos_toploop("Amos");

  /* clean up */
  /* if the socket is still opened */
  if (opened_udp_socket)
        stop_udp_socket();
  WSACleanup( );


  return 0;
}


