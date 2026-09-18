/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Description:  Merge two streams using unix pipe()
 * Language:     C
 ****************************************************************************/

void pipemerge_mapper(bindtype env, oidtype tpl, void *xa);
void pipemergebbff(a_callcontext cxt, a_tuple params);
void register_pipemerge(void);
