/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Thanh Truong, UDBL
 * $RCSfile: slaslogger.h,v $
 * $Revision: 1.1 $ $Date: 2013/12/12 16:29:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Stream (ManchineId, Time, PowCon) into a comma separate file.
 * ===========================================================================
 * $Log: slaslogger.h,v $
 * Revision 1.1  2013/12/12 16:29:37  thatr500
 * rev23. Compiled on MacOSX 10.8.4
 *
 * Revision 1.3  2012/05/24 18:03:40  thatr500
 * Reading generator settings as environement variables
 *
 * Revision 1.2  2012/05/23 07:33:46  thatr500
 * More robust generator
 *
 * Revision 1.1  2012/05/21 07:20:22  thatr500
 * stream (ManchineId, Time, PowCon) into a comma separate file.
 *
 *
 ****************************************************************************/

#ifndef _slaslogger_h_
#define _slaslogger_h_

#include "../../../../C/callin.h"
#include "../../../../C/callout.h"
#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>
#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif
#include "../logger/config.h"
#include "../logger/logger.h"
#include "../lofixP/lofixP.h"

/*Global array of LofixP indexes maintaining meta-data about log files*/
struct LofixP g_lx[10];

/*Functions*/
oidtype slas_write_indexed_logfilebbf(a_callcontext cxt);
#endif
