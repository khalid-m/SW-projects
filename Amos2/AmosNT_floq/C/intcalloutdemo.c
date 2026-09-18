/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Tore Risch, UDBL
 *
 * Description: Demo program illustrating the internal AMOSQL -> C interfaces
 * ===========================================================================
 * $Log: intcalloutdemo.c,v $
 * Revision 1.10  2010/12/29 18:39:44  torer
 * Removed test code
 *
 * Revision 1.9  2010/12/26 17:06:23  torer
 * No using obsoleted IntoNumber and a_global_callcontext
 *
 * Revision 1.8  2010/12/23 07:18:57  torer
 * print statement removed
 *
 * Revision 1.7  2010/12/09 18:41:14  torer
 * Removed coersions
 *
 * Revision 1.6  2010/12/08 12:16:40  torer
 * Examples of aggregate functions in C added
 *
 * Revision 1.5  2010/12/07 21:26:18  torer
 * Added example of aggregate function
 *
 * Revision 1.4  2010/12/03 08:49:12  torer
 * New macro IntoNumber
 *
 * Revision 1.3  2010/12/02 21:19:41  torer
 * using a_getfunctionnamed
 *
 * Revision 1.2  2010/12/01 18:31:17  torer
 * Included demo of a_mapfunctionC
 *
 * Revision 1.1  2010/12/01 08:25:43  torer
 * Demonstration of new callout interface
 *
 ****************************************************************************/

#include "callout.h"
#include <math.h>


/* 
   The following functions define foreign AmosQL functions whose signatures
   are in the file intcallout.amosql.

   E.g. the function solve2 in intcallout.amosql is defined as:
   create function solve2(real a, real b, real c) -> real x
   as multidirectional ('bbbf' foreign 'solve2bbbf')
   ('bbfb' foreign 'solve2bbfb')
   ('bfbb' foreign 'solve2bfbb')
   ('fbbb' foreign 'solve2fbbb');

*/

oidtype solve2bbbf(a_callcontext cxt)
{
  /* Foreign predicate p(a,b,c,x) to solve x in
     a*x**2 + b*x + c = 0 */
  double a, b, c, d, x;

  IntoDouble(a_arg(cxt,1),a,cxt->env); /* Unbox 1st arg */
  IntoDouble(a_arg(cxt,2),b,cxt->env); /* Unbox 2nd arg */
  IntoDouble(a_arg(cxt,3),c,cxt->env); /* Unbox 3rd arg */
  d = b * b - 4 * a * c; /* Compute discriminant */
  if(d < 0.0); /* No solution  */
  if(d==0.0)  /* One solution */
    {
      x = (-b)/(2.0 * a);
      a_bind(cxt, 4, mkreal(x)); /* Bind result */
      a_result(cxt); /* Emit the solution */
    }
  if(d > 0.0) /* Two solutions */
    {
      x = (-b + sqrt(d))/(2.0 * a);
      a_bind(cxt,4,mkreal(x));
      a_result(cxt); /* Emit 1st solution */
      x = (-b - sqrt(d))/(2.0 * a);
      a_bind(cxt,4,mkreal(x));
      a_result(cxt); /* Emit 2nd solution */
    }
  return nil; /* Always return nil */
}

oidtype solve2bbfb(a_callcontext cxt)
{
  /* a,b,x known => c = -(a*x^2 + b*x) */
  double a,b,c,x;

  IntoDouble(a_arg(cxt,1),a,cxt->env);
  IntoDouble(a_arg(cxt,2),b,cxt->env);
  IntoDouble(a_arg(cxt,4),x,cxt->env);
  c = -(a*x*x + b*x); /* Solution */
  a_bind(cxt,3,mkreal(c));
  a_result(cxt);
  return nil;
}

oidtype solve2bfbb(a_callcontext cxt)
{
  /* a,c,x known => b = (-c -a*x^2)/x */
  double a, b, c, x;

  IntoDouble(a_arg(cxt,1),a,cxt->env);
  IntoDouble(a_arg(cxt,3),c,cxt->env);
  IntoDouble(a_arg(cxt,4),x,cxt->env);
  b = (-c - a*x*x)/x; /* Solution */
  a_bind(cxt,2,mkreal(b));
  a_result(cxt);
  return nil;
}

oidtype solve2fbbb(a_callcontext cxt)
{
  /* b,c,x known => a = (-c - b*x)/x^2 */
  double a, b, c, x;

  IntoDouble(a_arg(cxt,2),b,cxt->env);
  IntoDouble(a_arg(cxt,3),c,cxt->env);
  IntoDouble(a_arg(cxt,4),x,cxt->env);
  a = (-c - b*x)/(x*x); /* Solution */
  a_bind(cxt, 1, mkreal(a));
  a_result(cxt);
  return nil;
}

#include "complex.h"
oidtype complex_plus(a_callcontext cxt)
     /* Demonstrates how to use internal ALisp datatypes
	in foreign AmosQL functions.
	All ALisp objecs are declared as oidtype */
{
  oidtype x = a_arg(cxt,1);
  oidtype y = a_arg(cxt,2);
  float re, im;
  struct complexcell *dx, *dy;

  OfType(x,complex,cxt->env); /* Will throw error if wrong type */
  OfType(y,complex,cxt->env); /* Will throw error if wrong type */
  dx = dr(x,complexcell); /* This is safe now! */
  dy = dr(y,complexcell);
  re = dx->real + dy->real;
  im = dx->imag + dy->imag;
  a_bind(cxt,3,new_complex(re,im)); /* Set result to new complex */
  a_result(cxt);
  return nil;
}

oidtype cvector(a_callcontext cxt)
     /* cvector(Real x, Real y, Integer size)
	Demonstrates how to create vector of size complex numbers */
{
  double x, y;
  int s; 
  int i;
  oidtype res;

  IntoDouble(a_arg(cxt,1),x,cxt->env);
  IntoDouble(a_arg(cxt,2),y,cxt->env);
  IntoInteger(a_arg(cxt,3),s,cxt->env); 

  if(s<0) a_error(ILLEGAL_ARGUMENT,a_arg(cxt,3),FALSE);
  res = new_array(s,nil); /* Need not increment refcnt here */
  for(i=0;i<s;i++) /* Fill vector res with complex numbers */
    a_seta(res,i,new_complex((float)x,(float)y));
  a_bind(cxt,4,res);
  a_result(cxt);
  return nil;
}

/**** Utilities to print tuples passed to/from Amos II functions ****/

oidtype printtpl(int width, oidtype *tpl)
{
  int i;

  printf("<");
  for(i=0;i<width;i++)
    {
      if(i>0) printf(" ");
      a_prin1(tpl[i],stdoutstream, FALSE); //print object wihout CR
    }
  printf(">\n");
  return nil;
}

oidtype printTuple(a_callcontext cxt, int width, oidtype tpl[], void *xa)
{
  return printtpl(width, tpl);
}

/**** Printing results from solve2 ****/

struct printCountVars {char *var; int cnt;};

oidtype printCountMapper(a_callcontext cxt, int width, oidtype tpl[], void *xa)
{
  printtpl(width, tpl);
  printf(" %s = ",((struct printCountVars *)xa)->var);
  a_print(tpl[0]);
  ((struct printCountVars *)xa)->cnt++;
  return nil;
}

/**** Aggregate function myavg(Bag of Number b)->Real ****/

struct myavgBFstats {int cnt; double s;};

oidtype myavgBFMapper(a_callcontext cxt, int width, oidtype res[],void *xa)
{  
  struct myavgBFstats *sc = (struct myavgBFstats *)xa;
  double r;
  IntoDouble(res[0], r, cxt->env);  // unbox as double (Real)
  sc->cnt++;
  sc->s = sc->s + r;
  return nil;
}

oidtype myavgBF(a_callcontext cxt)
{ 
  struct myavgBFstats sc;
  oidtype b = a_arg(cxt,1);

  sc.cnt=0;
  sc.s=0.0;
  a_mapbag(cxt, b, myavgBFMapper, (void *)&sc);
  a_bind(cxt,2,mkreal(sc.s/sc.cnt));  // box result number as Real
  a_result(cxt);
  return nil;
}

/**** Aggregate function mynth(Integer n, Bag b)->Object ****/

oidtype mynthBBFMapper(a_callcontext cxt, int width, oidtype *tpl, void *xa)
{
  int *n = (int *)xa;

  (*n)--; 
  if(*n<0) a_map_done(cxt,nil); /* Return nil from a_mapbag */
  else if(*n==0)/* Return 1st elem in tpl from a_mapbag */ 
    a_map_done(cxt,tpl[0]); 
  /* else continue iteration */
  return nil;
}

oidtype mynthBBF(a_callcontext cxt)
{
  int n;
  oidtype b;
  oidtype res;

  IntoInteger(a_arg(cxt,1),n,cxt->env);
  b = a_arg(cxt,2);
  res = a_mapbag(cxt,b,mynthBBFMapper,&n); /* need no a_setf here since we 
                                              just hand over res to a_bind */ 
  if(res==nil) return nil;                 /* symbols like nil not garbage 
                                              collected and need not be 
                                              released */
  a_bind(cxt,3,res);
  a_result(cxt);
  return nil;
}


main(int argc,char **argv)
{
  dcl_connection(c); /* To hold connection to Amos */
  oidtype args[10]; /* Argument for a_mapfunctionC */
  dcl_oid(fn); /* To hold Amos function solve2 */
  dcl_scan(s);/* To hold result streams from Amos queries and function calls */
  dcl_tuple(result);  /* To hold results from Amos function calls */
  dcl_global_cxt(cxt); /* To hold a_callcontext cxt used in calls */
  struct printCountVars pcv;

  init_amos(argc,argv); /* Initialize embedded Amos.
                           Interprets command line parameters */

  /* The following code illustrates how to make foreign functions in C. 
     The function definitions (signatures) are in intcallout.amosql.
     The loading of the init file is delayed until a_connect is defined.

     First bind all foreign C function implementattions immediately after 
     init_amos.
     E.g. we bind the C function 'solve2_bbbf' to Amos foreign 
     predicate named 'solve2bbbf' and set its parameter:
  */
  a_extimpl("solve2bbbf",solve2bbbf);
  /* We will also define all the inverses of solve2: */
  a_extimpl("solve2bbfb",solve2bbfb);
  a_extimpl("solve2bfbb",solve2bfbb);
  a_extimpl("solve2fbbb",solve2fbbb);

  a_extimpl("complex_plus",complex_plus);
  a_extimpl("cvector",cvector);

  a_extimpl("myavg-+",myavgBF);
  a_extimpl("mynth--+",mynthBBF);

  /* The initialization script
     ../C/callout.amosql
     deifines two AmosQL functions in terms of the above symbolic bindings,
     creates the image callout.dmp, and quits.
     The command
        callout ../bin/amos2.dmp ../C/callout.amosql
     thus creates thbe image callout.dmp

     The loading of init scripts on the command line is delayed until first 
     call to a_connect. The init script will therefore be able to use the 
     above bindings.

     In the MVC project the init script in loaded just after the compilation,
     in the 'Post-build Step'.
  */

  a_connect(c,"",FALSE); /* Connect to embedded Amos and load init script if
                            specified */

  /* The file callout.amosql contains the definition of the AMOSQL function
     'solve2(a,b,c)->x' defined as solve2bbbf when
     a, b, and c are known while x is unknown:

     create function solve2(real a, real b, real c) -> real x
     as foreign 'solve2bbbf'; 


     If the program is called with an image not containíng signature of solve2
     the following statement will fail and the system exit: */
  
  a_setf(fn,a_getfunctionnamed("real.real.real.solve2->real",FALSE));

  /*** Run solve2 ***/
  printf("solving x in x^2 + 2x - 3 = 0 \n");
  args[0] = mkreal(1.0); /* a=1 */
  args[1] = mkreal(2.0); /* b=2 */
  args[2] = mkreal(-3.0); /* c=-3 */
  pcv.var = "x";
  pcv.cnt = 0;
  a_mapfunctionC(cxt, fn, 3, args, printCountMapper, 
		 (struct printCountVars *)&pcv);
  printf("(%d solutions)\n",pcv.cnt);

  printf("Solving x in x^2 + 2x + 1 = 0\n");
  args[0] = mkreal(1.0); /* a=1 */
  args[1] = mkreal(2.0); /* b=2 */
  args[3] = mkreal(1.0); /* c=1 */
  pcv.cnt = 0;
  a_mapfunctionC(cxt, fn, 3, args, printCountMapper, 
		 (struct printCountVars *)&pcv);
  printf("(%d solutions)\n",pcv.cnt);

  printf("Solving x in x^2 + x + 1 = 0\n");
  args[0] = mkreal(1.0); /* a=1 */
  args[1] = mkreal(1.0); /* b=1 */
  args[2] = mkreal(1.0); /* c=1 */
  pcv.cnt = 0;
  a_mapfunctionC(cxt, fn, 3, args, printCountMapper, 
		 (struct printCountVars *)&pcv);
  printf("(%d solutions)\n",pcv.cnt);

  printf("Testing the inverses:\n");

  a_setf(fn, a_getfunctionnamed("charstring.eval->object",FALSE));
  args[0]=mkstring("select a,1 from real a where solve2b(a,2.0,4.0)=2.0;");
  pcv.var = "a";
  printf("Solving a in solve2b(a,2.0,4.0)=2.0\n");
  a_mapfunctionC(cxt, fn, 1, args, printCountMapper,
		 (struct printCountVars *)&pcv);
  printf("(%d solutions)\n",pcv.cnt);

  a_execute(c,s,"select b from real b where solve2b(1.0,b,4.0)=2.0;",FALSE);
  a_getrow(s,result,FALSE);
  printf("solev2(1,b,4)=2=> b= %g\n",a_getdoubleelem(result,0,FALSE));

  a_execute(c,s,"select c from real c where solve2b(1.0,2.0,c)=3.0;",FALSE);
  a_getrow(s,result,FALSE);
  printf("solev2(1,2,c)=3=> c= %g\n",a_getdoubleelem(result,0,FALSE));

  a_execute(c,s,"myavg(iota(1,1000));",FALSE);
  a_getrow(s, result,FALSE);
  printf("myavg(iota(1,1000)) => %g\n", a_getdoubleelem(result,0,FALSE));

  a_execute(c,s,"mynth(6,iota(1,6));",FALSE);
  a_getrow(s, result,FALSE);
  printf("mynth(6,iota(1,6)) => ");
  a_print(a_getobjectelem(result,0,FALSE));

  a_execute(c,s,"mynth(3,iota(1,10000000));",FALSE);
  a_getrow(s, result,FALSE);
  printf("mynth(3,iota(3,10000000)) => ");
  a_print(a_getobjectelem(result,0,FALSE));

  a_execute(c,s,"mynth(71,iota(1,70));",FALSE);
  printf("mynth(71,iota(1,70)) => ");
  if(a_eos(s)) printf("No result\n");
  else
    {
      a_getrow(s, result,FALSE);
      a_print(a_getobjectelem(result,0,FALSE));
    }
  /* Release image objects used in program: */

  free_oid(fn);
  free_scan(s);
  free_tuple(result);
  free_connection(c);

  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a') amos_toploop("Amos");

  return 0;
}
