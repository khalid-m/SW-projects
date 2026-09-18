/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Tore Risch, EDSLAB
 * $RCSfile: ODBCMain.c,v $
 * $Revision: 1.1 $ $Date: 2008/08/05 16:36:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Driver for ODBCAmos
 * ===========================================================================
 * $Log: ODBCMain.c,v $
 * Revision 1.1  2008/08/05 16:36:07  torer
 * Added ODBCAmos = Amos II + basic ODBC interface
 *
 ****************************************************************************/

#include "callin.h"
extern void init_ODBCAmos(int,char**);

main(int argc,char **argv)
{
  init_ODBCAmos(argc,argv);
  amos_toploop("ODBCAmos");
  return 0;
}






























































