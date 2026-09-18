/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Erik Zeitler, UDBL
 * $RCSfile: lproctime.c,v $
 * $Revision: 1.2 $ $Date: 2013/03/28 18:56:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Linux CPU measurement
 * ===========================================================================
 * $Log: lproctime.c,v $
 * Revision 1.2  2013/03/28 18:56:13  torer
 * (PROCTIME) works under OSX
 *
 * Revision 1.1  2010/12/30 13:02:43  zeitler
 * Linux CPU measurement
 *
 ****************************************************************************/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include "storage.h"
#include "lproctime.h"

#define STRING_LENGTH 80
#define MAX_PROCESSES 1000
#define DEFAULT_DELAY_BETWEEN_CHECKS 10
#define NANOSECONDS 1E9
#define MICROSECONDS 1E6
#define JIFFIES 100
typedef char String[STRING_LENGTH];

int procfile_open_failed;

//#define DEBUG
#ifdef __APPLE__
#include <time.h>
oidtype proctimefn(bindtype env)
{
  clock_t cl = clock();
  if(cl != (clock_t)-1) return mkreal(cl/(double)CLOCKS_PER_SEC);
  return mkreal(0.0);
}

#else
oidtype proctimefn(bindtype env) {
  double proctime = 0.0;
  pid_t p = getpid();
  proctime = GetProcessTime(p, 1, 0);
  if (proctime < - 0.5) {
    a_error(procfile_open_failed, mkinteger(p), FALSE);
  }
  return mkreal(proctime);
}

float GetProcessTime(pid_t PID, int IncludeSelf, int IncludeChildren) {
    FILE *ProcFile;
    String ProcFileName;
    double MyTime, ChildTime, ProcessTime;
    int UserJiffies, SysJiffies, ChildUserJiffies, ChildSysJiffies;

    ProcessTime = 0.0;
    sprintf(ProcFileName, "/proc/%d/stat", PID);
    if ((ProcFile = fopen(ProcFileName,"r")) != NULL) {
        fscanf(ProcFile,"%*d %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %d %d %d %d", 
	       &UserJiffies, &SysJiffies, &ChildUserJiffies, &ChildSysJiffies);
        fclose(ProcFile);

#ifdef DEBUG
	printf("%d: my jiffies = %d, dead child jiffies = %d\n", PID,
	       UserJiffies + SysJiffies, ChildUserJiffies + ChildSysJiffies);
#endif

        MyTime = ((float)(UserJiffies + SysJiffies))/JIFFIES;
//----Time used by this process's dead children (man pages are wrong - does
//----not include my jiffies)
        ChildTime = ((float)(ChildUserJiffies + ChildSysJiffies))/JIFFIES;
        if (IncludeSelf) {
	  ProcessTime += MyTime;
        }
        if (IncludeChildren) {
	  ProcessTime += ChildTime;
        }
        return(ProcessTime);
    } else {
      // Failed to open my proc file
      return - 1.0;
    }
}
#endif

void register_lproctime(void) {
  extfunction0("proctime", proctimefn);
  procfile_open_failed = a_register_error("Failed to open my /proc file");
}
