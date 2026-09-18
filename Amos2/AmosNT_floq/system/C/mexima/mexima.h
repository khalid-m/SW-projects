/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexima.h,v $
 * $Revision: 1.16 $ $Date: 2013/08/01 12:55:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Header file for Mexima C interfaces
 * ========================================================================
 * $Log: mexima.h,v $
 * Revision 1.16  2013/08/01 12:55:33  thatr500
 * added getidentifier into generic MEXIMA API
 *
 * Revision 1.15  2013/02/28 09:22:57  thatr500
 * replace reserved C++ keyword 'delete' by 'remove'
 *
 * Revision 1.14  2013/01/30 13:38:53  thatr500
 * used starsymbol instead
 *
 * Revision 1.13  2012/01/13 19:42:59  torer
 * Revert to storage.h
 *
 * Revision 1.12  2012/01/13 19:27:24  torer
 * Corrected include!
 *
 * Revision 1.11  2012/01/12 07:58:21  thatr500
 * - changed signature a_initialize_extension
 * - fixed "Loading Borland /VC++ dynamic dll" on Unix
 *
 * Revision 1.10  2011/12/30 17:09:05  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.9  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.8  2011/12/24 11:50:00  thatr500
 * new design
 *
 * Revision 1.6  2011/12/13 10:10:21  thatr500
 * removed boxed property
 *
 * Revision 1.5  2011/12/02 12:39:49  thatr500
 * MEXIMA core
 *
 * Revision 1.4  2011/05/04 08:26:53  thatr500
 * *** empty log message ***
 *
 **************************************************************************/
#ifndef _mexima_h_
#define _mexima_h_

#include "storage.h" /* aStorage API */

struct kv
{
  void* key;
  void* val;
};

/*Compute key*/
typedef void* (* mexi_compute_key) (void *key);

/*Compare key*/
typedef int (* mexi_compare) (void * key1, void *key2);

/*Create new index*/
typedef void* (* mexi_create)(unsigned int size);

/*Put*/
typedef void* (* mexi_put) (void *ind, void *key, int *newflag, 
			     mexi_compare cmpfn);
/*Get*/
typedef void* (* mexi_get) (void *ind, void *key, 
			     mexi_compare cmpfn);
/*Delete*/
typedef int (* mexi_delete)(void *ind, void *key, struct kv *kvp,
				   mexi_compare cmpfn);
/*Drop*/
typedef void (* mexi_drop) (void *ind);

/*Applied Mapp Fn*/
typedef int (* KVPmapper) (void *k, void *v,  void *xa);

/*Mapper on a given range*/
typedef void (* mexi_range_mapping) 
     (void *ind , KVPmapper mapfn, 
      void *lower, void *upper, mexi_compare cmpfn, void *xa);

/*Total mapper to iterate all items in the index ind*/
typedef void (* mexi_full_mapping) (void *ind , KVPmapper mapfn, 
			      mexi_compare cmpfn, void *xa);

/*Get identifer number*/
typedef int (* mexi_getidentifier)(void *ind);

#define  COMPARE_SELECTION(fn) (fn?fn:(mexi_compare)a_compare)


/*External index routines*/
struct mexi_index_props {  
  char name[10];
  char suffix[10];
  /*access method*/
  mexi_create create;
  mexi_put    put;
  mexi_get    get;
  mexi_delete remove;
  mexi_drop   drop;
  mexi_full_mapping full_mapping;  
  mexi_range_mapping range_mapping;
  mexi_compute_key computekey;
  mexi_compare  compare;
  mexi_getidentifier getidentifer;
};


EXPORT oidtype mexima_getfn(bindtype env, oidtype key, oidtype mexi);

EXPORT oidtype mexima_putfn(bindtype env, oidtype key, oidtype mexi, 
                            oidtype val);

EXPORT oidtype mexima_deletefn(bindtype env, oidtype key, oidtype mexi);

EXPORT int mexima_range_mapC(bindtype env, oidtype mexi, oidtype lower, 
			     oidtype upper, KVPmapper fn, void * xa);

EXPORT int mexima_full_mapC(bindtype env, oidtype mexi, KVPmapper fn,
			    void *xa);

EXPORT oidtype mexima_range_mapfn(bindtype env, oidtype mexi, oidtype ilower, 
			   oidtype iupper, oidtype fn);

EXPORT oidtype mexima_full_mapfn(bindtype env, oidtype mexi, oidtype fn);

EXPORT oidtype mexima_makefn(bindtype env, oidtype idxtype);

EXPORT oidtype mexima_dropfn(bindtype env, oidtype mexi);

/*Define a new index type (strIndextype) given a struct of properties (access methods)*/
EXPORT  void define_index(struct mexi_index_props idxro);

/*Get identifier number of mexi object if applicable.*/
EXPORT  oidtype mexima_getidentifierfn(bindtype env, oidtype mexi);

#endif
