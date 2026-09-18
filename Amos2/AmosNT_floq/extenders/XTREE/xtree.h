#ifndef _xtree_h_
#define _xtree_h_
/*
  CSC 5120 Project
  Group 2
  Members : Cheung Ka Leong (99586612) (klcheung@cse)
  Wong Chi Wing   (99681242) (cwwong@cse)
*/
#include <stdarg.h>
#include <float.h>
#include "callout.h"

#define CONFIG_FILE	"xtree.config"

#define FALSE    	0
#define TRUE     	1
#define ASC_NUM  	48
#define NO_ID	 	-1
#define FOUND		1
#define NOT_FOUND 	0

#define ROOT  0
#define LEAF  1
#define NODE  2

#define XTREE_INFINITY DBL_MAX //2500 
// for d_max in NN, equals ((highest dim)*(max dist))^2
#define UNDEFINED -3  // for id of entries in PR
#define MAX_X_SNODE 2

// Bunch of Thanh's configuration
#ifndef THANH
#define THANH
#define T_DISK_MEMORY 1
#define DEBUG_MODE debugMode
#endif

int DIM_DISAGREE;
int DELETED_NODE_FOUND;

int debugMode;

FILE *filePtrID;

int extra_level;

typedef struct node {
  float *a;
  float *b;
  int id;
  int attribute;
  int vacancy;
  struct node *parent;
  struct node **ptr;
  //*** Ray added the following internal variable
  int snodeSize;
  oidtype object; // to hold object handle of Amos II
} node_type;

typedef struct NN {
  double dist;
  int oid;
  struct node *pointer;
  struct NN *next;
  oidtype object;
  int valuable;
} NN_type;

typedef struct BranchArray {
  double min;
  node_type *node;
} ABL;

typedef struct config {
  int dim;
  int m;
  int M;
  int reinsert_p;
  int no_histogram;
  // Number of element in a tree . Added by 31st May
  // Increase/ decrease when xtree is updated.
  int counter;
} config_type;

config_type master_config; // To hold configuration

// prototypes for Xfile.tree.c
void myprintf(char* fmt, ...);
void write_inter_node(node_type *node, FILE *fp, config_type fconfig);
void read_inter_node(node_type *node, FILE *fp, config_type fconfig);

// prototypes for Xsearch.tree.c
int rectangle_search(node_type *curr_node, float *query, float error, 
		     config_type fconfig);
NN_type* k_NN_search(node_type *root, float *query, int k, 
		     config_type fconfig);

// prototypes for Xbuild.tree.c
node_type * o_xtree_make(config_type fconfig);
void* o_xtree_put(node_type *root, float *data, int* newflag, 
		config_type fconfig);
void o_xtree_save(FILE *fp, node_type *root, char filename[FILENAME_MAX]);
int o_xtree_load(FILE *fp, char filename[FILENAME_MAX]);
NN_type* o_xtree_get(node_type *root, float *key, config_type fconfig);
void* im_xtree_delete(node_type *root, float *key, config_type fconfig);

void choose_leaf_level(node_type **node_found, node_type *current_node,
		       int current_level, node_type *inserted_node, 
		       int desired_level, config_type fconfig);

int choose_leaf(node_type **node_found, node_type *current_node,
		int current_level, node_type *data_node, config_type fconfig);

void adjust_MBR_delete(node_type *node_inserted, config_type fconfig);
void overflow(node_type *, int, int, node_type *, node_type *, 
	      config_type fconfig);

void adjust_MBR(node_type *node_inserted, config_type fconfig);

// prototypes for Xtree.c
void initialize(config_type *config);
void tree_node_allocate(node_type **node, config_type fconfig);
NN_type* xtree_rectangle_search_tree(node_type *root,  float *query, 
				     double error, config_type fconfig);
void getConfig(int id, config_type *fconfig);
double cal_Euclidean(node_type *node, float *query, config_type fconfig);


/*Update list of tree. Each entry contains pair value 
  <ID, memory address> together with a pointer to the next
  entry in the list
*/
int updateListTree(int id, node_type* address, config_type fconfig);
int getIndexIdonFunction(int pos, oidtype indexedFunction);

#endif
