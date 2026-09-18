/*****************************************************************************
 * AMOS2
 *
 * Author: 2013 Tore Risch, UDBL
 *
 * Description: Example of SVALI stream wrapper
 * Wraps CSV stream from:
 *   http://www.orgs.ttu.edu/debs2013/index.php?goto=cfchallengedetails
 * C interfaces:
 *   http://user.it.uu.se/~torer/publ/externalC.pdf
 * Storage manager documentation:
 *   http://user.it.uu.se/~torer/publ/aStorage.pdf
 * ===========================================================================
 * $Log: csvwrapper.c,v $
 * Revision 1.2  2013/05/08 06:10:04  torer
 * Added documentation links
 *
 * Revision 1.1  2013/05/07 15:11:07  torer
 * Added example of stream wrapper in C
 ****************************************************************************/

#include "callout.h"
#include "numarr.h"

oidtype my_CSV_tuplesBF(a_callcontext cxt)
     /* This foreign function reads a CSV file of numbers and emits them
        as scaled Numarray objects */
{
  char *filename;  // To contain CSV file name            
  dcl_oid(stream); // To hold I/O stream object
  dcl_oid(v);      // To hold read CSV row object
  double *a;       // To point to read numeric CSV row
  double a0, a6;   // Temporary numbers

  IntoString(a_arg(cxt,1), filename, 
             cxt->env); // Guard to convert argument 1 to filename string
  {unwind_protect_begin; // Catch errors in body below
  a_assign(stream, // Open file stream object and assign to variable
           a_fopen(filename, "r")); 
  for(;;) // Iterate over rows in stream
    {
      v = na_csv_double_readfn(cxt->env, stream, nil);
      // na_csv_double_readfn() reads a CSV line as a Numarray object
      // from an I/O stream (can be file, socket, pipe, etc.)
      if(v==eofsymbol) break; // Test for end-of-file

      // Access read Numarray a and do some scaling: 
      OfType(v, NUMARRAYTYPE, cxt->env);       // Sanity guard
      a = (double *)dr(v, numarraycell)->cont; // Get pointer to Numarray a

      a0    = a[1] * 1E-12; // 0 ts in seconds 
      a[1]  = a[0];         // 1 sid
      a[0]  = a0;
      a[2]  = a[2] * 1E-3;  // 2 x mm->m
      a[3]  = a[3] * 1E-3;  // 3 y mm->m
      a[4]  = a[4] * 1E-3;  // 4 z mm->m
      a[5]  = a[5] * 1E-6;  // 5 |v|
      a6    = a[7] * 1E-4;  // 6 vx
      a[7]  = a[8] * 1E-4;  // 7 vy
      a[8]  = a[9] * 1E-4;  // 8 vz
      a[9]  = a[6] * 1E-6;  // 9 |a|
      a[6]  = a6;
      a[10] = a[10] * 1E-4; // 10 ax
      a[11] = a[11] * 1E-4; // 11 ay
      a[12] = a[12] * 1E-4; // 12 az

      a_bind(cxt,2,v);  // Bind result Numarray to 2nd parameter 
      a_result(cxt);    // Emit a result tuple of 2 elements into SVALI
    }
  unwind_protect_catch; // This code is always executed:
  a_free(stream);       // Close stream and free I/O stream object
  unwind_protect_end;}  // End of catch block
  return nil;           // Always return nil!
}

EXPORT void a_initialize_extension(void)
     /* This code is executed when the extension (.dll or .so) is loaded.
        This happpens when either:
        1. Call to load_extension("csvwrapper");. Allowed once only! 
        2. Call to reload_extension("csvwrapper");
        3. The system is initialized with image where the extension is saved.
     */
{
  a_extimpl("my-csv-tuples-+",my_CSV_tuplesBF); // Register symbol
}
