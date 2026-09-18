/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Erik Zeitler, UDBL
 * $RCSfile: lrmultiply.c,v $
 * $Revision: 1.6 $ $Date: 2012/03/26 23:35:25 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Multiply a multiarray of LR input events into multiple events
 * ===========================================================================
 * $Log: lrmultiply.c,v $
 * Revision 1.6  2012/03/26 23:35:25  zeitler
 * increment xway for type 3 queries
 *
 * Revision 1.5  2010/06/21 14:03:33  fred2431
 * remove the unnecessary variable "rest"
 *
 * Revision 1.4  2010/06/21 11:50:33  zeitler
 * Making lrmultiply compile again
 *
 * Revision 1.3  2010/06/20 14:34:18  fred2431
 * Introduce function lrmulf that multiplies a multiarray of LR input events with a float number
 *
 * Revision 1.2  2010/05/31 12:06:15  zeitler
 * bug fix
 *
 * Revision 1.1  2010/05/21 15:37:35  zeitler
 * lrmultiply re-written in C
 *
 *
 ****************************************************************************/


#include "amos.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "complex.h"
#include "w.h"
#include "storage.h"

#include <stdio.h>

EXTERN double a_round(double x);

void add_vid_qid_x(int* tpl, int mult, int srcl) {
  // 0: add vid and xway
  // 2: add vid and qid
  // 3: add vid and qid and xway
  // 4: add nothing
  if (tpl[0] != 4) { // just copy eventtype 4
    tpl[2] += 140000 * mult;
    if (tpl[0] == 0 || tpl[0] == 3) { // add xway
      tpl[4] += srcl * mult;
    }
    if (tpl[9] != -1) { // add qid if query
      tpl[9] += 125000 * mult;
    }
  }
}

oidtype lrmul(a_callcontext cxt) {
  int i, j, rep, srcl, esz, kind, numelems;
  int acount;
  struct numarraycell *dx, *dres;
  oidtype res = nil;
  oidtype x = a_arg(cxt, 1);
  oidtype l = a_arg(cxt, 2);
  oidtype repeat = a_arg(cxt, 3);

  IntoInteger(l, srcl, a_env(cxt));
  IntoInteger(repeat, rep, a_env(cxt));

  dx = dr(x, numarraycell);
  kind = dx->kind;
  numelems = dx->numelems;
  esz = numarray_elemsize(kind);
  acount = numelems / 15;

  a_bind(cxt, 4, x);
  a_result(cxt);

  for (i = 1; i < rep; i++) {
    res = make_numarray(dx->numelems, esz, kind);
    dx = dr(x, numarraycell);
    dres = dr(res, numarraycell);
    memcpy(dres->cont, dx->cont, dx->numelems * esz);
    dres->kind = dx->kind;
    for (j = 0; j < acount; j++) {
      add_vid_qid_x(dres->cont + j*15, i, srcl);
    }
    a_bind(cxt, 4, res);
    a_result(cxt);
  }
  return nil;
}

// Example:
// count(clrmultiplyf(in(i_hybrid(64, 0, 1)), 64, 0.5625 ) );
// should be the same as:
// select count( select v from iarray v where v in( i_hybrid(64, 0, 1) ) and v[4]<=36);

oidtype lrmulf(a_callcontext cxt) {
  int i, j, rep, srcl, esz, kind, numelems;
  int acount, rest_numel;
  double mult;
  struct numarraycell *dx, *dres;
  oidtype res = nil;
  oidtype x = a_arg(cxt, 1);
  oidtype l = a_arg(cxt, 2);
  oidtype repeat = a_arg(cxt, 3);

  IntoInteger(l, srcl, a_env(cxt));
  IntoDouble(repeat, mult, a_env(cxt));
 
  dx = dr(x, numarraycell);
  kind = dx->kind;
  numelems = dx->numelems;
  esz = numarray_elemsize(kind);
  acount = numelems / 15;

  if ( mult >= 1.0 )
  {
    a_bind(cxt, 4, x);
    a_result(cxt);
  }

  rep = (int)floor( mult );
  for (i = 1; i < rep; i++) {
    
    res = make_numarray(dx->numelems, esz, kind);
    dx = dr(x, numarraycell);
    dres = dr(res, numarraycell);
    memcpy(dres->cont, dx->cont, dx->numelems * esz);
    dres->kind = dx->kind;
    for (j = 0; j < acount; j++) {
      add_vid_qid_x(dres->cont + j*15, i, srcl);
    }
    a_bind(cxt, 4, res);
    a_result(cxt);
  }
  
  // multiply the remaining float number times 0 ... 1
  mult = mult - rep;
  rest_numel = (int)a_round((double)numelems * mult);
  if ( rest_numel > 0 )
  {
    int* tpl;
    int maxL = (int)a_round((double)mult*srcl);
    dx = dr(x, numarraycell);
    tpl = dx->cont; //first element in numarray
    if ( tpl[4] <= maxL )
    {
      res = make_numarray(dx->numelems, esz, kind);
      dx = dr(x, numarraycell);
      dres = dr(res, numarraycell);
      
      memcpy(dres->cont, dx->cont, dx->numelems * esz);
      dres->kind = dx->kind;
      for (j = 0; j < acount; j++)
      {
	add_vid_qid_x(dres->cont + j*15, rep, srcl);
      }
    
      a_bind(cxt, 4, res);
      a_result(cxt);
    }
  }
 
  return nil;
}


void register_lrmultiply(void) {
  a_extimpl("clrmulbbbf", lrmul);
  a_extimpl("clrfmulbbbf", lrmulf);
}
