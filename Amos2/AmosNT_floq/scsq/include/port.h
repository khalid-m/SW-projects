/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Function headers for port
 * Language:     C
 * Location:     AmosNT/astro/port.h
 ****************************************************************************/

#include "amos.h"

void port_bf(a_callcontext cxt, a_tuple params);
void register_port(void);
oidtype connecttoportfn(bindtype env, oidtype port);
void extract_bf(a_callcontext cxt, a_tuple params);
