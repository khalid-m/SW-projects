/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: buildtuple.h,v $
 * $Revision: 1.3 $ $Date: 2011/12/14 18:21:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: "build_data" converts byte array to contain data that is
 *              easier to parse into scsq types.
 *              "build_tuple" converts byte array into variables
 *              recognized by scsq.
 * ===========================================================================
 * $Log: buildtuple.h,v $
 * Revision 1.3  2011/12/14 18:21:13  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

#ifndef __buildtuple__
#define __buildtuple__

#include "alisp.h"
#include "parsetypes.h"
#include "extcode.h"

void build_data(TYPESTRUCT type, uint8_t *indata, uint8_t *outdata);

void build_tuple(oidtype v, TYPESTRUCT type, uint8_t *data);

#endif
