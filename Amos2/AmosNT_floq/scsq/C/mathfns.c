#include "amos.h"
#include <stdio.h>
#include <math.h>

double euclid(double fx, double fy, double tx, double ty) {
	return sqrt((fx-tx)*(fx-tx) + (fy-ty)*(fy-ty));
}

void a_cosched_e(a_callcontext cxt, a_tuple tpl) {
	double fx1, fy1, tx1, ty1, fx2, fy2, tx2, ty2, ret;
	oidtype v1, v2;

	v1 = a_getobjectelem(tpl,0,FALSE);
	v2 = a_getobjectelem(tpl,1,FALSE);
	fx1 = getreal(a_elt(v1,2));
	fy1 = getreal(a_elt(v1,3));
	tx1 = getreal(a_elt(v1,4));
	ty1 = getreal(a_elt(v1,5));

	fx2 = getreal(a_elt(v2,2));
	fy2 = getreal(a_elt(v2,3));
	tx2 = getreal(a_elt(v2,4));
	ty2 = getreal(a_elt(v2,5));

	ret = (euclid(fx1,fy1, fx2, fy2) + euclid(tx1,ty1,tx2,ty2)) /
	  euclid(fx1,fy1,tx1,ty1);

	a_setdoubleelem(tpl, 2, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

void register_mathfns() {
	a_extfunction("COSCHED_E", a_cosched_e);
}
