
#include <math.h>

#include "callout.h"
#include "rdf_reader.h"
#include "raptor.h"

extern void rdf_from_uri(a_callcontext cxt, a_tuple tpl);

void main(int argc,char **argv)
{
	int i=2;
	char amosql[256];
	
	dcl_connection(c); 
	dcl_scan(s);
	
	if (a_initialize(argv[1],TRUE))
	{
		printf("Error : Initializing AMOS II\n");
		return;
	}

	a_connect(c,"",FALSE);
	rdf_set_amos_connection(c);

	while(i < argc)
	{
		sprintf(amosql, "< '%s';", argv[i]);
		a_execute(c, s, amosql, FALSE);
		++i;
	}

	amos_toploop("Amos");
	
	a_disconnect(c,FALSE);
	
	free_scan(s);
	free_connection(c);
}

























