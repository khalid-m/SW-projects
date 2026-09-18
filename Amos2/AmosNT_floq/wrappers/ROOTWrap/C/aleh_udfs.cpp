/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Ruslan Fomkin
 * $RCSfile: aleh_udfs.cpp,v $
 * $Revision: 1.26 $ $Date: 2011/01/18 13:13:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description:
 *	Numerical UDFs from ALEH queries.
 ****************************************************************************
 * $Log: aleh_udfs.cpp,v $
 * Revision 1.26  2011/01/18 13:13:37  andan342
 * Fixed mapper functions according to new conventions
 *
 * Revision 1.25  2009/03/06 09:58:19  torer
 * son, cos, tan, atan, exp, ln defined
 *
 * Revision 1.24  2009/03/06 07:53:52  torer
 * ceiling and round to C
 *
 * Revision 1.23  2009/03/05 21:19:46  torer
 * FLOOR removed
 *
 * Revision 1.22  2008/05/28 13:09:02  ruslan
 * bug is fixed
 *
 * Revision 1.21  2008/03/10 15:57:38  ruslan
 * not_in on vector checks that input is a vector
 *
 * Revision 1.20  2008/02/18 14:30:46  ruslan
 * effectivemass and mod over x, y values in addition to vector implementation
 *
 * Revision 1.19  2008/02/16 08:51:55  ruslan
 * not in over tuple. it is not used because it does not improve performance event worse
 *
 * Revision 1.18  2008/02/15 12:01:00  ruslan
 * not in operator is implemented
 *
 * Revision 1.17  2008/02/13 15:53:58  ruslan
 * sum over bag of tuples
 *
 * Revision 1.16  2008/02/07 10:47:31  ruslan
 * fixing a bug in general implementation of minagg2. minagg4 with arity 4
 *
 * Revision 1.15  2008/02/01 15:02:09  ruslan
 * variable arity plus of vectors
 *
 * Revision 1.14  2008/01/23 14:06:07  ruslan
 * fixing bug with SUM: correct deleting temp data
 *
 * Revision 1.13  2008/01/23 13:47:25  ruslan
 * bug in SUM is corrected that no vector is returned when input bag is empty
 *
 * Revision 1.12  2008/01/15 13:07:14  ruslan
 * using context for storing currrent optimal tuple in minagg2
 *
 * Revision 1.11  2008/01/15 08:19:43  ruslan
 * unwind protect is removed by changing the order of emitting and freeing memory
 *
 * Revision 1.10  2008/01/14 19:07:59  torer
 * catching cut aggregation
 *
 * Revision 1.9  2008/01/14 11:37:32  ruslan
 * correct use of setf. memory leaking still persist
 *
 * Revision 1.8  2008/01/13 13:37:30  ruslan
 * small bug
 *
 * Revision 1.7  2008/01/13 13:30:29  ruslan
 * bug in minagg with memory leak is fixed. Amos is still leaking.
 *
 * Revision 1.6  2007/11/24 08:57:59  ruslan
 * notany and some in C
 *
 * Revision 1.5  2007/11/16 14:03:08  ruslan
 * vector.in in C for performance
 *
 * Revision 1.4  2007/11/16 11:54:54  ruslan
 * mathematical definition of round for projects using ROOTwrapper
 *
 * Revision 1.3  2007/11/11 11:15:53  ruslan
 * bug with empty bag in minagg2 is fixed
 *
 * Revision 1.2  2007/11/11 09:47:05  ruslan
 * aleh aggregates are implemented in C
 *
 * Revision 1.1  2007/11/10 08:12:04  ruslan
 * missing file
 *
****************************************************************************/

#include "aleh_udfs.h"

const double Pi= 3.14159265358979;

oidtype vector_plusbbf(a_callcontext cxt)
{
	oidtype x;
	int arity = a_arity(cxt);
	oidtype v = a_arg(cxt,1);
	int vsize = a_arraysize(v);
	bool realflg = false;
	int* isum = new int[vsize];
	double* rsum = new double[vsize];

	for (int i=0; i < vsize; i++) {
		x = a_elt(v,i);
		if (integerp(x)) {
			isum[i] = getinteger(x);
			rsum[i] = 0.0;
		} else {
			isum[i] = 0;
			rsum[i] = coerce_real(varstack, x);
			realflg = true;
		}
	}

	for (int j=2; j < arity; j++) {
		v=a_arg(cxt,j);
		if (vsize != a_arraysize(v)) {
			delete[] isum;
			delete[] rsum;
			return nil;
		}
		for (int i=0; i < vsize; i++) {
			x = a_elt(v,i);
			if (integerp(x))
				isum[i] = isum[i] + getinteger(x);
			else {
				rsum[i] = rsum[i] + coerce_real(varstack, x);
				realflg = true;
			}
		}
	}

	x = new_array(vsize,nil);
	if (realflg)
		for (int i=0; i<vsize; i++)
			a_seta(x,i,mkreal(rsum[i] + isum[i]));
	else 
		for (int i=0; i<vsize; i++)
			a_seta(x,i,mkinteger(isum[i]));
	delete[] rsum;
	delete[] isum;
	a_bind(cxt,arity,x);
	a_result(cxt);

	return nil;
}

oidtype vector_plusbfb(a_callcontext cxt)
{
	oidtype v1 = a_arg(cxt,1);
	oidtype res = a_arg(cxt,3);
	oidtype v2, x, y, z;
	int vsize = a_arraysize(v1);
	if (vsize != a_arraysize(res))
		return nil;
	v2 = new_array(vsize,nil);
	for (int i=0; i<vsize; i++) {
		x = a_elt(v1,i);
		z = a_elt(res,i);
		if(integerp(x) && integerp(z))
			y = mkinteger(getinteger(z)-getinteger(x));
		else y = mkreal(coerce_real(varstack,z)-coerce_real(varstack,x));
		a_seta(v2,i,y);
	}
	a_bind(cxt,2,v2);
	a_result(cxt);
	return nil;
}

struct sumvclosure
{
  int* isum;
  double* dsum;
  int realflg;
  int size;
};

oidtype vector_sum_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct sumvclosure *svc;
	oidtype v = restpl[0];
	oidtype x;

	svc = (struct sumvclosure *)xa;

	if (svc->size) {
		if (a_arraysize(v) != svc->size) {
			a_error(ARG_NOT_NUMBER,v,FALSE);
			return nil;
		}
		for (int i=0; i<svc->size; i++) {
			x = a_elt(v,i);
			if (integerp(x))
				svc->isum[i] = svc->isum[i] + getinteger(x);
			else
				if (realp(x)) {
					svc->dsum[i] = svc->dsum[i] + getreal(x);
					svc->realflg = TRUE;
				} else {
					a_error(ARG_NOT_NUMBER,x,FALSE);
					return nil;
				}
		}
	} else {
		svc->size = a_arraysize(v);
		svc->isum = new int[svc->size];
		svc->dsum = new double[svc->size];
		for (int i=0; i<svc->size; i++) {
			x = a_elt(v,i);
			if (integerp(x)) {
				svc->isum[i] = getinteger(x);
				svc->dsum[i] = 0;
			} else
				if (realp(x)) {
					svc->dsum[i] = getreal(x);
					svc->isum[i] = 0;
					svc->realflg = TRUE;
				} else {
					a_error(ARG_NOT_NUMBER,x,FALSE);
					return nil;
				}
		}
	}
	return nil; //Added by Andrej
}

oidtype vector_sum(a_callcontext cxt)
{
	struct sumvclosure svc;
	oidtype bag = a_arg(cxt,1);
	svc.size = FALSE;
	svc.realflg = FALSE;
	oidtype res;
	
	a_mapbag(cxt,bag,vector_sum_mapper, (void *)&svc);
	if (svc.size) {
		res = new_array(svc.size,nil);
		if (svc.realflg)
			for (int i=0; i<svc.size; i++)
				a_seta(res,i,mkreal(svc.dsum[i] + svc.isum[i]));
		else 
			for (int i=0; i<svc.size; i++)
				a_seta(res,i,mkinteger(svc.isum[i]));
		delete[] svc.dsum;
		delete[] svc.isum;
		a_bind(cxt,2,res);
		a_result(cxt);
	}
	return nil;
}

oidtype tuple_sum_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct sumvclosure *svc;
	oidtype x;
	
	svc = (struct sumvclosure *)xa;
	
	if (svc->size) {
		for (int i=0; i<arity; i++) {
			x = restpl[i];
			if (integerp(x))
				svc->isum[i] = svc->isum[i] + getinteger(x);
			else
				if (realp(x)) {
					svc->dsum[i] = svc->dsum[i] + getreal(x);
					svc->realflg = TRUE;
				} else {
					a_error(ARG_NOT_NUMBER,x,FALSE);
					return nil;
				}
		}
	} else {
		svc->size = arity;
		svc->isum = new int[arity];
		svc->dsum = new double[arity];
		for (int i=0; i<arity; i++) {
			x = restpl[i];
			if (integerp(x)) {
				svc->isum[i] = getinteger(x);
				svc->dsum[i] = 0;
			} else
				if (realp(x)) {
					svc->dsum[i] = getreal(x);
					svc->isum[i] = 0;
					svc->realflg = TRUE;
				} else {
					a_error(ARG_NOT_NUMBER,x,FALSE);
					return nil;
				}
		}
	}
	return nil; //Added by Andrej
}

oidtype tuple_sum(a_callcontext cxt)
{
	struct sumvclosure svc;
	oidtype bag = a_arg(cxt,1);
	svc.size = FALSE;
	svc.realflg = FALSE;
	
	a_mapbag(cxt,bag,tuple_sum_mapper, (void *)&svc);
	if (svc.size) {
		if (svc.realflg) {
			for (int i=0; i<svc.size; i++)
				a_bind(cxt,2+i,mkreal(svc.dsum[i] + svc.isum[i]));
		} else {
			for (int i=0; i<svc.size; i++)
				a_bind(cxt,2+i,mkinteger(svc.isum[i]));
		}
		delete[] svc.dsum;
		delete[] svc.isum;
		a_result(cxt);
	}
	return nil;
}

oidtype atan2bbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	double y = coerce_real(varstack,a_arg(cxt,2));
	double res;

	if (x != 0) res = atan2(y,x);
	else if (y == 0) res = 0;
	else if (y > 0) res = Pi/2;
	else res = -Pi/2;
	a_bind(cxt,3,mkreal(res));
	a_result(cxt);
	return nil;
}

int math_round(double x)
{
	if (x >= 0)
		return floor(x+0.5);
	else
		return -floor((-x)+0.5);
}

oidtype roundbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	a_bind(cxt,2,mkinteger(math_round(x)));
	a_result(cxt);
	return nil;
}

oidtype logbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	if(x>0) {
		a_bind(cxt,2,mkreal(log(x)));
		a_result(cxt);
	}
	return nil;
}

oidtype sqrtbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	if(x>=0) {
		a_bind(cxt,2,mkreal(sqrt(x)));
		a_result(cxt);
	}
	return nil;
}

double magnitude(double x, double y, double z)
{
	return sqrt(x*x+y*y+z*z);
}

double eta(double x, double y, double z)
{
	double mag = magnitude(x,y,z);
	return 0.5*log((mag+z)/(mag-z));
}

double pt(double x, double y)
{
	return sqrt(x*x+y*y);
}

oidtype magnitudebbbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	double y = coerce_real(varstack,a_arg(cxt,2));
	double z = coerce_real(varstack,a_arg(cxt,3));

	a_bind(cxt,4,mkreal(magnitude(x,y,z)));
	a_result(cxt);
	return nil;
}

oidtype ptbbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	double y = coerce_real(varstack,a_arg(cxt,2));

	a_bind(cxt,3,mkreal(pt(x,y)));
	a_result(cxt);
	return nil;
}

oidtype etabbbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	double y = coerce_real(varstack,a_arg(cxt,2));
	double z = coerce_real(varstack,a_arg(cxt,3));

	a_bind(cxt,4,mkreal(eta(x,y,z)));
	a_result(cxt);
	return nil;
}

double phi(double x, double y)
{
	return atan2(-y,-x)+Pi;
}

double phi_mpi_pi(double x)
{
	return x+ceil(-0.5-x/(2*Pi))*2*Pi;
}

double absolute_value(double x)
{
	if (x<0)
		return -x;
	else return x;
}

double effective_mass(double x1, double y1, double x2, double y2)
{
	double phi1 = phi(x1,y1);
	double phi2 = phi(x2,y2);
	return sqrt(absolute_value(2*(x1*x2+y1*y2)*(1-cos(phi_mpi_pi(phi2-phi1)))));
}

oidtype effective_massbbf(a_callcontext cxt)
{
	oidtype v1 = a_arg(cxt,1);
	oidtype v2 = a_arg(cxt,2);
	double x1 = coerce_real(varstack,a_elt(v1,0));
	double y1 = coerce_real(varstack,a_elt(v1,1));
	double x2 = coerce_real(varstack,a_elt(v2,0));
	double y2 = coerce_real(varstack,a_elt(v2,1));

	a_bind(cxt,3,mkreal(effective_mass(x1,y1,x2,y2)));
	a_result(cxt);
	return nil;
}

oidtype effective_massbbbbf(a_callcontext cxt)
{
	double x1 = coerce_real(varstack,a_arg(cxt,1));
	double y1 = coerce_real(varstack,a_arg(cxt,2));
	double x2 = coerce_real(varstack,a_arg(cxt,3));
	double y2 = coerce_real(varstack,a_arg(cxt,4));

	a_bind(cxt,5,mkreal(effective_mass(x1,y1,x2,y2)));
	a_result(cxt);
	return nil;
}

double scalar_product(oidtype v)
{
	double s = 0;
	double x;
	for(int i=0; i<a_arraysize(v); i++) {
		x = coerce_real(varstack,a_elt(v,i));
		s = s + x*x;
	}
	return s;
}

oidtype modbf(a_callcontext cxt)
{
	oidtype v = a_arg(cxt,1);
	a_bind(cxt,2,mkreal(sqrt(scalar_product(v))));
	a_result(cxt);
	return nil;
}

oidtype modbbf(a_callcontext cxt)
{
	double x = coerce_real(varstack,a_arg(cxt,1));
	double y = coerce_real(varstack,a_arg(cxt,2));
	a_bind(cxt,3,mkreal(sqrt(x*x+y*y)));
	a_result(cxt);
	return nil;
}

struct atleastclosure
{
	int fail;
	int cnt;
	int limit;
};

oidtype atleast_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct atleastclosure *cc = (struct atleastclosure *)xa;
	
	cc->cnt++;
	if(cc->cnt >= cc->limit)
    {
		cc->fail = FALSE;
		resetfn(cxt->env);
    }
	return nil;
}

oidtype atleastbb(a_callcontext cxt)
{
	struct atleastclosure cc;
	oidtype limit = a_arg(cxt, 1);
	oidtype bag = a_arg(cxt,2);
	
	cc.fail = TRUE;
	cc.cnt = 0;
	IntoInteger(limit,cc.limit,a_env(cxt));
	if (cc.limit<0) 
		return nil;
	{
		unwind_protect_begin;
		a_mapbag(cxt, bag, atleast_mapper, (void *)&cc);
		unwind_protect_catch;
		if(cc.fail) 
			return nil;
		a_result(cxt);
		return nil;
		unwind_protect_end;
	}
	return nil;
}

struct minagg2closure
{
	double minval;
	int arity;
	a_callcontext *cxt;
};

oidtype minagg2_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct minagg2closure *mac = (struct minagg2closure *)xa;
	double curval = coerce_real(varstack,restpl[0]);
	int i;

	if (curval < mac->minval) {
		mac->arity = arity;
		mac->minval = curval;
		for (i = 0; i < arity; i++)
			a_bind(*mac->cxt,i+2,restpl[i]);
	}
	return nil;
}

oidtype minagg2bf(a_callcontext cxt)
{
	struct minagg2closure mac;
	oidtype bag = a_arg(cxt,1);
	
	mac.minval = DBL_MAX;
	mac.arity = FALSE;
	mac.cxt = &cxt;
	
	a_mapbag(cxt, bag, minagg2_mapper, (void *)&mac);
	if (mac.arity)
		a_result(cxt);
	return nil;
}

oidtype vector_inbf(a_callcontext cxt)
{
	oidtype v = a_arg(cxt,1);
	for (int i=0; i < a_arraysize(v); i++) {
		a_bind(cxt,2,a_elt(v,i));
		a_result(cxt);
	}
	return nil;
}

struct existclosure
{
	int exist;
};

oidtype exist_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct existclosure *cc = (struct existclosure *)xa;
	
	cc->exist = TRUE;
	resetfn(cxt->env);	
	return nil;
}

oidtype someb(a_callcontext cxt)
{
	struct existclosure cc;
	oidtype bag = a_arg(cxt,1);
	
	cc.exist = FALSE;
	unwind_protect_begin;
	a_mapbag(cxt, bag, exist_mapper, (void *)&cc);
	{
		unwind_protect_catch;
		if(cc.exist) 
			a_result(cxt);
		return nil;
		unwind_protect_end;
	}
	return nil;
}

oidtype notanyb(a_callcontext cxt)
{
	struct existclosure cc;
	oidtype bag = a_arg(cxt,1);
	
	cc.exist = FALSE;
	unwind_protect_begin;
	a_mapbag(cxt, bag, exist_mapper, (void *)&cc);
	{
		unwind_protect_catch;
		if(cc.exist) 
			return nil;
		unwind_protect_end;
	}
	if(!cc.exist)
		a_result(cxt);
	return nil;
}

oidtype notinbb(a_callcontext cxt)
{
	oidtype x = a_arg(cxt,1);
	oidtype v = a_arg(cxt,2);
	int size;
	int not_in = TRUE;

	OfType(v,ARRAYTYPE,a_env(cxt));
	size = a_arraysize(v);

	for (int i = 0; (i<size) && not_in; i++)
		not_in = a_compare(x,a_elt(v,i));
	if (not_in)
		a_result(cxt);
	return nil;
}

oidtype tuple_notinbb(a_callcontext cxt)
{
	oidtype x = a_arg(cxt,1);
	int arity = a_arity(cxt);
	int not_in = TRUE;

	for (int i = 2; (i<=arity) && not_in; i++)
		not_in = a_compare(x,a_arg(cxt,i));
	if (not_in)
		a_result(cxt);
	return nil;
}

void register_udffns(void)
{
	a_extimpl("vector_plusbbf",vector_plusbbf);
	a_extimpl("vector_plusbfb",vector_plusbfb);
	a_extimpl("vector_sum",vector_sum);
	a_extimpl("tuple_sum",tuple_sum);
	a_extimpl("atan2bbf",atan2bbf);
	a_extimpl("roundbf",roundbf);
	a_extimpl("logbf",logbf);
	a_extimpl("sqrtbf",sqrtbf);
	a_extimpl("magnitudebbbf",magnitudebbbf);
	a_extimpl("etabbbf",etabbbf);
	a_extimpl("ptbbf",ptbbf);
	a_extimpl("effective_massbbf",effective_massbbf);
	a_extimpl("effective_massbbbbf",effective_massbbbbf);
	a_extimpl("modbf",modbf);
	a_extimpl("modbbf",modbbf);
	a_extimpl("atleastbb",atleastbb);
	a_extimpl("minagg2bf",minagg2bf);
	a_extimpl("vector_inbf",vector_inbf);
	a_extimpl("someb",someb);
	a_extimpl("notanyb",notanyb);
	a_extimpl("notinbb",notinbb);
	a_extimpl("tuple_notinbb",tuple_notinbb);
}
