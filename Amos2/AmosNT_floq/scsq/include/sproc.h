/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  Function headers for Stream Processors
 * Language:     C
 * Location:     AmosNT/astro/sproc.h
 ****************************************************************************/

oidtype stream_generator_mapper(a_callcontext env, int width, oidtype *tpl,
							 void *xa);
int sproc(a_callcontext cxt, int protocol);
void register_sproc();
void register_scsq_functions(void);
void pffn(bindtype env, oidtype object, oidtype socket);

#define TCPPROTOCOL 1
#define MPIPROTOCOL 2
#define BGOUTPROTOCOL 3
