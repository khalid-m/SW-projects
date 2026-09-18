/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: NT_Drivers.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:03 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the Alisp drivers of the naive trie
 * ===========================================================================
 *
 ****************************************************************************/
#include "alisp.h"
#include "amos.h"

#define MaxNumberOfNTries 200
#define FreeNTriesCellIndicator -1
#define NTriesWinSize 6	//window size in LRB

void InitializeNaiveTrieArray();
void NT_Test();

void Bind_NT();

oidtype make_naive_trie(bindtype env);
oidtype free_naive_trie(bindtype env,oidtype TrieID);
oidtype put_naive_trie(bindtype env, oidtype Key, oidtype TrieID, oidtype Value);
oidtype get_naive_trie(bindtype env, oidtype Key, oidtype TrieID);
oidtype map_naive_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High, oidtype fn);
oidtype count_naive_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High);
oidtype naive_avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype trie_vector);
