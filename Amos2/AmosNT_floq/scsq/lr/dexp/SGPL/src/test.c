/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Javad, Sobhan, UDBL
 * $RCSfile: test.c,v $
 * $Revision: 1.6 $ $Date: 2012/10/16 13:19:22 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Test and example on how to run SGPL.
 * ===========================================================================
 * $Log: test.c,v $
 * Revision 1.6  2012/10/16 13:19:22  sobso953
 * Mutex-free communication introduced
 *
 * Revision 1.5  2012/10/16 11:25:53  jaba9649
 * debugging
 *
 * Revision 1.4  2012/10/11 14:21:03  jaba9649
 * Debugging...
 *
 * Revision 1.3  2012/10/10 16:29:39  jaba9649
 * Added Debug mode,
 * change map function so it gets the number of work threads as argument,
 * setup simple test,
 * setup scalable test.
 *
 * Revision 1.2  2012/10/10 09:58:05  jaba9649
 * *** empty log message ***
 *
 * Revision 1.1  2012/10/10 09:19:30  jaba9649
 * SGPL, Scalable Generic Parallel Library
 *
 *
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <math.h>
#include "SGPL.h"
#include "../../q/src/q.h"

#define NUM_WORKER 100
//#define DEBUG   //enable for debugging
//#define DEBUG_DETAIL //enable for debugging with more detail about the number of elements sent and received

//input structure
typedef struct {
	int key;
	int val;
} in_row;


int out_array[NUM_WORKER];

// populate the input with the specified size
void populate_input_array(int size, in_row* in_array) {
	int i;

	for (i = 0; i < size; i++) {
		in_array[i].key = i;
		in_array[i].val = 1;
	}
	return;
}

/* the worker thread for the integrated test
 *
 */
void* integrity_worker_thread(void * args) {

	queue* fifo;

	volatile void* element;
	int sum = 0;
	int worker_id;
	//extract the queue and thread id from the arguments
	fifo = ((SGPL_worker_args*) args)->fifo;
	worker_id = ((SGPL_worker_args*) args)->id;

	//the worker arguments have to be extracted later.
#ifdef DEBUG
	printf("in worker_thread: worker thread %d started...\n", worker_id);
#endif
	while (1) {
		while(fifo->produceCount - fifo->consumeCount == 0){
#ifdef DEBUG_DETAIL
			printf ("consumer: queue EMPTY.\n");
#endif
		}
		//read next element from queue
		queueDel(fifo, &element);
#ifdef DEBUG_DETAIL
		printf ("worker thread [%d]: received queue element.\n",worker_id);
#endif
		fifo->consumeCount += 1;

		//do the process on queue elements
		if (element != NULL) {
			sum += ((in_row*) element)->val;
		} else
			break;
	}

	out_array[worker_id] = sum;
#ifdef DEBUG
	printf("in worker_thread: worker thread id %d with sum = %d...DONE!\n",
			worker_id, out_array[worker_id]);
#endif

	pthread_exit(NULL);
	return NULL;
}

/*
 * worker thread for scale test.
 */
void* scale_worker_thread(void * args) {

	queue* fifo;
	volatile void* element;
	int res = 0;
	int worker_id;
	//extract the queue and thread id from the arguments
	fifo = ((SGPL_worker_args*) args)->fifo;
	worker_id = ((SGPL_worker_args*) args)->id;
	//extract the worker arguments later
#ifdef DEBUG_DETAIL
	printf("in worker_thread: worker thread %d started...\n", worker_id);
#endif
	while (1) {
		while(fifo->produceCount - fifo->consumeCount == 0) {
#ifdef DEBUG_DETAIL
			printf ("consumer: thread[%d]->queue EMPTY.\n",worker_id);
#endif
		}
		//read next element from queue
		queueDel(fifo, &element);
#ifdef DEBUG_DETAIL
		printf ("worker thread[%d]: received queue element\n",worker_id);
#endif
		fifo->consumeCount += 1;
		if (element != NULL) {
			int val = ((in_row*) element)->val + ((in_row*) element)->key;
			res +=  sin(val) + cos(val);
		} else {
#ifdef DEBUG
			printf("in worker_thread: worker thread id %d reached NULL result is = %d!\n",
					worker_id, res);
#endif
			break;
		}
	}


#ifdef DEBUG
	printf("in worker_thread: worker thread %d...DONE!\n", worker_id);
#endif

	pthread_exit(NULL);
	return NULL;
}

/*
 * Mapper function for distribution
 */
int worker_map(void * in_element, int num_worker) {

#ifdef DEBUG_DETAIL
	printf("in worker_map: pointer address = %ld\n",(long int)in_element);
#endif
	return (((in_row*) in_element)->key % num_worker);
}

/*
 * Integrity test, checks if the distribution of the thread are
 * done correctly. In case of success return 1 else return 0.
 */
int integrity_test(int test_size) {

	int i, error_flag, SGPL_result;
	SGPL_conf config;
	in_row* in_array;
	in_array = (in_row*) malloc(test_size * sizeof(in_row));
	config.element_size = sizeof(in_row);
	config.in_array = (void*) in_array;
	config.in_array_size = test_size;
	config.map_fn = worker_map;
	config.num_workers = NUM_WORKER;
	config.waa_size = 0;
	config.worker_arg_array = NULL;
	config.worker_fn = integrity_worker_thread;
	populate_input_array(test_size, in_array);
#ifdef DEBUG
	printf("in simple_test: start SPGL_run...\n");
#endif
	SGPL_result = SGPL_run(config);
#ifdef DEBUG
	printf("in simple_test: start processing data...\n");
#endif
	error_flag = 0;
	for (i = 0; i < NUM_WORKER; i++) {
#ifdef DEBUG
		printf("in simple_test: out_array[%d]=%d\n", i, out_array[i]);
#endif
		if (out_array[i] != test_size / NUM_WORKER) {
			error_flag = 1;
			break;
		}
	}
	if (!error_flag) {
		printf("OK!\n");
		free(in_array);
		return 1;
	} else {
		printf("Not OK!!\n");
		free(in_array);
		return 0;
	}

}

/*
 * Scale test, checks if the distribution scales.
 */
int scale_test(int num_worker, int test_size) {

	SGPL_conf config;
	long milliTime = 0;
	struct timeval t1, t2;
	in_row* in_array;
	in_array = (in_row*) malloc(test_size * sizeof(in_row));
	config.element_size = sizeof(in_row);
	config.in_array = (void*) in_array;
	config.in_array_size = test_size;
	config.map_fn = worker_map;
	config.num_workers = num_worker;
	config.waa_size = 0;
	config.worker_arg_array = NULL;
	config.worker_fn = scale_worker_thread;
	populate_input_array(test_size, in_array);
	gettimeofday(&t1, NULL);
	SGPL_run(config);
	gettimeofday(&t2, NULL);
	milliTime = ((t2.tv_sec * 1000000.0) + (t2.tv_usec)) - ((t1.tv_sec
			* 1000000.0) + (t1.tv_usec));
	printf("Number of threads:	%d	Total time:	%ld\n", num_worker, milliTime);
	printf("-------------------------------------------------------\n");
	free(in_array);
	return 1;
}

int main() {
	int i = 0;
	int scale_test_size = 1000000;
	int integrity_test_size = 10000;
	int integrity_ok = 1;
	//int num_thraeds;
	//num_thraeds=atoi(argv[1]);
	integrity_ok = integrity_test(integrity_test_size);
	if (integrity_ok) {
		for (i = 1; i <= 20; i++) {
			scale_test(i, scale_test_size);

		}
	}

	return EXIT_SUCCESS;
}
