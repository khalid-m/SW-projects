/*****************************************************************************
* AMOS2
*
* Author: (c) 2005 Erik Zeitler, UDBL
*
* Description:  SCSQ: An AmosII driver with all SCSQ extensions.
* Language:     C
* Location:     AmosNT/scsq/C/scsq.c
****************************************************************************/

#include "scsq.h"

int main(int argc,char **argv) 
{
	int rc;
		
	a_default_image = "scsq.dmp";
	rc = init_scsq(argc, argv);
	if(rc) return rc;
	amos_toploop("[scsq]");
    return 0;
}
