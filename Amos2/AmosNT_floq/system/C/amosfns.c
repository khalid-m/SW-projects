/*****************************************************************************
 * AMOS2 
 *
 * Author: (c) 2005 Tore Risch, UDBL
 * $RCSfile: amosfns.c,v $
 * $Revision: 1.63 $ $Date: 2013/11/15 13:33:51 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Basic Amos functions 
 * ===========================================================================
 * $Log: amosfns.c,v $
 * Revision 1.63  2013/11/15 13:33:51  torer
 * Thread safe a_stringify()
 *
 * Revision 1.62  2013/11/13 18:17:39  chexu484
 * bug fix for mapVector
 *
 * Revision 1.61  2013/11/11 18:50:17  torer
 * New function realbytes(Number x)-> Integer
 * produces integer word of x without losing bits
 *
 * Revision 1.60  2013/03/11 19:15:16  torer
 * rnow() is now foreign function in C
 *
 * Revision 1.59  2013/02/16 17:36:37  torer
 * Slightly faster mod() function
 *
 * Revision 1.58  2013/02/05 21:01:31  torer
 * Illegal argument tolerant arithmetic operators
 *
 * Revision 1.57  2013/01/26 16:59:36  torer
 * Checking for integer overflow
 *
 * Revision 1.56  2012/10/12 07:24:28  torer
 * Reverted kernel C bug
 *
 * Revision 1.54  2011/12/29 20:07:37  torer
 * Correct typing of xa in mapper function
 *
 * Revision 1.53  2011/09/27 16:59:08  larme597
 * pi(), acos(), asin() amos functions.
 *
 * Revision 1.52  2011/08/25 12:31:02  thatr500
 * wrong fun call
 *
 * Revision 1.51  2011/06/23 16:04:08  thatr500
 * added powerfbb to compute a nth root of a possitive number
 *
 * Revision 1.50  2011/01/04 20:05:23  torer
 * in(Vector) as foreign function
 *
 * Revision 1.49  2010/12/29 14:29:11  torer
 * removed a_global_callcontext
 *
 * Revision 1.48  2010/12/26 17:10:29  torer
 * 1. Not using a_global_callcontext
 * 2. Mappers now return oidtype
 *
 * Revision 1.47  2010/12/26 09:51:37  torer
 * Possible memory leak fixed + Xemacs indentation
 *
 * Revision 1.46  2010/12/25 21:40:19  torer
 * (Partial) aggregate functions in C now work correctly
 * Common aggregate functions now in C
 *
 * Revision 1.45  2010/12/09 20:06:01  torer
 * revertt
 *
 * Revision 1.43  2010/12/01 19:16:31  torer
 * Using a_mapfunctionC in system functions
 *
 * Revision 1.42  2010/11/30 13:14:05  torer
 * Definition of a_global_callcontext
 *
 * Revision 1.41  2010/11/30 13:09:59  torer
 * New global C variable a_global_callcontext useful when calling a_mapfunction and no cxt available
 *
 * Revision 1.40  2010/05/07 18:43:31  torer
 * New functions:
 *   applyFunction1(Function f, Object o)->Bag of Object r
 *   mapVector(Function f, Vector v)->Vector r
 *
 * Revision 1.39  2009/12/14 22:06:52  torer
 * Equality as foreign predicate in C
 *
 * Revision 1.38  2009/11/11 15:05:11  zeitler
 * plus(Vector of Number, Number) and minus(Vector of Number, Number)
 *
 * Revision 1.37  2009/11/03 16:42:23  zeitler
 * Robust Minkowski
 *
 * Revision 1.36  2009/11/02 17:25:50  zeitler
 * Higher precision in euclid
 *
 * Revision 1.35  2009/10/03 08:23:40  torer
 * unitialized C variable. Better error messages.
 *
 * Revision 1.34  2009/10/02 20:22:16  zeitler
 * Name change:
 * avgstdev(vector)-><real,real>
 * replaced by
 * vavgstdev(vector)-><real,real>
 *
 * New function: avgstdev(bag of number)-><real,real>
 *
 * Revision 1.33  2009/10/02 18:04:28  torer
 * plus(vector,vector)->vector of number in C
 *
 * Revision 1.32  2009/09/30 15:07:44  zeitler
 * Minkowski distance metric
 *
 * Revision 1.31  2009/09/09 11:01:44  zeitler
 * Euclidean distance
 *
 * Revision 1.30  2009/03/20 12:05:31  zeitler
 * mlhash
 *
 * Revision 1.29  2009/03/06 10:55:34  torer
 * power as in SQL:99
 *
 * Revision 1.28  2009/03/06 09:58:17  torer
 * son, cos, tan, atan, exp, ln defined
 *
 * Revision 1.27  2009/03/06 07:53:50  torer
 * ceiling and round to C
 *
 * Revision 1.26  2009/03/05 20:59:08  torer
 * FLOOR in C
 *
 * Revision 1.25  2008/12/06 12:37:18  torer
 * Correct stringification of vectors
 *
 * Revision 1.24  2008/12/05 19:22:12  torer
 * Error in string equation solving
 *
 * Revision 1.23  2008/12/05 18:34:15  torer
 * plus(object,object)->Charstring implements concat
 *
 * Revision 1.22  2008/02/01 12:59:57  torer
 * Variable arity plusbbf
 *
 * Revision 1.21  2007/11/07 15:14:50  torer
 * Amos II version 10 with faster basic OjectLog interface to C
 * Aggregation operators can now be defined in C
 *
 ****************************************************************************/

#include "amos.h"
#include <float.h>
#include <stdlib.h>

//#define DEBUG

oidtype iotabbf(a_callcontext cxt)
{
  int l;
  int u;
  int i;
  oidtype lower = a_arg(cxt,1);
  oidtype upper = a_arg(cxt,2);

  IntoInteger(lower, l, varstack);
  IntoInteger(upper, u, varstack);

  for(i=l;i<=u;i++)
    {
      a_bind(cxt,3,mkinteger(i));
      a_result(cxt);
    }
  return nil;
  /* Original time:
     Amos 1> count(iota(1,1000000));
     1000000
     3.125 s
     This implementation:
     Amos 1> count(iota(1,1000000));
     1000000
     1.047 s
  */
}
/************************ Comparisons ****************************************/

oidtype nebb(a_callcontext cxt)
{
  if(a_compare(a_arg(cxt,1),a_arg(cxt,2)) != 0) a_result(cxt);
  return nil;
}

oidtype ltbb(a_callcontext cxt)
{
  if(a_compare(a_arg(cxt,1),a_arg(cxt,2)) < 0) a_result(cxt);
  return nil;
}

oidtype lebb(a_callcontext cxt)
{
  if(a_compare(a_arg(cxt,1),a_arg(cxt,2)) <= 0) a_result(cxt);
  return nil;
}

oidtype gtbb(a_callcontext cxt)
{
  if(a_compare(a_arg(cxt,1),a_arg(cxt,2)) > 0) a_result(cxt);
  return nil;
}

oidtype gebb(a_callcontext cxt)
{
  if(a_compare(a_arg(cxt,1),a_arg(cxt,2)) >= 0) a_result(cxt);
  return nil;
}

/******************************* aritmetics *********************************/

oidtype modbbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt, 1), y = a_arg(cxt, 2);

  if(integerp(x) & integerp(y))
    {
      a_bind(cxt,3,mkinteger(getinteger(x) % getinteger(y)));
      a_result(cxt);
    }
  else if(NUMERIC(a_datatype(x)) & NUMERIC(a_datatype(y)))
    {
      a_bind(cxt,3,mkreal(fmod(coerce_real(cxt->env,x),
                               coerce_real(cxt->env,y))));
      a_result(cxt);
    }
  return nil;
}

oidtype floorbf(a_callcontext cxt)
{
  extern oidtype floorfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,floorfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype ceilingbf(a_callcontext cxt)
{
  extern oidtype ceilingfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,ceilingfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype roundbf(a_callcontext cxt)
{
  extern oidtype roundfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,roundfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype realbytesbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  double dx;
  int ix;

  IntoDouble(x, dx, cxt->env);
  ix = dx;
  a_bind(cxt,2,mkinteger(ix));
  a_result(cxt);
  return nil;
}

oidtype sinbf(a_callcontext cxt)
{
  extern oidtype sinfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,sinfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype asinbf(a_callcontext cxt)
{
  extern oidtype asinfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,asinfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype cosbf(a_callcontext cxt)
{
  extern oidtype cosfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,cosfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype acosbf(a_callcontext cxt)
{
  extern oidtype acosfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,acosfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype tanbf(a_callcontext cxt)
{
  extern oidtype tanfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,tanfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype atanbf(a_callcontext cxt)
{
  extern oidtype atanfn(bindtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,2,atanfn(varstack,x));
      a_result(cxt);
    }
  return nil;
}

oidtype expbf(a_callcontext cxt)
{
  double x = coerce_real(varstack,a_arg(cxt,1));
  a_bind(cxt,2,mkreal(exp(x)));
  a_result(cxt);
  return nil;
}

oidtype lnbf(a_callcontext cxt)
{
  double x = coerce_real(varstack,a_arg(cxt,1));
  if(x>0) 
    {
      a_bind(cxt,2,mkreal(log(x)));
      a_result(cxt);
    }
  return nil;
}

oidtype powerbbf(a_callcontext cxt)
{
  extern oidtype exptfn(bindtype,oidtype,oidtype);
  oidtype x = a_arg(cxt,1);

  if(NUMERIC(a_datatype(x)))
    {
      a_bind(cxt,3,exptfn(varstack,a_arg(cxt,1),a_arg(cxt,2)));
      a_result(cxt);
    }
  return nil;
}

/*Return base given the result and power*/
oidtype powerfbb(a_callcontext cxt)
{
  double power;
  double result;
  extern oidtype exptfn(bindtype,oidtype,oidtype);
  oidtype e = a_arg(cxt,2), r = a_arg(cxt,3);

  if(NUMERIC(a_datatype(e)) & NUMERIC(a_datatype(r)))
    {
      power = coerce_real(varstack, e);
      result = coerce_real(varstack, r);
      if(power == 0.0) return nil;
      if(result < 0.0) return nil;
      a_bind(cxt,1,exptfn(varstack,a_arg(cxt, 3), mkreal(1/power)));
      a_result(cxt);
    }
  return nil;
}

/********************************* PLUS **************************************/

oidtype plusbbf(a_callcontext cxt)
     /* In Lisp: (defun plus--+ (obj x y z ...)
	(osql-result x y ...(+ x y ...))) */
{
  int i = a_arity(cxt), j, isum=0, realflg=FALSE;
  double rsum=0.0;
  oidtype x;

  for(j=1; j<i; j++)
    {
      x = a_arg(cxt, j);
      if(!NUMERIC(a_datatype(x))) return nil;
      if(!integerp(x))
	{
	  realflg = TRUE;
          rsum = rsum + coerce_real(varstack, x);
        }
      else if(PLUS_OVERFLOW(isum,getinteger(x)))
	{
          realflg = TRUE;
          rsum = rsum + getinteger(x);
        }
      else isum = isum + getinteger(x);
    }
  if(realflg) {a_bind(cxt,j,mkreal(isum+rsum))}
  else {a_bind(cxt,j,mkinteger(isum))};
  a_result(cxt);
  return nil;
}

oidtype plusbfb(a_callcontext cxt)
     /* In Lisp: (defun plusfbf (obj x y z)(osql-result x (- z x) z)) */
{
  oidtype x = a_arg(cxt,1);
  oidtype r = a_arg(cxt,3);

  if(!NUMERIC(a_datatype(x)) | !NUMERIC(a_datatype(r))) return nil;
  if(integerp(x) && integerp(r))
    {
      long i = getinteger(x), j = getinteger(r);

      if(PLUS_OVERFLOW(j,-i)) {a_bind(cxt,2,mkreal(j+0.0-i))}
      else {a_bind(cxt,2,mkinteger(j-i))};
    }
  else {a_bind(cxt,2,mkreal(coerce_real(varstack,r)-coerce_real(varstack,x)));}
  a_result(cxt);
  return nil;
}

/********************************* TIMES *************************************/

oidtype timesbbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  oidtype y = a_arg(cxt,2);

  if(!NUMERIC(a_datatype(x)) | !NUMERIC(a_datatype(y))) return nil;
  if(integerp(x) && integerp(y))
    {
      long i = getinteger(x), j = getinteger(y);

      if(TIMES_OVERFLOW(i,j))
        {a_bind(cxt,3,mkreal(i*1.0*j));}
      else {a_bind(cxt,3,mkinteger(i*j));}
    }
  else {a_bind(cxt,3,mkreal(coerce_real(varstack,x)*coerce_real(varstack,y)));}
  a_result(cxt);
  return nil;
}

oidtype timesbfb(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  oidtype r = a_arg(cxt,3);

  if(!NUMERIC(a_datatype(x)) | !NUMERIC(a_datatype(r))) return nil;
  if(integerp(x) && integerp(r))
    {
      int ix = getinteger(x), ir=getinteger(r);

      if(ix == 0) a_error(ZERO_DIVIDE, x, FALSE);
      else if(ir % ix == 0) {a_bind(cxt,2,mkinteger(ir/ix));}
      else {a_bind(cxt,2,mkreal((ir+0.0)/ix));}
    }
  else
    {
      double rx = coerce_real(varstack,x); 
    
      if(rx == 0.0) a_error(ZERO_DIVIDE, x, FALSE);
      else {a_bind(cxt,2,mkreal(coerce_real(varstack,r)/rx));}
    }
  a_result(cxt);
  return nil;
}

oidtype mlhashbbbf(a_callcontext cxt) {
  int k, d, m;
  oidtype key = a_arg(cxt, 1);
  oidtype div = a_arg(cxt, 2);
  oidtype mod = a_arg(cxt, 3);
  IntoInteger(key, k, varstack);
  IntoInteger(div, d, varstack);
  IntoInteger(mod, m, varstack);

  a_bind(cxt, 4, mkinteger((k / d) % m));
  a_result(cxt);
  return nil;
}

/************************** Scalar product ***********************************/

oidtype vectortimesbbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1), xi;
  oidtype y = a_arg(cxt,2), yi;
  int realflg = FALSE;
  double fsum = 0.0;
  int isum = 0, sx, sy, i;

  OfType(x,ARRAYTYPE,a_env(cxt));
  OfType(y,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  sy = a_arraysize(y);
  if(sx != sy) goto erry;
  for(i=0;i<sx;i++)
    {
      xi = a_elt(x, i);
      yi = a_elt(y, i);
      if(!realflg && a_datatype(xi) == REALTYPE) realflg = TRUE;
      if(!realflg && a_datatype(yi) == REALTYPE) realflg = TRUE;
      if(realflg)
	{
          fsum = fsum + coerce_real(varstack, xi) * coerce_real(varstack, yi);
        }
      else
        {
          if(a_datatype(xi) != INTEGERTYPE) goto errx;
          if(a_datatype(yi) != INTEGERTYPE) goto erry;
          isum = isum + getinteger(xi) * getinteger(yi);
        }
    }
  if(realflg)
    {
      a_bind(cxt, 3, mkreal(fsum + isum)); 
    }
  else
    {
      a_bind(cxt, 3, mkinteger(isum));
    }
  a_result(cxt);
  return nil;
 errx:
  a_error(ILLEGAL_ARGUMENT, x, FALSE); 
  return nil;
 erry:
  a_error(ILLEGAL_ARGUMENT, y, FALSE);
  return nil;
}

/************************** Vector addition **********************************/

oidtype vectorplusbbf(a_callcontext cxt) {
  oidtype x = a_arg(cxt,1), xi;
  oidtype y = a_arg(cxt,2), yi;
  oidtype res=nil;
  int i, sx, sy;

  OfType(x,ARRAYTYPE,a_env(cxt));
  OfType(y,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  sy = a_arraysize(y);
  if(sx != sy) 
    {
      a_error(ARRAY_BOUNDS, x, FALSE);
      return nil; 
    }
  res = new_array(sx,nil);
  for(i=0; i < sx; i++)
    {
      xi = a_elt(x, i);
      yi = a_elt(y, i);
      if(a_datatype(xi) == REALTYPE)
	{
          if(a_datatype(yi)==REALTYPE)
	    a_seta(res, i, mkreal(getreal(xi) + getreal(yi)));
          else if(a_datatype(yi)==INTEGERTYPE)
            a_seta(res, i, mkreal(getreal(xi) + getinteger(yi)));
          else goto erry;
        }
      else if(a_datatype(xi) == INTEGERTYPE)
        {
          if(a_datatype(yi)==REALTYPE)
	    a_seta(res, i, mkreal(getinteger(xi) + getreal(yi)));
          else if(a_datatype(yi)==INTEGERTYPE)
	    {
	      long a=getinteger(xi), b=getinteger(yi);
              
              if(PLUS_OVERFLOW(a,b))
                a_seta(res, i, mkreal(a+0.0+b));
              else a_seta(res, i, mkinteger(a + b));
            }
          else goto erry;
        }
      else goto errx;
    }
  a_bind(cxt, 3, res); 
  a_result(cxt);
  return nil;
 errx:
  release(res);
  a_error(ARG_NOT_NUMBER, x, FALSE); 
  return nil;
 erry:
  release(res);
  a_error(ARG_NOT_NUMBER, y, FALSE);
  return nil;
}

oidtype vectorplusbfb(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1), xi;
  oidtype r = a_arg(cxt,3), ri;
  oidtype res = nil;
  int i, sx, sr;

  OfType(x,ARRAYTYPE,a_env(cxt));
  OfType(r,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  sr = a_arraysize(r);
  if(sx != sr) 
    {
      a_error(ARRAY_BOUNDS, x, FALSE);
      return nil; 
    }
  res = new_array(sx,nil);
  for(i=0; i < sx; i++)
    {
      xi = a_elt(x, i);
      ri = a_elt(r, i);
      if(a_datatype(xi) == REALTYPE)
	{
          if(a_datatype(ri)==REALTYPE)
	    a_seta(res, i, mkreal(getreal(ri) - getreal(xi)));
          else if(a_datatype(ri)==INTEGERTYPE)
            a_seta(res, i, mkreal(getinteger(ri) - getreal(xi)));
          else goto errr;
        }
      else if(a_datatype(xi) == INTEGERTYPE)
        {
          if(a_datatype(ri)==REALTYPE)
	    a_seta(res, i, mkreal(getreal(ri) - getinteger(xi)));
          else if(a_datatype(ri)==INTEGERTYPE)
            {
              long a = getinteger(ri), b = getinteger(xi);
 
              if(PLUS_OVERFLOW(a,-b)) 
                a_seta(res, i, mkreal(a+0.0-b));
              else a_seta(res, i, mkinteger(a - b));
            }
          else goto errr;
        }
      else goto errx;
    }
  a_bind(cxt, 2, res); 
  a_result(cxt);
  return nil;
 errx:
  release(res);
  a_error(ARG_NOT_NUMBER, x, FALSE); 
  return nil;
 errr:
  release(res);
  a_error(ARG_NOT_NUMBER, r, FALSE);
  return nil;
}

/************************** Vector-Number addition ***************************/

oidtype vectornumplusbbf(a_callcontext cxt) 
{
  oidtype x = a_arg(cxt, 1), xi;
  oidtype y = a_arg(cxt, 2);
  oidtype res=nil;
  int i, sx;

  OfType(x,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  res = new_array(sx, nil);
  if (a_datatype(y) == REALTYPE) 
    {
      double yv = getreal(y);
      for(i=0; i < sx; i++) 
	{
	  xi = a_elt(x, i);
	  if(a_datatype(xi) == REALTYPE)
	    a_seta(res, i, mkreal(getreal(xi) + yv));
	  else if(a_datatype(xi) == INTEGERTYPE)
	    a_seta(res, i, mkreal(getinteger(xi) + yv));
	  else goto errx;
	}
    } 
  else if (a_datatype(y) == INTEGERTYPE) 
    {
      int yv = getinteger(y);
      for(i=0; i < sx; i++) 
	{
	  xi = a_elt(x, i);
	  if(a_datatype(xi) == REALTYPE)
	    a_seta(res, i, mkreal(getreal(xi) + yv));
	  else if(a_datatype(xi) == INTEGERTYPE)
	    {
              long a = getinteger(xi);
            
	      if(PLUS_OVERFLOW(a,yv)) a_seta(res, i, mkreal(a+0.0+yv));
	      else a_seta(res, i, mkinteger(a + yv));
            }
	  else goto errx;
	}
    } 
  else goto erry;
  a_bind(cxt, 3, res); 
  a_result(cxt);
  return nil;
 errx:
  release(res);
  a_error(ARG_NOT_NUMBER, x, FALSE); 
  return nil;
 erry:
  release(res);
  a_error(ARG_NOT_NUMBER, y, FALSE);
  return nil;
}

oidtype vectornumplusfbb(a_callcontext cxt) 
{
  oidtype y = a_arg(cxt, 2);
  oidtype x = a_arg(cxt, 3), xi;
  oidtype res=nil;
  int i, sx;

  OfType(x,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  res = new_array(sx, nil);
  if (a_datatype(y) == REALTYPE) 
    {
      double yv = getreal(y);
      for(i=0; i < sx; i++) 
	{
	  xi = a_elt(x, i);
	  if(a_datatype(xi) == REALTYPE)
	    a_seta(res, i, mkreal(getreal(xi) - yv));
	  else if(a_datatype(xi) == INTEGERTYPE)
	    a_seta(res, i, mkreal(getinteger(xi) - yv));
	  else goto errx;
	}
    } 
  else if (a_datatype(y) == INTEGERTYPE) 
    {
      int yv = getinteger(y);
      for(i=0; i < sx; i++) 
	{
	  xi = a_elt(x, i);
	  if(a_datatype(xi) == REALTYPE)
	    a_seta(res, i, mkreal(getreal(xi) - yv));
	  else if(a_datatype(xi) == INTEGERTYPE)
	    {
	      long a = getinteger(xi);
 
	      if(PLUS_OVERFLOW(a,-yv)) 
		a_seta(res, i, mkreal(a+0.0-yv));
	      else a_seta(res, i, mkinteger(a - yv));
	    }
	  else goto errx;
	}
    } 
  else goto erry;
  a_bind(cxt, 1, res); 
  a_result(cxt);
  return nil;
 errx:
  release(res);
  a_error(ARG_NOT_NUMBER, x, FALSE); 
  return nil;
 erry:
  release(res);
  a_error(ARG_NOT_NUMBER, y, FALSE);
  return nil;
}

oidtype vectornumplusbfb(a_callcontext cxt) 
{
  oidtype x = a_arg(cxt,1), xi;
  oidtype r = a_arg(cxt,3), ri;
  oidtype res = nil, pres = nil;
  int i, sx, sr;

  OfType(x,ARRAYTYPE,a_env(cxt));
  OfType(r,ARRAYTYPE,a_env(cxt));

  sx = a_arraysize(x);
  sr = a_arraysize(r);
  if (sx != sr) 
    {
      a_error(ARRAY_BOUNDS, x, FALSE);
      return nil; 
    }
  for (i=0; i < sx; i++) 
    {
      a_setf(pres, res);
      xi = a_elt(x, i);
      ri = a_elt(r, i);
      if (a_datatype(xi) == REALTYPE) 
	{
	  if (a_datatype(ri)==REALTYPE) 
	    {
	      a_setf(res, mkreal(getreal(ri) - getreal(xi)));
	    } 
	  else if (a_datatype(ri)==INTEGERTYPE) 
	    {
	      a_setf(res, mkreal(getinteger(ri) - getreal(xi)));
	    } 
	  else goto errr;
	} 
      else if (a_datatype(xi) == INTEGERTYPE) 
	{
	  if (a_datatype(ri)==REALTYPE) 
	    {
	      a_setf(res, mkreal(getreal(ri) - getinteger(xi)));
	    } 
	  else if (a_datatype(ri)==INTEGERTYPE) 
	    {
              long a = getinteger(ri), b = getinteger(xi);

              if(PLUS_OVERFLOW(a, -b))
		{a_setf(res, mkreal(a+0.0-b));}
	      else {a_setf(res, mkinteger(a - b));}
	    } 
	  else goto errr;
	}
      else goto errx;
      if (pres == nil) // First time
	a_setf(pres, res);
      if (a_compare(res, pres) != 0) 
	{ // res must be the same for all i
	  release(res);
	  release(pres);
	  return nil;
	}
    }
  a_bind(cxt, 2, res); 
  a_result(cxt);
  return nil;
 errx:
  release(res);
  a_error(ARG_NOT_NUMBER, x, FALSE); 
  return nil;
 errr:
  release(res);
  a_error(ARG_NOT_NUMBER, r, FALSE);
  return nil;
}

/************************* Distance measures *********************************/

int ddesc(const void* x, const void* y) {
  // Compare double numbers, to qsort them in descending order
  return ((*(double*)x > *(double*)y) ? 
	  -1 :
	  (*(double*)x < *(double*)y) ? 
	  1 : 0);
}

oidtype euclidbbf(a_callcontext cxt) {
  oidtype v = nil, w = nil;
  double* diffv;
  int i, dim;

  v = a_arg(cxt, 1);
  w = a_arg(cxt, 2);
  dim = a_arraysize(v);

  if (dim != a_arraysize(w)) {
    a_error(VDIM_DISAGREE, a_list(v, w, NULL), FALSE);
  }

  diffv = (double*)malloc(dim * sizeof(double));
  for (i = 0; i < dim; i++) {
    diffv[i] = fabs(coerce_real(cxt->env, a_elt(v, i)) -
		    coerce_real(cxt->env, a_elt(w, i)));
  }
  // Sorting is important for the scaling below
  qsort(diffv, dim, sizeof(double), &ddesc);

#ifdef DEBUG
  for (i = 0; i < dim; i++) {
    printf("%f ", diffv[i]);
  }
  printf("\n");
#endif

  if (diffv[1] == 0.) { // Trivial case: zero diff in all dim > 0
    a_bind(cxt, 3, mkreal(diffv[0]));
  } else {
    double sum2 = 0.0;
    for (i = dim - 1; i > 0; i--) {
      // Scale the numbers to a ratio using the biggest difference
      diffv[i] = diffv[i] / diffv[0];
      // Run loop backwards: 
      // Add smallest values first to minimize machine rounding error
      sum2 += diffv[i] * diffv[i];
    }
    a_bind(cxt, 3, mkreal(diffv[0] * sqrt(1 + sum2)));
  }
  free(diffv); // must come before a_result since a_result may fail
  a_result(cxt);
  return nil;
}

oidtype minkowskibbbf(a_callcontext cxt) {
  oidtype v = nil, w = nil;
  double x, y, r;
  int i, dim;

  v = a_arg(cxt, 1);
  w = a_arg(cxt, 2);
  r = coerce_real(cxt->env, a_arg(cxt, 3));
  dim = a_arraysize(v);

  if (dim != a_arraysize(w)) {
    a_error(VDIM_DISAGREE, a_list(v, w, NULL), FALSE);
  }

  if (u_is_pos_inf(r)) {
    double max = 0.0;
    for (i = 0; i < dim; i++) {
      x = coerce_real(cxt->env, a_elt(v, i));
      y = coerce_real(cxt->env, a_elt(w, i));
      max = max(fabs(y - x), max);
    }
    a_bind(cxt, 4, mkreal(max));
  } else {
    double* diffv;
    diffv = (double*)malloc(dim * sizeof(double));
    for (i = 0; i < dim; i++) {
      diffv[i] = fabs(coerce_real(cxt->env, a_elt(v, i)) -
		      coerce_real(cxt->env, a_elt(w, i)));
    }
    qsort(diffv, dim, sizeof(double), &ddesc);

    if (diffv[1] == 0.) {
      a_bind(cxt, 4, mkreal(diffv[0]));
    } else {
      double sum2 = 0.0;
      for (i = dim - 1; i > 0; i--) {
	diffv[i] = diffv[i] / diffv[0];
	sum2 += pow(diffv[i], r);
      }
      a_bind(cxt, 4, mkreal(diffv[0] * pow(1 + sum2, 1/r)));
    }
    free(diffv);
  }
  a_result(cxt);
  return nil;
}

oidtype maxnormbbf(a_callcontext cxt) {
  oidtype v = nil, w = nil;
  double max = 0.0, x, y;
  int i, dim;

  v = a_arg(cxt, 1);
  w = a_arg(cxt, 2);
  dim = a_arraysize(v);

  if (dim != a_arraysize(w)) {
    a_error(VDIM_DISAGREE, a_list(v, w, NULL), FALSE);
  }

  for (i = 0; i < dim; i++) {
    x = coerce_real(cxt->env, a_elt(v, i));
    y = coerce_real(cxt->env, a_elt(w, i));
    max = max(max, fabs(y - x));
  }

  a_bind(cxt, 3, mkreal(max));
  a_result(cxt);
  return nil;
}

/******************************** ABS ****************************************/

oidtype absbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);

  if(integerp(x))
    {
      int ix = getinteger(x);

      if(ix < 0) {a_bind(cxt,2,mkinteger(-ix));}
      else {a_bind(cxt,2,x);}
    }
  else 
    {
      double rx = coerce_real(varstack, x);

      if(rx < 0) {a_bind(cxt,2,mkreal(-rx));}
      else {a_bind(cxt,2,x);}
    }
  a_result(cxt);
  return nil;
}

/**************************   type checking     ******************************/

oidtype typecheckersymbol; /* Symbol TYPE-CHECKER */
extern oidtype matchargfn(bindtype,oidtype,oidtype);

oidtype typesofbb(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  oidtype y = a_arg(cxt,2);
  oidtype tc = getobjectfn(cxt->env, y, typecheckersymbol);

  if(tc!=nil)
    {
      oidtype res;

      res = call_lisp(tc, varstack, 2, x, y);

      if(res != nil)
	{
          release(res);
          a_result(cxt);
        }
      return nil;
    }
  if(matchargfn(varstack, x, y)!=nil)
    a_result(cxt);
  return nil;
}

/**************************   vector access     ******************************/

oidtype vrefbbf(a_callcontext cxt)
{
  oidtype a = a_arg(cxt,1);
  oidtype ind = a_arg(cxt,2);
  int i, arity = a_arraysize(a);

  IntoInteger(ind, i, a_env(cxt));

  if((i<arity) & (i>=0))
    {
      a_bind(cxt,3,a_elt(a,i));
      a_result(cxt);
    }
  return nil;
}

oidtype vrefbff(a_callcontext cxt)
     /*
       (defun vref-++ (obj a ind val)
       (let ((s (array-total-size a)) v)
       (dotimes (i s)
       (setq v (aref a i))
       (if v (osql-result a i v)))))
     */
{
  oidtype a = a_arg(cxt,1), v;
  int s = a_arraysize(a), i;

  for(i=0; i<s; i++)
    {
      v = a_elt(a,i);
      if(v!=nil) 
	{
	  a_bind(cxt, 2, mkinteger(i));
	  a_bind(cxt, 3, v);
	  a_result(cxt); 
	}
    }
  return nil;
}

oidtype construct_vectorC(a_callcontext cxt)
{
  int arity = a_arity(cxt), i;
  oidtype v = a_arg(cxt, 1);
  
  if(v == starsymbol) 
    {
      oidtype newarr = new_array(arity-1,nil);

      for(i=1; i<arity; i++)
	{
          oidtype e = a_arg(cxt,i+1);

          if(e!=starsymbol) a_seta(newarr, i-1, e); 
        }
      a_bind(cxt, 1, newarr);
      a_result(cxt);
    }
  else
    {
      if(a_arraysize(v)==arity-1)
	{
	  for(i=1; i<arity; i++)
	    {a_bind(cxt, i+1, a_elt(v,i-1));}
	  a_result(cxt);
	}
    }
  return nil;
}

oidtype vector_inBF(a_callcontext cxt)
{
  oidtype v = a_arg(cxt, 1), x;
  int arity = a_arity(cxt);
  int dim, dim2, i, j;
 
  if(!arrayp(v)) return nil;
  dim = a_arraysize(v);
  for(i=0;i<dim;i++)
    {
      x = a_elt(v,i); 
      if(x!=nil)
	{ 
	  if(arity>2) 
	    {
	      if(arrayp(x))
		{
		  dim2 = a_arraysize(x);
		  for(j=0;j<dim2;j++) a_bind(cxt,2+j, a_elt(x,j));
		}
	    }
	  else a_bind(cxt,2,x);
	  a_result(cxt);
	}
    }
  return nil;
}

/**************************   strings           ******************************/

oidtype concatbbf(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  oidtype y = a_arg(cxt,2);
  oidtype res;
  char *sx, *sy;

  sx = a_stringify(x);
  sy = a_stringify(y);

  res = new_string(strlen(sx)+strlen(sy)+1,"");
  strcpy(getstring(res),sx); 
  strcat(getstring(res),sy); 
  free(sx);
  free(sy);
  a_bind(cxt, 3, res);
  a_result(cxt);
  return nil;
}

oidtype concatbfb(a_callcontext cxt)
{
  oidtype x = a_arg(cxt,1);
  oidtype r = a_arg(cxt,3);
  char *sx, *sr;
  int lx, lr, i;

  sx = a_stringify(x);
  sr = a_stringify(r);
  lx = strlen(sx);
  lr = strlen(sr);
  if(lx>lr) goto ret;
  for(i=0;i<lx;i++)
    if(sx[i]!=sr[i]) goto ret;
  a_bind(cxt,2,mkstring(sr+lx));
  free(sx);
  free(sr);
  a_result(cxt);
  return nil;
 ret:
  free(sx);
  free(sr);
  return nil;
}

oidtype concatfbb(a_callcontext cxt)
{
  oidtype res;
  oidtype y = a_arg(cxt,2);
  oidtype r = a_arg(cxt,3);
  char *sy, *sr;
  int ly, lr, i;

  sy = a_stringify(y); 
  sr = a_stringify(r); 
  ly = strlen(sy);
  lr = strlen(sr);
  if(ly>lr) goto ret;
  for(i=0;i<ly;i++)
    if(sy[i]!=sr[i+lr-ly]) goto ret;
  res = new_string(lr-ly+1,"");
  strncpy(getstring(res), sr, lr-ly); 
  getstring(res)[lr-ly]='\0';
  free(sy);
  free(sr);
  a_bind(cxt, 1, res);
  a_result(cxt);
  return nil;
 ret:
  free(sy);
  free(sr);
  return nil;
}

/************************** equality            ******************************/
oidtype equalbb(a_callcontext cxt)
{
  if(equal(a_arg(cxt,1),a_arg(cxt,2))) a_result(cxt);
  return nil;
}

oidtype equalbf(a_callcontext cxt)
{
  a_bind(cxt,2,a_arg(cxt,1));
  a_result(cxt);
  return nil;
}

oidtype equalfb(a_callcontext cxt)
{
  a_bind(cxt,1,a_arg(cxt,2));
  a_result(cxt);
  return nil;
}

/************************** Temporal functions  ******************************/
oidtype rnowF(a_callcontext cxt)
{
  a_bind(cxt,1,mkreal(rnow()));
  a_result(cxt);
  return nil;
}

/************************** 2nd order functions ******************************/
oidtype applyFunction1Mapper(a_callcontext cxt, int width, oidtype *restpl, 
			     void *pcxt)
{
  a_callcontext rcxt = *((a_callcontext *)pcxt);

  if(width>0)a_bind(rcxt,3,*restpl);
  a_result(rcxt);
  return nil;
}

oidtype applyFunction1bbf(a_callcontext cxt)
{
  oidtype fno = a_arg(cxt,1);
  oidtype args[1];

  args[0] = a_arg(cxt,2);
  a_mapfunctionC(cxt, fno, 1, args, applyFunction1Mapper, (void *)&cxt);
  return nil;
} 

oidtype mapVectorMapper(a_callcontext cxt, int width, oidtype *restpl, void *xa)
{
  a_setf(*((oidtype *)xa),restpl[0]);
  return nil;
}

oidtype mapVectorbbf(a_callcontext cxt)
{
  oidtype fno = a_arg(cxt,1);
  oidtype v = a_arg(cxt,2);
  int s = a_arraysize(v),i;
  oidtype res = nil;
  oidtype args[1];
  oidtype mres = nil;

  a_setf(res,new_array(s,nil));
  {unwind_protect_begin;
  for(i=0;i<s;i++)
    {
      args[0] = a_elt(v,i);
      a_mapfunctionC(cxt, fno, 1, args, mapVectorMapper, &mres);
      a_seta(res,i,mres);
    }
  a_bind(cxt,3,res);
  a_result(cxt);
  unwind_protect_catch;
  a_free(res);
  a_free(mres);
  unwind_protect_end;}
  return nil;
}

/************************** symbol registration ******************************/
void register_amosfns(void)
{
  VDIM_DISAGREE = a_register_error("Vector dimensionality must agree");
  a_extimpl("iota--+",iotabbf);
  a_extimpl("ne--",nebb);
  a_extimpl("lt--",ltbb);
  a_extimpl("le--",lebb);
  a_extimpl("gt--",gtbb);
  a_extimpl("ge--",gebb);
  a_extimpl("mod--+",modbbf);
  a_extimpl("floorbf",floorbf);
  a_extimpl("ceilingbf",ceilingbf);
  a_extimpl("round-+",roundbf);
  a_extimpl("realbytes-+",realbytesbf);
  a_extimpl("sinbf",sinbf);
  a_extimpl("asinbf",asinbf);
  a_extimpl("cosbf",cosbf);
  a_extimpl("acosbf",acosbf);
  a_extimpl("tanbf",tanbf);
  a_extimpl("atanbf",atanbf);
  a_extimpl("expbf",expbf);
  a_extimpl("lnbf",lnbf);
  a_extimpl("powerbbf",powerbbf);
  a_extimpl("plus--+",plusbbf);
  a_extimpl("plus-+-",plusbfb);
  a_extimpl("times--+",timesbbf);
  a_extimpl("times-+-",timesbfb);
  a_extimpl("abs-+",absbf);
  a_extimpl("vectortimesbbf", vectortimesbbf);
  a_extimpl("vectorplusbbf", vectorplusbbf);
  a_extimpl("vectorplusbfb", vectorplusbfb);
  a_extimpl("vectornumplusbbf", vectornumplusbbf);
  a_extimpl("vectornumplusfbb", vectornumplusfbb);
  a_extimpl("vectornumplusbfb", vectornumplusbfb);
  a_extimpl("typesofbb",typesofbb);
  typecheckersymbol = mksymbol("type-checker");
  a_extimpl("vrefbbf",vrefbbf);
  a_extimpl("vrefbff",vrefbff);
  a_extimpl("construct-vectorC", construct_vectorC);
  a_extimpl("vector.in",vector_inBF);
  a_extimpl("concat--+",concatbbf);
  a_extimpl("concat-+-",concatbfb);
  a_extimpl("concat+--",concatfbb);
  a_extimpl("equal--",equalbb);
  a_extimpl("equal+-",equalfb);
  a_extimpl("equal-+",equalbf);
  a_extimpl("mlhash", mlhashbbbf);
  a_extimpl("euclidbbf", euclidbbf);
  a_extimpl("minkowskibbbf", minkowskibbbf);
  a_extimpl("maxnormbbf", maxnormbbf);
  a_extimpl("rnow+", rnowF);
  a_extimpl("applyFunction1--+",applyFunction1bbf);
  a_extimpl("mapVector--+",mapVectorbbf);
  a_extimpl("powerfbb",powerfbb);
}
