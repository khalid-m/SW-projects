/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Javad, Sobhan, UDBL
 * $RCSfile: SGPL.c,v $
 * $Revision: 1.6 $ $Date: 2012/10/16 13:19:22 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Scalable Generic Pthread Library, distributes an incoming
 * stream to different number of worker threads based on an application
 * defined mapper function. The worker function is handled by application.
 * ===========================================================================
 * $Log: SGPL.c,v $
 * Revision 1.6  2012/10/16 13:19:22  sobso953
 * Mutex-free communication introduced
 *
 * Revision 1.5  2012/10/16 12:06:18  sobso953
 * removed unused variable
 *
 * Revision 1.4  2012/10/16 11:25:24  jaba9649
 * Debugging
 *
 * Revision 1.3  2012/10/11 14:21:03  jaba9649
 * Debugging...
 *
 * Revision 1.2  2012/10/10 16:27:30  jaba9649
 * Added Debug mode,
 * change map function so it gets the number of work threads as argument
 *
 * Revision 1.1  2012/10/10 09:19:29  jaba9649
 * SGPL, Scalable Generic Parallel Library
 *
 *
 ****************************************************************************/
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include "SGPL.h"
#include "../../q/src/q.h"

//#define DEBUG   // enable for debugging
//#define DEBUG_DETAIL //enable for debugging with more detail about the number of elements sent and received
void* SGPL_distribute(void * args) {

	//////////////// local configuration variables /////////////////////////
	void * in_array;//pointer to the input array
	long long in_array_size;//size of the input array;
	int element_size;//size of each element in in_array
	SGPL_mapper map_fn;//how to map elements to workers
	SGPL_worker worker_fn;//worker function
	void* worker_arg_array;// the array containing arguments to be paased to workers
	int waa_size;//size of each element in worker_arg_array
	int num_workers;//number of workers
	SGPL_conf* config;
	//////////////// END: local configuration variables ///////////////////////

	/////////////// local variables /////////////////////////
	int i;
	pthread_attr_t attr;
	pthread_t* worker_threads;
	int rc;
	long long j;
	int thread_num;

	//holds queue pointers as well as application specific arguments, as in worker_arg_array
	SGPL_worker_args* thread_args;

	//////////////// extracting configuration from args /////////////////////////
	config = (SGPL_conf*) args;

	in_array = config->in_array;
	in_array_size = config->in_array_size;
	element_size = config->element_size;
	map_fn = config->map_fn;
	worker_fn = config->worker_fn;
	worker_arg_array = config->worker_arg_array;
	waa_size = config->waa_size;
	num_workers = config->num_workers;
	//////////////// END: extracting configuration from args /////////////////////

	//////////////// creating worker threads /////////////////////
	worker_threads = (pthread_t*) malloc(num_workers * sizeof(pthread_t));
	thread_args = (SGPL_worker_args*) malloc(num_workers
			* sizeof(SGPL_worker_args));

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	for (i = 0; i < num_workers; i++) {
		//1.prepare worker arguments
		//1.1 initialize queue
		thread_args[i].fifo = queueInit();
#ifdef DEBUG
	printf("in SPGL_distribute: created queue with address %ld worker thread %d... \n",(long int)thread_args[i].fifo,i);
#endif
		thread_args[i].id = i;
		if (thread_args[i].fifo == NULL) {
			printf("queueInit failed\n");
			exit(1);
		}
		//1.2 copy application specific arguments
		if (worker_arg_array != NULL)
			thread_args[i].worker_args = worker_arg_array + i * waa_size;
		else
			thread_args[i].worker_args = NULL;
		//2. create worker threads
#ifdef DEBUG
	printf("in SPGL_distribute: creating worker thread %d... \n",i);
#endif
		rc = pthread_create(&worker_threads[i], &attr, worker_fn,
				&thread_args[i]);
		if (rc) {
			printf("failed to create worker thread\n");
			exit(2);
		}
	}
	//////////////// END:creating worker threads /////////////////////

	//start assigning tasks to worker threads by putting them in thread_args[i].fifo
#ifdef DEBUG
	printf("in SPGL_distribute: in_array = %ld in_array_size = %lld   and element size = %d \n",(long int)in_array, in_array_size, element_size);
#endif
	for (j = 0; j < in_array_size; j++) {
		//find out which thread this input should be sent to
		thread_num = (*map_fn)(in_array + (j * element_size), num_workers);
#ifdef DEBUG
	printf("in SPGL_distribute: thread_num =  %d... \n",thread_num);
#endif
		while (thread_args[thread_num].fifo->produceCount -
				thread_args[thread_num].fifo->consumeCount
				== QUEUESIZE){
#ifdef DEBUG_DETAIL
			printf ("producer: thread[%d]->queue FULL.\n",thread_num);
#endif
		}
		queueAdd(thread_args[thread_num].fifo, in_array + (j * element_size));
		thread_args[thread_num].fifo->produceCount += 1;
#ifdef DEBUG
		printf ("producer: sent queue element Number %lld to thread[%d].\n",j,thread_num);
#endif
	}

	//broadcast termination message to all worker threads
	//by sending NULL to worker queues
	for (i = 0; i < num_workers; i++) {
		while (thread_args[i].fifo->produceCount -
					thread_args[i].fifo->consumeCount
					== QUEUESIZE){
		}
		queueAdd(thread_args[i].fifo, NULL);
#ifdef DEBUG
		printf ("producer: sent queue NULL element to thread[%d].\n",i);
#endif
		thread_args[i].fifo->produceCount += 1;
	}

	//wait for all workers
	for (i = 0; i < num_workers; i++) {
		pthread_join(worker_threads[i], NULL);
		queueDelete(thread_args[i].fifo);
	}

	//release resources

	pthread_attr_destroy(&attr);
	free(thread_args);
	free(worker_threads);
	pthread_exit(NULL);
	return NULL;
}

int SGPL_run(SGPL_conf cnf) {

	// create the distributer thread and pass to it the configurations

	pthread_t distributer_thrd;
	pthread_attr_t attr_main;
	int rc;
#ifdef DEBUG
	printf("in SPGL_run: creating main thread...\n");
#endif
	pthread_attr_init(&attr_main);
	pthread_attr_setdetachstate(&attr_main, PTHREAD_CREATE_JOINABLE);
	rc = pthread_create(&distributer_thrd, &attr_main, SGPL_distribute, &cnf);
	pthread_join(distributer_thrd, NULL);
	pthread_attr_destroy(&attr_main);
#ifdef DEBUG
	printf("in SPGL_run: main thread exit.\n");
#endif
	/*
	 * as mentioned in pthread_exit() description:
	 * An implicit call to pthread_exit() is made when a thread other than the thread
	 * in which main() was first invoked returns from the start routine that was used
	 *  to create it. The function's return value serves as the thread's exit status.
	 *
	 *  in this case we don't need pthread_exit() here.
	 */
	//pthread_exit(NULL);
	return 1;
}

