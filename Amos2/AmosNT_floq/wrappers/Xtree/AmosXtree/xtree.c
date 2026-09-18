/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 thanh, UDBL . It was originally implemented by Cheung Ka
 * Leong(klcheung@cse) and Wong Chi Wing (cwwong@cse).
 * $RCSfile: xtree.c,v $
 * $Revision: 1.14 $ $Date: 2010/06/19 06:24:50 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions to constructXtree
 * 
 * ===========================================================================
 * $Log: xtree.c,v $
 * Revision 1.14  2010/06/19 06:24:50  thtr1663
 * fix bug : variables are already free
 *
 * Revision 1.13  2010/06/07 19:22:48  thtr1663
 * create Xtree dynamically (not reading dim from config file)
 *
 * Revision 1.12  2010/06/07 08:21:02  thtr1663
 * remove debug info
 *
 * Revision 1.11  2010/06/04 14:18:35  thtr1663
 * Fix KNN search on multiple Xtree index
 *
 * Revision 1.10  2010/06/04 10:52:42  thtr1663
 * Remove ^M (ending line)
 *
 * Revision 1.9  2010/06/04 07:40:56  thtr1663
 * Modify Xtree to make it possible to store multiple index. 
 * Index hooks are updated accordingly
 *
 * 
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>
#include <time.h>

#include <string.h>
#include "xtree.h"

/*---------------------------------------------------------------------
  function : void initialize(config_type *config)
  purpose  : to initialize the configuration file of X-tree
  parameter: config_type *config - the configuration structure
  return   : none
  ---------------------------------------------------------------------*/
void initialize(config_type *fconfig) {
  FILE *fp;

  fp = fopen(CONFIG_FILE, "r");

  fscanf(fp, "m=%d\n", &fconfig->m);
  fscanf(fp, "M=%d\n", &fconfig->M);

  //fscanf(fp, "dim=%d\n", &fconfig->dim);
  // There is no dim in the configuration file. It will be determined from
  // the first put.
  fconfig->dim = UNDEFINED;

  fscanf(fp, "reinsert_p=%d\n", &fconfig->reinsert_p);

  fscanf(fp, "no_histogram=%d\n", &fconfig->no_histogram);

  fscanf(fp, "debugMode=%d\n", &debugMode);
  fconfig->counter = 0;

}
/*---------------------------------------------------------------------
  function : void tree_node_allocate(node_type **node)
  purpose  : to allocate a tree node node
  parameter: node_type **node - a tree node
  return   : none
  ----------------------------------------------------------------------*/
void tree_node_allocate(node_type **node, config_type fconfig) {
  if (node != NULL) {
    (*node) = (node_type *) malloc(sizeof(node_type));
    (*node)->a = (float *) malloc(sizeof(float) * fconfig.dim);
    (*node)->b = (float *) malloc(sizeof(float) * fconfig.dim);
    //(*node)->ptr = 
    //(node_type **)malloc(sizeof(node_type *) * MAX_X_SNODE *M);
    (*node)->ptr = (node_type **) malloc(sizeof(node_type *) * fconfig.M);
                
    // *** Ray added
    (*node)->snodeSize = 1;
                
  }
        
}

node_type * o_xtree_make(config_type fconfig) {
  int i, j;
  node_type *root;

  tree_node_allocate(&root, fconfig);

  for (i = 0; i < fconfig.dim; i++) {
    (*root).b[i] = (float) (-1 * INT_MAX);
    (*root).a[i] = (float) (INT_MAX);
  }

  (*root).attribute = ROOT;
  (*root).vacancy = fconfig.M;
  (*root).parent = NULL;
  (*root).snodeSize = 1;
  for (j = 0; j < fconfig.M * (*root).snodeSize; j++)
    (*root).ptr[j] = NULL;
  return root;
}

/**
 * Given a key, the function returns a list of objects having the same
 * key
 */
NN_type* o_xtree_get(node_type *root, float *key, config_type fconfig) {

  NN_type *NN; /* A list of leaf nodes which are results of a search*/
  
  /* Do a search. This search traverses the Xtree*/
  NN = xtree_rectangle_search_tree(root, key, 0.0, fconfig);
  /* Given a distance = 0.0 means there is one node found.*/
  while (NN != NULL && NN->valuable == 1) {
    if (NN->object == nil){
      /*It should not be found during the search since it was DELETED*/
      free(NN);
      a_error(DELETED_NODE_FOUND , mkinteger(FALSE), FALSE);
    }
    return NN;	
  }

  /*If there is no node found, then NULL is returned*/
  free(NN);
  return NULL;
}

int o_xtree_put(node_type *root, float *data, oidtype oid_obj, 
		config_type fconfig, int caller) {
  node_type *node_found, *new_node, *data_node;
  NN_type *existingNode;
  int level_found;
  int i;
  dcloid(ls_objects); /*a list of object associated with the given key*/
  
  node_found = root;
  extra_level = 0;

  // Copy data to a temp node which is used to find if existing node
  tree_node_allocate(&data_node, fconfig);
  for (i = 0; i < fconfig.dim; i++) {
    data_node->a[i] = data[i];
    data_node->b[i] = data[i];
  }

  /*-----------------------*/
  /*BEGIN-MULTIPLE INDEX*/
  /*-----------------------*/
  /* Here a GET is needed to find out if an object is there in loc already 
     IF loc == NULL THEN 
     next statement
     ELSEIF oid_obj is member of loc THEN return
     memberfn(varstack, oid_obj, loc)!=nil
     ELSE 
     a_setf(loc, cons(oid_obj,loc)) 
  */

  existingNode = o_xtree_get(root, data, fconfig);
  if (existingNode != NULL){
    a_setf(ls_objects, existingNode->pointer->object);

    /*If there if a list of objects having the same key*/
    if (ls_objects != nil){ 
      if (caller == INDEX_MANAGER) {
	/*Since the index manager computes itself a list of objects to
	  be updated. Just update the list*/
	a_setf(existingNode->pointer->object, oid_obj);
	a_free(ls_objects);
	myprintf("[Index manager] UPDATED\n");
	return FALSE;

      } else {	
	if ( memberfn(varstack, oid_obj, ls_objects)!= nil) {		
	  /*If the object was ready there, then just return*/ 
	  myprintf("[Manual index] OBJECT WAS ALREADY THERE\n");
	  a_free(ls_objects);
	  a_free(oid_obj);
	  return FALSE;
	} else {
	  /*Add the object to the list. Note : they have the same key*/ 
	  a_setf(ls_objects, cons(oid_obj, ls_objects));
	  a_setf(existingNode->pointer->object, ls_objects);
	  myprintf("[Manual index] UPDATED\n");
	  a_free(ls_objects);
	  a_free(oid_obj);
	  return FALSE;
	}  

      }
    }
  }
  /*There is no such of node found. We insert a new node*/
  myprintf("\n [%d] INSERTED a new node \n", caller);

  /*-----------------------*/
  /* END OF MULTIPLE INDEX*/
  /*-----------------------*/

  /*NOTE : Below is the code to add a new node ( <list(object), key> )
    into Xtree. The list now has only one element.
  */

  level_found = choose_leaf(&node_found, root, 0, data_node, fconfig);
  /* Now, node_found is the pointer to the leaf chosen */

  /******/
  /* I2 */
  /******/

  /********************************************************/
  /* Add record to leaf node:                            */
  /* If L has room for another entry, install the entry   */
  /* Otherwise invoke split() to split the node */
  /********************************************************/
  /* Make a leaf node */

  tree_node_allocate(&new_node, fconfig);

  for (i = 0; i < fconfig.dim; i++) {
    new_node->a[i] = data[i];
    new_node->b[i] = data[i];
  }
  new_node->id = (int)new_node; //Always ask for unique id
  new_node->attribute = LEAF;
  new_node->vacancy = fconfig.M;
  new_node->parent = node_found;
  a_let(new_node->object,oid_obj);

  for (i = 0; i < fconfig.M; i++)
    new_node->ptr[i] = NULL;

  /* Test whether the node has room or not */
  if (node_found->vacancy != 0) {

    /* have room to insert the entry */

    // *** Ray changed
    //node_found->ptr[M - node_found->vacancy] = new_node;
    node_found->ptr[fconfig.M * node_found->snodeSize - node_found->vacancy]
      = new_node;

    node_found->vacancy--;

    adjust_MBR(new_node, fconfig);

  } else {
    overflow(node_found, level_found, level_found + 1, new_node, 
	     root, fconfig);
  }
  return TRUE;
}


void o_xtree_save(node_type *root, char filename[FILENAME_MAX]) {
  FILE *fp;
  config_type fconfig;

  fp = fopen(filename, "w");
  getConfig((*root).id, &fconfig);

  // Thanh : write the ID of the tree
  fprintf(fp, "%d\n", root->id);
  fprintf(fp, "m=%d\n", fconfig.m);
  fprintf(fp, "M=%d\n", fconfig.M);
  fprintf(fp, "dim=%d\n", fconfig.dim);
  fprintf(fp, "reinsert_p=%d\n", fconfig.reinsert_p);
  fprintf(fp, "no_histogram=%d\n", fconfig.no_histogram);
  fprintf(fp, "counter=%d\n", fconfig.counter);

  write_inter_node(root, fp, fconfig);
  fclose(fp);
  return;
}

node_type* o_xtree_load(char filename[FILENAME_MAX]) {
  FILE *fp;
  node_type *root;
  config_type fconfig;
  int id = UNDEFINED;
        
  // Always get a new id when it is created/loaded
  //(*root).id = (int)root;
  /**/  
  fp = fopen(filename, "r");
  fscanf(fp, "%d\n", &id);
  fscanf(fp, "m=%d\n", &fconfig.m);
  fscanf(fp, "M=%d\n", &fconfig.M);
  fscanf(fp, "dim=%d\n", &fconfig.dim);
  fscanf(fp, "reinsert_p=%d\n", &fconfig.reinsert_p);
  fscanf(fp, "no_histogram=%d\n", &fconfig.no_histogram);
  fscanf(fp, "counter=%d\n", &fconfig.counter);

  tree_node_allocate(&root, fconfig);
  (*root).id = id;
  updateListTree((*root).id,  root, fconfig);

  read_inter_node(root, fp, fconfig);

  fclose(fp);

  return root;
}
/**
 * Given a key, the function marks the associated node as DELETED. 
 * A deleted node should be ignored during the search.
 * This function is only called by INDEX MANAGER via index hook deleter.
 */ 
int im_xtree_delete(node_type *root, float *key, config_type fconfig) {

  NN_type *existingNode; /* A list of leaf nodes which are results of a search*/ 
  dcloid(ls_objects);

  /* Do a search. This search traverses the Xtree*/ 
  existingNode = o_xtree_get(root, key, fconfig);
  if (existingNode != NULL){
    /*Get the list of objects*/
    a_setf(ls_objects, existingNode->pointer->object);

    /*If there if a list of objects having the same key*/
    if (ls_objects != nil){ 
      /*Since the index manager computes itself a list of objects to
	be updated. Just update the list*/
      a_setf(existingNode->pointer->object, nil);
      a_free(ls_objects);
      myprintf("[Index manager] DELETED\n");
      return TRUE;
    }
  }    
  /*If there is no node found, then FAlSE is returned*/
  return FALSE;
}

/**
 * Given a key, the function marks the associated node as DELETED. 
 * A deleted node should be ignored during the search.
 * This function is only called by MANUAL INDEX .
 */ 
int o_xtree_delete(node_type *root, float *key, oidtype oid_obj, 
		   config_type fconfig) {

  NN_type *existingNode; /* A list of leaf nodes which are results of a search*/ 
  dcloid(ls_objects);

  /* Do a search. This search traverses the Xtree*/ 
  existingNode = o_xtree_get(root, key, fconfig);
  if (existingNode != NULL){
    /*Get the list of objects*/
    a_setf(ls_objects, existingNode->pointer->object);

    /*If there if a list of objects having the same key*/
    if (ls_objects != nil){ 
      myprintf("[Manual index] REMOVE OBJECT \n");
      a_setf(existingNode->pointer->object, removefn(varstack, oid_obj, 
						     ls_objects));
      a_free(ls_objects);
      return TRUE;
    } 
  }    
  /*If there is no node found, then FAlSE is returned*/
  return FALSE;
}

