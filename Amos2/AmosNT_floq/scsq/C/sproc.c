/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  sproc: TCP Stream Processor
 *                      - sproc: Installs generators on SPs
 *                      - stream_generator_mapper: Iterate over a generator
 * Language:		 C
 * Location:		 AmosNT/astro/sproc.c
 ****************************************************************************/

#include <stdio.h>
#include <time.h>
#include "storage.h"
#include "storagetypes.h"
#include "callout.h"
#include "comm.h"
#include "sproc.h"
#include "extract.h"
#include "amos.h"

#ifdef NT
#include "wproctime.h"
#endif

#ifdef __MPI__
#include "mpicomm.h"
#include "mpistream.h"
#endif

//#define DEBUG
//#define TRACE_PACKET
//#define PRINTSTAT

double runtime, commtime, commtime_acc;
clock_t run_c, comm_c, comm_acc_c;

double printtime;
int printcalls, readcalls, proactive_flush, forced_flush;
int NO_LIST_ARRAY;
oidtype pts, pcs;

EXTERN oidtype error_qfn(bindtype env, oidtype form);
EXTERN double a_round(double x);
EXTERN oidtype make_recordfn(bindtype env, oidtype fields);

// Errors
int illegal_subid;

struct evalstate {
  int stop_flag, n_sub, first_time, protocol, cnc_rank;
  int pcount;
  oidtype poll_waittime;
	
  a_callcontext cxt;
  a_tuple params;
  int cont_period;
  oidtype sub_stream;
  oidtype coo_stream, preplistensock;
  oidtype postfilter;
};

oidtype callfunction1fn(bindtype env, oidtype fno, oidtype args);
int poll_socket(SOCKET sock, double to);
void add_subscriber(bindtype env, struct evalstate *mapperstate, 
                    oidtype new_socket);


oidtype stopsymbol=nil;
oidtype emitsymbol=nil;
oidtype eofsym=nil;

#define prstrlen 100
char prstr[prstrlen];

void pffn(bindtype env, oidtype object, oidtype socket) {
	printfn(env, object, socket);
	flushfn(env, socket);
}

oidtype stream_generator_mapper(a_callcontext cxt, int width,
								oidtype *restpl, void *xa) {
  struct evalstate *mapperstate;
  oidtype rd = nil, ctpl = nil, ps = nil;
  oidtype postf_res = nil, rlist = nil, cfres = nil;
  int j, event = 0;

  mapperstate = (struct evalstate *)xa;
  mapperstate->first_time=0;
  a_setf(ctpl, a_resultarray(width, restpl));

  // This is the actual emit
#ifdef TRACE_PACKET
  printf("stream_generator_mapper[%s]: ctpl=", prstr);
  a_print(ctpl);
  fflush(stdout);
#endif
  if (mapperstate->postfilter == nil) {
    commtime = run_time();
    comm_c = clock();
    for(j=0; j<mapperstate->n_sub; j++) {
      printfn(cxt->env, a_elt(ctpl, 0), a_elt(mapperstate->sub_stream, j));
      flushfn(cxt->env, a_elt(mapperstate->sub_stream, j));
    }
    commtime_acc += run_time() - commtime;
    comm_acc_c += clock() - comm_c;
  } else {
    // Postfilter function is present. Run the postfilter for each subscriber.
    for(j=0; j<mapperstate->n_sub; j++) {
      a_setf(rlist, a_list(a_elt(ctpl, 0), mkinteger(j),
			   mkinteger(mapperstate->n_sub),NULL));
      a_setf(cfres, callfunction1fn(cxt->env, mapperstate->postfilter, 
				    rlist));
      // Call kar() instead of hd(). callfunction1fn might return nil.
      a_setf(postf_res, kar(cfres));
      a_free(rlist);
      a_free(cfres);

#ifdef TRACE_PACKET
      printf("stream_generator_mapper[%s]: outbox=%d, ", prstr, j);
      if (postf_res == nil) {
	printf("NIL\n");
      } else {
	printf("sending ");
	a_print(a_elt(postf_res, 0));
      }
#endif
      if (postf_res != nil) {
	comm_c = clock();
	commtime = run_time();
	printfn(cxt->env, a_elt(postf_res, 0), a_elt(mapperstate->sub_stream, 
                                                     j));
	flushfn(varstack,a_elt(mapperstate->sub_stream, j));
	commtime_acc += run_time() - commtime;
	comm_acc_c += clock() - comm_c;
      }
    } // for (j=0..n_sub)
    a_free(postf_res);
  } // if postfilter
  a_free(ctpl);
#ifdef PRINTSTAT
  a_printstat();
#endif
  return nil;
}

int sproc(a_callcontext cxt, int protocol) {
  struct evalstate mapperstate;
  oidtype rd=nil;
#ifdef __MPI__
  int tag;
#endif
		
  char *str;
  int i, j;
  clock_t sl_startc;
  oidtype rcvd_pfilter = nil;
  oidtype errcond=nil;
  stopsymbol = mksymbol("stop");
  emitsymbol = mksymbol("emit");
  eofsym  = mksymbol("eof");
  runtime = run_time();
  run_c = clock();
  commtime_acc = 0.0;
  comm_acc_c = 0;
  mapperstate.protocol = protocol;
  mapperstate.n_sub = 0;
  mapperstate.first_time = 1;
  mapperstate.stop_flag = 0;
  mapperstate.coo_stream = nil;
  mapperstate.postfilter = nil;
  mapperstate.poll_waittime = mkreal(0.0);
  mapperstate.cont_period = 
    getinteger(globval(mksymbol("_continuation-period_")));
  mapperstate.cont_period = 1000000;
  mapperstate.preplistensock = nil;
  IntoString(globval(mksymbol("_amosid_")), str, varstack);
  mapperstate.pcount = 0;
  /* Set up traceable print outs */
  switch(mapperstate.protocol) {
  case MPIPROTOCOL:
    sprintf(prstr,"%s:%d", str, 
	    getinteger(globval(mksymbol("_my-mpirank_"))));
    break;
  case TCPPROTOCOL:
    strncpy(prstr,str,prstrlen);
    break;
  }
  printf("sproc[%s]: Starting\n", prstr); fflush(stdout);
		
		
  // Read form from coo/cnc
  switch(mapperstate.protocol) {
#ifdef __MPI__
  case MPIPROTOCOL:
    a_setf(rd, a_mpi_proberecv_any_block(&mapperstate.cnc_rank, &tag));
#ifdef DEBUG
    printf("sproc(mpi)[%s]: Got form on %d:%d\n", prstr, 
	   mapperstate.cnc_rank, tag); fflush(stdout);
#endif
    break;
#endif
  case TCPPROTOCOL:
    a_setf(mapperstate.preplistensock, 
	   globval(mksymbol("_prep-listen-sock_")));
    a_setf(mapperstate.coo_stream, 
	   accept_socket_blockfn(varstack, mapperstate.preplistensock));
#ifdef DEBUG
    printf("sproc(tcp)[%s]: Got form on ", prstr);
    a_print(mapperstate.coo_stream);
    fflush(stdout);
#endif
    commtime = run_time();
    comm_c = clock();
    a_setf(rd, readfn(varstack, mapperstate.coo_stream));
    commtime_acc += run_time() - commtime;
    comm_acc_c += clock() - comm_c;
  }
		
  if (rd == stopsymbol) {
#ifdef DEBUG
    printf("sproc[%s]: received stopsymbol. Quit!\n",prstr); fflush(stdout);
#endif
    a_free(rd);
    a_free(mapperstate.coo_stream);
    runtime = run_time() - runtime;
    run_c = clock() - run_c;
    printf("sproc[%s]: total_runtime %f commtime_acc %f run_c %f comm_c %f\n",
	   prstr, runtime, commtime_acc, (double)run_c/(double)CLOCKS_PER_SEC,
	   (double)comm_acc_c/(double)CLOCKS_PER_SEC);
    fflush(stdout);
    return 0; // Tell server loop to quit
  }

  switch(mapperstate.protocol) {
#ifdef __MPI__
  case MPIPROTOCOL:
    mapperstate.n_sub = 
      getinteger(a_mpi_proberecv_block(mapperstate.cnc_rank));
    break;
#endif
  case TCPPROTOCOL:
    commtime = run_time();
    comm_c = clock();
    mapperstate.n_sub = getinteger(readfn(varstack, mapperstate.coo_stream));

    rcvd_pfilter = readfn(varstack, mapperstate.coo_stream);
    commtime_acc += run_time() - commtime;
    comm_acc_c += clock() - comm_c;
    printf("rcvd_pfilter (postfilter function)= "); a_print(rcvd_pfilter);
	  if(!equal(rcvd_pfilter,mkstring(""))) {
			mapperstate.postfilter = rcvd_pfilter;
    } else {
			printf("mapperstate.postfilter remains nil\n");
		}
    break;
  }
  mapperstate.sub_stream = new_adjarray(mapperstate.n_sub, nil);
		
#ifdef DEBUG
  printf("sproc[%s]: nsubscribers=%d, rd = ", prstr, mapperstate.n_sub);
  a_print(rd); fflush(stdout);
  printf("sproc[%s]: postfilter: ", prstr);
  a_print(mapperstate.postfilter);
  printf("sproc[%s]: (inspect-generator): ",prstr);
  inspect_generatorfn(varstack, rd);
  fflush(stdout);
  printf("sproc[%s]: generator-fn: ",prstr);
  a_print(generator_functionfn(varstack, rd));
  printf("sproc[%s]: args: ",prstr);
  a_print(generator_paramsfn(varstack, rd));
  fflush(stdout);
#endif

  // Wait for subscriber(s)to request data
  printf("stream_generator_mapper[%s]: first_time\n", prstr);
  fflush(stdout);
  for (i=0; i<mapperstate.n_sub; i++) {
    oidtype extractport = nil;
    oidtype subscriber = nil;
    oidtype sub_id = nil;
    int nodenum=0, tag=0;
    switch(mapperstate.protocol) {
#ifdef __MPI__
    case MPIPROTOCOL:
      a_setf(extractport, a_mpi_proberecv_any_block(&nodenum, &tag));
      printf("stream_generator_mapper[%s]: extractport=", prstr); 
      fflush(stdout);
      a_print(extractport), fflush(stdout);
      if (equal(port_getprotofn(env,extractport), mkstring("tcp"))) {
	a_seta(mapperstate.sub_stream, i,
	       open_socket_blockfn(env, port_gethostnamefn(env,extractport), 
				   port_getportnofn(env,extractport),
				   mkreal(1.0)));
      } else if (equal(port_getprotofn(env,extractport), mkstring("mpi"))) {
	a_seta(mapperstate.sub_stream, i,
	       open_mpifn(env, port_gethostnamefn(env,extractport), 
			  port_getportnofn(env, extractport), 
			  globval(mksymbol("_mpistreambufsize_"))));
      } else {
	printf("stream_generator_mapper[%s]: Subscriber proto not implemented"
	       "here, ", prstr);
	a_print(port_getprotofn(env,extractport)); fflush(stdout);
	// TODO: Raise error!
      }
      break;
#endif
    case TCPPROTOCOL:
      printf("stream_generator_mapper[%s]: Waiting for connection on "
	     "preplistensock [i=%d]: ", prstr, i);
      a_print(mapperstate.preplistensock);
      fflush(stdout);
      subscriber = accept_socket_blockfn(cxt->env, mapperstate.preplistensock);
      printf("Connected to");
      a_print(subscriber);
      fflush(stdout);
      sub_id = readfn(varstack, subscriber);
      printf("sub_id: ");
      a_print(sub_id);
      fflush(stdout);
      if (integerp(sub_id)) {
				a_seta(mapperstate.sub_stream, getinteger(sub_id), subscriber);
      } else if (sub_id == nil) {
				a_seta(mapperstate.sub_stream, i, subscriber);
      } else {
				a_error(illegal_subid, sub_id, FALSE);
      }
      break;
    default:
      printf("Unknown protocol\n"); fflush(stdout);
      break;
    } // switch(proto)
  } // for (i=0..n_sub)

	printf("subscribers:\n");
	a_print(mapperstate.sub_stream);

  // Do it
  { struct a_callcontextrec cxt;
  unwind_protect_begin;
  sl_startc = clock();
  printf("sproc[%s]: entering mapfn\n", prstr);
  cxt.env=varstack;
  a_mapbag(&cxt, rd, stream_generator_mapper, (void*)&mapperstate);
  printf("sproc[%s]: after mapfn\n", prstr);
		
  unwind_protect_catch;
  if (unwind_reset) {
    if (1==mapperstate.stop_flag) {
      for (j=0; j<mapperstate.n_sub; j++) {
				printfn(varstack, eofsym, a_elt(mapperstate.sub_stream, j));
				flushfn(varstack, a_elt(mapperstate.sub_stream, j));
      }
#ifdef DEBUG
      printf("sproc[%s]: Subscriber requested STOP. EOF sent. Exiting to main "
	     "loop\n", prstr);
      fflush(stdout);
#endif
    } else {
      // Pass error to all subscribers
      printf("sproc[%s] in unwind_reset: Error raised. Sending err to parent\n",
	     prstr);
      fflush(stdout);
      a_setf(errcond, globval(mksymbol("_error-condition_")));
			printf("globval(mksymbol(\"_error-condition_\")): ");
			a_print(globval(mksymbol("_error-condition_")));
			printf("\n");
      printf("sproc[%s] in unwind_reset:", prstr);
			a_print(errcond);
			fflush(stdout);
      for (j=0; j<mapperstate.n_sub; j++) {
				printfn(varstack, errcond, a_elt(mapperstate.sub_stream, j));
				flushfn(varstack, a_elt(mapperstate.sub_stream, j));
      }
    }
  } else { // Normal termination after mapfunction (no more tuples)
    for (j=0; j<mapperstate.n_sub; j++) {
      commtime = run_time();
      comm_c = clock();
      printfn(varstack, eofsym, a_elt(mapperstate.sub_stream, j));
      flushfn(varstack, a_elt(mapperstate.sub_stream, j));
      commtime_acc += run_time() - commtime;
      comm_acc_c += clock() - comm_c;
    }
    for (j=0; j<mapperstate.n_sub; j++) {
      do {
	commtime = run_time();
	comm_c = clock();
	a_setf(rd, readfn(varstack, a_elt(mapperstate.sub_stream, j)));
	commtime_acc += run_time() - commtime;
	comm_acc_c += clock() - comm_c;
#ifdef DEBUG
	printf("sproc[%s]: Awaiting STOP from %d. Received ",prstr, j); 
	a_print(rd); fflush(stdout);
#endif
      } while (rd != stopsymbol);
    }
  }
  // Normal termination after mapfunction (no more tuples)
  a_free(mapperstate.sub_stream);
  a_free(mapperstate.coo_stream);
  a_free(mapperstate.preplistensock);
  a_free(rd);
  /* NB: No unwind_protect_end since we are at top level. */
  }
  runtime = run_time() - runtime;
  run_c = clock() - run_c;
  printf("sproc[%s]: total_runtime %f commtime_acc %f run_c %f comm_c %f\n",
	 prstr, runtime, commtime_acc, run_c/(CLOCKS_PER_SEC + 0.0), 
	 comm_acc_c/(CLOCKS_PER_SEC +0.0));
  printf("== We will return 1\n");
  fflush(stdout);
  return 1; /* Return true => restart sproc */
}

void add_subscriber(bindtype env, struct evalstate *mapperstate,
		    oidtype new_socket) {
  int newsubstream = nil;
  int newnsub = mapperstate->n_sub + 1;

  a_print(mapperstate->sub_stream); fflush(stdout);
  a_setf(newsubstream, push_vectorfn(env, mapperstate->sub_stream, new_socket));
  a_setf(mapperstate->sub_stream, newsubstream);
  a_print(mapperstate->sub_stream); fflush(stdout);

  mapperstate->n_sub = newnsub;
}

void a_sproc(a_callcontext cxt, a_tuple tpl) {
  int r;
  oidtype lres = nil;
  int sticky = a_getintelem(tpl, 0, FALSE);
  a_setf(lres, call_lisp(mksymbol("STOP-PROFILE"), cxt->env, 0));
  a_setf(lres, call_lisp(mksymbol("START-PROFILE"), cxt->env, 0));
  r = sproc(cxt, TCPPROTOCOL);
  a_setf(lres, call_lisp(mksymbol("PROFILE"), cxt->env, 0));
  a_print(lres);
  a_free(lres);

  printf("sproc[%s]: returned %d\n", prstr, r);
  if (0 == sticky) {
    exit(0);
  }
	
  a_setobjectelem(tpl,0,mkinteger(r), FALSE);
  a_emit(cxt, tpl, FALSE);
}

void register_sproc(void) {
  a_extfunction("SPROC", a_sproc);
	illegal_subid = a_register_error("Illegal subscriber ID");
}


oidtype hashfn(bindtype env, oidtype key) {
  return mkinteger(compute_hash_key(key));
}

oidtype shiftfn(bindtype env, oidtype x) {
  return mkinteger(getinteger(x) >> 1);
}


/* All MPI related functions have empty definitions in this binary. */

void mpi_mergebbff(a_callcontext cxt, a_tuple params) {
}

void mpi_smergebf(a_callcontext cxt, a_tuple params) {
}

oidtype mpi_revalfn(bindtype env, oidtype form, oidtype nodenum) {
		oidtype rd = nil;
		return rd;
}

oidtype mpi_sendfn(bindtype env, oidtype form, oidtype nodenum) {
		oidtype rd = nil;
		return rd;
}

oidtype open_mpifn(bindtype env, oidtype peer, oidtype tag, oidtype bufsize) {
		oidtype rd = nil;
		return rd;
}

oidtype mpi_send_blockfn(bindtype env, oidtype form, oidtype peer,
			 oidtype tag) {
		oidtype rd = nil;
		return rd;
}

oidtype instrum_printfn(bindtype env, oidtype form, oidtype stream, 
			oidtype bgrecv) {
  struct socketcell *s;
  double tstart = run_time();
  int flushed_before = 0;

  if (a_datatype(stream) == sockettype) {
    s = dr(stream, socketcell);
    flushed_before = s->sentpackets;
  }

  if (nil == bgrecv) {
    printfn(env, form, stream);
  } else {
    lprintfn(env, form, stream);
  }

  if (a_datatype(stream) == sockettype) {
    s = dr(stream, socketcell);
    if (s->sentpackets != flushed_before) { // if flushed when printing form
      flushfn(env, stream); // keep form together by flushing again
      forced_flush++;
    }
    if (s->outpos > PACKET_SIZE - 200) {
      flushfn(env, stream);
      proactive_flush++;
    }
  }

  printtime += run_time() - tstart;
  printcalls++;
  return nil;
}

oidtype instr_commstatfn(bindtype env) {
	oidtype ret = nil;
	double proctime = getreal(proctimefn(env));
	ret = new_array(16, nil);
	a_seta(ret, 0, mkstring("proctime"));
	a_seta(ret, 1, mkreal(a_round(1000.0*proctime)/1000.0));
	a_seta(ret, 2, mkstring("printtime"));
	a_seta(ret, 3, mkreal(a_round(1000.0*printtime)/1000.0));
	a_seta(ret, 4, mkstring("readtime"));
	a_seta(ret, 5, mkreal(a_round(1000.0*readtime)/1000.0));
	a_seta(ret, 6, mkstring("printcalls"));
	a_seta(ret, 7, mkinteger(printcalls));
	a_seta(ret, 8, mkstring("proactive flush"));
	a_seta(ret, 9, mkinteger(proactive_flush));
	a_seta(ret, 10, mkstring("forced flush"));
	a_seta(ret, 11, mkinteger(forced_flush));
	a_seta(ret, 12, mkstring("readcalls"));
	a_seta(ret, 13, mkinteger(readcalls));
	a_seta(ret, 14, mkstring("interrupt-flush"));
	a_seta(ret, 15, globval(mksymbol("_flush-count_")));
	return make_recordfn(env, ret);
}

oidtype modrandbf(a_callcontext cxt) {
	oidtype max = a_arg(cxt, 1);
	a_bind(cxt, 2, mkinteger(rand()%getinteger(max)));
	a_result(cxt);
	return nil;
}


void register_scsq_functions(void) {
  NO_LIST_ARRAY = a_register_error("Not a list OR array");

  a_extimpl("modrandbf", modrandbf);
  a_extfunction("MERGEBBFF",mpi_mergebbff);
  a_extfunction("SMERGEBF",mpi_smergebf);
  extfunction2("mpi-reval", mpi_revalfn);
  extfunction2("mpi-send-form", mpi_sendfn);
  extfunction3("open-mpi", open_mpifn);
  extfunction3("mpi-send-block", mpi_send_blockfn);
  extfunction1("hash", hashfn);
  extfunction1("shift", shiftfn);
  extfunction3("instr-print", instrum_printfn);
  extfunction0("instr-commstat", instr_commstatfn);
  printtime = 0.0;
  readtime = 0.0;
  printcalls = 0;
  readcalls = 0;
  proactive_flush = 0;
  forced_flush = 0;
}
