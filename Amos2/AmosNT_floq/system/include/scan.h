/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Robert Kajic, UDBL
 * $RCSfile: scan.h,v $
 * $Revision: 1.11 $ $Date: 2013/08/12 09:25:03 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Scan datatype. 
 * ===========================================================================
 * $Log: scan.h,v $
 * Revision 1.11  2013/08/12 09:25:03  larme597
 * New interface function.
 *
 * Revision 1.10  2012/06/27 19:20:07  torer
 * options in custom C functions passed as property list to scan functions
 *
 * Revision 1.9  2012/06/27 09:29:00  larme597
 * Storing socket in scan.
 *
 * Revision 1.8  2012/06/19 16:27:51  larme597
 * stream_eos_remotefn().
 *
 * Revision 1.7  2012/06/08 16:29:26  larme597
 * Setting buffer size and time out in open_* functions.
 *
 * Revision 1.6  2012/06/04 14:27:15  larme597
 * Remote scan functions visible.
 *
 * Revision 1.5  2011/05/11 18:09:29  roka4241
 * changed a bunch of exports into externs
 *
 * Revision 1.4  2011/05/06 15:59:51  torer
 * Scan is stream
 *
 * Revision 1.3  2011/04/20 17:16:31  roka4241
 * Returning of scans from amos to python. Calling and mapping over amos functions from python.
 *
 * Revision 1.2  2011/04/07 17:47:05  roka4241
 * Added scan_next wrapper around the lisp implementation to enable use of scans from c.
 *
 * Revision 1.1  2011/04/05 11:48:23  roka4241
 * added scan header
 *
 ****************************************************************************/

#ifndef _scan_h_
#define _scan_h_

EXTERN int scantype;

struct scancell
{
  objtags tags;
  short int length; /* maintained by system */
  int terminated;
  oidtype buffer;
  oidtype coroutine;
  oidtype current; /* reference to object that scan just returned */
  oidtype timeout;
  oidtype socket; /* Used if scan is server-side */
};

EXTERN oidtype terminated_symbol;

EXTERN void dealloc_stream(oidtype);

EXTERN oidtype stream_nextfn(bindtype env, oidtype oScan);
EXTERN int stream_eos_remotefn(bindtype env, oidtype oScan);
EXTERN oidtype stream_next_remotefn(bindtype env, oidtype oScan);
EXTERN oidtype open_function_streamfn(bindtype env, oidtype fn, oidtype args,
				      oidtype options);
EXTERN oidtype open_function_stream_remotefn(bindtype env, oidtype fn, 
                                             oidtype args, oidtype addr, 
					     oidtype options);
EXTERN oidtype open_query_streamfn(bindtype env, oidtype q, oidtype options);
EXTERN oidtype open_query_stream_remotefn(bindtype env, oidtype q, 
                                          oidtype addr, oidtype options);
EXTERN oidtype open_bag_streamfn(bindtype env, oidtype b, oidtype options);
EXTERN oidtype open_bag_stream_remotefn(bindtype env, oidtype b,
					oidtype address, oidtype options);
EXTERN oidtype close_stream_remotefn(bindtype env, oidtype oScan);

#endif

