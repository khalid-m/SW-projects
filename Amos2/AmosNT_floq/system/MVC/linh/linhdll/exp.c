/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: exp.c,v $
 * $Revision: 1.9 $ $Date: 2012/01/12 07:47:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: DLL interfaces invoking Linear Hashing code
 * ===========================================================================
 * $Log: exp.c,v $
 * Revision 1.9  2012/01/12 07:47:46  thatr500
 * changed signature a_initialize_extension
 *
 * Revision 1.8  2011/05/02 15:19:15  thatr500
 * *** empty log message ***
 *
 * Revision 1.7  2011/05/02 06:21:25  thatr500
 * used a_initialize_extension and a_load_extension
 *
 * Revision 1.6  2011/04/29 13:28:57  thatr500
 * modified BT and Linh to compile them on Unix
 *
 * Revision 1.5  2011/04/27 15:54:19  thatr500
 * returned nil instead of 0
 *
 * Revision 1.4  2011/04/24 12:27:00  thatr500
 * defined ex_index_routines struct
 *
 * Revision 1.3  2011/04/23 12:29:09  thatr500
 * added comparefn to Dll's interface
 *
 * Revision 1.2  2011/04/19 22:38:47  thatr500
 * *** empty log message ***
 *
 * Revision 1.1  2011/04/09 02:19:20  thatr500
 * - test.cmd is not working
 * - linhdemo.exe cannot run
 * - linh.dll calls back to Amos with compute_hash_key
 *
 * Revision 1.1  2011/01/26 14:10:20  thatr500
 * - make Linear Hashing as a DLL
 * - demo code to utilize Linear Hashing as a DLL
 *
 *
 ****************************************************************************/

#include <stdio.h>
#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif
#include "exp.h"

#define TRUE 1
#define FALSE 0

/*--------------------------------------------------------------*/
oidtype LINH_make() {
  return (idgen++);
}
/*--------------------------------------------------------------*/
oidtype LINH_put(int htid, oidtype key, oidtype val, ExinmaCompareKeyFunc cmpfn) {
  if (ht[htid] == NULL) {
    ht[htid] = lh_init_hashtable(TRUE);  	  
  }
  lh_enter((char *) (val), (char *)(key), ht[htid]);
  return val;
}
/*--------------------------------------------------------------*/
oidtype LINH_get(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn) {
  oidtype t;
  if (ht[htid] == NULL) {
    ht[htid] = lh_init_hashtable(TRUE);  	  
  }
  t = (oidtype)lh_retrieve((char *)(key),ht[htid]);  
  if (t == 0) return nil;
  else return t;
}
/*--------------------------------------------------------------*/
oidtype LINH_delete(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn) {
  oidtype t;
  t = (oidtype) lh_delete((char *)(key), ht[htid]);
  if (t == 0) return nil;
  else return t;
}
/*--------------------------------------------------------------*/
oidtype LINH_clear(int htid) {    
  lh_free(ht[htid]);
  return 0;
}
/*--------------------------------------------------------------*/
void LINH_mapper(int htid, ExinmaMappingFunc f, ExinmaCompareKeyFunc cmpfn, void *xa){
  lh_map(ht[htid], (maplh_function)f, xa);
}
/*--------------------------------------------------------------*/
oidtype LINH_computekey(oidtype key) {
	return compute_hash_key(key);
}
/*--------------------------------------------------------------*/
void a_initialize_extension(void *xa) {	
	struct ex_index_routines rot;
	// reset id base number
	idgen = 0;
	// mapping index routines to local functions
	rot.exCreateFn = LINH_make;
	rot.exPutFn = LINH_put;
	rot.exGetFn = LINH_get;
	rot.exDeleteFn = LINH_delete;
	rot.exClearFn = LINH_clear;
	rot.exMapperFn = LINH_mapper;
	rot.exComputeKeyFn = LINH_computekey;
	rot.exCompareKeyFn = NULL;
	rot.exSaveFn = NULL;
	rot.exLoadFn = NULL;

	 	
	define_ex_index_type("LINH", rot);
}
