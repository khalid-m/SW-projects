/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Thanh Truong, 
 * $RCSfile: xfile.c,v $
 * $Revision: 1.4 $ $Date: 2010/06/04 10:52:41 $
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
		fprintf(fp, "%f\n", (node->a)[i]);

	for (i = 0; i < fconfig.dim; i++)
		fprintf(fp, "%f\n", (node->b)[i]);

	fprintf(fp, "%d\n", node->attribute);
	fprintf(fp, "%d\n", node->id);
	fprintf(fp, "%u\n", (unsigned int)node->object);
	fprintf(fp, "%d\n", node->vacancy);
	//fprintf(filePtrID, "%d\n", node->id);
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
		fprintf(fp, "%f\n", (node->a)[i]);
	//fprintf(fp, "%f\n", 0.0f);

	for (i = 0; i < fconfig.dim; i++)
		fprintf(fp, "%f\n", (node->b)[i]);
	//fprintf(fp, "%f\n", 1.0f);

	fprintf(fp, "%d\n", node->attribute);
	fprintf(fp, "%d\n", node->vacancy);
	// **** Ray added
	fprintf(fp, "%d\n", node->snodeSize);
	if (node->snodeSize > 1) {
		myprintf("**** has supernode (%d)\n", node->snodeSize);
		myprintf("     vacancy (%d)\n", node->vacancy);
	}

	// **** Ray changed
	//count = M - node->vacancy;
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
		fscanf(fp, "%f\n", &((node->a)[i]));

	for (i = 0; i < fconfig.dim; i++)
		fscanf(fp, "%f\n", &((node->b)[i]));

	fscanf(fp, "%d\n", &(node->attribute));
	if (node->attribute == LEAF) {
		fscanf(fp, "%d\n", &(node->id));
		fscanf(fp, "%u\n", &(node->object));
	}
	fscanf(fp, "%d\n", &(node->vacancy));

	if (node->attribute != LEAF) {
		fscanf(fp, "%d\n", &(node->snodeSize));

		free(node->ptr);
		node->ptr = (node_type **) malloc(sizeof(node_type *) * fconfig.M
				* node->snodeSize);

		//myprintf(" **** snodeSize: %d\n", node->snodeSize);
		if (node->snodeSize > 1) {
			myprintf("hello\n");
			myprintf("  vacancy: %d\n", node->vacancy);
			myprintf("  snodeSize: %d\n", node->snodeSize);
		}
	}

	

	if (node->attribute != LEAF) {
		count = fconfig.M * node->snodeSize - node->vacancy;
		for (i = 0; i < count; i++) {
			tree_node_allocate(&(node->ptr[i]), fconfig);
			read_inter_node(node->ptr[i], fp, fconfig);
		}
	}

	return;

}





