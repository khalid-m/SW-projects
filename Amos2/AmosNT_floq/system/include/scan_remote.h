/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Lars Melander, UDBL
 * $RCSfile: scan_remote.h,v $
 * $Revision: 1.2 $ $Date: 2013/08/07 17:31:29 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Type SCANREMOTE for remote scans
 * ===========================================================================
 * $Log: scan_remote.h,v $
 * Revision 1.2  2013/08/07 17:31:29  larme597
 * Adding environment variable.
 *
 * Revision 1.1  2012/06/19 16:25:09  larme597
 * SCANREMOTE type.
 *
 ****************************************************************************/

#ifndef _scanremote_h_
#define _scanremote_h_

EXTERN int scanremotetype;

struct scanremotecell
{
  objtags tags;
  short int length; /* maintained by system */
  int terminated;
  bindtype env;
  oidtype id;
  oidtype socket;
  oidtype buffer;
  oidtype current; /* reference to object that scan just returned */
};

#endif
