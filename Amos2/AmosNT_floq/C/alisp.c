/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: alisp.c,v $
 * $Revision: 1.2 $ $Date: 2013/03/13 17:58:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: ALisp driver program
 ****************************************************************************/

#include "callin.h"
#include "alisp.h"

int main(int argc,char **argv)
{ 
  a_default_image = "alisp.dmp";
  init_amos(argc,argv);
  evalloop("Lisp> ");
  return 0;
}









