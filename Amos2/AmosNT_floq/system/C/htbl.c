/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch (extending code by Mikael Pettersson, IDA)
 * $RCSfile: htbl.c,v $
 * $Revision: 1.16 $ $Date: 2012/01/18 09:36:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Linear hashing inside image
 * ===========================================================================
 * $Log: htbl.c,v $
 * Revision 1.16  2012/01/18 09:36:40  torer
 * Revert
 *
 * Revision 1.11  2010/12/02 18:29:21  torer
 * Checkin mistake corrected
 *
 * Revision 1.9  2010/06/23 20:30:16  torer
 * *** empty log message ***
 *
 * Revision 1.8  2010/06/23 19:03:33  torer
 * *** empty log message ***
 *
 * Revision 1.7  2010/06/23 18:40:53  torer
 *
 * Revision 1.5  2010/05/25 15:18:57  torer
 * Index interface included
 *
 * Revision 1.4  2009/10/05 14:27:07  torer
 * Hashing on adjustable vectors did not work
 *
 * Revision 1.3  2009/09/17 12:51:45  torer
 * Bug in hashing on complex array structures
 *
 * Revision 1.2  2009/04/10 15:18:03  torer
 * *** empty log message ***
 *
 * Revision 1.1  2009/04/07 21:02:15  torer
 * Added htbl.c
 *
 ****************************************************************************/

#include "intstorage.h"
#include "htbl.h"
#include "index.h"

#define DIRINDEX(address)       ((address) / SEGMENTSIZE)
#define SEGINDEX(address)       ((address) % SEGMENTSIZE)
#if     !defined(MAXLOADFCTR)
#define MAXLOADFCTR     2
#endif  /*MAXLOADFCTR*/
#if     !defined(MINLOADFCTR)
#define MINLOADFCTR     (MAXLOADFCTR/2)
#endif  /*MINLOADFCTR*/

#define new_directory() new_array(DIRECTORYSIZE,nil)
#define new_segment()   new_array(SEGMENTSIZE,nil)
#define getdirectory(ht) dr(ht,hashtabcell)->directory
#define aref(a,i) dr(a,arraycell)->cont[i]
#define a_setf1(var,val)((var) = (val), ref(doid(var))=1)
#define hash_equal(x,y) (equalflag ? equal(x,y) : (x) == (y))
#define hash_value(x) (equalflag ? compute_hash_key(x) : x)

EXPORT unsigned int compute_hash_key(register oidtype key)
{       register hash_function hfn;

 hfn = typefns[a_datatype(key)].hashfn;
 if(hfn != NULL) return (*hfn)(key);
 return (unsigned int)key;
}

EXPORT void clear_hashtable(oidtype tbl)
{
  oidtype directory;
  struct hashtabcell *T = dr(tbl,hashtabcell);
  int i;

  T->p                = 0;
  T->maxp_minus_1     = SEGMENTSIZE - 1;
  T->slack            = SEGMENTSIZE * MAXLOADFCTR;
  T->elements         = 0;
  directory = getdirectory(tbl);
  if(a_datatype(directory) == ARRAYTYPE)
    {
      struct arraycell *dir = dr(directory,arraycell);

      for(i=1;i<dir->size && dir->cont[i]!=nil;i++)
	a_free(dir->cont[i]);
      if(a_datatype(dir->cont[0])== ARRAYTYPE)
	{
	  struct arraycell *seg = dr(dir->cont[0],arraycell);
	  for(i=0;i<seg->size;i++)
            a_free(seg->cont[i]);
	}
      else a_free(dir->cont[0]);
    }
  else released(getdirectory(tbl));
  return;
}

EXPORT oidtype new_hashtable(unsigned int equalflag)
{
  struct hashtabcell *T;
  oidtype tbl, directory;

  inittypen(HASHTYPE,tbl,T,sizeof(*T),hashtabcell);
  T->equalflag        = equalflag;
  T->directory         = nil;
  T->p                = 0;
  T->maxp_minus_1     = SEGMENTSIZE - 1;
  T->slack            = SEGMENTSIZE * MAXLOADFCTR;
  T->elements         = 0;
  directory = new_directory();
  a_setf(getdirectory(tbl),directory);
  a_setf(aref(directory,0),new_segment());
  return tbl;
}

void dealloc_lh(oidtype tbl)
{
  a_free(getdirectory(tbl));
  freebytes(tbl,sizeof(struct hashtabcell));
}

void dealloc_lhelem(oidtype e)
{
  struct lh_element *de = dr(e,lh_element);
  oidtype nxt;

  for(;;)
    {
      a_free(de->value);
      a_free(de->key);
      nxt = de->next;
      free2(e,de);
      if(nxt == nil) break;
      decalloccnt(nxt,HASHBUCKETTYPE);
      de = dr(nxt,lh_element);
      e = nxt;
    }
  return;
}

void expandtable_lh(oidtype tbl)
{
  struct hashtabcell *T = dr(tbl,hashtabcell);
  oidtype *oldbucketp, chain, headofold, headofnew, next;
  unsigned int maxp0 = T->maxp_minus_1 + 1;
  unsigned int tp = T->p;
  unsigned int newaddress = maxp0 + tp;

  /* no more room? */
  if( newaddress >= DIRECTORYSIZE * SEGMENTSIZE )
    return; /* should allocate a larger directory */

  /* if necessary, create a new segment */
  if( SEGINDEX(newaddress) == 0 )
    {
      oidtype nw = new_segment();

      T = dr(tbl,hashtabcell); /* Re-reference tbl */
      a_setf1(aref(T->directory,DIRINDEX(newaddress)), nw);
    }

  /* adjust the state variables */
  if( ++(T->p) > T->maxp_minus_1 ) 
    {
      T->maxp_minus_1 = 2 * T->maxp_minus_1 + 1;
      T->p = 0;
    }
  T->slack += MAXLOADFCTR;

  /* relocate records to the new bucket (does not preserve order) */
  headofold = nil;
  headofnew = nil;
  /* locate the old (to be split) bucket */
  oldbucketp = &aref(aref(getdirectory(tbl),DIRINDEX(tp)),SEGINDEX(tp));
  for(chain = *oldbucketp; chain != nil; chain = next)
    {
      struct lh_element *el = dr(chain,lh_element);

      next = el->next;
      if( el->hash & maxp0 ) 
	{
	  el->next = headofnew;
	  headofnew = chain;
	} 
      else 
	{
	  el->next = headofold;
	  headofold = chain;
	}
    }
  *oldbucketp = headofold;
  aref(aref(getdirectory(tbl),DIRINDEX(newaddress)),
       SEGINDEX(newaddress)) = headofnew;
}

EXPORT int put_hashtable(oidtype tbl, oidtype key, oidtype val)
{
  register struct hashtabcell *T = dr(tbl,hashtabcell);
  unsigned int equalflag = T->equalflag;
  register struct lh_element *dchain;
  unsigned int hash, si;
  unsigned int address;
  oidtype oldchain, chain, segment;

  /* locate the bucket for this object */
  hash = hash_value(key);
  address = hash & T->maxp_minus_1;
  if( address < T->p )
    address = hash & (2 * T->maxp_minus_1 + 1);

  segment = aref(T->directory,DIRINDEX(address));
  si = SEGINDEX(address);
  oldchain = aref(segment,si);

  /* is the object already in the hash table? */
  for(chain = oldchain; chain != nil; chain = dchain->next)
    {
      dchain = dr(chain,lh_element);
      if( dchain->hash == hash && hash_equal(dchain->key,key))
        {
	  a_setf(dchain->value,val);
	  return FALSE;     /* already there */
        }
    }

  /* nope, must add new entry */
  inittype2(HASHBUCKETTYPE,chain,dchain,lh_element);
  dchain->hash = hash;
  a_let(dchain->key,key);
  dchain->next = oldchain;
  a_let(dchain->value,val);
  a_setf1(aref(segment,si),chain);
  T = dr(tbl,hashtabcell);
  T->elements++;
  /* do we need to expand the table? */

  if( --(T->slack) < 0 )
    expandtable_lh(tbl);
  return TRUE;
}

EXPORT oidtype get_hashtable(oidtype tbl, oidtype key)
{
  register struct hashtabcell *T = dr(tbl,hashtabcell);
  unsigned int equalflag = T->equalflag;
  unsigned int hash;
  register unsigned int address;
  oidtype oldchain, chain;
  register lh_element_t *dchain;

  /* locate the bucket for this object */
  hash = hash_value(key);
  address = hash & T->maxp_minus_1;
  if( address < T->p )
    address = hash & (2 * T->maxp_minus_1 + 1);

  oldchain = aref(aref(T->directory,DIRINDEX(address)),SEGINDEX(address));

  /* is the object already in the hash table? */
  for(chain = oldchain; chain != nil; chain = dchain->next)
    {
      dchain = dr(chain,lh_element);
      if( dchain->hash == hash && hash_equal(dchain->key,key))
	return dchain->value;     /* already there */
    }

  /* nope, must return NULL */
  return NULLH;
}

void shrink_lh(oidtype tbl)
{
  struct hashtabcell *T = dr(tbl,hashtabcell);
  oidtype *lastseg;
  oidtype *chainp;
  unsigned oldlast = T->p + T->maxp_minus_1;

  if( oldlast == 0 )
    return; /* cannot shrink below this */

  /* adjust the state variables */
  if( T->p == 0 ) 
    {
      T->maxp_minus_1 >>= 1;
      T->p = T->maxp_minus_1;
    } 
  else
    --(T->p);
  T->slack -= MAXLOADFCTR;

  /* insert the chain `oldlast' at the end of chain `T->p' */
  chainp = &aref(aref(T->directory, DIRINDEX(T->p)),SEGINDEX(T->p));
  while( *chainp != nil )
    chainp = &(dr(*chainp,lh_element)->next);
  lastseg = &aref(T->directory,DIRINDEX(oldlast));
  *chainp = aref(*lastseg,SEGINDEX(oldlast));
  aref(*lastseg,SEGINDEX(oldlast)) = nil;
  /* if necessary, free the last segment */
  if( SEGINDEX(oldlast) == 0 )
    a_free(*lastseg);
}

EXPORT oidtype rem_hashtable(oidtype tbl, oidtype key)
{
  struct hashtabcell *T = dr(tbl,hashtabcell);
  unsigned int equalflag = T->equalflag;
  unsigned hash, address;
  oidtype *prev, here;
  struct lh_element *dhere;

  /* locate the bucket for this object */
  hash = hash_value(key);
  address = hash & T->maxp_minus_1;
  if( address < T->p )
    address = hash & (2 * T->maxp_minus_1 + 1);

  /* find the element to be removed */
  prev = &aref(aref(T->directory,DIRINDEX(address)),SEGINDEX(address));
  for(; (here = *prev) != nil; prev = &dhere->next)
    {
      dhere = dr(here,lh_element);
      if( dhere->hash == hash && hash_equal(dhere->key,key))
	break;
    }
  if( here == nil)
    return nil; /* the object wasn't there! */

  /* remove this element */
  *prev = dhere->next;
  dhere->next = nil; /* makes deallocation of 'here' work OK */
  released(here);
  T = dr(tbl,hashtabcell);
  T->elements--;

  /* do we need to shrink the table? the test is:
   *          keycount / currentsize < minloadfctr
   * i.e.     ((maxp+p)*maxloadfctr-slack) / (maxp+p) < minloadfctr
   * i.e.     (maxp+p)*maxloadfctr-slack < (maxp+p)*minloadfctr
   * i.e.     slack > (maxp+p)*(maxloadfctr-minloadfctr)
   */

  if( ++(T->slack) >
      (int)(T->maxp_minus_1 + 1 + T->p) * (MAXLOADFCTR-MINLOADFCTR)
      )
    shrink_lh(tbl);
  return t;
}

EXPORT void map_hashtable(bindtype env, oidtype indhdr, oidtype ht,
			  maphash_function f, void *x)
{
  struct hashtabcell *T = dr(ht,hashtabcell);
  oidtype directory = T->directory, segment;
  oidtype bck, next;
  struct lh_element *de;
  int i,j;

  for(i=0;i<DIRECTORYSIZE;i++)
    {
      segment = aref(directory,i);
      if(segment!=nil)
	for(j=0;j<SEGMENTSIZE;j++)
	  {
	    bck = aref(segment,j);
	    if(bck!=nil)
	      for(;bck != nil; bck=next)
		{
		  de = dr(bck,lh_element);
		  next = de->next;
		  if(!((f)(env,indhdr,de->key,de->value,x))) return;
		}
	  }
    }
}

int hash_buckets(oidtype ht)
{
  struct hashtabcell *T = dr(ht,hashtabcell);

  return T->p + T->maxp_minus_1;
}

oidtype nth_hash_bucket_firstval(oidtype ht, int n)
     /* returns the first value in */
     /* the n:th hashbucket */
{
  struct hashtabcell *T = dr(ht,hashtabcell);
  oidtype directory = T->directory, segment, bck;

  segment = aref(directory,DIRINDEX(n));
  if(segment==nil) return nil;
  bck = aref(segment,SEGINDEX(n));
  if(bck==nil) return nil;
  return dr(bck,lh_element)->value;
}

#define hash_add(x, old) (old + old + old + x)

unsigned int list_hash(oidtype key)
{
  int i=0;
  unsigned int sum=0;

  while(i<10)
    {
      sum = hash_add(compute_hash_key(fhd(key)),sum);
      key = ftl(key);
      if(!listp(key)) return sum;
      i++;
    }
  return sum;
}

unsigned int integer_hash(oidtype key)
{
  return getinteger(key);
}

unsigned int real_hash(oidtype key)
{
  struct {unsigned int lower; unsigned int upper;} r;

  memcpy(&r,dr(key,realcell)->real,sizeof(r));
  return r.upper;
}
 
unsigned int string_hash(oidtype key)
{
  char *str = getstring(key);
  int len = strlen(str);

  return hash_x33_u4(str,len);
}

unsigned int array_hash(oidtype key)
{
  int i, mx=10;
  unsigned int sum=0;
  int sz;
  struct arraycell *arr=dr(key,arraycell);
  
  if(is_adjustable_array(arr)) sz = ((struct adjarraycell *)arr)->size-1;
  else sz = arr->size-1;
  if(sz<mx) mx=sz;
  for(i=0;i<=mx;i++)
    {
      sum = hash_add(compute_hash_key(a_elt(key,i)),sum);
    }
  return sum;
}

/*
 * Index hooks
 */

oidtype hashtable_creator(bindtype env, oidtype indhdr, unsigned int parm)
{
  return new_hashtable(parm);
}

oidtype hashtable_getter(bindtype env, oidtype indhdr, oidtype ht, oidtype key)
{
  oidtype res = get_hashtable(ht,key);

  if(res==NULLH) return nil;
  return res;
}

oidtype hashtable_putter(bindtype env, oidtype indhdr, oidtype ht, oidtype key,
                    oidtype val)
{
  if(val==nil) rem_hashtable(ht,key);
  else put_hashtable(ht,key,val);
  return val;
}

oidtype hashtable_deleter(bindtype env, oidtype indhdr, oidtype ht, 
			  oidtype key)
{
  return rem_hashtable(ht,key);
}

int hashtable_counter(bindtype env, oidtype indhdr, oidtype ht)
{
  return dr(ht,hashtabcell)->elements;
}

void register_hash(void)
{
  struct index_properties hashprops;
  strcpy(hashprops.name,"HASH");
  hashprops.creator=hashtable_creator;
  /*hashprops.dropper=NULL;*/
  hashprops.mapper=map_hashtable;
  hashprops.getter=hashtable_getter;
  hashprops.inserter=hashtable_putter;
  hashprops.deleter=hashtable_deleter;
  hashprops.counter=hashtable_counter;
  define_index_type(hashprops);

  typefns[LISTTYPE].hashfn = list_hash;
  typefns[SYMBOLTYPE].hashfn = NULL;
  typefns[INTEGERTYPE].hashfn = integer_hash;
  typefns[REALTYPE].hashfn = real_hash;
  typefns[EXTFNTYPE].hashfn = NULL;
  typefns[CLOSURETYPE].hashfn = NULL;
  typefns[STRINGTYPE].hashfn = string_hash;
  typefns[ARRAYTYPE].hashfn = array_hash;
  typefns[STREAMTYPE].hashfn = NULL;
  typefns[TEXTSTREAMTYPE].hashfn = NULL;
  typefns[HASHTYPE].hashfn = NULL;
  typefns[HASHTYPE].deallocfn = dealloc_lh;
  typefns[HASHBUCKETTYPE].deallocfn = dealloc_lhelem;
}
