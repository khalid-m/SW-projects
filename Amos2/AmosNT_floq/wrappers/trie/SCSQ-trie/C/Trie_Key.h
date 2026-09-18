/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: Trie_Key.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:03 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the 'Trie_Key.c'
 * ===========================================================================
 *
 ****************************************************************************/
#include "alisp.h"
#include "amos.h"
#include "judy.h"

void Bind_Trie_Key();

oidtype trie_key(bindtype env, oidtype vector_key);
oidtype trie_low_range(bindtype env, oidtype vector_key);
oidtype trie_high_range(bindtype env, oidtype vector_key);
void cons_64_trie_key(int x,int d, int s, int v, uint8_t* key);
void cons_64_BT_key  (int m, int x,int d, int s, int v, __int64* result);
void bin_prnt_byte(int x);
void bin_prnt_int(int x);
int compare_trie_keys(uint8_t* a,uint8_t* b);
