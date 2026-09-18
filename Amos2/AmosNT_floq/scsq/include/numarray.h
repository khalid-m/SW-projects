/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 * $RCSfile: numarray.h,v $
 * $Revision: 1.31 $ $Date: 2013/06/25 15:49:48 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Management of binary repr numerical data
 ***************************************************************************/

/* Double word aligned (aligned_objectcell) array of bytes */

#ifndef __numarray__
#define __numarray__

struct numarraycell {
  objtags tags;
  short int kind;                           // Kind of numarray. Default 0
  int bytes;                                        // Total size in bytes 
	int numelems;                                         // Num of elements
  int cont[1];                                     // Contents padded here
};

#define numarray_size(db) db->bytes - sizeof(*db) + sizeof(db->cont)

EXTERN int NUMARRAYTYPE;
extern int NUMOOB_ERROR, NUMNARR_ERROR, NUMDMIS_ERROR,
  NUMNOTIMP_ERROR, NUMUNKNOWN_ERROR, NUMTMISMATCH_ERROR, MAMISMATCH_ERROR,
  nannotator;

oidtype new_numarray(int size);
oidtype make_numarray(int numelems, int elemsize, int kind);
oidtype make_iarrayfn(bindtype env, oidtype numelems);
oidtype make_darrayfn(bindtype env, oidtype numelems);
oidtype make_carrayfn(bindtype env, oidtype numelems);
size_t numarray_elemsize(int kind);

oidtype init_darrayfn(bindtype env, oidtype init_array);

oidtype type_of_numarrayfn(bindtype env, oidtype b);
void dealloc_numarray(oidtype array);
void bulkprint_numarray(oidtype x,oidtype stream,int princflg);
oidtype bulkread_numarray(bindtype env, oidtype tag, oidtype x, oidtype stream);

oidtype numarray_sizefn(bindtype env, oidtype b);
oidtype numarray_printfn(bindtype env, oidtype o, oidtype str);
void numarray_hr_printer(oidtype na, oidtype str);
oidtype numarray_dimfn(bindtype env, oidtype b);

oidtype a_numvrefbbf(a_callcontext cxt);
void a_numvrefbff(a_callcontext cxt, a_tuple params);

int equal_numarrayfn(oidtype x, oidtype y);

oidtype naprojectfn(bindtype env, oidtype x, oidtype begin, oidtype size);

oidtype naselt(bindtype env, oidtype array, oidtype i);
oidtype naeltfn(bindtype env, oidtype array, oidtype index);

int namin(int* indexes, oidtype tplv, int attrib);

/* Euclid norm */
void a_enormbf(a_callcontext cxt, a_tuple params);

void register_numarray(void);

/* Debug fcn */
void inspect_numarray(oidtype x);

/* Multiarrays */
oidtype mabbf(a_callcontext cxt);
void register_multina(void);
void register_lrmultiply(void);

// ADDED BY Andrej
oidtype nasetafn(bindtype env, oidtype array, oidtype index, oidtype val);
unsigned int numarray_hash(oidtype key);

#endif
