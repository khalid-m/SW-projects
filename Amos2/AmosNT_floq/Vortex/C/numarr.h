/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2013 Tore Risch, UDBL
 * $RCSfile: numarr.h,v $
 * $Revision: 1.4 $ $Date: 2013/05/30 13:03:04 $
 * $State: Exp $ $Locker:  $
 *
 * Description: External interface to numarray
 ***************************************************************************/

/* Double word aligned (aligned_objectcell) array of bytes */

#ifndef __numarr__
#define __numarr__

struct numarraycell 
{
  objtags tags;
  short int kind;                           // Kind of numarray. Default 0
  int bytes;                                        // Total size in bytes 
  int numelems;                                         // Num of elements
  int cont[1];                                     // Contents padded here
};

#define numarray_size(db) db->bytes - sizeof(*db) + sizeof(db->cont)

EXTERN int NUMARRAYTYPE;
EXTERN oidtype na_csv_double_readfn(bindtype env, oidtype str, oidtype delim);
EXTERN oidtype na_csv_float_readfn(bindtype env, oidtype str, oidtype delim);
EXTERN oidtype na_new_iarray(int dim); // allocate new integer numarray
EXTERN oidtype na_new_darray(int dim); // allocate new souble numaray

#endif
