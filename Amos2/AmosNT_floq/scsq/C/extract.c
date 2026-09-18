/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Erik Zeitler, UDBL
 * $RCSfile: extract.c,v $
 * $Revision: 1.8 $ $Date: 2012/09/06 21:20:09 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Extract operators are
 *              extract, uall, smj, zip
 * ===========================================================================
 * $Log: extract.c,v $
 * Revision 1.8  2012/09/06 21:20:09  torer
 * using a_mapbag() instead of a_mapfunction()
 *
 * Revision 1.7  2011/02/21 16:38:51  zeitler
 * *** empty log message ***
 *
 * Revision 1.6  2011/01/12 00:31:11  zeitler
 * *** empty log message ***
 *
 * Revision 1.5  2010/12/30 19:44:10  zeitler
 * cleanup + eliminated warnings
 *
 * Revision 1.4  2010/12/06 23:17:38  zeitler
 * simplifications
 *
 * Revision 1.3  2010/09/03 12:46:16  zeitler
 * Poll timeout bug fix in smjna
 *
 * Revision 1.2  2010/09/02 14:22:38  zeitler
 * Sort Merge Join in C
 *
 * Revision 1.1  2010/08/19 14:58:57  zeitler
 * extract re-written in C
 *
 *
 ****************************************************************************/

#include "storage.h"
#include "callout.h"
#include "comm.h"
#include "amos.h"
#include "extract.h"
#include "sproc.h"
#include "numarray.h"

EXTERN oidtype error_qfn(bindtype env, oidtype form);

oidtype TS, ADD2DELAYS, EOFS, DERR, STOPSOCKS, STOPSYM, MERGEPROC, IEXTRACT;
oidtype REMPROD, ASYNCREAD, POLLIST;
oidtype SETDIFF, MEMQ, GS_SP;

double readtime;
int readcalls;


oidtype instrum_tsreadfn(bindtype env, oidtype stream) {
  double tstart = run_time();
  oidtype tpl = nil;
  a_setf(tpl, readfn(env, stream));

  if (nil != error_qfn(env, tpl)) {
    printf("instrum_tsdreadfn: got error tpl: "); a_print(tpl);
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

  readtime += run_time() - tstart;
  readcalls++;
  a_return(tpl);
}

oidtype instrum_ezreadfn(bindtype env, oidtype stream, oidtype allsocks) {
  double tstart = run_time();
  oidtype tpl = nil;
  a_setf(tpl, readfn(env, stream));

  if (nil != error_qfn(env, tpl)) {
    printf("instrum_ezreadfn: got error tpl: "); a_print(tpl);
    release(call_lisp(STOPSOCKS, env, 2, stream, allsocks));
    release(call_lisp(DERR, env, 1, tpl));
  }

  if (listp(tpl)) {
    if (hd(tpl) == TS) {
      a_setf(tpl, call_lisp(ADD2DELAYS, env, 1, tpl));
    } else if (hd(tpl) == EOFS) {
      printfn(env, STOPSYM, stream);
      flushfn(env, stream);
      close_socketfn(env, stream);
      release(call_lisp(MERGEPROC, env, 1, tpl));
      a_setf(tpl, nil);
    }
  }

  readtime += run_time() - tstart;
  readcalls++;
  a_return(tpl);
}

oidtype instrum_ezreadsfn(bindtype env, oidtype readarray, oidtype allsocks) {
  double tstart = run_time();
  oidtype tpl = nil;
  oidtype emitarray = nil;
  int i, alength = a_arraysize(readarray);

  a_setf(emitarray, new_array(alength, nil));
  for (i=0; i<alength; i++) {
    a_setf(tpl, readfn(env, a_elt(readarray, i)));

    if (nil != error_qfn(env, tpl)) {
      release(call_lisp(STOPSOCKS, env, 2, a_elt(readarray, i), allsocks));
      release(call_lisp(DERR, env, 1, tpl));
    }

    if (listp(tpl)) {
      if (hd(tpl) == TS) {
	a_setf(tpl, call_lisp(ADD2DELAYS, env, 1, tpl));
      } else if (hd(tpl) == EOFS) {
	printfn(env, STOPSYM, a_elt(readarray, i));
	flushfn(env, a_elt(readarray, i));
	close_socketfn(env, a_elt(readarray, i));
	release(call_lisp(MERGEPROC, env, 1, tpl));
	a_setf(tpl, nil);
      }
    }
    a_seta(emitarray, i, tpl);
    a_free(tpl);
  }

  readtime += run_time() - tstart;
  readcalls++;
  a_return(emitarray);
}

oidtype tsread(bindtype env, oidtype stream) {
  double tstart = run_time();
  oidtype tpl = nil;
  a_setf(tpl, readfn(env, stream));

  if (nil != error_qfn(env, tpl)) {
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

  readtime += run_time() - tstart;
  readcalls++;
  a_return(tpl);
}

oidtype csixtractbf(a_callcontext cxt) {
  oidtype tpl = nil, sp = nil, socket = nil;
  int graceful = 0;
  bindtype env = cxt->env;

  release(call_lisp(IEXTRACT, env, 0));
  a_setf(sp, a_arg(cxt, 1));
  a_setf(socket, call_lisp(GS_SP, cxt->env, 1, sp));

  {
    unwind_protect_begin;
    while (TRUE) {
      a_setf(tpl, tsread(env, socket));
      if (nil == tpl)
	break;
      a_bind(cxt, 2, tpl);
      a_result(cxt);
    }
    graceful = 1;
    unwind_protect_catch;
    if (!graceful) {
      printfn(env, STOPSYM, socket);
      flushfn(env, socket);
    }
    a_free(sp);
    a_free(socket);
    unwind_protect_end;
    return nil;
  }
}

oidtype uallcbbf(a_callcontext cxt) {
  oidtype spv = nil, sv = nil, rv = nil, to = nil;
  oidtype ev = nil;
  int graceful = 0, i, n;

  release(call_lisp(IEXTRACT, cxt->env, 0));
  a_setf(spv, a_arg(cxt, 1));
  a_setf(to, a_arg(cxt, 2));
  n = a_arraysize(spv);
  a_setf(sv, new_array(n, nil));
  for (i=0; i < n; i++) {
    a_seta(sv, i, call_lisp(GS_SP, cxt->env, 1, a_elt(spv, i)));
  }
  {
    unwind_protect_begin;
    while (a_arraysize(sv) > 0) {
      a_setf(rv, poll_sockets_blockfn(cxt->env, sv, to, nil));
      n = a_arraysize(rv);
      if (n > 0) {
	a_setf(ev, instrum_ezreadsfn(cxt->env, rv, sv));
	for (i=0; i < n; i++) {
	  if (nil == a_elt(ev, i)) {
	    a_setf(sv, call_lisp(REMPROD, cxt->env, 2,
				 a_elt(rv, i), sv));
	  } else {
	    a_bind(cxt, 3, a_elt(ev, i));
	    a_result(cxt);
	  }
	}
      }
    }
    graceful = 1;
    unwind_protect_catch;
    if (!graceful) {
      n = a_arraysize(sv);
      for (i=0; i<n; i++) {
	pffn(cxt->env, STOPSYM, a_elt(sv, i));
      }
    }
    a_free(spv);
    a_free(sv);
    a_free(to);
    a_free(rv);
    a_free(ev);
    unwind_protect_end;
    return nil;
  }
}

oidtype smjnacbbbf(a_callcontext cxt) {
  oidtype spv = nil, sockv = nil, to = nil, tplv = nil;
  oidtype lefttopoll = nil;
  int graceful = 0, i, n, mincount, attrib, *indexes;

  release(call_lisp(IEXTRACT, cxt->env, 0));
  a_setf(spv, a_arg(cxt, 1));
  attrib = getinteger(a_arg(cxt, 2));
  a_setf(to, a_arg(cxt, 3));
  n = a_arraysize(spv);
  a_setf(sockv, new_array(n, nil));
  for (i=0; i < n; i++) {
    a_seta(sockv, i, call_lisp(GS_SP, cxt->env, 1, a_elt(spv, i)));
  }

  {
    unwind_protect_begin;
    a_setf(tplv, call_lisp(ASYNCREAD, cxt->env, 1, sockv));
    indexes = malloc(sizeof(int) * a_arraysize(tplv));
    mincount = namin(indexes, tplv, attrib);
    while (mincount > 0) {
      n = a_arraysize(tplv);
      for (i = 0; i < n; i++) {
	if (indexes[i]) {
	  a_bind(cxt, 4, a_elt(tplv, i));
	  a_result(cxt);
	  if (nil != a_elt(sockv, i)) {
	    push(a_elt(sockv, i), lefttopoll);
	  }
	}
      }
      /* lefttopoll is a list of all sockets that still must be polled */
      while (listp(lefttopoll)) {
	oidtype polled = nil, pv = nil, topollv = nil;
	a_setf(topollv, listtoarrayfn(cxt->env, lefttopoll));
	while (nil == pv) { /* Wait until data arrives anywhere */
	  a_setf(pv, poll_sockets_blockfn(cxt->env, topollv, to, nil));
	}
        /* pv is a vector of all the sockets with some data to read */
	a_free(topollv);
	a_setf(polled, arraytolistfn(cxt->env, pv));
	a_free(pv);
	a_setf(lefttopoll, set_differencefn(cxt->env, lefttopoll, polled,
					    nil));
	/*a_setf(lefttopoll, call_lisp(SETDIFF, cxt->env, 2, 
	  lefttopoll, polled));*/
	for (i = 0; i < n; i++) {
	  if (nil != a_elt(sockv, i)) {
	    oidtype memq;
	    memq = memqfn(cxt->env, a_elt(sockv, i), polled);
	    /*a_setf(memq, call_lisp(MEMQ, cxt->env, 2, a_elt(sockv, i),
	      polled));*/
	    if (nil != memq) {
	      oidtype tpl;
	      tpl = instrum_ezreadfn(cxt->env, a_elt(sockv, i), sockv);
	      a_seta(tplv, i, tpl);
	    }
	  }
	}
	a_free(polled);
      }
      mincount = namin(indexes, tplv, attrib);
      a_free(lefttopoll);
    }
    graceful = 1;
    unwind_protect_catch;
    if (!graceful) {
      n = a_arraysize(sockv);
      for (i = 0; i < n; i++) {
	pffn(cxt->env, STOPSYM, a_elt(sockv, i));
      }
    }
    free(indexes);
    a_free(spv);
    a_free(sockv);
    a_free(to);
    a_free(tplv);
    a_free(lefttopoll);
    unwind_protect_end;
    return nil;
  }
}

void register_extract(void) {
  readtime = 0;

  TS = mksymbol("ts");
  ASYNCREAD = mksymbol("async-read");
  ADD2DELAYS = mksymbol("add2delaytimes");
  EOFS = mksymbol("EOF");
  DERR = mksymbol("derror");
  STOPSOCKS = mksymbol("stop-sockets");
  STOPSYM = mksymbol("STOP");
  MERGEPROC = mksymbol("merge-proctimes");
  IEXTRACT = mksymbol("init-extract");
  REMPROD = mksymbol("remove-producer");
  POLLIST = mksymbol("pollist");
  SETDIFF = mksymbol("set-difference");
  MEMQ = mksymbol("memq");
  GS_SP = mksymbol("get&start-sp");

  extfunction1("instr-tsread", instrum_tsreadfn);
  extfunction2("instr-ezread", instrum_ezreadfn);
  extfunction2("instr-ezreads", instrum_ezreadsfn);

  a_extimpl("csixtractbf", csixtractbf);
  a_extimpl("uallcbbf", uallcbbf);
  a_extimpl("smjnacbbbf", smjnacbbbf);
}
