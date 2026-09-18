/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Javad, Sobhan, UDBL
 * $RCSfile: q.h,v $
 * $Revision: 1.4 $ $Date: 2012/10/16 13:21:10 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Header for the queue as in q.c.
 * ===========================================================================
 * $Log: q.h,v $
 * Revision 1.4  2012/10/16 13:21:10  sobso953
 * Mutex-free communication introduced
 *
 * Revision 1.3  2012/10/16 11:26:35  jaba9649
 * Debugging
 *
 * Revision 1.2  2012/10/10 09:29:48  jaba9649
 * A dynamic queue with locks for passing tasks in a multi threaded
 *  environment
 *
 *
 ****************************************************************************/
#ifndef Q_H_
#define Q_H_
#define QUEUESIZE 100
#include <pthread.h>

typedef struct {
	volatile void* buf[QUEUESIZE];
	long head, tail;
	volatile int full;
	volatile int empty;
	volatile long long produceCount;
	volatile long long consumeCount;
	pthread_mutex_t *mut;
	pthread_cond_t *notFull, *notEmpty;
} queue;
queue *queueInit(void);
void queueDelete(queue *q);
void queueAdd(queue *q, void* in);
void queueDel(queue *q, volatile void** out);

#endif /* Q_H_ */
