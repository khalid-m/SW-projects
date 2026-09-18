/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexutilities.c,v $
 * $Revision: 1.1 $ $Date: 2011/12/13 09:53:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: <description>
 * ===========================================================================
 * $Log: mexutilities.c,v $
 * Revision 1.1  2011/12/13 09:53:19  thatr500
 * new files
 *
 *
 ****************************************************************************/
#include "mexutilities.h"
oidtype extractkeyvalue(a_callcontext cxt){
  oidtype l = a_arg(cxt,1);
  
  //Only the first (key, value) is extracted
  if (listp(l) && hd(l)) {
    a_bind(cxt,2, hd(l));
    a_bind(cxt,3, a_elt(hd(l), 1));
  } else {
    a_bind(cxt,2, l);
    a_bind(cxt,3, a_elt(l, 1));
  }
  a_result(cxt);
  return nil;
}

/*--------------------------------------------------------------------------
Get the latest resolvent of a given function name
--------------------------------------------------------------------------*/
oidtype getlatestresolvent1(char fname[]){
  dcl_oid(fn);
  /* Mexima always generate one resolvent (X) for the given 
    name. (X) raises an error 
    "Foreign funciton is not implemented!" each time it is invoked.
    
    This function picks the latest resolvent of fname if one has created 
    another of fname. Otherwise (X) is returned.*/
  fn = call_lisp(mksymbol("getlatestresolvent"), 
		 varstack, 1, mksymbol(fname));
  a_return(fn);
}

/*-----------------------------------------------------
 Compute index identifier on given position of indexed
 function.
-----------------------------------------------------*/
int getIndexId(int pos, oidtype indexedFunction) {
  dcl_scan(s); 
  dcl_tuple(result);  /* To hold results from Amos function calls */
  dcl_tuple(arg);
  dcl_oid(fun);
  int indexID;
	
  // Get the function 
  a_setf(fun,
	 a_getfunction(a_callback_connection,		      
		       "INTEGER.FUNCTION.GET_INDEX_IDENTIFIER->INTEGER",
		       FALSE));

  // Initialize arguments
  a_newtuple(arg, 2, FALSE);
  a_setintelem(arg, 0, pos, FALSE);
  a_setobjectelem(arg, 1, indexedFunction, FALSE);

  // Callin Amos2 
  a_callfunction(a_callback_connection,s,fun,arg,FALSE); 
  
  // Get result
  a_getrow(s, result, FALSE);
  
  // Get ID from the result
  indexID = a_getintelem(result, 0, FALSE);

  free_tuple(result);
  free_scan(s);
  free_tuple(arg);
  free_oid(fun);
  return indexID;
}
/*-----------------------------------------------------
  Register utilities  
  -----------------------------------------------------*/
void register_utilities() {
  a_extimpl("extractkeyvalue", extractkeyvalue);
}
