/*****************************************************************************
 * AMOS2
 *
 * Author: 2013 Tore Risch, UDBL
 * $RCSfile: myAmosExtenders.c,v $
 * $Revision: 1.5 $ $Date: 2013/03/08 07:04:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Example of Amos II extentions
 ****************************************************************************/

/*******************************************************************
 Test it:
 1. Run amos2
 2. load_extension("myAmosExtenders");
 3. mymult(2,3);
 4. myscalprod({1,2,3.1},{4.2,5,6});
 5. save "foo.dmp"; quit;
 6. amos2 foo.dmp
 7. mymult(2,3);  Saved in image!
 8. myscalprod({1,2},{1,2,3}); 
 9. myscalprod({1,2},{1,"a"}); 
********************************************************************/

#include "callout.h"

oidtype mymultBBF(a_callcontext cxt) 
     /* Implement in C a simple foreign function 
           mymult(Number x, Number y) -> Real 
        The implenetation is tolerant to illegal values so that
        it fails (no result) if some argument is illegal.
        This makes it possible to query data sets containing
        non-expected data, which is desired in a query language */
{
  oidtype x = a_arg(cxt, 1); // Bind x to 1st argument
  oidtype y = a_arg(cxt, 2); // Bind y to 2nd argument
  double rx, ry;             // Holding values of x and y

  if(!NUMERIC(a_datatype(x))) return nil; // Fail if non-numeric x
  if(!NUMERIC(a_datatype(y))) return nil; // Fail if non-numeric y
  IntoDouble(x, rx, cxt->env);   // Convert x to real rx
  IntoDouble(y, ry, cxt->env);   // Convert y to real ry
  a_bind(cxt, 3, mkreal(rx*ry)); // Bind the result to new real in parameter 3
  a_result(cxt);                 // emit the result
  return nil;                    // always return nil!
}

oidtype myscalprodBBF(a_callcontext cxt)
     /* Implement simple foreign function to compute the scalar product
        of two vectors:
        myscalprod(Vector x, Vector y) -> Real
        The function returns nothing if some argument is wrong.
     */
{
  int i, dimx, dimy;
  double prod=0;
  oidtype x = a_arg(cxt, 1); // Bind x to 1st argument
  oidtype y = a_arg(cxt, 2); // Bind y yo 2nd argument

  if(a_datatype(x)!=ARRAYTYPE) return nil; // Fail if x not array
  if(a_datatype(y)!=ARRAYTYPE) return nil; // fail if y not array
  dimx = a_arraysize(x);     // Get array dimensionality of x
  dimy = a_arraysize(y);     // Get array dimensionality of y
  if(dimx!=dimy) return nil; // Fail if dimensionality mismatch
  for(i=0;i<dimx;i++)
    {
      double rx, ry;
      oidtype ex = a_elt(x, i); // Bind ex to element i of array x
      oidtype ey = a_elt(y, i); // Bind ey to element i of array y

      if(!NUMERIC(a_datatype(ex))) return nil; // Fail if non-numeric ex
      if(!NUMERIC(a_datatype(ey))) return nil; // Fail if non-numeric ey
      IntoDouble(ex, rx, cxt->env); // Convert ex to number rx
      IntoDouble(ey, ry, cxt->env); // Convert ey to number ry
      prod = prod + rx*ry;
    }
  a_bind(cxt, 3, mkreal(prod));  // Bind the result value to parameter 3
  a_result(cxt);                 // Emit the result
  return nil;                    // Always return nil
}

EXPORT void a_initialize_extension(void)// EXPORT makes DLL entry.
     /* This code is executed when the extension is loaded.
        This happpend when either:
        1. call to load_extension("myAmosExtenders");. Alloed once only! 
        2. Call to reload_extension("myAmosExtenders");
        3. The system is initialized with an image where an extension is saved.
     */
{
  a_extimpl("mymult--+", mymultBBF); // Bind implementation name 'mymult--+' 
                                     // to address of C function mymultBBF
  a_extimpl("myscalprod--+", myscalprodBBF); 

  /* Execute AmosQL function definitions when loading the extender: */
  amosql("\
create function mymult(Number x, Number y) -> Real\
  as foreign 'mymult--+';\
\
create function myscalprod(Vector x, Vector y) -> Real\
  as foreign 'myscalprod--+';", 
	 FALSE); // Errors are not caught. 
  /* There will be an Amos exception if there the AmosQL defitions are wrong.

     Notice that the code is executed at the 3 different occations above. */
}
