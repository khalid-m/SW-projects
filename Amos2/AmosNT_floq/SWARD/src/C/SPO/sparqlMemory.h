/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, UDBL
 * $RCSfile: sparqlMemory.h,v $
 * $Revision: 1.1 $ $Date: 2007/11/22 14:58:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SparQL parser temporary memory manager
 * ===========================================================================
 * $Log: sparqlMemory.h,v $
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
