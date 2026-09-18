/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mex_relation.c,v $
 * $Revision: 1.9 $ $Date: 2013/08/06 16:20:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima vs (index on) Relation
 * ========================================================================
 * $Log: mex_relation.c,v $
 * Revision 1.9  2013/08/06 16:20:46  thatr500
 * removed OSX warnings
 *
 * Revision 1.8  2013/02/23 17:41:39  torer
 * Removed all memory cdereferences
 *
 * Revision 1.7  2012/01/09 14:06:00  torer
 * *** empty log message ***
 *
 * Revision 1.6  2012/01/05 09:15:37  torer
 * Fixed memory dereferences
 *
 * Revision 1.5  2011/12/30 17:09:04  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.4  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.3  2011/12/28 10:21:34  thatr500
 * added code to avoid "biting-the-tail" (insertion + deletion)
 *
 * Revision 1.2  2011/12/27 10:55:20  thatr500
 * M-x indent-region
 *
 * Revision 1.1  2011/12/27 09:41:35  thatr500
 * index on relation (function)
 *
 *
 **************************************************************************/
#include "amos.h"
#include "storagetypes.h"
#include "mexima.h"
#include "mexi.h"
#include "mexmeda.h"
#include "mexglobvals.h"
#include "mex_generic_api.h"

/*--------------------------------------------------------------------------
  Create an index
  --------------------------------------------------------------------------*/
oidtype mex_idm_creator(bindtype env, oidtype indhdr, size_t parm)
{
  struct meda *m;
  oidtype mexi;
  oidtype idxtype;

  m =  get_medatable(dr(indhdr, indexcell)->type); /*look up meta data*/
  if (m == NULL) return nil;
  a_let(idxtype, mkstring(m->idxprops.name));
  a_let(mexi, mexima_makefn(env, idxtype));
  OfType(mexi, MEXITYPE, env);
  a_setf(dr(mexi, mexicell)->owner, dr(indhdr, indexcell)->owner); 
  a_free(idxtype);
  a_return(mexi);
}

/*--------------------------------------------------------------------------
  Get data from an index given a key
  --------------------------------------------------------------------------*/
oidtype mex_idm_getter(bindtype env, oidtype indhdr, oidtype mexi,
		       oidtype key)
{
  return mexima_getfn(env, key, mexi);
}
/*--------------------------------------------------------------------------
  Get data from an index given a key, a value
  --------------------------------------------------------------------------*/
oidtype mex_idm_inserter(bindtype env, oidtype indhdr, oidtype mexi, 
			 oidtype key,  oidtype val)
{
  return mexima_putfn(env,key,mexi,val);
  
}

/*--------------------------------------------------------------------------
  Delete data from an index given a key
  --------------------------------------------------------------------------*/
oidtype mex_idm_deleter(bindtype env, oidtype indhdr, oidtype mexi, 
			oidtype key)
{
  return mexima_deletefn(env, key,mexi);
}

/*--------------------------------------------------------------------------
  Number of rows
  --------------------------------------------------------------------------*/
int mex_idm_counter(bindtype env, oidtype indhdr, oidtype xt)
{
  return dr(indhdr, indexcell)->cardinality;
}
/*--------------------------------------------------------------------------
  Drop an index
  --------------------------------------------------------------------------*/
int mex_idm_dropper(bindtype env, oidtype inhdr)
{
  // Derefrences 
  mexima_dropfn(env, dr(inhdr, indexcell)->rows);
  return dr(inhdr, indexcell)->pos;
} 

/*-------------------------------------------------------------------
  Map over items in an index
  ----------------------------------------------------------------------*/
struct mapdata
{
  maphash_function mapfn;
  oidtype indhdr;
  void* xa;
};

/*Applying maphash_function to each returned tuple*/
int idxm_mapperfn(void *key, void *val, void *xa)
{
  struct mapdata* mdata = (struct mapdata*) xa;  
  int res = FALSE;
  res = (mdata->mapfn)(varstack, mdata->indhdr, (oidtype) key, 
		       (oidtype) val, mdata->xa);
  return res;
}

void mex_idm_mapper(bindtype env, oidtype indhdr, oidtype mexi,
		    index_mapfn fn, void *x) 
{
  struct mapdata mdata;
  struct meda *m;
	
  m = get_medatable(dr(mexi, mexicell)->indextype);
  if (m == NULL) return;
  mdata.mapfn = fn;
  mdata.indhdr = indhdr;
  mdata.xa = x;	

  dr(mexi, mexicell)->flag = TRUE;
  m->idxprops.full_mapping(dr(mexi, mexicell)->idxp, idxm_mapperfn, 
			   COMPARE_SELECTION(m->idxprops.compare), &mdata);
  dr(mexi, mexicell)->flag = FALSE;
}
