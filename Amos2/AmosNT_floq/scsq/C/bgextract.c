/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Erik Zeitler, UDBL
 * $RCSfile: bgextract.c,v $
 * $Revision: 1.8 $ $Date: 2011/01/12 15:17:11 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Extract operators are
 *              extract, uall, smj, zip
 * ===========================================================================
 * $Log: bgextract.c,v $
 * Revision 1.8  2011/01/12 15:17:11  zeitler
 * tslreadfn
 *
 * Revision 1.7  2011/01/12 14:46:00  zeitler
 * lread extract
 *
 * Revision 1.6  2011/01/12 00:30:55  zeitler
 * *** empty log message ***
 *
 * Revision 1.5  2010/12/30 19:44:44  zeitler
 * single threaded bguall
 *
 * Revision 1.4  2010/12/19 13:47:33  zeitler
 * lprint + lread based operators
 *
 * Revision 1.3  2010/12/17 13:22:45  zeitler
 * remove read/print of separators
 *
 * Revision 1.2  2010/12/07 18:44:13  zeitler
 * *** empty log message ***
 *
 * Revision 1.1  2010/12/06 23:15:15  zeitler
 * bgrecv extract + uall
 *
 *
 ****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "comm.h"
#include "extract.h"
#include "bgextract.h"
#include "sproc.h"
#include "numarray.h"

//#define DEBUGBGE

oidtype BGS;

EXTERN oidtype error_qfn(bindtype env, oidtype form);

void init_bgs(bindtype env) {
  a_setf(BGS, call_lisp(mksymbol("bgsep"), env, 0));
}

oidtype tslreadfn(bindtype env, oidtype stream) {
  oidtype tpl = nil;

  a_setf(tpl, lreadfn(env, stream));

  if (nil != error_qfn(env, tpl)) {
#ifdef DEBUGBGE
    printf("tslread caught error: "); fflush(stdout);
    a_print(tpl);
#endif
    close_socketfn(env, stream);
    release(call_lisp(DERR, env, 1, tpl));
  }

  if (listp(tpl)) {
    if (hd(tpl) == TS) {
      release(call_lisp(ADD2DELAYS, env, 1, tpl));
      a_setf(tpl, a_nth(tpl, 3));
    } else if (hd(tpl) == EOFS) {
      printfn(env, STOPSYM, stream);
      flushfn(env, stream);
      close_socketfn(env, stream);
      release(call_lisp(MERGEPROC, env, 1, tpl));
      a_setf(tpl, nil);
    }
  }

  readcalls++;
  a_return(tpl);
}

oidtype bgextractbf(a_callcontext cxt) {
  static oidtype busy = nil;
  oidtype tpl = nil, sp = nil, socket = nil;
  int graceful = 0, stop = 0;
  bindtype env = cxt->env;

  if (BGS == nil) init_bgs(cxt->env);
  if (busy == nil) busy = mksymbol("*BUSY*");

  release(call_lisp(IEXTRACT, env, 0));
  a_setf(sp, a_arg(cxt, 1));
  a_setf(socket, call_lisp(GS_SP, cxt->env, 2, sp, BGS));

  {
    unwind_protect_begin;
    do {
      a_setf(tpl, tslreadfn(env, socket));
      if (busy == tpl) {
	a_sleep(0.001);
	continue;
      }
      if (nil == tpl) {
	stop = 1;
	break;
      }
      a_bind(cxt, 2, tpl);
      a_result(cxt);
    } while (!stop);
    graceful = 1;
    unwind_protect_catch;
    if (!graceful) {
      fflush(stdout);
      printfn(env, STOPSYM, socket);
      flushfn(env, socket);
    }
    a_free(sp);
    a_free(socket);
    unwind_protect_end;
  }
  return nil;
}

oidtype bgezreadfn(bindtype env, oidtype stream, oidtype allsocks) {
  oidtype tpl = nil;
  a_setf(tpl, lreadfn(env, stream));

  if (nil != error_qfn(env, tpl)) {
#ifdef DEBUGBGE
    printf("bgezreadfn: got error tpl: "); fflush(stdout);
    a_print(tpl);
#endif
    release(call_lisp(STOPSOCKS, env, 2, stream, allsocks));
    release(call_lisp(DERR, env, 1, tpl));
  }

  if (listp(tpl)) {
    if (hd(tpl) == TS) {
      a_setf(tpl, call_lisp(ADD2DELAYS, env, 1, tpl));
    } else if (hd(tpl) == EOFS) {
#ifdef DEBUGBGE
      printf("[bgezreadfn: EOF from "); a_prin1(stream, stdoutstream, TRUE);
      printf("]\n"); fflush(stdout);
#endif
      printfn(env, STOPSYM, stream);
      flushfn(env, stream);
      close_socketfn(env, stream);
      release(call_lisp(MERGEPROC, env, 1, tpl));
      a_setf(tpl, nil);
    }
  }

  readcalls++;
  a_return(tpl);
}

oidtype bguallbbf(a_callcontext cxt) {
  static oidtype busy = nil;
  oidtype spv = nil, sv = nil, to = nil, e = nil;
  int graceful = 0, i, busycount;
  double timeout;

  if (BGS == nil) init_bgs(cxt->env);
  if (busy == nil) busy = mksymbol("*BUSY*");

  release(call_lisp(IEXTRACT, cxt->env, 0));
  a_setf(spv, a_arg(cxt, 1));
  a_setf(to, a_arg(cxt, 2));
  timeout = getreal(to);
  a_setf(sv, new_array(a_arraysize(spv), nil));
  for (i=0; i < a_arraysize(spv); i++) {
    a_seta(sv, i, call_lisp(GS_SP, cxt->env, 2, a_elt(spv, i), BGS));
  }

  {
    unwind_protect_begin;
#ifdef DEBUGBGE
    printf("[bguallbf: size %d]", a_arraysize(sv)); fflush(stdout);
#endif
    while (a_arraysize(sv) > 0) {
      busycount = 0;
      for (i = 0; i < a_arraysize(sv); i++) {
	a_setf(e, bgezreadfn(cxt->env, a_elt(sv, i), sv));
	if (nil == e) {
	  a_setf(sv, call_lisp(REMPROD, cxt->env, 2, a_elt(sv, i), sv));
#ifdef DEBUGBGE
	  printf("[removed producer %d: size %d]\n", i, a_arraysize(sv));
	  fflush(stdout);
#endif
	} else if (busy == e) {
	  busycount++;
	  continue;
	} else {
	  a_bind(cxt, 3, e);
	  a_result(cxt);
	}
      }
      if (busycount == a_arraysize(sv)) {
	a_sleep(0.001); // sleep some if all were busy
      }
    }

    graceful = 1;
    unwind_protect_catch;
    if (!graceful) {
      for (i=0; i<a_arraysize(sv); i++) {
	pffn(cxt->env, STOPSYM, a_elt(sv, i));
      }
    }
    a_free(spv);
    a_free(sv);
    a_free(to);
    unwind_protect_end;
  }
  return nil;
}

void register_bgextract(void) {
  BGS = nil;

  a_extimpl("bguallbbf", bguallbbf);
  a_extimpl("bgextractbf", bgextractbf);

  extfunction1("tslread", tslreadfn);
}
