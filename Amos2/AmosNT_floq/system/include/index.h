/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2001 Tore Risch, UDBL
 * $Revision:
 * $State:
 *
 * Description: Declarations for index manager
 *
 * Requirements:
 * ===========================================================================
 * $Log:
 */

#ifndef _index_h_
#define _index_h_
struct indexcell   /* Index header */
{
  objtags tags;    /* Internal storage tags */
  short int unique;/* Unique index if TRUE */
  int pos;         /* The position of the index in owner object */
  int cardinality; /* # index keys stored */
  int totalrows;   /* # rows stored */
  oidtype rows;    /* The index */
  oidtype owner;   /* The object owning the index */
  int type;        /* The index type */
};
EXTERN int indextype; /* Storage type ID for index header */

/*****************************************************************************/
/*                    Signatures of index hooks                              */
/*****************************************************************************/


typedef oidtype(*index_creator)(bindtype env,oidtype indhdr,size_t size);

typedef int(*index_dropper)(bindtype env, oidtype inhdr); 

typedef int(*index_mapfn)(bindtype env, oidtype indhdr, oidtype ind,
                          oidtype pat, void *xa);
typedef void(*index_mapper)(bindtype env, oidtype indhdr, oidtype ind,
                            index_mapfn fn, void *xa);
typedef oidtype(*index_getter)(bindtype env, oidtype indhdr, oidtype ind,
                               oidtype key);
typedef oidtype(*index_inserter)(bindtype env, oidtype indhdr, oidtype ind,
                                 oidtype key, oidtype v);
typedef oidtype(*index_deleter)(bindtype env, oidtype indhdr, oidtype ind,
                                oidtype key);
typedef int(*index_counter)(bindtype env, oidtype indhdr, oidtype ind);

/*****************************************************************************/
/*               Primitives to introduce new kind of index                   */
/*****************************************************************************/

struct index_properties
{
  char name[10];
  index_creator creator;
  index_mapper mapper;
  index_getter getter;
  index_inserter inserter;
  index_deleter deleter;
  index_counter counter;
  index_dropper dropper;
};

#define MAX_INDEX_TYPES 20
EXTERN struct index_properties index_types[MAX_INDEX_TYPES];
                                                     /* table of index types */
EXTERN int define_index_type(struct index_properties props);
                                                    /* Define new index type */

/*****************************************************************************/
/*                         Internal functions                                */
/*****************************************************************************/

extern oidtype mapindex(bindtype env,oidtype indx, oidtype pat,
                        index_mapfn fn, void *xa);
extern oidtype index_cardinalityfn(bindtype env, oidtype ix);
extern oidtype insertindexfn(bindtype env, oidtype indx, oidtype key,
                             oidtype rel);
extern oidtype patternpfn(bindtype env, oidtype p);
extern oidtype retractindexfn(bindtype env, oidtype indx, oidtype key,
                              oidtype rel);
extern int get_index_type(char *name);
extern oidtype dropindexfn(bindtype env, oidtype indx);

#endif

