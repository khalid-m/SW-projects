/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Erik Zeitler, UDBL
 * $RCSfile: lproctime.h,v $
 * $Revision: 1.1 $ $Date: 2010/12/30 13:02:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Linux CPU measurement
 * ===========================================================================
 * $Log: lproctime.h,v $
 * Revision 1.1  2010/12/30 13:02:45  zeitler
 * Linux CPU measurement
 *
 ****************************************************************************/

void register_lproctime(void);
float GetProcessTime(pid_t PID,int IncludeSelf,int IncludeChildren);
oidtype proctimefn(bindtype env);
