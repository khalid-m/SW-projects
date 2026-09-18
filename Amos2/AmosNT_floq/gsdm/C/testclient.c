#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/uio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <time.h>
#include <sys/time.h>
#include <sys/poll.h>

typedef struct {
  unsigned short counter; // packet number
  short data[122*2*3];  // sample  *  real,imaginary  *  channel
} packet_data_type;

#define MAX_MESG_SIZE 4096
char mesg[MAX_MESG_SIZE] = "";

#define MYPORT 2096
#define SOCKET int


////////////////////////////////////////////////////////////////////////////
// polls socket to see if any incoming data is available
// returns 1 if there's data to read
int socket_has_data(SOCKET sockfd)
{
  struct pollfd fd;
  unsigned int nfds = 1;
  int timeout = 1; // don't wait too long :)

  fd.fd = sockfd;
  fd.events = POLLIN | POLLPRI; // requested events bit-mask
  fd.revents = 0; // returned events bit-mask, set by kernel

  poll(&fd, nfds, timeout); // blocks for at most 'timeout' milliseconds
  
  return (fd.revents & POLLIN || fd.revents & POLLPRI);
}
//
////////////////////////////////////////////////////////////////////////////




int main(int argc, char *argv[])
{
  char progress[5] = "-\\|/";
  int udpSocket = 0,
    myPort = 0,
    status = 0,
    size = 0,
    clientLength = 0;
  struct sockaddr_in serverName = { 0 }, clientName = { 0 };
  unsigned int packets=0, iterations=0, counter=0;

  myPort = MYPORT;
  udpSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if (-1 == udpSocket) {
    perror("testclient: socket()");
    exit(1);
  }
  
  memset(&serverName, 0, sizeof(serverName));
  memset(&clientName, 0, sizeof(clientName));

  serverName.sin_family = AF_INET;
  serverName.sin_addr.s_addr = htonl(INADDR_ANY);
  serverName.sin_port = htons(myPort);
  status = bind(udpSocket, (struct sockaddr *)
                &serverName, sizeof(serverName));
  if (-1 == status) {
    perror("testclient: bind()");
    exit(1);
  }

  printf("Ready to receive.\n");

  for (;;)
    {
      while (socket_has_data(udpSocket)) {
	packet_data_type *pkt = (packet_data_type*)&mesg[0];
	clientLength = sizeof(clientName);
	size = recvfrom(udpSocket, mesg,
			MAX_MESG_SIZE, 0,
			(struct sockaddr *) &clientName,
			&clientLength);
	if (size == -1) {
	  perror("testclient: recvfrom()");
	  exit(1);
	}
	packets++;
	counter = pkt->counter;
      }
      iterations++;
      printf("\r#%8u:  Packets: %6u   Last packet's counter: %6u",  iterations, packets, counter);
      fflush(stdout);
    }

  /* never reached */
  return 0;
}

