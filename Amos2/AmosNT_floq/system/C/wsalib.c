/*****************************************************************************
 * AMOS II
 *
 * Author: (c) 1999 Tore Risch, EDSLAB
 *
 * Description:  Winsock2 interface and error messages
 *
 * Requirements:
 * ===========================================================================
 */
#include <stdio.h>
#include <winsock2.h>

char *sockerrorstring(int no)
{
    switch(no)
    {
    case WSAEACCES: return "Permission denied";
    case WSAEADDRINUSE: return "Address already in use";
    case WSAEADDRNOTAVAIL: return "Cannot assign requested address";
    case WSAEAFNOSUPPORT: return "Address family not supported by protocol family";
    case WSAEALREADY: return "Operation already in progress";
    case WSAECONNABORTED: return "Software caused connection abort";
    case WSAECONNREFUSED: return "Connection refused";
    case WSAECONNRESET: return "Connection reset by peer";
    case WSAEDESTADDRREQ: return "Destination address required";
    case WSAEFAULT: return "Bad address";
    case WSAEHOSTDOWN: return "Host is down";
    case WSAEHOSTUNREACH: return "No route to host";
    case WSAEINPROGRESS: return "Operation now in progress";
    case WSAEINTR: return "Interrupted function call";
    case WSAEINVAL: return "Invalid argument";
    case WSAEISCONN: return "Socket is already connected";
    case WSAEMFILE: return "Too many open files";
    case WSAEMSGSIZE: return "Message too long";
    case WSAENETDOWN: return "Network is down";
    case WSAENETRESET: return "Network dropped connection on reset";
    case WSAENETUNREACH: return "Network is unreachable";
    case WSAENOBUFS: return "No buffer space available";
    case WSAENOPROTOOPT: return "Bad protocol option";
    case WSAENOTCONN: return "Socket is not connected";
    case WSAENOTSOCK: return "Socket operation on non-socket";
    case WSAEOPNOTSUPP: return "Operation not supported";
    case WSAEPFNOSUPPORT: return "Protocol family not supported";
    case WSAEPROCLIM: return "Too many processes";
    case WSAEPROTONOSUPPORT: return "Protocol not supported";
    case WSAEPROTOTYPE: return "Protocol wrong type for socket";
    case WSAESHUTDOWN: return "Cannot send after socket shutdown";
    case WSAESOCKTNOSUPPORT: return "Socket type not supported";
    case WSAETIMEDOUT: return "Connection timed out";
    case WSAEWOULDBLOCK: return "Resource temporarily unavailable";
    case WSAHOST_NOT_FOUND: return "Host not found";
    case WSA_INVALID_HANDLE: return "Specified event object handle is invalid";
    case WSA_INVALID_PARAMETER: return "One or more parameters are invalid";
    case WSA_IO_PENDING: return "Overlapped operations will complete later";
    case WSA_IO_INCOMPLETE: return "Overlapped I/O event object not in signaled state";
    case WSA_NOT_ENOUGH_MEMORY: return "Insufficient memory available";
    case WSANOTINITIALISED: return "Successful WSAStartup not yet performed";
    case WSANO_DATA: return "Valid name, no data record of requested type";
    case WSANO_RECOVERY: return "This is a non-recoverable error";
    case WSASYSCALLFAILURE: return "System call failure";
    case WSASYSNOTREADY: return "Network subsystem is unavailable";
    case WSATRY_AGAIN: return "Non-authoritative host not found";
    case WSAVERNOTSUPPORTED: return "WINSOCK.DLL version out of range";
    case WSAEDISCON: return "Graceful shutdown in progress";
    case WSA_OPERATION_ABORTED: return "Overlapped operation aborted";
    }
    return strerror(no);
}

void init_sockets(void)
{
   WORD wVersionRequested;
   WSADATA wsaData;
   int err;

   wVersionRequested = MAKEWORD( 2, 0 );

   err = WSAStartup( wVersionRequested, &wsaData );
   if ( err != 0 )
   {
    /* Tell the user that we couldn't find a usable */
    /* WinSock DLL.                                  */
    printf("Couldn't find a usable WinSock DLL\n");
    return;
   }

   /* Confirm that the WinSock DLL supports 2.0.*/
   /* Note that if the DLL supports versions greater    */
   /* than 2.0 in addition to 2.0, it will still return */
   /* 2.0 in wVersion since that is the version we      */
   /* requested.                                        */

   if ( LOBYTE( wsaData.wVersion ) != 2 ||
        HIBYTE( wsaData.wVersion ) != 0 )
   {
      /* Tell the user that we couldn't find a usable */
      /* WinSock DLL.                                  */
      printf("Couldn't find usable WinSock DLL\n");
      WSACleanup( );
      return;
   }

   /* The WinSock DLL is acceptable. Proceed. */
   return;
}

