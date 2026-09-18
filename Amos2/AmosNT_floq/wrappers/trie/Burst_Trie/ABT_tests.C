/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan B, UDBL
 * $RCSfile: ABT_tests.C,v $
 * $Revision: 1.7 $ $Date: 2011/12/21 13:22:18 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Unit tests for the burst trie
 * ===========================================================================
 * $Log: ABT_tests.C,v $
 * Revision 1.7  2011/12/21 13:22:18  sobso953
 * introduction of the binary search for containers
 *
 * Revision 1.6  2011/11/19 14:27:43  sobso953
 * Test cases refined to fit the new container design.
 *
 * Revision 1.5  2011/11/16 18:30:11  sobso953
 * extra pointer redirection in nodes elliminated
 *
 * Revision 1.4  2011/11/16 15:37:31  sobso953
 * extra pointer redirection elliminated
 *
 * Revision 1.3  2011/11/13 14:08:38  sobso953
 * Unit tests for freeing burst tries added
 *
 * Revision 1.2  2011/11/09 14:45:03  sobso953
 * Trie mapper function added.
 *
 * Revision 1.1  2011/11/04 10:04:53  sobso953
 * Adding burst trie unit tests
 *
 *
 ****************************************************************************/
#include <Stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "include/CuTest.h"
#include "include/ABT.h"

//prototype of functions being tested but not included in ABT.h
BTrieValue* new_container(BTrieNode node, unsigned char path, unsigned char *key,BTrieValue val,int level);
int add_to_bucket(BTrieContainer container,unsigned char*  key,BTrieValue val,int level,BTrieNode node, unsigned char path);
void split_container(BTrieContainer bucket,BTrieNode new_node,int level);
void print_container(BTrieContainer bucket);
int burst_container(BTrieContainer bucket,char key_1,BTrieNode c_node,int level);
BTrieValue* bucket_search(BTrieContainer bucket,char* key);
int container_map(BTrieContainer bucket, BTrieKey lower, BTrieKey upper, BTrieKey prefix, int level,BTrie_mapper fn,  void *xa);
CuSuite* StrUtilGetSuite();

static unsigned long int rand_seed=13465241;

unsigned int randgen(int i) /* returns a random integer 0..i-1 */
{
  rand_seed = rand_seed * 1103515245 + 12345;
  if (i == 0) return 0;
  return (unsigned int)(rand_seed % i);
}

void print_container(BTrieContainer bucket)
{

	int partial_key_len;//the length of the part of the key that is stored in the container.
	unsigned int key_val_len;//the length of the <key,val> is stored in the container.
	unsigned int i;
	int j;
	char* key;
	BTrieValue val=0;

	partial_key_len=BTRIE_KEY_LENGTH-container_depth(bucket);
	key_val_len=partial_key_len+sizeof(BTrieValue);
	
	key=malloc(partial_key_len);

	printf("\nprinting contents of container:%d, depth:%d,tail:%d\n",bucket,container_depth(bucket),container_tail(bucket));
	for(i=0;i<container_tail(bucket);i+=key_val_len)
	{
		memcpy(key,bucket+i,partial_key_len);
		memcpy(&val,(BTrieValue*)(bucket+i+partial_key_len),sizeof(BTrieValue));
		printf("<|");
		for (j=0;j<partial_key_len-1;j++)
			printf("%u,",key[j]);
		printf("%u",key[j]);
		printf("|%u>",val);
	}

	free(key);
	printf("\n");
}


int TEST_BTrie_new(CuTest *tc){
	
	BTrie* new_trie=NULL;
	int i;
	
	printf("Testing BTrie_new()...");

	new_trie=BTrie_new();
	
	//check if new trie is created
	CuAssertPtrNotNullMsg(tc,"Failed at creating a new node!\n",new_trie->root_node);
	CuAssertPtrNotNullMsg(tc,"Failed at creating a new node!\n",new_trie);

	//Check the root node's integrity
	for(i=0;i<256;i++)
	{
		CuAssertIntEquals_Msg(tc,"Failed at initializing the root node!\n",(int)NULL,(int)new_trie->root_node[i].ptr);
		CuAssertIntEquals_Msg(tc,"Failed at initializing the root node!\n",0,new_trie->root_node[i].type);
	}
	printf("passed!\n");
	return 0;
}

int TEST_new_container(CuTest *tc){
	
	BTrieNode node;
	unsigned char path;
	BTrieKey key[3];
	BTrieValue val;
	unsigned int level;
	BTrieContainer container;
	unsigned int i,j;

	printf("Testing new_container()...");

	val=3658974235;
	level=1;
	
	node=(BTrieNode) malloc(sizeof(BTriePointer)*256);

	//testing border regions:0
	key[0][0]=0;key[0][1]=231;key[0][2]=23;key[0][3]=56;key[0][4]=0;
	//testing border regions:255
	key[1][0]=255;key[1][1]=231;key[1][2]=23;key[1][3]=56;key[1][4]=0;
	//testing the middle of the range
	key[2][0]=187;key[2][1]=231;key[2][2]=23;key[2][3]=56;key[2][4]=0;

	for(i=0;i<3;i++)
	{
		path=key[i][0];
		new_container(node,path,key[i]+1,val,level);
		
		CuAssertIntEquals_Msg(tc,"parent pointer assigned improperly!\n",'C',node[path].type);

		container=(BTrieContainer) (node[path].ptr);
		CuAssertPtrNotNullMsg(tc,"pointer to container is not valid!\n",container);
		CuAssertIntEquals_Msg(tc,"level assigned improperly!\n",level,container_depth(container));
		CuAssertIntEquals_Msg(tc,"tail_ptr assigned improperly!\n",container_Overhead+4+sizeof(BTrieValue),container_tail(container));

		for(j=0;j<4;j++)
			CuAssertIntEquals_Msg(tc,"Key not properly copied!\n",key[i][j+1],*(container+container_Overhead+j));
		
		CuAssertIntEquals_Msg(tc,"value not properly copied!\n",val,*((BTrieValue*)(container+container_Overhead+4)));

		for(j=container_Overhead+4+sizeof(BTrieValue);j<container_size(container);j++)
			CuAssertIntEquals_Msg(tc,"array is currupt!\n",0,container[j]);
	}
	
	printf("passed!\n");	
	return 0;
}

//TBD:test expansin of containers if  dynamic arrays are used
int TEST_add_to_bucket(CuTest *tc){
	BTrieContainer container;
	BTrieNode node;
	unsigned char path;
	//The total number of keys that can fit into a level 1 container (5 byte keys 4 byte vallues -1 =8)
	BTrieKey key[container_ultimate_size/8+1];
	BTrieValue val;
	unsigned int level;
	unsigned int i,j,cmp_res;
	//the maximum capacity of an L1 container
	unsigned int L1_cnt_capacity=(container_ultimate_size-container_Overhead)/8;

	printf("Testing add_to_bucket()...");
	
	//create a new container
	node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	
	//key generation
	key[0][0]=0;
	key[0][1]=231;
	key[0][2]=23;
	key[0][3]=56;
	key[0][4]=0;

	val=0;
	level=1;
	path=key[0][0];
	new_container(node,path,key[0]+1,val,level);
	
	container=(BTrieContainer) (node[path].ptr);
	level=1;
	for(i=1;i<L1_cnt_capacity;i++)
	{
		/////////////////////////////
		//generate and insert values
		/////////////////////////////
		key[i][0]=0;
		key[i][1]=i;
		key[i][2]=i*2;
		key[i][3]=i*3;
		key[i][4]=i*4;
		val=60000000*i;

		CuAssertIntEquals_Msg(tc,"wrong burst signal emited!\n",0,add_to_bucket(container,key[i]+1,val,level,node,path));
/*		
		//////////////////////
		//test post conditions
		//////////////////////

		//post condition#1: all previous <key,val> pairs are there

		for(j=0;j<i;j++)
		{
			CuAssertIntEquals_Msg(tc,"previous <key,val>s ruined!\n",0,strncmp(container+container_Overhead+j*(4+sizeof(BTrieValue)),key[j]+1,4));
			CuAssertIntEquals_Msg(tc,"previous <key,val>s ruined!\n",(BTrieValue)60000000*j,*(BTrieValue*)(container+container_Overhead+j*(4+sizeof(BTrieValue))+sizeof(BTrieValue)));
		}
		//post condition#2: new <key,val> on the right place
		CuAssertIntEquals_Msg(tc,"<key,val> not placed in the right position!\n",0,strncmp(container+container_Overhead+i*(4+sizeof(BTrieValue)),key[i]+1,4));
		CuAssertIntEquals_Msg(tc,"<key,val> not placed in the right position!\n",(BTrieValue)60000000*i,*(BTrieValue*)(container+container_Overhead+i*(4+sizeof(BTrieValue))+sizeof(BTrieValue)));
*/
		//test if tail pointer assigned properly
		CuAssertIntEquals_Msg(tc,"tail_ptr not assigned properly!\n",container_Overhead+(i+1)*(4+sizeof(BTrieValue)),container_tail(container));

		for(j=container_Overhead+(i+1)*(4+sizeof(BTrieValue));j<container_size(container);j++) //the rest of the buffer must be just 0
			CuAssertIntEquals_Msg(tc,"Array currupt after insertion!\n",0,container[j]);
	}

	//check if the container is sorted
	for(i=1;i<L1_cnt_capacity;i++)
	{
		cmp_res=strncmp(container+container_Overhead+(i-1)*(4+sizeof(BTrieValue)),key[i]+1,4);
		CuAssertIntEquals_Msg(tc,"order is violated!\n",0,cmp_res);
	
	}

	//Test updating the val for an existing key
	CuAssertIntEquals_Msg(tc,"wrong burst signal fired!\n",0,add_to_bucket(container,key[10]+1,100,level,node,path));
/*
	//post condition#2: new <key,val> on the right place
	CuAssertIntEquals_Msg(tc,"Update failed!\n",0,strncmp(container+container_Overhead+10*(4+sizeof(BTrieValue)),key[10]+1,4));
	CuAssertIntEquals_Msg(tc,"Update failed!\n",100,*(BTrieValue*) (container+container_Overhead+10*(4+sizeof(BTrieValue))+4) );
*/
	//Test if it signals a burst -on the right time-/
	CuAssertIntEquals_Msg(tc,"Burst signal missing!\n",1,add_to_bucket(container,key[i]+1,val,level,node,path));

	printf("passed!\n");	
	return 0;
}

int TEST_split_container(CuTest *tc){

	
	BTrieContainer container;
	BTrieContainer bucket;
	BTrieNode parent_node;
	BTrieNode new_node;
	unsigned char path;
	//The total number of keys that can fit into a level 1 container (5 byte keys 4 byte vallues -1 =8)
	BTrieKey key[60];
	BTrieValue val;
	unsigned int level;
	int i,j;

	printf("Testing split_container()...");

	
	//create the nodes
	parent_node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	new_node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	memset(new_node,0,sizeof(BTriePointer)*256);
	//create a container
	key[0][0]=0;
	key[0][1]=0;
	key[0][2]=23;
	key[0][3]=56;
	key[0][4]=0;


	level=1;
	val=123;
	path=key[0][0];
	new_container(parent_node,path,key[0]+1,val,level);
	container=parent_node[0].ptr;
	//populate the container
	for(i=1;i<60;i++)
	{
		/////////////////////////////
		//generate and insert values
		/////////////////////////////
		key[i][0]=0;
		key[i][1]=i;
		key[i][2]=i+2;
		key[i][3]=i+3;
		key[i][4]=i+4;
		val=60000000*i;
		//BUT some keys share a prefix-reinforce the default vals
		key[1][1]=0; //key#0 and key#1 share '0' prefix	
		key[2][1]=255; key[3][1]=255; //key#2 and key#3 share '255' prefix
		key[4][1]=80; key[5][1]=80; //key#4 and key#5 share '50' prefix
		add_to_bucket(container,key[i]+1,val,level,parent_node,path);
	}

	
	//split the container
	split_container(container,new_node,level);

	//post conditions:
	//#1: test pointers and pointer types in new_node
	j=0;
	for (i=0;i<256;i++)//count the number of container pointers after split
		if (new_node[i].type=='C' && new_node[i].ptr)
			j++;

	CuAssertIntEquals(tc,60-3,j);// 6 key pairs share the same prefix-> -3
	//#2: find the keys in expected containers key[][HERE!]
	for(i=0;i<60;i++)
	{
		bucket=new_node[key[i][1]].ptr;
		//printf("accessing element#%d\n",key[i][1]);
		//print_container(bucket);
		if(i==3||i==4||i==1||i==5||i==0||i==2)//these containers must have two <key,val> pairs each
			CuAssertIntEquals(tc,container_tail(bucket),14+container_Overhead);//(3+4)*2=14
		else
			CuAssertIntEquals(tc,container_tail(bucket),7+container_Overhead);

	}


	printf("passed!\n");	
	return 0;
}

int TEST_burst_container(CuTest *tc){
	int i=0,j=0;
	BTrieKey key;
	BTrieContainer bucket;
	BTrieNode parent_node;
	int level=1;

	printf("Testing burst_container()...");
	//populate a container
	parent_node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	key[0]=53;
	key[1]=24;
	key[2]=65;
	key[3]=44;
	key[4]=67;
	new_container(parent_node,key[0],key+1,0,level);
	bucket=parent_node[53].ptr;
	//generate/add the keys
	for(i=0;i<10;i++)
	{
		key[0]=53;
		for(j=1;j<BTRIE_KEY_LENGTH;j++)
			key[j]=i*j;
		add_to_bucket(bucket,key+1,i,1,parent_node,key[0]);
	}
	//burst
	burst_container(bucket,key[0],parent_node,1);
	//the container pointer must be replaced by a node pointer
	CuAssertIntEquals(tc,'T',parent_node[key[0]].type);

	printf("passed!\n");	
	return 0;
}

int TEST_BTrie_insert(CuTest *tc){
	BTrie* trie;
	BTrieKey key;
	BTrieContainer bucket;
	BTrieValue val;
	BTrieNode new_node;
	int i;
	//maximum number of key,val pairs that can fit into a single level1 container:
	int max_level1_cnt_size=(container_ultimate_size-container_Overhead)/8;

	printf("Testing BTrie_insert()...");

	trie=BTrie_new();

	for(i=0;i<max_level1_cnt_size;i++)
	{	
		key[0]=53;
		key[1]=i;
		key[2]=i+2;
		key[3]=i+3;
		key[4]=i+4;
		val=10000000*i;	

		BTrie_insert(trie,key,val);

		bucket=trie->root_node[53].ptr;
		
		memcpy(key+1,bucket+container_Overhead+i*8,4);
		memcpy(&val,(BTrieValue*)(bucket+container_Overhead+i*8+4),sizeof(BTrieValue));

		CuAssertIntEquals(tc,i+0,key[1]);
		CuAssertIntEquals(tc,i+2,key[2]);
		CuAssertIntEquals(tc,i+3,key[3]);
		CuAssertIntEquals(tc,i+4,key[4]);
		CuAssertIntEquals(tc,10000000*i,val);
	}
	//now the bucket is full:
	//printf("container_size(bucket):%d\n",container_size(bucket));
	CuAssert(tc,"Container is not full!", container_ultimate_size-container_tail(bucket)<8);
	//CuAssertIntEquals(tc,container_tail(bucket),container_ultimate_size);
	//now test the bursting
	key[0]=53;
	key[1]=i;
	key[2]=i+2;
	key[3]=i+3;
	key[4]=i+4;
	val=10000000*i;	
	BTrie_insert(trie,key,val);
	//test if it has "bursted"
	//The initial node now points to an internal node
	CuAssertIntEquals(tc,'T',trie->root_node[53].type);
	new_node=trie->root_node[53].ptr;
	//The internal node has pointers to containers
	for(i=0;i<max_level1_cnt_size;i++)
		CuAssertIntEquals(tc,'C',new_node[i].type);
	//test the contents of one of the containers
	bucket=new_node[0].ptr;
	CuAssertIntEquals(tc,container_Overhead+7,container_tail(bucket));
	CuAssertIntEquals(tc,2,*(bucket+container_Overhead));

	printf("passed!\n");	
	return 0;
}

int TEST_bucket_search(CuTest *tc){
	int i=0,j=0;
	//The total number of keys that can fit into a level 1 container (5 byte keys 4 byte vallues -1 =8)
	BTrieKey key[container_ultimate_size/8];
	BTrieContainer bucket;
	BTrieNode parent_node;
	int level=1;

	printf("Testing bucket_search()...");
	//populate a container
	parent_node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	key[0][0]=53;
	key[0][1]=24;
	key[0][2]=65;
	key[0][3]=44;
	key[0][4]=67;
	new_container(parent_node,key[0][0],key[0]+1,0,level);
	bucket=parent_node[53].ptr;
	//generate/add the keys
	for(i=1;i<(container_ultimate_size-container_Overhead)/8;i++)
	{
		key[i][0]=53;
		for(j=1;j<BTRIE_KEY_LENGTH;j++)
			key[i][j]=i*j;
		add_to_bucket(bucket,key[i]+1,i,1,parent_node,key[0][0]);
		bucket=parent_node[53].ptr;
		for(j=0;j<=i;j++)//all previous keys must exist
		{	
			CuAssertPtrNotNullMsg(tc,"<Key,Val> missing!",(void*)(bucket_search(bucket,key[j]+1)));
			CuAssertIntEquals(tc,j,*(bucket_search(bucket,key[j]+1)));
		}
		//tailptr pointing to the right place
		CuAssertIntEquals(tc,container_Overhead+8*(i+1),container_tail(bucket));
	}
	printf("passed!\n");	
	return 0;
}

int TEST_BTrie_lookup(CuTest *tc){
	unsigned int i=0,j=0;
	#define test_size 5000
	BTrieKey key[test_size];
	int level=1;
	BTrie* trie;
	BTrie* trie2;
	BTrieValue val;
	BTrieValue* res;

	printf("Testing BTrie_lookup()...");
	//populate the trie
	trie=BTrie_new();
	//generate&add the keys
	for(i=0;i<test_size;i++)
	{
		key[i][0]=1;//256*256*256*256
		key[i][1]=i/16777216;//256*256*256
		key[i][2]=i/65536;//256*256
		key[i][3]=i/256;
		key[i][4]=i;
		//if (i==256||i==0)
		//	printf("\naha!i/256:%d<%u,%u,%u,%u,%u>\n",i/256,key[i][0],key[i][1],key[i][2],key[i][3],key[i][4]);
		BTrie_insert(trie,key[i],(BTrieValue) i);

		for(j=0;j<i;j++)//all previous keys must exist
		{	
			//if(i==64&&j==63)
			//	printf("i:%d,j:%d\n",i,j);
			res=BTrie_lookup(trie,key[j]);
			CuAssertPtrNotNull(tc,res);//there has to be a value
			val=*res;
			CuAssertIntEquals(tc,(BTrieValue)j,val);
		}
	}
	//test with random keys
	trie2=BTrie_new();
	for(i=0;i<test_size;i++)
	{
		key[i][0]=randgen(2000000000)/683;
		key[i][1]=randgen(2000000000)/857;
		key[i][2]=randgen(2000000000)/883;
		key[i][3]=randgen(2000000000)/109;
		key[i][4]=randgen(2000000000)/257;
		
		//printf("\ni:%d<%u,%u,%u,%u,%u>\n",i, key[i][0],key[i][1],key[i][2],key[i][3],key[i][4]);
		
		BTrie_insert(trie2,key[i],(BTrieValue) i);

		for(j=0;j<i;j++)//all previous keys must exist
		{	
			//if(i==64&&j==63)
			//	printf("i:%d,j:%d\n",i,j);
			res=BTrie_lookup(trie2,key[j]);
			CuAssertPtrNotNull(tc,res);//there has to be a value
			val=*res;
			CuAssertIntEquals(tc,(BTrieValue)j,val);
		}
	}
	//TBD: test: nothing else has to exist (use counting)
	printf("passed!\n");	
	return 0;
}

int BTriePrintMapper(BTrieKey key,BTrieValue* val, void *xa)
{
	printf("<{%u,%u,%u,%u,%u},%u>\n",key[0],key[1],key[2],key[3],key[4],*val);
	return 1;
}

int BTrieSumMapper(BTrieKey key,BTrieValue* val, void *xa)
{
  *(int *) xa+= (int) *val;
  return 1;
}
int TEST_container_map(CuTest *tc){
	
	BTrie* trie;
	BTrieContainer bucket;
	BTrieKey key,low,high,prefix;
	BTrieValue val;
	int sum=0;

	printf("Testing container_map()...");
	
	trie=BTrie_new();
	
	key[0]=0;key[1]=33;key[2]=33;key[3]=33;key[4]=33;
	val=3;
	BTrie_insert(trie,key,val);

	key[0]=0;key[1]=22;key[2]=22;key[3]=22;key[4]=22;
	val=2;
	BTrie_insert(trie,key,val);
	key[0]=0;key[1]=11;key[2]=11;key[3]=11;key[4]=11;
	val=1;
	BTrie_insert(trie,key,val);

	key[0]=0;key[1]=44;key[2]=44;key[3]=44;key[4]=44;
	val=4;
	BTrie_insert(trie,key,val);

	bucket=trie->root_node[0].ptr;
	prefix[0]=0;

	//test the whole range
	low[0]=0;low[1]=0;low[2]=0;low[3]=0;low[4]=0;
	high[0]=255;high[1]=255;high[2]=255;high[3]=255;high[4]=255;
	sum=0;
	container_map(bucket,low,high,prefix,1,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Container's full range mapping failed!",10,sum);

	//test a range in the middle
	low[0]=0;low[1]=22;low[2]=22;low[3]=22;low[4]=22;
	high[0]=0;high[1]=33;high[2]=33;high[3]=33;high[4]=33;
	sum=0;
	container_map(bucket,low,high,prefix,1,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Container's full range mapping failed!",5,sum);

	//test a range in the low border
	low[0]=0;low[1]=11;low[2]=11;low[3]=11;low[4]=11;
	high[0]=0;high[1]=11;high[2]=11;high[3]=11;high[4]=11;
	sum=0;
	container_map(bucket,low,high,prefix,1,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Container's full range mapping failed!",1,sum);

	//test a range in the high border
	low[0]=0;low[1]=44;low[2]=44;low[3]=44;low[4]=44;
	high[0]=0;high[1]=44;high[2]=44;high[3]=44;high[4]=44;
	sum=0;
	container_map(bucket,low,high,prefix,1,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Container's full range mapping failed!",4,sum);

	//test a range including the high border and above
	low[0]=0;low[1]=44;low[2]=44;low[3]=44;low[4]=44;
	high[0]=255;high[1]=255;high[2]=255;high[3]=255;high[4]=255;
	sum=0;
	container_map(bucket,low,high,prefix,1,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Container's full range mapping failed!",4,sum);

	printf("passed!\n");	
	return 0;
}
int TEST_BTrie_map0(CuTest *tc){

	int i=0,j=0;
	#define test_size 5000
	BTrieKey key,low,high,prefix;
	int level=1;
	BTrie* trie1;
	BTrie* trie2;
	BTrieValue val;
	int sum=0;
	int max_l1_container_cnt=(container_ultimate_size-container_Overhead)/((BTRIE_KEY_LENGTH-1)+sizeof(BTrieValue));
	int total_cnt=0;

	printf("Testing BTrie_map0()...");
	//populate the trie
	trie1=BTrie_new();
	
	key[0]=0;key[1]=0;key[2]=0;key[3]=21;key[4]=35;
	val=1007654321;
	BTrie_insert(trie1,key,val);

	key[0]=0;key[1]=0;key[2]=0;key[3]=21;key[4]=39;
	val=1001234567;
	BTrie_insert(trie1,key,val);

	low[0]=0;low[1]=0;low[2]=0;low[3]=20;low[4]=0;
	high[0]=0;high[1]=0;high[2]=0;high[3]=22;high[4]=40;

	for(i=0;i<BTRIE_KEY_LENGTH;i++)
		prefix[i]=0;
	//1.very simple case:the whole range is in one container at the 1st level
	sum=0;
	BTrie_map0(trie1->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '1.very simple case'!",2008888888,sum);
	//TBD: free trie1!

	//2.simple case: The whole range is in a container, but at the second level
	trie2=BTrie_new();
	//2.1continue filling the same container so that it bursts
	//means that the leading bytes of low and high are identical
	key[0]=0;key[1]=10;//so that after the burst all end up in a single container
	val=1;
	for(i=0;i<max_l1_container_cnt;i++)
	{
		key[2]=i+1;key[3]=i+2;key[4]=i+3;
		BTrie_insert(trie2,key,val);
		total_cnt++;
	}
	
	key[2]=i+1;key[3]=i+2;key[4]=i+3;
	BTrie_insert(trie2,key,val);//this should triger the burst
	total_cnt++;

	low[0]=0;low[1]=10;low[2]=0;low[3]=0;low[4]=0;
	high[0]=0;high[1]=10;high[2]=255;high[3]=255;high[4]=255;
	sum=0;
	BTrie_map0(trie2->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '2.simple case'!",max_l1_container_cnt+1,sum);
	//TBD: free trie2!

	//3.Scattered range:range is scattered accross different containers in different levels
	//3.1 Add 5 keys to a new level 1 container
	key[0]=100;
	val=1;
	for(i=0;i<5;i++){
		key[1]=i;key[2]=i+1;key[3]=i+2;key[4]=i+3;
		BTrie_insert(trie2,key,val);
		total_cnt++;
	}
	//3.2 Add 5 more keys to another level 1 container
	key[0]=255;
	val=1;
	for(i=0;i<5;i++){
		key[1]=i+3;key[2]=i+2;key[3]=i+1;key[4]=i;
		BTrie_insert(trie2,key,val);
		total_cnt++;
	}
	//build the range such that it includes some of the keys in 2 and some in 3
	low[0]=0;low[1]=10;low[2]=max_l1_container_cnt+1;low[3]=0;low[4]=0;//includes only one key from the range in #2
	high[0]=100;high[1]=255;high[2]=255;high[3]=255;high[4]=255;//includes range 3.1, but not 3.2
	sum=0;
	BTrie_map0(trie2->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '3.Scattered range'!",6,sum);

	//build the range such that it includes the keys in 3
	low[0]=100;low[1]=0;low[2]=0;low[3]=0;low[4]=0;//includes only one key from the range in #2
	high[0]=255;high[1]=255;high[2]=255;high[3]=255;high[4]=255;//includes range 3.1, but not 3.2
	sum=0;
	BTrie_map0(trie2->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '3.Scattered range'!",10,sum);

	//3.2 Continue with more diversity in container levels

	//populating the key range 100|X|X|X|X so that the trie branches further down
	
	key[0]=100;
	val=1;
	for(i=0;i<3000;i++){
		key[1]=randgen(2000000000)/683;
		key[2]=randgen(2000000000)/257;
		key[3]=randgen(2000000000)/857;
		key[4]=randgen(2000000000)/109;
		BTrie_insert(trie2,key,val);
		total_cnt++;
	}
	
	//count the values in range 100|*|*|*|*
	low[0]=100;low[1]=0;low[2]=0;low[3]=0;low[4]=0;//includes only one key from the range in #2
	high[0]=100;high[1]=255;high[2]=255;high[3]=255;high[4]=255;//includes range 3.1, but not 3.2
	sum=0;
	BTrie_map0(trie2->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '3.Scattered range'!",3005,sum);//5 keys added before

	//4.The full range scan
	low[0]=0;low[1]=0;low[2]=0;low[3]=0;low[4]=0;//includes only one key from the range in #2
	high[0]=255;high[1]=255;high[2]=255;high[3]=255;high[4]=255;//includes range 3.1, but not 3.2
	sum=0;
	BTrie_map0(trie2->root_node,low,high,prefix,0,BTrieSumMapper,&sum);
	CuAssertIntEquals_Msg(tc,"Failed in the '4.The full range scan'!",total_cnt,sum);
	printf("passed!\n");
	
	return 0;
}

int TEST_BTrie_free(CuTest *tc){
//make a trie
//populate it
//free it
	int i=0;
	int TestSize=50000000;
	BTrieKey key;
	int level=1;
	BTrie* trie;
	BTrieValue val=1;

	printf("Testing BTrie_free()...");

	trie=BTrie_new();
	for(i=0;i<TestSize;i++){
		key[0]=randgen(2000000000)/683;
		key[1]=randgen(2000000000)/883;
		key[2]=randgen(2000000000)/857;
		key[3]=randgen(2000000000)/109;
		key[4]=randgen(2000000000)/257;

		BTrie_insert(trie,key,val);
	}
	//printf("insertion is over\n");
	//BTrie_free(trie->root_node);
	printf("passed!\n");
	
	return 0;
}

int TEST_BTrie_MACROS(CuTest *tc){

	BTrieContainer cnt=NULL;

	printf("Testing TEST_BTrie_MACROS()...");

	cnt=malloc(Growth_step_size);

	container_tail(cnt)=1000;
	container_depth(cnt)=250;

	CuAssertIntEquals_Msg(tc,"container_tail() Macro failed!",1000,container_tail(cnt));

	CuAssertIntEquals_Msg(tc,"container_depth() Macro failed!",250,container_depth(cnt));

	printf("passed!\n");
	
	return 0;
}

CuSuite* StrUtilGetSuite() {

	CuSuite* suite = CuSuiteNew();
	
	SUITE_ADD_TEST(suite,TEST_BTrie_MACROS);
	SUITE_ADD_TEST(suite,TEST_BTrie_new);
	SUITE_ADD_TEST(suite,TEST_new_container);
	SUITE_ADD_TEST(suite,TEST_add_to_bucket);
	SUITE_ADD_TEST(suite,TEST_split_container);
	SUITE_ADD_TEST(suite,TEST_burst_container);
	SUITE_ADD_TEST(suite,TEST_BTrie_insert);
	SUITE_ADD_TEST(suite,TEST_bucket_search);
	SUITE_ADD_TEST(suite,TEST_BTrie_lookup);
	SUITE_ADD_TEST(suite,TEST_container_map);
	SUITE_ADD_TEST(suite,TEST_BTrie_map0);
	
	SUITE_ADD_TEST(suite,TEST_BTrie_free);

	return suite;
}


int test_BTrie(){
	CuString *output = CuStringNew();
	CuSuite* suite = CuSuiteNew();
	CuSuiteAddSuite(suite, StrUtilGetSuite());
	CuSuiteRun(suite);
	CuSuiteSummary(suite, output);
	CuSuiteDetails(suite, output);
	printf("%s\n", output->buffer);
	return 1;
}

main(){
	char c=0;
	test_BTrie();
	scanf("%c",&c);
}
