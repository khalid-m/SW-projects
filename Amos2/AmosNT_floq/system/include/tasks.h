/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1995 Jonas S Karlsson, EDSLAB
 * $RCSfile: tasks.h,v $
 * $Revision: 1.1 $ $Date: 2006/05/31 10:06:49 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Portable C light weight thread package
 * ===========================================================================
 * $Log: tasks.h,v $
 * Revision 1.1  2006/05/31 10:06:49  torer
 * Moved to include directory
 *
 ****************************************************************************/

#include <stddef.h>
#include <setjmp.h>
#include <assert.h>
#include <signal.h>
#include <stdlib.h>

#define INFO(a) /* a */

#define MAX_THREADS 1000

/*
 * Tasks Statuses
 */

typedef int TStatus;

#define TaskKilled	0
#define TaskRunning	1
#define	TaskRunnable	2
#define	TaskSleeping	3
#define	TaskWaiting	4
#define	TaskSignalling	5
#define	TaskNotSetup	6
#define	TaskIllegal	7
#define	TaskDied	8
#define	TaskExited	9
#define	TaskStackBogous	10

/*
 * TaskEntry, total state information
 */

typedef int Tid;

typedef struct te {
    jmp_buf state;
    jmp_buf start;
    Tid tid;
    Tid	fid; /* father */
    int	stack;
    int	exitval;
    int priority;
    char *overrun;
    void *userdata;
    TStatus status;
    struct te *next;
} TaskEntry;

/*
 * Definition of a task function.
 * Should return the ExitValue.
 */

/*
typedef int (*Task)(void*);
*/
typedef int (*Task)(void*);

/*
 *  Tasking Hooks for user defined actions
 */

/*
typedef void (*TaskChanger)(TaskEntry*);
*/
typedef void (*TaskChanger)(TaskEntry*);

TaskChanger TaskSavePrelude;
TaskChanger TaskRestorePostlude;
TaskChanger TaskFreePrelude;
TaskChanger TaskInitPrelude;
TaskChanger TaskPrintPostlude; /* NULL = print header */

/*
 * Magic number used for creating tasks
 */

#define TaskMagic	680712

/*
 * Waiting task data structure
 */

typedef struct {
    TaskEntry *waiters;
    TaskEntry *lastwaiter;
    int value;
    int start;
} TSem_t, *TSem;

/*
 * ---<	Normals
 */

Tid	TaskCurrent(void);
TaskEntry *TaskData(Tid t);
void	Yield(void);
TaskEntry *TaskData(Tid t);
void	TaskSetCurrent(Tid t);
TaskEntry *TaskAllocate(int tid, int fid, int stack);
void EatStack(int);
Tid	TaskNewID(void);
void	TaskSetStatus(Tid t, TStatus s);
TStatus	TaskStatus(Tid t);
void	Die(int exitnum);
int	TaskCount(void);
Tid	TaskCreateStack(Task t, void *env, int size);
Tid	TaskNext(void);
void	TaskYield(Tid next);
void	TasksPrint(void);


/* TaskNext::
   - may not starve any runnable process
   - prioritiese highly priorited
   - those who have sleept and are to be awaken
   - those who wait for a semaphore
   - those who do roundezvouz
   */




