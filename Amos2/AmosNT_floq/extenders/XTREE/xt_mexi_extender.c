/*****************************************************************************
* AMOS2
*
* Author: (c) 2011 Thanh Truong, UDBL
* $RCSfile: xt_mexi_extender.c,v $
* $Revision: 1.4 $ $Date: 2013/11/18 17:51:20 $
* $State: Exp $ $Locker:  $
*
* Description: MEXIMA Extender for XTREE index
* ===========================================================================
* $Log: xt_mexi_extender.c,v $
* Revision 1.4  2013/11/18 17:51:20  thatr500
* added mapping function, that iterates through all indexed items
*
* Revision 1.3  2013/08/01 13:02:28  thatr500
* Xtree is handled by mexima_generic_api
*
* Revision 1.2  2012/01/12 07:46:19  thatr500
* fix Unix compilation error
*
* Revision 1.1  2012/01/04 14:48:50  thatr500
* add Xtree extender
*
****************************************************************************/
#include <stdio.h>
#include <limits.h>
#include "../../system/C/mexima/mexima.h" /* MEXIMA API */
#include "amosXtree.h" /* XTREE API */


EXPORT void a_initialize_extension(void *xa);


extern void define_index(struct mexi_index_props idxro);

int clearUpXtree(int id) {
  ListTree_type * pos, * prev;
  config_type fConfig;
  
  pos = m_listTreeHead;
  prev = m_listTreeHead;

  //A Find pos of that Xtree in the list
  while (pos != NULL){
    if (pos->id == id) {
      break;
    } 
    prev = pos;
    pos = pos->next;
  }
  
  // It stopped at either the head or somewhere at the middle
  if (pos != NULL) {    
    // B Leave it out of the list of Xtree
    prev->next = pos->next;
    if (m_listTreeHead == pos) {
      m_listTreeHead = prev->next;
    }
    pos->next = NULL;
    

    fConfig.dim = pos->config.dim;
    fConfig.M = pos->config.M;
    fConfig.m = pos->config.m;
    fConfig.no_histogram = pos->config.no_histogram;
    fConfig.reinsert_p = pos->config.reinsert_p;
    fConfig.counter = pos->config.counter;

    // C Free links to Amos
    free_object_handle((node_type *)pos->address, fConfig);
    
    // D Free the tree
    if (pos->address != NULL) {
      free(pos->address);
    }     

    pos = NULL; 
  }
  return (m_listTreeHead == NULL)? TRUE: FALSE;
}


/* Create new XTREE index xt */
void *xtintf_create(unsigned int paras)
{
	node_type *root;
	int indexID;
	ListTree_type * xtdescr;
	xtdescr = NULL;
	root = NULL;
	
	// Update the list of trees.
	indexID = updateListTree(-1, root, master_config);
	// return xt descriptor
	return getXtDescriptor(indexID);
}


/* Get value for given key in XTREE index xt */
void *xtintf_get(void *xt, void *key, mexi_compare cmp)
{
	int size;
	float *data;
	NN_type * existingNode;
	node_type *root;
	config_type fconfig;
	ListTree_type * xtdescr;
	xtdescr = (ListTree_type *) xt;
		
	if (xtdescr != NULL) {
		// Get size of the key ( array of numbers)
		size = dr((oidtype) key, arraycell)->size;
		// Tree's configuration
		getConfig(xtdescr->id, &fconfig);		
		// Address of the tree
		root = getXtree(xtdescr->id);
		
		if (root != NULL) {
			(*root).id = xtdescr->id;			
			data = getFeatures((oidtype)key);
			existingNode = o_xtree_get(root, data, fconfig);
			if (existingNode != NULL && existingNode->valuable == 1) {
				return (void *) &existingNode->pointer->object;
			}
		}
	}
	return NULL;  
}

/* Insert key into XTREE index xt. 
Return pointer to corresponding value for key. 
Set newflag=TRUE if the key was not there before */
void *xtintf_put(void *xt, void * key, int *newflag, mexi_compare cmp) 
{	  
	int size;
	float *data;
	ListTree_type * xtdescr;	
	node_type *root;
	config_type fconfig;
	oidtype* pval; // pointer to a cell hosting value
	xtdescr = (ListTree_type *) xt;
	
	if (xtdescr != NULL) {
		// Get size of the key ( array of numbers)
		size = dr((oidtype) key, arraycell)->size;	
		// Take its configuration
		getConfig(xtdescr->id, &fconfig);
		// Take address (memory space) of the tree
		root = getXtree(xtdescr->id);
		
		// If it is the first PUT, then allocate the memory the the tree  
		if (root == NULL && fconfig.counter == 0) {
			fconfig.dim = size;
			fconfig.counter = 0;
			root = o_xtree_make(fconfig);
			(*root).id = xtdescr->id;
		}
		// One it is done or the tree exists 
		if (root != NULL) {
			(*root).id = xtdescr->id;
			
			// Check configuration and actually size of key agrument
			if (size != fconfig.dim) {
				a_error(DIM_DISAGREE ,mkinteger(size), FALSE);
			}
			
			data = getFeatures((oidtype) key);
			
			// Increase the counter
			fconfig.counter++;
			// Return pointer to data value for the key		
			pval = (oidtype*) o_xtree_put(root, data, newflag, fconfig);
			updateListTree(xtdescr->id, root, fconfig);
			return pval; 
		}
		
	}
	return NULL;
}

/* Delete key from XTREE index. 
If the key exists
kvp->key = deleted key
kvp->val = deleted val
return TRUE;
Else
return FALSE;
*/
int xtintf_delete(void *xt, void *key,  struct kv *kvp,  mexi_compare cmpfn) 
{
	float *data;
	node_type *root;
	config_type fconfig;
	ListTree_type * xtdescr;
	void* val;

	xtdescr = (ListTree_type *) xt;
	
	// Take its configuration
	getConfig(xtdescr->id, &fconfig);
	
	// Take address (memory space) of the tree
	root = getXtree(xtdescr->id);
	
	// One it is done or the tree exists 
	if (root != NULL) {
		(*root).id = xtdescr->id;		
		data = getFeatures((oidtype) key);
		
		val = im_xtree_delete(root, data, fconfig);
		if (val != NULL){
			fconfig.counter --;
			updateListTree((*root).id, root, fconfig);
			kvp->key = key;
			kvp->val = val;
			return TRUE;
		}
	}
	return FALSE;
}

/* Deallocate the XTREE */
void xtintf_drop(void *xt) 
{
	ListTree_type* xtdescr;
	xtdescr = (ListTree_type*) xt;
	if (xtdescr != NULL) {
		clearUpXtree(xtdescr->id);
	}
}

struct applyMapData
{
	KVPmapper mapfn;
	config_type config;
	void* xa;
};
int emitMultiplekv(oidtype kv, void* xa) {
	oidtype tmp;
	int arraysize;
	struct applyMapData *btxa = (struct applyMapData *)xa;
	if (listp(kv) && hd(kv)){
		tmp = hd(kv);
		arraysize = a_arraysize(tmp);
		if (arraysize == 1) { /*Kv consists only value no key*/									
			return btxa->mapfn(NULL, (void*) kv, btxa->xa);	
			/*correct case 3*/
		} else {
			/*correct case 4*/
			return btxa->mapfn((void*) NULL, (void*) kv, btxa->xa);
		}
	}     
	return TRUE;
}
int emitUniquekv(oidtype kv, void* xa) {
	int arraysize;
	struct applyMapData *btxa = (struct applyMapData *)xa;
    if (arrayp(kv)) {
		arraysize = a_arraysize(kv);
		if (arraysize == 1) { /*Kv consists only value no key*/						
			return btxa->mapfn(NULL, (void*) kv, btxa->xa);	
			/*correct case 1*/
		} else if (arraysize == 2){
			return btxa->mapfn((void*) NULL, (void*) kv, btxa->xa);
			/*correct case 2 + case 2b*/
		}
	}
	return TRUE;
}
int scan_leaf_node(node_type *node, void* xa) {
	oidtype item;
	int nostop;
	struct applyMapData *btxa = (struct applyMapData *)xa;
	nostop = TRUE;
	item = node->object;
	if (item != nil) {
		if (listp(item) && item != nil) {
			// multiple index		
			nostop = emitMultiplekv(item, xa);
		} else if (arrayp(item)) {
			// unique index	
			nostop = emitUniquekv(item, xa);
		}
		return nostop;
	}
	return TRUE;
}
int scan_leaf_node1(node_type *node, void* xa) {
	oidtype item;
	int nostop;	
	item = node->object;
	nostop = TRUE;
	if (item != nil) {
		if (listp(item)) {
			
		} else if (arrayp(item)) {
			
		}
		printf("Here for a little while");a_print(item);
		return nostop;
	}
	return TRUE;
}
int scan_inter_node(node_type *node, void* xa) {
  int i, count, nostop;
  struct applyMapData *btxa = (struct applyMapData *)xa;

  count = btxa->config.M * node->snodeSize - node->vacancy;
  nostop = TRUE;
  for (i = 0; i < count && nostop == TRUE; i++) {
    if (node->ptr[i]->attribute != LEAF)
      nostop = scan_inter_node(node->ptr[i], xa);
    else
      nostop = scan_leaf_node(node->ptr[i], xa);
  }
  return nostop;
}

int xtmapper(void *bi, void *xa)
{
	return TRUE;
}

/* Map over range in XTREE index */
void xtinf_range_mapping (void *xt,  KVPmapper mapfn, void *lower, 
						  void *upper, mexi_compare cmpfn, void *xa)
{
	// Not support !
}


/*Total mapper to iterate all items in the index ind*/
void xtintf_full_mapping(void *xt, KVPmapper  mapfn , mexi_compare cmpfn,
						 void *xa)
{
	ListTree_type* xtdescr;
	node_type *root;
	struct applyMapData btxa;
	config_type fconfig;
	
	xtdescr = (ListTree_type*) xt;
	if (xtdescr != NULL) {
		root = getXtree(xtdescr->id);
		if (root == NULL) {
			return;
		}
		getConfig((*root).id, &fconfig);
		btxa.mapfn = mapfn;
		btxa.xa = xa;
		//btxa.config = fconfig;
		btxa.config.dim = fconfig.dim;
		btxa.config.M = fconfig.M;
		btxa.config.m = fconfig.m;
		btxa.config.no_histogram = fconfig.no_histogram;
		btxa.config.reinsert_p = fconfig.reinsert_p;
		btxa.config.counter = fconfig.counter;

		scan_inter_node(root, (void*) &btxa);			
	}
}


/*Get identifier number of mexi object if applicable.*/
int xt_getidentifier(void* xt)
{
	ListTree_type* xtdescr;
	xtdescr = (ListTree_type*) xt;
	if (xtdescr != NULL) {
		return xtdescr->id;
	}
	return -1;
}


EXPORT void a_initialize_extension(void *xa)
{ 
	struct mexi_index_props idxpros;  
	
	strcpy(idxpros.name, "XTREE"); /* Name of index */
	idgenerator = UNDEFINED_ID;
	// Initialize error message
	DIM_DISAGREE = 
		a_register_error("Feature vector dimensionality different from configuration");
	
	DELETED_NODE_FOUND = 
		a_register_error("Critical error happened since DELETED NODE was found");
	
	/* Read default configuration*/
	initialize(&master_config);
	idxpros.create = xtintf_create;
	idxpros.get = xtintf_get;
	idxpros.put = xtintf_put;
	idxpros.remove = xtintf_delete;
	idxpros.drop = xtintf_drop;
	idxpros.range_mapping = xtinf_range_mapping;
	idxpros.full_mapping = xtintf_full_mapping; 
	idxpros.compare = NULL; /* let mexima decide compare function */
	idxpros.getidentifer = xt_getidentifier;
	define_index(idxpros);

	a_extfunction("xtree_distance_search", xtree_distance_search);
	a_extfunction("xtree_distance_search_fn", xtree_distance_search_fn);
	a_extfunction("xtree_knn_search_fn", xtree_knn_search_fn);
}
