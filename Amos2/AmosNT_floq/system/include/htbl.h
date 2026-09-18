/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch (extending code by Mikael Pettersson, IDA)
 * $RCSfile: htbl.h,v $
 * $Revision: 1.3 $ $Date: 2009/04/07 20:30:51 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Declarations for linear hashing inside image
 * ===========================================================================
 * $Log: htbl.h,v $
 * Revision 1.3  2009/04/07 20:30:51  torer
 * Faster hashing on arrays and lists
 *
 ****************************************************************************/

#ifndef _htbl_h_
#define _htbl_h_

#include <stdlib.h>
#include <stdio.h>
#include "linh.h"

/* SEGMENTSIZE must be a power of 2 !! */
#define SEGMENTSIZE     512
#define DIRECTORYSIZE   512

typedef struct lh_element 
{
    objtags             tags;
    unsigned            hash;
    oidtype             key;
    oidtype             value;
    oidtype             next;
} lh_element_t;

typedef struct hashtabcell 
{
    objtags      tags;
    unsigned int p;                                         /* split pointer */
    unsigned int maxp_minus_1;       /* == maxp - 1; maxp is the upper bound */
    int          slack;             /* number of insertions before expansion */
    oidtype      directory;      /* Points to directory array where each
                                    element points to segment array where
                                    each element points to hash bucket 
                                    elements                                 */
    unsigned int elements;        /* the current number of elements in table */
    unsigned int equalflag;                       /* test with equal if true */
} hashtab;

oidtype new_lh(unsigned int equalflag);        /* allocates new lh hashtable */
void clear_lh(oidtype tbl);
int enter_lh(oidtype ht, oidtype key, oidtype val); 
                                            /* insert string into hash table */
oidtype retrieve_lh(oidtype ht, oidtype key);    /* retrieve value given key */
int delete_lh(oidtype ht, oidtype key);              /* delete key and value */
int hash_buckets(oidtype ht);                 /* nr of buckets in hash table */
oidtype nth_hash_bucket_firstval(oidtype ht, int n); 
                                          /* First value in n:th hash bucket */

#endif
