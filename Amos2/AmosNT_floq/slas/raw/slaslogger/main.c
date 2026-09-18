/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2012 Thanh Truong, UDBL
 * $RCSfile: main.c,v $
 * $Revision: 1.1 $ $Date: 2013/12/12 16:29:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Simulator main
 ****************************************************************************/
#include "../../../../C/callin.h"
#include "../../../../C/callout.h"
#include "slaslogger.h"

extern void testGenerate();
extern void testGetRandom();
extern void testMap();
extern void testRelease();

int main(int argc,char **argv)
{
	dcl_connection(c); 
	dcl_scan(s);

	// Start program with a different seed for randomness
	srand(time(NULL)); 

	// Connect to embbeded database
	init_amos(argc,argv); 
	
	// Mapping foreign functions with their implementations
	a_extimpl("slas_write_indexed_logfilebbf", slas_write_indexed_logfilebbf);	
	a_connect(c,"",FALSE); 

	free_scan(s);
	free_connection(c);

	// Testing
	testGenerate();
	testGetRandom();
	testMap();
	testRelease(),

	amos_toploop("SLAS");  	
	return 0;
}









