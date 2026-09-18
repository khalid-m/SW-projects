/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: BT_Drivers.c,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Alisp driver functions of th B-tree
 * ===========================================================================
 *
 ****************************************************************************/

#include "BT_Drivers.h"
#include "Trie_Key.h"
#include <math.h>


///////////////////
//Btree array///// 
///////////////////
void InitializeBTArray(){
	int i=0;
	for (i=0;i<MaxNumberOfBTrees;i++)
		Btrees[i]=(BThead*)FreeBTCellIndicator;
}



////////////////////////////////////////////////////////////////////////////////////
//Driver functions to implement make put, get and map for BTres
////////////////////////////////////////////////////////////////////////////////////

oidtype make_BT(bindtype env)
{
	int i;
	oidtype BT_id=nil;
	//Find the first free BTree ID
	for (i=0;i<MaxNumberOfBTrees;i++){
		if (Btrees[i]==(BThead*)FreeBTCellIndicator)//find first free element in array
			break;
	}
	BTIndex=i;

	if (Btrees[BTIndex]==(BThead*)FreeBTCellIndicator)
		Btrees[BTIndex]=newBThead();//make an empty BTree
	else{
		printf("No space for new BTrees! reached MaxNumberOfBTrees:%d\n",MaxNumberOfBTrees);
		return nil;
	}		
	a_setf(BT_id,mkinteger(BTIndex));
	//printf("making Btree %d \n", BTIndex);
	return BT_id;
}

oidtype free_BT(bindtype env,oidtype BTID)
{
	int id;//to maintain BTID
	int MAXINT=2147483647;// this is the biggest value for a signed int TBD:

	IntoInteger(BTID,id,env);
	if (Btrees[id]==(BThead*)FreeBTCellIndicator)//Btree is already free, return.
		return nil;
	//Some comments!:
	//before freeing the Btree, all the objects it is pointing
	//to in the db image have to be freed first,
	//this might take time, not a good solution...
	//optimal solution is to run this in a background thread

	//1- loop through all items and free them in Amos 
	BTmap0(Btrees[id]->root,0,MAXINT,BTFreeMapper,compareBTdata,NULL);
	//2- Free the whole BTree
	freeBThead(Btrees[id]);

	Btrees[id]=(BThead*)FreeBTCellIndicator;//to signal this BTree pointer as a free one.

	return nil;
}

oidtype put_BT64(bindtype args,bindtype env)//args:{[s,1],[x,2],[d,3],[v,4],[Min,5] [BtreeID,6], [Value,7]}
{	
	BTitem * PValue;	// pointer to BTree item
	int id;//to maintain BtreeID
	int Seg,Xp,Dir,Veh,Min; //to maintain compound key elements s,x,d and v
	BTdata key=0; //maintains Btree key transformed from sxdv
	
	IntoInteger(nthargval(args,6),id,env);

	if(Btrees[id]==(BThead*)FreeBTCellIndicator)//if the BTree is freed, return without insertion
	{
		printf("Btree with id %d does not exist!\n",id);
		return nil;
	}

	IntoInteger(nthargval(args,1),Seg,env);
	IntoInteger(nthargval(args,2),Xp,env);
	IntoInteger(nthargval(args,3),Dir,env);
	IntoInteger(nthargval(args,4),Veh,env);
	IntoInteger(nthargval(args,5),Min,env);
	
	cons_64_BT_key(Min,Xp,Dir,Seg,Veh,&key);//construct/transform the compound key

	//get the current value for the key
	PValue=BTget(Btrees[id], key);

//debug prints
/*	printf("Veh is:\n");
	bin_prnt_int(Veh);
	printf("Key to be inserted is:\n");
	bin_prnt_int64(key);
*/	
	PValue=BTinsert(Btrees[id],key,nil,NULL);
	
	if (PValue==NULL)//First time insertion, use "a_let"
	{a_let(PValue->data.value,nthargval(args,7));}//Value=nthargval(args,7)
	else//This is an update, use "a_setf"
	{a_setf((unsigned int)PValue->data.value,nthargval(args,7));}//Value=nthargval(args,7)
	return nil;
}

oidtype put_BT(bindtype env, oidtype Key, oidtype BTID, oidtype Value)
{
	BTitem * PValue;	// pointer to BTree item
	int id;//to maintain BTID
	int k;//to maintain Key

	IntoInteger(BTID,id,env);
	IntoInteger(Key,k,env);
	
	if(Btrees[id]==(BThead*)FreeBTCellIndicator)//if the BTree is freed, return without insertion
	{
		printf("Btree with id %d does not exist!\n",id);
		return nil;
	}
	//get the current value for the key
	PValue=BTget(Btrees[id], k);
	if (PValue==NULL){ //First time insertion, use "a_let"
		PValue=BTinsert(Btrees[id],k,nil,NULL);
		a_let(PValue->data.value,Value);
	}
	else{//This is an update, use "a_setf"
		PValue=BTinsert(Btrees[id],k,nil,NULL);
		a_setf((unsigned int)PValue->data.value,Value);
	}
	return nil;
}

oidtype get_BT64(bindtype args,bindtype env)//args:{[s,1],[x,2],[d,3],[v,4],[Min,5] [BtreeID,6]}
{	
	BTitem * PValue;	// pointer to BTree item
	int id;//to maintain BtreeID
	int Seg,Xp,Dir,Veh,Min; //to maintain compound key elements s,x,d and v
	BTdata key=0; //maintains Btree key transformed from sxdv
//debug
//	printf("get_BT64 invoked!\n");
	IntoInteger(nthargval(args,6),id,env);

	if(Btrees[id]==(BThead*)FreeBTCellIndicator)//if the BTree is freed, return without insertion
	{
		printf("Btree with id %d does not exist!\n",id);
		return nil;
	}

	IntoInteger(nthargval(args,1),Seg,env);
	IntoInteger(nthargval(args,2),Xp,env);
	IntoInteger(nthargval(args,3),Dir,env);
	IntoInteger(nthargval(args,4),Veh,env);
	IntoInteger(nthargval(args,5),Min,env);
	
	cons_64_BT_key(Min,Xp,Dir,Seg,Veh,&key);//construct/transform the compound key

	//get the current value for the key
	PValue=BTget(Btrees[id], key);
	
	if (PValue!=NULL){
		return (unsigned int)PValue->data.value;
	}
	else
		return nil;
}

oidtype get_BT(bindtype env, oidtype Key, oidtype BTID)
{
	BTitem * PValue;	// pointer to BTree item
	int id;//to maintain BTID
	int k;//to maintain Key
	oidtype Val=nil;

	IntoInteger(BTID,id,env);
	IntoInteger(Key,k,env);

	if(Btrees[id]==(BThead*)FreeBTCellIndicator)//if the BTree is freed, return without insertion
	{
		printf("Btree with id %d does not exist!\n",id);
		return nil;
	}
	//get the value associated with the "Key"
	PValue=BTget(Btrees[id], (BTdata) k);
	if (PValue!=NULL){
		return (unsigned int)PValue->data.value;
	}
	else
		return nil;
}

oidtype BT_avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype BT_vector){
	int exp;//the BTree that should not be involved
	int id;//keeps the BTree ID
	int l,h;//keeps low and high range of the keys associated with s x d *

	double sum_avg_v;// keeps the sum of avg_vs in all b-tree
	int mn,i;
	IntoInteger(min,mn,env);
	exp=(mn+1) % BTWinSize;
	
	IntoInteger(trie_low_range(env,range_vector),l,env);
	IntoInteger(trie_high_range(env,range_vector),h,env);
	sum_avg_v=0.0;
	
	for (i=0;i<BTWinSize;i++){
		if 	(i!=exp){
			IntoInteger(a_elt(BT_vector,i),id,env);//get the B-tree ID
			//Get the average of values from the b-tree in the range [l,h]
			//printf("here0 btid:%d,l:%d,h:%d\n",id,l,h);
			sum_avg_v=sum_avg_v+BTAvgVelocity(Btrees[id],l,h);
			//printf("BTAvg: %.3fBTCount: %d\n",BTAvg(Btrees[id],l,h),BTCount(Btrees[id],l,h));

		}
	}
	//printf("result is %E\n",sum_avg_v/(WinSize-1));
	if (mn<5)
		return mkreal(sum_avg_v/mn);
	else

	return mkreal(sum_avg_v/(BTWinSize-1));
}

// this function returns avg-v for 64 bit keys in the 'bulk maintenance' approach
//keys setting:[mn,x,d,s,v]

oidtype BT_avg_v_c64_bulk(bindtype env,	oidtype s,oidtype x,oidtype d,oidtype min, oidtype BT_vector)
{
	int exp;//the BTree that should not be involved
	int id;//keeps the BTree ID
	BTdata l,h;//keeps low and high range of the keys associated with s x d *

	double sum_avg_v;// keeps the sum of avg_vs in all b-tree
	int i;
	int Seg,Xp,Dir,mn,MAXVehID;


	IntoInteger(min,mn,env);
	exp=(mn+1) % BTWinSize;

	MAXVehID=(int)pow(2,24)-1;

//	IntoInteger(BTID,id,env);
	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);

	cons_64_BT_key(0,Xp,Dir,Seg,0,&l);//passing 0 as minute to discard the time stamp
	cons_64_BT_key(0,Xp,Dir,Seg,MAXVehID,&h);

	sum_avg_v=0.0;
	
	for (i=0;i<BTWinSize;i++){
		if 	(i!=exp){
			IntoInteger(a_elt(BT_vector,i),id,env);//get the B-tree ID
			//Get the average of values from the b-tree in the range [l,h]
			//printf("here0 btid:%d,l:%d,h:%d\n",id,l,h);

			sum_avg_v=sum_avg_v+BTAvgVelocity(Btrees[id],l,h);
			//printf("BTAvg: %.3fBTCount: %d\n",BTAvg(Btrees[id],l,h),BTCount(Btrees[id],l,h));

		}
	}
	//printf("result is %E\n",sum_avg_v/(WinSize-1));
	if (mn<5)
		return mkreal(sum_avg_v/mn);
	else

	return mkreal(sum_avg_v/(BTWinSize-1));


}

// this function returns avg-v for 64 bit keys in the 'incremental maintenance' approach
//keys setting:[mn,x,d,s,v]

oidtype BT_avg_v_c64(bindtype env,	oidtype s,oidtype x,oidtype d,oidtype min, oidtype BTID)
{
	int id=0;//keeps the BTree ID
	int Seg,Xp,Dir,mn,MAXVehID;
	int startmin=0,endmin=0,i=0,cnt=0;
	BTdata l,h;//keeps low and high range of the keys associated with [mn * * * *]
	double sum_avg_v=0.0;// keeps the sum of avg_vs in all b-tree

	MAXVehID=(int)pow(2,24)-1;

	IntoInteger(min,mn,env);
	IntoInteger(BTID,id,env);
	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);


	if (mn<BTWinSize-1)
	{
		for (i=1;i<=mn;i++)
		{
			cons_64_BT_key(i,Xp,Dir,Seg,0,&l);
			cons_64_BT_key(i,Xp,Dir,Seg,MAXVehID,&h);

			sum_avg_v+=BTAvgVelocity(Btrees[id],l,h);
			cnt++;
		}
		//
	}
	else
	{
		startmin= mn-(BTWinSize-2);//Note that BTWinSize=6
		endmin=mn;//Note that BTWinSize=6
		for (i=startmin;i<=endmin;i++)
		{
			cons_64_BT_key(i,Xp,Dir,Seg,0,&l);
			cons_64_BT_key(i,Xp,Dir,Seg,MAXVehID,&h);

			sum_avg_v+=BTAvgVelocity(Btrees[id],l,h);
		}
		cnt=5;
	}
/*	printf("the range:\n");
	bin_prnt_int64(l);
	bin_prnt_int64(h);

	printf("Total count:%d\n",BTCount(Btrees[id],0,(__int64)pow(2,64)-1));
	printf("count in range:%d\n",BTCount(Btrees[id],l,h));
	printf("sum in range:%d\n",BTSum(Btrees[id],l,h));
*/	//printf("result is %E\n",sum_avg_v/(WinSize-1));
	if (cnt<=0)
		return mkreal(sum_avg_v);
	else
	return mkreal(sum_avg_v/cnt);
}

//TBD: move the following line to header file.
void BTBulkDel(BThead *bh, BTdata low,BTdata high);

oidtype BT_bulk_del(bindtype env, oidtype min, oidtype winsize, oidtype BTID)
{
	int id=0;//keeps the BTree ID
	int mn,MAX32int,WindowSize;
	BTdata l=0,h=0;//keeps low and high range of the keys associated with [mn * * * *]

//	printf("BT_bulk_del invoked!\n");

	MAX32int=(int)pow(2,32)-1;
	IntoInteger(min,mn,env);
	IntoInteger(BTID,id,env);
	IntoInteger(winsize,WindowSize,env);
	//first clear any junk present in the tree that might be for minute mn
	cons_64_BT_key(mn,0,0,0,0,&l);
	cons_64_BT_key(mn,127,1,255,(int)pow(2,24)-1,&h);//max values for x d s v
//	bin_prnt_int64(l);
//	bin_prnt_int64(h);
//	printf("Total count after deletion:%d\n",BTCount(Btrees[id],0,(__int64)pow(2,64)-1));
//	printf("count before deletion:%d\n",BTCount(Btrees[id],l,h));
	BTBulkDel(Btrees[id],l,h);

	//Now remove the old data
	if (mn-(WindowSize+1)<0)
		return nil;
	else
	{
		cons_64_BT_key(mn-(WindowSize+1),0,0,0,0,&l);
		cons_64_BT_key(mn-(WindowSize+1),127,1,255,(int)pow(2,24)-1,&h);//max values for x d s v
		BTBulkDel(Btrees[id],l,h);
	}



	return nil;


}

oidtype count_BT64(bindtype env, oidtype BTID, oidtype s,oidtype x,oidtype d,oidtype mn)
{
	int Seg,Xp,Dir,Min; //to maintain compound key elements s,x,d and v
	BTdata l=0,h=0;//keeps low and high boundries
	int id;//to maintain TrieID

	IntoInteger(BTID,id,env);
	if(Btrees[id]==(BThead*)FreeBTCellIndicator)//if the BTree is freed, return without insertion
	{
		printf("Btree with id %d does not exist!\n",id);
		return nil;
	}

	IntoInteger(s,Seg,env);
	IntoInteger(x,Xp,env);
	IntoInteger(d,Dir,env);
	IntoInteger(mn,Min,env);
//	if (Min==0)
//		Min=1;
	cons_64_BT_key(Min,Xp,Dir,Seg,0,&l);
	cons_64_BT_key(Min,Xp,Dir,Seg,(int)pow(2,24)-1,&h);

	return mkinteger(BTCount(Btrees[id],l,h));
}

oidtype count_BT(bindtype env, oidtype BTID, oidtype Low,oidtype High)
{
	int l,h;//keeps low and high boundries
	int id;//to maintain TrieID
	IntoInteger(BTID,id,env);
	IntoInteger(High,h,env);
	IntoInteger(Low,l,env);
	return mkinteger(BTCount(Btrees[id],l,h));
}

int BTBulkDelMapper(BTitem *bi, void *xa)
{
	BTdata* buffer;

	buffer=(BTdata*)xa;

	a_free((unsigned int)bi->data.value);//free the memory block that is kept in Amos for the object(value)
	buffer[DelBuffIndex]=bi->data.key;//put it in DelBuffer array to be deleted later
	DelBuffIndex++;

	if (DelBuffIndex==DelBuffSize)
		return FALSE;//signalling that buffer is full, stop mapping
	else
		return TRUE;//contuniue mapping
}
int BTFreeMapper(BTitem *bi, void *xa)
{
	//free the memory block that is kept in Amos for the object(value)
	a_free((unsigned int)bi->data.value);
	return TRUE;
}

//this is specific mapper for linear road benchmark avgv function calculations
int BTAvgVelocityMapper(BTitem *bi, void *xa)
{
	//BTavgDS * avgDS;
	
	//avgDS=(BTavgDS *)xa;
	((BTavgDS *)xa)->sum+= getreal(tl((unsigned int)bi->data.value));
	((BTavgDS *)xa)->cnt++;
//debugging
//	printf("[Mapper] %d %f\n",avgDS->cnt,getreal(tl((unsigned int)bi->data.value)));
	return TRUE;
}

double BTAvgVelocity(BThead *bh, BTdata low,BTdata high)
{
	BTavgDS container;
	container.cnt=0;
	container.sum=0.0;
	BTmap0(bh->root,low,high,BTAvgVelocityMapper,compareBTdata,(void *)&container);
	
	if (container.cnt!=0)
	{
		//printf("cnt:%d,total count:%d\n",container.cnt,BTCount(bh,0,(BTdata)pow(2,64)-1));
		return container.sum/container.cnt;
	}
	else
		return 0.0;
}

void BTBulkDel(BThead *bh, BTdata low,BTdata high)
{
	int i;
	BTdata DelBuffer[DelBuffSize];

//	printf("BTBulkDel invoked low=%I64d high=%I64d\n",low, high);
//	bin_prnt_int64(low);
//	bin_prnt_int64(high);
//	printf("\n\nTotal count before deletion:%d\n",BTCount(bh,0,(BTdata)pow(2,64)-1));
	while(1)
	{
		DelBuffIndex=0;
		BTmap0(bh->root,low,high,BTBulkDelMapper,compareBTdata,(void *)DelBuffer);
		
		if (DelBuffIndex==0)
			break;//nothing was put in the buffer, no key is left in [low,high] range
		//printf("%d items to be removed\n",DelBuffIndex);
		for(i=0;i<DelBuffIndex;i++)//delete all items that have been put in buffer for deletion
			BTdelete(DelBuffer[i],bh);
		
		//printf("Total count after deletion:%d\n",BTCount(bh,0,(__int64)pow(2,64)-1));
	}
//	printf("Total count after deletion:%d\n",BTCount(bh,0,(BTdata)pow(2,64)-1));
	return;
}

void test_BT_mappers()
{
	BThead* bt1;
	int sum,count;
	double average;
	BTitem* nxt=NULL;
	BTdata btd=0;
	
	bt1=newBThead();

	BTinsert(bt1,11,11,NULL);
	BTinsert(bt1,21,22,NULL);
	//BTinsert(bt1,3,33,NULL);
	BTinsert(bt1,14,44,NULL);
	BTinsert(bt1,25,55,NULL);
	BTinsert(bt1,68,66,NULL);
	BTinsert(bt1,16,66,NULL);
	BTinsert(bt1,26,66,NULL);

	sum=BTSum(bt1,1,6);
	count=BTCount(bt1,1,6);
	average=BTAvg(bt1,12,6);
	

	btd=13;
	nxt=BTnext(bt1,&btd);
	while (nxt&&nxt->data.key<=26)
	{
		printf("<Key,Value> of next is <%d,%d> btd is %d\n",nxt->data.key,nxt->data.value,btd);
		nxt=BTnext(bt1,&btd);
	}

}


void Bind_BT()
{
	DelBuffIndex=0;
	BTIndex=0;
	InitializeBTArray();
	extfunction0("make-BT",make_BT);
	extfunction1("free-BT",free_BT);
	extfunctionn("put-BT64",put_BT64);
	extfunction3("put-BT",put_BT);
	extfunctionn("get-BT64",get_BT64);
	extfunction2("get-BT",get_BT);
	extfunction5("BT-avg-v-c64",BT_avg_v_c64);
	extfunction5("BT-avg-v-c64-bulk",BT_avg_v_c64_bulk);
	extfunction3("BT-avg-v-c",BT_avg_v_c);
	extfunction5("count-BT64",count_BT64);
	extfunction3("count-BT",count_BT);
	extfunction3("BT-bulk-del",BT_bulk_del);
}
//////////////////stupid stuff!!!

/*
//add this in the header
int freeBTnode_stupid(BTnode *node);
int freeBThead_stupid(BThead *bt);
*/

/*
int freeBTnode_stupid(BTnode *node)
{
  unsigned int i, cnt=0;
  BTitem* bip;

  if(node->p0 != NULL) cnt = cnt + freeBTnode_stupid(node->p0);
  for(i=0;i<node->m;i++)
    {
      BTitem bi = node->e[i];
	  bip=&(node->e[i]);
	  
	  //added by Sobhan: free (in DB image) the underlying Amos object.
	  //printf("bi.data.value:%d \n",bip->data.value);
	  //tmp=bi.data.value;
	  a_free(bip->data.value);
	  /////////////////////
	  if(bi.p!=NULL) 
          cnt = cnt + freeBTnode_stupid(bi.p);
      bi.p = NULL;
    }
  free(node);
//  nodecnt--;
  return cnt+1;
}

int freeBThead_stupid(BThead *bt)
{
  int cnt;

  if(bt->root == NULL) return 0;
  cnt = freeBTnode_stupid(bt->root);
  free(bt);
  return cnt;  
}
*/