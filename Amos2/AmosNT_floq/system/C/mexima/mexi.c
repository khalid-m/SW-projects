/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexi.c,v $
 * $Revision: 1.24 $ $Date: 2013/08/07 09:31:30 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexi is a generic name for storage type for an index type which
 * integrated to the system via MEXIMA
 * ========================================================================
 * $Log: mexi.c,v $
 * Revision 1.24  2013/08/07 09:31:30  thatr500
 * updated pointer to in-memory index to null, when extension couldnot be loaded
 *
 * Revision 1.23  2013/08/06 16:21:20  thatr500
 * added check when index type is not available
 *
 * Revision 1.22  2013/02/24 10:01:36  torer
 * Reverted to original mexima
 *
 * Revision 1.19  2013/01/09 15:03:43  thatr500
 * Check if index type is available
 *
 * Revision 1.18  2012/01/09 14:06:00  torer
 * *** empty log message ***
 *
 * Revision 1.17  2012/01/05 16:54:55  thatr500
 * *** empty log message ***
 *
 * Revision 1.16  2012/01/04 17:43:04  thatr500
 * save as array
 *
 * Revision 1.15  2012/01/04 16:44:13  thatr500
 * - maintain counter
 * - use array instead of list. It gains 5MB (lesser) than the original MBTREE
 *   for one million key/value pairs.
 *
 * Revision 1.14  2012/01/02 08:50:41  thatr500
 * added function to get owner of a Mexi
 *
 * Revision 1.13  2011/12/31 14:09:21  thatr500
 * Fixed : Wrong deletion from a linked-list ( of mexi objects)
 *
 * Revision 1.12  2011/12/30 17:09:04  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.11  2011/12/28 16:20:21  thatr500
 * Unix conventions
 *
 * Revision 1.10  2011/12/28 10:06:38  thatr500
 * keep track mexi objects by a linked list
 *
 * Revision 1.9  2011/12/27 12:11:19  thatr500
 * *** empty log message ***
 *
 * Revision 1.8  2011/12/27 10:55:20  thatr500
 * M-x indent-region
 *
 * Revision 1.7  2011/12/27 09:42:39  thatr500
 * *** empty log message ***
 *
 * Revision 1.6  2011/12/24 11:50:00  thatr500
 * new design
 *
 * Revision 1.4  2011/12/21 08:02:03  thatr500
 * *** empty log message ***
 *
 * Revision 1.3  2011/12/20 21:04:49  thatr500
 * removed log of owner(relation) having transient index on it
 *
 * Revision 1.2  2011/12/13 10:06:21  thatr500
 * - added 'modification' flag
 * - new box/unbox marco
 *
 * Revision 1.1  2011/12/02 12:32:19  thatr500
 * Mexi represents external index instances
 *
 *
 **************************************************************************/
#include "amos.h"
#include "storagetypes.h"
#include "storage.h"
#include "mexi.h"
#include "mexmeda.h"
#include "mexima.h"
#ifdef WIN32
#include <windows.h>
#else 
#include <dlfcn.h>
#endif

/*Add mexi to a list of mexi objects*/
void add_mexiobject(oidtype mexi)
{
  mexitem* item;
  item = (mexitem*)malloc(sizeof(mexitem));
  item->mexi = mexi;
  item->next = mexitems;
  mexitems = item;  
}
/*Remove mexi from a list of mexi objects*/
void remove_mexiobject(oidtype mexi)
{
  mexitem* curr;
  mexitem* prev;

  curr = mexitems;
  prev = NULL;
  while(curr != NULL) 
  {
      if (curr->mexi == mexi)
	  {   /*Found !!! Remove curr*/		  
		  if (prev == NULL) 
		  {   /*Curr is the first node*/
			  mexitems = curr->next;			  
		  } else 
		  {   /*Last node or middle node*/
			  prev->next = curr->next;
			  curr->next = NULL; 
		  }
		  free(curr);
		  /*break the loop*/
		  break;
	  } 
	  /*Otherwise, move forward*/
      prev = curr;
      curr = curr->next;
  }
}
/*Make a Mexi object*/
oidtype make_mexifn(bindtype env, oidtype  idxtype)
{
  struct meda *m;
  struct mexicell *dx;
  oidtype mexi;
  char *stridxtype;

  IntoString(idxtype, stridxtype, env); 
  m =  get_metadata(stridxtype); /*look up meta data*/
  if (m == NULL){
    printf("WARNING Index type %s is not available ! \n", stridxtype);
    return nil;
  }

  mexi = new_object(sizeof(*dx), MEXITYPE);
  dx = dr(mexi, mexicell);	
  dx->idxp = m->idxprops.create(0); /*construct index*/
  dx->indextype = m->indextype;
  dx->owner = nil;
  dx->count = 0;
  dx->tbdlist = nil; /*to-be-deleted  keys*/
  dx->tbilist = nil; /*to-be-inserted (k, v) pairs*/
  dx->flag = FALSE;  /*by default, iteration flag = FALSE*/
  
  add_mexiobject(mexi); /*Add mexi to a list of mexi objects*/

  return mexi;
}

/*Free mexi object called from garbage collector*/
void free_mexifn(oidtype mexi)
{  
  struct mexicell *dmexi = dr(mexi, mexicell);
  mexima_dropfn(varstack, mexi); /* Remove the KVPs */
  remove_mexiobject(mexi);    
  a_free(dmexi->owner); /* Release reference to owner */
  dealloc_object(mexi); /* Deallocate the mexi object itself */
}

/*Print out given instance mexi on stream*/
void print_mexifn(oidtype mexi, oidtype stream, int princflg)
{
  struct mexicell *mc;
  struct meda *m;
  mc = dr(mexi, mexicell);
  m = get_medatable(mc->indextype);
  if (m == NULL) return;
  a_puts("#[MEXI:",stream);
  a_putc(' ',stream);
  a_puts(m->idxprops.name, stream);
  a_putc(' ',stream); 
  a_putc(']',stream);		
}

int MEXITYPE;
/*Register a derrived storage type*/
int  register_mexi()
{
  MEXITYPE = a_definetype("MEXI", free_mexifn, NULL);
  /*In case it exists a storagetype with the same name. It is better to wire up
    deallocation and print function as the following*/
  typefns[MEXITYPE].deallocfn = free_mexifn;
  return MEXITYPE;
}

/*Return a list of mexi objects available on memory*/
oidtype list_mexi_objectsfn(bindtype env)
{
  oidtype res = nil;
  mexitem* curr;
	
  curr = mexitems;	
  while(curr != NULL) 
    {
      push(curr->mexi, res);
      curr = curr->next;
    }
  return res; 
}

/*Reconstruct mexi index ( without data)*/
oidtype restore_mexifn(bindtype env, oidtype mexi, oidtype listkv)
{
  struct mexicell *mx;
  struct meda *m;
  
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);	
  m = get_medatable(mx->indextype);
  if (m== NULL) {
    mx->idxp = NULL;
    return nil;
  }
  mx->idxp = m->idxprops.create(0); /*re-construct index*/
  mx->count = 0;
  add_mexiobject(mexi); /*Add mexi to a list of mexi objects*/
  return t; 
}

/*Return the owner of mexi object if exists. Otherwise, return nil*/
oidtype mexi_ownerfn(bindtype env, oidtype mexi)
{
  struct mexicell *mx;
    
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);	  
  return mx->owner;
}

oidtype mexi_countfn(bindtype env, oidtype mexi)
{
   struct mexicell *mx;
    
  OfType(mexi, MEXITYPE, env);
  mx = dr(mexi, mexicell);	  
  return mkinteger(mx->count);
}

oidtype is_mexifn(bindtype env, oidtype mexi)
{
	struct mexicell *mx;    
    if (a_datatype(mexi) == MEXITYPE){
		mx = dr(mexi, mexicell);
		return (mx->idxp != NULL ? t:nil);
	}
	return nil;
}
