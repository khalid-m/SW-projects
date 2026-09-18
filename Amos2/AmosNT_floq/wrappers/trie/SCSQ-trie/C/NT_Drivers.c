/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: NT_Drivers.c,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Alisp driver functions of the Naive trie
 * ===========================================================================
 *
 ****************************************************************************/
#include "NT_Drivers.H"
#include "NT.h"
#include "Trie_Key.h"

///////////////////
//NaiveTrie array// 
///////////////////

Trie*  NaiveTries[MaxNumberOfNTries];//array keeping pointers to Naive Tries.
int NaiveTrieIndex=0;//indicates were to put the new trie in NaiveTries[] array.
void InitializeNaiveTrieArray(){
	int i=0;
	for (i=0;i<MaxNumberOfNTries;i++)
		NaiveTries[i]=(Trie *)FreeNTriesCellIndicator;
}


////////////////////////////////////////////////////////////////////////////////////
//Driver functions to implement make put, get and map for naive_trie
////////////////////////////////////////////////////////////////////////////////////
oidtype make_naive_trie(bindtype env){
	
	int i;
	oidtype trie_id=nil;
	
	//printf("make_naive_trie invoked.\n");
		
	//Find the first free trie ID
	for (i=0;i<MaxNumberOfNTries;i++){
		if (NaiveTries[i]==(Trie*)FreeNTriesCellIndicator)//find first free element in array
			break;
	}
	NaiveTrieIndex=i;

	if (NaiveTries[NaiveTrieIndex]==(Trie*)FreeNTriesCellIndicator)
		NaiveTries[NaiveTrieIndex]=naive_trie_new();//make an empty trie
	else{
		printf("No space for new tries! reached MaxNumberOfTries:%d\n",MaxNumberOfNTries);
		return nil;
	}		
	a_setf(trie_id,mkinteger(NaiveTrieIndex));
//	printf("making Naive trie %d \n", NaiveTrieIndex);
	return trie_id;
}

oidtype free_naive_trie(bindtype env,oidtype TrieID){
	
	int id=0;//to maintain TrieID
	Trie_Node_Element e;

	e.key=0;e.next=NULL;

	IntoInteger(TrieID,id,env);

//printf("free_naive_trie invoked, TrieID:%d.\n",id);
	
	if (NaiveTries[id]==(Trie*)FreeNTriesCellIndicator)//trie is already free, return.
		return nil;
	//Some comments!:
	//before freeing the trie, all the objects it is pointing
	//to in the db image have to be freed first,
	//this might take time, not a good solution...
	//optimal solution is to run this in a background thread

    e=naive_trie_next(NaiveTries[id],0);//starting a full traverse
    while (e.next!=NULL){
        //printf("e.key: %d e.next: %d\n",e.key,*(int*)e.next);

		//TBC:Check if it works properly...
		if (e.next!=NULL)
			a_free((oidtype)e.next);//free the object stored as value for the key TBCALL
        e=naive_trie_next((Trie*) NaiveTries[id],e.key+1);
    }
	naive_trie_free(NaiveTries[id]->root_node); //free the space used by trie nodes.
	NaiveTries[id]=(Trie*)FreeNTriesCellIndicator;//to signal this trie pointer as a free one.
	return nil;
}


oidtype put_naive_trie(bindtype env, oidtype Key, oidtype TrieID, oidtype Value){
	
	int id=0;//to maintain TrieID
	int k=0;//to maintain Key
	int* prev_val=NULL;//to hold pointer to the value already present.
//	int* tmp;
	Trie_Node_Element* NewElem=NULL;

	IntoInteger(TrieID,id,env);
	IntoInteger(Key,k,env);
	
//	printf("put_naive_trie invoked: %d %d %d\n",id,k,Value);
	
	if(NaiveTries[id]==(Trie*)FreeNTriesCellIndicator)//if the trie is freed, return without insertion
		return nil;
	//get the current value for the key
	prev_val=naive_trie_lookup(NaiveTries[id],k);
//	printf("lookup success\n");
	if (prev_val==NULL){ //First time insertion, use "a_let"
		NewElem=naive_trie_insert(NaiveTries[id],k);
//		printf("putting (a_let) Value:%d in NewElem:%d\n",Value,NewElem);
		a_let((oidtype)(NewElem->next),Value);
	}
	else{//This is an update, use "a_setf"
		
		NewElem=naive_trie_insert(NaiveTries[id],k);
//		printf("putting (a_setf) Value:%d in NewElem->next:%d\n",Value,(oidtype) NewElem->next);
		a_setf((oidtype)(NewElem->next),Value);
//		printf("\na_setf!*(int*)val:%d, (int*)val:%d, *prev_val:%d\n",*(int*)val,(int*)val,*prev_val);
	}
	return nil;
}

oidtype get_naive_trie(bindtype env, oidtype Key, oidtype TrieID){
	int * pval=NULL;
	int id=0;//to maintain TrieID
	int k=0;//to maintain Key
	oidtype Val=nil;

	

	IntoInteger(TrieID,id,env);
	IntoInteger(Key,k,env);

//	printf("get_naive_trie invoked:<id,key><%d,%d>\n",id,k);

	if(NaiveTries[id]==(Trie*)FreeNTriesCellIndicator)//if the trie is freed, return nil
		return nil;
	//get the value associated with the "Key"
	pval=naive_trie_lookup(NaiveTries[id],k);
	if (pval!=NULL){
//		printf("\nget_naive_trie invoked: %d\n",pval);
		return (oidtype) pval;
	}
	else
//		printf("\nget_naive_trie invoked: nil\n");
		return nil;
}

oidtype map_naive_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High, oidtype fn)
{
	oidtype res=nil, key = nil, val=nil;//keeps <key val> pair to be returned
	int l=0,h=0;//keeps low and high boundries
	int id=0;//to maintain TrieID
	Trie_Node_Element e;
	
	e.key=0;
	e.next=NULL;
	
//	printf("map_naive_trie invoked.\n");

	IntoInteger(TrieID,id,env);
	IntoInteger(High,h,env);
	IntoInteger(Low,l,env);
		
	{unwind_protect_begin;
		
	e=naive_trie_next(NaiveTries[id],l);
	while ((e.next != NULL)//While there are values in [Low High range]
		&& (e.key<=h))
	{
		a_setf(res,call_lisp(fn,env,2, mkinteger(e.key),e.next));//TBCALL
		e=naive_trie_next(NaiveTries[id],e.key+1);
	}

	unwind_protect_catch;
	a_free(res);
	a_free(key);
	a_free(val);
	unwind_protect_end;
	}
	return nil;
}

oidtype count_naive_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High){

	int l=0,h=0;//keeps low and high boundries
	int id=0;//to maintain TrieID
	Trie_Node_Element e;
	register int cnt=0;

	e.key=0;
	e.next=NULL;

//	printf("count_naive_trie invoked.\n");

	IntoInteger(TrieID,id,env);
	IntoInteger(High,h,env);
	IntoInteger(Low,l,env);
	cnt=0;

    e=naive_trie_next(NaiveTries[id],l);
    while (e.next!=NULL && e.key<=h){
		cnt++;
		e=naive_trie_next((Trie*) NaiveTries[id],e.key+1);
    }
	
	return mkinteger(cnt);
}

oidtype naive_avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype trie_vector){

	int exp=0;//the trie that should not be involved
	int id=0;//keeps the trie ID
	int l=0,h=0;//keeps low and high range of the keys associated with s x d *
	register int nxsd=0;
	register double sum_v_t=0.0;
	double sum_avg_v=0.0;
	double tmp=0.0;
	int mn=0,i=0;
	Trie_Node_Element e;
	
	e.key=0;
	e.next=NULL;

	IntoInteger(min,mn,env);
	exp=(mn+1) % NTriesWinSize;
	
//	printf("naive_avg_v_c invoked,min:%d\n",mn);
	
	IntoInteger(trie_low_range(env,range_vector),l,env);
	IntoInteger(trie_high_range(env,range_vector),h,env);
	sum_avg_v=0.0;
	tmp=0.0;
	
	for (i=0;i<NTriesWinSize;i++){
		if 	(i!=exp){
			
			IntoInteger(a_elt(trie_vector,i),id,env);//get the trie ID
			
			//perform a range search in trie
			//start range search by finding smallest key that is greater or equal to "Low" key.
			e=naive_trie_next(NaiveTries[id], l);
			nxsd=0;
			sum_v_t=0.0;

			while ((e.next != NULL)//While there are values in [Low High range]
				&& (e.key<=h))
			{
				//The following assumes that tails of value is always a real number.
				sum_v_t=sum_v_t+getreal(tl((oidtype)e.next));//TBCALL
				nxsd++;
				e=naive_trie_next(NaiveTries[id], e.key+1);
			}
			if (nxsd!=0)
				tmp=sum_v_t/(nxsd);
			else
				tmp=0;
			sum_avg_v=sum_avg_v+tmp;
		}
	}
	//printf("naive_avg_v_c result:%E\n",sum_avg_v/(WinSize-1));
	if (mn<5)
		return mkreal(sum_avg_v/mn);
	else
	return mkreal(sum_avg_v/(NTriesWinSize-1));
}

void Bind_NT()
{
	InitializeNaiveTrieArray();
	extfunction0("make-naive-trie",make_naive_trie);
	extfunction1("free-naive-trie",free_naive_trie);
	extfunction3("put-naive-trie",put_naive_trie);
	extfunction2("get-naive-trie",get_naive_trie);
	extfunction4("map-naive-trie",map_naive_trie);
	extfunction3("naive-avg-v-c",naive_avg_v_c);
	extfunction3("count-naive-trie",count_naive_trie);
}