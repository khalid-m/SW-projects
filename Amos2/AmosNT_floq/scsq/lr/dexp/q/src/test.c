/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Javad, Sobhan, UDBL
 * $RCSfile: test.c,v $
 * $Revision: 1.2 $ $Date: 2012/10/10 09:29:48 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Test and example on how to run queue.
 * ===========================================================================
 * $Log: test.c,v $
 * Revision 1.2  2012/10/10 09:29:48  jaba9649
 * A dynamic queue with locks for passing tasks in a multi threaded
 *  environment
 *
 *
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include "q.h"

#define LOOP 20

void *producer(void *args);
void *consumer(void *args);

int main() {
	queue *fifo;
	pthread_t pro, con;
	fifo = queueInit();
	if (fifo == NULL) {
		fprintf(stderr, "main: Queue Init failed.\n");
		exit(1);
	}

	pthread_create(&pro, NULL, producer, fifo);
	pthread_create(&con, NULL, consumer, fifo);
	pthread_join(pro, NULL);
	pthread_join(con, NULL);

	queueDelete(fifo);
	return 0;
}

void *producer(void *q) {
	queue *fifo;
	int i;
	fifo = (queue *) q;
	for (i = 0; i < LOOP; i++) {
		pthread_mutex_lock(fifo->mut);
		while (fifo->full) {
			printf("producer: queue FULL.\n");
			pthread_cond_wait(fifo->notFull, fifo->mut);
		}
		queueAdd(fifo, (void*) (long long)i);
		pthread_mutex_unlock(fifo->mut);
		pthread_cond_signal(fifo->notEmpty);
		usleep(100000);
	}
	for (i = 0; i < LOOP; i++) {
		pthread_mutex_lock(fifo->mut);
		while (fifo->full) {
			printf("producer: queue FULL.\n");
			pthread_cond_wait(fifo->notFull, fifo->mut);
		}
		queueAdd(fifo, (void*) (long long)i);
		pthread_mutex_unlock(fifo->mut);
		pthread_cond_signal(fifo->notEmpty);
		usleep(200000);
	}
	return (NULL);
}
void *consumer(void *q) {
	queue *fifo;
	int i;
	volatile void *d;
	fifo = (queue *) q;
	for (i = 0; i < LOOP; i++) {
		pthread_mutex_lock(fifo->mut);
		while (fifo->empty) {
			printf("consumer: queue EMPTY.\n");
			pthread_cond_wait(fifo->notEmpty, fifo->mut);
		}
		queueDel(fifo, &d);
		pthread_mutex_unlock(fifo->mut);
		pthread_cond_signal(fifo->notFull);
		printf("consumer: recieved %lld .\n", (long long)d);
		usleep(200000);
	}
	for (i = 0; i < LOOP; i++) {
		pthread_mutex_lock(fifo->mut);
		while (fifo->empty) {
			printf("consumer: queue EMPTY.\n");
			pthread_cond_wait(fifo->notEmpty, fifo->mut);
		}
		queueDel(fifo, &d);
		pthread_mutex_unlock(fifo->mut);
		pthread_cond_signal(fifo->notFull);
		printf("consumer: recieved %lld.\n", (long long)d);
		usleep(50000);
	}
	return (NULL);
}
