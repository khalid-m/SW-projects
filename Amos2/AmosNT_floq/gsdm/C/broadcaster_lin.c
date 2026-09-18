/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2005 Arsenij Vodjanov
 * $RCSfile: broadcaster_lin.c,v $
 * $Revision: 1.2 $
 *
 * Description: Amos2 driver program for UDP broadcaster linux daemon
 ****************************************************************************/

#include "../../C/callin.h"
#include "../../C/callout.h"

#include "udp_common.h"

// defined in udp_common.h
// If not defined, code in udp_test.c is compiled instead.
#ifdef BROADCASTER_IS_DAEMON

#include "udp_streams.h"
#include "udp_radiosource.h"
#include "udp_producer.h"

#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>

// Daemon configuration: rundir, lockfile
#include "daemon_cfg.h"

// Amos2 database image
#define AMOS_IMAGE_FILE         "amos2.dmp"

// UDP Broadcaster Lisp functions
#define BROADCASTER_LISP_FILE   "daemon.lsp"

// Logging convenience macros
#define MSG(x) udp_log_message x
#define ERR(x) udp_log_error x

// Server state
#define STATE_INIT 0
#define STATE_RUNNING 1
#define STATE_RESTARTING 2
#define STATE_SHUTDOWN 3
static int server_state = STATE_INIT;


///
// Handler for catching signals
void signal_handler(int sig)
{
  switch(sig) {
  case SIGHUP:
    MSG(("Hangup-signal (SIGHUP) caught: reset\n"));
    server_state = STATE_RESTARTING;
    break;
  case SIGTERM:
    MSG(("Terminate-signal (SIGTERM) caught: terminate\n"));
    server_state = STATE_SHUTDOWN;
    break;
  default:
    break;
  }
}


void daemonize()
{
  int i, lfp;
  char str[10];

  if(getppid()!=1) { /* already a daemon? */

    i = fork();
    if (i<0) exit(1); /* Fork error */
    if (i>0) exit(0); /* parent exits */
    /* child (daemon) continues */

    setsid(); /* obtain a new process group */
  }
  for (i=getdtablesize();i>=0;--i) close(i); /* close all descriptors */
  i=open("/dev/null",O_RDWR); dup(i); dup(i); /* handle standard I/O streams, 0,1,2 */
  umask(027); /* set newly created file permissions */
  chdir(DAEMON_RUN_DIR); /* change running directory */
  lfp=open(DAEMON_LOCK_FILE, O_RDWR|O_CREAT,0640);
  if (lfp<0) {
    ERR(("Can't open lockfile\n"));
    exit(1); /* can not open */
  }
  if (lockf(lfp,F_TLOCK,0)<0) {
    ERR(("Can't lock lockfile\n"));
    exit(0); /* can not lock */
  }
  /* first instance continues */
  sprintf(str,"%d\n",getpid());
  write(lfp,str,strlen(str)); /* record pid to lockfile */
  signal(SIGCHLD,SIG_IGN); /* ignore child */
  signal(SIGTSTP,SIG_IGN); /* ignore tty signals */
  signal(SIGTTOU,SIG_IGN);
  signal(SIGTTIN,SIG_IGN);
  signal(SIGHUP, signal_handler); /* hangup signal */
  signal(SIGTERM, signal_handler); /* software termination signal from kill */
}

// (re)loads Lisp code and runs init
void start_udp_broadcaster()
{
  dcl_oid(lispfile);
  bindtype env = topframe();
  a_setf(lispfile, mkstring(BROADCASTER_LISP_FILE));
  call_lisp(mksymbol("load"), env, 1, lispfile);
  a_free(lispfile);
  call_lisp(mksymbol("init-broadcaster"), env, 0);
}


// all three pointers must point to valid data
inline void update_timestamps(struct timespec **tpC, 
			      struct timespec **tpP, 
			      struct timespec *tpD)
{
  // What was current timestamp has now become the previous timestamp.
  // Swap pointers instead of copying the data from current to prev.
  struct timespec *tpTmp = *tpP;
  *tpP = *tpC;
  *tpC = tpTmp;
  clock_gettime(CLOCK_REALTIME, *tpC);
  // calc time delta between prev and current
  tpD->tv_sec = (*tpC)->tv_sec - (*tpP)->tv_sec;
  if ((*tpP)->tv_nsec < (*tpC)->tv_nsec)
    tpD->tv_nsec = (*tpC)->tv_nsec - (*tpP)->tv_nsec;
  else
    tpD->tv_nsec = (*tpP)->tv_nsec - (*tpC)->tv_nsec;
}


int main(int argc,char **argv)
{
  dcl_connection(c);
  dcl_scan(s);
  bindtype env;
  dcl_oid(res);
  dcl_oid(initfile);
  dcl_oid(cd_timeout); // timeout for check-descriptors
  int listen_port=0;
  struct timespec tCurr, tPrev, tDelta;
  struct timespec *tpCurr=&tCurr, *tpPrev=&tPrev;
  daemonize();

  MSG(("\n  Amos2 UDP-Radio Broadcaster Server\n  By Arsenij Vodjanov (arsenij@gmail.com)\n\n"));

  MSG((" --- Initializing AMOS with image \"%s\"\n", AMOS_IMAGE_FILE));

  // initialize embedded amos
  a_initialize(AMOS_IMAGE_FILE, FALSE);
  a_connect(c,"",FALSE);
  // register foreign C-functions with amos
  udp_register_stream_functions();
  udp_register_radiosource_functions();
  udp_register_producer_functions();
  // get Lisp env
  env = topframe();
  // start UDP subsys for the first time
  MSG((" --- Loading %s\n", BROADCASTER_LISP_FILE));
  start_udp_broadcaster();
  MSG((" --- Init finished, entering main loop\n"));
  server_state = STATE_RUNNING;

  /* Get first timestamp */
  clock_gettime(CLOCK_REALTIME, tpCurr);

  /* Main loop start */

  while (server_state!=STATE_SHUTDOWN) {

    if (server_state == STATE_RESTARTING) {
      MSG((" --- Restarting broadcaster\n"));
      call_lisp(mksymbol("close-udp-modules"), env, 0);
      sleep(1); // wait a moment to make sure that everything dies in peace
      start_udp_broadcaster(); // reinitialize udp
      MSG(("\n --- %s reloaded, resuming main loop\n", BROADCASTER_LISP_FILE));
      server_state = STATE_RUNNING;
    }

    update_timestamps(&tpCurr, &tpPrev, &tDelta);
    call_lisp(mksymbol("pump-server-loop"), env, 0);

    a_setf(cd_timeout, mkreal(0.000005));
    call_lisp(mksymbol("check-descriptors"), env, 1, cd_timeout);
    a_free(cd_timeout);
  }

  /* End of main loop */

  MSG((" --- Shutting down\n"));
  call_lisp(mksymbol("close-udp-modules"), env, 0);
  a_free(cd_timeout);
  a_disconnect(c, FALSE);
  free_connection(c);
  exit(0);
}

#endif // ifdef BROADCASTER_IS_DAEMON

/* EOF */
