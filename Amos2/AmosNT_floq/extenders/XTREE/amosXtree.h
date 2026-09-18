/*****************************************************************************
* AMOS2
*
* Author: (c) 2010 Thanh Truong, 
* $RCSfile: amosXtree.h,v $
* $Revision: 1.2 $ $Date: 2013/08/01 13:02:27 $
* $State: Exp $ $Locker:  $
*
* Description:  AMOSQL <-> X-tree interfaces
* Language:     C
****************************************************************************/
#ifndef _amosXtree_h_
#define _amosXtree_h_

#include "xtree.h"
//#include "objbase.h"
#include <math.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#ifndef NT
#include <fcntl.h>
#endif
#define  UNDEFINED_ID -1;
/*ListTree contains a list of entries <Xtree's ID, Xtree's address, Xtree's configuration>*/
typedef struct ListTree {
	struct ListTree *next;
	node_type* address;
	int id;
	config_type config;
} ListTree_type;

/* a global list of Xtree*/
ListTree_type *m_listTreeHead;
int idgenerator;


a_connection getConnection();

/*Gets memory address of a tree given its ID*/
node_type* getXtree(int id);

/*Gets memory address of a tree descriptor given its ID*/
ListTree_type* getXtDescriptor(int id);

/*Gets configuration of a tree given its ID*/
void getConfig(int id, config_type *fconfig);

/*Save Xtree to file*/
void xtree_save(a_callcontext cxt, a_tuple t);

/*Load Xtree to file*/
void xtree_load(a_callcontext cxt, a_tuple t);

void xtree_distance_search(a_callcontext cxt, a_tuple t);

/*Distance search */
void xtree_distance_search_fn(a_callcontext cxt, a_tuple t);

/*KNN search */
void xtree_knn_search_fn(a_callcontext cxt, a_tuple t);

/*Register foreign functions*/
void register_xtree_foreignfunctions();

/*Introduce to system a new kind of index ; Xtree index*/
void register_xtree_index_hooks();

void register_xtree();

void free_object_handle(node_type *node, config_type fconfig);

float* getFeatures(oidtype key);
#define INDEX_MANAGER 0
#define INDEX_MANUAL  1
#endif
