/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: nma_fns.c,v $
 * $Revision: 1.6 $ $Date: 2013/11/23 22:56:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Basic functions operating on NMAs
 ****************************************************************************
 * $Log: nma_fns.c,v $
 * Revision 1.6  2013/11/23 22:56:02  andan342
 * - moved fragment mapper facility into nma.c
 * - added ALisp functions nma-copy, nma-vsum, nmau-scale, nma-scale, nmau-roundto, nma-roundto, nma-round
 *
 * Revision 1.5  2013/02/21 23:33:02  andan342
 * Renamed NMA-PROXY-RESOLVE to APR, using it to define all non-aggregate SciSparql foreign functions as proxy-tolerant
 *
 * Revision 1.4  2013/02/08 00:46:44  andan342
 * Added C implementation of NMA chunk cache and NMA-PROXY-RESOLVE
 *
 * Revision 1.3  2013/02/05 14:12:31  andan342
 * Renamed nma-init to nma-fill (more general behavior), nma-allocate now takes extra argument,
 * implemented RDF:SUM and RDF:AVG aggregate functions in C
 *
 * Revision 1.2  2013/02/04 12:22:14  andan342
 * Implemented vector sum for NMAs
 *
 * Revision 1.1  2012/03/27 10:26:56  andan342
 * Added C implementations of array aggregates
 *
 *
  ****************************************************************************/

#include "nma.h"

//////////////////// COUNT 

void nma_count_bf(a_callcontext cxt, a_tuple tpl)
{ // Amos: count of the array elements, 1 if atomic number 
	oidtype x = a_getobjectelem(tpl, 0, FALSE);
	int dt = a_datatype(x),
		  res;

	if (dt == NMATYPE) res = nmacell_elemcnt(dr(x, nmacell));
	else if (dt == INTEGERTYPE || dt == REALTYPE || dt == COMPLEXTYPE) res = 1;
	else return;

	a_setobjectelem(tpl, 1, mkinteger(res), FALSE);
	a_emit(cxt, tpl, FALSE);
}

/////////////////// SUM & AVG 

int nmacell_isum(struct nmacell* dx)
{	
	struct numarraycell *ds;
	int res;

	ds = dr(dx->s, numarraycell);
	res = 0;
	do {
		res += ds->cont[nmacell_iter2si(dx)];
	} while (nmacell_iter_next(dx) > 0);
	return res;
}

double nmacell_dsum(struct nmacell* dx)
{	
	struct numarraycell *ds;
	double res;
	double *dcont;
	
	ds = dr(dx->s, numarraycell);
	dcont = (double*)ds->cont;
	res = 0;
	do {
		res += dcont[nmacell_iter2si(dx)];
	} while (nmacell_iter_next(dx) > 0);
	return res;
}

oidtype nma_sumfn(bindtype env, oidtype x)
{ // ALisp (unsafe): sum of the array elements
	struct nmacell *dx = dr(x, nmacell);

	nmacell_iter_reset(dx);
	switch (dr(dx->s, numarraycell)->kind) {
		case 0: return mkinteger(nmacell_isum(dx)); 
		case 1: return mkreal(nmacell_dsum(dx));
	}
	return nil;
}

oidtype nma_avgfn(bindtype env, oidtype x)
{ // ALisp (unsafe): average of the array elements
	struct nmacell *dx = dr(x, nmacell);
	int cnt = nmacell_elemcnt(dx); // guaranteed >= 1

	nmacell_iter_reset(dx);
	switch (dr(dx->s, numarraycell)->kind) {
		case 0: return mkreal(nmacell_isum(dx) * 1.0 / cnt); 
		case 1: return mkreal(nmacell_dsum(dx) / cnt);
	}
	return nil;
}

////////////////// MIN 

int nmacell_imin(struct nmacell* dx)
{	
	struct numarraycell *ds;
	int res;

	ds = dr(dx->s, numarraycell);
	res = ds->cont[nmacell_iter2si(dx)];
	while (nmacell_iter_next(dx) > 0)  
		if (ds->cont[nmacell_iter2si(dx)] < res)
			res = ds->cont[nmacell_iter2si(dx)];
	return res;
}

double nmacell_dmin(struct nmacell* dx)
{	
	struct numarraycell *ds;
	double res;
	double *dcont;

	ds = dr(dx->s, numarraycell);
	dcont = (double*)ds->cont;
	res = dcont[nmacell_iter2si(dx)];
	while (nmacell_iter_next(dx) > 0) 
		if (dcont[nmacell_iter2si(dx)] < res)
			res = dcont[nmacell_iter2si(dx)];
	return res;
}

oidtype nma_minfn(bindtype env, oidtype x)
{ // ALisp (unsafe): min of the array elements
	struct nmacell *dx = dr(x, nmacell);

	nmacell_iter_reset(dx);
	switch (dr(dx->s, numarraycell)->kind) {
		case 0: return mkinteger(nmacell_imin(dx)); 
		case 1: return mkreal(nmacell_dmin(dx));
	}
	return nil;
}

/////////////// MAX

int nmacell_imax(struct nmacell* dx)
{	
	struct numarraycell *ds;
	int res;

	ds = dr(dx->s, numarraycell);
	res = ds->cont[nmacell_iter2si(dx)];
	while (nmacell_iter_next(dx) > 0)  
		if (ds->cont[nmacell_iter2si(dx)] > res)
			res = ds->cont[nmacell_iter2si(dx)];
	return res;
}

double nmacell_dmax(struct nmacell* dx)
{	
	struct numarraycell *ds;
	double res;
	double *dcont;

	ds = dr(dx->s, numarraycell);
	dcont = (double*)ds->cont;
	res = dcont[nmacell_iter2si(dx)];
	while (nmacell_iter_next(dx) > 0) 
		if (dcont[nmacell_iter2si(dx)] > res)
			res = dcont[nmacell_iter2si(dx)];
	return res;
}

oidtype nma_maxfn(bindtype env, oidtype x)
{ // ALisp (unsafe): max of the array elements
	struct nmacell *dx = dr(x, nmacell);

	nmacell_iter_reset(dx);
	switch (dr(dx->s, numarraycell)->kind) {
		case 0: return mkinteger(nmacell_imax(dx)); 
		case 1: return mkreal(nmacell_dmax(dx));
	}
	return nil;
}

//////////////// ARRAY SUM, AVG, MIN & MAX 

void nma_aggregate_bbf(a_callcontext cxt, a_tuple tpl) // TODO: extensible aggregation
{ // Amos: apply to array tpl[0] aggregate function identified by tpl[1]:
	// 1 = sum, 2 = avg, 3 = min, 4 = max
	oidtype x = aprfn(cxt->env, a_getobjectelem(tpl, 0, FALSE));
	int dt = a_datatype(x),
		  res;

	if (dt == INTEGERTYPE || dt == REALTYPE || dt == COMPLEXTYPE) res =  x;
	else if (dt == NMATYPE) 
		switch(a_getintelem(tpl, 1, FALSE)) {
			case 1: res = nma_sumfn(cxt->env, x); break;
			case 2: res = nma_avgfn(cxt->env, x); break;
			case 3: res = nma_minfn(cxt->env, x); break;
			case 4: res = nma_maxfn(cxt->env, x); break;
			default: return;
	}
	
	a_setobjectelem(tpl, 2, res, FALSE);
	a_emit(cxt, tpl, FALSE);
}

////////////////////// VECTOR SUM

void nmacellu_IIvsum(struct nmacell* dx, struct nmacell* dy)
{	
	int *dxcont = dr(dx->s, numarraycell)->cont,
		  *dycont = dr(dy->s, numarraycell)->cont;

	do dxcont[nmacell_yiter2xsi(dx, dy)] += dycont[nmacell_iter2si(dy)];
	while (nmacell_iter_next(dy) > 0);
}

void nmacellu_DIvsum(struct nmacell* dx, struct nmacell* dy)
{	
	double *dxcont = (double*)dr(dx->s, numarraycell)->cont;
  int *dycont = dr(dy->s, numarraycell)->cont;

	do dxcont[nmacell_yiter2xsi(dx, dy)] += dycont[nmacell_iter2si(dy)];
	while (nmacell_iter_next(dy) > 0);
}

void nmacellu_DDvsum(struct nmacell* dx, struct nmacell* dy)
{	
	double *dxcont = (double*)dr(dx->s, numarraycell)->cont,
		     *dycont = (double*)dr(dy->s, numarraycell)->cont;

	do dxcont[nmacell_yiter2xsi(dx, dy)] += dycont[nmacell_iter2si(dy)];
	while (nmacell_iter_next(dy) > 0);
}

oidtype nmau_vsumfn(bindtype env, oidtype x, oidtype y)
{ // ALisp (unsafe): update X += Y elementwise, return T on success
	// assumes both X and Y are resident NMAs, 
	// checks if they are of same shape and element type of X includes that of Y
	struct nmacell *dx = dr(x, nmacell),
		             *dy = dr(y, nmacell);

	if (dx->kind < dy->kind || nmacell_compareDims(dx, dy) != 0) return nil; 	
  nmacell_iter_reset(dy);
	switch (dx->kind) {
		case 0: 
			nmacellu_IIvsum(dx, dy);			
			break;
		case 1: 
			if(dy->kind == 0) nmacellu_DIvsum(dx, dy);
			else nmacellu_DDvsum(dx, dy);
			break;		
		default: return nil; // X kind not supported
	}
	return t;
}

oidtype nma_vsumfn(bindtype env, oidtype x, oidtype y)
{ // ALisp (unsafe): return X + Y elementwise
	// assumes both X and Y are resident NMAs, 
	// checks if they are of same shape and element type of X includes that of Y
	oidtype res = nma_copy(x);

	if (nmau_vsumfn(env, res, y)==t) return res;
	else return nil;
}

//////////////////// SCALAR MULTIPLICATION

void nmacellu_scaleII(struct nmacell* dx, int s)
{
	int *dxcont = dr(dx->s, numarraycell)->cont;

	nmacell_iter_reset(dx);
	do dxcont[nmacell_iter2si(dx)] *= s;
	while (nmacell_iter_next(dx));
}

void nmacellu_scaleID(struct nmacell* dx, double s)
{
	int *dxcont = dr(dx->s, numarraycell)->cont;

	nmacell_iter_reset(dx);
	do dxcont[nmacell_iter2si(dx)] = a_roundi(s * dxcont[nmacell_iter2si(dx)]);
	while (nmacell_iter_next(dx));
}

void nmacellu_scaleDD(struct nmacell* dx, double s)
{
	double *dxcont = (double*)dr(dx->s, numarraycell)->cont;

	nmacell_iter_reset(dx);
	do dxcont[nmacell_iter2si(dx)] *= s;
	while (nmacell_iter_next(dx));
}

oidtype nmau_scalefn(bindtype env, oidtype x, oidtype s) 
{ // ALisp: update X *= S, return X on success
	struct nmacell *dx = dr(x, nmacell);

	OfType(x, NMATYPE, env);

	switch (a_datatype(s)) {
		case INTEGERTYPE:
			switch (dx->kind) {
			case 0: 
				nmacellu_scaleII(dx, getinteger(s));
				return x;
			case 1:
				nmacellu_scaleDD(dx, 1.0 * getinteger(s));
				return x;
			default:
				return nil; //element type not supported
			}
		case REALTYPE:
			switch (dx->kind) {
			case 0:
				nmacellu_scaleID(dx, getreal(s));
				return x;
			case 1:
				nmacellu_scaleDD(dx, getreal(s));
				return x;
			default:
				return nil; //element type not supported;
			}
			default:
				return nil; //factor is not a number
	}
}

oidtype nma_scalefn(bindtype env, oidtype x, oidtype s) 
{ // ALisp: return X * S
	return nmau_scalefn(env, nma_copy(x), s);
}

////////////////// ROUNDING

oidtype nmau_roundtofn(bindtype env, oidtype x, oidtype digits)
{ // ALisp: update X, round all elements to DIGITS precision
  struct nmacell* dx = dr(x, nmacell);
	int ddigits, i;
	double scale = 1.0;
	double *dcont;

	OfType(x, NMATYPE, env);
	OfType(digits, INTEGERTYPE, env);

	ddigits = getinteger(digits);
	if (digits < 0) return nil; // negative digits to round
	if (dx->kind == 0) return x; // integer array is always valid result of any round operation

	for (i=0; i<ddigits; i++) scale *= 10.0;
	nmacell_iter_reset(dx);			

	switch (dx->kind) {
		case 1: 			
			dcont = (double*)dr(dx->s, numarraycell)->cont;
			do {
				i = nmacell_iter2si(dx);
				dcont[i] = a_round(dcont[i] * scale) / scale;
			} while (nmacell_iter_next(dx));
			return x;
		default:
			return nil; //ellement type not supported
	}
}

oidtype nma_roundtofn(bindtype env, oidtype x, oidtype digits)
{ // ALisp: round all elements to DIGITS precision
	return nmau_roundtofn(env, nma_copy(x), digits);
}

oidtype nma_roundfn(bindtype env, oidtype x)
{ // ALisp: return integer array consisting of rounded elements of X	
	oidtype res;
	struct nmacell *dx, *dres;
	double *dcont;
	int *icont;

	OfType(x, NMATYPE, env);
	if (dr(x, nmacell)->kind == 0) return x; // an integer array is valid result

	res = nma_allocate(x, 0);
	dres = dr(res, nmacell);
	icont = (int*)dr(dres->s, numarraycell)->cont;
	dx = dr(x, nmacell);

	nmacell_iter_reset(dres);
	switch (dx->kind) {
		case 1: 			
			dcont = (double*)dr(dx->s, numarraycell)->cont;
			do icont[nmacell_iter2si(dres)] = a_roundi(dcont[nmacell_yiter2xsi(dx, dres)]);
			while (nmacell_iter_next(dres));
			return res;
		default:
			return nil; //ellement type not supported
	}
}



//////////////// AGGREGATE SUM & AVG 
	
struct NMASumCntMapperData {
	int newKind, cnt;
	double d;
	oidtype o;
};

oidtype nma_sum_cnt_mapper(a_callcontext cxt, int width, oidtype res[], void *xa) 
{ 
	struct NMASumCntMapperData *data = (struct NMASumCntMapperData*)xa;
	int dt = a_datatype(res[0]);

	if (dt == NMATYPE) {
		if (!data->cnt) { //if first value in bag
			a_let(data->o, nma_allocate(res[0], data->newKind)); //create resulting array
			nmacell_fill_rec(cxt->env, dr(data->o, nmacell), mkinteger(0), 0); //initialize with 0
		}
		if (data->o != nil) {
			nmau_vsumfn(cxt->env, data->o, res[0]); // sum up the elements
			data->cnt++;
		}
	} else if (dt == INTEGERTYPE && data->o == nil) {
		data->d += getinteger(res[0]);
		data->cnt++;
	} else if (dt == REALTYPE && data->o == nil) {					
		data->d += getreal(res[0]);
		data->cnt++;
	}
	return nil;
}

oidtype nma_sum_cnt(a_callcontext cxt, int newKind)
{ // return (sum . count) of a bag of numbers or resident NMAs (elementwise)
	oidtype res;
	struct NMASumCntMapperData data;

	data.newKind = newKind;
	data.cnt = 0;
	data.d = 0;
	data.o = nil;
	a_mapbag(cxt, a_arg(cxt,1), nma_sum_cnt_mapper, (void*)&data);

	if (!data.cnt) return nil; //no valid values found
	else if (data.o == nil) return cons(mkreal(data.d), mkinteger(data.cnt)); // numeric sum
	else { // array sum
		res = cons(data.o, mkinteger(data.cnt));
		a_free(data.o);
		return res;
	}
}

oidtype rdf_sumBF(a_callcontext cxt)
{ // Amos: aggregate sum of a bag of numbers or resident NMAs (elementwise)
	// result type is dictated by first value in bag, REAL for single numbers
	oidtype sum_cnt = nma_sum_cnt(cxt, -1);

	if (sum_cnt != nil) {
		a_bind(cxt, 2, hd(sum_cnt));  //TODO: maybe should free sum_cnt
	  a_result(cxt);
	}
	return nil;
}

oidtype rdf_avgBF(a_callcontext cxt)
{ // Amos: aggregate average of a bag of numbers or resident NMAs (elementwise)
	// result type is dictated by first value in bag: either REAL or REAL NMA
	oidtype sum_cnt = nma_sum_cnt(cxt, 1), sum;		      
	int cnt;

	if (sum_cnt != nil) {
		sum = hd(sum_cnt);
		cnt = getinteger(tl(sum_cnt)); // >0
		if (a_datatype(sum) == NMATYPE) {
			nmacellu_scaleDD(dr(sum, nmacell), 1.0 / cnt);
			a_bind(cxt, 2, sum);
		} else a_bind(cxt, 2, mkreal(getreal(sum) / cnt));
	  a_result(cxt);
	}
	return nil;
}

//////////////////////////

void register_nma_fns(void)
{
	extfunction1("nma-sum", nma_sumfn);
	extfunction1("nma-avg", nma_sumfn);
	extfunction1("nma-min", nma_minfn);
	extfunction1("nma-max", nma_maxfn);
	a_extfunction("nma-count-+", nma_count_bf);
	a_extfunction("nma-aggregate--+", nma_aggregate_bbf);

	extfunction2("nmau-vsum", nmau_vsumfn);
	extfunction2("nma-vsum", nma_vsumfn);
	extfunction2("nmau-scale", nmau_scalefn);
	extfunction2("nma-scale", nma_scalefn);
	extfunction2("nmau-roundto", nmau_roundtofn);
	extfunction2("nma-roundto", nma_roundtofn);
	extfunction2("nma-round", nma_roundfn);

	a_extimpl("rdf-sum-+", rdf_sumBF);
	a_extimpl("rdf-avg-+", rdf_avgBF);
}