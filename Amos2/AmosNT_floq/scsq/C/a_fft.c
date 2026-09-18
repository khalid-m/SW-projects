/****************************************************************************
* AMOS2
*
* Author: (c) 2007 Erik Zeitler, UDBL
* $RCSfile: a_fft.c,v $
* $Revision: 1.4 $ $Date: 2011/04/26 17:44:35 $
* $State: Exp $ $Locker:  $
*
* Description: AmosII fft methods
*
***************************************************************************/

#include "amos.h"
#include "numarray.h"
#include "fftcomplex.h"

void a_realfftbf(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx, *dres;
  oidtype x, res;
  x = a_getobjectelem(params,0,FALSE);
	
  //OfType(x, NUMARRAYTYPE, cxt->env);
  dx = dr(x, numarraycell);
  res = make_darrayfn(cxt->env, mkinteger(dx->numelems));
  dres = dr(res, numarraycell);
  realfft((double*)dx->cont, dx->numelems, (double*)dres->cont);
  a_setobjectelem(params, 1, res, FALSE);
  a_emit(cxt, params, FALSE);
}

void a_realfftfb(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx, *dres;
  oidtype x, res;
  x = a_getobjectelem(params,1,FALSE);
	
  //OfType(x, NUMARRAYTYPE, cxt->env);
  dx = dr(x, numarraycell);
  res = make_darrayfn(cxt->env, mkinteger(dx->numelems));
  dres = dr(res, numarraycell);
  realrft((double*)dx->cont, dx->numelems, (double*)dres->cont);
  a_setobjectelem(params, 0, res, FALSE);
  a_emit(cxt, params, FALSE);
}

void a_fftbf(a_callcontext cxt, a_tuple params) {
	struct numarraycell *dx, *dres;
	oidtype x, res;
	COMPLEX *in;
	x = a_getobjectelem(params,0,FALSE);
	
	//OfType(x, NUMARRAYTYPE, cxt->env);
	dx = dr(x, numarraycell);
	res = make_carrayfn(cxt->env, mkinteger(dx->numelems));
	in = (COMPLEX*)malloc(dx->numelems*sizeof(COMPLEX));
	dres = dr(res, numarraycell);
	memcpy(in,(char *)(dx->cont),dx->numelems*sizeof(COMPLEX));
	fft(in, dx->numelems, (COMPLEX*)dres->cont);
	a_setobjectelem(params, 1, res, FALSE);
	free(in);
	a_emit(cxt, params, FALSE);
}

void a_fftpartbf(a_callcontext cxt, a_tuple params) {
	struct numarraycell *dx, *dres;
	oidtype x, res;
	COMPLEX *in;
	int totlen;
	x = a_getobjectelem(params,0,FALSE);
	totlen = a_getintelem(params,1,FALSE);
	
	//OfType(x, NUMARRAYTYPE, cxt->env);
	dx = dr(x, numarraycell);
	res = make_carrayfn(cxt->env, mkinteger(dx->numelems));
	in = (COMPLEX*)malloc(dx->numelems*sizeof(COMPLEX));
	dres = dr(res, numarraycell);
	memcpy(in,(char *)(dx->cont),dx->numelems*sizeof(COMPLEX));
	fftpart(in, dx->numelems, (COMPLEX*)dres->cont, totlen);
	a_setobjectelem(params, 2, res, FALSE);
        free(in);
	a_emit(cxt, params, FALSE);
}

void a_ifftbf(a_callcontext cxt, a_tuple params) {
	struct numarraycell *dx, *dres;
	oidtype x, res;
	COMPLEX *in;
	x = a_getobjectelem(params,0,FALSE);
	
	//OfType(x, NUMARRAYTYPE, cxt->env);
	dx = dr(x, numarraycell);
	res = make_carrayfn(cxt->env, mkinteger(dx->numelems));
	in = (COMPLEX*)malloc(dx->numelems*sizeof(COMPLEX));
	dres = dr(res, numarraycell);
	memcpy(in,(char *)(dx->cont),dx->numelems*sizeof(COMPLEX));
	rft(in, dx->numelems, (COMPLEX*)dres->cont);
	a_setobjectelem(params, 1, res, FALSE);
        free(in);
	a_emit(cxt, params, FALSE);
}

void register_fft() {
	a_extfunction("REALFFTBF", a_realfftbf);
	a_extfunction("REALFFTFB", a_realfftfb);
	a_extfunction("FFTBF", a_fftbf);
	a_extfunction("FFTPARTBF", a_fftpartbf);
	a_extfunction("IFFTBF",a_ifftbf);
}
