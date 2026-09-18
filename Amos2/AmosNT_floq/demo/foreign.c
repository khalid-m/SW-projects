/*****************************************************************************
 * AMOS2
 *
 * Author: 2014 Tore Risch, UDBL
 * $RCSfile: foreign.c,v $
 * $Revision: 1.2 $ $Date: 2014/01/06 19:12:10 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Examples of Amos II foreign function definitions in C
 ****************************************************************************/

#include "callout.h"
#include <math.h>

/***************************************************************************
 * NOTICE:                                                                 *
 * To include the Amos foreign function definitions below in an Amos       *
 * database image 'mydb.dmp' you have to:                                  *
 * 1. Compile the program                                                  *
 *    The compilation will create a file myForeign.dll (Windows) or        *
 *    myForeign.so (Unix) in the folder ../bin                             *
 *    Windows:                                                             *
 *       Use the MS Visual Studio project file 'myForeign.vcxproj'         *
 *    Linux:                                                               *
 *       Set environment variable:                                         *
 *          export ARCHITECTURE=Linux32                                    *
 *       Compile with:                                                     *
 *          make ../bin/myForeign.so                                       *
 *    OSX:                                                                 *
 *       Set environment variable:                                         *
 *          export ARCHITECTURE=Apple32                                    *
 *       Compile with:                                                     *
 *          make ../bin/myForeign.so                                       *
 * 2. Make a database image 'mydb.dmp' by running the AmosQL script        *
 *      Windows:  ..\bin\amos2 -O myCdbdef.amosql                          *
 *      Unix:     ../bin/amos2 -O myCdbdef.amosql                          *
 * 3. Run amos with database image 'mydb.dmp*:                             *
 *      Windows:  ..\bin\amos2 mydb.dmp                                    *
 *      Unix:     ../bin/amos2 mydb.dmp                                    *
 *    Test the functions in AmosQL queries:                                *
 *      helloworld();                                                      *
 *      mysqrt(2);                                                         *
 *      mysqrt(0);                                                         *
 *      mysqrt(-1);                                                        *
 *      myabs(-1.22);                                                      *
 *      select x from Number x where myabs(x)=2.3;                         *
 *      cota(1,5);                                                         *
 *      set :b = cota(1,1000000);                                          *
 *      count(:b);                                                         *
 *      cota(5,1);                                                         *
 **************************************************************************/

void helloworldF(a_callcontext cxt, a_tuple tpl) 
{
  /* Set first result tuple element (position 0): */  
  a_setstringelem(tpl,0,"Hello world",FALSE); 

  /* Emit result to Amos II kernel: */
  a_emit(cxt,tpl,FALSE);            
}

void mysqrtBF(a_callcontext cxt, a_tuple tpl)
{
  double x;

  x = a_getdoubleelem(tpl, 0, FALSE);	// Pick up the real argument
  if (x < 0.0) 
    {
      // Don't return any value if x < 0
    }
  else if (x == 0)
    {
      // One root if x is zero
      a_setdoubleelem(tpl, 1, 0.0, FALSE);
      a_emit(cxt, tpl, FALSE);
    }
  else
    {
      // Two roots
      a_setdoubleelem(tpl, 1, sqrt(x), FALSE);
      a_emit(cxt, tpl, FALSE);
      a_setdoubleelem(tpl, 1, -sqrt(x), FALSE);
      a_emit(cxt, tpl, FALSE);
    }
}

void myabsBF(a_callcontext cxt, a_tuple tpl)
{
  double x;
     
  x = a_getdoubleelem(tpl, 0, FALSE); // pick up first argument
  if(x<0) a_setdoubleelem(tpl, 1, -x, FALSE);
  else    a_setdoubleelem(tpl, 1 , x, FALSE);
  a_emit(cxt, tpl, FALSE);
}

void myabsFB(a_callcontext cxt, a_tuple tpl)
{
  // Inverse of abs(x)
  double x;
     
  x = a_getdoubleelem(tpl, 1, FALSE); // pick up result
  if(x==0.0)
    {
      a_setdoubleelem(tpl, 0, x, FALSE);
      a_emit(cxt, tpl, FALSE);
    }
  else
    {
      a_setdoubleelem(tpl, 0, x, FALSE);
      a_emit(cxt, tpl, FALSE);
      a_setdoubleelem(tpl, 0, -x, FALSE);
      a_emit(cxt, tpl, FALSE);
    }
}

void cotaBBF(a_callcontext cxt, a_tuple tpl)
{
  int low = a_getintelem(tpl,0,FALSE), up = a_getintelem(tpl,1,FALSE), i;

  for(i=low;i<=up;i++)
    {
      a_setintelem(tpl,2,i,FALSE); 
      a_emit(cxt,tpl,FALSE);
    }
}


EXPORT void a_initialize_extension(void)// EXPORT required to make DLL entry!
     /* This code is executed when the extension is loaded.
        This happpens whenever:
        1. call to load_extension("myForeign");. Alloed once only! 
        2. Call to reload_extension("myForeign");
        3. The system is initialized with an image in which an extension 
	is defined.
     */
{
  /* Define symbols used in AmosQL foreign function definitions: */
  a_extfunction("helloworld+",helloworldF);
  a_extfunction("mysqrt-+",mysqrtBF);
  a_extfunction("myabs-+",myabsBF);
  a_extfunction("myabs+-",myabsFB);
  a_extfunction("cota--+",cotaBBF);
  /* The function signatures are defined in the script myCdbdef.amosql */
}
