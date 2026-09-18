#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sqlite3.h>

#define Multiplier 1
#define Max64input 776886 
#define FILENAME "./data/outDexpSort.txt"
#define L 64
#define NUM_THREADS 10
#define QUEUESIZE 10

typedef struct
{
    unsigned short simTime;
    int vid;
    unsigned short xway;
    unsigned short day;
    int qid;
    volatile short flag;
    
}inRow;

typedef struct {
    volatile inRow* buf[QUEUESIZE];
    long head, tail;
    int full, empty;
    pthread_mutex_t *mut;
    pthread_cond_t *notFull, *notEmpty;
} queue;

typedef struct {
    queue* fifo;
    int id;
    char* fileString; 
} qdata;

queue *queueInit (void);
void queueDelete (queue *q);
void queueAdd (queue *q, inRow* in);
void queueDel (queue *q,volatile inRow* *out);

void readFile(inRow* inputs, char *inName);

void *workThread(void *q)
{
   //printf("Thread starting...\n");
   queue *fifo;
   qdata *queued;
   int i, retval, j;
   queued = (qdata *)q;
   printf("Thread %d starting...\n",queued->id);
   fifo=queued->fifo;
   volatile inRow* d;
   short flag =0;
   char * ErrMsg;
   char * sql;
   sqlite3_stmt *stmt;
   sqlite3 *handle;
   retval = sqlite3_open("Lr.db", &handle);
   if(retval)
   {
       printf("Database connection failed\n");
       exit(-1);
   }
   printf("Connection successful\n");
   sql = "SELECT toll from hist where vid = ? and xway = ? and day = ?";
   retval = sqlite3_prepare_v2(handle,sql,-1,&stmt,0);
   while (flag<1) {
	pthread_mutex_lock (fifo->mut);
	while (fifo->empty) {
	    //printf ("consumer: queue EMPTY.\n");
	    pthread_cond_wait (fifo->notEmpty, fifo->mut);
	}
	queueDel (fifo, &d);
	flag = ((inRow*)d)->flag;
	pthread_mutex_unlock (fifo->mut);
	pthread_cond_signal (fifo->notFull);
	//flag = ((inRow*)d)->flag;
	if(flag<1){
	    //printf ("consumer: recieved %d.\n", ((inRow*)d)->vid);
	    sqlite3_bind_int(stmt, 1,((inRow*)d)->vid);
	    sqlite3_bind_int(stmt, 2,((inRow*)d)->xway);
	    sqlite3_bind_int(stmt, 3,((inRow*)d)->day);
	    while(1)
	    {
		//printf("(#3,%d,%d,%d)\n",((inRow*)d)->simTime,((inRow*)d)->vid,((inRow*)d)->qid);
    		retval = sqlite3_step(stmt);
		if(retval == SQLITE_ROW)
    		{
                    int val = sqlite3_column_int(stmt,0);
        	    printf("(#3,%d,%d,%d,%d)\n",((inRow*)d)->simTime,((inRow*)d)->vid,((inRow*)d)->qid,val);

    		}
    		else if(retval == SQLITE_DONE)
    		{
        	    //printf("All rows fetched\n");
        	    break;
    		}
    		else
    		{
        	    printf("Some error encountered\n");
        	    //exit(-1);
    		}
	    }
	    sqlite3_reset(stmt);
	    sqlite3_clear_bindings(stmt);
	}
   }
   printf("Thread done. \n");
   //sqlite3_finalize(stmt);
   //sqlite3_close(handle);
   pthread_exit(NULL);
   //pthread_exit((void*) t);
}

void append(char* s, char c)
{
	int len = strlen(s);
	s[len] = c;
	s[len + 1] = '\0';
}
void *mainThread(void *pinputs)
{
 /*************************************************\
 * For Multi threading:                       	   *
 * TODO: Initialize and create working threads DONE*
 * TODO: Create Queue for each working thread      *
 * TODO: Split the input stream                    *
 * TODO: Multiply and create read Time Stamp       *
 * TODO: Write to each queue                       *
 \*************************************************/
   printf("In mainThread: initializing \n");
   inRow* inputs;
   inputs =  (inRow*)pinputs;
   int j;
   //queue *fifo[NUM_THREADS];
   qdata q[NUM_THREADS];
   int i;
   pthread_t thread[NUM_THREADS];
   pthread_attr_t attr;
   int rc;
   long t;
   pthread_attr_init(&attr);
   pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
   //create threads
   for(t=0; t<NUM_THREADS; t++) {
	printf("Main: creating thread %ld ...\n", t);
	//q[t] = (qdata *)malloc (sizeof (qdata));
     	q[t].fifo = queueInit ();
	if (q[t].fifo == NULL) {
     	    fprintf (stderr, "main: Queue Init failed.\n");
     	    exit (1);
	}
	q[t].id=t;
	q[t].fileString="Lr";
      	rc = pthread_create(&thread[t], &attr, workThread, (void *) &q[t]);
      	if(rc) {
	    printf("ERROR; return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
   }
   int queueNum = 0;
   //load input data into queues
   for(t=0; t<Max64input; t++){// for condition = inputs[t].flag != 0;
	queueNum = inputs[t].vid % NUM_THREADS;
	pthread_mutex_lock (q[queueNum].fifo->mut);
	while (q[queueNum].fifo->full) {
	    //printf ("producer: queue FULL.\n");
	    pthread_cond_wait (q[queueNum].fifo->notFull, q[queueNum].fifo->mut);
	}
	queueAdd (q[queueNum].fifo, &inputs[t]);
	//printf ("producer: sent %d in queue Number %d.\n",inputs[t].vid, queueNum);
	pthread_mutex_unlock (q[queueNum].fifo->mut);
	pthread_cond_signal (q[queueNum].fifo->notEmpty);
	   
   }
   // if we reached the final input send a flag to all queues
   if(inputs[t-1].flag==-1)
   {
        for(i=0; i<NUM_THREADS; i++) {
	    pthread_mutex_lock (q[i].fifo->mut);
	    while (q[i].fifo->full) {
		    //printf ("producer: queue FULL.\n");
		    pthread_cond_wait (q[i].fifo->notFull, q[i].fifo->mut);
	    }
	    queueAdd(q[i].fifo, &inputs[t]);
            //printf ("producer: sent flag %d to queue Number %d.\n",inputs[t].flag, i);
	    pthread_mutex_unlock (q[i].fifo->mut);
	    pthread_cond_signal (q[i].fifo->notEmpty);
        }
   }
   for (i=0; i<NUM_THREADS; i++) {
	pthread_join(thread[i], NULL);
   }
   pthread_attr_destroy(&attr);
   free(inputs);
   pthread_exit(NULL);
}

int main (int argc, char *argv[])
{  
   inRow* inputs = (inRow*) malloc((Max64input +1)* (sizeof (inRow)));
   readFile(inputs, FILENAME);
   pthread_t thread;
   int rc;
   printf("In main: creating thread \n");
   rc = pthread_create(&thread, NULL, mainThread, inputs);
   if (rc){
      printf("ERROR; return code from pthread_create() is %d\n", rc);
      exit(-1);
   }

   /* Last thing that main() should do */
   
   pthread_exit(NULL);
}

void readFile(inRow* inputs, char *inName){
    const char delimiters[] = " ,(,),#";
    FILE *in;
    char *token;
    char lineBuff[BUFSIZ];
    int i = 0;
    in = fopen(inName, "r");
    if (!in){
	printf("Couldn't open File\n");
    }
    printf("Reading from file %s ...\n",inName);
    int count;
    int countIn, countEnd;
    char *chk;
    int val;
    short sval;
    countIn = 0;
    while(fgets(lineBuff, sizeof(lineBuff), in)){
	count = 0;
	token=strtok(lineBuff,delimiters);
   	while(token != NULL){
            if (count == 1){
                sval = (short) strtol(token, &chk, 10);
                if (isspace(*chk) || *chk == 0)
                {
                    inputs[countIn].simTime= sval;
                    //printf("vid = %d ",val);
                }
            }
	    if (count == 2){
		val = (int) strtol(token, &chk, 10);
		if (isspace(*chk) || *chk == 0)
    		{
	    	    inputs[countIn].vid= val;
		    //printf("p = %d vid = %d",countIn,val);
		}
	    }
	    if (count == 4){
 	        sval = (short) strtol(token, &chk, 10);
	        if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].xway= sval;
		    //printf("p = %d xway = %d",countIn,sval);
    		}
	    }
	    if (count == 9){
    		val = (int) strtol(token, &chk, 10);
	        if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].qid= val;
		    //printf("p = %d qid = %d",countIn,val);
    		}
	    }
	    if (count == 14){
    		sval = (short) strtol(token, &chk, 10);
    		if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].day= sval;
		    //printf("p = %d day = %d",countIn,sval);
    		}
	    }
	    inputs[countIn].flag= 0;
	    count++;
	    token=strtok(NULL,delimiters);
	}
	//printf("vid = %s xway =  %s day = %s qid = %s\n", vid, xway, day, qid);
    countEnd = ++countIn;
    }
    inputs[countEnd -1].flag= -1;
    inputs[countEnd].vid = 0;
    inputs[countEnd].xway = 0;
    inputs[countEnd].qid = 0;
    inputs[countEnd].day = 0;
    inputs[countEnd].flag = 1;
    printf("Reading from file completed!\n");
    
}
queue *queueInit (void)
{
    queue *q;
    q = (queue *)malloc (sizeof (queue));
    if (q == NULL) return (NULL);
    q->empty = 1;
    q->full = 0;
    q->head = 0;
    q->tail = 0;
    q->mut = (pthread_mutex_t *) malloc (sizeof (pthread_mutex_t));
    pthread_mutex_init (q->mut, NULL);
    q->notFull = (pthread_cond_t *) malloc (sizeof (pthread_cond_t));
    pthread_cond_init (q->notFull, NULL);
    q->notEmpty = (pthread_cond_t *) malloc (sizeof (pthread_cond_t));
    pthread_cond_init (q->notEmpty, NULL);
    return (q);
}
void queueDelete (queue *q)
{
    pthread_mutex_destroy (q->mut);
    free (q->mut);
    pthread_cond_destroy (q->notFull);
    free (q->notFull);
    pthread_cond_destroy (q->notEmpty);
    free (q->notEmpty);
    free (q);
}
void queueAdd (queue *q, inRow* in)
{
    q->buf[q->tail] = in;
    q->tail++;
    if (q->tail == QUEUESIZE)
	q->tail = 0;
    if (q->tail == q->head)
	q->full = 1;
    q->empty = 0;
    return;
}
void queueDel (queue *q,volatile inRow* *out)
{
    *out = q->buf[q->head];
    q->head++;
    if (q->head == QUEUESIZE)
	q->head = 0;
    if (q->head == q->tail)
	q->empty = 1;
    q->full = 0;
    return;
}

