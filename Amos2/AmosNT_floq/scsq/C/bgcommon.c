/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, Tore Risch, UDBL
 *
 * Description:  BGcommon. Functions common for both BlueGene and front nodes
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include "amos.h"
#include <stdlib.h>

oidtype is_errorfn(bindtype env, oidtype x) {
  /* If x is an error condition list retur its contents */
  static oidtype efn=nil;

  if(efn==nil) efn = mksymbol("error?");
  return call_lisp(efn,env,1,x);
}

char *get_varstring(bindtype env, char *var) {
     /* Get BG variable bound to string */
  return getstring(call_lisp(mksymbol("get-varstring"),env,1,
			     mksymbol(var)));
}

oidtype ez_randfn(bindtype env, oidtype max) {
	return mkinteger((int)(getinteger(max)/(RAND_MAX + 1.0) * rand()));
}

void acc_tv(struct timeval* res,
       const struct timeval* tstart, const struct timeval* tend) {
  /* Add (tend - tstart) to result res */
  if ((res->tv_usec += tend->tv_usec - tstart->tv_usec) < 0) {
    res->tv_usec += 1000000;
    res->tv_sec  += tend->tv_sec - tstart->tv_sec - 1;
  } else if (res->tv_usec > 1000000) {
    res->tv_usec -= 1000000;
    res->tv_sec  += tend->tv_sec - tstart->tv_sec + 1;
  } else {
    res->tv_sec  += tend->tv_sec - tstart->tv_sec;
  }
}

void register_bgcommon(void) {
	extfunction1("EZ-RAND", ez_randfn);
}
