/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  port: Port = stream handle. Extract = execute stream
 * Language:     C
 * Location:     AmosNT/astro/port.c
 ****************************************************************************/

#include <stdio.h>
#include "storage.h"
#include "storagetypes.h"
#include "comm.h"
#include "port.h"

#ifdef __MPI__
#include "mpistream.h"
#include "mpicomm.h"
#endif

//#define DEBUG
//#define TRACE_PACKET

// port(vector of stream,integer nsub,vector params)-> vector of sp
// params format: {"proto", {rank_1, ... , rank_n}}
// port(vector of stream, integer nsub, vector params, charstring postfilter, 
// vector dumpfiles, vector hostnames) -> vector of sp
// dumpfiles format: {charstring dumpfile_1, ..., charstring dumpfile_n}
// hostnames format: {charstring hostname_1, ..., charstring hostname_n}


extern oidtype stopsymbol;
extern oidtype emitsymbol;
extern oidtype eofsym;

void port_bf(a_callcontext cxt, a_tuple params) {
  int j, n_gen=0;
  oidtype argarray = nil, resultarray = nil, paramsarray = nil, 
    postfarray = nil, dumpfilearray = nil, hostnamearray = nil,
    execarray = nil, nsubarray = nil, osqlarray = nil, rargarray = nil;
	
  a_setf(argarray,a_getobjectelem(params, 0, FALSE));
  if (!arrayp(argarray)) {
    printf("port_bf: generator argument is not an array\n");
    fflush(stdout);
    // TODO: Raise error if input type is not an array
  }
  n_gen = a_arraysize(argarray);
  nsubarray = a_getobjectelem(params, 1, FALSE);
  if (0 == a_arraysize(nsubarray)) {
    nsubarray = new_array(n_gen, mkinteger(1));
  }
  a_setf(resultarray, new_array(n_gen, nil));
  a_setf(paramsarray, a_getobjectelem(params, 2, FALSE));
  if (!arrayp(paramsarray)) {
    printf("port_bf: params argument is not an array\n");
    fflush(stdout);
    // TODO: Raise error if input type is not an array
  }
  postfarray = a_getobjectelem(params, 3, FALSE);
  if (0 == a_arraysize(postfarray)) {
    postfarray = new_array(n_gen, mkstring(""));
  }
  dumpfilearray = a_getobjectelem(params, 4, FALSE);
  if (0 == a_arraysize(dumpfilearray)) {
    dumpfilearray = new_array(n_gen, nil);
  }
  hostnamearray = a_getobjectelem(params, 5, FALSE);
  if (0 == a_arraysize(hostnamearray)) {
    hostnamearray = new_array(n_gen, nil);
  }
  execarray = a_getobjectelem(params, 6, FALSE);
  if (0 == a_arraysize(execarray)) {
    execarray = new_array(n_gen, nil);
  }
  osqlarray = a_getobjectelem(params, 7, FALSE);
  if (0 == a_arraysize(osqlarray)) {
    osqlarray = new_array(n_gen, nil);
  }
  rargarray = a_getobjectelem(params, 8, FALSE);
  if (0 == a_arraysize(rargarray)) {
    rargarray = new_array(n_gen, nil);
  }

#ifdef DEBUG
  printf("port_bf: Will request %d ports.\n", n_gen);
  printf("port_bf: paramsarray "); a_print(paramsarray);
  printf("port_bf: argarray "); a_print(argarray);
	printf("port_bf: nsubarray "); a_print(nsubarray);
  printf("port_bf: postfarray "); a_print(postfarray);
  printf("port_bf: dumpfilearray "); a_print(dumpfilearray);
  printf("port_bf: hostnamearray "); a_print(hostnamearray);
  printf("port_bf: execarray "); a_print(execarray);
  printf("port_bf: osqlarray "); a_print(osqlarray);
  printf("port_bf: rargarray "); a_print(rargarray);
  fflush(stdout);
#endif
  if(equal(a_elt(paramsarray, 0), mkstring("tcp"))) {
    for (j = 0; j < n_gen; j++) {
      a_seta(resultarray, j,
	     call_lisp(mksymbol("request-tcpport"), cxt->env,
		       8,
		       a_elt(argarray, j), 
		       a_elt(nsubarray, j),
		       a_elt(postfarray, j),
		       a_elt(dumpfilearray, j),
		       a_elt(hostnamearray, j),
		       a_elt(execarray, j),
		       a_elt(osqlarray, j),
		       a_elt(rargarray, j)));
    }

  } else if (equal(a_elt(paramsarray, 0), mkstring("mpi"))) {
    oidtype rankarray = nil, debugprint = nil;
    a_setf(rankarray, a_elt(paramsarray, 1));
    if (!arrayp(rankarray)) {
      printf("port_bf: rank array is not an array\n");
      fflush(stdout);
      // TODO: Raise error if input type is not an array
    }
    if (a_arraysize(rankarray) != n_gen) {
      printf("port_bf: rank array is of wrong size\n");
      fflush(stdout);
      // TODO: Raise error if input type is not an array
    }
#ifdef DEBUG
    printf("port_bf: Requesting %d MPI ports\n", n_gen);
    fflush(stdout);
#endif
    for (j=0; j<n_gen; j++) {
      a_seta(resultarray, j,
	     make_portfn(cxt->env, mkstring("mpi"), a_elt(rankarray, j), 
			 mkinteger(0), nil));
      a_setf(debugprint,
	     call_lisp(mksymbol("request-bgport"), cxt->env,
		       3, a_elt(argarray,j), a_elt(nsubarray, j),
		       a_elt(resultarray,j)));
#ifdef DEBUG
      printf("port_bf: requested bgport and got "); 
      a_print(debugprint); 
      fflush(stdout);
#endif
    }
  } else if (equal(a_elt(paramsarray,0),mkstring("bgout"))) {
    oidtype rankarray = nil, debugprint = nil;
    int bgtag = 0;
    a_setf(rankarray, a_elt(paramsarray,1));
    if (!arrayp(rankarray)) {
      printf("port_bf: rank array is not an array\n");
      fflush(stdout);
      // TODO: Raise error if input type is not an array
    }
    if (a_arraysize(rankarray) != n_gen) {
      printf("port_bf: rank array is of wrong size\n");
      fflush(stdout);
      // TODO: Raise error if input type is not an array
    }
    // Enqueue the generator expressions to BG and return bgout ports.
    for (j=0; j<n_gen; j++) {
      a_seta(resultarray, j, 
	     make_portfn(cxt->env, mkstring("bgout"), a_elt(rankarray, j), 
			 mkinteger(bgtag), nil));
      a_setf(debugprint,
	     call_lisp(mksymbol("request-bgport"), cxt->env,
		       3, a_elt(argarray,j), a_elt(nsubarray,j),
		       a_elt(resultarray,j)));
#ifdef DEBUG
      printf("port_bf: requested bgport and got "); 
      a_print(debugprint); 
      fflush(stdout);
#endif
    }
  }
	
#ifdef DEBUG
  printf("port_bf: Resultarray "); 
  a_print(resultarray); 
  fflush(stdout);
#endif
  a_setelem(params, 9, resultarray);
  a_emit(cxt, params, FALSE);
  a_free(argarray);
  a_free(resultarray);
  a_free(paramsarray);
}

void extract_bf(a_callcontext cxt, a_tuple params) {
  oidtype *instream, argarray=nil, resultarray=nil, *rd;
  int cont_period, eofflag=0, inp, j, n_input, pos;
  double tstart, recv_t = 0.0;

  stopsymbol = mksymbol("stop");
  emitsymbol = mksymbol("emit");
  eofsym  = mksymbol("eof");
  cont_period = getinteger(globval(mksymbol("_continuation-period_")));
  cont_period = 1000000;
  a_setf(argarray, a_getobjectelem(params,0,FALSE));
  if (!arrayp(argarray)) {
    printf("port_bf: Not an array argument\n");
    fflush(stdout);
    /* TODO: Raise error if input type is not an array */
  }
  n_input = a_arraysize(argarray);
#ifdef DEBUG
  printf("extract_bf: cont_period=%d, Argarray: ", cont_period);
  a_print(argarray);
  printf("extract_bf: n_input=%d.\n", n_input);
  fflush(stdout);
#endif
	
  instream = (oidtype*)malloc(n_input*sizeof(oidtype));
  rd = (oidtype*)malloc(n_input*sizeof(oidtype));
  for (j=0; j<n_input; j++) {
    instream[j]=nil;
    rd[j]=nil;
  }
	
  // Open sockets to producers
  for (j=0; j < n_input; j++) {
    a_setf(instream[j], connecttoportfn(cxt->env, a_elt(argarray, j)));
#ifdef DEBUG
    printf ("extract_bf: n_input=%d, j=%d. Producer conn ", n_input, j);
    a_print(instream[j]);
    fflush(stdout);
#endif
  }
	
  for (;;) {
    // Request data from producers
    for (j=0; j<n_input; j++) {
#ifdef DEBUG
      printf("extract_bf: Sending EMIT to %d\n", j); fflush(stdout);
#endif
      printfn(cxt->env, emitsymbol, instream[j]);
      flushfn(cxt->env, instream[j]);
    }
#ifdef DEBUG
    printf("extract_bf: EMIT sent. Now waiting\n"); fflush(stdout);
#endif

    for (pos=0; pos < cont_period; pos++) {
      for (inp=0; inp < n_input; inp++) {
	tstart = run_time();
	a_setf(rd[inp], readfn(cxt->env, instream[inp]));
	recv_t += run_time() - tstart;
	a_setf(globval(mksymbol("_readtime_")), mkreal(recv_t));
#ifdef TRACE_PACKET
	printf("extract_bf: pos=%d, inp=%d, rd=", pos, inp);
	a_print(rd[inp]); 
	fflush(stdout);
#endif
	if(listp(rd[inp])) {
	  if (kar(rd[inp]) == mksymbol(":ERRCOND")) {
	    oidtype err = hd(tl(rd[inp]));
	    a_error(getinteger(hd(err)), hd(tl(tl(err))), FALSE);
	  }
	}
	while (listp(rd[inp]) && kar(rd[inp]) == mksymbol("hb")) {
	  call_lisp(mksymbol("symbol-setvalue"), cxt->env, 2,
		    mksymbol("_heartbeat_"), rd[inp]);
	  a_setf(rd[inp], readfn(cxt->env, instream[inp]));
	}
	if(rd[inp] == eofsym) {
	  eofflag=1;
	  break;
	}

      }
      if (!eofflag) {
	resultarray = new_array(n_input, nil);
	for (j=0; j<n_input; j++) {
	  a_seta(resultarray, j, rd[j]);
	}
	a_setelem(params, 1, resultarray);
	a_emit(cxt, params, FALSE);
      } else {
	/* EOF: stop input, recv&drop inflight messages, de-allocate */
	for(j=n_input-1; j>=0; j--) {
	  printfn(cxt->env, stopsymbol, instream[j]);
	  flushfn(cxt->env, instream[j]);
	}
	for(j = n_input - 1; j >= 0; j--) {
	  if (j != inp) { /* all except EOF sender */
	    do {
	      a_setf(rd[j], readfn(cxt->env, instream[j]));
#ifdef TRACE_PACKET
	      printf("extract_bf: gOT RUBBISH FROM inp %d:\n", j);
	      a_print(rd[j]);
	      fflush(stdout);
#endif
	    } while(rd[j] != eofsym);
	  }
	}
	for (j = 0; j < n_input; j++) {
	  a_free(rd[j]);
	}
	free(rd);
				
	for (j = 0; j < n_input; j++) {
	  a_free(instream[j]);
	}
	free(instream);
	return;
      } /* EOF cleanup */
    } /* pos = 0...cont_period */
  } /* Forever */
}
	
oidtype connecttoportfn(bindtype env, oidtype port) {
#ifdef DEBUG
  printf("connecttoportfn: Enter. Port is "); 
  a_print(port); 
  fflush(stdout);
#endif
  if(equal(port_getprotofn(env, port), mkstring("tcp"))) {
    oidtype tcpport = open_socket_blockfn(env, port_gethostnamefn(env, port),
					  port_getportnofn(env, port), mkreal(1.0), nil, nil);
    printfn(env, port_getsubfn(env, port), tcpport);
    flushfn(env, tcpport);
    return tcpport;
  }
#ifdef __MPI__
  else if(equal(port_getprotofn(env,port), mkstring("mpi"))) {
    oidtype ret=nil, mpiport=nil;
    int rank = 0;
    rank = getinteger(globval(mksymbol("_my-mpirank_")));
#ifdef DEBUG
    printf("connecttoportfn(mpi)@[%d]: start-bgport", rank); 
    fflush(stdout);
#endif
    /* My ID */
    a_setf(mpiport, 
	   make_portfn(env, mkstring("mpi"),
		       globval(mksymbol("_my-mpirank_")), mkinteger(0), nil));
    mpi_send_blockfn(env, mpiport, port_gethostnamefn(env,port), 
		     port_getportnofn(env,port));
    a_setf(ret,open_mpifn(env, port_gethostnamefn(env,port), 
			  port_getportnofn(env,port),
			  globval(mksymbol("_mpistreambufsize_"))));
#ifdef DEBUG
    printf("connecttoportfn(mpi)@[%d]: ret=", rank); 
    a_print(ret); 
    fflush(stdout);
#endif
    return ret;
  }
#endif
  else if(equal(port_getprotofn(env,port), mkstring("bgout"))) {
    oidtype listensock=nil, ret=nil;
    struct socketcell *scell;
    a_setf(listensock, open_socket_blockfn(env, nil, mkinteger(0), mkreal(1.0), nil, nil));
#ifdef DEBUG
    printf("connecttoportfn: listensock="); 
    a_print(listensock); 
    fflush(stdout);
#endif
    scell = dr(listensock,socketcell);
    call_lisp(mksymbol("start-bgport"), env, 2, 
	      make_portfn(env, mkstring("tcp"), mkstring("localhost"), 
			  mkinteger(scell->portno), nil),
	      port);
    a_setf(ret, call_lisp(mksymbol("accept-socket"), env, 1, listensock));
#ifdef DEBUG
    printf("connecttoportfn: ret="); a_print(ret); fflush(stdout);
#endif
    return ret;
  } else {
    printf("connecttoportfn: Unknown port protocol, ");
    a_print(port_getprotofn(env,port));
    return nil;
  }
}
	
void register_port(void) {
  //  a_extfunction("PORTBF",port_bf);
  //  a_extfunction("EXTRACTBF",extract_bf);
  //  extfunction1("connect-to-port", connecttoportfn);
}
