/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: judy_mexi_extender.c,v $
 * $Revision: 1.3 $ $Date: 2013/02/28 09:21:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: MEXIMA Extender for Judy index
 * ===========================================================================
 
 *
 ****************************************************************************/
#include <stdio.h>
#include <limits.h>
#include "../../system/C/mexima/mexima.h" /* MEXIMA API */
#include "../../wrappers/trie/SCSQ-trie/Judy-1.0.5/src/judy.h"


typedef struct judyhead_ddd
{     
  Pvoid_t root;               /* judy root */
} judyhead;

typedef struct judy_kvp
{     
  void* key;
  void* value;
} judy_kvp;


//typedef struct judyhead judyhead;

/* Exported initializer function.
   Called by MEXIMA when subsystem initialized.*/
EXPORT void a_initialize_extension(void* xa);
extern void define_index(struct mexi_index_props idxro);

/* Create new Judy index bt */
void *judyintf_create(unsigned int size)
{
	judyhead *jh;

	jh = malloc(sizeof(judyhead));
	jh->root = NULL;
	
	return (void*)(jh);
}

/* Get value for given key in Judy index jh */
void *judyintf_get(void *jh, void *key, mexi_compare cmp)
{	 
	void *pValue = NULL;
	judy_kvp *jkvp = NULL;

	JLG(pValue,((judyhead*)jh)->root, (Word_t) compute_hash_key((oidtype) key));

	if(pValue==NULL)
		return NULL;

	(unsigned int)jkvp = *(unsigned int*)pValue;

	return &(jkvp->value);
}

/* Insert key into Judy index bt. 
   Return pointer to corresponding value for key. 
   Set newflag=TRUE if the key was not there before */
void *judyintf_put(void *jhead, void * key, int *newflag, mexi_compare cmp) 
{
	judy_kvp *jkvp = NULL;
	void *pValue = NULL;
	judyhead *jh;
	Word_t   cnt1, cnt2;
	
	jh=(judyhead *)jhead;
	JLC(cnt1, jh->root, 0, -1);
	
	JLI(pValue,jh->root, compute_hash_key((oidtype) key));	
	
	JLC(cnt2, jh->root, 0, -1);
	printf("cnt 1 = %d while cnt 2 = %d \n", cnt1, cnt2);

	if (cnt1 == cnt2)  // kvp already existing
	{
		//jkvp =  *pValue;
		(unsigned int)jkvp = *(unsigned int*)pValue;

		*newflag = FALSE;	
	} else 
	{
		jkvp = malloc(sizeof(judy_kvp*));
		*(unsigned int *)pValue = (unsigned int)jkvp;

		//*(int *)pValue = 11111;

		*newflag = TRUE;
		jkvp->key = key;		
	}
	return &(jkvp->value); // return a pointer to the cell hosting *value*	
}

/* Delete key from Judy index. 
   If the key exists
     kvp->key = deleted key
     kvp->val = deleted val
     return TRUE;
   Else
     return FALSE;
   */
int judyintf_delete(void *jh, void *key,  struct kv *kvp,  mexi_compare cmpfn) 
{
	void *pValue = NULL;
	judy_kvp *jkvp = NULL;
	int delflag;

	JLG(pValue,((judyhead*)jh)->root, compute_hash_key((oidtype) key));	
	if (pValue == NULL) 
	{
		return FALSE;
	}

	(unsigned int)jkvp = *(unsigned int*)pValue;
	kvp->key = jkvp->key;
	kvp->val= jkvp->value;
	
	// Delete jkvp	
	JLD(delflag, ((judyhead*)jh)->root, compute_hash_key((oidtype) key));
	free(jkvp); 
	return TRUE;
}

/* Deallocate the Judy */
void judyintf_drop(void *jh) 
{
	Word_t bytesfree;
	void *PValue= NULL;
	Word_t Index;
	Pvoid_t root;

	root=((judyhead*)jh)->root;
	
	//free all jkvp objects refered from this index,
	//by performing a complte-range search
	Index = (Word_t) 0;//start the search
	JLF(PValue, root, Index);
	while (PValue != NULL)
	{
		free((judy_kvp *)PValue);
		JLN(PValue, root, Index);
	}

	JLFA(bytesfree,root);//free the judy array
	free(jh); // free Judy head object
}

struct applyMapData
{
  KVPmapper mapfn;
  void* xa;
};

int judymapper(void *kvp, void *xa)
{  
  return TRUE;
}

/* Map over range in Judy index */
void judyinf_range_mapping (void *jh,  KVPmapper mapfn, void *lower, 
			  void *upper, mexi_compare cmpfn, void *xa)
{
	// Sobhan :)
}

/*Total mapper to iterate all items in the index ind*/
void judyintf_full_mapping(void *jh, KVPmapper  mapfn , mexi_compare cmpfn,
			 void *xa)
{
 	// Sobhan :)
}


EXPORT void a_initialize_extension(void *xa)
{   
  struct mexi_index_props idxpros;  

  strcpy(idxpros.name, "JUDY"); /* Name of index */
  idxpros.create = judyintf_create;
  idxpros.get = judyintf_get;
  idxpros.put = judyintf_put;
  idxpros.remove = judyintf_delete;
  idxpros.drop = judyintf_drop;
  idxpros.drange_mapping = judyinf_range_mapping;  
  idxpros.full_mapping = judyintf_full_mapping; 
  idxpros.compare = NULL; /* let mexima decide compare function */
  define_index(idxpros);
}
