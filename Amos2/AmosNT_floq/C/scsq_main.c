/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2010 Tore Risch, EDSLAB
 * $RCSfile: scsq_main.c,v $
 * $Revision: 1.2 $ $Date: 2010/12/31 07:15:04 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SCSQ driver program
 ****************************************************************************/

#include "scsq.h"

main(int argc,char **argv)
{ 
  init_scsq(argc,argv);
  amos_toploop("[myscsq]");
  return 0;
}









