/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Thanh Truong, 
 * $RCSfile: xfile.c,v $
 * $Revision: 1.1 $ $Date: 2012/01/04 14:48:49 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  AMOSQL <-> X-tree interfaces
 * Language:     C
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>

#include <string.h>
#include "xtree.h"

/*---------------------------------
 */
void myprintf(char* fmt, ...)
{
  if (DEBUG_MODE == 1) {
    va_list args;
    va_start(args,fmt);
    vprintf(fmt,args);
    va_end(args);
  }
}

/*
  function : void write_leaf_node(node_type *node, FILE *fp)
  purpose  : to write the information of the leaf node to the file pointer fp
  parameter: node_type *node - the leaf node to be written
  FILE *fp        - the file pointer pointing to the file
  return   : none
*/
void write_leaf_node(node_type *node, FILE *fp, config_type fconfig) {
  int i;
  
  for (i = 0; i < fconfig.dim; i++)
    fprintf(fp, "%f;", (node->a)[i]);

   for (i = 0; i < fconfig.dim; i++)
    fprintf(fp, "%f;", (node->b)[i]);

  fprintf(fp, "%d;%d;%u;%d\n", node->attribute, node->id, 
	  (unsigned int)node->object, node->vacancy);
  return;
}
/*
  function : void write_inter_node(node_type *node, FILE *fp)
  purpose  : to write the internal node to the file pointer fp
  parameter: node_type *node - the internal node to be written to the file
  FILE *fp        - the file pointer pointing to the file to be written
  return   : none
*/
void write_inter_node(node_type *node, FILE *fp, config_type fconfig) {
  int i, count;

  for (i = 0; i < fconfig.dim; i++)
    fprintf(fp, "%f;", (node->a)[i]);
 
  for (i = 0; i < fconfig.dim; i++)
    fprintf(fp, "%f;", (node->b)[i]);
 
  fprintf(fp, "%d;%d;%d\n", node->attribute, node->vacancy, node->snodeSize);

  count = fconfig.M * node->snodeSize - node->vacancy;
  for (i = 0; i < count; i++) {
    if (node->ptr[i]->attribute != LEAF)
      write_inter_node(node->ptr[i], fp, fconfig);
    else
      write_leaf_node(node->ptr[i], fp, fconfig);
  }
  return;

}
void read_inter_node(node_type *node, FILE *fp, config_type fconfig) {
  int i, count;

  for (i = 0; i < fconfig.dim; i++)
    fscanf(fp, "%f;", &((node->a)[i]));

  for (i = 0; i < fconfig.dim; i++)
    fscanf(fp, "%f;", &((node->b)[i]));

  fscanf(fp, "%d;", &(node->attribute));
  if (node->attribute == LEAF) {
    fscanf(fp, "%d;", &(node->id));
    fscanf(fp, "%u;", &(node->object));
    fscanf(fp, "%d\n", &(node->vacancy));

  } else {
    fscanf(fp, "%d;", &(node->vacancy));
    fscanf(fp, "%d\n", &(node->snodeSize));
    
    free(node->ptr);
    node->ptr = (node_type **) malloc(sizeof(node_type *) * fconfig.M
				      * node->snodeSize);

    count = fconfig.M * node->snodeSize - node->vacancy;
    for (i = 0; i < count; i++) {
      tree_node_allocate(&(node->ptr[i]), fconfig);
      read_inter_node(node->ptr[i], fp, fconfig);
    }

  }
 
  return;
}





