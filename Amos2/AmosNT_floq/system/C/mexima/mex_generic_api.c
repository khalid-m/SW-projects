/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mex_generic_api.c,v $
 * $Revision: 1.19 $ $Date: 2014/01/12 20:32:26 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima Generic API
 * ========================================================================
 * $Log: mex_generic_api.c,v $
 * Revision 1.19  2014/01/12 20:32:26  torer
 * Missing {..}
 *
 * Revision 1.18  2014/01/12 16:33:12  torer
 * Apple cc 5.0 safe C code
 *
 * Revision 1.17  2013/08/06 16:21:20  thatr500
 * added check when index type is not available
 *
 * Revision 1.16  2013/08/01 12:55:33  thatr500
 * added getidentifier into generic MEXIMA API
 *
 * Revision 1.15  2013/02/28 09:22:57  thatr500
 * replace reserved C++ keyword 'delete' by 'remove'
 *
 * Revision 1.14  2013/02/24 10:01:36  torer
 * Reverted to original mexima
 *
 * Revision 1.10  2012/01/09 14:06:00  torer
 * *** empty log message ***
 *
 * Revision 1.9  2012/01/04 17:43:04  thatr500
 * save as array
 *
 * Revision 1.8  2012/01/04 16:44:13  thatr500
 * - maintain counter
 * - use array instead of list. It gains 5MB (lesser) than the original MBTREE
 *   for one million key/value pairs.
 *
 * Revision 1.7  2011/12/30 17:09:04  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.6  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.5  2011/12/28 16:20:20  thatr500
 * Unix conventions
 *
 * Revision 1.4  2011/12/28 10:21:34  thatr500
 * added code to avoid "biting-the-tail" (insertion + deletion)
 *
 * Revision 1.3  2011/12/27 12:53:28  torer
 * reformatting code
 *
 * Revision 1.2  2011/12/27 10:55:20  thatr500
 * M-x indent-region
 *
 * Revision 1.1  2011/12/27 09:39:59  thatr500
 * Mexima Generic API
 *
 **************************************************************************/
#include "storage.h"
#include "mex_generic_api.h"
#include "alisp.h"
#include "mexi.h"
#include "mexmeda.h"
#include "mexima.h"

oidtype delete_from_mexifn(bindtype env, oidtype mexi, oidtype key)
{
  struct kv kvp;
  struct mexicell  *mx;
  struct meda *m;
  oidtype k, v;
  int delflag;

  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);	
  if (m == NULL) return nil;
  /*the deleted k/v will be stored in kvp*/
  delflag = m->idxprops.remove(mx->idxp, (void*) key, &kvp,
			     COMPARE_SELECTION(m->idxprops.compare));
  if (delflag)
  {	
      k = (oidtype)kvp.key;
      v = (oidtype)kvp.val;
      /*Index does not reference the deleted k/v pair anymore*/
	  mx->count--;
      a_free(k);
      a_free(v);
      return t;
    }
  return nil;
}

oidtype delayed_delete_from_mexifn(bindtype env, oidtype mexi)
     /* Remove 'to-be-deleted' keys. It is to avoid biting-a-tail problem*/
{
  struct mexicell  *mx;
  struct meda *m;
  oidtype key;
  mexi_delete delfn;
  int delflag = FALSE;
	
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);
  if (m == NULL) return nil;
  delfn = m->idxprops.remove;	
  if(delfn==NULL) return lerror(ILLEGAL_ARGUMENT, mexi, env);
  while (mx->tbdlist != nil)
    {
      oidtype del;      
      key = hd(mx->tbdlist);
      del = delete_from_mexifn(env, mexi, key);	
      if(del!=nil) delflag=TRUE;
      mx = dr(mexi, mexicell);	
      a_setf(mx->tbdlist, tl(mx->tbdlist)); /*Move forward*/
    }		
  return (delflag?t:nil);
}

#define mark(x) incref(doid(x))

oidtype instert_into_mexifn(bindtype env, oidtype mexi, oidtype key, 
			     oidtype val)
{
  struct mexicell *mx = dr(mexi,mexicell);
  struct meda *m = get_medatable(mx->indextype);
  oidtype *oldval; /* Pointer to old V for key in mexi */
  int newflag; /* Set to TRUE if KVP existed in mexi before */
  if (m == NULL) return nil;
  oldval = m->idxprops.put(mx->idxp, (void *) key, &newflag, 
			   COMPARE_SELECTION(m->idxprops.compare));  

  if (newflag)
    {   //(key, val) did not exist yet
      mark(key); //index holds a ref
      a_let(*oldval, val); /* Initialize the new value */
	  mx->count++;
    } 
  else 
    {
      //replace the old value
      a_setf(*oldval, val); 
    }
  return val;
}

oidtype delayed_insert_into_mexifn(bindtype env, oidtype mexi)
     /* Insert a list of to-be-inserted kv. It is to avoid biting-a-tail 
        problem*/
{
  struct mexicell  *mx;
  oidtype key = nil;
  oidtype val = nil;

  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);
  
  while(mx->tbilist!=nil) 
    {
      a_setf(val, hd(mx->tbilist));
      a_setf(mx->tbilist, tl(mx->tbilist));
      a_setf(key, hd(mx->tbilist));
      instert_into_mexifn(env, mexi, key, val);
      mx = dr(mexi, mexicell);
      a_setf(mx->tbilist, tl(mx->tbilist));/*Move forward*/	  
    }
  a_free(key);
  a_free(val);
  a_setf(mx->tbilist, nil);
  return nil;
}

oidtype delayed_updates_of_mexifn(bindtype env, oidtype mexi)
{
  struct mexicell  *mx;

  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);
  if(mx->flag)
    {
      mx->flag = FALSE;
      delayed_delete_from_mexifn(env,mexi);	  
      delayed_insert_into_mexifn(env,mexi);
    }
  return nil;
}

/*--------------------------------------------------------*/
oidtype mexima_makefn(bindtype env, oidtype idxtype) 
{
 OfType(idxtype, STRINGTYPE, env);	
 return make_mexifn(env, idxtype);
}

/*--------------------------------------------------------*/
/* Remove all KVPs in a mexi */
int release_KVP_in_index(void *key, void *val, void *xa)
{ 
  oidtype k;
  oidtype v;

  k = (oidtype)key;
  v = (oidtype)val;
  a_free(k);
  a_free(v);	  
  return TRUE;
}

oidtype mexima_dropfn(bindtype env, oidtype mexi)
     /* Remove all KVPs from a mexi without deallocating the mexi itself*/
{	
  struct mexicell *mx;
  struct meda *m;
  
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);	
  if (mx->idxp != NULL) 
    {
      m = get_medatable(mx->indextype);
	  if (m == NULL) return nil;
      /*Because a mexi represents an index, we need
	    to iterate over the index to reclaim ref counter held
     	by each item in the index*/
	
	  mexima_full_mapC(env, mexi, release_KVP_in_index, NULL); 
      m->idxprops.drop(mx->idxp);// Free memory occupied the index
      a_free(mx->tbdlist);
      a_free(mx->tbilist);
    }
  return nil;
}

/*--------------------------------------------------------*/
oidtype mexima_getfn(bindtype env, oidtype key, oidtype mexi) 
     /* Return pointer to key in mexi.
        REturns NULL if key not in mexi. */
{  	
  struct mexicell *mx;
  oidtype *val;
  struct meda *m;
	
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);
  if (m == NULL) return nil;
  val = m->idxprops.get(mx->idxp, (void *) key, 
			COMPARE_SELECTION(m->idxprops.compare));
  if(val != NULL) return *(oidtype*)val;
  return nil; /* Value not found */
}

/*--------------------------------------------------------*/
oidtype mexima_putfn(bindtype env, oidtype key, oidtype mexi, 
                            oidtype val)
     /* Insert our update KVP in mexi */
{
  OfType(mexi, MEXITYPE, env);
  if(dr(mexi, mexicell)->flag) /* Delay inserting while mapping over self */
    {
      push(key, dr(mexi, mexicell)->tbilist);
      push(val, dr(mexi, mexicell)->tbilist);
      return val;
    }		
  else return 
	 /*Immediately insert this object*/
	 instert_into_mexifn(env, mexi, key, val);
}

/*--------------------------------------------------------*/
int mexima_range_mapC(bindtype env, oidtype mexi, oidtype lower, 
                             oidtype upper, KVPmapper fn, void * xa)
{
  struct mexicell *mx;
  struct meda *m;
	
  OfType(mexi, MEXITYPE, env);	
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);
  if (m == NULL) return nil;
  {unwind_protect_begin;
  mx->flag = TRUE;
  m->idxprops.range_mapping(mx->idxp, fn, (void *) lower,
			   (void*) upper,
			   COMPARE_SELECTION(m->idxprops.compare), xa);
  unwind_protect_catch;
  delayed_updates_of_mexifn(env, mexi);
  unwind_protect_end};  
  return TRUE;
}

/* Lisp interface */

struct applymapdata
{
  oidtype mapfn;
  bindtype env;
};

int applymapfn(void *key, void *val, void *xa)
     /*Applying function on each returned tuple*/
{
  struct applymapdata* mdata = (struct applymapdata*) xa;  
  oidtype res;
	
  a_let(res, call_lisp(mdata->mapfn, mdata->env, 2, (oidtype)key, 
		       (oidtype)val));
  if (res == nil) return FALSE; /* Stop mapping */
  a_free(res);
  return TRUE; /* Continue mapping */
}

oidtype mexima_range_mapfn(bindtype env, oidtype mexi, oidtype lower, 
			   oidtype upper, oidtype fn)
{
  struct applymapdata mdata;

  OfType(mexi, MEXITYPE, env);
  a_let(mdata.mapfn, fn);
  mdata.env = env;	
  {unwind_protect_begin;	
  mexima_range_mapC(env, mexi, lower, upper,
                         applymapfn, (void *)&mdata);
  unwind_protect_catch;
  a_free(mdata.mapfn);
  unwind_protect_end;}
  return t;
}

/*Implementation of full mapping of index */
int mexima_full_mapC(bindtype env, oidtype mexi, KVPmapper fn,
                                void *xa)
{
  struct mexicell *mx;
  struct meda *m;
	
  OfType(mexi, MEXITYPE, env);	
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);
  if (m == NULL) return nil;
  {unwind_protect_begin;
  mx->flag = TRUE;
  m->idxprops.full_mapping(mx->idxp, fn, COMPARE_SELECTION(m->idxprops.compare), xa);
  unwind_protect_catch;
  delayed_updates_of_mexifn(env, mexi);
  unwind_protect_end};
  return TRUE;
}

/* Lisp interface */
oidtype mexima_full_mapfn(bindtype env, oidtype mexi, oidtype fn)
{
  struct applymapdata mdata;

  OfType(mexi, MEXITYPE, env);
  a_let(mdata.mapfn, fn);	
  mdata.env = env;
  {unwind_protect_begin;	
  mexima_full_mapC(env, mexi, applymapfn, (void *)&mdata);
  unwind_protect_catch;
  a_free(mdata.mapfn);
  unwind_protect_end;}
  return t;
}

/*--------------------------------------------------------*/
oidtype mexima_deletefn(bindtype env, oidtype key, oidtype mexi)
{
  OfType(mexi, MEXITYPE, env);

  if (dr(mexi, mexicell)->flag) /* Delay delete if mapping over self */
   {
     push(key, dr(mexi, mexicell)->tbdlist);
     return nil;
   }
  else return delete_from_mexifn(env, mexi, key); 
}
/*--------------------------------------------------------*/
/*Get identifier number of mexi object if applicable.*/
oidtype mexima_getidentifierfn(bindtype env, oidtype mexi)
{
  struct mexicell *mx;
  struct meda *m;
	
  OfType(mexi, MEXITYPE, env);	
  mx = dr(mexi, mexicell);
  m = get_medatable(mx->indextype);
  if (m != NULL) {
	return mkinteger(m->idxprops.getidentifer(mx->idxp));
  }
  return nil;
}
