/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: math_fns.c,v $
 * $Revision: 1.15 $ $Date: 2011/12/15 20:33:34 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Basic math functions
 *
 * ===========================================================================
 * $Log: math_fns.c,v $
 * Revision 1.15  2011/12/15 20:33:34  torer
 * Removed IntoDouble0
 *
 * Revision 1.14  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.13  2010/12/27 10:16:20  torer
 * C warnings removed
 *
 * Revision 1.12  2010/02/02 10:40:45  torer
 * Handling integer overflow in floor, ceiling, and round
 *
 * Revision 1.11  2009/03/06 10:56:40  torer
 * *** empty log message ***
 *
 * Revision 1.10  2009/03/06 10:55:34  torer
 * power as in SQL:99
 *
 * Revision 1.9  2006/10/16 13:07:12  torer
 * a_round(x) introduced since round(x) does not exist under Windows C
 *
 * Revision 1.8  2006/04/05 12:59:24  torer
 * New and much more elaborate documentation of ALisp.
 * Minor ALisp changes to make it follow CommonLisp more closely.
 *
 * Revision 1.7  2006/04/05 10:58:13  torer
 * Function names now follow ALisp coding conventions.
 * Added function EXP.
 *
 ****************************************************************************/

#include <callin.h>
#include <storage.h>
#include <alisp.h>
#include <math.h>

int math_err;

/*****************************************************************************
 * Return x to the power p
 *****************************************************************************/
oidtype exptfn(bindtype env, oidtype x, oidtype p) {
  double base;
  double power;
  double result;

  IntoDouble(x, base, env);
  IntoDouble(p, power, env);

  if(base==0.0 && power<0.0) return lerror(ILLEGAL_ARGUMENT, p, env);
  if(base<0.0 && !integerp(p))return lerror(ILLEGAL_ARGUMENT, p, env);
  result = pow(base, power); 
  if (integerp(x) && integerp(p) && power>0.0 
      && result<(double)INT_MAX && result > (double)INT_MIN)
    return mkinteger((int) result); 
  return mkreal(result);
}

/*****************************************************************************
 * Return e to the power p
 *****************************************************************************/
oidtype expfn(bindtype env, oidtype p)
{
  double power;

  IntoDouble(p, power, env);

  return mkreal(exp(power));
}

/*****************************************************************************
 * Return the (integer) ceiling of a real number.
 *****************************************************************************/
oidtype ceilingfn(bindtype env, oidtype oidNumber) {
  double theCeiling;

  IntoDouble(oidNumber, theCeiling, env);
  theCeiling = ceil(theCeiling);
  if((theCeiling >= INT_MAX) | (theCeiling <= INT_MIN)) return mkreal(theCeiling);

  return mkinteger((int) theCeiling);
}

/*****************************************************************************
 * Return the (integer) floor of a real number.
 *****************************************************************************/
oidtype floorfn(bindtype env, oidtype oidNumber) {
  double theFloor;

  IntoDouble(oidNumber, theFloor, env);
  theFloor = floor(theFloor);
  if((theFloor >= INT_MAX) | (theFloor <= INT_MIN)) return mkreal(theFloor);
  return mkinteger((int) theFloor);
}



/*****************************************************************************
 * Round a real number to it's nearest integer.
 *****************************************************************************/
EXPORT double a_round(double x)
{
  double num=x, cl, fl, middle;

  cl = ceil(num);
  fl = floor(num);
  middle = fl + 0.5;

  if (num < middle) {
    num = fl;
  } else if (num > middle) {
    num = cl;
  } else if (fmod(fl, 2) == 0) {
    num = fl;
  } else {
    num = cl;
  }
  return num;
}

oidtype roundfn(bindtype env, oidtype oidNumber) 
{
  double num;

  IntoDouble(oidNumber, num, env);
  if((num >= INT_MAX) | (num <= INT_MIN)) 
    {
      return mkreal(a_round(num));
    }
  return mkinteger(a_roundi(num)); 
}

/****** Trigonometric functions  ******/
/*****************************************************************************
 * Return sin of a real number- angle in radians.
 *****************************************************************************/
oidtype sinfn(bindtype env, oidtype oidNumber) {
  double angle;

  IntoDouble(oidNumber, angle, env);
  return mkreal(sin(angle));
}

/*****************************************************************************
 * Return cos of a real number.
 *****************************************************************************/
oidtype cosfn(bindtype env, oidtype oidNumber) {
  double angle;

  IntoDouble(oidNumber, angle, env);
  return mkreal(cos(angle));
}

/*****************************************************************************
 * Return tangent of a real number.
 *****************************************************************************/
oidtype tanfn(bindtype env, oidtype oidNumber) {
  double angle;

  IntoDouble(oidNumber, angle, env);
  return mkreal(tan(angle));
}

/*****************************************************************************
 * Return arcsinus of a real number.
 *****************************************************************************/
oidtype asinfn(bindtype env,oidtype arg)
{
  double     no;

  IntoDouble(arg,no,env);

  return mkreal(asin(no));
}
/*****************************************************************************
 * Return arc cosine of a real number.
 *****************************************************************************/
oidtype acosfn(bindtype env, oidtype oidNumber) {
  double cos_angle;

  IntoDouble(oidNumber, cos_angle, env);
  return mkreal(acos(cos_angle));
}

/*****************************************************************************
 * Return arc tangent of a real number.
 *****************************************************************************/
oidtype atanfn(bindtype env, oidtype oidNumber) {
  double tan_angle;

  IntoDouble(oidNumber, tan_angle, env);
  return mkreal(atan(tan_angle));
}

/*****************************************************************************
 * arctan with two arguments to identify correct sign. Definition corrsponds
 * to atan2 definition in ROOT library.
 *****************************************************************************/
oidtype atan2fn(bindtype env, oidtype oidX, oidtype oidY) {
  const double Pi= 3.14159265358979;
  double x;
  double y;

  IntoDouble(oidX, x, env);
  IntoDouble(oidY, y, env);

  if (x != 0) return  mkreal(atan2(y, x));
  if (y == 0) return  mkreal(0);
  if (y >  0) return  mkreal(Pi/2);
  else        return  mkreal(-Pi/2);
}

/*****************************************************************************
 * Return logarithm of a real number. Default base e
 *****************************************************************************/
oidtype logfn(bindtype env,oidtype arg, oidtype base)
{
  double     no;

  IntoDouble(arg,no,env);
  if(base!=nil)
  {
     double b;

     IntoDouble(base,b,env);
     return mkreal(log(no)/log(b));
  }
  else return mkreal(log(no));
}

/*****************************************************************************
 * Initialization
 *****************************************************************************/
void register_math_functions(void) {
  math_err = a_register_error("Math error.");

  extfunction1("ceiling", ceilingfn);
  extfunction1("floor", floorfn);
  extfunction1("round", roundfn);
  extfunction2("expt", exptfn);
  extfunction1("exp",expfn);
  extfunction1("sin", sinfn);
  extfunction1("cos", cosfn);
  extfunction1("tan", tanfn);
  extfunction2("atan2", atan2fn);
  extfunction1("acos", acosfn);
  extfunction1("atan", atanfn);
  extfunction1("asin", asinfn);
  extfunction2("log",logfn);
}

