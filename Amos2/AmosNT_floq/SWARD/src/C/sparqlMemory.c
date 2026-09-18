/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, UDBL
 * $RCSfile: sparqlMemory.c,v $
 * $Revision: 1.4 $ $Date: 2010/04/28 14:46:29 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SparQL parser temporary memory manager
 * ===========================================================================
 * $Log: sparqlMemory.c,v $
 * Revision 1.4  2010/04/28 14:46:29  fred2431
 * Compile and regression test for SWARD under Linux
 *
 * Revision 1.3  2007/10/03 14:43:19  silvias
 * Changed the memory size from 8K to 10K
 *
 * Revision 1.2  2007/07/24 05:55:36  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/07/23 20:24:16  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/06/12 14:32:39  torer
 * Stand-alone SparQL parser in C
 *
 ****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "sparqlMemory.h"

#define MEMORY_SIZE	(1024*1024) /*10K bytes*/

static u8 *pMem = 0;
static u32 iMemUsed;

void create_memory(void)
{
	iMemUsed = 0;
	if ( pMem == 0)
		pMem = (u8*)malloc(MEMORY_SIZE);
	memset(pMem, 0, MEMORY_SIZE);
}

void delete_memory(void)
{
	iMemUsed = 0;
	if ( pMem != 0)
	{
		free(pMem);
		pMem = 0;
	}
}

void memory_profile(void)
{
	printf("SparQL memory left : %dK bytes\n", (MEMORY_SIZE-iMemUsed)/1024);
}

void *sparql_new(u32 size)
{
	u32 ret = iMemUsed;
	
	iMemUsed += size + size % 4;
	if (iMemUsed >= MEMORY_SIZE)
	{
		printf("Error : SparQL memory running out of memory\n");
		return 0;
	}
	
	return (void*)&pMem[ret];
}


