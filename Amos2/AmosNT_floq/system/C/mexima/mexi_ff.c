/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexi_ff.c,v $
 * $Revision: 1.7 $ $Date: 2013/01/18 14:35:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexi is a generic name for storage type for an index type which
 * integrated to the system via MEXIMA
 * ========================================================================
 * $Log: mexi_ff.c,v $
 * Revision 1.7  2013/01/18 14:35:43  thatr500
 * - removed printf
 * - added commandline assignment3.cmd
 *
 * Revision 1.6  2012/01/13 19:16:09  torer
 * Correct include files!
 *
 * Revision 1.5  2012/01/09 14:06:01  torer
 * *** empty log message ***
 *
 * Revision 1.4  2012/01/09 09:11:47  thatr500
 * assigned indextype
 *
 * Revision 1.3  2012/01/04 16:44:14  thatr500
 * - maintain counter
 * - use array instead of list. It gains 5MB (lesser) than the original MBTREE
 *   for one million key/value pairs.
 *
 * Revision 1.2  2012/01/04 14:50:26  thatr500
 * - allowed to extend indexing through Foreign function
 * - add XTree as built-in index
 *
 * Revision 1.1  2012/01/02 08:54:41  thatr500
 * skeleton code for defining new indextype through foreign function
 *
 **************************************************************************/
#include "amos.h"
#include "storagetypes.h"
#include "storage.h"
#include "mexi_ff.h"
#include "mexima.h"
#ifdef WIN32
#include <windows.h>
#else 
#include <dlfcn.h>
#endif

/*Add mexi to a list of mexi objects*/
void add_mexiffobject(oidtype mexiff)
{
  mexiforeignitem* item;
  item = (mexiforeignitem*)malloc(sizeof(mexiforeignitem));
  item->mexiforeign = mexiff;
  item->next = listmexiff;
  listmexiff = item;  
}

/*Remove mexi from a list of mexi objects*/
void remove_mexiffobject(oidtype mexiff)
{
  mexiforeignitem* curr;
  mexiforeignitem* prev;

  curr = listmexiff;
  prev = NULL;
  while(curr != NULL) 
    {
      if (curr->mexiforeign == mexiff)
	{   /*Found !!! Remove curr*/		  
	  if (prev == NULL) 
	    {   /*Curr is the first node*/
	      listmexiff = curr->next;			  
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
/*-------------------------------------------------------------------
  MAKE MEXIFF
  -------------------------------------------------------------------*/
oidtype createmapperfn(a_callcontext cxt, int width, oidtype res[], void *xa){
  int* indexId = (int *) xa;
  (*indexId) = dr(res[0], integercell)->integer;
  return nil;
}

int make_foreign_index(bindtype env, int indextype) 
{
  oidtype argl[1];
  int indexID;
  dcl_local_cxt(cxt,env);	
  
  // call foreign function to create an index of indextype
  a_mapfunctionC(cxt,
		 mexfsubs_table[indextype].create, 
		 0, argl, createmapperfn, (void *) &indexID);
  return indexID;
}

/*Make a Mexi object*/
oidtype make_foreign_mexifn(bindtype env, oidtype  idxtype)
{
  struct mexiforeigncell *mxff;
  oidtype mexiff;
  int indextype;

  OfType(idxtype, INTEGERTYPE, env);
  IntoInteger(idxtype, indextype, env); 
  
  mexiff = new_object(sizeof(*mxff), MEXIFOREIGNTYPE);
  mxff = dr(mexiff, mexiforeigncell);	
  mxff->id = make_foreign_index(env, indextype);  
  mxff->indextype = indextype;
  mxff->owner = nil;
  
  add_mexiffobject(mexiff); /*Add mexiff to a list of mexiff objects*/
  return mexiff;
}

/*Free mexi object called from garbage collector*/
void free_mexiforeignfn(oidtype mexiff)
{  
  struct mexiforeigncell *dmexiff = dr(mexiff, mexiforeigncell);
  //mexima_dropfn(varstack, mexi); /* Remove the KVPs */
  remove_mexiffobject(mexiff);    
  a_free(dmexiff->owner); /* Release reference to owner */
  dealloc_object(mexiff); /* Deallocate the mexi object itself */
}

/*Print out given instance mexiff on stream*/
void print_mexiforeignfn(oidtype mexiff, oidtype stream, int princflg)
{
}

int MEXIFOREIGNTYPE;
/*Register a derrived storage type*/
int  register_mexiforeign()
{
  MEXIFOREIGNTYPE = a_definetype("MEXIFF", free_mexiforeignfn, NULL);
  typefns[MEXIFOREIGNTYPE].deallocfn = free_mexiforeignfn;
  return MEXIFOREIGNTYPE;
}

/*Return a list of mexi objects available on memory*/
oidtype list_mexiforeign_objectsfn(bindtype env)
{
  oidtype res = nil;
  mexiforeignitem* curr;
	
  curr = listmexiff;	
  while(curr != NULL) 
    {
      push(curr->mexiforeign, res);
      curr = curr->next;
    }
  return res; 
}

/*Reconstruct mexi index ( without data)*/
oidtype restore_mexiforeignfn(bindtype env, oidtype mexiff, oidtype listkv)
{
  struct mexiforeigncell *mxff;  
  OfType(mexiff, MEXIFOREIGNTYPE, env);
  mxff = dr(mexiff, mexiforeigncell);  
  mxff->id = make_foreign_index(env, mxff->indextype);  
  add_mexiffobject(mexiff); /*Add mexi to a list of mexi objects*/
  return nil; 
}

/*Return the owner of mexi object if exists. Otherwise, return nil*/
oidtype mexiforeign_ownerfn(bindtype env, oidtype mexiff)
{
  struct mexiforeigncell *mx;
    
  OfType(mexiff, MEXIFOREIGNTYPE, env);
  mx = dr(mexiff, mexiforeigncell);	  
  return mx->owner;
}
/*Return id of mexi foreign*/
oidtype mexi_foreign_getidfn(bindtype env, oidtype mexiff)
{
  OfType(mexiff, MEXIFOREIGNTYPE, env);
  return mkinteger(dr(mexiff, mexiforeigncell)->id);
}


/*Return count*/
oidtype mexi_foreign_countfn(bindtype env, oidtype mexiff)
{
  OfType(mexiff, MEXIFOREIGNTYPE, env);
  return mkinteger(dr(mexiff, mexiforeigncell)->count);
}
