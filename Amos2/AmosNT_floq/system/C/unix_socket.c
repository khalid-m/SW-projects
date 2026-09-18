/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2003, Tore Risch, UDBL
 * $RCSfile: unix_socket.c,v $
 * $Revision: 1.1 $ $Date: 2011/01/10 19:57:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Unix Socket errors and initialization
 * ===========================================================================
 * $Log: unix_socket.c,v $
 * Revision 1.1  2011/01/10 19:57:45  torer
 * Unix socket error messages
 *
 ****************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

char *sockerrorstring(int no)
{
  switch(no)
    {
    case EACCES: return "Permission denied";
    case EADDRINUSE: return "Address already in use";
    case EADDRNOTAVAIL: return "Cannot assign requested address";
    case EAFNOSUPPORT: return "Address family not supported by protocol family";
    case EALREADY: return "Operation already in progress";
    case ECONNABORTED: return "Software caused connection abort";
    case ECONNREFUSED: return "Connection refused";
    case ECONNRESET: return "Connection reset by peer";
    case EDESTADDRREQ: return "Destination address required";
    case EFAULT: return "Bad address";
    case EHOSTDOWN: return "Host is down";
    case EHOSTUNREACH: return "No route to host";
    case EINPROGRESS: return "Operation now in progress";
    case EINTR: return "Interrupted function call";
    case EINVAL: return "Invalid argument";
    case EISCONN: return "Socket is already connected";
    case EMFILE: return "Too many open files";
    case EMSGSIZE: return "Message too long";
    case ENETDOWN: return "Network is down";
    case ENETRESET: return "Network dropped connection on reset";
    case ENETUNREACH: return "Network is unreachable";
    case ENOBUFS: return "No buffer space available";
    case ENOPROTOOPT: return "Bad protocol option";
    case ENOTCONN: return "Socket is not connected";
    case ENOTSOCK: return "Socket operation on non-socket";
    case EOPNOTSUPP: return "Operation not supported";
    case EPFNOSUPPORT: return "Protocol family not supported";
    case EPROTONOSUPPORT: return "Protocol not supported";
    case EPROTOTYPE: return "Protocol wrong type for socket";
    case ESHUTDOWN: return "Cannot send after socket shutdown";
    case ESOCKTNOSUPPORT: return "Socket type not supported";
    case ETIMEDOUT: return "Connection timed out";
    case EWOULDBLOCK: return "Resource temporarily unavailable";
    case HOST_NOT_FOUND: return "Host not found";
      /*    case NO_DATA: return "Valid name, no data record of requested type";*/
    case NO_RECOVERY: return "This is a non-recoverable error";
    case TRY_AGAIN: return "Non-authoritative host not found";
    }
  return strerror(no);
}

void init_sockets(void)
{
  return;
}

