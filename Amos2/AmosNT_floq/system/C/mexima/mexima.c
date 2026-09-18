/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexima.c,v $
 * $Revision: 1.17 $ $Date: 2013/08/01 12:55:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima vs (index on) Relation
 * ========================================================================
 * $Log: mexima.c,v $
 * Revision 1.17  2013/08/01 12:55:33  thatr500
 * added getidentifier into generic MEXIMA API
 *
 * Revision 1.16  2013/01/30 13:38:53  thatr500
 * used starsymbol instead
 *
 * Revision 1.15  2013/01/09 15:06:05  thatr500
 * removed load_index_extension0fn, and load_special_extension0fn
 *
 * Revision 1.14  2012/01/12 07:58:20  thatr500
 * - changed signature a_initialize_extension
 * - fixed "Loading Borland /VC++ dynamic dll" on Unix
 *
 * Revision 1.13  2012/01/05 16:54:55  thatr500
 * *** empty log message ***
 *
 * Revision 1.12  2012/01/04 16:44:14  thatr500
 * - maintain counter
 * - use array instead of list. It gains 5MB (lesser) than the original MBTREE
 *   for one million key/value pairs.
 *
 * Revision 1.11  2012/01/04 14:50:26  thatr500
 * - allowed to extend indexing through Foreign function
 * - add XTree as built-in index
 *
 * Revision 1.10  2012/01/02 08:52:59  thatr500
 * added mexi-owner
 *
 * Revision 1.9  2011/12/30 17:56:43  thatr500
 * *** empty log message ***
 *
 * Revision 1.8  2011/12/30 17:09:04  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.7  2011/12/28 10:09:08  thatr500
 * removed code
 *
 * Revision 1.6  2011/12/27 09:43:22  thatr500
 * removed codes
 *
 * Revision 1.5  2011/12/24 11:50:00  thatr500
 * new design
 *
 * Revision 1.3  2011/12/20 21:06:31  thatr500
 * logged which owner(relation) having transient index on it
 *
 * Revision 1.2  2011/12/13 10:09:05  thatr500
 * - overwrite system index if they have the same index type name
 * - interfaces with Index manager so that transient indexes can
 *   work on relation.
 * - added total mapper
 *
 * Revision 1.1  2011/12/02 12:39:48  thatr500
 * MEXIMA core
 *
 * Revision 1.4  2011/05/04 08:26:53  thatr500
 * *** empty log message ***
 *
 **************************************************************************/
#include "amos.h"
#include "storagetypes.h"
#include "mexima.h"
#include "mexi.h"
#include "mexmeda.h"
#include "mexglobvals.h"
#include "mex_generic_api.h"
#include "mex_relation.h"
#include "mex_foreign.h"
#include "mexutilities.h"

/*-------------------------------------------------------------------*/
/*Introduce to Index Manager a new kind of index */
int register_index(char *indname) {
  struct index_properties idxpro;	
  int i = 0;

  strcpy(idxpro.name, indname);	
  // Index Manager's routines to Mexima dispatcher	
  idxpro.creator = mex_idm_creator;
  idxpro.mapper = mex_idm_mapper;
  idxpro.getter = mex_idm_getter;
  idxpro.inserter = mex_idm_inserter;
  idxpro.deleter = mex_idm_deleter;
  idxpro.counter = mex_idm_counter;
  idxpro.dropper = mex_idm_dropper;
  // overwrite if idxpro.name was already defined.
  for( i = 0; i < MAX_INDEX_TYPES; i++) {
    if (strcmp(index_types[i].name, idxpro.name) == 0) {
      index_types[i] = idxpro;
      return i;
    }
  }
  return define_index_type(idxpro);		
}

/*Define a new index type (strIndextype) given a struct of properties 
  (access methods)*/
EXPORT void define_index(struct mexi_index_props idxro)
{
  short int indextype;
  struct meda m;

  // register with the system a new index type which is 
  // later used
  indextype = register_index(idxro.name);

  // add meta-data
  m.idxprops = idxro;
  m.indextype = indextype;
  m.storagetype = MEXITYPE;  
  add_medatable(&m);    
}

/*Register MEXIMA*/
extern void register_mex_amos_intf();
extern void register_utilities();
void register_mexima(void) 
{
  register_mexf();
  register_mexi(); /*Mexi storagetype*/ 
  
  a_let(_limit_, mksymbol("*"));
  /*List of mexi objects*/
  mexitems = NULL; 

  /*Internal Lisp functions*/
  extfunction0("list-mexi-objects", list_mexi_objectsfn);
  extfunction2("restore-mexi", restore_mexifn);
  extfunction1("mexi-owner", mexi_ownerfn);
  extfunction1("mexi-count", mexi_countfn);
  extfunction1("is-mexi", is_mexifn);

  /*Mexima generic API*/
  extfunction1("mexima-make", mexima_makefn);	
  extfunction2("mexima-get", mexima_getfn);
  extfunction3("mexima-put", mexima_putfn);	
  extfunction4("mexima-range-map", mexima_range_mapfn);
  extfunction2("mexima-map", mexima_full_mapfn);
  extfunction1("mexima-drop", mexima_dropfn);
  extfunction2("mexima-delete", mexima_deletefn);	
  extfunction1("mexima-getidentifier", mexima_getidentifierfn);

  register_utilities();
}

