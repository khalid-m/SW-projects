/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, UDBL
 * $RCSfile: sparqlMemory.c,v $
 * $Revision: 1.1 $ $Date: 2007/11/22 14:58:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SparQL parser temporary memory manager
 * ===========================================================================
 * $Log: sparqlMemory.c,v $
 * Revision 1.1  2007/11/22 14:58:21  petrini
 * Added functionality for:
 * 1. Running SparQL parser outside java for debugging purposes.
 * 2. Support for implicit 'FROM' clauses by SparQL parser.
 * 3. Regression testing of RDQL, original SparQL parser and SparQL parser.
 * 4. Handling of foreign and composite keys in SWARD.
 * 5. Handling of class instances in SWARD.
 * 6. Regression testing of foreign, composite keys and class instances.
 *
 * Revision 1.1  2007/07/24 05:55:38  petrini
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

#define MEMORY_SIZE	(1024*8) /*8K bytes*/

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


