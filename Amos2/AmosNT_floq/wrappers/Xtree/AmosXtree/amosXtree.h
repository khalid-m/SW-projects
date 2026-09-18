/*****************************************************************************
* AMOS2
*
* Author: (c) 2010 Thanh Truong, 
* $RCSfile: amosXtree.h,v $
* $Revision: 1.5 $ $Date: 2010/08/14 20:05:06 $
* $State: Exp $ $Locker:  $
*
* Description:  AMOSQL <-> X-tree interfaces
* Language:     C
****************************************************************************/
#ifndef _amosXtree_h_
#define _amosXtree_h_

#include "..\..\..\C\callout.h"
#include "cj.h"
#include "xtree.h"
#include "objbase.h"
#include <math.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK_RC(rc) assert((rc) == CJ_ERR_SUCCESS)


a_connection xtreeConn;

/*ListTree contains a list of entries <Xtree's ID, Xtree's address, Xtree's configuration>*/
typedef struct ListTree {
	struct ListTree *next;
	node_type* address;
	int id;
	config_type config;
} ListTree_type;

/* a global list of Xtree*/
ListTree_type *m_listTreeHead;
config_type master_config; // To hold configuration

cjJVM_t jvm;
cjClass_t cjFacadeClass;	
cjObject_t cjFacadeProxy;	

int rc;	
jobject dummy;	

a_connection getConnection();

/*Gets memory address of a tree given its ID*/
node_type* getXtree(int id);

/*Gets configuration of a tree given its ID*/
void getConfig(int id, config_type *fconfig);

/*Make a new Xtree*/
void xtree_make(a_callcontext cxt, a_tuple t);

/*Insert/ update a <key, object> into Xtree */
void xtree_put(a_callcontext cxt, a_tuple t);

/*Delete a pair <key, object> into Xtree */
void xtree_delete(a_callcontext cxt, a_tuple t);

/*Get a value(s) out of Xtree*/
void xtree_get(a_callcontext cxt, a_tuple t);

/*Save Xtree to file*/
void xtree_save(a_callcontext cxt, a_tuple t);

/*Load Xtree to file*/
void xtree_load(a_callcontext cxt, a_tuple t);

/*Extract color histogram*/

void colorHistogramExtractor(a_callcontext cxt, a_tuple t);

/*Shows pictures*/
void show_pictures_fn(a_callcontext cxt, a_tuple t);

/*Similarity search */
void xtree_similarity_search_fn(a_callcontext cxt, a_tuple t);

/*KNN search */
void xtree_knn_search_fn(a_callcontext cxt, a_tuple t);

/*Register foreign functions*/
void register_X_functions();

/*Introduce to system a new kind of index ; Xtree index*/
void register_xtree_index();

void free_object_handle(node_type *node, config_type fconfig);
#endif
