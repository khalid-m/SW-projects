/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2013 Tore Risch, UDBL
 * $RCSfile: debswrapper.c,v $
 * $Revision: 1.7 $ $Date: 2013/04/21 22:08:47 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SVALI extensions for DEBS 2013 Challenge
 * ===========================================================================
 * $Log: debswrapper.c,v $
 * Revision 1.7  2013/04/21 22:08:47  torer
 * *** empty log message ***
 *
 * Revision 1.6  2013/04/18 17:42:43  torer
 * Numarray CSV reader functions are now named:
 *
 * oidtype na_csv_double_readfn(bindtype env, oidtype str, oidtype delim);
 * oidtype na_csv_float_readfn(bindtype env, oidtype str, oidtype delim);
 *
 * Revision 1.5  2013/04/14 10:51:47  torer
 * Removed old code from the DEBS-wrapper
 *
 * Revision 1.4  2013/04/13 08:42:46  torer
 * New stream wrapper function
 * debs_event_file_tuples(Charstring filename, Number half) -> Bag of Numarray
 *
 * Revision 1.3  2013/04/12 11:33:03  torer
 * Naive C version of eventconv() now passes regression. Factor 2.3 faster.
 *
 * Revision 1.2  2013/04/12 09:47:12  torer
 * eventconv() in C
 *
 * Revision 1.1  2013/04/12 08:33:50  torer
 * *** empty log message ***
 *
 ****************************************************************************/

#include "amos.h"
#include "numarr.h"

oidtype debs_event_file_tuplesBBF(a_callcontext cxt)
{
  oidtype file = a_arg(cxt,1);
  char *filename;
  oidtype half = a_arg(cxt, 2);
  double dhalf, a0, a6;
  oidtype stream = nil, v;
  double *a;
  oidtype res=nil;
  IntoDouble(half, dhalf, cxt->env);
  IntoString(file, filename, cxt->env);
  a_setf(stream,a_fopen(filename, "r"));
  for(;;)
    {
      v = na_csv_double_readfn(cxt->env, stream, nil);
      if(v==eofsymbol) break;
      OfType(v, NUMARRAYTYPE, cxt->env);
      a = (double *)dr(v, numarraycell)->cont;
      a0 = (a[1] - dhalf) * 1E-12; /*0 ts: */
      a[1] = a[0]; /*1 sid*/
      a[0] = a0;
      a[2] = a[2] * 1E-3;  /*2 x mm->m*/
      a[3] = a[3] * 1E-3;  /*3 y mm->m*/
      a[4] = a[4] * 1E-3;  /*4 z mm->m*/
      a[5] = a[5] * 1E-6; /*5 |v|*/
      a6 = a[7] * 1E-4; /*6 vx*/
      a[7] = a[8] * 1E-4; /*7 vy*/
      a[8] = a[9] * 1E-4; /*8 vz*/
      a[9] = a[6] * 1E-6; /*9 |a|*/
      a[6] = a6;
      a[10] = a[10] * 1E-4; /*10 ax*/
      a[11] = a[11] * 1E-4; /*11 ay*/
      a[12] = a[12] * 1E-4; /*12 az*/
      a_bind(cxt,3,v);
      a_result(cxt);
    }
  a_fclose(stream);
  a_free(stream);
  return nil;
}

EXPORT void a_initialize_extension(void)
     /* This code is executed when the extension is loaded.
        This happpens when either:
        1. Call to load_extension("debswrapper");. Allowed once only! 
        2. Call to reload_extension("debswrapper");
        3. The system is initialized with an image where an extension is saved.
     */
{
  a_extimpl("debs_event_file_tuples--+",debs_event_file_tuplesBBF);
}
