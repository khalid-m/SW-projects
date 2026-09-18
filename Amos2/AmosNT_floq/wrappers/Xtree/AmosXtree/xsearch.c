/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 thanh, UDBL . It was originally implemented by Cheung Ka
 * Leong(klcheung@cse) and Wong Chi Wing (cwwong@cse).
 * $RCSfile: xsearch.c,v $
 * $Revision: 1.8 $ $Date: 2010/06/22 05:48:15 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions to search in Xtree
 * 
 * ===========================================================================
 * $Log: xsearch.c,v $
 * Revision 1.8  2010/06/22 05:48:15  thtr1663
 * rewriter.lsp
 *
 * Revision 1.7  2010/06/07 08:24:04  thtr1663
 * change signature of function compare
 *
 * Revision 1.6  2010/06/04 14:18:35  thtr1663
 * Fix KNN search on multiple Xtree index
 *
 * Revision 1.5  2010/06/04 10:52:42  thtr1663
 * Remove ^M (ending line)
 *
 * Revision 1.4  2010/06/04 07:40:56  thtr1663
 * Modify Xtree to make it possible to store multiple index. Index hooks are 
 * updated accordingly
 *
 * 
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>

#include <string.h>

#ifndef WIN32
#include <sys/times.h>
#include <unistd.h>
#endif

#include "xtree.h"

int E_dist_comp_count = 0;
int E_page_access_count = 0;
int E_represent_accuracy = 0;
int E_prune_ans_no = 0;
int E_overlap_yes = 0;
int E_no_answer = 0;
int Num_of_super_node_access = 0;

/* Distance Computation */
double MINDIST(float *P, float *a, float *b, config_type fconfig) {
  int i;
  double sum = 0.0;

  for (i = 0; i < fconfig.dim; i++) {
    if (P[i] > b[i])
      sum += pow(P[i] - b[i], 2.0);
    else if (P[i] < a[i])
      sum += pow(a[i] - P[i], 2.0);
  }

  return sum;
}

double cal_Euclidean(node_type *node, float *query, config_type fconfig) {
  int i;
  double distance;
  distance = 0.0;

  for (i = 0; i < fconfig.dim; i++)
    distance += pow((node->a[i] - query[i]), (double) 2.0);

  return (sqrt(distance));
}


void NN_update(NN_type *NN, double dist, node_type *node, int k) {
  int i = 0;
  while (i < k - 1 && NN->next->dist >= dist) {
    NN->dist = NN->next->dist;
    NN->oid = NN->next->oid;
    NN->pointer = NN->next->pointer;
    a_setf(NN->object, NN->next->object);
    NN = NN->next;
    i++;
  }
  NN->dist = dist;
  NN->oid = node->id;
  NN->pointer = node;
  a_setf(NN->object, node ->object);
  return;
}

int compare(ABL *i, ABL *j) {
  if (i->min > j->min)
    return (1);
  if (i->min < j->min)
    return (-1);
  return (0);
}

void gen_ABL(node_type *node, ABL branch[], float *query, int total, 
	     config_type fconfig) {
  int i;
  for (i = 0; i < total; i++) {
    branch[i].node = node->ptr[i];
    branch[i].min = MINDIST(query, node->ptr[i]->a, node->ptr[i]->b, fconfig);
  }
  qsort(branch, total, sizeof(struct BranchArray), compare);
  return;
}

void k_NN_NodeSearch(node_type *curr_node, float *query, NN_type *NN, int k, 
		     config_type fconfig) {
  int i, total;
  double dist;
  ABL *branch;

  E_page_access_count++;
  if (curr_node->snodeSize > 1) {

    Num_of_super_node_access++;
  }

  /* Please refer NN Queries paper */
  /*[Thanh] Ignore the DELETED node*/
  if (curr_node->ptr[0]->attribute == LEAF && curr_node->object != nil) {
    //*** Ray changed
    //total = M - curr_node->vacancy;
    total = fconfig.M * curr_node->snodeSize - curr_node->vacancy;
    for (i = 0; i < total; i++) {
      dist = cal_Euclidean(curr_node->ptr[i], query, fconfig);
      if (dist < NN->dist)
	NN_update(NN, dist, curr_node->ptr[i], k);
    }
  } else {
    /* Please refer SIGMOD record Sep. 1998 Vol. 27 No. 3 P.18 */
    //**** Ray changed
    //total=M-curr_node->vacancy;
    total = fconfig.M * curr_node->snodeSize - curr_node->vacancy;
    branch = (struct BranchArray *) malloc(total
					   * sizeof(struct BranchArray));
    gen_ABL(curr_node, branch, query, total, fconfig);
    for (i = 0; i < total; i++) {
      if (branch[i].min >= NN->dist)
	break;
      else
	k_NN_NodeSearch(branch[i].node, query, NN, k, fconfig);
    }
    free(branch);
  }
  return;
}

NN_type* k_NN_search(node_type *root, float *query, int k, 
		     config_type fconfig) {
  int i,j;

  NN_type *NN, *head;

  for (j = 0; j < fconfig.dim; j++)
    myprintf("%f ", query[j]);
  myprintf("is found satisfied with\n");

  if ((NN = (NN_type *) malloc(sizeof(NN_type))) == NULL)
    fprintf(stderr, "malloc error at k-NN_search 1\n");

  NN->oid = UNDEFINED;
  NN->dist = INFINITY;
  NN->pointer = NULL;
  a_let(NN->object, nil);

  head = NN;

  for (i = 0; i < k - 1; i++) {
    if ((NN->next = (NN_type *) malloc(sizeof(NN_type))) == NULL)
      fprintf(stderr, "malloc error at k-NN_search 1\n");

    NN->next->oid = UNDEFINED;
    NN->next->dist = INFINITY;
    a_let(NN->next->object, nil);

    NN = NN->next;
  }
  NN->next = NULL;

  k_NN_NodeSearch(root, query, head, k, fconfig);

  NN = head;

  while (NN != NULL && NN->oid != UNDEFINED) {
    //myprintf("%d %f\n", NN->oid, NN->dist);
    NN = NN->next;
  }
  return head;

}



void xtree_rangequery_result_update(NN_type *NN, double dist, node_type *node) {
  while(NN->next!=NULL) {
    NN = NN->next;
  }

  NN->dist = dist;
  NN->oid = node->id;
  NN->pointer = node;
  a_let(NN->object, node->object);
  NN->valuable = 1;
        
  if ((NN->next = (NN_type *) malloc(sizeof(NN_type))) == NULL) {
    fprintf(stderr, "malloc error at xtree_rangequery_result_update\n");
  }
  NN->next->oid = UNDEFINED;
  NN->next->dist = INFINITY;
  NN->next->valuable = 0;
  NN->next->next = NULL;
  NN->next->object = nil;
        
}

int xtree_rectangle_search(node_type *curr_node, float *query, NN_type *NN, 
			   double error, config_type fconfig) {
  int find_flag;
  int i, j, stop, flag;
  double distance;      
  if (curr_node->snodeSize > 1) {
  }
        
  /* Search leaf node */
/* [Thanh] Ignored DELETED node*/ 
 if (curr_node->attribute == LEAF && curr_node->object != nil) {
   //distance = 0.0;
   //for (i = 0; i < dim; i++)
   //  distance += pow((curr_node->a[i] - query[i]), (double) 2.0);
                
   //distance = (sqrt(distance));
   distance = cal_Euclidean(curr_node, query, fconfig);
   // normalize the value
   //if (distance > 0) {
   //  distance = 1/ distance;
   //}
                
   if (distance <= error) {
                        
     for (j = 0; j < fconfig.dim; j++)
       myprintf("%f ", curr_node->a[j]);
      
     myprintf("  at %d\n", curr_node->id);
     xtree_rangequery_result_update(NN, distance, curr_node);     
   }
   return (FOUND);                
 }
     
 /**** RAY CHANGED*/
 /*stop = M - curr_node->vacancy;*/
 stop = fconfig.M * curr_node->snodeSize - curr_node->vacancy;

 for (i = 0; i < stop; i++) {
   flag = TRUE;
   /* search subtree */
   for (j = 0; j < fconfig.dim; j++) {
     if (curr_node->ptr[i]->a[j] > (query[j] + error)
	 || curr_node->ptr[i]->b[j] < (query[j] - error)) {
       flag = FALSE;
       break;
     }
   }
   /* search the node which contains the query */
   if (flag == TRUE) {
     find_flag = xtree_rectangle_search(curr_node->ptr[i], query, NN,error, 
					fconfig);
   }
 }
 return (find_flag);
        
}

NN_type* xtree_rectangle_search_tree(node_type *root,  float *query, 
				     double error, config_type fconfig) {
  int j, find_flag = NOT_FOUND;
  NN_type *NN;
  NN_type *head;
        
  /* start search data points by invoking rectangle_search() */
  for (j = 0; j < fconfig.dim; j++)
    myprintf("%f ", query[j]);
  myprintf("is found satisfied with\n");
        
  find_flag = NOT_FOUND;
  //////////////////////
  // Allocate a first space of a chain
        
  if ((NN = (NN_type *) malloc(sizeof(NN_type))) == NULL)
    fprintf(stderr, "malloc error at xtree_rectangle_search_tre\n");
  NN->oid = UNDEFINED;
  NN->dist = INFINITY;
  NN->pointer = NULL;
  NN->object = nil;
  NN->valuable = 0;
  NN->next = NULL;
        
  head = NN;
        
  if ((NN->next = (NN_type *) malloc(sizeof(NN_type))) == NULL)
    fprintf(stderr, "malloc error at xtree_rectangle_search_tre\n");
        
  NN->next->oid = UNDEFINED;
  NN->next->dist = INFINITY;
  NN->next->valuable = 0;
  NN->next->next = NULL;
  NN->object = nil;
        
  NN = NN->next;

       
  find_flag = xtree_rectangle_search(root, query, head, error, fconfig); 
     
  //NN = head;

  return NN;  
} /* rectangle_search_tree */


#ifndef THANH

#endif
