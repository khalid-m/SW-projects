/*****************************************************************************
* AMOS2
* 
* Author: (c) 2007 Yu Cao, Tore Risch, UDBL
* $RCSfile: sparql_main.c,v $
* $Revision: 1.5 $ $Date: 2007/01/30 17:54:41 $
* $State: Exp $ $Locker:  $
*
* Description: Driver program for SparQL
****************************************************************************/

#include <math.h>

#include "callout.h"
#include "sparql_memory.h"
#include "sparql_help.h"
#include "..\..\..\wrappers\CRDF\src\rdf_reader.h"
#include "raptor.h"
 
void main(int argc,char **argv)
{
  int i=2;
  char amosql[256];
  char *image=argv[1];


  dcl_connection(c); 
  dcl_scan(s);
	

  if(image==NULL) image="sparql.dmp";
  if (a_initialize(image,TRUE))
    {
      ERR_PRT("Initializing AMOS II\n");
      return;
    }
	
  a_connect(c,"",FALSE);

  rdf_set_amos_connection(c);
  sparql_set_amos_connection(c);
	
  while(i < argc)
    {
      sprintf(amosql, "< '%s';", argv[i]);
      a_execute(c, s, amosql, FALSE);
      ++i;
    }

  amos_toploop("Amos");
	
  rdf_raptor_finish();

  a_disconnect(c,FALSE);
	
  delete_memory();

  free_scan(s);
  free_connection(c);
}

























