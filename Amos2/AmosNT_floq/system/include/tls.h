/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Lars Melander, UDBL
 * $RCSfile: tls.h,v $
 * $Revision: 1.3 $ $Date: 2012/06/19 16:28:49 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Thread local storage
 * ===========================================================================
 * $Log: tls.h,v $
 * Revision 1.3  2012/06/19 16:28:49  larme597
 * Updates.
 *
 * Revision 1.2  2012/04/27 11:49:06  larme597
 * Linux bugfix.
 *
 * Revision 1.1  2012/04/12 15:35:37  larme597
 * Coroutine and callin thread local storage added.
 *
 * Revision 1.2  2010/06/19 19:12:48  larme597
 * Removed locks from tls. Tls now is initialized at startup.
 *
 * Revision 1.1  2009/11/27 09:49:39  larme597
 * Thread local storage for XP, Vista and Unix
 *
 ****************************************************************************/

#ifndef _tls_h_
#define _tls_h_

#include "amos.h"

void tls_init();

void tls_save_co(oidtype);
oidtype tls_get_co();

#endif
