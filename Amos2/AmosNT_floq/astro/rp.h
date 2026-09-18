/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 *
 * Description:  Function headers for Running Processors
 * Language:     C
 * Location:     AmosNT/astro/rp.h
 ****************************************************************************/

#include "amos.h"
void udpgw_mapper(bindtype env, oidtype tpl, void *xa);
void udpgw(a_callcontext cxt, a_tuple params);
void register_rp(void);

#define TCPPROTOCOL 1
#define MPIPROTOCOL 2
#define BGOUTPROTOCOL 3
#define VIAPROTOCOL 4
