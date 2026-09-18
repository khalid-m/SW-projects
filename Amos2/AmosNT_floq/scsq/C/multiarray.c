/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Erik Zeitler, UDBL
 * $RCSfile: multiarray.c,v $
 * $Revision: 1.12 $ $Date: 2013/01/04 13:42:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Window functions over numarrays
 * ===========================================================================
 * $Log: multiarray.c,v $
 * Revision 1.12  2013/01/04 13:42:33  torer
 * Memory management bug
 *
 * Revision 1.11  2011/01/17 13:47:34  zeitler
 * sleep if all busy
 *
 * Revision 1.10  2011/01/13 10:31:33  zeitler
 * lread multiarray zip
 *
 * Revision 1.9  2010/12/30 19:44:10  zeitler
 * cleanup + eliminated warnings
 *
 * Revision 1.8  2010/07/21 14:39:11  zeitler
 * Allocate correct numarray size after mapfunction of na2multi
 *
 * Revision 1.7  2010/06/27 19:46:45  zeitler
 * *** empty log message ***
 *
 * Revision 1.6  2010/06/26 14:59:42  zeitler
 * Optimized multibuffer zip
 *
 * Revision 1.5  2010/06/24 11:43:53  zeitler
 * *** empty log message ***
 *
 * Revision 1.4  2010/06/23 16:31:02  zeitler
 * C helper functions for stream merge on multiarrays
 *
 * Revision 1.3  2010/06/14 16:04:00  zeitler
 * multiarray pointer arithmetic fix
 *
 * Revision 1.2  2010/03/02 14:48:22  zeitler
 * Multiarrays
 *
 * Revision 1.1  2010/03/01 16:55:43  zeitler
 * Multiarrays
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

oidtype mzipread, busy;

struct mastate {
  int kind;
  unsigned int alength, malength, pos, first, sz;
  oidtype ma;
  a_callcontext cxt;
};

oidtype ma_mapper(a_callcontext cxt, int arity, oidtype *tpl, void *xa) {
  struct numarraycell *mx, *tx;
  struct mastate *state;
  state = (struct mastate*)xa;

  if (state->first) {
    tx = dr(tpl[0], numarraycell);
    state->kind = tx->kind;
    switch(tx->kind) {
    case 0:
      state->sz = 1;
      break;
    case 1:
      state->sz = sizeof(double)/sizeof(int);
      break;
    case 2:
      state->sz = sizeof(COMPLEX)/sizeof(int);
      break;
    default: // Crash!
      break;
    }
    state->alength = tx->numelems;
    state->malength = state->first * state->alength;
    state->first = 0;
  }

  if (state->pos == 0)
    a_setf(state->ma, make_numarray(state->malength, state->sz*sizeof(int), state->kind));

  tx = dr(tpl[0], numarraycell);
  mx = dr(state->ma, numarraycell);
  memcpy(mx->cont + state->pos, tx->cont, state->alength * state->sz * sizeof(int));
  state->pos += state->alength*state->sz;

  if (state->pos == state->malength*state->sz) {
    state->pos=0;
    a_bind(state->cxt, 3, state->ma);
    a_result(state->cxt);
  }
  return nil;
}

oidtype mabbf(a_callcontext cxt) {
  struct mastate state;
  oidtype bag = a_arg(cxt, 1);
  oidtype size = a_arg(cxt, 2);

  IntoInteger(size, state.first, a_env(cxt));
  state.alength = 0;
  state.malength = 0;
  state.sz = 0;
  state.pos = 0;
  state.kind = 0;
  state.ma = nil;
  {
    unwind_protect_begin;
    state.cxt = cxt;
    a_mapbag(cxt, bag, ma_mapper, (void*)&state);
    unwind_protect_catch;
    if (!unwind_reset) {
      if (state.pos) {
	unsigned int i;
	struct numarraycell *tx, *rx;
	oidtype ret = nil;
	a_setf(ret, make_numarray(state.pos, state.sz*sizeof(int), state.kind));
	tx = dr(state.ma, numarraycell);
	rx = dr(ret, numarraycell);
	rx->kind = tx->kind;
	rx->numelems = state.pos;
	for (i=0; i< state.pos;i++) {
	  rx->cont[i] = tx->cont[i];
	}
	a_bind(cxt, 3, ret);
	a_result(cxt);
	a_free(ret);
      }
    }
    a_free(state.ma);
    unwind_protect_end;
    return nil;
  }
}

oidtype splitna(a_callcontext cxt) {
  int rlen, xlen;
  int pos, step, tots;
  size_t esz;
  struct numarraycell *dx, *dres;
  oidtype ret = nil;
  oidtype multiarray = a_arg(cxt, 1);
  oidtype retlen = a_arg(cxt, 2);
  IntoInteger(retlen, rlen, a_env(cxt));

  dx = dr(multiarray, numarraycell);
  esz = numarray_elemsize(dx->kind);
  xlen = dx->numelems;
  step = rlen * esz / WORD_SIZE;
  tots = xlen * esz / WORD_SIZE;

  if (0 != xlen%rlen) {
    a_error(MAMISMATCH_ERROR, a_list(mkinteger(xlen), mkinteger(rlen), NULL),
	    FALSE);
  }

  for (pos = 0; pos < tots; pos += step) {
    ret = make_numarray(rlen, esz, dx->kind);
    dx = dr(multiarray, numarraycell);
    dres = dr(ret, numarraycell);
    memcpy(dres->cont, dx->cont + pos, dres->numelems*esz);
    a_bind(cxt, 3, ret);
    a_result(cxt);
  }
  return nil;
}

oidtype new_emitarrfn(bindtype env, oidtype bufarr, oidtype bufpos, 
		      oidtype nalen) {
  struct numarraycell *numbuf, *resbuf;
  int i, n, kind, nl = getinteger(nalen), sz, *pos;
  int chunk, offsetsz;
  oidtype res = nil, *dbufarr, *dres;

  n = dr(bufpos, numarraycell)->numelems;
  dbufarr = dr(bufarr, arraycell)->cont;
  // no buf may be nil
  for (i = 0; i < n; i++) {
    if (nil == dbufarr[i]) {
      return nil;
    }
  }

  // look at bufarr 0: assume same kind of numarray in all input buffers
  numbuf = dr(dbufarr[0], numarraycell);
  kind = numbuf->kind;
  sz = numarray_elemsize(kind);

  // allocate the array of numarrays to emit
  a_setf(res, new_array(n, nil));
  for (i = 0; i < n; i++) {
    a_seta(res, i, make_numarray(nl, sz, kind));
  }
  chunk = nl*sz;
  offsetsz = sz/sizeof(int);

  dbufarr = dr(bufarr, arraycell)->cont;
  pos = dr(bufpos, numarraycell)->cont;
  dres = dr(res, arraycell)->cont;

  for (i = 0; i < n; i++) {
    numbuf = dr(dbufarr[i], numarraycell);
    resbuf = dr(dres[i], numarraycell);
    memcpy(resbuf->cont, numbuf->cont + pos[i] * offsetsz, chunk);
    resbuf->kind = numbuf->kind;
  }
  a_return(res);
}

oidtype dest_read_somefn(bindtype args, bindtype env) 
{
  oidtype bufarr = nthargval(args, 1);
  oidtype bufpos = nthargval(args, 2);
  oidtype prodv = nthargval(args, 3);
  oidtype prodl = nthargval(args, 4);
  oidtype nalen = nthargval(args, 5);
  oidtype lreadflag = nthargval(args, 6);
  oidtype ctpl;
  int i, n = a_arraysize(bufarr), nl = getinteger(nalen), *pos, *arr, 
    lefttoread = 0, dosleep;
  pos = dr(bufpos, numarraycell)->cont;
  arr = dr(bufarr, arraycell)->cont;

  for (i = 0; i < n; i++) 
    {
      pos[i] += nl;
      if (pos[i] == dr(arr[i], numarraycell)->numelems) 
	{
	  pos[i] = -1;
	  lefttoread++;
	}
    }
  while (lefttoread > 0) 
    {
      dosleep = 1;
      for (i = 0; i < n; i++) 
	{
	  if (pos[i] == -1) 
	    {
	      ctpl = call_lisp(mzipread, env, 3, a_elt(prodv, i), prodl, 
			       lreadflag);
              pos = dr(bufpos, numarraycell)->cont;
              arr = dr(bufarr, arraycell)->cont;
	      if (nil == ctpl) 
		{ // return nil and stop if any ctpl is nil
		  return nil; 
		} 
	      else if (busy != ctpl) 
		{
		  dosleep = 0;
		  pos[i] = 0;
		  lefttoread--;
		  a_seta(bufarr, i, ctpl);
		}
	    }
	}
      if (dosleep) 
	{ // sleep if all were busy
	  a_sleep(0.001);
	  pos = dr(bufpos, numarraycell)->cont;
	  arr = dr(bufarr, arraycell)->cont;
	}
    }
  return bufarr;
}

void register_multina(void) {
  extfunction3("new-emitarr", new_emitarrfn);
  extfunctionn("dest-readsome", dest_read_somefn);
  a_extimpl("multinabbf", mabbf);
  a_extimpl("splitnabbf", splitna);
  MAMISMATCH_ERROR = a_register_error("Multiarray size mismatch");
  mzipread = mksymbol("MZIPREAD");
  busy = mksymbol("*BUSY*");
}
