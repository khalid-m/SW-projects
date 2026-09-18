/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Merge two streams using unix pipe()
 * Language:     C
 ****************************************************************************/

oidtype pipemerge_mapper(a_callcontext cxt, oidtype tpl, void *xa);
void pipemergebbff(a_callcontext cxt, a_tuple params);
void register_pipemerge(void);
