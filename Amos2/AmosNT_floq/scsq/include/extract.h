/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Erik Zeitler, UDBL
 * $RCSfile: extract.h,v $
 * $Revision: 1.5 $ $Date: 2010/12/19 13:47:30 $
 * $State: Exp $ $Locker:  $
 *
 * Description: TCP extract from >= 1 other stream processes
 ***************************************************************************/

void register_extract();

oidtype instrum_ezreadsfn(bindtype env, oidtype readarray, oidtype allsocks);
oidtype instrum_ezreadfn(bindtype env, oidtype stream, oidtype allsocks);
oidtype tsread(bindtype env, oidtype stream);

extern oidtype TS, ADD2DELAYS, EOFS, DERR, STOPSOCKS, STOPSYM, MERGEPROC, 
  IEXTRACT;
extern oidtype REMPROD, ASYNCREAD, POLLIST;
extern oidtype SETDIFF, MEMQ, GS_SP;
extern double readtime;
extern int readcalls;
