/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: scan.c,v $
 * $Revision: 1.14 $ $Date: 2013/09/02 14:20:00 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Scan storage type
 * ===========================================================================
 * $Log: scan.c,v $
 * Revision 1.14  2013/09/02 14:20:00  larme597
 * Function for replacing a scan socket.
 *
 * Revision 1.13  2013/08/12 09:21:52  larme597
 * New interface function.
 *
 * Revision 1.12  2012/06/27 19:20:07  torer
 * options in custom C functions passed as property list to scan functions
 *
 * Revision 1.11  2012/06/27 09:28:06  larme597
 * Storing socket in scan.
 *
 * Revision 1.10  2012/06/19 16:23:01  larme597
 * Updates.
 *
 * Revision 1.9  2012/06/08 16:31:33  larme597
 * Buffer size and timeout in open_* functions.
 *
 * Revision 1.8  2012/06/04 14:33:54  larme597
 * Remote stream functions.
 *
 * Revision 1.7  2011/05/11 18:09:27  roka4241
 * changed a bunch of exports into externs
 *
 * Revision 1.6  2011/05/06 15:59:49  torer
 * Scan is stream
 *
 * Revision 1.5  2011/04/07 17:45:45  roka4241
 * Added scan_next wrapper around the lisp implementation to enable use of scans from c.
 *
 * Revision 1.4  2011/04/05 11:48:21  roka4241
 * added scan header
 *
 * Revision 1.3  2011/02/01 13:22:46  larme597
 * Adding amos functions "this" and "peek" to scans.
 *
 * Revision 1.2  2011/01/26 20:51:19  torer
 * Terminate thread when closing scan
 *
 * Revision 1.1  2011/01/21 14:31:49  torer
 * New storage type SCAN
 *
 ****************************************************************************/

#include "amos.h"
#include "storagetypes.h"
#include "scan.h"

EXPORT int scantype;
EXPORT oidtype terminated_symbol;
oidtype scan_eos, scan_nextrow, scan_eos_remote, scan_nextrow_remote,
  open_function_scan, open_function_scan_remote, open_query_scan,
  open_query_scan_remote, open_bag_scan,
  open_stream_scan_remote, scan_close_remote;

oidtype make_scanfn(bindtype env, oidtype buffer, oidtype coroutine,
		    oidtype timeout, oidtype socket)
     /* Construct new scan with attributes */
{
  oidtype res;
  struct scancell *dres;

  res = new_object(sizeof(*dres), scantype);
  dres = dr(res, scancell);
  a_let(dres->buffer, buffer);
  a_let(dres->coroutine, coroutine);
  dres->current = nil;
  dres->terminated = FALSE;
  a_let(dres->timeout, timeout);
  a_let(dres->socket, socket);
  return res;  
}

oidtype scan_update_socketfn(bindtype env, oidtype scan, oidtype socket)
{
  a_setf(dr(scan, scancell)->socket, socket);
  return nil;
}

EXPORT void dealloc_stream(oidtype x) 
{
  struct scancell *dx = dr(x, scancell);

  a_free(dx->buffer);
  a_free(dx->coroutine);
  a_free(dx->current);
  a_free(dx->timeout);
  a_free(dx->socket);
  dealloc_object(x);
}

void print_scan(oidtype x, oidtype stream, int princflg) 
{
  struct scancell *dx = dr(x, scancell);

  a_puts("#[SCAN ",stream);
  a_prin1(dx->buffer, stream, princflg);
  a_putc(' ',stream);
  a_prin1(dx->coroutine, stream, princflg);
  a_putc(' ',stream);
  if (dx->terminated) a_puts("*TERMINATED*", stream);
  a_putc(']',stream);
}


oidtype scan_bufferfn(bindtype env, oidtype xp)
     /* Access query scan buffer */
{
  OfType(xp, scantype, env);
  
  return dr(xp,scancell)->buffer;
}

oidtype scan_coroutinefn(bindtype env, oidtype xp)
     /* Access query scan coroutine  */
{
  OfType(xp, scantype, env);
  
  return dr(xp,scancell)->coroutine;
}

oidtype scan_getcurrentfn(bindtype env, oidtype xp)
     /* Access query scan resently returned object */
{
  OfType(xp, scantype, env);
  
  return dr(xp,scancell)->current;
}

oidtype scan_setcurrentfn(bindtype env, oidtype xp, oidtype val)
     /* Access query scan resently returned object */
{
  OfType(xp, scantype, env);

  a_setf(dr(xp,scancell)->current, val);
  return val;
}

oidtype scan_terminatedfn(bindtype env, oidtype xp)
     /* True if scan terminated */
{
  OfType(xp, scantype, env);
  
  if(dr(xp,scancell)->terminated) return terminated_symbol;
  else return nil;
}

oidtype scan_terminatefn(bindtype env, oidtype xp)
     /* Terminate scan */
{
  OfType(xp, scantype, env);
  
  dr(xp,scancell)->terminated=TRUE; 
  a_free(dr(xp,scancell)->coroutine); /* Terminate thread */
  return xp;
}

oidtype scan_timeoutfn(bindtype env, oidtype xp)
{
  OfType(xp, scantype, env);

  return dr(xp, scancell)->timeout;
}

oidtype scan_socketfn(bindtype env, oidtype xp)
{
  OfType(xp, scantype, env);

  return dr(xp, scancell)->socket;
}

EXPORT oidtype stream_nextfn(bindtype env, oidtype oScan)       
{ 
  if (call_lisp(scan_eos, env, 1, oScan) == nil) {
    return call_lisp(scan_nextrow, env, 1, oScan);
  } else {
    return nil;
  }
}

EXPORT int stream_eos_remotefn(bindtype env, oidtype oScan)
{
  return call_lisp(scan_eos_remote, env, 1, oScan) != nil;
}

EXPORT oidtype stream_next_remotefn(bindtype env, oidtype oScan)       
{
  if (stream_eos_remotefn(env, oScan))
    return nil;
  return call_lisp(scan_nextrow_remote, env, 1, oScan);
}

EXPORT oidtype open_function_streamfn(bindtype env, oidtype fn, oidtype args,
				      oidtype options)
{
  return call_lisp(open_function_scan, env, 3, fn, args, options);
}

EXPORT oidtype open_function_stream_remotefn(bindtype env, oidtype fn, 
					     oidtype args, oidtype address, 
					     oidtype options)
{
  return call_lisp(open_function_scan_remote, env, 
                   4, fn, args, address, options);
}

EXPORT oidtype open_query_streamfn(bindtype env, oidtype q, oidtype options)
{
  return call_lisp(open_query_scan, env, 2, q, options);
}

EXPORT oidtype open_query_stream_remotefn(bindtype env, oidtype q, 
                                          oidtype address, oidtype options)
{
  return call_lisp(open_query_scan_remote, env, 3, q, address, options);
}

EXPORT oidtype open_bag_streamfn(bindtype env, oidtype b, oidtype options)
{
  return call_lisp(open_bag_scan, env, 2, b, options);
}

EXPORT oidtype open_bag_stream_remotefn(bindtype env, oidtype b,
					oidtype address, oidtype options)
{
  return call_lisp(open_stream_scan_remote, env, 3, b, address, options);
}

EXPORT oidtype close_stream_remotefn(bindtype env, oidtype oScan)
{
  return call_lisp(scan_close_remote, env, 1, oScan);
}

void register_scan(void)
{
  scantype = a_definetype("scan", dealloc_stream, print_scan);
  scan_eos = mksymbol("scan-eos");
  scan_nextrow = mksymbol("scan-nextrow");
  scan_eos_remote = mksymbol("scan-eos-remote");
  scan_nextrow_remote = mksymbol("scan-nextrow-remote");
  open_function_scan = mksymbol("open-function-scan");
  open_function_scan_remote = mksymbol("open-function-scan-remote");
  open_query_scan = mksymbol("open-query-scan");
  open_query_scan_remote = mksymbol("open-query-scan-remote");
  open_bag_scan = mksymbol("open-bag-scan");
  open_stream_scan_remote = mksymbol("open-stream-scan-remote");
  scan_close_remote = mksymbol("scan-close-remote");
  extfunction4("make-scan", make_scanfn);
  extfunction2("scan-update-socket", scan_update_socketfn);
  extfunction1("scan-buffer", scan_bufferfn);
  extfunction1("scan-coroutine", scan_coroutinefn);
  extfunction1("scan-getcurrent", scan_getcurrentfn);
  extfunction2("scan-setcurrent", scan_setcurrentfn);
  terminated_symbol = mksymbol("*terminated*");
  extfunction1("scan-terminated", scan_terminatedfn);
  extfunction1("scan-terminate", scan_terminatefn);
  extfunction1("scan-timeout", scan_timeoutfn);
  extfunction1("scan-socket", scan_socketfn);
}
