/*****************************************************************************
 * AMOS2
 *
 * Author: 2013 Tore Risch, UDBL
 *
 * Description: Example of foreign function generating numarray tuples
 * C interfaces:
 *   http://user.it.uu.se/~torer/publ/externalC.pdf
 * Storage manager documentation:
 *   http://user.it.uu.se/~torer/publ/aStorage.pdf
 * ===========================================================================
 * $Log: numtuples.c,v $
 * Revision 1.1  2013/06/25 10:22:52  torer
 * another example
 *
 ****************************************************************************/

#include "callout.h"
#include "numarr.h"
#include "a_time.h"

oidtype numtuplesBF(a_callcontext cxt)
     /* This foreign function generates an infinite stream of
        random integer tuples */
{
  dcl_oid(v);   // To hold constructed numarray tuple
  int *a;
  double delay;           // To point to new numarray of integers
  double start = rnow(); //time stamp as seconds from epoc
  int i=0; //tuple counter
  /* Emitted tuples have format (TS, ID#, VAL) */
  IntoDouble(a_arg(cxt,1), delay,// Delay between tuples in seconds 
	     cxt->env); 
  for(;;)
    {
      v = na_new_iarray(3); // Allocate new numarray of integers of size 3
      a = (int *)dr(v,numarraycell)->cont; // The array content
      a[0] = (int)((rnow()-start)*1000000); // time in us since start
      a[1] = i++;       // tuple #
      a[2] = rand();    // random number
      a_bind(cxt,2,v);  // Bind result Numarray to 2nd parameter 
      a_result(cxt);    // Emit a result tuple of argument and result 
      // v is freed automatically
      a_sleep(delay);   // Wait between tuples
    }
  return nil;       // Return nil to avoid compiler warning
}

EXPORT void a_initialize_extension(void)
     /* This code is executed when the extension (.dll or .so) is loaded.
        This happpens when either:
        1. Call to load_extension("numtuples");. Allowed once only! 
        2. Call to reload_extension("numtuples");
        3. The system is initialized with image where the extension is saved.
     */
{
  a_extimpl("numtuples-+",numtuplesBF); // Register symbol
}
