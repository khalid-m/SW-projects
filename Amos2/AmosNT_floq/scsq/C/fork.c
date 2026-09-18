/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Fork a process
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "fork.h"
#include "amos.h"
#include <stdio.h>
#include "pipestream.h"

#ifndef NT
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#endif

#define DEBUGFLG

oidtype forkfn(bindtype env) {
  int forkstate = fork();
  if (forkstate < 0) {
    return lerror(FORK_FAILED, nil, env);
  } else if (forkstate == 0) {
    fclose(stdin);
    return mkinteger(forkstate);
  } else {
    return mkinteger(forkstate);
  }
}

oidtype waitpfn(bindtype env, oidtype child_pid) {
  int status;
  int pid = getinteger(child_pid);
  waitpid(pid, &status, 0);
  return mkinteger(status);
}

oidtype pollpfn(bindtype env, oidtype child_pid) {
  int status;
  int pid = getinteger(child_pid);
  waitpid(pid, &status, WNOHANG);
  return mkinteger(status);
}

void register_fork(void) {
  FORK_FAILED = a_register_error("Fork failed");
  extfunction0("fork0", forkfn);
  extfunction1("waitproc", waitpfn);
  extfunction1("pollproc", pollpfn);
}
