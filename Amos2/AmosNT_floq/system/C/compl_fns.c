/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2003 Milena Ivanova, Tore Risch, UDBL
 * $RCSfile: compl_fns.c,v $
 * $Revision: 1.22 $ $Date: 2010/12/27 10:16:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: complex numbers type and operations
 * ===========================================================================
 * $Log: compl_fns.c,v $
 * Revision 1.22  2010/12/27 10:16:20  torer
 * C warnings removed
 *
 * Revision 1.21  2006/06/05 19:31:31  torer
 * Complex numbers printed with double precision.
 * Warnings removed.
 *
 * Revision 1.20  2006/06/05 12:39:56  torer
 * Using include for type BINARY
 *
 * Revision 1.19  2006/06/05 12:26:41  torer
 * Large storage leak
 *
 ****************************************************************************/

#include "amos.h" /* Needed to add to kernel dll. Defines EXPORT */
#include "binary.h"
#include <math.h>
#include "complex.h"

EXPORT int complex; /* Will hold the type tag of objects of type COMPLEX */
/* All functions and variables to be exported (external) from dll must be
   prefixed with EXPORT */

EXPORT oidtype new_complex(double re,double im)
     /*** Constructor for the complex number re + i*im ***/
{
  /*** Allocate a new object of type COMPLEX in the image ***/
  oidtype res = new_object(sizeof(struct complexcell),complex);
  float sre = (float)re, sim = (float)im;

  /*** Set the real and imaginary parts of the new object ***/
  dr(res, complexcell)->real = sre;
  dr(res, complexcell)->imag = sim;

  /*** Return the new object ***/
  return res;
}

void a_double_to_string(double d, char *buff)
{
  sprintf(buff,"%.15G",d);
  if(strchr(buff,'.')==NULL && strchr(buff,'E')==NULL)
    sprintf(buff,"%G.0",d);
}

void print_complex(oidtype o, oidtype stream, int princflg)
     /*** Print function for complex numbers ***/
{
  char floatbuff[100];

  a_puts("#[C ",stream);
  a_double_to_string(dr(o,complexcell)->real,floatbuff);
  a_puts(floatbuff,stream);
  a_puts(" ",stream);
  a_double_to_string(dr(o,complexcell)->imag,floatbuff);
  a_puts(floatbuff,stream);
  a_puts("]",stream);

  return;
}

oidtype read_complex(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
  oidtype re, im;
  double dre, dim;

  re = hd(x);
  im = hd(ftl(x));
  IntoDouble(re,dre,env);
  IntoDouble(im,dim,env);
  return new_complex(dre,dim);
}

int complex_equal(oidtype x, oidtype y)
{
  struct complexcell *dx = dr(x,complexcell);
  struct complexcell *dy = dr(y,complexcell);

  return (dx->real == dy->real) & (dx->imag == dy->imag);
}

oidtype mkcomplexfn(bindtype env, oidtype oidRe, oidtype oidIm)
{
  double re,im;

  IntoDouble(oidRe,re,env);
  IntoDouble(oidIm,im,env);
  return new_complex(re,im);
}

oidtype sumcomplexfn(bindtype env, oidtype x, oidtype y)
     /*** Add the two complex numbers x and y ***/
{
  float xre,xim,yre,yim;

  IntoComplex(x,xre,xim,env);
  IntoComplex(y,yre,yim,env);
  return new_complex(xre + yre, xim + yim); /* Construct result */
}

oidtype subcomplexfn(bindtype env, oidtype x, oidtype y)
     /*** Subtract the two complex numbers x and y ***/
{
  float xre,xim,yre,yim;

  IntoComplex(x,xre,xim,env);
  IntoComplex(y,yre,yim,env);
  return new_complex(xre - yre, xim - yim); /* Construct result */
}

oidtype multcomplexfn(bindtype env, oidtype x, oidtype y)
     /*** Multiply the two complex numbers x and y ***/
{
  float xre,xim,yre,yim;

  IntoComplex(x,xre,xim,env);
  IntoComplex(y,yre,yim,env);
  return new_complex(xre * yre - xim * yim,
		     xre * yim + xim * yre); /* Construct result */
}

oidtype divcomplexfn(bindtype env, oidtype x, oidtype y)
     /*** Divide the two complex numbers x and y ***/
{
  float xre,xim,yre,yim,d;

  IntoComplex(x,xre,xim,env);
  IntoComplex(y,yre,yim,env);
  d= yre* yre + yim * yim;
  if (d)
    return new_complex((xre * yre + xim * yim)/d,
                       (-xre * yim + xim * yre)/d);
  /* Construct the result */
  /* Raise an ALisp error division by zero: (error codes in storage.h) */
  return lerror(ZERO_DIVIDE,y,env);
}

oidtype getrealfn(bindtype env, oidtype x)
     /* Get the real part of a complex number */
{
  float d;
  OfType(x,complex,env); /* Check type of x */
  d= dr(x,complexcell)->real;
  return mkreal(d);
}

oidtype getimagfn(bindtype env, oidtype x)
     /* Get the real part of a complex number */
{
  float d;

  OfType(x,complex,env); /* Check type of x */
  d= dr(x,complexcell)->imag;
  return mkreal(d);
}

oidtype conjfn(bindtype env, oidtype x)
     /*** Conjugate of a complex number ***/
{ 
  float xre,xim;

  IntoComplex(x,xre,xim,env);
  return new_complex(xre,- xim); /* Construct result */
}

double truncn(double x, int n)
     /* trunc a real number x to the n-th position after decimal point */
{   int i;
 for(i=0;i<n; i++)
   x=x*10;
 x=floor(x);
 for(i=0;i<n; i++)
   x=x/10;
 return x;
}

oidtype ncomplex_rootfn(bindtype env, oidtype n)
     /* calculate the n-th complex root of 1
	wn= e on power i*2*Pi/n
	Used by FFT*/
{
  const double Pi= 3.14159265358979;
  double alfa, re, im;
  int in;
  OfType(n,INTEGERTYPE,env);
  IntoInteger(n,in,env);
  alfa=2*Pi/in;
  re = truncn(cos(alfa),5);
  im = truncn(sin(alfa),5);
  return new_complex(re,im);
}

oidtype ncomplex_root_powfn(bindtype env, oidtype n, oidtype k)
     /*wn on power k, Used by FFT */
{   
 const double Pi= 3.14159265358979;
 double alfa, re, im;
 int in, ik;

 OfType(n,INTEGERTYPE,env);
 IntoInteger(n,in,env);
 OfType(k,INTEGERTYPE,env);
 IntoInteger(k,ik,env);

 alfa=2*Pi*ik/in;
 re = truncn(cos(alfa),5);
 im = truncn(sin(alfa),5);
 return new_complex(re,im);
}

oidtype trunccomplexfn(bindtype env, oidtype x, oidtype n)
     /*** Truncate complex number fields to the n-th position 
          after decimal point ***/
{
  float xre,xim;
  int in;
  OfType(n,INTEGERTYPE,env);
  IntoInteger(n,in,env);

  IntoComplex(x,xre,xim,env);
  return new_complex(truncn(xre,in), truncn(xim,in)); /* Construct result */
}

/* Returns: makes fft partitions
   returns a subarray of selected indexes
   for n =2, pno=0 - even, pno=1 -odd indexes
*/

oidtype fftpartfn(bindtype env, oidtype arr, oidtype n, oidtype pno)
{
  int in, ipno, i, idx;
  int sz;
  oidtype el = nil, res =nil;

  OfType(n,INTEGERTYPE,env);
  IntoInteger(n,in,env);
  OfType(pno,INTEGERTYPE,env);
  IntoInteger(pno,ipno,env);
  OfType(arr,ARRAYTYPE,env);
  sz = a_arraysize(arr);
  sz= (int) sz / in;

  // create array
  a_setf(res, new_array(sz, 0));

  for (i=0; i<sz; i++) {
    idx= (int) in * i + ipno;
    a_setf(el, a_elt(arr,idx));   
    a_seta(res, i, el);
  }
  a_free(el);
  a_return(res);
}

oidtype fftcombinefn(bindtype env, oidtype x, oidtype y)
{
  int i, idx;
  int sz, szn;
  oidtype elx = nil, ely =nil, el =nil, nroot = nil, res =nil, i1=nil, i2=nil;

  OfType(x,ARRAYTYPE,env);
  OfType(y,ARRAYTYPE,env);
  sz = a_arraysize(x);
  /* if (sz != a_arraysize(y)) amos_error(); */
  szn = (int) 2* sz;

  // create array
  a_setf(res, new_array(szn, 0));

  for (i=0; i<szn; i++) {
    idx= (int)fmod(i,sz);
    a_setf(elx, a_elt(x,idx));
    a_setf(ely, a_elt(y,idx));
    a_setf(i1, mkinteger(szn));
    a_setf(i2, mkinteger(i));
    a_setf(nroot, ncomplex_root_powfn(env, i1, i2));
    a_setf(el,multcomplexfn(env, ely, nroot));
    a_setf(el,sumcomplexfn(env, elx, el));
    /*    a_setf(el,trunccomplexfn(env, el, mkinteger(1)));*/
    a_seta(res, i, el);
  }
  a_free(elx);
  a_free(ely);
  a_free(nroot);
  a_free(el);
  a_free(i1);
  a_free(i2);
  a_return(res);
}

oidtype dftfn(bindtype env, oidtype arr, oidtype n, oidtype pno)
{  /* compute partial result of DFT for partition number pno */
  int in, ipno, i, idx, offs,k;
  int sz;
  oidtype el = nil, sm=nil, coef=nil, res =nil, i1=nil;

  OfType(n,INTEGERTYPE,env);
  IntoInteger(n,in,env);
  OfType(pno,INTEGERTYPE,env);
  IntoInteger(pno,ipno,env);
  OfType(arr,ARRAYTYPE,env);
  sz = a_arraysize(arr);
  offs = ipno*sz;

  // create array
  a_setf(res, new_array(in, 0));

  for (i=0; i<in; i++){
    a_setf(sm,new_complex(0.0,0.0)); //compute partial sum
    for (k=0; k<sz; k++) {
      idx= offs + k;
      a_setf(el,a_elt(arr,k));
      a_setf(i1, mkinteger(idx*i));
      a_setf(coef,ncomplex_root_powfn(env, n, i1));
      a_setf(el,multcomplexfn(env,el,coef));
      a_setf(sm,sumcomplexfn(env,sm,el));  }
    a_seta(res, i, sm);
  }
  a_free(el);
  a_free(coef);
  a_free(sm);
  a_free(i1);
  a_return(res);
}

oidtype dftcombinefn(bindtype env, oidtype x, oidtype y)
{
  int i;
  int sz;
  oidtype elx = nil, ely =nil, el =nil, res =nil;

  OfType(x,ARRAYTYPE,env);
  OfType(y,ARRAYTYPE,env);
  sz = a_arraysize(x);
  /* if (sz != a_arraysize(y)) amos_error(); */

  // create array
  a_setf(res, new_array(sz, 0));

  for (i=0; i<sz; i++) { //add partial sums
    a_setf(elx, a_elt(x,i));
    a_setf(ely, a_elt(y,i));
    a_setf(el,sumcomplexfn(env, elx, ely));
    a_seta(res, i, el);
  }
  a_free(elx);
  a_free(ely);
  a_free(el);
  a_return(res);
}

oidtype encodecomplexarrayfn(bindtype env, oidtype x)
     /*** Encode vector of complex to vector of reals ***/
{
  oidtype y=nil,el=nil,re=nil,im=nil;
  int sz,i;

  OfType(x,ARRAYTYPE,env);
  sz =  a_arraysize(x);

  a_setf(y, new_array((int) 2*sz, 0));
  for (i=0; i<sz; i++) {
    a_setf( el,a_elt(x,i));
    a_setf(re,getrealfn(env, el));
    a_setf(im,getimagfn(env, el));
    a_seta(y,2*i,re);
    a_seta(y,1+(2*i),im);
  }
  a_free(el);
  a_free(re);
  a_free(im);
  a_return(y);
}

oidtype decodecomplexarrayfn(bindtype env, oidtype x)
     /*** Decode vector of real x into vector of complex ***/
{
  oidtype y=nil, re=nil, im=nil, c1=nil;
  int sz,i;

  OfType(x,ARRAYTYPE,env);
  sz = (int) a_arraysize(x)/ 2;

  a_setf(y, new_array(sz, 0));
  for (i=0; i<sz; i++) {
    a_setf(re,a_elt(x,2*i));
    a_setf(im,a_elt(x,2*i+1));
    a_setf(c1, mkcomplexfn(env,re,im));
    a_seta(y,i,c1);
  }
  a_free(re);
  a_free(im);
  a_free(c1);
  a_return(y);
}

oidtype vectorconcatfn(bindtype env, oidtype x, oidtype y)
     /* Concat 2 vectors into 1 */
{
  int i;
  int sz, szn;
  oidtype res =nil;

  OfType(x,ARRAYTYPE,env);
  OfType(y,ARRAYTYPE,env);
  sz = a_arraysize(x);
  /* if (sz != a_arraysize(y)) amos_error(); */
  szn = (int) 2* sz;

  // create array
  a_setf(res, new_array(szn, 0));

  for (i=0; i<sz; i++) {
    a_seta(res, i, a_elt(x,i));
    a_seta(res, i+sz, a_elt(y,i));
  }
  a_return(res);
}

oidtype vectorconcatnfn(bindtype env, oidtype v)
     /* Concat vectors that are elements of vector v */
{

  int i, j;
  int sz, szn, tplno;
  oidtype res =nil, tpl=nil;

  OfType(v,ARRAYTYPE,env);
  tplno = a_arraysize(v); //number of vectors to be concatenated

  a_setf(tpl,a_elt(v,0));
  OfType(tpl,ARRAYTYPE,env);
  sz = a_arraysize(tpl);  // size of 1 vector
  /* if (sz != a_arraysize(y)) amos_error(); */
  szn = (int) tplno* sz;  //new vector size

  // create array
  a_setf(res, new_array(szn, 0));

  for(j=0; j<tplno; j++){
    a_setf(tpl,a_elt(v,j));
    OfType(tpl,ARRAYTYPE,env);
    for (i=0; i<sz; i++) {
      a_seta(res, i+sz*j, a_elt(tpl,i));
    }
  }
  a_free(tpl);
  a_return(res);
}


/* Returns: makes a vector partition (chop)
   numbered pno out of n partitions
*/

oidtype vectorpartfn(bindtype env, oidtype arr, oidtype n, oidtype pno)
{

  int in, ipno, i, idx;
  int sz, psz;
  oidtype el = nil, res =nil;

  OfType(n,INTEGERTYPE,env);
  IntoInteger(n,in,env);
  OfType(pno,INTEGERTYPE,env);
  IntoInteger(pno,ipno,env);
  OfType(arr,ARRAYTYPE,env);
  sz = a_arraysize(arr);
  psz= (int) sz / in;

  // create array
  a_setf(res, new_array(psz, 0));

  for (i=0; i<psz; i++) {
    idx= (int) ipno*psz + i;
    a_setf(el, a_elt(arr,idx));
    a_seta(res, i, el);
  }
  a_free(el);
  a_return(res);
}

oidtype complextobinaryfn(bindtype env, oidtype x)
     /// Encode vector of complex to binary
{

  oidtype b=nil,el=nil;
  int sz,i;

  OfType(x,ARRAYTYPE,env);
  sz =  a_arraysize(x);

  a_setf(b, new_binary((int) 8*sz, 0)); // 2 floats x 4

  for (i=0; i<sz; i++) {
    a_setf(el,a_elt(x,i));
    put_float(env, b, 2*i,getrealfn(env, el));
    put_float(env, b, 2*i + 1,getimagfn(env, el));
  }
  a_free(el);
  a_return(b);
}

oidtype binarytocomplexfn(bindtype env, oidtype b)
     /// Encode binary to vector of complex
{

  oidtype y=nil, re=nil, im=nil, c1=nil;
  int bsz,sz,i;

  OfType(b,BINARYTYPE,env);
  bsz = binary_size(dr(b,binarycell));
  sz= (int) bsz/8; // complex array size
  //   printf("BSize %d \n",bsz);
  a_setf(y, new_array(sz, 0));

  for (i=0; i<sz; i++) {
    a_setf(re,get_float(env,b,2*i));
    a_setf(im,get_float(env,b,2*i+1));
    a_setf(c1, mkcomplexfn(env,re,im));
    a_seta(y,i,c1);
  }
  a_free(re);
  a_free(im);
  a_free(c1);
  a_return(y);
}

/*****************************************************************************
 * Initialization
 *****************************************************************************/
void register_complex_functions(void) {

  /*** Define user defined datatype COMPLEX ***/
  complex = a_definetype("complex",dealloc_object,print_complex);

  /*** Define user defined reader for #[C r.r i.i] ***/
  type_reader_function("C", read_complex);

  /*** Define equality of complex numbers ***/
  typefns[complex].equalfn = complex_equal;

  /*** Constructor ***/
  extfunction2("make-complex",mkcomplexfn);

  /*** Define Lisp function to add, subtract, multiply,
       and divide complex numbers ***/
  extfunction2("sumcomplex",sumcomplexfn);
  extfunction2("subcomplex",subcomplexfn);
  extfunction2("multcomplex",multcomplexfn);
  extfunction2("divcomplex",divcomplexfn);
  extfunction1("getreal",getrealfn);
  extfunction1("getimag",getimagfn);
  extfunction1("conj",conjfn);
  extfunction2("trunccomplex",trunccomplexfn);

  /*** Define Lisp functions needed for DFT and FFT ***/
  /*** Calculate and return the n-th complex root of 1 ***/
  extfunction1("ncomplex_root",ncomplex_rootfn);
  /*** Calculate and return the n-th complex root of 1 on power k***/
  extfunction2("ncomplex_root_pow",ncomplex_root_powfn);
  extfunction3("fft-part",fftpartfn);
  extfunction2("fft-combine",fftcombinefn);
  extfunction2("vector-concat",vectorconcatfn);
  extfunction1("vector-concatn",vectorconcatnfn);
  extfunction3("vector-part",vectorpartfn);
  extfunction1("encodecomplexarray",encodecomplexarrayfn);
  extfunction1("decodecomplexarray",decodecomplexarrayfn);
  extfunction1("complex-to-binary",complextobinaryfn);
  extfunction1("binary-to-complex",binarytocomplexfn);
  extfunction3("dft",dftfn);
  extfunction2("dft-combine",dftcombinefn);
}
