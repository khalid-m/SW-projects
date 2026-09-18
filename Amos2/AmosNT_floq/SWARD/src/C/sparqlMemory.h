/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, UDBL
 * $RCSfile: sparqlMemory.h,v $
 * $Revision: 1.2 $ $Date: 2007/07/24 05:55:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SparQL parser temporary memory manager
 * ===========================================================================
 * $Log: sparqlMemory.h,v $
 * Revision 1.2  2007/07/24 05:55:37  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/07/23 20:24:16  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/06/12 14:32:39  torer
 * Stand-alone SparQL parser in C
 *
 ****************************************************************************/

#ifndef _SPARQLMEMORY_H_
#define _SPARQLMEMORY_H_

typedef unsigned char u8;
typedef unsigned int u32;

typedef char s8;
typedef int s32;

void create_memory(void);
void delete_memory(void);
void memory_profile(void);
void *sparql_new(u32 size);

#endif
