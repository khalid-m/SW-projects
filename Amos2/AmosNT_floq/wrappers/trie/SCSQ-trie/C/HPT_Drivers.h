/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: HPT_Drivers.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the Alisp drivers of the HP trie (Judy)
 * ===========================================================================
 *
 ****************************************************************************/#include "alisp.h"
#include "amos.h"

#define MaxNumberOfHPTries 200
#define FreeHPTCellIndicator -1
#define HPTWinSize 6	//window size in LRB

void InitializeTrieArray();

void Bind_HPT();

oidtype make_trie(bindtype env);
oidtype make_trie64(bindtype env);
oidtype free_trie(bindtype env,oidtype TrieID);
oidtype free_trie64(bindtype env,oidtype TrieID);
oidtype put_trie(bindtype env, oidtype Key, oidtype TrieID, oidtype Value);
oidtype put_trie64(bindtype env, bindtype args);
oidtype get_trie(bindtype env, oidtype Key, oidtype TrieID);
oidtype get_trie64(bindtype env, oidtype s,oidtype x,oidtype d,oidtype v, oidtype TrieID);
oidtype map_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High, oidtype fn);
oidtype count_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High);
oidtype count_trie64(bindtype env, oidtype TrieID,oidtype s,oidtype x,oidtype d);
oidtype avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype trie_vector);
oidtype avg_v_c64(bindtype env,	oidtype s,oidtype x,oidtype d, oidtype min, oidtype trie_vector);
