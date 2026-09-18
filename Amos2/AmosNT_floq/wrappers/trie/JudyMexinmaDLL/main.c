/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: main.c,v $
 * $Revision: 1.2 $ $Date: 2012/01/12 07:50:56 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Main entry for HP Tries (Judy) as a DLL
 * ===========================================================================
 * $Log: main.c,v $
 * Revision 1.2  2012/01/12 07:50:56  thatr500
 * changed signature a_initialize_extension
 *
 * Revision 1.1  2011/08/24 04:48:24  soba1559
 * added Hp trie (Judy) dll based Mexinma extension
 *
 * Revision 1.7  2011/05/02 06:20:42  thatr500
 * used a_initialize_extension and a_load_extension
 *
 * Revision 1.6  2011/04/29 13:28:56  thatr500
 * modified BT and Linh to compile them on Unix
 *
 * Revision 1.5  2011/04/27 15:52:35  thatr500
 * removed BT_computekey as BT does not compute anything from original key.
 *
 * Revision 1.4  2011/04/24 12:28:38  thatr500
 * defined ex_index_routines struct
 *
 * Revision 1.3  2011/04/23 12:26:08  thatr500
 * added comparefn into BTget, BTdelete, BTmap0
 *
 * Revision 1.2  2011/04/20 20:45:52  thatr500
 * *** empty log message ***
 *
 * Revision 1.1  2011/04/19 17:06:13  thatr500
 * add BT as a dll
 *
 ****************************************************************************/

#include <stdio.h>
#ifdef WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif

#include <limits.h>
#include "Judy.h"
#include "dll.h"
#include "alisp.h"

#define COMPARE_MAYBE(fn) (fn);
/*--------------------------------------------------------------*/

void InitializeTrieArray(){
	int i=0;
	for (i=0;i<MaxNumberOfHPTries;i++)
		HPTries[i]=(Pvoid_t)FreeHPTCellIndicator;
}

oidtype HPT_make(void) {
	
	int i;
	oidtype trie_id=nil;
	//Find the first free trie ID
	for (i=0;i<MaxNumberOfHPTries;i++){
		if (HPTries[i]==(Pvoid_t)FreeHPTCellIndicator)//find first free element in array
			break;
	}
	HPTrieIndex=i;

	if (HPTries[HPTrieIndex]==(Pvoid_t)FreeHPTCellIndicator)
		HPTries[HPTrieIndex]=(Pvoid_t) NULL;//make an empty trie
	else{
		printf("No space for new tries! reached MaxNumberOfTries:%d\n",MaxNumberOfHPTries);
		return nil;
	}		
	//a_setf(trie_id,mkinteger(HPTrieIndex));
	//printf("making trie %d \n", HPTrieIndex);
	return HPTrieIndex;
}
/*--------------------------------------------------------------*/
oidtype HPT_put(int TrieID, oidtype Key, oidtype Value, ExinmaCompareKeyFunc cmpfn) {
/*
	if (bhs[btid] == NULL) {
    bhs[btid] = newBThead();  	  
  }  
  BTinsert(bhs[btid], (BTdata) key, (BTdata) val, ((BTcomparer) cmpfn)); 
  */
	void * PValue;			// pointer to array element value
	int k;//to maintain Key
	
	k=getinteger(Key);
	if(HPTries[TrieID]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return without insertion
	{
		printf("HPTrie with id %d does not exist!\n",TrieID);
		return nil;
	}
	JLG(PValue,HPTries[TrieID],(Word_t) k);
	//a_assign(*(int*)PValue,Value);

	if (PValue==NULL){ //First time insertion, use "a_let"
		JLI(PValue,HPTries[TrieID], (Word_t) k);
		a_let(*(int*)PValue,Value);
	}
	else{//This is an update, use "a_setf"
		JLI(PValue,HPTries[TrieID], (Word_t) k);
		a_setf(*(int*)PValue,Value);
	}

	return Value;

}
/*--------------------------------------------------------------*/
oidtype HPT_get(int TrieID, oidtype Key, ExinmaCompareKeyFunc cmpfn) {	
 
	void * PValue;		// pointer to array element value
	int k;				//to maintain Key
	
	k=getinteger(Key);

	if(HPTries[TrieID]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return nil
	{
		printf("HPTrie with id %d does not exist!\n",TrieID);
		return nil;
	}
	
	JLG(PValue, HPTries[TrieID], (Word_t) k);
	if (PValue!=NULL){
		return *(int*)PValue;
	}
	else
		return nil;
}
/*--------------------------------------------------------------*/
oidtype HPT_delete(int TrieID, oidtype Key, ExinmaCompareKeyFunc cmpfn) {

	int k;				//to maintain Key
	int Rc_int;			// return code - integer

	
	k=getinteger(Key);
	
	
	if(HPTries[TrieID]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return nil
	{
		printf("HPTrie with id %d does not exist!\n",TrieID);
		return nil;
	}

	JLD(Rc_int, HPTries[TrieID], k);
	if (Rc_int==JERR){
		printf("Problem with delletion of %d from trieid %d!\n",k,TrieID);
	}
	
	//printf("%d Deleted!\n",k );

	return nil;

  
}


oidtype map_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High, oidtype fn)
{
	//implements the range search

	void * PValue;			// pointer to array element value
	Word_t Index;
	oidtype res=nil, key = nil, val=nil;//keeps <key val> pair to be returned
	int l,h;//keeps low and high boundries
	int id;//to maintain TrieID
	IntoInteger(TrieID,id,env);
	IntoInteger(High,h,env);
	IntoInteger(Low,l,env);
	//This is to maintain the root pointer even if the image is expanded (not needed, Tries are not in image!)
	#define trie_root HPTries[id]
	{unwind_protect_begin;
		
	Index = (Word_t) l;//start range search by finding "Low" key
	JLF(PValue, trie_root, Index);
	while ((PValue != NULL)//While there are values in [Low High range]
		&& (Index<=(Word_t)h))
	{
		//TBD:Investigate if mkinteger creates memory leak?
		//this is wrong, it has to return the value as oidtype, not an int
		a_setf(res,call_lisp(fn,env,2, mkinteger(Index),*(int*)PValue));
		JLN(PValue, trie_root, Index);
	}

	unwind_protect_catch;
	a_free(res);
	a_free(key);
	a_free(val);
	unwind_protect_end;
	}
	return nil;
}



/*--------------------------------------------------------------*/
oidtype HPT_clear(int TrieID) {

	Word_t   Rc_word;                         // return code - unsigned word
	
	JLFA(Rc_word, HPTries[TrieID]);
	
	printf("%d bytes freed\n",Rc_word);

	HPTries[TrieID]=(Pvoid_t)FreeHPTCellIndicator;//to signal this trie pointer as a free one.

	return nil;
}

/*--------------------------------------------------------------*/
void HPT_mapper(int btid, ExinmaMappingFunc f, ExinmaCompareKeyFunc cmpfn, void *xa) {
  // root, lower, upper, mapfunction, comparefn, 
  //BTmap0(bhs[btid]->root, (BTdata) nil, INT_MAX, NULL, f, ((BTcomparer) cmpfn), xa);
}
/*--------------------------------------------------------------*/
int HPT_comparekey(oidtype key1, oidtype key2) {
	//return COMPARE(key1, key2);
	if(key1 == nil) {
		return -1;
	}
	if (key2 == INT_MAX) {
		return -1;
	}	
	return a_compare(key1, key2); 	
}

/*--------------------------------------------------------------*/
void a_initialize_extension(void *xa) {
	struct ex_index_routines rot;
	HPTrieIndex = 0;
	rot.exCreateFn = HPT_make;
	rot.exPutFn = HPT_put;
	rot.exGetFn = HPT_get;
	rot.exDeleteFn = HPT_delete;
	rot.exClearFn = HPT_clear;
	rot.exMapperFn = HPT_mapper;
	rot.exComputeKeyFn = NULL;
	rot.exCompareKeyFn = HPT_comparekey;
	rot.exSaveFn = NULL;
	rot.exLoadFn = NULL;

	define_ex_index_type("HPTRIE", rot);

	extfunction4("map-hptrie",map_trie);//makes the range search available to Amos
	amosql("load_lisp('hpt-rewrite.lsp');",FALSE);
	InitializeTrieArray();
}
