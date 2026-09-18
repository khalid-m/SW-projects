/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexi_ff.h,v $
 * $Revision: 1.4 $ $Date: 2013/02/28 09:49:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexi FF is a storage object for an index through FF
 * ========================================================================
 * $Log: mexi_ff.h,v $
 * Revision 1.4  2013/02/28 09:49:02  thatr500
 * replace reserved C++ keyword 'delete' by 'remove'
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
 * Revision 1.1  2012/01/02 08:54:42  thatr500
 * skeleton code for defining new indextype through foreign function
 *
 *
 **************************************************************************/
#ifndef _mexi_foreign_h_
#define _mexi_foreign_h_

extern int MEXIFOREIGNTYPE;

struct mexiforeigncell 
{
  objtags tags;
  short int id; /* pointer to index object*/  
  short int indextype; /*index type*/
  oidtype owner; /*owner of the index.e.g: a relation / function*/ 
  unsigned int count;
};

typedef struct mexiforeign_item {
   oidtype mexiforeign; 	
   struct mexiforeign_item * next;
} mexiforeign_item;

typedef struct mexiforeign_item mexiforeignitem;

/*Make a new instance of Mexi storage type*/
oidtype make_foreign_mexifn(bindtype env, oidtype idxtype);

/*Deallocate given instance of Mexi storage type*/
void free_mexiforeignfn(oidtype mexi);

/*Print out given instance mexi on stream*/
void print_mexiforeignfn(oidtype mexiforeign, oidtype stream, int princflg);

/*Register a derrived storage type*/
int  register_mexiforeign();

/*Return a list of mexi objects available on memory*/
oidtype list_mexiforeign_objectsfn(bindtype env);

/*Reconstruct mexi index ( without data)*/
oidtype restore_mexiforeignfn(bindtype env, oidtype mexiforeign, oidtype listkv);

/*Return the owner of mexi object if exists. Otherwise, return nil*/
oidtype mexiforeign_ownerfn(bindtype env, oidtype mexiforeign);

/*Return id of mexi foreign*/
oidtype mexi_foreign_getidfn(bindtype env, oidtype mexiforeign);
oidtype mexi_foreign_countfn(bindtype env, oidtype mexiforeign);

mexiforeignitem* listmexiff;

typedef struct mexfsubs
{
  oidtype create;
  oidtype insert;
  oidtype get;
  oidtype remove;
  oidtype clear;
  oidtype map;
  oidtype count;

} mexfsubs;

mexfsubs* mexfsubs_table;

#endif


