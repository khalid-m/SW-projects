/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexutilities.h,v $
 * $Revision: 1.2 $ $Date: 2012/01/13 19:16:09 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Utilities
 * ===========================================================================
 * $Log: mexutilities.h,v $
 * Revision 1.2  2012/01/13 19:16:09  torer
 * Correct include files!
 *
 * Revision 1.1  2011/12/13 09:53:19  thatr500
 * new files
 *
 * Revision 1.2  2011/05/04 08:26:53  thatr500
 ****************************************************************************/
#include "amos.h"

/* Extract the first (key, value)*/
oidtype extractkeyvalue(a_callcontext cxt);

/* Get index identifier on function f at a given pos */
int getIndexId(int pos, oidtype f );

/* Get the latest resolvent of a given function name*/
oidtype getlatestresolvent1(char fname[]);

/* Register some utilities as foreign functions*/
void register_utilities();
