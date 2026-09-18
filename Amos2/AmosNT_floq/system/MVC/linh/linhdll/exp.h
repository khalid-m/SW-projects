/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: exp.h,v $
 * $Revision: 1.8 $ $Date: 2012/01/12 07:47:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Linear Hashing is compiled as a Windows DLL
 * ===========================================================================
 * $Log: exp.h,v $
 * Revision 1.8  2012/01/12 07:47:46  thatr500
 * changed signature a_initialize_extension
 *
 * Revision 1.7  2011/05/02 06:21:25  thatr500
 * used a_initialize_extension and a_load_extension
 *
 * Revision 1.6  2011/04/29 13:28:58  thatr500
 * modified BT and Linh to compile them on Unix
 *
 * Revision 1.5  2011/04/24 12:27:00  thatr500
 * defined ex_index_routines struct
 *
 * Revision 1.4  2011/04/23 12:29:09  thatr500
 * added comparefn to Dll's interface
 *
 * Revision 1.3  2011/04/19 22:38:47  thatr500
 * *** empty log message ***
 *
 * Revision 1.2  2011/04/09 02:19:21  thatr500
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

#ifndef _LINH_DLL_H_
#define _LINH_DLL_H_

#ifdef WIN32
#define DECLDIR __declspec(dllexport)
#else
#define DECLDIR __attribute__ ((visibility("default")))
#endif

#include "storage.h"
#include "../../../include/linh.h"

static int idgen;
hashtable_t *ht[10];

/*--------------------------------------------------------------*/
/*Linear hasing functions importing from linh.obj*/

/*--------------------------------------------------------------*/
/*DLL interal functions which are index routines*/
oidtype LINH_make(void);
oidtype LINH_put(int htid, oidtype key, oidtype val, ExinmaCompareKeyFunc cmpfn);
oidtype LINH_get(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn);
oidtype LINH_delete(int htid, oidtype key, ExinmaCompareKeyFunc cmpfn);
oidtype LINH_clear(int htid);
void LINH_mapper(int htid, ExinmaMappingFunc f, ExinmaCompareKeyFunc cmpfn, void *xa);
oidtype LINH_computekey(oidtype key);

/*--------------------------------------------------------------*/
/*DLL exported init function*/
DECLDIR void a_initialize_extension(void *xa);
#endif
