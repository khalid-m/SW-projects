/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Ruslan Fomkin
 * $RCSfile: structs.h,v $
 * $Revision: 1.5 $ $Date: 2011/03/09 12:33:56 $
 * $State: Exp $ $Locker:  $
 *
 * Description:
 *	Struct interface for C
 ****************************************************************************
 * $Log: structs.h,v $
 * Revision 1.5  2011/03/09 12:33:56  torer
 * Amos as DLL!
 *
 * Revision 1.4  2008/03/01 10:05:23  ruslan
 * collecting cardinality statistics for vector slots
 *
 * Revision 1.3  2008/02/28 13:11:32  ruslan
 * using sobject
 *
 * Revision 1.2  2007/12/02 11:24:51  ruslan
 * collecting statistics during setting slots with vectors
 *
 * Revision 1.1  2007/11/03 10:10:11  ruslan
 * returning structs
 *
****************************************************************************/

#ifndef	_structs_h_
#define	_structs_h_

#include <iostream>

#include "../../../C/callout.h"
#include "../../../system/include/storagetypes.h"

using namespace std;

void register_structsfns(void);
extern oidtype sobject_set_stat(a_callcontext cxt, oidtype s, int i, oidtype v);
extern oidtype sobject_set_advstat(a_callcontext cxt, oidtype s, int i, oidtype v);

#endif /* _structs_h */