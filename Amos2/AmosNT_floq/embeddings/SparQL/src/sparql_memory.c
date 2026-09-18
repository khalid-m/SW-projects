#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "sparql_memory.h"

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


