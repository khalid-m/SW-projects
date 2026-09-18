/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexi.h,v $
 * $Revision: 1.14 $ $Date: 2013/02/24 10:01:36 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexi is a storage object for an index 
 * ========================================================================
 * $Log: mexi.h,v $
 * Revision 1.14  2013/02/24 10:01:36  torer
 * Reverted to original mexima
 *
 * Revision 1.12  2012/01/05 16:54:55  thatr500
 * *** empty log message ***
 *
 * Revision 1.11  2012/01/04 16:44:14  thatr500
 * - maintain counter
 * - use array instead of list. It gains 5MB (lesser) than the original MBTREE
 *   for one million key/value pairs.
 *
 * Revision 1.10  2012/01/02 08:51:45  thatr500
 * added function mexi-owner
 *
 * Revision 1.9  2011/12/30 17:09:04  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.8  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.7  2011/12/28 16:20:21  thatr500
 * Unix conventions
 *
 * Revision 1.6  2011/12/28 10:06:38  thatr500
 * keep track mexi objects by a linked list
 *
 * Revision 1.5  2011/12/24 11:50:00  thatr500
 * new design
 *
 * Revision 1.3  2011/12/20 21:03:30  thatr500
 * added some variables
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
#ifndef _mexi_h_
#define _mexi_h_

extern int MEXITYPE;

struct mexicell 
{
  objtags tags;
  void *idxp; /* pointer to index object*/  
  short int indextype; /*index type*/
  oidtype owner; /*owner of the index.e.g: a relation / function*/ 
  oidtype tbdlist; 
  oidtype tbilist;
  short int flag;
  unsigned int count;
  /* list of keys which are to be deleted. This list is computed 
     in case deletions are invoked during a loop over the entire index*/
};

typedef struct mexi_item {
   oidtype mexi; 	
   struct mexi_item * next;
} mexi_item;

typedef struct mexi_item mexitem;

/*Make a new instance of Mexi storage type*/
oidtype make_mexifn(bindtype env, oidtype idxtype);

/*Deallocate given instance of Mexi storage type*/
void free_mexifn(oidtype mexi);

/*Print out given instance mexi on stream*/
void print_mexifn(oidtype mexi, oidtype stream, int princflg);

/*Register a derrived storage type*/
int  register_mexi();

/*Return a list of mexi objects available on memory*/
oidtype list_mexi_objectsfn(bindtype env);

/*Reconstruct mexi index ( without data)*/
oidtype restore_mexifn(bindtype env, oidtype mexi, oidtype listkv);

/*Return the owner of mexi object if exists. Otherwise, return nil*/
oidtype mexi_ownerfn(bindtype env, oidtype mexi);

oidtype mexi_countfn(bindtype env, oidtype mexi);
oidtype is_mexifn(bindtype env, oidtype mexi);

oidtype _limit_;
mexitem* mexitems;
#endif

