/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Ruslan Fomkin
 * $RCSfile: aleh_udfs.h,v $
 * $Revision: 1.3 $ $Date: 2007/11/17 09:30:17 $
 * $State: Exp $ $Locker:  $
 *
 * Description:
 *	Numerical UDFs from ALEH queries.
 ****************************************************************************
 * $Log: aleh_udfs.h,v $
 * Revision 1.3  2007/11/17 09:30:17  ruslan
 * missing file in Makefile for Linux
 *
 * Revision 1.2  2007/11/11 09:47:05  ruslan
 * aleh aggregates are implemented in C
 *
 * Revision 1.1  2007/11/10 07:57:42  ruslan
 * missing file
 *
****************************************************************************/

#ifndef	_aleh_udfs_h_
#define	_aleh_udfs_h_

#include <math.h>
#include <float.h>
#include <iostream>


#include "../../../C/callout.h"
#include "../../../system/include/storagetypes.h"

using namespace std;

void register_udffns(void);

#endif /* _aleh_udfs_h */
