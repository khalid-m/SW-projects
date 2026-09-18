/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Thanh, UDBL
 * $RCSfile: indexhooks.c,v $
 * $Revision: 1.12 $ $Date: 2010/08/14 20:05:06 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Hooks function for Xtree index.
 * ===========================================================================
 * $Log: indexhooks.c,v $
 * Revision 1.12  2010/08/14 20:05:06  thtr1663
 * add xtree_dropper to deallocate xtree. It should be called when drop_index
 * command is executed.
 *
 * Revision 1.11  2010/06/19 06:21:18  thtr1663
 * free used variables
 *
 * Revision 1.10  2010/06/08 08:34:57  thtr1663
 * fix bug: Connection closed
 *
 * Revision 1.9  2010/06/07 19:22:48  thtr1663
 * create Xtree dynamically (not reading dim from config file)
 *
 * Revision 1.8  2010/06/07 08:21:01  thtr1663
 * remove debug info
 *
 * Revision 1.7  2010/06/04 14:18:34  thtr1663
 * Fix KNN search on multiple Xtree index
 *
 * Revision 1.6  2010/06/04 10:52:41  thtr1663
 * Remove ^M (ending line)
 *
 * Revision 1.5  2010/06/04 07:40:56  thtr1663
 * Modify Xtree to make it possible to store multiple index. 
 * Index hooks are updated accordingly
 *
 * Revision 1.4  2010/06/02 10:13:01  torer
 * *** empty log message ***
 *
 ****************************************************************************/

#include "amosXtree.h"

#include "index.h"

float* getFeatures(oidtype key) {
  int size = 0, i;
  float* feature;
	
  // Get size of the array
  size = dr(key, arraycell)->size;
  
  feature = (float *) malloc(sizeof(float) * size);
		
  // Loop and build the feature
  for (i = 0; i < size ; i ++) {
    if (a_datatype(dr(key, arraycell)->cont[i]) == INTEGERTYPE) {
      feature[i] = 
	(float) dr((dr(key, arraycell)->cont[i]), integercell)->integer;
    }else if (a_datatype(dr(key, arraycell)->cont[i]) == REALTYPE) {
      feature[i] = (float) getreal(dr(key, arraycell)->cont[i]);
    } 
    // Print out the feature	
    myprintf(" key[%d] = %f ", i, feature[i]);
  }
  myprintf("\n");	
	
  return feature;
}

/*Basically, the val passed to putter, getter, ... as a list which a first 
  element is 
  a real object and the second is a key*/
oidtype getVal(oidtype val) {
  dcloid(objVal);
	
  if (a_datatype(val) == LISTTYPE) {					
    a_setf(objVal, a_elt(hd(val), 0));	
    return objVal;
  }
	
  return nil;
}

oidtype xtreeindex_creator(bindtype env, oidtype indhdr, unsigned int parm)
{
  dcl_scan(s); /* To hold result streams from Amos queries and function 
		  calls */
  dcl_tuple(result);  /* To hold results from Amos function calls */
  int indexID;
	
  /*Callin to Amos to create a new Xtree index*/
  //a_execute(getConnection(),s,"createXtreeIndex();",FALSE);

  // Call back to system (Amos II) to create Xtree index 
  a_execute(a_callback_connection,s,"createXtreeIndex();",FALSE);
	
  a_getrow(s,result,FALSE);
  indexID = a_getintelem(result,0,FALSE);
  myprintf("indexID = %d\n",indexID);
	
  free_tuple(result);
  free_scan(s);
  return mkinteger(indexID);
}

oidtype xtreeindex_getter(bindtype env, oidtype indhdr, oidtype xt,
			  oidtype key)
{
  int indexID;
  float *queryPoints;
  node_type *root;
  NN_type *existingNode;
  config_type fconfig;
  dcloid(result);

  myprintf("\n xtree_getter  ........... ");
  //a_print(key);
  queryPoints = getFeatures(key);
	
  indexID = dr(xt, integercell)->integer;	
	
  // Search in xtree	
  root = getXtree(indexID);
  if (root != NULL) {
    (*root).id = indexID;
    getConfig((*root).id, &fconfig);
    
    existingNode = o_xtree_get(root, queryPoints, fconfig);
    
    if (existingNode == NULL) {
      myprintf("ExistingNode is NULL \n");
    } else {
      myprintf("ExistingNode is found\n");
    }
    while (existingNode != NULL && existingNode->valuable == 1) {
      // It is supposed to hold only one result.
      myprintf("returns");      
      a_setf(result, existingNode->pointer->object);
      //a_print(result);	
      return result;
    }
  }	
	
  // Return
  myprintf("returns NOTHING");
  return nil;
}

oidtype xtreeindex_putter(bindtype env, oidtype indhdr, oidtype xt, 
			  oidtype key,  oidtype val)
{
  int indexID, size, result = FALSE;
  float *data;

  node_type *root;
  config_type fconfig;
  dcloid(obj_val);
	
  myprintf("\n xtree_putter  ........... ");	
  //data = getFeatures(key);

  indexID = dr(xt, integercell)->integer;      
  // Get size of the array
  size = dr(key, arraycell)->size;

  getConfig(indexID, &fconfig);
  root = getXtree(indexID);

  myprintf("xtree_putter ID =%d ROOT is [%d] counter =%d \n", indexID, 
	   (root == NULL), fconfig.counter);
  // This is the first put. Actually allocate memory space for Xtree
  if (root == NULL && fconfig.counter == 0) {
    fconfig.dim = size;
    fconfig.counter = 0;
    root = o_xtree_make(fconfig);
    // Update 
    (*root).id = indexID;
  }
  
  if (root != NULL) {
    (*root).id = indexID;

    if (size != fconfig.dim) {
      a_error(DIM_DISAGREE ,mkinteger(size), FALSE);
    }
    data = getFeatures(key);

    a_setf(obj_val, val);
    //a_print(obj_val);
    if(o_xtree_put(root, data, obj_val, fconfig, INDEX_MANAGER)){
      // Increase the counter
      fconfig.counter++;
      updateListTree(indexID, root, fconfig);
      myprintf("Put is oke\n");
    }
    result = TRUE;		
  }
  
  myprintf("...is %s ", (result == TRUE)? "TRUE" : "FALSE");  
  // Return
  root = NULL;
  free(root);
  free(data);
  free_oid(obj_val);
  return mkinteger(result);
}

oidtype xtreeindex_deleter(bindtype env, oidtype indhdr, oidtype xt, 
			   oidtype key)
{
  float *queryPoints;
  int indexID;
  node_type *root;
  config_type fconfig;

  myprintf("xtree_deleter ..........\n");
  queryPoints = getFeatures(key);
	
  indexID = dr(xt, integercell)->integer;	
	
  // Search in xtree	
  root = getXtree(indexID);
  if (root != NULL) {
    (*root).id = indexID;
    getConfig((*root).id, &fconfig);
		
    if(im_xtree_delete(root, queryPoints, fconfig)){
      fconfig.counter --;
      updateListTree((*root).id, root, fconfig);
      return mkinteger(TRUE);
    }
  }
	
  // Return
  return mkinteger(FALSE);

}

int xtreeindex_counter(bindtype env, oidtype indhdr, oidtype xt)
{
  config_type fconfig;
  int indexID;
	
  myprintf("\n xtree_counter  ........... ");
  indexID = dr(xt, integercell)->integer;	
	
  // It would be an error here if there is no such index id.
  // It simply means something really wrong happened.
  getConfig(indexID, &fconfig);	
  return fconfig.counter;

}

void map_xtree(bindtype env, oidtype indhdr, oidtype xt,
	       mapxtree_function f, void *x) {
	
  printf("TODO : Mapping function \n");
}

int xtreeindex_dropper(bindtype env, oidtype inhdr) {
  int xtId;	
  char strXtId[80];
  char amosql[80];
  dcl_scan(s);

  // Extract identifier of xtree index
  xtId = dr(inhdr, indexcell)->rows;	
 
  // Call back to drop the xtree
  itoa(xtId, strXtId, 10);
  
  strcat(amosql, "drop_xtree(");
  strcat(amosql, strXtId);
  strcat(amosql, ");");
  a_execute(a_callback_connection, s, amosql,FALSE);
  
  return xtId;
}

void register_xtree_index() {
  struct index_properties xtreeprops;	
  strcpy(xtreeprops.name,"XTREE");
  xtreeprops.creator = xtreeindex_creator;
  xtreeprops.mapper = map_xtree;
  xtreeprops.getter = xtreeindex_getter;
  xtreeprops.inserter = xtreeindex_putter;
  xtreeprops.deleter = xtreeindex_deleter;
  xtreeprops.counter = xtreeindex_counter;
  xtreeprops.dropper = xtreeindex_dropper;
  define_index_type(xtreeprops);	
}
