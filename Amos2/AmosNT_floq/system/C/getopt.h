/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: getopt.h,v $
 * $Revision: 1.2 $ $Date: 2004/02/03 15:01:17 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface to the GotOption module.
 *
 ****************************************************************************/

#ifndef _getopt_h_
#define _getopt_h_

extern int GetOption (int argc, char** argv, const char* pszValidOpts, char** ppszParam);

#endif
