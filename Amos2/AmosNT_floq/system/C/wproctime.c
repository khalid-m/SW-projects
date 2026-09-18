/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Erik Zeitler, UDBL
 * $RCSfile: wproctime.c,v $
 * $Revision: 1.2 $ $Date: 2011/03/09 12:33:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Windows CPU measurement
 * ===========================================================================
 * $Log: wproctime.c,v $
 * Revision 1.2  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.1  2010/12/30 12:42:29  zeitler
 * Windows CPU time measurement
 *
 *
 ****************************************************************************/

#include <stdio.h>
#include "storage.h"
#include "Winsock2.h"
#include "amos.h"

int procfile_open_failed;

//#define DEBUG

EXPORT double proctime() 
{
  double proctime;
  DWORD p;
  HANDLE hProcess;
  FILETIME ftCreation, ftExit, ftKernel, ftUser;
  __int64 i64Kernel, i64User;
  double kerneltime, usertime;

  p = GetCurrentProcessId();
  hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, 0, p);
  GetProcessTimes(hProcess, &ftCreation, &ftExit, &ftKernel, &ftUser);
  i64Kernel = *((__int64 *) &ftKernel);
  i64User = *((__int64 *) &ftUser);
  kerneltime = i64Kernel / 10e6;
  usertime = i64User / 10e6;
  proctime = kerneltime + usertime;
  CloseHandle(hProcess);
#ifdef DEBUG
  printf("k %f, u %f\n", kerneltime, usertime);
#endif
  return proctime;
}

EXPORT oidtype proctimefn(bindtype env) 
{
  DWORD p;
  double pt = proctime();
  p = GetCurrentProcessId();
  if (pt < - 0.5) {
    a_error(procfile_open_failed, mkinteger(p), FALSE);
  }
  return mkreal(pt);
}

void register_wproctime(void) {
	extfunction0("proctime", proctimefn);
	procfile_open_failed = a_register_error("wproctime error");
}
