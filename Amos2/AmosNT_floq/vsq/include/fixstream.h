/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: fixstream.h,v $
 * $Revision: 1.2 $ $Date: 2011/11/01 15:32:36 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions for handling a stream that outputs a byte array
 *              with fixed types.
 * ===========================================================================
 * $Log: fixstream.h,v $
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

#ifndef __fixstream__
#define __fixstream__

#include <extcode.h>
#include <windows.h>
#include "scsq.h"
#include "parsetypes.h"
#include "buildtuple.h"
#include "language.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "threadbarrier.h"
#include "vsq_labview.h"
#include "vi.h"

int fixstreamtype;
int fixstreamerror;

typedef struct fixstreamcell
{
  objtags tags;
  oidtype vi;
  t_typestruct type;
  BARRIER barrier, endbarrier;
  uint8_t *data;
  uint8_t *transdata[2];
  int current;
} *FIXSTREAM;

void register_fixstream();

#endif
