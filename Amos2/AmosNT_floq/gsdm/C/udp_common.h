////////////////////////////////////////////////////////////////////////////
//
// Common includes and defines 
// by Arsenij Vodjanov
// 
//////////////////////////////////////////////////////////////////////////////

#ifndef UDP_COMMON_H__
#define UDP_COMMON_H__

#ifdef LINUX
#define PLATFORM_LINUX
#else
#define PLATFORM_WINDOWS
#endif
////////////////////////////////////////////////////////////////////////////
// Define if target platform is Linux/unix
//#define PLATFORM_LINUX
//
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// Define if target platform is Windows
//#define PLATFORM_WINDOWS
//
////////////////////////////////////////////////////////////////////////////

#include "../../C/callout.h"
#include "../../C/complex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>

// Logging messages and errors to log files and console (file only if daemon)
#include "udp_logging.h"

////
#ifdef PLATFORM_LINUX
////

///
// Define to compile & run as a linux daemon
///

//#define BROADCASTER_IS_DAEMON

//

#include <pthread.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#define SOCKET int
#define DWORD long int
#define DWORD long int
#define HANDLE pthread_t
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1
#define sockerrno errno
#define INLINE inline
extern int errno;
#define EXPORT
#endif /* PLATFORM_LINUX */


/// Borland C
#ifdef PLATFORM_WINDOWS
///
#include <dos.h>
#include <winsock2.h>
#include <winbase.h>
#include <values.h>
//_export
#define EXPORT __declspec(dllexport)
#define sockerrno WSAGetLastError()
#define socklen_t int
#define INLINE __inline
#define __FUNCTION__ "()"
#endif /* PLATFORM_WINDOWS */

#endif /* UDP_COMMON_H__ */
