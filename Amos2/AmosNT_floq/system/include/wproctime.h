/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Erik Zeitler, UDBL
 * $RCSfile: wproctime.h,v $
 * $Revision: 1.1 $ $Date: 2010/12/30 12:42:30 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Windows CPU measurement
 * ===========================================================================
 * $Log: wproctime.h,v $
 * Revision 1.1  2010/12/30 12:42:30  zeitler
 * Windows CPU time measurement
 *
 *
 ****************************************************************************/

void register_wproctime(void);
double proctime();
oidtype proctimefn(bindtype env);
