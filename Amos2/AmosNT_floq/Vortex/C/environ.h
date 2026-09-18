/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: environ.h,v $
 * $Revision: 1.7 $ $Date: 2013/04/29 17:08:36 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Macros to handle different compilation environments
 * ===========================================================================
 * $Log: environ.h,v $
 * Revision 1.7  2013/04/29 17:08:36  torer
 * Macro #ZU for printing pointers defined
 *
 * Revision 1.6  2013/02/13 18:39:27  torer
 * Datatype LONGINT defined
 *
 * Revision 1.5  2012/12/21 11:42:52  torer
 * malloc.h obsolete under Unix
 *
 * Revision 1.4  2011/07/06 20:02:30  torer
 * UNIX -> LINUX
 *
 * Revision 1.3  2011/04/28 20:13:31  torer
 * More general DLL environment test
 *
 * Revision 1.2  2011/03/24 18:01:22  torer
 * error message
 *
 * Revision 1.1  2011/03/09 12:29:15  torer
 * Macros to set compilation environments
 *
 ****************************************************************************/

#ifndef _environ_h_
#define _environ_h_

//-----------------------------
#if defined(__cplusplus)
    #define EXTLANG extern "C"
#else
    #define EXTLANG extern
#endif
//-----------------------------
#if defined(WIN32)
    #include <io.h>
    #define NT 1
#elif defined(LINUX)
    #define O_BINARY 0
#else 
    #error Unsupported operating system
#endif
//-----------------------------
#if defined(KERNEL_DLL) // Compiling kernel DLL
    #define EXPORT __declspec(dllexport)
    #define EXTERN EXPORT
#elif defined(_DLL) || defined(_USRDLL) // Compiling DLL on top of kernel DLL
    #define EXPORT __declspec(dllexport)
    #define EXTERN EXTLANG __declspec(dllimport)
#elif defined(WIN32) // Compiling non-DLL under Windows
    #define EXPORT
    #define EXTERN EXTLANG __declspec(dllimport)
#elif defined(LINUX)
    #define EXPORT
    #define EXTERN EXTLANG
    #define LONGINT long long
    #define ZU "%u"
#else 
    #error Unsupported operating system
#endif
//-----------------------------
#ifdef NT
    #include <malloc.h>
    #define LONGINT __int64
#endif
//-----------------------------

#endif
