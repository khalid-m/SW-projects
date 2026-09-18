/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mex_foreign.h,v $
 * $Revision: 1.3 $ $Date: 2013/08/06 16:20:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima - Index routines through foreign functions
 * ========================================================================
 * $Log: mex_foreign.h,v $
 * Revision 1.3  2013/08/06 16:20:45  thatr500
 * removed OSX warnings
 *
 * Revision 1.2  2011/12/29 08:48:22  thatr500
 * add new line at the end of file
 *
 * Revision 1.1  2011/12/27 09:40:46  thatr500
 * Index routines through foreign functions
 *
 **************************************************************************/
#ifndef _mex_foreign_h_
#define _mex_foreign_h_
#include "storage.h"

oidtype mexf_creator(bindtype env, oidtype indhdr, size_t parm);

oidtype mexf_getter(bindtype env, oidtype indhdr, oidtype xt,
					oidtype key);

oidtype mexf_inserter(bindtype env, oidtype indhdr, oidtype xt, 
					oidtype key,  oidtype val);

oidtype mexf_deleter(bindtype env, oidtype indhdr, oidtype xt, 
					 oidtype key);

int mexf_counter(bindtype env, oidtype indhdr, oidtype xt);

void mexf_mapper(bindtype env, oidtype indhdr, oidtype xt,
				 maphash_function f, void *x);

oidtype mexf_register_indextype0(bindtype env, oidtype name, oidtype stubs);

/*Register Mexima - foreign functions*/
void register_mexf();
#endif


									  
