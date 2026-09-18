/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: dll.h,v $
 * $Revision: 1.2 $ $Date: 2012/01/12 07:49:25 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Main entry for main memory Btree (BT) as a DLL
 * ===========================================================================
 * $Log: dll.h,v $
 * Revision 1.2  2012/01/12 07:49:25  thatr500
 * changed signature a_initialize_extension
 *
 * Revision 1.1  2011/08/24 04:48:22  soba1559
 * added Hp trie (Judy) dll based Mexinma extension
 *
 * Revision 1.5  2011/05/02 06:20:41  thatr500
 * used a_initialize_extension and a_load_extension
 *
 * Revision 1.4  2011/04/29 13:28:56  thatr500
 * modified BT and Linh to compile them on Unix
 *
 * Revision 1.3  2011/04/24 12:28:38  thatr500
 * defined ex_index_routines struct
 *
 * Revision 1.2  2011/04/23 12:26:08  thatr500
 * added comparefn into BTget, BTdelete, BTmap0
 *
 * Revision 1.1  2011/04/19 17:06:13  thatr500
 * add BT as a dll
 *
 ****************************************************************************/
#include "storage.h"
#ifdef WIN32
#define DECLDIR __declspec(dllexport)
#else
#define DECLDIR __attribute__ ((visibility("default")))
#endif
/* Internal variables */
//static int idgen;
//BThead *bhs[10];

#define MaxNumberOfHPTries 200
Pvoid_t  HPTries[MaxNumberOfHPTries];//array keeping pointers to HPTries.
static int HPTrieIndex;//indicates were to put the new trie in HPTries[] array.
#define FreeHPTCellIndicator -1
#define HPTWinSize 6	//window size in LRB


/*-----------------------------------------------------------------------*/
/*DLL internal functions which are index routines*/
oidtype HPT_make(void);
oidtype HPT_put(int htid, oidtype key, oidtype val, ExinmaCompareKeyFunc cmpfn);
oidtype HPT_get(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn);
oidtype HPT_delete(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn);
oidtype HPT_clear(int htid);
void HPT_mapper(int htid, ExinmaMappingFunc f,ExinmaCompareKeyFunc cmpfn, void *xa);
oidtype HPT_computekey(oidtype key);
int HPT_comparekey(oidtype key1, oidtype key2);

/*-----------------------------------------------------------------------*/
/*DLL exported functions which are index routines*/
DECLDIR void a_initialize_extension(void *xa);
