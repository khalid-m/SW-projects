/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Fork a process
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"
#include <stdio.h>
#include "pipestream.h"

#ifndef NT
#include <unistd.h>
#endif

int FORK_FAILED;

oidtype forkfn(bindtype env);
void register_fork(void);
