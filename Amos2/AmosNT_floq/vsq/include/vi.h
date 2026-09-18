/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: vi.h,v $
 * $Revision: 1.3 $ $Date: 2011/12/14 18:21:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for handling virtual instruments (labview).
 * ===========================================================================
 * $Log: vi.h,v $
 * Revision 1.3  2011/12/14 18:21:13  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

#ifndef __vi__
#define __vi__

#include "scsq.h"
#include <windows.h>
#include "vsq_labview.h"

int vitype;
int vierror;

typedef struct vicell
{
  objtags tags;
  oidtype name;
  LVRefNum ref;
  int isopen;
  HMODULE vi_lib;

  // Pointer to data to use
  void *vi_data;
} *VI;

oidtype vi_openfn(oidtype);
oidtype vi_closefn(oidtype);
oidtype vi_runfn(oidtype);

void register_vi();

#endif
