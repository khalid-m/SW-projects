/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 thanh, UDBL . It was originally implemented by Cheung Ka
 * Leong(klcheung@cse) and Wong Chi Wing (cwwong@cse).
 * $RCSfile: xtree.c,v $
 * $Revision: 1.2 $ $Date: 2013/08/01 13:02:28 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions to constructXtree
 * 
 * ===========================================================================
 * $Log: xtree.c,v $
 * Revision 1.2  2013/08/01 13:02:28  thatr500
 * Xtree is handled by mexima_generic_api
 *
 * Revision 1.1  2012/01/04 14:48:50  thatr500
 * add Xtree extender
 *
 * Revision 1.6  2011/01/25 12:24:52  thatr500
 * supports EXINMA delivered as a DLL (Windows)
 *
 * Revision 1.5  2010/12/01 19:20:02  thatr500
 * use EXSTMA to integerate Xtree
 *
 * Revision 1.4  2010/11/22 09:00:58  thatr500
 * compact all index files into one
 *
 * Revision 1.3  2010/11/02 08:06:21  thatr500
 * remove redudant function
 *
 * Revision 1.2  2010/10/27 15:50:48  thatr500
 * Fix: itoa does not exist in all Unix systems
 *
 * Revision 1.1  2010/08/20 13:46:04  thtr1663
 * add xtree package
 *
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
#include "xtreeconst.h"

/*---------------------------------------------------------------------
  function : void initialize(config_type *config)
  purpose  : to initialize the configuration of X-tree
  parameter: config_type *config - the configuration structure
  return   : none
  ---------------------------------------------------------------------*/
void initialize(config_type *fconfig) {
  fconfig->dim = master_config.dim = UNDEFINED;
  fconfig->M = master_config.M = 20;
  fconfig->m = master_config.m = 4;
  fconfig->no_histogram = master_config.no_histogram = 52;
  fconfig->reinsert_p = master_config.reinsert_p = 4;
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

void* o_xtree_put(node_type *root, float *data,int* newflag,
		config_type fconfig) {
  node_type *node_found, *new_node, *data_node;
  NN_type *existingNode;
  int level_found;
  int i;
  node_found = root;
  extra_level = 0;

  existingNode = o_xtree_get(root, data, fconfig);
  if (existingNode != NULL){    
	(*newflag) = FALSE;
    return (void*) &existingNode->pointer->object;
  }
  /*There is no such of node found. We insert a new node*/
  myprintf("\n INSERTED a new node \n");

  /*-----------------------*/
  /* END OF MULTIPLE INDEX*/
  /*-----------------------*/

  /*NOTE : Below is the code to add a new node ( <list(object), key> )
    into Xtree. The list now has only one element.
  */
  // Copy data to a temp node which is used to find if existing node
  tree_node_allocate(&data_node, fconfig);
  for (i = 0; i < fconfig.dim; i++) {
    data_node->a[i] = data[i];
    data_node->b[i] = data[i];
  }

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
  // Thanh Nov 29th : Make it as a list
  new_node->object = UNDEFINED;

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
  (*newflag) = TRUE;   
  new_node->object = UNDEFINED;
  tree_node_deallocate(data_node);
  return (void *) &new_node->object;
}


void o_xtree_save(FILE * fp, node_type *root, char filename[FILENAME_MAX]) {
  //FILE *fp;
  config_type fconfig;

  getConfig((*root).id, &fconfig);
  // Print out the configuration of the xtree to file
  fprintf(fp, "%d;m=%d;M=%d;dim=%d;reinsert_p=%d;no_histogram=%d;counter=%d\n",
	  root->id,
	  fconfig.m,
	  fconfig.M,
	  fconfig.dim,
	  fconfig.reinsert_p,
	  fconfig.no_histogram,
	  fconfig.counter);
 
  write_inter_node(root, fp, fconfig);  
  return;
}

int o_xtree_load(FILE* fp, char filename[FILENAME_MAX]) {
  //FILE *fp;
  node_type *root;
  config_type fconfig;
  int id = UNDEFINED;
 
  fscanf(fp, "%d;m=%d;M=%d;dim=%d;reinsert_p=%d;no_histogram=%d;counter=%d\n",
	 &id,
	 &fconfig.m,
	 &fconfig.M,
	 &fconfig.dim,
	 &fconfig.reinsert_p,
	 &fconfig.no_histogram,
	 &fconfig.counter);
  
  tree_node_allocate(&root, fconfig);
  (*root).id = id;

  updateListTree((*root).id,  root, fconfig);

  read_inter_node(root, fp, fconfig);

  return id;
}
/**
 * Given a key, the function marks the associated node as DELETED. 
 * A deleted node should be ignored during the search.
 * This function is only called by INDEX MANAGER via index hook deleter.
 */ 
void* im_xtree_delete(node_type *root, float *key, config_type fconfig) {

  NN_type *existingNode; /* A list of leaf nodes which are results of a search*/ 
  unsigned int val;
 
  existingNode = o_xtree_get(root, key, fconfig);
  if (existingNode != NULL){
    if (existingNode->pointer->object!= nil){ 
		val = existingNode->pointer->object;
		existingNode->pointer->object = nil;
		return (void*) val;
    }
  } 
  return NULL;
}

/*-----------------------------------------------------
  Remove a Xtree
-----------------------------------------------------*/

