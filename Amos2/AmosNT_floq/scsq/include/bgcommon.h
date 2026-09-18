/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, Tore Risch, UDBL
 *
 * Description:  BGcommon. Common functions for BlueGene and front nodes
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"

oidtype is_errorfn(bindtype env, oidtype x);
char *get_varstring(bindtype env, char *var);
void register_bgcommon(void);
void acc_tv(struct timeval* res,
	    const struct timeval* tstart, const struct timeval* tend);

#ifdef NT
void gettimeofday(struct timeval *tv, void* unused);
#endif
