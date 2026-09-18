/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Javad, Sobhan, UDBL
 * $RCSfile: SGPL.h,v $
 * $Revision: 1.2 $ $Date: 2012/10/10 16:28:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Header file for SGPL.c, includes q.h which is a queue Library 
 * implemented in UDBL.
 * ===========================================================================
 * $Log: SGPL.h,v $
 * Revision 1.2  2012/10/10 16:28:14  jaba9649
 * Added Debug mode,
 * change map function so it gets the number of work threads as argument
 *
 * Revision 1.1  2012/10/10 09:19:30  jaba9649
 * SGPL, Scalable Generic Parallel Library
 *
 *
 ****************************************************************************/

#ifndef SGPL_H_
#define SGPL_H_

#include "../../q/src/q.h"

//specifies to which worker an element, element_p, should be mapped.
typedef int (*SGPL_mapper) (void * element_p, int num_worker);

//worker signature, very generic as in pthread
typedef void* (*SGPL_worker) (void * args);

//configuration specification for the parallel system
typedef struct {
	void * in_array;//pointer to the input array
	long long in_array_size;//size of the input array;
	int element_size;//size of each element in in_array
	SGPL_mapper map_fn;//how to map elements to workers
	SGPL_worker worker_fn;//worker function
	void* worker_arg_array;// the array containing arguments to be paased to workers
	int waa_size;//size of each element in worker_arg_array
	int num_workers;//number of workers
} SGPL_conf;

//configuration specification for the parallel system
typedef struct {
	void* worker_args;// delivers the "application specific" worker arguments
	int id; // worker identifier
	queue* fifo; //the communication channel between distributer/worker
	//NOTE! Do not manipulate fifo!
} SGPL_worker_args;

//starts the the parallel system with specified configuration cnf.
int SGPL_run(SGPL_conf cnf);

#endif /* SGPL_H_ */
