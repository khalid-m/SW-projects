/*****************************************************************************
 * Tasks
 *
 * Author: (c) 1995 Jonas S Karlsson, EDSLAB
 * Email: jonka@ida.liu.se, jsk@lysator.liu.se
 * $RCSfile: tasks.c,v $
 * $Revision: 1.1 $ $Date: 2006/05/31 07:07:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: C light weight thread package
 *
 *	By taking advantage of the C library primitives setjmp
 *	and longjmp a simple thread package has been implemented.
 *	The idea used and the usage is presented in the report
 *
 *		"Implementing C-Portable Light Weight Threads".
 *
 *	Hooks govern the exensibility without source code changes.
 *
 * Requirements: ansi-C, linearly growing C-stack, unsafe longjmp
 *
 * Limitations:
 *
 *	- There is a maximum number of possible threads (MAX_THREADS).
 *	- C stack is currently not reclaimed when a thread terminates.
 *	- Stack overrun is not checked with a failproof method.
 *	- The scheduler stinks (round-robin, scanning).
 *	- Priorities not implemented.
 *	- TaskSleep() & TaskTimeLeft() not implemented.
 *
 * ToDo:
 *
 *	- The next field when TaskRunnable/Running should point to the next.
 *	- Reclaim stack. (Keep a free list, and reuse with field start)
 *	- Abstract Queues of tasks. Are they allowed to be in multi Q:s?
 *
 * ===========================================================================
 *  1)	In Startthread, allocate some variables set them to a predefined
 *	vaule Check these variables before chaning to this task,
 *     	so noone has overwritten the stack. - DONE!
 *  2) 	Make a setjmp at each start of each process save it as a
 *	starting point. It can be used after the task has been finished
 *	to start a new task. Possible tasks near eachother could merge,
 *	and then do memory manangement. But it should be easy to reuse
 *	tasks of the same size...
 *  3)	At stack error raise a condition.
 *  4)	Test stack trashing (NOTOVERRUN) before entering the task!!!!!
 *  5)	TaskCreateSem()+TaskWait()+TaskSignal() works! TaskEntry->next added.
 * -----
 * $Log: tasks.c,v $
 * Revision 1.1  2006/05/31 07:07:05  torer
 * Portable lightweight thread package
 *
 */

#include "tasks.h"
#include <stdio.h>
#include <string.h>

#define	TaskSave(taskdata) setjmp(taskdata->state)
#define TaskRestore(taskdata) longjmp(taskdata->state, taskdata->tid)
#define TaskSetup(taskdata) longjmp(taskdata->state, TaskMagic)

static int _task_current_id = 0;
static int _task_highest = 0;
static int _task_count = 0;
static int _task_default = 0;

static Task _task_start_process = NULL;
static void* _task_start_env = NULL;
static int _task_start_stack = 0;

TaskChanger TaskSavePrelude = NULL;
TaskChanger TaskRestorePostlude = NULL;
TaskChanger TaskFreePrelude = NULL;
TaskChanger TaskInitPrelude = NULL;
TaskChanger TaskPrintPostlude = NULL;

static TaskEntry *_task_array[MAX_THREADS];

#define NOTOVERRUN "NOTOVERRUN"

void StartThread(void)
{
    TaskEntry *t;
    /* Is checked so that it has not been overwritten */
    /* char overrun[] = NOTOVERRUN; --- ansi init */
    char overrun[sizeof(NOTOVERRUN)+1];

    memcpy(&overrun[0], NOTOVERRUN, sizeof(NOTOVERRUN));
    t = TaskData(TaskCurrent());
    assert(t);
    t->overrun = overrun; /* Save address, check in TaskYield */
    INFO(printf("StartThread: Waiting for action!\n"));
    Yield();
    INFO(printf("StartThread: After first Yield\n"));
    while(!_task_start_process) Yield();
    INFO(printf("StartThread: Got an process to start!\n"));

    INFO(printf("overrun = %i, &over=%i\n", overrun, overrun));
    INFO(printf("StartThread: Current = %i, tid = %i, t->overrun = %i, ==%s\n",
		TaskCurrent(), t->tid, t->overrun, t->overrun));
    if (TaskSavePrelude) (*TaskSavePrelude)(t);
    switch (TaskSave(t)) {
    case TaskMagic: {
	int n = TaskNewID();
	/* TaskCreator */
	TaskAllocate(n,TaskCurrent(),-1);
	if (TaskInitPrelude) (*TaskInitPrelude)(TaskData(n));
 	TaskSetCurrent(n);
	EatStack(_task_start_stack); break; }
    case 0: { /* Jumps to case TaskMagic */
	TaskSetup(t); break; }
    default: { /* This is the only exit from the switch! */
	if (TaskRestorePostlude) (*TaskRestorePostlude)(t); break; }
    }

    assert(_task_start_process);
    {
	Task proc = _task_start_process;
	int ret;

        /*
         * Allow a new process, i.e. first after next Yield
         */
	_task_start_process = NULL;

	INFO(printf("StartThread: Starting the task procedure!\n"));
	TaskData(TaskCurrent())->stack = _task_start_stack;
	assert(proc);
	/*
	 * Start the task procedure
         */
	ret = (*proc)(_task_start_env);
	if (TaskStatus(TaskCurrent())==TaskRunning)
	    TaskSetStatus(TaskCurrent(), TaskExited);
	TaskData(TaskCurrent())->exitval = ret;

	/* What if it ever returns? */
	INFO(printf("StartThread: A procedure returned! should not!\n"));
	Die(0);
    }
}

void EatStack(int KB)
{
    char stack[1024];
    if (KB < 0) StartThread();
    EatStack(KB-1);
}

int Spawn(Task func, void *env, int stack)
{
    while(_task_start_process) Yield();  /* Wait for free */
    _task_start_process = func;
    _task_start_env = env;
    _task_start_stack = stack;
    Yield();   /*let it start */
    Yield();
    Yield();
    return 0;
}

/* ---<	Normals */
void    TaskInit(int mainstack, int defaultstack)
/* Create a stack of size mainstack for the main program/task.
 * Set the defaultstack size to be used for new tasks.
 * Creates the taskcreator.
 */
{
    TaskEntry *t;

    _task_default = defaultstack;
    assert(TaskCount()==0);
    t = TaskAllocate(0, 0, mainstack);
    if (TaskInitPrelude) (*TaskInitPrelude)(t);
    TaskSetStatus(0, TaskRunnable);
    if (TaskSavePrelude) (*TaskSavePrelude)(t);
    switch (TaskSave(t)) {
    case TaskMagic: {
        int n = TaskNewID();
        /* TaskCreator */
       INFO(printf("TaskInit: allocation task started!\n"));
        TaskAllocate(n, 0, -1);
        if (TaskInitPrelude) (*TaskInitPrelude)(TaskData(n));
        TaskSetCurrent(n);
        EatStack(mainstack);    break; }
    case 0: {
        INFO(printf("TaskInit: Setting up task!\n"));
        TaskSetup(t); break; }
    case 1: {
        if (TaskRestorePostlude) (*TaskRestorePostlude)(t); break; }
    }
    INFO(printf("TaskInit: Finished!\n"));
}

Tid	TaskCreate(Task t, void *env)
/* Gives the task and environment to the taskcreater */
{
    Tid id = _task_highest; /* Not when reusing */
    TaskCreateStack(t, env, 0);
    return id;
}

Tid	TaskCreateStack(Task t, void *env, int size)
{
    Tid id = _task_highest; /* Not when reusing */
    Spawn(t, env, size?size:_task_default);
    return id;
}

int	TaskExitVal(Tid t)
{
    return TaskData(t)->exitval;
    /* Maybe kill activation and stack after asked? (as unix-wait!) */
}

void	Yield(void)
/* Give up till next time */
{
    TaskYield(TaskNext());
}

void	Die(int exitnum)
{
    INFO(printf("%i Dies!\n", TaskCurrent()));
    if (TaskStatus(TaskCurrent())==TaskRunning)
	TaskSetStatus(TaskCurrent(), TaskDied);
    while(1) Yield(); /* Never return */
}

int	TaskP(Tid t)
{
    return (t>=0)&&(t<=_task_highest)&&(TaskData(t));
}

/* ---< Control */
int	TaskKill(Tid to)
{
    TaskSetStatus(to, TaskKilled);
    Yield(); /* good if we killed ourselves... */
    return 0;
}

void	TaskYield(Tid next)
/* Give up till next time */
{
    int current;
    int r;
    TaskEntry *c;
    TaskEntry *n;

    if (TaskStatus(next)!=TaskRunnable)
	return;
    INFO(printf("-->TaskYield\n"));
    INFO(TasksPrint());
    current = TaskCurrent();
    if (current == next)
	return;
    c = TaskData(current);
    n = TaskData(next);
    assert(c);
    assert(n);
    INFO(printf("Leaving %i for %i\n", current, next));
    INFO(printf("===Going to setjmp from %i\n", current));
    if (TaskSavePrelude) (*TaskSavePrelude)(c);
    TaskSetCurrent(next);
    if (r = (TaskSave(c))) {
	INFO(printf("Continuing %i (ret= %i)\n", TaskCurrent(), r));
	if (TaskRestorePostlude) (*TaskRestorePostlude)(TaskData(TaskCurrent()));
    } else {
	/*
	 * Save stack starting mark
	 */
	if (TaskStatus(current)==TaskNotSetup)
	    memcpy(TaskData(current)->start, TaskData(current)->state, sizeof(jmp_buf));
	INFO(printf("Resuming %i\n", next));
	INFO(printf("===Going to longjmp to %i\n", next));
	/*
	 * Not overrun stack check
	 */
	INFO(printf("TaskYield: Current = %i, next = %i, tid = %i, n->overrun = %i, ==%s\n",
		    TaskCurrent(), next, n->tid, n->overrun, n->overrun));
	if (next && (memcmp(n->overrun, NOTOVERRUN, sizeof(NOTOVERRUN))!=0)) {
	    /* Give some error information, possible raise a condition? */
	    fprintf(stderr, "Tasks: %i:s stack has been overrun by %i (probably)!\n",
		    next, current);
	    TasksPrint();
	    /*
	     * Do not call it again!
	     */
	    TaskSetStatus(next, TaskStackBogous);
	    /*
	     * Take next, and never return!
	     */
	    Yield();
 	}
	TaskRestore(n);
    }
    INFO(TasksPrint());
    INFO(printf("<--Yield\n"));
}

int	TaskCount(void)
{
    return _task_count;
}

/* ---< Internals */
TaskEntry *TaskAllocate(int tid, int fid, int stack)
/* Only allocates, does not insert in table - Yes it does! */
{
    TaskEntry *t = (void*)calloc(1, sizeof(TaskEntry));
    assert(t);
    t->tid = tid;
    t->fid = fid;
    t->stack = stack;
    t->exitval = -1;
    t->priority = 0;
    t->status = TaskNotSetup;
    t->userdata = NULL;
    _task_array[tid] = t;
    return t;
}

void	TaskFree(TaskEntry *t)
/* Only deallocates, does not remove from tables and lists - Yes it does!*/
{
    Tid id = t->tid;

    if (TaskFreePrelude) (*TaskFreePrelude)(t);
    free(t);
    _task_array[id] = NULL;
}

TaskEntry *TaskData(Tid t)
{
    return _task_array[t];
}

void	TaskSetCurrent(Tid t)
{
    if (TaskStatus(_task_current_id)==TaskRunning)
	TaskSetStatus(_task_current_id, TaskRunnable);
    _task_current_id = t;
    TaskSetStatus(t, TaskRunning);
}

Tid	TaskCurrent(void)
{
    return _task_current_id;
}

Tid	TaskNewID(void)
{
    _task_highest++;
    _task_count = _task_highest;
    return _task_highest;
}

int	TaskDeleteID(Tid t)
/* Currently do nothing */
{
    return 1;
}

TStatus	TaskStatus(Tid t)
{
    TaskEntry *e = TaskData(t);
    if (e)
	return TaskData(t)->status;
    else
	return TaskIllegal;
}

void	TaskSetStatus(Tid t, TStatus s)
{
    TaskEntry *e = TaskData(t);
    assert(e);
    e->status = s;
}

int	TaskTimeLeft(Tid t)
{
    return -1;
}

char	*StatusTaskString(int status)
{
    switch (status) {
    case TaskKilled: return "Killed";
    case TaskRunning: return "Running";
    case TaskRunnable: return "Runnable";
    case TaskSleeping: return "Sleeping";
    case TaskWaiting: return "Waiting";
    case TaskSignalling: return "Signalling";
    case TaskNotSetup: return "NotSetup";
    case TaskIllegal: return "Illegal";
    case TaskDied: return "Died";
    case TaskExited: return "Exited";
    case TaskStackBogous: return "StackBogous";
    default: return "Unknown";
    }
}

void	TaskPrint(Tid t)
{
    TaskEntry *e = NULL;
    if (t>=0) e = TaskData(t);
    if (e) {
	printf("%5i:%5i#%5i=%8i!%5i? %9s !"
	       ,e->tid,e->fid,e->stack,e->exitval,e->priority,StatusTaskString(e->status));
	if (TaskPrintPostlude) (*TaskPrintPostlude)(e);
	printf("\n");
    } else {
	printf("-ID--!-FID-!-stk-!--exit--!-pri-!---status--!");
	if (TaskPrintPostlude) (*TaskPrintPostlude)(NULL);
	printf("\n");
    }
}

void	TasksPrint(void)
{
    int i;
    TaskPrint(-1);
    for(i=0; i<=_task_highest; i++) {
	TaskPrint(i);
    }
}

/* ---< Synchronizers */
TSem	TaskCreateSem(int value)
{
    TSem t = (void*)calloc(1, sizeof(TSem_t));
    assert(t);
    t->waiters = NULL;
    t->lastwaiter = NULL;
    t->value = value;
    t->start = value;
    return t;
}

void	TaskSignal(TSem sem)
{
    assert(sem);
    if (sem->waiters) {
	/*
	 * Wake up somone
	 */
	TaskSetStatus(sem->waiters->tid, TaskRunnable);
	sem->waiters = sem->waiters->next;
	if (!(sem->waiters))
	    sem->lastwaiter = NULL;
	else {
	    if (!(sem->waiters->next))
		sem->lastwaiter = sem->waiters;
	}
    }
    sem->value++;
}

void	TaskWait(TSem sem)
{
    assert(sem);
    while (!(sem->value)) {
	TaskEntry *t = TaskData(TaskCurrent());
	/*
	 * Queue
	 */
	TaskSetStatus(TaskCurrent(), TaskWaiting);
	t->next = NULL;
	if (sem->lastwaiter)
	    sem->lastwaiter->next = t;
	else
	    sem->waiters = t;
	sem->lastwaiter = t;
	/*
	 * Wait to be awaken!
	 */
	Yield();
	/*
	 * Check if it is free
	 * (someone might have taken it!)
	 */
    }
    sem->value--;
}

int	TaskSemValue(TSem sem)
{
    assert(sem);
    return sem->value;
}

void	TaskSleep(int msec)
{
}


/* ---< Schedulers */
int	TaskPriority(Tid t)
{
    return 0;
}

int	TaskSetPriority(Tid t, int priority)
{
    return 0;
}

Tid	TaskNext(void)
{
    int n = _task_current_id;

    /*
     * Just return first Runnable
     */
    do {
	n = (n+1)%(_task_highest+1);
    } while (TaskStatus(n)!=TaskRunnable);
    INFO(printf("TaskNext=%i\n", n));
    return n;
}

void mytask(int i)
{
  while (1) {printf("hello world %d\n", i); Yield();}
}

int taskmain(int argc, char* argv[])
{       
        TaskInit(10, 10);
        printf("Back from taskinit\n");
        TaskCreate((Task)mytask,(void *)1);
        printf("Back from taskcreate 1\n");
        TaskCreate((Task)mytask,(void *)2);
        printf("Back from taskcreate 2\n");
        while(1){fgetc(stdin); Yield(); }
        return 0;
}

