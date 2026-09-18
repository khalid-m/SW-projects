/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Lars Melander, UDBL
 * $RCSfile: scan_remote.c,v $
 * $Revision: 1.2 $ $Date: 2013/08/07 17:32:26 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Type SCANREMOTE for remote scans
 * ===========================================================================
 * $Log: scan_remote.c,v $
 * Revision 1.2  2013/08/07 17:32:26  larme597
 * Adding deallocation of scan on server.
 *
 * Revision 1.1  2012/06/19 16:24:24  larme597
 * SCANREMOTE type.
 *
 ****************************************************************************/

#include "amos.h"
#include "storagetypes.h"
#include "scan_remote.h"

EXTERN oidtype terminated_symbol;
EXPORT int scanremotetype;

oidtype make_scanremotefn(bindtype env, oidtype socket, oidtype id,
			  oidtype buffer)
{
  oidtype res;
  struct scanremotecell *dres;

  res = new_object(sizeof(*dres), scanremotetype);
  dres = dr(res, scanremotecell);
  a_let(dres->socket, socket);
  a_let(dres->id, id);
  a_let(dres->buffer, buffer);
  dres->current = nil;
  dres->terminated = FALSE;
  dres->env = env;
  return res;  
}

EXPORT void dealloc_scanremote(oidtype x) 
{
  struct scanremotecell *dx = dr(x, scanremotecell);

  if (!dx->terminated)
    release(call_lisp(mksymbol("_scan-close-remote"), dx->env, 2,
		      dx->id, dx->socket));

  a_free(dx->socket);
  a_free(dx->id);
  a_free(dx->buffer);
  a_free(dx->current);
  dealloc_object(x);
}

oidtype scanremote_idfn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  return dr(scan, scanremotecell)->id;
}

oidtype scanremote_socketfn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  return dr(scan, scanremotecell)->socket;
}

oidtype scanremote_getbufferfn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  return dr(scan, scanremotecell)->buffer;
}

oidtype scanremote_setbufferfn(bindtype env, oidtype scan, oidtype val)
{
  OfType(scan, scanremotetype, env);

  a_setf(dr(scan, scanremotecell)->buffer, val);
  return val;
}

oidtype scanremote_getcurrentfn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  return dr(scan, scanremotecell)->current;
}

oidtype scanremote_setcurrentfn(bindtype env, oidtype scan, oidtype val)
{
  OfType(scan, scanremotetype, env);

  a_setf(dr(scan, scanremotecell)->current, val);
  return val;
}

oidtype scanremote_terminatedfn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  if (dr(scan, scanremotecell)->terminated)
    return terminated_symbol;
  else
    return nil;
}

oidtype scanremote_terminatefn(bindtype env, oidtype scan)
{
  OfType(scan, scanremotetype, env);

  dr(scan, scanremotecell)->terminated = TRUE;
  return scan;
}

void register_scanremote(void)
{
  scanremotetype = a_definetype("scanremote", dealloc_scanremote, NULL);
  extfunction3("make-scan-remote", make_scanremotefn);
  extfunction1("scan-remote-id", scanremote_idfn);
  extfunction1("scan-remote-socket", scanremote_socketfn);
  extfunction1("scan-remote-getbuffer", scanremote_getbufferfn);
  extfunction2("scan-remote-setbuffer", scanremote_setbufferfn);
  extfunction1("scan-remote-getcurrent", scanremote_getcurrentfn);
  extfunction2("scan-remote-setcurrent", scanremote_setcurrentfn);
  extfunction1("scan-remote-terminated", scanremote_terminatedfn);
  extfunction1("scan-remote-terminate", scanremote_terminatefn);
}
