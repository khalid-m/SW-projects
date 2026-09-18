/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: HPT_Drivers.c,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Alisp driver functions of the HP trie (Judy)
 * ===========================================================================
 *
 ****************************************************************************/
#include "HPT_Drivers.h"
#include "judy.h"
#include "Trie_Key.h"

///////////////////
//HPTrie array///// 
///////////////////

//Works for both 64bit and 32 bits
Pvoid_t  HPTries[MaxNumberOfHPTries];//array keeping pointers to HPTries.
int HPTrieIndex=0;//indicates were to put the new trie in HPTries[] array.
void InitializeTrieArray(){
	int i=0;
	for (i=0;i<MaxNumberOfHPTries;i++)
		HPTries[i]=(Pvoid_t)FreeHPTCellIndicator;
}


////////////////////////////////////////////////////////////////////////////////////
//Driver functions to implement make put, get and map for HPTrie
////////////////////////////////////////////////////////////////////////////////////

oidtype make_trie64(bindtype env)
{
	return make_trie(env);
}

//Works for both 64bit and 32 bits
oidtype make_trie(bindtype env){

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
	a_setf(trie_id,mkinteger(HPTrieIndex));
	//printf("making trie %d \n", HPTrieIndex);
	return trie_id;
}

oidtype free_trie64(bindtype env,oidtype TrieID)
{
	int id;//to maintain TrieID
	Word_t bytes_freed;
	uint8_t Key[5]="";
	PWord_t   PValue;			// pointer to array element value
	IntoInteger(TrieID,id,env);
	if (HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//trie is already free, return.
		return nil;
	//Some comments!:
	//before freeing the trie, all the objects it is pointing
	//to in the db image have to be freed first,
	//this might take time, not a good solution...
	//optimal solution is to run this in a background thread

	Key[0] = '\0';					// start with smallest string.

	JSLF(PValue, HPTries[id], Key);       // get first string
    while (PValue != NULL)
    {
        a_free(*(int*)PValue);
        JSLN(PValue, HPTries[id], Key);   // get next string
    }
    JSLFA(bytes_freed, HPTries[id]);              // free array

	HPTries[id]=(Pvoid_t)FreeHPTCellIndicator;//to signal this trie pointer as a free one.
	//printf("freeing trie %d \n", id);
	return nil;
}

oidtype free_trie(bindtype env,oidtype TrieID){
	int id;//to maintain TrieID
	Word_t bytes_freed;
	Word_t Key;
	void * PValue;			// pointer to array element value
	IntoInteger(TrieID,id,env);
	if (HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//trie is already free, return.
		return nil;
	//Some comments!:
	//before freeing the trie, all the objects it is pointing
	//to in the db image have to be freed first,
	//this might take time, not a good solution...
	//optimal solution is to run this in a background thread
	Key=0;
	JLF(PValue, HPTries[id], Key);//starting a full traverse
	while (PValue != NULL)//While there are values in thr trie
	{
		a_free(*(int*)PValue);//free the object stored as value for the key
		JLN(PValue, HPTries[id], Key);
	}	

	JLFA(bytes_freed,HPTries[id]);//freeing the whole array.
	HPTries[id]=(Pvoid_t)FreeHPTCellIndicator;//to signal this trie pointer as a free one.
	//printf("freeing trie %d \n", id);
	return nil;
}

//sxdv is the key
oidtype put_trie64(bindtype args,bindtype env)//args:{[s,1],[x,2],[d,3],[v,4], [TrieID,5], [Value,6]}
{	
	void * PValue;			// pointer to array element value
	int id;//to maintain TrieID
	int Seg,Xp,Dir,Veh; //to maintain compound key elements s,x,d and v
	uint8_t key[5]=""; //maintains trie key transformed from sxdv
	
	IntoInteger(nthargval(args,5),id,env);

	if(HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return without insertion
	{
		printf("HPTrie with id %d does not exist!\n",id);
		return nil;
	}
	IntoInteger(nthargval(args,1),Seg,env);
	IntoInteger(nthargval(args,2),Xp,env);
	IntoInteger(nthargval(args,3),Dir,env);
	IntoInteger(nthargval(args,4),Veh,env);
	
	cons_64_trie_key(Xp,Dir,Seg,Veh,key);//construct/transform the compound key

	//get the current value for the key
	JSLG(PValue, HPTries[id], key);
	
	if (PValue==NULL){ //First time insertion, use "a_let"
		JSLI(PValue, HPTries[id], key) 
		a_let(*(int*)PValue,nthargval(args,6));//Value=nthargval(args,6)
	}
	else{//This is an update, use "a_setf"
		JSLI(PValue, HPTries[id], key) 
		a_setf(*(int*)PValue,nthargval(args,6));//Value=nthargval(args,6)
	}
	return nil;
}

oidtype put_trie(bindtype env, oidtype Key, oidtype TrieID, oidtype Value){
	
	void * PValue;			// pointer to array element value
	int id;//to maintain TrieID
	int k;//to maintain Key

	IntoInteger(TrieID,id,env);
	IntoInteger(Key,k,env);
	if(HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return without insertion
	{
		printf("HPTrie with id %d does not exist!\n",id);
		return nil;
	}
	//get the current value for the key
	JLG(PValue,HPTries[id],(Word_t) k);
	if (PValue==NULL){ //First time insertion, use "a_let"
		JLI(PValue,HPTries[id], (Word_t) k);
		a_let(*(int*)PValue,Value);
	}
	else{//This is an update, use "a_setf"
		JLI(PValue,HPTries[id], (Word_t) k);
		a_setf(*(int*)PValue,Value);
	}
	return nil;
}

oidtype get_trie64(bindtype env, oidtype s,oidtype x,oidtype d,oidtype v, oidtype TrieID)
{
	void * PValue;			// pointer to array element value
	int id;//to maintain TrieID
	int Seg,Xp,Dir,Veh;//to maintain compound key elements s,x,d and v
	uint8_t key[5]="";//maintains trie key transformed from sxdv
	oidtype Val=nil;

	IntoInteger(TrieID,id,env);

	if(HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return nil
	{
		printf("HPTrie with id %d does not exist!\n",id);
		return nil;
	}

	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);
	IntoInteger(v,Veh,env);

	cons_64_trie_key(Xp,Dir,Seg,Veh,key);//construct/transform the compound key

	//get the value associated with the "Key"
	JSLG(PValue, HPTries[id], key);
	if (PValue!=NULL){
		return *(int*)PValue;
	}
	else
		return nil;
}

oidtype get_trie(bindtype env, oidtype Key, oidtype TrieID){
	void * PValue;			// pointer to array element value
	int id;//to maintain TrieID
	int k;//to maintain Key
	oidtype Val=nil;

	IntoInteger(TrieID,id,env);
	IntoInteger(Key,k,env);
	if(HPTries[id]==(Pvoid_t)FreeHPTCellIndicator)//if the trie is freed, return nil
	{
		printf("HPTrie with id %d does not exist!\n",id);
		return nil;
	}
	//get the value associated with the "Key"
	JLG(PValue, HPTries[id], (Word_t) k);
	if (PValue!=NULL){
		return *(int*)PValue;
	}
	else
		return nil;
}

oidtype map_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High, oidtype fn)
{
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

oidtype count_trie64(bindtype env, oidtype TrieID,oidtype s,oidtype x,oidtype d)
{

	uint8_t l[5]="",h[5]="",Index[5]="";//keeps low and high range of the keys associated with s x d *
	int Seg,Xp,Dir;
	int id;//to maintain TrieID
	int cnt=0;
	void * PValue;// pointer to array element value

	IntoInteger(TrieID,id,env);
	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);

	cons_64_trie_key(Xp,Dir,Seg,0,l);//construct value for low bound l
	cons_64_trie_key(Xp,Dir,Seg,16777216,h);//construct value for high bound h (max value for v is 2^24=16777216

	JSLF(PValue, HPTries[id], Index);
	while ((PValue != NULL)//While there are values in [Low High range]
				&& (compare_trie_keys(h,Index)>0))//means Index<= h
	{
		cnt++;
		JSLN(PValue, HPTries[id], Index);
	}

	return mkinteger(cnt);
}

oidtype count_trie(bindtype env, oidtype TrieID,oidtype Low,oidtype High){

	int l,h;//keeps low and high boundries
	int id;//to maintain TrieID
	Word_t   Rc_word;// to maintain the count of elements in the range
	IntoInteger(TrieID,id,env);
	IntoInteger(High,h,env);
	IntoInteger(Low,l,env);
	JLC(Rc_word, HPTries[id], l, h);
	return mkinteger((int)Rc_word);
}

oidtype avg_v_c64(bindtype env,	oidtype s,oidtype x,oidtype d, oidtype min, oidtype trie_vector)
{

	int exp;//the trie that should not be involved
	int id;//keeps the trie ID
	int Seg,Xp,Dir;
	uint8_t l[5]="",h[5]="";//keeps low and high range of the keys associated with s x d *
	void * PValue;// pointer to array element value
	uint8_t Index[5]="";
	register int nxsd;
	register double sum_v_t;
	double sum_avg_v;
	double tmp;
	int mn,i;


	IntoInteger(min,mn,env);
	exp=(mn+1) % HPTWinSize;

	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);
	
	cons_64_trie_key(Xp,Dir,Seg,0,l);//construct value for low bound l
	cons_64_trie_key(Xp,Dir,Seg,16777216,h);//construct value for high bound h (max value for v is 2^24=16777216

	sum_avg_v=0.0;
	tmp=0.0;
	
	for (i=0;i<HPTWinSize;i++){
		if 	(i!=exp){
			IntoInteger(a_elt(trie_vector,i),id,env);//get the trie ID
			//perform a range search in trie
			//start range search by finding smallest key that is greater or equal to "Low" key.
			
			strcpy(Index,l);//instead of Index = l;
			JSLF(PValue, HPTries[id], Index);
			nxsd=0;
			sum_v_t=0.0;
			while ((PValue != NULL)//While there are values in [Low High range]
				&& (compare_trie_keys(h,Index)>0))//means Index<= h
			{
				//no need for the following check, made sure it is always floating point number
				/*if(a_datatype(tl(*(int*)PValue)) == INTEGERTYPE)
					sum_v_t=sum_v_t+(double)getinteger(tl(*(int*)PValue));
				else*/
					sum_v_t=sum_v_t+getreal(tl(*(int*)PValue));

					//printf("getint: %d\n",getinteger(tl(*(int*)PValue)));
					nxsd++;
				//}
				//printf("sum_v_t: %d nxsd: %d\n",sum_v_t,nxsd);
				JSLN(PValue, HPTries[id], Index);
			}
			if (nxsd!=0)
				tmp=sum_v_t/(nxsd);
				//printf("sum_v_t is %.d--nxsd is %d\n",sum_v_t,nxsd);
			else
				tmp=0;
			sum_avg_v=sum_avg_v+tmp;
			//printf("HPTries[id] is %d, trie#%d: sum_v_t is %d nxsd is %d\n",HPTries[id],id,sum_v_t,nxsd);
			//printf("sum_avg_v is %.3f\n",sum_avg_v);
		}
	}
	//printf("result is %E\n",sum_avg_v/(WinSize-1));
	return mkreal(sum_avg_v/(HPTWinSize-1));
}

oidtype avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype trie_vector){
	int exp;//the trie that should not be involved
	int id;//keeps the trie ID
	int l,h;//keeps low and high range of the keys associated with s x d *
	void * PValue;// pointer to array element value
	Word_t Index;
	register int nxsd;
	register double sum_v_t;
	double sum_avg_v;
	double tmp;
	int mn,i;

	IntoInteger(min,mn,env);
	exp=(mn+1) % HPTWinSize;
	
	IntoInteger(trie_low_range(env,range_vector),l,env);
	IntoInteger(trie_high_range(env,range_vector),h,env);
	sum_avg_v=0.0;
	tmp=0.0;
	
	for (i=0;i<HPTWinSize;i++){
		if 	(i!=exp){
			IntoInteger(a_elt(trie_vector,i),id,env);//get the trie ID
			//perform a range search in trie
			//start range search by finding smallest key that is greater or equal to "Low" key.
			Index = (Word_t) l;
			JLF(PValue, HPTries[id], Index);
			nxsd=0;
			sum_v_t=0.0;
			while ((PValue != NULL)//While there are values in [Low High range]
				&& (Index<=(Word_t)h))
			{
				//no need for the following check, made sure it is always floating point number
				/*if(a_datatype(tl(*(int*)PValue)) == INTEGERTYPE)
					sum_v_t=sum_v_t+(double)getinteger(tl(*(int*)PValue));
				else*/
					sum_v_t=sum_v_t+getreal(tl(*(int*)PValue));

					//printf("getint: %d\n",getinteger(tl(*(int*)PValue)));
					nxsd++;
				//}
				//printf("sum_v_t: %d nxsd: %d\n",sum_v_t,nxsd);
				JLN(PValue, HPTries[id], Index);
			}
			if (nxsd!=0)
				tmp=sum_v_t/(nxsd);
				//printf("sum_v_t is %.d--nxsd is %d\n",sum_v_t,nxsd);
			else
				tmp=0;
			sum_avg_v=sum_avg_v+tmp;
			//printf("HPTries[id] is %d, trie#%d: sum_v_t is %d nxsd is %d\n",HPTries[id],id,sum_v_t,nxsd);
			//printf("sum_avg_v is %.3f\n",sum_avg_v);
		}
	}
	//printf("result is %E\n",sum_avg_v/(WinSize-1));
	if (mn<5)
		return mkreal(sum_avg_v/mn);
	else
		return mkreal(sum_avg_v/(HPTWinSize-1));
}

oidtype sumfn(bindtype args,bindtype env)
{
	int sum=0, arity = envarity(args), i, v;
	for(i=1;i<=arity;i++)
	{
		printf("!");
		IntoInteger(nthargval(args,i),v,env);
		sum = sum + v;
	}
	return mkinteger(sum);
}

void Bind_HPT()
{
	InitializeTrieArray();
	extfunction0("make-trie",make_trie);
	extfunction0("make-trie64",make_trie64);
	extfunction1("free-trie",free_trie);
	extfunction1("free-trie64",free_trie64);
	extfunction3("put-trie",put_trie);
	extfunctionn("put-trie64",put_trie64);//supports arity=6
	extfunction2("get-trie",get_trie);
	extfunction5("get-trie64",get_trie64);
	extfunction4("map-trie",map_trie);
	extfunction3("avg-v-c",avg_v_c);
	extfunction5("avg-v-c64",avg_v_c64);
	extfunction3("count-trie",count_trie);
	extfunction4("count-trie64",count_trie64);
	//extfunctionn("SUM",sumfn);
}