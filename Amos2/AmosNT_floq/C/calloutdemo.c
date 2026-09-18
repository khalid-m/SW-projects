/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: calloutdemo.c,v $
 * $Revision: 1.11 $ $Date: 2013/03/06 14:23:32 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Demo program illustrating the C <-> AMOSQL <-> C interfaces
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include <math.h>

void solve2bbbf(a_callcontext cxt, a_tuple t)
{
   /* Foreign predicate p(a,b,c,x) to solve x in
      a*x**2 + b*x + c = 0 */
   double a, b, c, d;
   printf("Calling %s\n",a_extpredname(cxt));
   printf("Parameter: %s\n",a_extpredparam(cxt));
   a = a_getdoubleelem(t,0,FALSE);
   b = a_getdoubleelem(t,1,FALSE);
   c = a_getdoubleelem(t,2,FALSE);
   d = b * b - 4 * a * c; /* Discriminant */
   if(d < 0.0) /* No solution */
     return;
   if(d==0.0) /* One solution */
   {
      a_setdoubleelem(t,3,(-b)/(2.0 * a),FALSE);
      a_emit(cxt,t,FALSE);
      return;
   }
   if(d > 0.0) /* Two solutions */
   {
      a_setdoubleelem(t,3,(-b + sqrt(d))/(2.0 * a),FALSE);
      printf("First tuple\n");
      if(a_emit(cxt,t,TRUE))
      {
         printf("(1) Error %d: %s ",a_errno, a_errstr); a_print(a_errform);
         return; /* Always return after trapped error */
      }
      if(cxt->done) /* When this is true and there is no error it means that
                       the consumer of the result needs no more tuples */
      {
         printf("Done!\n");
         return; /* Always return when no more tuples needed */
      }

      printf("Second tuple\n");
      a_setdoubleelem(t,3,(-b - sqrt(d))/(2.0 * a),FALSE);
      a_emit(cxt,t,FALSE);
      return;
   }
}

void solve2bbfb(a_callcontext cxt, a_tuple t)
{
    /* a,b,x known => c = -(a*x^2 + b*x) */
    double a,b,x;

    a = a_getdoubleelem(t,0,FALSE);
    b = a_getdoubleelem(t,1,FALSE);
    x = a_getdoubleelem(t,3,FALSE);
    a_setdoubleelem(t,2,-(a*x*x + b*x),FALSE);
    a_emit(cxt,t,FALSE);
    return;
}

void solve2bfbb(a_callcontext cxt, a_tuple t)
{
    /* a,c,x known => b = (-c -a*x^2)/x */
    double a, c, x;

    a = a_getdoubleelem(t,0,FALSE);
    c = a_getdoubleelem(t,2,FALSE);
    x = a_getdoubleelem(t,3,FALSE);
    a_setdoubleelem(t,1,(-c - a*x*x)/x,FALSE);
    a_emit(cxt,t,FALSE);
    return;
}

void solve2fbbb(a_callcontext cxt, a_tuple t)
{
    /* b,c,x known => a = (-c - b*x)/x^2 */
    double b, c, x;

    b = a_getdoubleelem(t,1,FALSE);
    c = a_getdoubleelem(t,2,FALSE);
    x = a_getdoubleelem(t,3,FALSE);
    a_setdoubleelem(t,0,(-c - b*x)/(x*x),FALSE);
    a_emit(cxt,t,FALSE);
    return;
}

#include "complex.h"
void complex_plus(a_callcontext cxt, a_tuple t)
   /* Demonstrates how to use internal ALisp datatypes
      in foreign AmosQL functions.
      All ALisp objecs are declared as oidtype */
{
   oidtype x = a_getobjectelem(t,0,FALSE);
   oidtype y = a_getobjectelem(t,1,FALSE);
   float re, im;
   struct complexcell *dx, *dy;

   if(a_datatype(x)!=COMPLEXTYPE)
      /* Error codes are in storage.h.
         Don't catch errors in foreign functions.
         Notice that a throw will happen next here! */
      a_error(ILLEGAL_ARGUMENT,x,FALSE);
   if(a_datatype(y)!=COMPLEXTYPE)
      a_error(ILLEGAL_ARGUMENT,y,FALSE);
   dx = dr(x,complexcell); /* This is safe now! */
   dy = dr(y,complexcell);
   re = dx->real + dy->real;
   im = dx->imag + dy->imag;
   a_setelem(t,2,new_complex(re,im)); /* Set result to new complex */
   a_emit(cxt,t,FALSE);
}

void cvector(a_callcontext cxt, a_tuple t)
   /* cvector(Real x, Real y, Integer size)
      Demonstrates how to create vector of complex numbers */
{
   double x = a_getdoubleelem(t,0,FALSE);
   double y = a_getdoubleelem(t,1,FALSE);
   int s = a_getintelem(t,2,FALSE), i;
   dcl_tuple(res);

   if(s<0) a_error(ILLEGAL_ARGUMENT,a_getobjectelem(t,2,FALSE),FALSE);
   a_newtuple(res,s,FALSE);
   for(i=0;i<s;i++) /* Fill vector res with complex numbers */
     a_setelem(res,i,new_complex((float)x,(float)y));
   a_setseqelem(t,3,res,FALSE); /* Set result to vector res */
   a_emit(cxt,t,FALSE);
}

main(int argc,char **argv)
{
  dcl_connection(c); /* To hold connection to Amos */
  dcl_tuple(argl); /* To hold Amos function argument lists */
  dcl_oid(fn); /* To hold Amos function solve2 */
  dcl_scan(s); /* To hold result streams from Amos queries and function calls */
  dcl_tuple(result);  /* To hold results from Amos function calls */
  int i;

  init_amos(argc,argv); /* Initialize embedded Amos.
                           Notice that database image file must be specified */

  /* The following code illustrates how to make foreign functions in C available
     in the init AmosQL file specified on the command line.
     The loading of the init file is delayed until function solve2 is defined. */
  /* First bind all foreign C function implementattions immediately after init_amos.
     In this case we bind the C function 'solve2_bbbf' to Amos foreign predicate
     named 'solve2bbbf' and set its parameter: */
  a_extfunction("solve2bbbf",solve2bbbf);
  a_setpredparam("solve2bbbf","solves 2nd degree equations");
  /* We will also define its inverses later so we bind it too: */
  a_extfunction("solve2bbfb",solve2bbfb);
  a_extfunction("solve2bfbb",solve2bfbb);
  a_extfunction("solve2fbbb",solve2fbbb);

  a_extfunction("complex_plus",complex_plus);
  a_extfunction("cvector",cvector);

  /* The initialization script
        ../C/callout.amosql
     deifines two AmosQL functions in terms of the above symbolic bindings,
     creates the image callout.dmp and quits.
     The command
        callout ../bin/amos2.dmp ../C/callout.amosql
     thus creates thbe image callout.dmp
     */

  /* The loading of init scripts on the command line is delayed until first call
     to a_connect. The init script will now be able to use the above bindings.
     */
  a_connect(c,"",FALSE); /* Connect to embedded Amos and load init script if
                            specified */


  /* The file callout.amosql contains the definition of the AMOSQL function
     'solve2(a,b,c)->x' defined as solve2bbbf when
     a, b, and c are known while x is unknown:

     create function solve2(real a, real b, real c) -> real x
     as foreign 'solve2bbbf'; */

  /* If program is called with image not containíng solve2
     the following statement will fail and the system exit: */
  a_setf(fn,a_getfunction(c,"real.real.real.solve2->real",FALSE));

  /*** Test solve2 ***/
  printf("solving x^2 + 2x - 3 = 0 \n");
  a_newtuple(argl,3,FALSE);
  a_setdoubleelem(argl,0,1.0,FALSE); /* a=1 */
  a_setdoubleelem(argl,1,2.0,FALSE); /* b=2 */
  a_setdoubleelem(argl,2,-3.0,FALSE); /* c=-3 */
  i = 0;
  a_callfunction(c,s,fn,argl,FALSE); /* call solve2(1,2,-3) */
  while(!a_eos(s))
  {
     a_getrow(s,result,FALSE);
     printf("   x = %g\n",a_getdoubleelem(result,0,FALSE));
     a_nextrow(s,FALSE);
     i++;
  }
  printf("(%d solutions)\n",i);

  printf("Solving x^2 + 2x + 1 = 0\n");
  a_setdoubleelem(argl,0,1.0,FALSE); /* a=1 */
  a_setdoubleelem(argl,1,2.0,FALSE); /* b=2 */
  a_setdoubleelem(argl,2,1.0,FALSE); /* c=1 */
  i = 0;
  a_callfunction(c,s,fn,argl,FALSE); /* call solve2(1,2,1) */
  while(!a_eos(s))
  {
     a_getrow(s,result,FALSE);
     printf("   x = %g\n",a_getdoubleelem(result,0,FALSE));
     a_nextrow(s,FALSE);
     i++;
  }
  printf("(%d solutions)\n",i);

  printf("Solving x^2 + x + 1 = 0\n");
  a_setdoubleelem(argl,0,1.0,FALSE); /* a=1 */
  a_setdoubleelem(argl,1,1.0,FALSE); /* b=1 */
  a_setdoubleelem(argl,2,1.0,FALSE); /* c=1 */
  i = 0;
  a_callfunction(c,s,fn,argl,FALSE); /* call solve2(1,2,1) */
  while(!a_eos(s))
  {
     a_getrow(s,result,FALSE);
     printf("   x = %g\n",a_getdoubleelem(result,0,FALSE));
     a_nextrow(s,FALSE);
     i++;
  }
  printf("(%d solutions)\n",i);

  /* The function solve2b is in callout.amosql:
     create function solve2b(real a, real b, real c) -> real x
     as multidirectional ('bbbf' foreign 'solve2bbbf')
                         ('bbfb' foreign 'solve2bbfb')
                         ('bfbb' foreign 'solve2bfbb')
                         ('fbbb' foreign 'solve2fbbb'); */

  printf("Testing the inverses:\n");

  a_execute(c,s,"select a from real a where solve2b(a,2.0,4.0)=2.0;",FALSE);
  a_getrow(s,result,FALSE);
  printf("solev2(a,4,1)=2=> a= %g\n",a_getdoubleelem(result,0,FALSE));

  a_execute(c,s,"select b from real b where solve2b(1.0,b,4.0)=2.0;",FALSE);
  a_getrow(s,result,FALSE);
  printf("solev2(1,b,4)=2=> b= %g\n",a_getdoubleelem(result,0,FALSE));

  a_execute(c,s,"select c from real c where solve2b(1.0,2.0,c)=3.0;",FALSE);
  a_getrow(s,result,FALSE);
  printf("solev2(1,2,c)=3=> c= %g\n",a_getdoubleelem(result,0,FALSE));

  free_oid(fn);
  free_tuple(result);
  free_tuple(argl);
  free_scan(s);
  free_connection(c);
  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a') amos_toploop("Amos");

  return 0;
}
