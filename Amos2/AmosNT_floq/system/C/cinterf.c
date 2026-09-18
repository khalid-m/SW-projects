/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $RCSfile: cinterf.c,v $
 * $Revision: 1.82 $ $Date: 2014/01/12 20:32:24 $
 * $State: Exp $ $Locker:  $
 *
 * Description: C interface
 *
 * ===========================================================================
 * $Log: cinterf.c,v $
 * Revision 1.82  2014/01/12 20:32:24  torer
 * Missing {..}
 *
 * Revision 1.81  2014/01/12 16:28:23  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.80  2014/01/11 10:52:30  torer
 * More (but not all) MacProblems fixed
 *
 * Revision 1.79  2014/01/11 10:38:11  torer
 * More MacProblems fixed
 *
 * Revision 1.78  2014/01/05 12:57:23  torer
 * Client error check
 *
 * Revision 1.77  2013/12/02 13:42:32  larme597
 * Added simplified interface functions ending with "_basic".
 *
 * Revision 1.76  2013/11/15 13:33:51  torer
 * Thread safe a_stringify()
 *
 * Revision 1.75  2013/09/10 20:22:11  torer
 * Printing error message if system not initialized
 *
 * Revision 1.74  2013/09/04 08:05:59  larme597
 * Bugfix.
 *
 * Revision 1.73  2013/09/02 14:18:05  larme597
 * New multi scan interface functions.
 *
 * Revision 1.72  2013/08/12 10:28:52  larme597
 * New functions a_openstream and a_openstream_custom.
 *
 * Revision 1.71  2013/02/28 05:18:16  torer
 * removed trace
 *
 * Revision 1.70  2013/02/28 04:48:28  torer
 * Systematic locking
 *
 * Revision 1.69  2012/12/21 12:26:11  larme597
 * Bugfixes, a_nextrow_remote now saves all globals, not just reset pointer.
 *
 * Revision 1.68  2012/11/02 08:20:34  torer
 * The decision to materialize scan moved to server
 * to allow for pure Java client
 *
 * Revision 1.67  2012/11/02 07:12:53  torer
 * The dispatch between command and query in client again temporarily
 *
 * Revision 1.66  2012/11/01 20:38:07  torer
 * Desicion to execute command immediately moved to server
 * to allow for pure Java client
 *
 * Revision 1.65  2012/10/25 18:06:43  torer
 * New interface function
 * void a_freebytes(char *);
 * When deallocating bytes allocated by amos from C application
 *
 * Revision 1.64  2012/08/23 12:58:46  larme597
 * Separate connection not needed to kill remote scan.
 *
 * Revision 1.63  2012/08/21 15:31:20  larme597
 * Bugfix for check_init_hooks(). Storing correct resetlabelp value in
 * a_nextrow_remote(). New function a_killscan() for stopping remote scans.
 *
 * Revision 1.62  2012/07/27 05:44:27  torer
 * Changed special variable *suppress-error* into global variable _catch-errors_
 *
 * Revision 1.61  2012/07/27 05:24:06  torer
 * revert
 *
 * Revision 1.60  2012/07/27 05:14:15  torer
§ * Changed *catch-error* to _catch-error_
 *
 * Revision 1.59  2012/07/19 20:34:57  torer
 * amos now uses materialized_remote_scan = TRUE
 * scsq now uses materialized_remote_scan = FALSE.
 *
 * Revision 1.58  2012/06/28 19:57:51  torer
 * Possible race condition under Linux?
 *
 * Revision 1.57  2012/06/27 19:20:06  torer
 * options in custom C functions passed as property list to scan functions
 *
 * Revision 1.56  2012/06/26 08:31:20  larme597
 * UNIX fix.
 *
 * Revision 1.55  2012/06/26 07:26:09  torer
 * readOpt() introduced
 *
 * Revision 1.54  2012/06/26 06:54:05  torer
 * Introduced optional keyword :buffersize
 *
 * Revision 1.53  2012/06/22 13:51:37  torer
 * remote scans are now default in client-server interface
 *
 * Revision 1.52  2012/06/22 13:38:00  torer
 * Client server callin interface completely in terms of bare bone
 * socket client interface
 *
 * Revision 1.51  2012/06/20 11:49:18  larme597
 * a_nextrow & a_getrow sanity check on wrong variable. Fixed.
 *
 * Revision 1.50  2012/06/20 08:20:25  larme597
 * Bugfix in a_nextrow_remote.
 *
 * Revision 1.49  2012/06/19 16:16:55  larme597
 * a_execute_custom & a_callfunction_custom functions. New nextrow function
 * for non-materialized remote scans.
 *
 * Revision 1.48  2012/06/14 08:51:52  torer
 * Revert to old lock method
 *
 * Revision 1.42  2012/03/18 16:38:15  torer
 * Race condition in a_closescan when called from Java GBC
 *
 * Revision 1.41  2012/03/13 18:19:47  torer
 * Possibility to switch to coroutine based scans by setting
 *    materialized_scan=FALSE (does not work fully yet)
 *
 * Revision 1.39  2012/03/13 16:38:47  torer
 *
 * Revision 1.36  2011/04/28 20:12:15  torer
 * New function for simple execution of AmosQL commands from C
 *   int amosql(char *stmt, int catcherror)
 *
 * Revision 1.35  2011/04/18 18:29:52  torer
 * setElem on byte arrays
 *
 * Revision 1.34  2011/04/06 15:04:22  torer
 * type tag macro OIDTYPE changed to SURROGATETYPE to not confuse with C typedef 'oidtype'
 *
 * Revision 1.33  2010/12/26 09:41:32  torer
 * missing return
 *
 * Revision 1.31  2010/12/02 21:28:10  torer
 * New function a_gettypenamed
 *
 * Revision 1.30  2010/12/02 21:17:35  torer
 * New function a_getfunctionnamed(char *name, int catcherror)
 *
 * Revision 1.29  2010/09/11 03:07:43  torer
 * Byte buffer interface for JDBC strings
 *
 * Revision 1.28  2010/09/09 19:55:57  torer
 * a_addstringelem using nconcat2
 *
 * Revision 1.27  2010/09/09 14:29:59  torer
 * Added Tuple.addStringElem method in Java
 *
 * Revision 1.26  2010/06/08 18:39:11  torer
 * a_getdoubleelem coerces integers to reals
 *
 * Revision 1.25  2009/07/31 16:18:15  larme597
 * Removing coroutines again.
 *
 * Revision 1.24  2009/07/30 10:16:27  larme597
 * Adding coroutines.
 *
 * Revision 1.23  2009/01/02 08:35:09  torer
 * Error trapping bugs
 *
 * Revision 1.22  2009/01/01 22:50:49  torer
 * Empty row access trapped
 *
 * Revision 1.21  2009/01/01 20:11:36  torer
 * Clearing error message before calling operation
 *
 * Revision 1.20  2008/12/30 16:52:23  torer
 * Concurrency bug
 *
 * Revision 1.19  2008/12/14 16:34:54  torer
 * Added global variable a_callback_connection
 * to be used when calling back to system from inside foreign function
 *
 * Revision 1.18  2008/05/19 16:37:35  torer
 * Concurrency bug
 *
 * Revision 1.17  2007/04/09 13:24:55  torer
 * Removed unnecessary EXPORT declaration
 *
 * Revision 1.16  2007/02/23 22:01:43  torer
 * Making init file for PHP optional
 * Allowing function names as strings in PHP
 *
 * Revision 1.15  2007/02/21 15:53:49  torer
 * Bug in PHP interface
 *
 ****************************************************************************/

#include "amos.h"
#include "binary.h"
#include "scan.h"
#include "scan_remote.h"
#include "coroutine.h"
#include <string.h>
#include <ctype.h>

extern void check_init_hooks(void);

EXPORT int materialized_scan = TRUE; /* Scans represented as lists if TRUE */
EXPORT int materialized_remote_scan = TRUE;

EXTERN oidtype _function_, _type_, call_function;
int connection_not_initialized, connection_nolocal, empty_scan, 
  illegal_rowpos,  scan_not_initialized, tuple_not_initialized, 
  blob_not_initialized,  arg_not_blob, blob_too_small, arg_not_seq, 
  no_function_named, no_type_named, connection_already_opened, 
  connection_closed,  amos_not_initialized, illegal_object, 
  cannot_use_materialized_scan, can_only_use_remote_scan;

EXPORT a_connection a_callback_connection;

extern oidtype exportto, xoidno; /* from oid.c */
extern int amos_initialized; /* from top.c */
oidtype open_query_scan, amos_execute, execute_remote_statement, socket_call;
oidtype scan_fillbuffer_remote_request, scan_remote_poll_socket,
  scan_fillbuffer_remote_result;
oidtype setfunction_dynamic, remfunction_dynamic, _suppress_error_;
int trace_interface=FALSE;
extern oidtype _histflg_;

void check_amos_initialized(void)
{
  if(!amos_initialized)
    {
      fprintf(stderr, "System not initialized. Abending...\n");
      exit(1);
    }
}

#define kwote(x) kwotefn(varstack, x)

#define check_initconnection(c)if(c==NULL || c->hasbeeninitialized!=CONNECTED)\
 a_error(connection_not_initialized,nil,FALSE)

#define check_initscan(c)if(c==NULL || c->hasbeeninitialized!=INITSCAN) \
a_error(scan_not_initialized,nil,FALSE)
#define check_inittuple(c)if(c==NULL || c->hasbeeninitialized!=INITTUPLE) \
a_error(tuple_not_initialized,nil,FALSE)

#define check_initblob(c)if(c==NULL || c->hasbeeninitialized!=INITBLOB) \
a_error(blob_not_initialized,nil,FALSE)

#define setup_error_trap setup_error_trap0(TRUE)

#define setup_error_trap0(lock)check_amos_initialized();				  \
     if(lock)a_lock();{volatile oidtype olds=nil; unwind_protect_begin;\
     a_errorflag = FALSE; a_errno=0; a_free(a_errform);	  \
     if(catcherror) { olds = globval(_suppress_error_); \
                     globval(_suppress_error_) = t; }\
     

#define check_error_occurred check_error_occurred0(TRUE)

#define check_error_occurred0(unlock)					\
     unwind_protect_catch;						\
     if(catcherror) {throw_label = global_reset;			\
       globval(_suppress_error_) = olds; } if(unlock)a_unlock();        \
     if(unwind_reset && catcherror) return (a_errorflag = TRUE);	\
     unwind_protect_end;}

int ci_excl=FALSE;
#define BE(x) (ci_excl?printf("Cinterface-thread not exclusive at %d: %d\n",x,ci_excl):(ci_excl=x))
#define EE(x) (ci_excl?(ci_excl=FALSE):printf("Other Cinterface-thread running when leaving %d\n",x))

#define PRINT(x) //printf("--- id: %d %s\n", GetCurrentThreadId(), x); fflush(stdout)

EXPORT a_connection a_init_connection(void)
{
  a_connection c = (a_connection)mymalloc(sizeof(*c));

  PRINT("a_init_connection");
  c->hasbeeninitialized=CONNECTED;
  c->result = nil;
  c->name = "";
  c->primscan = NULL;
  c->status = FALSE;
  return c;
}

EXPORT a_scan a_init_scan(void)
{
  a_scan s = (a_scan)mymalloc(sizeof(*s));
  PRINT("a_init_scan");
  s->here = nil;
  s->row = nil;
  s->hasbeeninitialized = INITSCAN;
  s->stopafter=-1; /* Stop function call when no more tuples in result */
  s->status=0;
  /* printf("New scan %d\n",(int)s);*/
  return s;
}

EXPORT a_tuple a_init_tuple(void)
{
  a_tuple tp = (a_tuple)mymalloc(sizeof(*tp));
  PRINT("a_init_tuple");
  tp->tpl = nil;
  tp->hasbeeninitialized = INITTUPLE;
  /* printf("New tuple %d\n",(int)t); */
  return tp;
}

EXPORT void a_freebytes(char *p)
{
  free(p);
}

EXPORT int a_newtuple(a_tuple tp, int size, int catcherror)
{
  PRINT("a_newtuple");
  check_inittuple(tp);
  setup_error_trap;
  a_setf(tp->tpl,new_array(size,nil));
  check_error_occurred;
  return (a_errorflag=FALSE);
}

EXPORT void free_tuple(a_tuple tp)
{
  PRINT("free_tuple");
  /* printf("Free tuple %d\n",(int)tp); */
  free_oid(tp->tpl);
  free(tp);
}

void a_reset_catch(oidtype olds)
{
  PRINT("a_reset_catch");
  throw_label = global_reset;
  globval(_suppress_error_) = olds;
}

EXPORT int a_connect(a_connection c, char *amosname, int catcherror)
{
  oidtype port;
  static int flag = 1;

  PRINT("a_connect");
  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: Connecting ", stdoutstream);
      a_puts(amosname, stdoutstream);
      a_terpri(stdoutstream);
    }
  if (c->status)
    {
      return a_error(connection_already_opened, nil, catcherror);
    }
  c->name = mystrdup(amosname);
  c->servid = nil;
  c->port = nil;
  setup_error_trap;
  if (flag)
    {
      flag = 0;
      check_init_hooks();
    }
  if (strlen(amosname) != 0) /* Connect to remote Amos server */
    {
      oidtype sid;
      sid = mksymbol(amosname);
      port = call_lisp(mksymbol("open-socket-to"), varstack, 1, sid);
      a_setf(c->port, port);
      a_setf(c->servid, sid);
    }
  else if(a_clientflg)
    return a_error(connection_nolocal, mkstring(""), catcherror);
  c->status = TRUE;
  check_error_occurred;
  PRINT("a_connect end");
  if (trace_interface) a_message("<-CCall: OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_connectto(a_connection c,char *amosname,char *host,int catcherror)
{
  if(trace_interface)
    {
      a_puts("->CCall: Connecting through remote nameserver",stdoutstream);
      a_puts(amosname,stdoutstream);
      a_puts(" ",stdoutstream);
      a_puts(host,stdoutstream);
      a_terpri(stdoutstream);
    }
  setup_error_trap;
  call_lisp(mksymbol("set-nameserverhost"),topframe(), 1, mkstring(host));
  check_error_occurred;
  return  a_connect(c, amosname, catcherror);
}

EXPORT int a_disconnect(a_connection c,int catcherror)
{
  PRINT("a_disconnect");
  if (c == a_callback_connection)
    return FALSE;
  setup_error_trap;
  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: Disconnecting ",stdoutstream);
      a_puts(c->name,stdoutstream);
      a_terpri(stdoutstream);
      // if(strcmp(c->name,"")) eval_forms(varstack,"(traceall t)");
    }
  if (!c->status) 
    {
      a_unlock(); 
      a_message("<-CCall: Already disconnected\n");
      return (a_errorflag = FALSE);
    }
  free_oid(c->result);
  if (c->port != nil)
    {
      release(call_lisp(mksymbol("close-socket"), topframe(), 1,
			c->port));
    }
  else
    release(commitfn(topframe())); /* Local disconnect => commit */
  a_free(c->port);
  a_free(c->servid);
  if (strcmp(c->name, ""))
    free(c->name);
  c->name = "";
  c->primscan = NULL;
  check_error_occurred;
  c->status = FALSE;
  if (trace_interface)
    a_message("<-Ccall: OK\n");
  return (a_errorflag = FALSE);
}

EXPORT void free_connection(a_connection c)
{
  PRINT("free_connection");
  if(c->status) a_disconnect(c,TRUE); a_errorflag=FALSE;
  free(c);
}

EXPORT int a_commit(a_connection c,int catcherror)
{
  PRINT("a_commit");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  setup_error_trap;
  if(c->port == nil) release(commitfn(topframe()));
  else { a_unlock(); return FALSE; /* Remote commit is dummy */}
  check_error_occurred;
  return (a_errorflag=FALSE);
}

EXPORT int a_rollback(a_connection c,int catcherror)
{
  PRINT("a_rollback");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  setup_error_trap;
  if(c->port == nil) release(rollbackfn(topframe(),nil));
  else {a_unlock(); return FALSE; /* Remote rollback is dummy */}
  check_error_occurred;
  return (a_errorflag=FALSE);
}

#ifdef UNIX
#include <unistd.h>
#endif

oidtype a_nextrow_remote(bindtype env, oidtype scan)
{
  oidtype poll;
  struct globals g;
  //jmp_buf *resetlabelp_local;

  a_let(poll, call_lisp(scan_fillbuffer_remote_request, env, 1, scan));
  if (poll != nil)
    {
      while (1)
	{
	  a_setf(poll, call_lisp(scan_remote_poll_socket, env, 1, scan));
	  if (poll == nil)
	    {
	      SaveGlobals(&g);
	      //resetlabelp_local = resetlabelp;
	      a_unlock();
#ifdef UNIX
	      usleep(5000);
#else
	      Sleep(5);
#endif
	      a_lock();
	      RestoreGlobals(&g);
	      //resetlabelp = resetlabelp_local;
	    }
	  else
	    break;
	}
      release(call_lisp(scan_fillbuffer_remote_result, env, 1, scan));
      a_free(poll);
    }
  return stream_next_remotefn(env, scan);
}

int openscan(a_connection c, a_scan s, int catcherror)
{
  PRINT("openscan");
  check_initscan(s);
  check_initconnection(c);
  if (!c->status)
    return a_error(connection_closed, nil, catcherror);
  c->primscan = s;
  if (trace_interface)
    {
      a_puts("[SCAN\n", stdoutstream);
      a_print(c->result);
      a_message("]\n");
    }
  //BE(20);
  PRINT("openscan mid");

  a_setf(s->here, c->result); 
  if (a_datatype(c->result) == scanremotetype)
    { 
      PRINT("openscan scanremotetype");
      a_setf(s->row, a_nextrow_remote(varstack, s->here));
    }
  else if (a_datatype(c->result) == scantype)
    {
      PRINT("openscan scantype");
      a_setf(s->row, stream_nextfn(varstack, s->here)); 
      //if(s->row==nil) a_free(s->here);
    }
  else if (listp(c->result))
    {
      PRINT("openscan list");
      a_setf(s->row, fhd(c->result));
    }
  else /* Atomic results specially treated as a single row */
    {
      PRINT("openscan atomic");
      a_setf(s->row, c->result);
    }

  //EE(20);
  s->stopafter = -1; /* Clear STOPAFTER counter for next call */
  return (a_errorflag = FALSE);
}

EXPORT int a_nextrow(a_scan s, int catcherror)
{
  check_initscan(s);
  if (s->row == nil)
    return a_error(empty_scan, nil, catcherror);

  setup_error_trap;
  //BE(30);
  PRINT("a_nextrow");

  if (a_datatype(s->here) == scanremotetype)
    {
      PRINT("a_nextrow scanremotetype");
      a_setf(s->row, a_nextrow_remote(varstack, s->here));
    }
  else if (a_datatype(s->here) == scantype)
    {
      PRINT("a_nextrow scantype");
      a_setf(s->row, stream_nextfn(varstack, s->here));
      //if(s->row==nil) a_free(s->here);
    }
  else if (listp(s->here))
    {
      PRINT("a_nextrow listp");
      a_setf(s->here, ftl(s->here));
      a_setf(s->row, fhd(s->here));
    }
  else /* Atomic result => no next tuple */
    {
      PRINT("a_nextrow atomic");
      a_setf(s->here, nil);
      a_setf(s->row, nil);
    }

  PRINT("a_nextrow end");
  //EE(30);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT int a_nextrow_basic(a_scan scan, a_tuple tpl, int catcherror)
{
  setup_error_trap;
  a_setf(tpl->tpl, a_nextrow_remote(varstack, scan->here));
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT int a_eos_basic(a_scan scan, int *eos, int catcherror)
{
  setup_error_trap;
  *eos = stream_eos_remotefn(varstack, scan->here);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT int a_getarity(a_tuple tp, int catcherror)
{
  PRINT("a_getarity");
  check_inittuple(tp);
  a_errorflag = FALSE;
  if (arrayp(tp->tpl)) return a_arraysize(tp->tpl);
  if (!listp(tp->tpl)) return 1; /* Atomic result */
  return a_length(tp->tpl);
}

EXPORT int a_getrow(a_scan s, a_tuple tp, int catcherror)
{
  PRINT("a_getrow");
  check_initscan(s);
  check_inittuple(tp);

  if (s->row == nil)
    return a_error(empty_scan, nil, catcherror);
  if (listp(s->here))
    a_assign(tp->tpl, fhd(s->here));
  else
    a_assign(tp->tpl, s->row);

  PRINT("a_getrow end");
  return (a_errorflag = FALSE);
}

EXPORT oidtype a_getelem(a_tuple tp, int pos, int catcherror)
{
  PRINT("a_getelem");
  check_inittuple(tp);
  return a_getelem_basic(tp->tpl, pos, catcherror);
}

EXPORT oidtype a_getelem_basic(oidtype oid, int pos, int catcherror)
{
  a_errorflag = FALSE;
  if (arrayp(oid))
    {
      if (pos < 0 || pos >= a_arraysize(oid))
	{
          a_error(illegal_rowpos, mkinteger(pos), catcherror);
          return nil;
	}
      return a_elt(oid, pos);
    }

  if (!listp(oid)) /* Atomic result => only pos 0 valid */
    {
      if (pos == 0) return oid;
      a_error(illegal_rowpos, mkinteger(pos), catcherror);
      return nil;
    }
  if (pos < 0 || pos >= a_length(oid))
    {
      a_error(illegal_rowpos, mkinteger(pos), catcherror);
      return nil;
    }
  return a_nth(oid, pos);
}

EXPORT int a_getelemsize(a_tuple tp, int pos, int catcherror)
{
  oidtype e;

  PRINT("a_getelemsize");
  a_errorflag = FALSE;
  e = a_getelem(tp,pos,catcherror);
  if(a_errorflag) return a_errorflag;
  switch(a_datatype(e))
    {
    case ARRAYTYPE:
      return a_arraysize(e);
    case STRINGTYPE:
      return stringlen(e);
    case BINARYTYPE:
      return binary_size(dr(e,binarycell));
    case INTEGERTYPE:
    case REALTYPE:
    case SURROGATETYPE:
      return 1;
    default:
      a_error(illegal_object,e,catcherror);
      return 0;
    }
}
EXPORT oidtype a_getobjectno(a_connection c, int n, int catcherror)
{
  oidtype res;
  PRINT("a_getobjectno");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  {setup_error_trap;
  if(c->port==nil) res = getobjectnumbered(n);
  else res = call_lisp(socket_call,topframe(),3,
		       c->port,mksymbol("getobjectnumbered"),mkinteger(n));
  unwind_protect_catch;
  if(catcherror) a_reset_catch(olds); a_unlock();
  if(unwind_reset && catcherror)
    {
      a_errorflag = TRUE;
      return nil;
    }
  unwind_protect_end;}}
return res;
}

EXPORT oidtype a_mksymbol(char *pname, int catcherror)
{
  oidtype res=nil;
  PRINT("a_mksymbol");
  setup_error_trap;
  res = mksymbol(pname);
  check_error_occurred;
  return res;
}

EXPORT oidtype a_typeof(oidtype o, int catcherror)
{
  oidtype res, tmp;

  PRINT("a_typeof");
  {setup_error_trap;
  tmp = getobjectfn(topframe(),o,xoidno);
  if(tmp==nil) res = arg_typefn(topframe(), o);
  else
    {
      oidtype db, port;

      db = getobjectfn(topframe(),o,exportto);
      port = call_lisp(mksymbol("open-socket-to"), topframe(), 1, db);
      res = call_lisp(socket_call,topframe(),3,port,mksymbol("arg-type"),o);
    }
  unwind_protect_catch;
  if(catcherror) a_reset_catch(olds);
  a_unlock();
  if(unwind_reset && catcherror)
    {
      a_errorflag = TRUE;
      return nil;
    }
  unwind_protect_end;}}
return res;
}

EXPORT int a_getid(oidtype o, int catcherror)
{
  oidtype tmp;

  PRINT("a_getid");
  if(a_datatype(o) != SURROGATETYPE)
    {
      a_errorflag = TRUE;
      return -1;
    }
  setup_error_trap;
  tmp = getobjectfn(topframe(),o,xoidno);
  check_error_occurred;
  if(tmp==nil) return dr(o,oidcell)->idno;
  else return getinteger(tmp);
}

EXPORT int a_getstringelem(a_tuple tp, int pos, char *str, int maxlen,
  int catcherror)
{
  return a_getstringelem_basic(tp->tpl, pos, str, maxlen, catcherror);
}

EXPORT int a_getstringelem_basic(oidtype oid, int pos, char *str, int maxlen,
				 int catcherror)
{
  oidtype val;
  char *tmp;
  int len;

  PRINT("a_getstringelem");
  a_lock();
  val = a_getelem_basic(oid, pos, catcherror);
  if (a_errorflag) return a_errorflag;
  if (a_datatype(val) != STRINGTYPE)
    {
      a_error(ARG_NOT_STRING, val, catcherror);
      return TRUE;
    }
  tmp = getstring(val);
  len = strlen(tmp) + 1;
  if (len > maxlen)
    {
      memcpy(str, tmp, maxlen - 1);
      str[maxlen - 1] = '\0';
    }
  else
    memcpy(str, tmp, len);
  a_unlock();

  return (a_errorflag = FALSE);
}

// Doesn't use lock
int a_setelem_internal(a_tuple tp, int pos, oidtype v)
{
  PRINT("a_setelem_internal");
  check_inittuple(tp);
  a_seta(tp->tpl, pos, v);
  return FALSE;
}

EXPORT int a_setstringelem(a_tuple tp, int pos, char *str, int catcherror)
{
  PRINT("a_setstringelem");
  check_inittuple(tp);
  a_lock();
  a_setelem_internal(tp, pos, mkstring(str));
  a_unlock();
  return FALSE;
}

EXPORT int a_setbyteselem(a_tuple tp, int pos, int len, char *str, 
                          int catcherror)
{
  oidtype nstr;
  char *s;

  PRINT("a_setbyteselem");
  a_lock();
  nstr = new_string(len + 1, "");
  s = getstring(nstr);
  memcpy(s, str, len);
  s[len] = '\0';
  a_setelem_internal(tp, pos, nstr);
  a_unlock();
  return FALSE;
}

extern oidtype nconcat2(bindtype, oidtype, int, char*);

EXPORT int a_addbyteselem(a_tuple tp, int pos, int len, char *str, 
                          int catcherror)
{
  oidtype e;

  PRINT("a_addbyteselem");
  check_inittuple(tp);
  a_lock();
  e = a_getelem(tp, pos, catcherror);
  if (a_datatype(e) != STRINGTYPE)
    {
      oidtype nstr = new_string(len + 1, "");
      char *s = getstring(nstr);

      memcpy(s, str, len);
      s[len] = '\0';
      a_setelem_internal(tp, pos, nstr);
    }
  else
    a_setelem_internal(tp, pos, nconcat2(varstack, e, len, str));
  a_unlock();
  return FALSE;
}

EXPORT int a_addstringelem(a_tuple tp, int pos, char *str, int catcherror)
{
  oidtype e;

  PRINT("a_addstringelem");
  check_inittuple(tp);
  a_lock();
  e = a_getelem(tp, pos, catcherror);
  if (a_datatype(e) != STRINGTYPE)
    a_setelem_internal(tp, pos, mkstring(str));
  else
    a_setelem_internal(tp, pos, nconcat2(varstack, e, strlen(str), str));
  a_unlock();
  return FALSE;
}

EXPORT int a_getintelem(a_tuple tp, int pos, int catcherror)
{
  oidtype o;

  PRINT("a_getintelem");
  a_errorflag = FALSE;
  o = a_getelem(tp, pos, catcherror);
  if (a_errorflag) return 0;
  if (a_datatype(o) != INTEGERTYPE)
    {
      a_error(ARG_NOT_INTEGER, o, catcherror);
      return 0;
    }
  return getinteger(o);
}

EXPORT int a_setintelem(a_tuple tp, int pos, int v, int catcherror)
{
  PRINT("a_setintelem");
  check_inittuple(tp);
  a_lock();
  a_setelem_internal(tp, pos, mkinteger(v));
  a_unlock();
  return FALSE;
}

EXPORT double a_getdoubleelem(a_tuple tp, int pos, int catcherror)
{
  PRINT("a_getdoubleelem");
  a_errorflag = FALSE;
  return a_getdoubleelem_basic(tp->tpl, pos, catcherror);
}

EXPORT double a_getdoubleelem_basic(oidtype oid, int pos, int catcherror)
{
  oidtype val;

  val = a_getelem_basic(oid, pos, catcherror);
  if (a_errorflag) return 0.0;
  if (a_datatype(val) == INTEGERTYPE) return getinteger(val);
  if (a_datatype(val) != REALTYPE)
    {
      a_error(ARG_NOT_REAL, val, catcherror);
      return 0.0;
    }
  return getreal(val);
}

EXPORT int a_setdoubleelem(a_tuple tp, int pos, double v, int catcherror)
{
  PRINT("a_setdoubleelem");
  check_inittuple(tp);
  a_lock();
  a_setelem_internal(tp, pos, mkreal(v));
  a_unlock();
  return FALSE;
}

EXPORT int a_getseqelem(a_tuple tp, int pos, a_tuple seq, int catcherror)
{
  oidtype o;

  PRINT("a_getseqelem");
  a_errorflag = FALSE;
  o = a_getelem(tp, pos, catcherror);
  check_inittuple(seq);
  if (a_errorflag) return a_errorflag;
  if (a_datatype(o) != ARRAYTYPE)
    {
      a_error(arg_not_seq, o, catcherror);
      return a_errorflag;
    }
  a_assign(seq->tpl, o);
  return (a_errorflag = FALSE);
}

EXPORT int a_setseqelem(a_tuple tp, int pos, a_tuple seq, int catcherror)
{
  PRINT("a_setseqelem");
  check_inittuple(tp);
  check_inittuple(seq);
  a_lock();
  a_setelem_internal(tp, pos, copy_arrayfn(topframe(), seq->tpl));
  a_unlock();
  return FALSE;
}

EXPORT int a_setelem(a_tuple tp, int pos, oidtype v)
{
  PRINT("a_setelem");
  check_inittuple(tp);
  a_lock(); a_seta(tp->tpl, pos, v); a_unlock();
  return FALSE;
}

/******************************* BLOBs ***************************************/

EXPORT a_blob a_initBLOB(void)
{
  a_blob b = (a_blob)mymalloc(sizeof(*b));
  PRINT("a_initBLOB");
  b->BLOB = nil;
  b->hasbeeninitialized = INITBLOB;
  return b;
}

EXPORT int a_newBLOB(a_blob b, int size, int catcherror)
{
  PRINT("a_newBLOB");
  check_initblob(b);
  setup_error_trap;
  a_assign(b->BLOB,new_binary(size,0));
  check_error_occurred;
  return (a_errorflag=FALSE);
}

EXPORT int a_freeBLOB(a_blob b, int catcherror)
{
  PRINT("a_freeBLOB");
  /* printf("Free blob %d\n",(int)b); */
  check_initblob(b);
  free_oid(b->BLOB);
  free(b);
  return FALSE;
}


EXPORT int a_getBLOBelem(a_tuple tp, int pos, a_blob b, int catcherror)
{
  oidtype o;

  PRINT("a_getBLOBelem");
  a_errorflag = FALSE;
  o = a_getelem(tp, pos, catcherror);
  check_initblob(b);
  if (a_errorflag) return a_errorflag;
  if (a_datatype(o) != BINARYTYPE)
    {
      a_error(arg_not_blob, o, catcherror);
      return a_errorflag;
    }
  a_assign(b->BLOB, o);
  return FALSE;
}

EXPORT int a_putBLOBelem(a_tuple tp, int pos, a_blob b, int catcherror)
{
  PRINT("a_putBLOBelem");
  check_inittuple(tp);
  check_initblob(b);
  a_lock(); a_setelem_internal(tp, pos, b->BLOB); a_unlock();
  return FALSE;
}

EXPORT int a_getBLOBarea(a_blob b, int pos, int len, char **area,
			 int catcherror)
{
  struct binarycell *blob;

  PRINT("a_getBLOBarea");
  check_initblob(b);
  if(a_datatype(b->BLOB)!=BINARYTYPE)
    {
      a_error(arg_not_blob,b->BLOB,catcherror);
      return TRUE;
    }
  blob =  dr(b->BLOB,binarycell);
  if(binary_size(blob) < (unsigned int)(pos + len))
    {
      a_error(blob_too_small,b->BLOB,catcherror);
    }
  *area = (char *)blob->cont + pos;
  return FALSE;
}

EXPORT int a_getBLOBsize(a_blob b, int *size, int catcherror)
{
  PRINT("a_getBLOBsize");
  check_initblob(b);
  *size = binary_size(dr(b->BLOB,binarycell));
  return FALSE;
}

EXPORT int a_getBLOBbytes(a_blob b, int pos, int len, char *buffer,
			  int catcherror)
{
  char *area;

  PRINT("a_getBLOBbytes");
  if(a_getBLOBarea(b, pos, len, &area, catcherror)) return TRUE;
  memcpy(buffer,area,len);
  return FALSE;
}

EXPORT int a_putBLOBbytes(a_blob b, int pos, int len, char *buffer,
			  int catcherror)
{
  char *area;

  PRINT("a_putBLOBbytes");
  if(a_getBLOBarea(b, pos, len, &area, catcherror)) return TRUE;
  memcpy(area,buffer,len);
  return FALSE;
}

EXPORT int a_closescan(a_scan s, int catcherror)
{
  check_initscan(s);

  PRINT("a_closescan");
  setup_error_trap;

  // Calling close_stream_remotefn for scanremotetype no longer needed

  free_oid(s->here);
  free_oid(s->row);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT void free_scan(a_scan s)
{
  PRINT("free_scan");
  /* printf("Close scan %d\n",(int)s); */
  a_closescan(s, TRUE);
  free(s);
  return;
}

EXPORT int a_killscan(a_scan s, int catcherror)
{
  PRINT("a_killscan");
  check_initscan(s);
  if (a_datatype(s->here) != scanremotetype)
    {
      // a_killscan only supported for remote scans
      return a_error(illegal_object, s->here, catcherror);
    }
  setup_error_trap;
  release(call_lisp(mksymbol("scan-kill-remote"), varstack, 1, s->here));
  check_error_occurred;

  return (a_errorflag = FALSE);
}

EXPORT int a_is_query(char *query)
{
  return call_lisp(mksymbol("is-query"), varstack, 1, mkstring(query)) != nil;
}

EXPORT int a_execute(a_connection c, a_scan s, char *query, int catcherror)
{
  return a_execute_custom(c, s, query, "", catcherror);
}

oidtype readOpt(char *string)
{
  oidtype res;

  if(strcmp(string,"")==0) return nil;
  res = a_read_from_string(string);
  if(symbolp(res)) return nil; /* E.g. *EOF* */
  return res;
}

EXPORT int a_execute_custom(a_connection c, a_scan s, char *query, 
			    char *options, int catcherror)
{
  oidtype opt;

  PRINT("a_execute_custom");

  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: execute_custom", stdoutstream);
      a_puts(query, stdoutstream);
      a_puts(options, stdoutstream);
      a_terpri(stdoutstream);
    }
  if (!c->status) return a_error(connection_closed, nil, catcherror);
  //setup_error_trap0(c != a_callback_connection);
  setup_error_trap;
  //BE(45);
  a_let(opt,readOpt(options)); /* Make opt property list */
  if (c->port == nil)
    {
      if (materialized_scan)
	{
	  PRINT("materialized local scan");
	  a_setf(c->result, call_lisp(amos_execute, varstack, 2,
				      mkstring(query),
                                      mkinteger(s->stopafter)));
	}
      else if (!a_is_query(query))
	{
	  PRINT("local non-query");
	  a_setf(c->result, call_lisp(amos_execute, varstack, 1, 
				      mkstring(query)));
	}
      else
	{
	  PRINT("local continuous scan");
	  a_setf(c->result,
		 open_query_streamfn(varstack, mkstring(query), kwote(opt)));
	}
    }
  else
    {
      if (materialized_remote_scan)
	{
	  PRINT("materialized remote scan");
	  a_setf(c->result, call_lisp(execute_remote_statement, varstack, 3,
				      mkstring(query), c->port,
				      mkinteger(s->stopafter)));
	}
      else
	{
	  PRINT("remote continuous scan");
	  a_setf(c->result,
		 open_query_stream_remotefn(varstack, mkstring(query),
					    c->port, kwote(opt)));
	}
    }
  openscan(c, s, FALSE);
  a_free(opt);
  //check_error_occurred0(c != a_callback_connection);
  //EE(45);
  check_error_occurred;
  if (trace_interface) a_message("<-CCall: Execute OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_execute_basic(char *amosname, a_scan scan, char *query, 
			   char *options, int catcherror)
{
  oidtype port, opt;

  setup_error_trap;
  a_let(port, call_lisp(mksymbol("open-socket-to"), varstack, 1, mksymbol(amosname)));
  a_let(opt, readOpt(options));
  a_setf(scan->here,
	 open_query_stream_remotefn(varstack, mkstring(query), port, kwote(opt)));
  release(call_lisp(mksymbol("close-socket"), varstack, 1, port));
  a_free(opt);
  a_free(port);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT int a_execute_update(char *amosname, char *query, int catcherror)
{
  oidtype port;

  setup_error_trap;
  a_let(port, call_lisp(mksymbol("open-socket-to"), varstack, 1, mksymbol(amosname)));
  release(call_lisp(execute_remote_statement, varstack, 2, mkstring(query), port));
  release(call_lisp(mksymbol("close-socket"), varstack, 1, port));
  a_free(port);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT int a_openstream(a_connection c, a_scan s, oidtype stream, int catcherror)
{
  return a_openstream_custom(c, s, stream, "", catcherror);
}

EXPORT int a_openstream_custom(a_connection c, a_scan s, oidtype stream, 
			       char *options, int catcherror)
{
  oidtype opt;

  PRINT("a_openstream_custom");

  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: openstream_custom", stdoutstream);
      a_print(stream);
      a_puts(options, stdoutstream);
      a_terpri(stdoutstream);
    }
  if (!c->status) return a_error(connection_closed, nil, catcherror);
  //setup_error_trap0(c != a_callback_connection);
  setup_error_trap;
  //BE(45);
  a_let(opt,readOpt(options)); /* Make opt property list */
  if (c->port == nil)
    {
      if (materialized_scan)
	{
	  // Cannot use materialized scan?
	  return a_error(cannot_use_materialized_scan, nil, catcherror);
	}
      else
	{
	  PRINT("local stream scan");
	  a_setf(c->result,
		 open_bag_streamfn(varstack, stream, kwote(opt)));
	}
    }
  else
    {
      if (materialized_remote_scan)
	{
	  // Cannot use materialized scan?
	  return a_error(cannot_use_materialized_scan, nil, catcherror);
	}
      else
	{
	  PRINT("remote stream scan");
	  a_setf(c->result,
		 open_bag_stream_remotefn(varstack, stream,
					  c->port, kwote(opt)));
	}
    }
  openscan(c, s, FALSE);
  a_free(opt);
  //check_error_occurred0(c != a_callback_connection);
  //EE(45);
  check_error_occurred;
  if (trace_interface) a_message("<-CCall: stream scan OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_openmultiscan(a_connection c, a_scan s, char *query, int catcherror)
{
  return a_openmultiscan_custom(c, s, query, "", catcherror);
}

EXPORT int a_openmultiscan_custom(a_connection c, a_scan s, char *query, 
				  char *options, int catcherror)
{
  oidtype opt;

  PRINT("a_openmultiscan_custom");

  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: openmultiscan_custom", stdoutstream);
      printf("%s\n", query);
      a_puts(options, stdoutstream);
      a_terpri(stdoutstream);
    }
  if (!c->status) return a_error(connection_closed, nil, catcherror);
  //setup_error_trap0(c != a_callback_connection);
  setup_error_trap;
  //BE(45);
  a_let(opt,readOpt(options)); /* Make opt property list */
  if (c->port == nil)
    {
      return a_error(can_only_use_remote_scan, nil, catcherror);
    }
  else
    {
      if (materialized_remote_scan)
	{
	  // Cannot use materialized scan?
	  return a_error(cannot_use_materialized_scan, nil, catcherror);
	}
      else
	{
	  PRINT("remote multiscan");
	  a_setf(c->result,
		 call_lisp(mksymbol("open-multi-scan-remote"), varstack,
			   3, mkstring(query), c->port, kwote(opt)));
	}
    }
  openscan(c, s, FALSE);
  a_free(opt);
  //check_error_occurred0(c != a_callback_connection);
  //EE(45);
  check_error_occurred;
  if (trace_interface) a_message("<-CCall: multiscan OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_init_singlescan(a_scan s, oidtype o, int catcherror)
{
  PRINT("singlescan");
  check_initscan(s);

  setup_error_trap;
  a_setf(s->here, o);

  if (a_datatype(s->here) == scanremotetype)
    { 
      PRINT("singlescan scanremotetype");
      a_setf(s->row, a_nextrow_remote(varstack, s->here));
    }
  else // No other allowed type
    {
      return a_error(can_only_use_remote_scan, nil, catcherror);
    }
  check_error_occurred;

  return (a_errorflag = FALSE);
}

EXPORT int amosql(char *stmt, int catcherror)
{
  PRINT("amosql");
  //setup_error_trap0(FALSE);
  setup_error_trap;
  release(call_lisp(amos_execute, topframe(), 1, stringbuffer(stmt)));
  //check_error_occurred0(FALSE);
  check_error_occurred;
  return (a_errorflag = FALSE);
}

EXPORT oidtype a_getfunctionnamed(char *name, int catcherror)
{
  oidtype fno;

  PRINT("a_getfunctionnamed");
  setup_error_trap;
  fno = getobjectnamedfn(topframe(), mksymbol(name),globval(_function_),
                          (catcherror?t:nil));
  check_error_occurred;
  return fno;
}

EXPORT oidtype a_getfunction(a_connection c, char *name, int catcherror)
{
  oidtype res = nil, fnsymb;

  PRINT("a_getfunction");
  check_initconnection(c);
  if (!c->status)
    {
      a_error(connection_closed, nil, catcherror);
      return nil;
    }
  a_errorflag = FALSE;
  setup_error_trap;
  fnsymb = mksymbol(name);
  if (c->port == nil)
    res = a_getfunctionnamed(name, catcherror);
  else
    {
      res = call_lisp(socket_call, varstack, 5,
		      c->port, mksymbol("getobjectnamed"), fnsymb,
		      globval(_function_),
		      t);
    }
  check_error_occurred;
  if (res == nil)
    {
      a_error(no_function_named, fnsymb, catcherror);
      return nil;
    }
  return res;
}

EXPORT oidtype a_gettypenamed(char *name, int catcherror)
{
  oidtype tpo;
  PRINT("a_gettypenamed");
  setup_error_trap;
  tpo = getobjectnamedfn(topframe(), mksymbol(name), globval(_type_),
			  (catcherror?t:nil));
  check_error_occurred;
  return tpo;
}
 
EXPORT oidtype a_gettype(a_connection c, char *name, int catcherror)
{
  oidtype res=nil;
  oidtype fnsymb;

  PRINT("a_gettype");
  check_initconnection(c);
  if(!c->status)
    {
      a_error(connection_closed,nil,catcherror);
      return nil;
    }
  a_errorflag = FALSE;
  a_lock(); fnsymb=mksymbol(name); 
  if(c->port==nil) res = a_gettypenamed(name,catcherror);
  else res = call_lisp(socket_call,topframe(),5,
		       c->port,mksymbol("getobjectnamed"),fnsymb,
		       globval(_type_),
		       t);
  a_unlock();
  if(res == nil)
    {
      a_error(no_type_named,fnsymb,catcherror);
      return nil;
    }
  return res;
}

EXPORT int a_callfunction(a_connection c, a_scan s, oidtype fn, a_tuple args,
			  int catcherror)
{
  return a_callfunction_custom(c,s,fn,args,"",catcherror);
}

EXPORT int a_callfunction_custom(a_connection c, a_scan s, oidtype fn, 
                                 a_tuple args, char *options, int catcherror)
{
  oidtype opt;

  check_initconnection(c);
  if (trace_interface)
    {
      a_puts("->CCall: Calling ", stdoutstream);
      a_prin1(fn, stdoutstream, FALSE);
      a_print(args->tpl);
      if(strcmp(options,"")!=0) 
        {
          a_puts("Options: ", stdoutstream);
          a_puts(options, stdoutstream);
          a_terpri(stdoutstream);
        }
    }
  PRINT("a_callfunction_custom");
  if (!c->status) return a_error(connection_closed, nil, catcherror);
  //setup_error_trap0(c != a_callback_connection);
  setup_error_trap;
  a_let(opt,readOpt(options));
  if (c->port == nil)
    {
      if (materialized_scan)
	{
	  a_setf(c->result, callfunction(varstack, fn, args->tpl,
					 s->stopafter));
	}
      else
	{
	  a_setf(c->result, open_function_streamfn(varstack, fn, args->tpl,
						   kwote(opt)));
	}
    }
  else
    {
      if (materialized_remote_scan)
	{
	  a_setf(c->result, call_lisp(socket_call, varstack, 5,
				      c->port, call_function, fn, args->tpl,
				      mkinteger(s->stopafter)));
	}
      else
	{
	  a_setf(c->result, 
		 open_function_stream_remotefn(varstack, fn, args->tpl, 
                                               c->port, kwote(opt))); 
	}
    }
  openscan(c, s, FALSE);
  a_free(opt);
  //check_error_occurred0(c != a_callback_connection);
  check_error_occurred;
  if (trace_interface) a_message("<-CCall: call OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_addfunction(a_connection c, oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror)
{
  PRINT("a_addfunction");
  check_initconnection(c);
  if (!c->status) return a_error(connection_closed,nil,catcherror);
  if (trace_interface)
    {
      a_puts("->CCall: add ", stdoutstream);
      a_prin1(fn, stdoutstream, FALSE);
      a_prin1(argl->tpl, stdoutstream, FALSE);
      a_puts(" = ", stdoutstream);
      a_print(resl->tpl);
    }
  setup_error_trap;
  if (c->port == nil) release(addfunction0fn(varstack, fn, argl->tpl,
					     resl->tpl, nil));
  else release(call_lisp(socket_call, varstack, 6,
			 c->port, mksymbol("addfunction0"), fn, argl->tpl,
			 resl->tpl, nil));
  check_error_occurred;
  if (trace_interface) a_message("<-CCall: add OK\n");
  return (a_errorflag = FALSE);
}

EXPORT void a_loadfunction(oidtype fn, oidtype argl, oidtype resl)
     /* A fast and unchecked function for loading data into functions 
        without logging */
{
  oidtype old_histflg = globval(_histflg_);
  PRINT("a_loadfunction");
  {
    unwind_protect_begin;
    a_setf(globval(_histflg_),nil);
    release(addfunction0fn(varstack, fn, argl, resl, nil));
    unwind_protect_catch;
    a_setf(globval(_histflg_),old_histflg);
    unwind_protect_end;
  }
}

EXPORT int a_setfunction(a_connection c,oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror)
{
  PRINT("a_setfunction");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  if(trace_interface)
    {
      a_puts("->CCall: set ",stdoutstream);
      a_prin1(fn,stdoutstream,FALSE);
      a_prin1(argl->tpl,stdoutstream,FALSE);
      a_puts(" = ",stdoutstream);
      a_print(resl->tpl);
    }
  {setup_error_trap;
  if(c->port==nil)
    release(call_lisp(setfunction_dynamic,topframe(),4,
		      fn,argl->tpl,resl->tpl,nil));
  else release(call_lisp(socket_call,topframe(),6,
			 c->port,setfunction_dynamic,fn,argl->tpl,
			 resl->tpl,nil));
  check_error_occurred;}
  if(trace_interface) a_message("<-CCall: set OK\n");
  return (a_errorflag = FALSE);
}

EXPORT int a_remfunction(a_connection c,oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror)
{
  PRINT("a_remfunction");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  if(trace_interface)
    {
      a_puts("->CCall: remove ",stdoutstream);
      a_prin1(fn,stdoutstream,FALSE);
      a_prin1(argl->tpl,stdoutstream,FALSE);
      a_puts(" = ",stdoutstream);
      a_print(resl->tpl);
    }
  {setup_error_trap;
  if(c->port==nil)
    release(call_lisp(remfunction_dynamic,topframe(),4,
		      fn,argl->tpl,resl->tpl,nil));
  else release(call_lisp(socket_call,topframe(),6,
			 c->port,remfunction_dynamic,fn,argl->tpl,
			 resl->tpl,nil));
  check_error_occurred;}
  if(trace_interface) a_message("<-CCall: remove OK");
  return (a_errorflag=FALSE);
}

EXPORT oidtype a_createobject(a_connection c,oidtype type,int catcherror)
{
  dcloid(res);

  PRINT("a_createobject");
  check_initconnection(c);
  if(!c->status)
    {
      a_error(connection_closed,nil,catcherror);
      return nil;
    }
  {setup_error_trap;
  if(c->port==nil) 
    {
      a_setf(res,createobject_tfn(topframe(),type,nil));
    }
  else 
    {
      a_setf(res,call_lisp(socket_call,topframe(),4,
			   c->port,mksymbol("/createobject"),type,nil));
    }
  unwind_protect_catch;
  if(catcherror) a_reset_catch(olds);
  a_unlock();
  if(unwind_reset && catcherror)
    {
      released(res);
      a_errorflag = TRUE;
      return nil;
    }
  unwind_protect_end;}}
  a_return(res);
}

EXPORT int a_deleteobject(a_connection c,oidtype o,int catcherror)
{
  PRINT("a_deleteobject");
  check_initconnection(c);
  if(!c->status) return a_error(connection_closed,nil,catcherror);
  {setup_error_trap;
  if(c->port==nil) release(call_lisp(mksymbol("deleteobject"),
				     topframe(),1,o));
  else release(call_lisp(socket_call,topframe(),3,
			 c->port,mksymbol("deleteobject"),o));
  check_error_occurred;}
  return (a_errorflag = FALSE);
}

EXPORT char *a_stringify(oidtype o)
{
  oidtype str;
  char *res;

  if(o==nil) return mystrdup("NIL");
  if(symbolp(o)) return mystrdup(getpname(o));
  if(stringp(o)) return mystrdup(getstring(o));
  if(integerp(o)) return mystrdup(IntegerToString(getinteger(o)));
  a_lock();
  str = call_lisp(mksymbol("stringify-amos-object"),varstack,1,o);
  res = mystrdup(getstring(str));
  release(str);
  a_unlock();
  return res;
}

oidtype trace_cinterfacefn(bindtype env, oidtype flag)
{
  if(flag==nil) trace_interface = FALSE;
  else trace_interface = TRUE;
  return flag;
}

void register_cinterface(void)
{
  amos_execute = mksymbol("amos-execute");
  execute_remote_statement = mksymbol("execute-remote-statement");
  socket_call = mksymbol("socket-call");
  scan_fillbuffer_remote_request = mksymbol("scan-fillbuffer-remote-request");
  scan_remote_poll_socket = mksymbol("scan-remote-poll-socket");
  scan_fillbuffer_remote_result = mksymbol("scan-fillbuffer-remote-result");
  setfunction_dynamic = mksymbol("setfunction-dynamic");
  remfunction_dynamic = mksymbol("remfunction-dynamic");
  _suppress_error_ = mksymbol("_catch-errors_");
  connection_not_initialized = a_register_error("Connection not initialised");
  connection_nolocal = a_register_error("No local database");
  connection_closed = a_register_error("Connection closed");
  connection_already_opened = a_register_error("Connection already opened");
  no_function_named = a_register_error("No function named");
  no_type_named = a_register_error("No type named");
  scan_not_initialized = a_register_error("Scan not initialized");
  tuple_not_initialized = a_register_error("Tuple not initialized");
  blob_not_initialized = a_register_error("BLOB not initialized");
  arg_not_blob = a_register_error("Not a BLOB");
  blob_too_small = a_register_error("BLOB too small");
  arg_not_seq = a_register_error("Tuple element not sequence");
  empty_scan = a_register_error("Empty scan");
  illegal_rowpos = a_register_error("Illegal scan row position");
  amos_not_initialized = a_register_error("Amos II not initialized");
  illegal_object = a_register_error("Illegal kind of object");
  cannot_use_materialized_scan = a_register_error("Cannot use materialized scan for stream");
  can_only_use_remote_scan = a_register_error("Can only use remote scan");
  extfunction1("trace-cinterface",trace_cinterfacefn);
  a_callback_connection = a_init_connection();
  a_callback_connection->name = mystrdup("");
  a_callback_connection->servid = nil;
  a_callback_connection->port = nil;
  a_callback_connection->status = TRUE;
  return;
}
