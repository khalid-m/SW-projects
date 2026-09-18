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