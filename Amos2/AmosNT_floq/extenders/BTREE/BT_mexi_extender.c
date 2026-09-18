/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: BT_mexi_extender.c,v $
 * $Revision: 1.7 $ $Date: 2013/02/28 09:21:12 $
 * $State: Exp $ $Locker:  $
 *
 * Description: MEXIMA Extender for BTREE index
 * ===========================================================================
 * $Log: BT_mexi_extender.c,v $
 * Revision 1.7  2013/02/28 09:21:12  thatr500
 * replace reserved C++ keyword 'delete' by 'remove'
 *
 * Revision 1.6  2013/01/30 13:38:52  thatr500
 * used starsymbol instead
 *
 * Revision 1.5  2013/01/09 15:01:19  thatr500
 * Index extension is self contained : defining a new index type
 *
 * Revision 1.4  2012/01/12 07:45:43  thatr500
 * fix Unix compilation error
 *
 * Revision 1.3  2011/12/30 17:57:51  thatr500
 * Unix convention
 *
 * Revision 1.2  2011/12/30 17:11:09  thatr500
 * updated b/c of new deletion interface (by Sobhan)
 *
 * Revision 1.1  2011/12/30 11:03:14  torer
 * BTREE extender added
 *
 * Revision 1.1  2011/12/29 17:36:48  torer
 * Stored all BTREE index code in separate directory
 *
 * Revision 1.6  2011/12/29 09:31:29  torer
 * *** empty log message ***
 *
 * Revision 1.5  2011/12/24 11:42:37  thatr500
 * use of newflag & delflag
 *
 * Revision 1.4  2011/12/21 09:30:32  torer
 * Use of EXPORT
 *
 * Revision 1.3  2011/12/20 21:10:13  thatr500
 * added comments
 *
 * Revision 1.2  2011/12/13 09:49:48  thatr500
 * add full mapper
 *
 * Revision 1.1  2011/12/02 12:57:07  thatr500
 * make a dll out of BT.c
 *
 *
 ****************************************************************************/
#include <stdio.h>
#include <limits.h>
#include "bt.h" /* BTREE implementation API */
#include "../../system/C/mexima/mexima.h" /* MEXIMA API */

/* Exported initializer function.
   Called by MEXIMA when subsystem initialized.*/
EXPORT void a_initialize_extension(void* xa);
extern void define_index(struct mexi_index_props idxro);

/* Create new BTREE index bt */
void *btintf_create(unsigned int size)
{
  return (void *)newBThead();
}

/* Get value for given key in BTREE index bt */
void *btintf_get(void *bt, void *key, mexi_compare cmp)
{
  BTitem *kvp = NULL;

  kvp = BTget((BThead *)bt, (BTdata) key, (BTcomparer)cmp);
  if (kvp == NULL) return NULL; /* key not found */
  /* Return pointer to the cell hosting value.
     Key is not returned */
  return &kvp->data.value;
}

/* Insert key into BTREE index bt. 
   Return pointer to corresponding value for key. 
   Set newflag=TRUE if the key was not there before */
void *btintf_put(void *btx, void * key, int *newflag, mexi_compare cmp) 
{	  
  BTitem *kvp;
  BThead *bt = (BThead *)btx;
  int cnt = bt->elements;
  
  kvp = BTinsert(bt, (BTdata) key, cmp);  
  if (cnt  == bt->elements)
    (*newflag) = FALSE;	/* The key was aleady there, i.e. tree not changed */
  else (*newflag) = TRUE; /* New key inserted */
  return (void *)&(kvp->data.value); 
  /* Return pointer to data value for the key */
}

/* Delete key from BTREE index. 
   If the key exists
     kvp->key = deleted key
     kvp->val = deleted val
     return TRUE;
   Else
     return FALSE;
   */
int btintf_delete(void *bt, void *key,  struct kv *kvp,  mexi_compare cmpfn) 
{
  BTitem bi;   
  int delflag = BTdelete((BThead *)bt, (BTdata) key, (BTcomparer) cmpfn, &bi);
  if (delflag) 
  {
	 kvp->key = (void *) bi.data.key;
	 kvp->val = (void *) bi.data.value;
  }
  return delflag;  
}

/* Deallocate the BTREE */
void btintf_drop(BThead *bt) 
{
  freeBThead(bt);
}

struct applyMapData
{
  KVPmapper mapfn;
  void* xa;
};

int btmapper(BTitem *bi, void *xa)
{
  struct applyMapData *btxa = (struct applyMapData *)xa;  
  if (btxa != NULL && btxa->mapfn != NULL) {
    return btxa->mapfn((void *) bi->data.key, (void *)bi->data.value, btxa->xa);	
  } 
  return TRUE;
}

/* Map over range in BTREE index */
void btinf_range_mapping (void *btx,  KVPmapper mapfn, void *lower, 
			  void *upper, mexi_compare cmpfn, void *xa)
{
  struct applyMapData btxa;
  BThead *bt = (BThead *)btx;

  btxa.mapfn = mapfn;
  btxa.xa = xa;
  BTmap0(bt->root, (BTdata)lower, (BTdata)upper, 
	 (BTmapper)btmapper, (BTcomparer)cmpfn, (void *)&btxa);
}

/*Total mapper to iterate all items in the index ind*/
void btintf_full_mapping(void *btx, KVPmapper  mapfn , mexi_compare cmpfn,
			 void *xa)
{
  struct applyMapData btxa;
  BThead *bt = (BThead*) btx;
  btxa.mapfn = mapfn;
  btxa.xa = xa;  

  BTmap0(bt->root, (BTdata) starsymbol, (BTdata) starsymbol, 
	 (BTmapper)btmapper, (BTcomparer)cmpfn,
	 &btxa); 
}

EXPORT void a_initialize_extension(void *xa)
{ 
  struct mexi_index_props idxpros;  

  strcpy(idxpros.name, "MBTREE"); /* Name of index */
  idxpros.create = btintf_create;
  idxpros.get = btintf_get;
  idxpros.put = btintf_put;
  idxpros.remove = btintf_delete;
  idxpros.drop = btintf_drop;
  idxpros.range_mapping = btinf_range_mapping;
  idxpros.full_mapping = btintf_full_mapping; 
  idxpros.compare = NULL; /* let mexima decide compare function */
  define_index(idxpros);
}
