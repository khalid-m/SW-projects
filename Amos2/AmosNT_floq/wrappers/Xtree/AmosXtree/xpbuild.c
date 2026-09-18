/*
 CSC 5120 Project
 Group 2
 Members : Cheung Ka Leong (99586612) (klcheung@cse)
 Wong Chi Wing   (99681242) (cwwong@cse)
 */

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

#define DEBUG 1

void overflow(node_type *, int, int, node_type *, node_type *, config_type fconfig);

/*
 function : int hasLeafElement(node_type *node, int reqID)
 purpose  : to check whether there is a leaf node with leaf node id reqID
 parameter: node_type *node - leaf node to be examined
 int reqID       - the node id to be examined
 return   : int - the boolean to represent whether there is a node
 with node id reqID
 */
int hasLeafElement(node_type *node, int reqID) {

	if (node->id == reqID) {
		return TRUE;
	} else {
		return FALSE;
	}
}

/*
 function : int hasInterElement(node_type *node, int reqID)
 purpose  : to check whether there is a leaf node with leaf node id reqID for all
 children at this internal node
 parameter: node_type *node - the internode with all children to be examined
 int reqID       - the node id to be examined
 return   : int - the boolean to represent whether there is a node with node
 node id reqID for all children at this internal node
 */
int hasInterElement(node_type *node, int reqID, config_type fconfig) {
	int i, count;
	int returnValue;

	returnValue = FALSE;

	count = fconfig.M * node->snodeSize - node->vacancy;
	for (i = 0; i < count; i++) {
		if (node->ptr[i]->attribute != LEAF) {
			//if (hasInterElement(node->ptr[i], reqID) == TRUE) {
			//	returnValue = TRUE;
			//}
			return hasInterElement(node->ptr[i], reqID, fconfig);
		} else {
			return hasLeafElement(node->ptr[i], reqID);
		}
	}

	return returnValue;
}

/* initialize */

void tree_temp_node_allocate(node_type **node, int snodeSize,config_type fconfig) {
	(*node) = (node_type *) malloc(sizeof(node_type));
	(*node)->a = (float *) malloc(sizeof(float) * fconfig.dim);
	(*node)->b = (float *) malloc(sizeof(float) * fconfig.dim);
	(*node)->ptr = (node_type **) malloc(sizeof(node_type *) * snodeSize * fconfig.M);

	// *** Ray added
	(*node)->snodeSize = 1;
}

/*
 function : void tree_node_deallocate(node_type *free_node)
 purpose  : to free the node
 parameter: node_type *free_node - the node to be freed
 return   : none
 */
void tree_node_deallocate(node_type *free_node) {

	free(free_node->a);
	free(free_node->b);
	free(free_node->ptr);

	free(free_node);

}

/*
 function : void cal_MBR_node_node(float *new_a, float *new_b, node_type *node1, node_type *node2)
 purpose  : to calculate the MBR among two nodes
 parameter: float *new_a     - the returned array of the lower bound for each dimension
 float *new_b     - the returned array of the upper bound for each dimension
 node_type *node1 - the first to be calculated
 node_type *node2 - the second to be calculated
 return   : none
 */
void cal_MBR_node_node(float *new_a, float *new_b, node_type *node1,
		node_type *node2, config_type fconfig) {
	int i;

	for (i = 0; i < fconfig.dim; i++) {

		if (node1->a[i] < node2->a[i])
			new_a[i] = node1->a[i];
		else
			new_a[i] = node2->a[i];
	}

	for (i = 0; i < fconfig.dim; i++) {

		if (node1->b[i] > node2->b[i])
			new_b[i] = node1->b[i];
		else
			new_b[i] = node2->b[i];
	}

	return;

}

/*
 function : double cal_vol(float *a, float *b)
 purpose  : to calculate the volume of the given bound
 parameter: float *a - the array of the lower bounds for each dimension
 float *b - the array of the upper bounds for each dimension
 return   : double - the volume of the give bounds
 */
double cal_vol(float *a, float *b, config_type fconfig) {
	int i;
	double volume = 1.0;

	for (i = 0; i < fconfig.dim; i++)
		volume = volume * (double) (b[i] - a[i]);

	return (volume);

}

/*
 function : double cal_overlap(node_type *node1, node_type *node2)
 purpose  : to calculate the overlap of these given two nodes
 parameter: node_type *node1 - the 1st node
 node_type *node2 - the 2nd node
 return   : double - the overlap of these give two nodes
 */
double cal_overlap(node_type *node1, node_type *node2, config_type fconfig) {
	double overlap;

	int i;

	overlap = 1.0;
	for (i = 0; i < fconfig.dim; i++) {

		/* 6 possible cases */

		if (node2->a[i] > node1->b[i] || node1->a[i] > node2->b[i]) {

			overlap = 0.0;
			break;

		} else if (node2->a[i] <= node1->a[i]) {

			if (node2->b[i] <= node1->b[i]) {

				// a2, a1, b2, b1

				overlap = overlap * (node2->b[i] - node1->a[i]);

			} else {

				// a2, a1, b1, b2

				overlap = overlap * (node1->b[i] - node1->a[i]);

			}
		} else if (node1->a[i] < node2->a[i]) {

			if (node2->b[i] <= node1->b[i]) {

				// a1, a2, b2, b1

				overlap = overlap * (node2->b[i] - node2->a[i]);

			} else {

				// a1, a2, b1, b2

				overlap = overlap * (node1->b[i] - node2->a[i]);

			}

		}

		// *** Ray added
		overlap *= 100;

	}

	return (overlap);

}

/*
 function : double cal_overlap_sum(node_type *node, int index_skip,  node_type *parent_node)
 purpose  : to calculate the sum of the overlap between the node and all children nodes
 (except the index specified) of the parent node parent_node
 parameter: node_type *node        - the node to be calculated with the overlap
 int index_skip         - the index of the children to be skipped to calculate the overlap
 node_type *parent_node - the parent node with all children to be calculated with the overlap
 return   : double - the sum of the overlap between the node and all children nodes (except the
 index specified) of the parent node parent_node
 */
double cal_overlap_sum(node_type *node, int index_skip, node_type *parent_node, 
					   config_type fconfig) {
	double overlap;

	int i, stop;

	overlap = 0.0;
	// **** Ray changed
	//stop = M - parent_node->vacancy;
	stop = parent_node->snodeSize * fconfig.M - parent_node->vacancy;
	for (i = 0; i < stop; i++) {

		if (i == index_skip)
			continue;
		// ***** To be Changed
		if (i == 13) {
			//parent_node->ptr[i] = parent_node->ptr[i-1];
			//myprintf("Hello!\n");
		}
		overlap = overlap + cal_overlap(parent_node->ptr[i], node, fconfig);

	}

	return (overlap);

}

/*
 function : double Dist2(node_type *node1, node_type *node2)
 purpose  : to calculate the distance between the centers of two nodes
 parameter: node_type *node1 - the first node to be calculated with the distance
 node_type *node2 - the second node to be calculated with the distance
 return   : double - the distance between the centers of two nodes
 */
double Dist2(node_type *node1, node_type *node2, config_type fconfig) {
	double distance;
	float *point1, *point2;

	int i;

	point1 = (float *) malloc(sizeof(float) * fconfig.dim);
	point2 = (float *) malloc(sizeof(float) * fconfig.dim);

	for (i = 0; i < fconfig.dim; i++) {
		// *** Ray has type casting the following with float type
		point1[i] = (float) ((node1->b[i] - node1->a[i]) / 2.0);
		point2[i] = (float) ((node2->b[i] - node2->a[i]) / 2.0);
	}

	distance = 0.0;
	for (i = 0; i < fconfig.dim; i++) {
		distance = distance + pow((double) (point1[i] - point2[i]), 2.0);
	}

	return (pow(distance, 0.5));

}

/**************************/
/* End Utility procedures */
/**************************/

/*
 function : int least_overlap_enlarge(node_type *parent_node, node_type  *data_node)
 purpose  : to return the index of the children such that the overlap enlargement
 is minimum when the data_node is inserted to parent_node
 parameter: node_type *parent_node - the parent node in which the data node is inserted
 node_type *data_node   - the data node to be inserted to the parent node
 return   : int - the index of the best children of the parent node to be inserted
 */
int least_overlap_enlarge(node_type *parent_node, node_type *data_node, config_type fconfig) {
	double new_overlap_diff, old_overlap, new_overlap;
	double vol_at_index, new_vol, min_overlap_diff;
	int index;
	node_type *temp_node;

	int i, stop;

	tree_node_allocate(&temp_node, fconfig);

	// **** Ray changed
	//stop = M - parent_node->vacancy;
	stop = parent_node->snodeSize * fconfig.M - parent_node->vacancy;
	for (i = 0; i < stop; i++) {

		/* original overlap */

		old_overlap = cal_overlap_sum(parent_node->ptr[i], i, parent_node, fconfig);

		/* overlap after enlargement */

		cal_MBR_node_node(temp_node->a, temp_node->b, parent_node->ptr[i],
				data_node, fconfig);

		new_overlap = cal_overlap_sum(temp_node, i, parent_node, fconfig);

		/* check if index is needed to updated */
		new_overlap_diff = new_overlap - old_overlap;

		if (i == 0) {

			index = i;
			min_overlap_diff = new_overlap_diff;

		} else {
			if (new_overlap_diff < min_overlap_diff) {
				index = i;
				min_overlap_diff = new_overlap_diff;
			} else if (new_overlap_diff == min_overlap_diff) {

				vol_at_index = cal_vol(parent_node->ptr[index]->a,
						parent_node->ptr[index]->b, fconfig);
				new_vol = cal_vol(temp_node->a, temp_node->b, fconfig);
				if (new_vol < vol_at_index) {

					index = i;

				}
			}
		}

	} /* end i */

	tree_node_deallocate(temp_node);

	return (index);

}

/********************************************************/
/* least_area_enlarge():                                */
/* Select the node which will cause least bounding      */
/* box enlargement when insert an entry to it           */
/********************************************************/
/*
 function : int least_area_enlarge(node_type *parent_node, node_type *data_node)
 purpose  : to return the index of the children such that the area enlargement
 is minimum when the data_node is inserted to parent_node
 parameter: node_type *parent_node - the parent node in which the data node is inserted
 node_type *data_node   - the data node to be inserted to the parent node
 return   : int - the index of the best children of the parent node to be inserted
 */
int least_area_enlarge(node_type *parent_node, node_type *data_node, config_type fconfig) {
	double new_vol_diff, old_vol, new_vol;
	double vol_at_index, min_vol_diff;
	int index;
	float *temp_a, *temp_b;
	int i, stop;

	temp_a = (float *) malloc(sizeof(float) * fconfig.dim);
	temp_b = (float *) malloc(sizeof(float) * fconfig.dim);

	// *** Ray changed
	//stop = M - parent_node->vacancy;
	stop = parent_node->snodeSize * fconfig.M - parent_node->vacancy;
	if (parent_node->snodeSize > 1) {
		myprintf("snode Size : %d\n", parent_node->snodeSize);
	}
	if (stop > 13) {
		myprintf("  stop : %d\n", stop);
	}
	for (i = 0; i < stop; i++) {

		/* original volume */

		old_vol = cal_vol(parent_node->ptr[i]->a, parent_node->ptr[i]->b, fconfig);

		/* volume after enlargement */

		cal_MBR_node_node(temp_a, temp_b, parent_node->ptr[i], data_node, fconfig);

		new_vol = cal_vol(temp_a, temp_b, fconfig);

		/* check if index is needed to updated */
		new_vol_diff = new_vol - old_vol;

		if (i == 0) {

			index = i;
			min_vol_diff = new_vol_diff;
			vol_at_index = new_vol;

		} else {
			if (new_vol_diff < min_vol_diff) {
				index = i;
				min_vol_diff = new_vol_diff;
				vol_at_index = new_vol;
			} else if (new_vol_diff == min_vol_diff) {
				if (new_vol < vol_at_index) {
					index = i;
					vol_at_index = new_vol;
				}
			}
		}

	} /* end i */

	free(temp_a);
	free(temp_b);

	return (index);

}
/* least_enlarge */

/**********************************************************/
/* choose_leaf():                                         */
/* Select a leaf node in which to place a new index entry */
/* current_level is the level of the current_node	  */
/**********************************************************/
/*
 function : int choose_leaf(node_type **node_found, node_type *current_node, int
 current_level, node_type *data_node)
 purpose  : Select a leaf node in which to place a new index entry
 current_level is the level of the current_node
 parameter: node_type **node_found  - the node found
 node_type *current_node - the current node
 int current_level       - current level
 node_type *data_node    - the data node to be inserted
 return   : int - the index of the children for the best leaf node to place a new
 index entry
 */
int choose_leaf(node_type **node_found, node_type *current_node,
		int current_level, node_type *data_node, config_type fconfig) {

	int child_chosen, level_found;

	/*******/
	/* CL1 */
	/*******/

	/**********************************************************/
	/* Initialise: 			     		    */
	/* Set N to be the root node(already done in insert_node) */
	/**********************************************************/

	/*  It has been already done in insert()  */

	/*******/
	/* CL2 */
	/*******/

	/**************/
	/* Leaf check */
	/**************/

	if (current_node->attribute == ROOT && (current_node->ptr[0] == NULL
			|| current_node->ptr[0]->attribute == LEAF)) {

		/************************************************************
		 *node_found is the root of the tree because the root is
		 the only internal node of the tree at that time.
		 *************************************************************/

		return (current_level); // root is at level 0

	}
	/*
	 myprintf("currentLevel:%d\n", current_level);
	 if (current_node == NULL) myprintf("current_node is NULL!\n");
	 if (current_node->ptr[0] == NULL)
	 {myprintf(" ptr[0] is NULL!\n");

	 //myprintf(" NOde type : %d\n",
	 }
	 myprintf("   node size: %d\n", current_node->snodeSize);
	 */
	if (current_node->ptr[0]->attribute == LEAF) {
		*node_found = current_node;
		return (current_level);
	}

	/*******/
	/* CL3 */
	/*******/

	/******************/
	/* Choose subtree */
	/******************/

	if (current_node->ptr[0]->ptr[0]->attribute != LEAF) {

		child_chosen = least_area_enlarge(current_node, data_node, fconfig);

	} else {

		child_chosen = least_overlap_enlarge(current_node, data_node, fconfig);

	}

	/*******/
	/* CL4 */
	/*******/

	/***********************/
	/* Descend recursively */
	/***********************/

	current_node = current_node->ptr[child_chosen];
	level_found = choose_leaf(node_found, current_node, current_level + 1,
			data_node, fconfig);

	return (level_found);

} /* choose_leaf */

/*
 function : void adjust_MBR(node_type *node_inserted)
 purpose  : to adjust the MBR from the node inserted up to the root
 parameter: node_type *node_inserted - the node just inserted
 return   : none
 */
void adjust_MBR(node_type *node_inserted, config_type fconfig) {
	node_type *node = node_inserted;
	int i, flag;

	while (node->attribute != ROOT) {

		flag = FALSE;
		for (i = 0; i < fconfig.dim; i++) {
			if (node->parent->a[i] > node->a[i]) {
				node->parent->a[i] = node->a[i];
				flag = TRUE;
			}
			if (node->parent->b[i] < node->b[i]) {
				node->parent->b[i] = node->b[i];
				flag = TRUE;
			}
		}

		if (flag == FALSE)
			break;

		node = node->parent;

	}

	return;

} /* adjust_MBR */

/*
 function : void adjust_MBR_delete(node_type *node_inserted)
 purpose  : to adjust the MBR from the node just some entries are removed up to the root
 parameter: node_type *node_inserted - the nodes that some nodes have beem removed
 return   : none
 */
void adjust_MBR_delete(node_type *node_inserted, config_type fconfig) {
	node_type *node = node_inserted, *parent;
	int j, stop;

	while (node->attribute != ROOT) {

		parent = node->parent;
		//if (node == NULL)
		//{
		//	myprintf("---node is nULL!\n");
		//}
		//if (parent == NULL)
		//{
		//	myprintf("---parent is NULL!\n");
		//	myprintf("---restore\n");
		//	parent = node_inserted->parent;
		//}
		// **** Ray changed
		//stop = M - parent->vacancy;
		stop = parent->snodeSize * fconfig.M - parent->vacancy;

		for (j = 0; j < fconfig.dim; j++) {
			parent->a[j] = parent->ptr[0]->a[j];
			parent->b[j] = parent->ptr[0]->b[j];
		}
		//myprintf("stop %d\n", stop);
		for (j = 1; j < stop; j++) {
			cal_MBR_node_node(parent->a, parent->b, parent, parent->ptr[j], fconfig);
		}

		//myprintf("3\n");
		//   if (flag == FALSE) break;

		node = parent;

	}

	return;

} /* adjust_MBR_delete */

/*
 function : void swap(int *sorted_index, double *value, int i, int j)
 purpose  : to swap the two elements in both sorted index and value
 specified by the index i and index j
 parameter: int *sorted_index - the array with two elements to be swapped
 double *value     - the array with two elements to be swapped
 int i             - the index of swapping
 int j             - the index of swapping
 return   : none
 */
void swap(int *sorted_index, double *value, int i, int j) {
	int temp_index;
	double temp_value;

	temp_value = value[i];
	value[i] = value[j];
	value[j] = temp_value;

	temp_index = sorted_index[i];
	sorted_index[i] = sorted_index[j];
	sorted_index[j] = temp_index;

	return;

}

/*
 function : int partition(int *sorted_index, double *value, int start_index, int end_index)
 purpose  : to partition the sorted index and the value into two parts, which is used
 in quicksort
 parameter: int *sorted_index - the array of sorted index
 double *value     - the array of value
 int start_index   - the index of the beginning of the array to be partitioned
 int end_index     - the index of the end of the array to be partitioned
 return   : int - the index pointing to the partition index
 */
int partition(int *sorted_index, double *value, int start_index, int end_index) {
	double pivot_value;
	int i, j;

	pivot_value = value[start_index];

	i = start_index - 1;
	j = end_index + 1;

	while (1) {

		do {
			j = j - 1;

		} while (value[j] > pivot_value);

		do {
			i = i + 1;

		} while (value[i] < pivot_value);

		if (i < j)
			swap(sorted_index, value, i, j);
		else
			return (j);

	}

	// **** Ray have added the return value -1.
	return -1;

}

/* I think it is sorted in increasing order */
/*
 function : void quicksort(int *sorted_index, double *value, int start_index, int end_index)
 purpose  : to sort the array value starting from start_index to end_index with the output
 in the sorted_index
 parameter: int *sorted_index - the sorted index of the array value
 double *value     - the array value to be sorted
 int start_index   - the start index of the array to be sorted
 int end_index     - the end index of the array to be sorted
 return   : none
 */
void quicksort(int *sorted_index, double *value, int start_index, int end_index) {
	int pivot;

	if (start_index < end_index) {

		pivot = partition(sorted_index, value, start_index, end_index);

		quicksort(sorted_index, value, start_index, pivot);

		quicksort(sorted_index, value, pivot + 1, end_index);

	}

	return;

}

/*
 function : void sort_entries(int *sorted_index, node_type **overnode, int axis_sort, int noOfOver)
 purpose  : to sort the entries in the over node according to the axis chosen axis_sort
 parameter: int *sorted_index    - the array of sorted index
 node_type **overnode - the array of the over node
 int axis_sort        - the axis chosen
 int noOfOver         - the no. of over nodes
 return   : none
 */
// *** Ray changed
//void sort_entries(int *sorted_index, node_type **overnode, int axis_sort)
void sort_entries(int *sorted_index, node_type **overnode, int axis_sort,
		int noOfOver) {
	int i, start, end;
	double *value;

	// *** Ray changed
	//value = (double *)malloc(sizeof(double) * (M+1));
	value = (double *) malloc(sizeof(double) * noOfOver);

	// *** Ray changed
	//for (i=0; i<M+1; i++) {
	for (i = 0; i < noOfOver; i++) {
		sorted_index[i] = i;
		value[i] = (double) overnode[i]->a[axis_sort];
	}

	// *** Ray changed
	//quicksort(sorted_index, value, 0, M);
	quicksort(sorted_index, value, 0, noOfOver - 1);

	i = 0;
	// *** Ray changed
	//while (i<M) {
	while (i < noOfOver - 1) {

		if (value[i] == value[i + 1]) {

			start = i;

			// *** Ray changed
			//while (i < M && value[i] == value[i+1]) {
			while (i < noOfOver - 1 && value[i] == value[i + 1]) {

				value[i] = (double) overnode[sorted_index[i]]->b[axis_sort];
				i++;

			}

			value[i] = (double) overnode[sorted_index[i]]->b[axis_sort];
			end = i;

			if ((end - start) > 1) {
				quicksort(sorted_index, value, start, end);
			} else {
				if (value[end] < value[start]) {
					swap(sorted_index, value, start, end);
				}
			}
		}

		i++;

	}

	free(value);

	return;

}

/*
 function : int ChooseSplitAxis(node_type **overnode)
 purpose  : to choose the best split axis among the array of the nodes overnode
 parameter: node_type **overnode - the array of the over nodes to be chosen with the
 best split axis
 return   : int - the best split axis
 */
int ChooseSplitAxis(node_type **overnode, config_type fconfig) {
	int axis_chosen, *sorted_index;
	node_type *group1, *group2;
	double new_margin_value, min_margin_value;

	int i, j, k, l, stop, cut;
	// *** Ray added
	node_type *parentNode;
	int noOfOver;

	// *** Ray added
	if (overnode[0] == NULL)
		myprintf("  ~~~~~sad\n");
	parentNode = overnode[0]->parent;
	noOfOver = parentNode->snodeSize * fconfig.M + 1;

	// *** Ray changed
	//sorted_index = (int *)malloc(sizeof(int) * (M+1));
	sorted_index = (int *) malloc(sizeof(int) * noOfOver);
	tree_node_allocate(&group1, fconfig);
	tree_node_allocate(&group2, fconfig);

	for (i = 0; i < fconfig.dim; i++) {

		sort_entries(sorted_index, overnode, i, noOfOver); // sort the entries by axis i


		new_margin_value = 0.0;
		// *** Ray changed
		//stop = M - 2*m + 1;
		stop = fconfig.M * parentNode->snodeSize - 2 * fconfig.m + 1;
		for (k = 0; k < stop; k++) {

			for (l = 0; l < fconfig.dim; l++) {
				group1->a[l] = overnode[sorted_index[0]]->a[l];
				group1->b[l] = overnode[sorted_index[0]]->b[l];
				// *** Ray changed
				//group2->a[l] = overnode[sorted_index[M]]->a[l];
				//group2->b[l] = overnode[sorted_index[M]]->b[l];
				group2->a[l]
						= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[l];
				group2->b[l]
						= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[l];
			}

			j = 0;
			cut = fconfig.m + k;
			// *** Ray changed
			//while (j < M+1) {
			while (j < fconfig.M * parentNode->snodeSize + 1) {

				if (j < cut) {

					cal_MBR_node_node(group1->a, group1->b, group1,
							overnode[sorted_index[j]], fconfig);

				} else {

					cal_MBR_node_node(group2->a, group2->b, group2,
							overnode[sorted_index[j]], fconfig);

				}

				j++;

			}

			for (l = 0; l < fconfig.dim; l++) {

				new_margin_value = new_margin_value + group1->b[l]
						- group1->a[l];
				new_margin_value = new_margin_value + group2->b[l]
						- group2->a[l];

			}
		}

		if (i == 0) {

			axis_chosen = i;
			min_margin_value = new_margin_value;
		} else {

			if (new_margin_value < min_margin_value) {

				axis_chosen = i;
				min_margin_value = new_margin_value;
			}

		}
	}

	tree_node_deallocate(group1);
	tree_node_deallocate(group2);
	free(sorted_index);

	return (axis_chosen);

} /* ChooseSplitAxis */

/*
 function : void ChooseSplitIndex(node_type **overnode, int axis_chosen, node_type
 *group1_chosen, node_type *group2_chosen)
 purpose  : to choose the best split index among the over nodes given the chosen axis
 parameter: node_type **overnode     - the array of the over nodes
 int axis_chosen          - the axis to be split
 node_type *group1_chosen - the 1st group to be partitioned
 node_type *group2_chosen - the 2nd group to be partitioned
 return   : none
 */
void ChooseSplitIndex(node_type **overnode, int axis_chosen,
		node_type *group1_chosen, node_type *group2_chosen, config_type fconfig) {
	int split_index, *sorted_index;
	node_type *group1, *group2;
	double new_overlap_value, min_overlap_value;
	double vol_at_index, new_vol;

	int i, j, k, stop, cut;

	//FILE *fp;
	// *** Ray added
	node_type *parentNode;
	int noOfOver;

	// *** Ray added (to be changed)
	parentNode = overnode[0]->parent;
	noOfOver = parentNode->snodeSize * fconfig.M + 1;

	// **** Ray has changed
	//sorted_index = (int *)malloc(sizeof(int) * (M+1));
	sorted_index = (int *) malloc(sizeof(int) * noOfOver);

	// **** Ray changed
	tree_temp_node_allocate(&group1, parentNode->snodeSize, fconfig);
	tree_temp_node_allocate(&group2, parentNode->snodeSize, fconfig);

	sort_entries(sorted_index, overnode, axis_chosen, noOfOver); // sort the entries by the axis, axis_chosen


	new_overlap_value = 0.0;
	// *** Ray has changed
	//stop = M - 2*m + 1;
	stop = fconfig.M * parentNode->snodeSize - 2 * fconfig.m + 1;
	for (k = 0; k < stop; k++) {

		for (i = 0; i < fconfig.dim; i++) {
			group1->a[i] = overnode[sorted_index[0]]->a[i];
			group1->b[i] = overnode[sorted_index[0]]->b[i];
			// *** Ray changed
			//group2->a[i] = overnode[sorted_index[M]]->a[i];
			//group2->b[i] = overnode[sorted_index[M]]->b[i];
			group2->a[i]
					= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[i];
			group2->b[i]
					= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[i];
		}

		cut = fconfig.m + k;
		// *** Ray changed
		//for (j=0; j<M+1; j++) {
		for (j = 0; j < fconfig.M * parentNode->snodeSize + 1; j++) {

			if (j < cut) {

				cal_MBR_node_node(group1->a, group1->b, group1,
						overnode[sorted_index[j]], fconfig);

			} else {

				cal_MBR_node_node(group2->a, group2->b, group2,
						overnode[sorted_index[j]], fconfig);

			}

		}

		new_overlap_value = cal_overlap(group1, group2, fconfig);

		if (k == 0) {

			split_index = k;
			min_overlap_value = new_overlap_value;
			vol_at_index = cal_vol(group1->a, group1->b, fconfig) + cal_vol(group2->a,
					group2->b, fconfig);

		} else {

			if (new_overlap_value < min_overlap_value) {

				split_index = k;
				min_overlap_value = new_overlap_value;
				vol_at_index = cal_vol(group1->a, group1->b, fconfig) + cal_vol(
						group2->a, group2->b, fconfig);

			} else {

				new_vol = cal_vol(group1->a, group1->b,fconfig) + cal_vol(group2->a,
						group2->b, fconfig);
				if (new_vol < vol_at_index) {
					split_index = k;
				}

			}
		}

	}

	for (i = 0; i < fconfig.dim; i++) {
		group1_chosen->a[i] = overnode[sorted_index[0]]->a[i];
		group1_chosen->b[i] = overnode[sorted_index[0]]->b[i];
		// *** Ray changed
		//group2_chosen->a[i] = overnode[sorted_index[M]]->a[i];
		//group2_chosen->b[i] = overnode[sorted_index[M]]->b[i];
		group2_chosen->a[i]
				= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[i];
		group2_chosen->b[i]
				= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[i];
	}

	cut = fconfig.m + split_index;

	// *** Ray changed
	//for (j=0; j<M+1; j++) {
	for (j = 0; j < fconfig.M * parentNode->snodeSize + 1; j++) {

		if (j < cut) {

			group1_chosen->ptr[j] = overnode[sorted_index[j]];

			overnode[sorted_index[j]]->parent = group1_chosen;
			cal_MBR_node_node(group1_chosen->a, group1_chosen->b,
					group1_chosen, overnode[sorted_index[j]], fconfig);
		}

		else {

			group2_chosen->ptr[j - cut] = overnode[sorted_index[j]];
			overnode[sorted_index[j]]->parent = group2_chosen;
			cal_MBR_node_node(group2_chosen->a, group2_chosen->b,
					group2_chosen, overnode[sorted_index[j]], fconfig);
		}

	}

	// *** Ray changed
	//group1_chosen->vacancy = M - cut;
	//group2_chosen->vacancy = cut - 1;	// M - (M+1 - cut);
	if (cut % fconfig.M == 0) {
		group1_chosen->vacancy = 0;
		group2_chosen->vacancy = fconfig.M - 1;

		group1_chosen->snodeSize = cut / fconfig.M;
		group2_chosen->snodeSize = parentNode->snodeSize + 1
				- group1_chosen->snodeSize;
	} else {
		group1_chosen->vacancy = fconfig.M - cut % fconfig.M;
		group2_chosen->vacancy = cut % fconfig.M - 1; // M - (M+1 - cut);

		group1_chosen->snodeSize = cut / fconfig.M + 1;
		group2_chosen->snodeSize = parentNode->snodeSize + 1
				- group1_chosen->snodeSize;
	}

	tree_node_deallocate(group1);
	tree_node_deallocate(group2);
	free(sorted_index);

	return;

} /* ChooseSplitIndex() */

/*
 function : int minOverlapSplitAxis(node_type **overnode)
 purpose  : to return the best split axis according to the minimum overlap
 parameter: node_type **overnode - the array of the over nodes overnode
 return   : int - the index of the best split axix according to the minimum overlap
 */
// **** Ray added
// Min overlap split
int minOverlapSplitAxis(node_type **overnode, config_type fconfig) {
	int axis_chosen, *sorted_index;
	node_type *group1, *group2;
	// *** Ray changed
	//double new_margin_value, min_margin_value;
	double new_overlap_value, min_overlap_value;

	int i, j, k, l, stop, cut;
	// *** Ray added
	node_type *parentNode;
	int noOfOver;

	// *** Ray added
	parentNode = overnode[0]->parent;
	noOfOver = parentNode->snodeSize * fconfig.M + 1;

	// *** Ray changed
	//sorted_index = (int *)malloc(sizeof(int) * (M+1));
	sorted_index = (int *) malloc(sizeof(int) * noOfOver);
	tree_node_allocate(&group1, fconfig);
	tree_node_allocate(&group2, fconfig);

	for (i = 0; i < fconfig.dim; i++) {

		sort_entries(sorted_index, overnode, i, noOfOver); // sort the entries by axis i


		// *** Ray changed
		//new_margin_value = 0.0;
		new_overlap_value = 0.0;
		// *** Ray changed
		//stop = M - 2*m + 1;
		stop = fconfig.M * parentNode->snodeSize - 2 * fconfig.m + 1;
		for (k = 0; k < stop; k++) {

			for (l = 0; l < fconfig.dim; l++) {
				group1->a[l] = overnode[sorted_index[0]]->a[l];
				group1->b[l] = overnode[sorted_index[0]]->b[l];
				// *** Ray changed
				//group2->a[l] = overnode[sorted_index[M]]->a[l];
				//group2->b[l] = overnode[sorted_index[M]]->b[l];
				group2->a[l]
						= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[l];
				group2->b[l]
						= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[l];
			}

			j = 0;
			cut = fconfig.m + k;
			// *** Ray changed
			//while (j < M+1) {
			while (j < fconfig.M * parentNode->snodeSize + 1) {

				if (j < cut) {

					cal_MBR_node_node(group1->a, group1->b, group1,
							overnode[sorted_index[j]], fconfig);

				} else {

					cal_MBR_node_node(group2->a, group2->b, group2,
							overnode[sorted_index[j]], fconfig);

				}

				j++;

			}

			// *** Ray modified
			//for (l=0; l<dim; l++) {
			//
			//	new_margin_value = new_margin_value + group1->b[l] - group1->a[l];
			//	new_margin_value = new_margin_value + group2->b[l] - group2->a[l];
			//
			//}
			new_overlap_value = cal_overlap(group1, group2, fconfig);
		}

		if (i == 0) {

			axis_chosen = i;
			// *** Ray modified
			//min_margin_value = new_margin_value;
			min_overlap_value = new_overlap_value;
		} else {

			// *** Ray modified
			//if (new_margin_value < min_margin_value) {
			if (new_overlap_value < min_overlap_value) {

				axis_chosen = i;
				// *** Ray modified
				//min_margin_value = new_margin_value;
				min_overlap_value = new_overlap_value;
			}

		}
	}

	tree_node_deallocate(group1);
	tree_node_deallocate(group2);
	free(sorted_index);

	return (axis_chosen);

} /* minOverlapSplitAxis */

/*
 function : void minOverlapSplitIndex(node_type **overnode, int axis_chosen, node_type
 *group1_chosen, node_type *group2_chosen)
 purpose  : to choose the best split index of the axis chosen axis_chosen according to
 minimum overlap
 parameter: node_type **overnode     - the array of the overflow nodes
 int axis_chosen          - the index of the axis chosen
 node_type *group1_chosen - the first group to be split
 node_type *group2_chosen - the second group to be split
 return   : none
 */
// *** Ray added
// min overlap split
void minOverlapSplitIndex(node_type **overnode, int axis_chosen,
		node_type *group1_chosen, node_type *group2_chosen, config_type fconfig) {
	int split_index, *sorted_index;
	node_type *group1, *group2;
	double new_overlap_value, min_overlap_value;
	double vol_at_index;

	int i, j, k, stop, cut;

	//FILE *fp;
	// *** Ray added
	node_type *parentNode;
	int noOfOver;

	// *** Ray added (to be changed)
	parentNode = overnode[0]->parent;
	noOfOver = parentNode->snodeSize * fconfig.M + 1;

	// **** Ray has changed
	//sorted_index = (int *)malloc(sizeof(int) * (M+1));
	sorted_index = (int *) malloc(sizeof(int) * noOfOver);

	// *** Ray changed
	tree_temp_node_allocate(&group1, parentNode->snodeSize, fconfig);
	tree_temp_node_allocate(&group2, parentNode->snodeSize, fconfig);

	sort_entries(sorted_index, overnode, axis_chosen, noOfOver); // sort the entries by the axis, axis_chosen


	new_overlap_value = 0.0;
	// *** Ray has changed
	//stop = M - 2*m + 1;
	stop = fconfig.M * parentNode->snodeSize - 2 * fconfig.m + 1;
	for (k = 1; k < stop; k++) {

		for (i = 0; i < fconfig.dim; i++) {
			group1->a[i] = overnode[sorted_index[0]]->a[i];
			group1->b[i] = overnode[sorted_index[0]]->b[i];
			// *** Ray changed
			//group2->a[i] = overnode[sorted_index[M]]->a[i];
			//group2->b[i] = overnode[sorted_index[M]]->b[i];
			group2->a[i]
					= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[i];
			group2->b[i]
					= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[i];
		}

		// *** Ray changed
		//cut = m + k;
		cut = k;
		//for (j=0; j<M+1; j++) {
		for (j = 0; j < fconfig.M * parentNode->snodeSize + 1; j++) {

			if (j < cut) {

				cal_MBR_node_node(group1->a, group1->b, group1,
						overnode[sorted_index[j]], fconfig);

			} else {

				cal_MBR_node_node(group2->a, group2->b, group2,
						overnode[sorted_index[j]], fconfig);

			}

		}

		new_overlap_value = cal_overlap(group1, group2, fconfig);

		if (k == 1) {

			split_index = k;
			min_overlap_value = new_overlap_value;
			vol_at_index = cal_vol(group1->a, group1->b, fconfig) + cal_vol(group2->a,
					group2->b, fconfig);

		} else {

			if (new_overlap_value < min_overlap_value) {

				split_index = k;
				min_overlap_value = new_overlap_value;
				vol_at_index = cal_vol(group1->a, group1->b, fconfig) + cal_vol(
						group2->a, group2->b, fconfig);

			} else {

				// *** Ray modified
				//new_vol = cal_vol(group1->a, group1->b) + cal_vol(group2->a, group2->b);
				//if (new_vol < vol_at_index) {
				split_index = k;
				//}

			}
		}

	}

	for (i = 0; i < fconfig.dim; i++) {
		group1_chosen->a[i] = overnode[sorted_index[0]]->a[i];
		group1_chosen->b[i] = overnode[sorted_index[0]]->b[i];
		// *** Ray changed
		//group2_chosen->a[i] = overnode[sorted_index[M]]->a[i];
		//group2_chosen->b[i] = overnode[sorted_index[M]]->b[i];
		group2_chosen->a[i]
				= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->a[i];
		group2_chosen->b[i]
				= overnode[sorted_index[fconfig.M * parentNode->snodeSize]]->b[i];
	}

	// *** Ray changed
	//cut = m + split_index;
	cut = split_index;

	// *** Ray changed
	//for (j=0; j<M+1; j++) {
	for (j = 0; j < fconfig.M * parentNode->snodeSize + 1; j++) {

		if (j < cut) {

			group1_chosen->ptr[j] = overnode[sorted_index[j]];

			overnode[sorted_index[j]]->parent = group1_chosen;
			cal_MBR_node_node(group1_chosen->a, group1_chosen->b,
					group1_chosen, overnode[sorted_index[j]], fconfig);
		}

		else {

			group2_chosen->ptr[j - cut] = overnode[sorted_index[j]];
			overnode[sorted_index[j]]->parent = group2_chosen;
			cal_MBR_node_node(group2_chosen->a, group2_chosen->b,
					group2_chosen, overnode[sorted_index[j]], fconfig);
		}

	}

	// *** Ray changed
	//group1_chosen->vacancy = M - cut;
	//group2_chosen->vacancy = cut - 1;	// M - (M+1 - cut);
	if (cut % fconfig.M == 0) {
		group1_chosen->vacancy = 0;
		group2_chosen->vacancy = fconfig.M - 1;

		group1_chosen->snodeSize = cut / fconfig.M;
		group2_chosen->snodeSize = parentNode->snodeSize + 1
				- group1_chosen->snodeSize;
	} else {
		group1_chosen->vacancy = fconfig.M - cut % fconfig.M;
		group2_chosen->vacancy = cut % fconfig.M - 1; // M - (M+1 - cut);

		// *** Ray added
		group1_chosen->snodeSize = cut / fconfig.M + 1;
		group2_chosen->snodeSize = parentNode->snodeSize + 1
				- group1_chosen->snodeSize;
	}

	tree_node_deallocate(group1);
	tree_node_deallocate(group2);
	free(sorted_index);

	return;

} /* minOverlapSplitIndex() */

/*
 function : int split(node_type *splitting_node, node_type *extra_node, node_type *node1, node_type *node2)
 purpose  : to split the node splitting_node and the extra_node into two nodes (node1 and node2)
 parameter: node_type *splitting_node - the splitting node
 node_type *extra_node     - the extra node to be inserted
 node_type *node1          - the 1st splitted node
 node_type *node2          - the 2nd splitted node
 return   : int - TRUE or FALSe : to indicate that this split is good or not
 */
// *** Ray changed
int split(node_type *splitting_node, node_type *extra_node, node_type *node1,
		node_type *node2, config_type fconfig)
//void split(node_type *splitting_node, node_type *extra_node, node_type *node1, node_type *node2)
{
	node_type **overnode;
	int axis_chosen;

	int i;

	// *** Ray added
	node_type *parentNode;
	int noOfOver;

	// *** Ray added
	parentNode = splitting_node;
	noOfOver = parentNode->snodeSize * fconfig.M + 1;

	// **** Ray changed
	//overnode = (node_type **)malloc((M+1) * sizeof(node_type *));
	overnode = (node_type **) malloc(noOfOver * sizeof(node_type *));
	// *** Ray changed
	//for (i=0; i<M; i++) {
	for (i = 0; i < noOfOver - 1; i++) {
		overnode[i] = splitting_node->ptr[i];
		if (overnode[i] == NULL)
			myprintf(" ^^^^^^^^^^^^^ overnode %d is NULL\n", i);
	}
	if (overnode[0] == NULL)
		myprintf(" ^^^^^^^^^^^^^@overnode 0 is NULL\n");
	// *** Ray changed
	//overnode[M] = extra_node;
	overnode[noOfOver - 1] = extra_node;

	if (overnode[0] == NULL) {
		myprintf("  !!!!!! sad0\n");
	}

	// *** Ray changed
	//for(i=0; i < M; i++) {
	for (i = 0; i < noOfOver - 1; i++) {
		node1->ptr[i] = NULL;
		node2->ptr[i] = NULL;
	}

	// Topological split (in R*-tree)
	if (overnode[0] == NULL) {
		myprintf("  !!!!!! sad4\n");
	}
	axis_chosen = ChooseSplitAxis(overnode, fconfig);

	ChooseSplitIndex(overnode, axis_chosen, node1, node2, fconfig);

	node1->attribute = NODE;
	node1->parent = splitting_node->parent;
	node1->id = NO_ID;

	node2->attribute = NODE;
	node2->parent = splitting_node->parent;
	node2->id = NO_ID;


	if (cal_overlap(node1, node2, fconfig) > pow(5, fconfig.dim)) {
		//#ifdef RAYMOND
		// *** Min-overlap split

		// *** IMPORTANT
		overnode[0]->parent = parentNode;

		axis_chosen = minOverlapSplitAxis(overnode, fconfig);

		minOverlapSplitIndex(overnode, axis_chosen, node1, node2, fconfig);

		node1->attribute = NODE;
		node1->parent = splitting_node->parent;
		node1->id = NO_ID;

		node2->attribute = NODE;
		node2->parent = splitting_node->parent;
		node2->id = NO_ID;

		//free(overnode);
		//if ((M*parentNode->snodeSize - node1->vacancy < MIN_FANOUT) || (M*parentNode->snodeSize - node2->vacancy < MIN_FANOUT))
		//if ((parentNode->snodeSize <= MAX_X_SNODE) && ((node1->vacancy < 0) || (node1->vacancy > M) || (node2->vacancy < 0) || (node1->vacancy > M)))
		//{
		//	myprintf("@@@@@@@@@@@@@@@@@@ Vancancy is incorrect!\n");
		//}
		if ((parentNode->snodeSize <= MAX_X_SNODE) 
			&& ((fconfig.M - node1->vacancy	< fconfig.m) // MIN_FANOUT
				|| (fconfig.M - node2->vacancy < fconfig.m))) {
			//myprintf("*******\n");

			return FALSE;

		}
		//#endif
	}

	free(overnode);

	// *** Ray changed
	//return;
	return TRUE;

} /* split() */

/*
 function : void adjust_tree(node_type *splitting_node, int over_level, int old_level, node_type
 *node1, node_type *node2, node_type *root)
 purpose  : to adjust the MBR of the trees from the splitting node at the node level over_level
 from two splitted nodes (node1 and node2) up to the root
 parameter: node_type *splitting_node - the splitting node
 int over_level            - the overnode level
 int old_level             - the last level of the overnode level
 node_type *node1          - the first splitted node
 node_type *node2          - the second splitted node
 node_type *root           - the root node
 return   : none
 */
// *** Ray has added the void return type of the function
void adjust_tree(node_type *splitting_node, int over_level, int old_level,
		node_type *node1, node_type *node2, node_type *root, config_type fconfig) {
	int split_child_no = 0;
	node_type *split_parent;

	int i, j;

	if (splitting_node->attribute == ROOT) {

		/* The splitting node is the root */

		node1->parent = root;
		node2->parent = root;
		root->ptr[0] = node1;
		root->ptr[1] = node2;
		if (node1 == NULL)
			myprintf("  ~~~~~~~~~ adjust_tree1\n");
		if (node2 == NULL)
			myprintf("  ~~~~~~~~~ adjust_tree2\n");
		for (j = 2; j < fconfig.M; j++)
			root->ptr[j] = NULL;
		root->parent = NULL;
		root->vacancy = fconfig.M - 2;
		root->attribute = ROOT;

		// *** Ray added
		root->snodeSize = 1;

		cal_MBR_node_node(root->a, root->b, node1, node2, fconfig);

		extra_level++;
	} else {

		/* The splitted is an intermediate node */

		split_parent = splitting_node->parent;

		// **** Ray changed
		//for(i=0; i < M; i++) {
		for (i = 0; i < fconfig.M * split_parent->snodeSize; i++) {
			if (split_parent->ptr[i] == splitting_node) {
				split_child_no = i;
				break;
			}
		}
		// **** cwwong
		//	tree_node_deallocate(splitting_node);

		/* insert first node */
		split_parent->ptr[split_child_no] = node1;
		node1->parent = split_parent;

		adjust_MBR_delete(node1, fconfig);

		/* insert second node */

		if (split_parent->vacancy != 0) {

			/* no need to split again */
			// **** Ray changed
			//split_parent->ptr[M - split_parent->vacancy] = node2;
			split_parent->ptr[fconfig.M * split_parent->snodeSize
					- split_parent->vacancy] = node2;

			node2->parent = split_parent;
			split_parent->vacancy--;

			//	cal_MBR_node_node(split_parent->a, split_parent->b, node1, split_parent);
			cal_MBR_node_node(split_parent->a, split_parent->b, node2,
					split_parent, fconfig);

			adjust_MBR(split_parent, fconfig);

		} else {

			/* need to split again */
			overflow(split_parent, over_level - 1, old_level, node2, root, fconfig);

		}

	}

	return;

} /* adjust_tree */

/*
 function : void choose_leaf_level(node_type **node_found, node_type *current_node, int
 current_level, node_type *inserted_node, int desired_level)
 purpose  : to choose the leaf node specified by the leaf level
 parameter: node_type **node_found  - the node to be found as a a leaf node
 node_type *current_node - the current node with its children to be found
 with the best leaf
 int current_level       - the level of the current node current_node
 node_type *insert_node  - the node to be inserted
 int desired_level       - the desired level up to be checked
 return   : none
 */
void choose_leaf_level(node_type **node_found, node_type *current_node,
		int current_level, node_type *inserted_node, int desired_level, config_type fconfig) {

	int child_chosen;

	if (current_level == desired_level) {
		*node_found = current_node;
		//myprintf("7\n");

		return;
	}

	//myprintf("current_level %d desired_level %d\n", current_level, desired_level);

	//myprintf("current_node->ptr[0]->ptr[0] %d\n", current_node->ptr[0]->ptr[0]);
	if (current_node->ptr[0]->ptr[0]->attribute != LEAF) {

		//myprintf("8\n");
		child_chosen = least_area_enlarge(current_node, inserted_node, fconfig);

	} else {

		//myprintf("9\n");
		child_chosen = least_overlap_enlarge(current_node, inserted_node, fconfig);

	}

	//myprintf("5\n");

	current_node = current_node->ptr[child_chosen];
	//myprintf("current_level %d desired_level %d\n", current_level, desired_level);
	choose_leaf_level(node_found, current_node, current_level + 1,
			inserted_node, desired_level, fconfig);

	return;

} /* choose_leaf_level */

/*
 function : void reinsert(node_type *over_node, int over_level, node_type *extra_node,
 node_type *root)
 purpose  : to reinsert the extra node extra_node into the over node over_node at the level
 over_level given with the root node root
 parameter: node_type *over_node  - the node to be overflown
 int over_level        - the level of the over node
 node_type *extra_node - the extra node to be inserted
 node_type *root       - the root node
 return   : none
 */
void reinsert(node_type *over_node, int over_level, node_type *extra_node,
		node_type *root, config_type fconfig) {
	node_type *node_found;
	node_type **overnode;
	double *value;
	int *sorted_index;

	int i, start, stop;

	// **** Ray has fixed the following bugs
	// **** from "sizeof(double) * M+1" to "sizeof(double) * (M+1)"
	// **** from "sizeof(int) * M+1" to "sizeof(int) * (M+1)"
	value = (double *) malloc(sizeof(double) * (fconfig.M + 1));
	sorted_index = (int *) malloc(sizeof(int) * (fconfig.M + 1));

	overnode = (node_type **) malloc((fconfig.M + 1) * sizeof(node_type *));
	for (i = 0; i < fconfig.M; i++) {
		overnode[i] = over_node->ptr[i];
	}

	overnode[fconfig.M] = extra_node;
	overnode[fconfig.M]->parent = over_node;

	for (i = 0; i < fconfig.M + 1; i++) {
		value[i] = Dist2(overnode[i], over_node, fconfig);
		sorted_index[i] = i;
	}

	quicksort(sorted_index, value, 0, fconfig.M);

	for (i = 0; i < fconfig.dim; i++) {
		over_node->a[i] = overnode[sorted_index[0]]->a[i];
		over_node->b[i] = overnode[sorted_index[0]]->b[i];
	}
	over_node->ptr[0] = overnode[sorted_index[0]];

	//myprintf("1\n");

	stop = fconfig.M + 1 - fconfig.reinsert_p;

	for (i = 1; i < stop; i++) {
		over_node->ptr[i] = overnode[sorted_index[i]];
		cal_MBR_node_node(over_node->a, over_node->b, over_node,
				overnode[sorted_index[i]], fconfig);
	}
	for (i = stop; i < fconfig.M ; i++)
		over_node->ptr[i] = NULL;

	over_node->vacancy = fconfig.reinsert_p - 1;

	adjust_MBR_delete(over_node, fconfig);

	start = fconfig.M + 1 - fconfig.reinsert_p;

	for (i = start; i < fconfig.M + 1; i++) {

		node_found = root;

		choose_leaf_level(&node_found, root, 0, overnode[sorted_index[i]],
				over_level + extra_level, fconfig);
		//myprintf("2\n");

		/* Test whether the node has room or not */
		if (node_found->vacancy != 0) {

			/* have room to insert the entry */
			//myprintf("3\n");

			overnode[sorted_index[i]]->parent = node_found;

			node_found->ptr[fconfig.M - node_found->vacancy]
					= overnode[sorted_index[i]];

			node_found->vacancy--;

			adjust_MBR(overnode[sorted_index[i]], fconfig);
			//myprintf("4\n");
		} else {

			overflow(node_found, over_level, over_level,
					overnode[sorted_index[i]], root, fconfig);

		}

	}

	return;

} /* reinsert */

/*
 function : void adjust_tree_X(node_type *over_node, node_type *extra_node, node_type *root)
 purpose  : to adjust the tree where the additional super node is created in the over_node
 parameter: node_type *over_node  - the over node
 node_type *extra_node - the extra node to be added
 node_type *root       - the root node
 return   : none
 */
// *** Ray added this function
//create the supernode on the X-tree
void adjust_tree_X(node_type *over_node, node_type *extra_node, node_type *root, config_type fconfig) {
	node_type *parentNode;
	node_type **temp;

	int i;

	if (over_node->attribute == ROOT) {
		temp = root->ptr;

		// Increment the snode Size
		root->snodeSize++;

		// Assign the children
		root->ptr = (node_type **) malloc(sizeof(node_type *) * root->snodeSize
				* fconfig.M);

		for (i = 0; i < (root->snodeSize - 1) * fconfig.M; i++) {
			temp[i]->parent = root;
			root->ptr[i] = temp[i];
			if (root->ptr[i] == NULL)
				myprintf("  ########## adjust_tree_X1:%d\n", i);
		}
		root->ptr[(root->snodeSize - 1) * fconfig.M] = extra_node;

		//parent of extra node
		extra_node->parent = root;

		//attriubet of extra node
		//extra_node->attribute = NODE;

		// update the vacnacy
		root->vacancy = fconfig.M - 1;

		// update the MBR
		cal_MBR_node_node(root->a, root->b, root, extra_node, fconfig);
		adjust_MBR(root, fconfig);
	} else {
		// the super node is at the intermediate node

		parentNode = over_node->parent;

		temp = over_node->ptr;

		// Increment the snode Size
		over_node->snodeSize++;

		// Asign the children
		over_node->ptr = (node_type **) malloc(sizeof(node_type *)
				* over_node->snodeSize * fconfig.M);

		for (i = 0; i < (over_node->snodeSize - 1) * fconfig.M; i++) {
			temp[i]->parent = over_node;
			over_node->ptr[i] = temp[i];
		}
		over_node->ptr[(over_node->snodeSize - 1) * fconfig.M] = extra_node;
		//myprintf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
		//parent of extra node
		extra_node->parent = over_node;

		//attribute of the extra node
		//extra_node->attribute = NODE;

		// update the vacancy
		over_node->vacancy = fconfig.M - 1;

		// update the MBR
		cal_MBR_node_node(over_node->a, over_node->b, over_node, extra_node, fconfig);
		adjust_MBR(over_node, fconfig);
	}

	//myprintf("*****\n");
	/*
	 parentNode = over_node->parent;

	 temp = over_node->ptr;

	 // Increment the snode size
	 over_node->snodeSize++;

	 // Assign the children
	 over_node->ptr = (node_type **) malloc(sizeof(node_type *)*over_node->snodeSize*M);

	 for (i = 0; i < (over_node->snodeSize-1)*M; i++)
	 {
	 temp[i]->parent = over_node;
	 over_node->ptr[i] = temp[i];
	 }
	 over_node->ptr[(over_node->snodeSize-1)*M] = extra_node;

	 //parent of extra node
	 extra_node->parent = over_node;

	 // update the vacancy
	 over_node->vacancy = M-1;

	 // update the MBR
	 cal_MBR_node_node(over_node->a, over_node->b, over_node, extra_node);
	 adjust_MBR(over_node);
	 */
}

/*
 function : void overflow(node_type *over_node, int over_level, int old_level, node_type
 *extra_node, node_type *root)
 purpose  : to handle the situation of the overflow node over_node with the over node level
 over_level and the old over node level when the extra node extra_node is added
 parameter: node_type *over_node  - the overflow node
 int over_level        - the level of the overflow node
 node_type *extra_node - the extra node to be added into the overflow node
 node_type *root       - the root node
 return   : none
 */
void overflow(node_type *over_node, int over_level, int old_level,
		node_type *extra_node, node_type *root, config_type fconfig) {
	node_type *node1, *node2;

	// *** Ray modified
	/*  if (over_level < old_level && over_level != 0) {
	 reinsert(over_node, over_level, extra_node, root);

	 }
	 else {

	 tree_node_allocate(&node1);
	 tree_node_allocate(&node2);

	 split(over_node, extra_node, node1, node2);

	 adjust_tree(over_node, over_level, old_level, node1, node2, root);

	 //myprintf("overflow, go out adjust, extra_node->id %d\n", extra_node->id);


	 }
	 */

	// *** Ray changed
	tree_temp_node_allocate(&node1, over_node->snodeSize, fconfig);
	tree_temp_node_allocate(&node2, over_node->snodeSize, fconfig);

	if (split(over_node, extra_node, node1, node2, fconfig) == TRUE) {

		adjust_tree(over_node, over_level, old_level, node1, node2, root, fconfig);
	} else {
		//create supernode
		adjust_tree_X(over_node, extra_node, root, fconfig);
	}

	return;

}



/*
 function : int make_data(char *positionfile, float ***data)
 purpose  : to read the file name positionfile and put the data which has
 been read into the variable data
 parameter: char *positionfile - the name of the file
 float ***data      - the array of data to be put
 return   : int - no. of data
 */
int make_data(char *positionfile, float ***data, config_type fconfig) {
	int no_data;
	int i, j;
	FILE *fp_position;
	myprintf("%s\n", positionfile);
	fp_position = fopen(positionfile, "r");

	no_data = fconfig.no_histogram;

	(*data) = (float **) malloc(sizeof(float*) * no_data);
	for (i = 0; i < no_data; i++)
		(*data)[i] = (float *) malloc(sizeof(float) * fconfig.dim);

	for (i = 0; i < no_data; i++)
		for (j = 0; j < fconfig.dim; j++)
			fscanf(fp_position, "%f", &((*data)[i][j]));

	fclose(fp_position);

	return (no_data);

} /* make_data */

