/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mex_relation.h,v $
 * $Revision: 1.3 $ $Date: 2013/08/06 16:20:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima vs (index on) Relation
 * ========================================================================
 * $Log: mex_relation.h,v $
 * Revision 1.3  2013/08/06 16:20:46  thatr500
 * removed OSX warnings
 *
 * Revision 1.2  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.1  2011/12/27 09:41:35  thatr500
 * index on relation (function)
 * 
 **************************************************************************/

#ifndef _mex_relation_h_
#define _mex_relation_h_
/*-----------------------------------------------------------------------*/
/*                    Signatures of index hooks   
/*                    MEXIMA - (INDEX ON) RELATION                       */
/*-----------------------------------------------------------------------*/

oidtype mex_idm_creator(bindtype env, oidtype indhdr, size_t parm);

oidtype mex_idm_getter(bindtype env, oidtype indhdr, oidtype mexi,
					oidtype key);
oidtype mex_idm_inserter(bindtype env, oidtype indhdr, oidtype mexi, 
					oidtype key,  oidtype val);

oidtype mex_idm_deleter(bindtype env, oidtype indhdr, oidtype mexi, 
					 oidtype key);

int mex_idm_counter(bindtype env, oidtype indhdr, oidtype xt);

int mex_idm_dropper(bindtype env, oidtype inhdr);

int idxm_mapfn(void *key, void *val, void *xa);

void mex_idm_mapper(bindtype env, oidtype indhdr, oidtype mexi,
				 index_mapfn fn, void *x);

#endif
