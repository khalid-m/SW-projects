/*****************************************************************************
 * AMOS2
 *
 * Author: 2013 Tore Risch, UDBL
 * $RCSfile: myLispExtenders.c,v $
 * $Revision: 1.4 $ $Date: 2013/03/02 12:04:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Example of aLisp extenders
 * ===========================================================================
 * $Log: myLispExtenders.c,v $
 * Revision 1.4  2013/03/02 12:04:33  torer
 * Nicer code
 *
 * Revision 1.3  2013/03/01 20:22:20  torer
 * Removed call to min() which is not defined in Unix
 *
 * Revision 1.2  2013/03/01 20:07:51  torer
 * More explanation
 *
 * Revision 1.1  2013/03/01 20:02:09  torer
 * Added example of aLisp extender
 *
 ****************************************************************************/

/*******************************************************************
 Usage:
 1. Compile using Visual Studio 2010 or later by opening project file
    myLispExtenders.vcxproj and click 'build solution'.
    Then AmosNT/bin/myLispExtenders.dll will be created
 2. Run 'alisp' in any folder
 3. (load-extension "myLispExtenders" t) ;; will be 'saved' in image
 4. Test with: 
    (mymult 2 3)
    (myscalprod (vector 1 2 3)(vector 4 5 6))
    (myscalprod (vector 1 2 3)(vector 4 5 "a")) ;; error
 5. (rollout "myimage.dmp") ;; save image
    (quit)
 6. Run 
     alisp myimage.dmp
 7. (myscalprod (vector 1 2 3)(vector 4 5 6)) ;; extender restored

********************************************************************/

#include "alisp.h"

int differing_dimensions; // User error code

oidtype mymultfn(bindtype env, oidtype x, oidtype y)
     /* Multiply boxed numbers x and y */
{
  double rx, ry;

  IntoDouble(x, rx, env); // dereference x to number rx
  IntoDouble(y, ry, env); // dereference y to number ry
  return mkreal(rx*ry);   // make boxed number of product
}

oidtype myscalprodfn(bindtype env, oidtype x, oidtype y)
     /* Scalar product of vectors x and y */
{
  int i, dimx, dimy;
  double prod=0;

  OfType(x, ARRAYTYPE, env); // Check that x is array
  OfType(y, ARRAYTYPE, env); // Check that y is array

  dimx = a_arraysize(x);     // Get array dimensionality
  dimy = a_arraysize(y);
  if(dimx!=dimy) return lerror(differing_dimensions, x, env); // User error
  for(i=0;i<dimx;i++)
    {
      double rx, ry;
      oidtype ex = a_elt(x, i); // Access array element i
      oidtype ey = a_elt(y, i);
		
      IntoDouble(ex, rx, env);
      IntoDouble(ey, ry, env);
      prod = prod + rx*ry;
    }
  return mkreal(prod);  // box the result
}

EXPORT void a_initialize_extension(void)
{
  differing_dimensions = a_register_error("Vector dimensions differ");
  extfunction2("mymult", mymultfn);
  extfunction2("myscalprod", myscalprodfn);
}
