/*****************************************************************************
 * AMOS2
 *
 * Author: (c) Sobhan B , UDBL
 * $RCSfile: ABT.C,v $
 * $Revision: 1.11 $ $Date: 2012/08/05 15:35:06 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Array burst trie source code, this implementation is inspired from source code in http://www.naskitis.com/
 * ===========================================================================
 * $Log: ABT.C,v $
 * Revision 1.11  2012/08/05 15:35:06  sobso953
 * Some commetns removed, key size set to 5
 *
 * Revision 1.10  2011/12/21 13:21:34  sobso953
 * introduction of the binary search for containers
 *
 * Revision 1.9  2011/11/19 14:26:59  sobso953
 * Bugs associated with the new container design fixed.
 *
 * Revision 1.8  2011/11/16 18:29:50  sobso953
 * extra pointer redirection in nodes elliminated
 *
 * Revision 1.7  2011/11/16 15:35:22  sobso953
 * extra pointer redirection elliminated
 *
 * Revision 1.6  2011/11/16 13:59:09  sobso953
 * Stepwise container growth introduced
 *
 * Revision 1.5  2011/11/15 10:18:49  sobso953
 * linear container introduced:
 * The meta data about the container (i.e depth and tail_ptr) is stored in the beginning of the container array.
 *
 * Revision 1.4  2011/11/13 14:07:25  sobso953
 * code for freeing burst trie added
 *
 * Revision 1.3  2011/11/09 14:45:03  sobso953
 * Trie mapper function added.
 *
 * Revision 1.2  2011/11/04 10:00:56  sobso953
 * *** empty log message ***
 *
 * Revision 1.1  2011/11/04 09:58:15  sobso953
 * Burst trie source code added
 *
 *
 ****************************************************************************/

#include <Stdio.h>
#include <stdlib.h>
#include <string.h>

#include "include/ABT.h"

BTrie* BTrie_new(void){
	
	BTrie* new_trie=NULL;
	BTrieNode RootNode=NULL;

	new_trie=(BTrie*) malloc(sizeof(BTrie));
	RootNode=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	BTrienodecnt++;
	if (RootNode==NULL || new_trie==NULL )
		return NULL;//signaling a failure
	
	memset(RootNode, 0, sizeof(BTriePointer)*256);
	
	new_trie->root_node=RootNode;
	
	return new_trie;
}

void BTrie_free(BTrieNode node){

	int i;
	
	for(i=0;i<256;i++)
		switch(node[i].type)
		{
			case 'T':
				BTrie_free(node[i].ptr);//free all sub-tries
				free(node[i].ptr);//free the node itself
				break;
			case 'C':
				free(node[i].ptr);
				break;
		}
}

//creates a new container in element(pointer) path under BTrieNode node.
//then inserts <key,val) into it and returns a pointer to val
BTrieValue* new_container(BTrieNode node, unsigned char path,unsigned char *key,BTrieValue val,unsigned char level)
{
	BTrieContainer newcontainer;
	int partial_key_len;//the length of the part of the key that will be stored in the container.
	int key_val_len;//the length of the <key,val> that will be stored in the container.

	partial_key_len=BTRIE_KEY_LENGTH-level;
	key_val_len=partial_key_len+sizeof(BTrieValue);
	newcontainer=malloc(Growth_step_size);
	BTrieContainerSize+=Growth_step_size;
	if (newcontainer==NULL){
		printf("Memory exhausted!\n");
		return NULL;
	}
	memset(newcontainer,0,Growth_step_size);
	if(newcontainer==NULL)//malloc failure
		return NULL;
	
	container_depth(newcontainer)=level;
	//place the new key into the container
	memcpy(newcontainer+container_Overhead,key,partial_key_len);
	memcpy(newcontainer+container_Overhead+partial_key_len,&val,sizeof(BTrieValue));
	//set the tail pointer of the container.
	container_tail(newcontainer)=container_Overhead+key_val_len;
	//set the current size of the container
	container_size(newcontainer)=Growth_step_size;

	//link the newly created container to the parent trie node
	node[path].type='C';
	node[path].ptr=newcontainer;
	
	return (BTrieValue*) (newcontainer+container_Overhead+partial_key_len);
}

//adds <key,val> to container at specified level.if the key already exists,
//it replaces its value,otherwise appends <key,val> to the end of the bucket
//if the buket is full, returns 1 signalling the need for a burst
//Note that the container's address might change due to realloc,
//therefore the respective pointer in parent node must be re-assigned
int add_to_bucket(BTrieContainer container,unsigned char*  key,BTrieValue val,int level,BTrieNode node, unsigned char path){
	
	unsigned int partial_key_len;//the length of the part of the key that will be stored in the container.
	unsigned int key_val_len;//the length of the <key,val> that will be stored in the container.
	BTrieContainer resized_container=NULL;
	int l=0,u=0,mid=0,population=0,cmp_res,found=0;//used in binary search
	unsigned char* lposition;

	partial_key_len=BTRIE_KEY_LENGTH-level;
	key_val_len=partial_key_len+sizeof(BTrieValue);
	
//perform a binary search
	population=(container_tail(container)-container_Overhead)/key_val_len;
	
	l=0;
	u=population-1;
	while(l<=u){
		
		mid=(l+u)/2;
		cmp_res=memcmp(container+container_Overhead+mid*key_val_len,key,partial_key_len);
		if (cmp_res==0)//container[mid]==key
		{
             found=1;
             break;
         }
         else if(cmp_res>0){//container[mid]>key
             u=mid-1;
         }
         else
             l=mid+1;
    }
	//check if the key is already present
	if(found)
	{
		memcpy(container+container_Overhead+mid*key_val_len+partial_key_len,&val,sizeof(BTrieValue));//replace value
		return 0;	
	}

	if(  (container_ultimate_size - container_tail(container))<key_val_len  )
		return 1;//There is no space left for a new <key,val> pair, return 1, initiating a burst
	//if the container has to grow
	if(container_size(container) - container_tail(container)<key_val_len)
	{
		container=realloc(container,container_size(container)+Growth_step_size);
		BTrieContainerSize+=Growth_step_size;
		memset(container+container_size(container),0,Growth_step_size);//set the new bytes to 0
		container_size(container)+=Growth_step_size;
		//re-assigne the pointer in the parent node
		node[path].ptr=container;
	}

	//add <key,val> pair to the right place in the order
	//l [from binsearch]indicates the place where the insertion must happen

	//first make room for the new element by shifting
	lposition=container+container_Overhead+l*key_val_len;
	//move(shift) container[l] to container[l+1] for (number_of_elements-l)*size_of_elements
	memmove(lposition+key_val_len,lposition,(population-l)*key_val_len);

	//Now insert new <key,val>
	memcpy(lposition,key,partial_key_len);//copy the key
	memcpy(lposition+partial_key_len,&val,sizeof(BTrieValue));//replace value

	container_tail(container)+=key_val_len;

	return 0;
}

//splits the contents of a container between ab node and new containers
//actual burst operation happens here
void split_container(BTrieContainer bucket,BTrieNode new_node,unsigned char level){
	unsigned int partial_key_len;//the length of the part of the key that will be stored in the container.
	unsigned int key_val_len;//the length of the <key,val> that will be stored in the container.
	unsigned int i;
	unsigned char* new_key;
	BTrieValue val;
	unsigned char new_lead;


	partial_key_len=BTRIE_KEY_LENGTH-level;
	key_val_len=partial_key_len+sizeof(BTrieValue);
	
	//go throgh the whole container and distribute its content to new_node
	for(i=container_Overhead;i<container_tail(bucket);i+=key_val_len){
		
		new_key=bucket+i+1; // the lead character of the key is consumed in new_node
		new_lead=*(bucket+i);//the next lead character
		
		val=*(BTrieValue*)(bucket+i+partial_key_len);
		
		//if two keys share prefix at a lower level, they should be inserted to the same container
		if(new_node[new_lead].type=='C'&&new_node[new_lead].ptr)
			add_to_bucket((BTrieContainer)new_node[new_lead].ptr,new_key,val,level+1,new_node,new_lead);
		else
			new_container(new_node,*(bucket+i),new_key,val,(unsigned char)(level+1));

	}
	free(bucket);
	return;
}

//bursts container node that has overflowed.
//the container is replaced by a trie node,
//then its content is splitted over to new containers
int burst_container(BTrieContainer bucket,unsigned char key_1,BTrieNode c_node,unsigned char level){
	
	BTrieNode new_node;
	//cretae a new trie node
	new_node=(BTrieNode) malloc(sizeof(BTriePointer)*256);
	BTrienodecnt++;
	memset(new_node,0,sizeof(BTriePointer)*256);
	
	//make the c_node point to new_node instead of the container that is going to burst
	c_node[key_1].type='T';
	c_node[key_1].ptr=new_node;

	//split the contents of the container over the new_node
	split_container(bucket,new_node,level);

	return 1;
}


//inserts <key,val> into burst trie tri
//returns the pointer to the corresponding value
BTrieValue* BTrie_insert(BTrie* tri, BTrieKey key,BTrieValue val){

	BTrieContainer x; 
	int exhaust=0;//a flag indicating that a container has no more space
	int i=0;
	BTrieNode c_node;//current trie node being traversed


	c_node=tri->root_node;

	/* take the leading character from the key */
	for (i=0;i<BTRIE_KEY_LENGTH;i++)
	{
		/* if the pointer that maps to the leading character is null,
		 * then create a new container to house the string, to complete
		 * the insertion process
		 */
		if (c_node[*key].ptr==NULL) //TBD: Find out the specifications for this function/case
			return new_container(c_node,*key,key+1,val,(unsigned char)(i+1));//TBD:recheck the order of the arguments of this function call...
         
		/* check whether the pointer that maps to the leading character 
		 * leads to a trie node or to a container
		 */
		if( c_node[*key].type=='T')//a trie node
			c_node = c_node[*key].ptr;   
		else
		{
			/*
			* a container is acquired.  Attempt to add the string
			* to the container.  If the function returns a non-null value,
			* then the insertion was a success. In this case, check to see
			* whether the container needs to be burst 
			*/
			
			/* consume the lead character */
			key++;
			
			x = (BTrieContainer) (c_node[*(key-1)].ptr);

			exhaust=add_to_bucket(x,key,val,i+1,c_node,*(key-1));
			if (exhaust)
			{	
				burst_container(x, *(key-1), c_node,(unsigned char)(i+1));
				c_node = c_node[*(key-1)].ptr;
				continue;//the new key is not added yet->continue
			}
			break;
		}

		/* consume the current character and continue with the traversal */
		key++;
	}
	return 0;
}

//find the value associated with key in the container x
BTrieValue* bucket_search(BTrieContainer bucket,unsigned char* key){
	
	int partial_key_len;//the length of the part of the key that is stored in the container.
	unsigned int key_val_len;//the length of the <key,val> is stored in the container.
	int l=0,u=0,mid=0,population=0,cmp_res,found=0;//used in binary search

	partial_key_len=BTRIE_KEY_LENGTH-container_depth(bucket);
	key_val_len=partial_key_len+sizeof(BTrieValue);

//perform a binary search
	population=(container_tail(bucket)-container_Overhead)/key_val_len;
	
	l=0;
	u=population-1;
	while(l<=u){
		
		mid=(l+u)/2;
		cmp_res=memcmp(bucket+container_Overhead+mid*key_val_len,key,partial_key_len);
		if (cmp_res==0)//bucket[mid]==key
		{
             found=1;
             break;
         }
         else if(cmp_res>0){//bucket[mid]>key
             u=mid-1;
         }
         else
             l=mid+1;
    }
	//check if the key is already present
	if(found)
		return (BTrieValue*) (bucket+container_Overhead+mid*key_val_len+partial_key_len);
	else
		return NULL;
}

//looks up the burst trie tri for key.
//returns the pointer to value associated with ikey
//returns NULL if value does not exist

BTrieValue* BTrie_lookup(BTrie* tri, BTrieKey key){

	BTrieContainer x; 
	int i=0;
	BTrieNode c_node;//current trie node being traversed

	c_node=tri->root_node;

	for (i=0;i<BTRIE_KEY_LENGTH;i++)
	{
		if (c_node[*key].ptr==NULL) 
			return NULL;

		if( c_node[*key].type=='T')//a trie node
			c_node = c_node[*key].ptr;
		else//have reached a container
		{
			x = (BTrieContainer) (c_node[*key].ptr);
			key++;
			return bucket_search(x, key);
		}
		key++;
	}
	return NULL;
}

int container_map(BTrieContainer bucket, BTrieKey lower, BTrieKey upper, BTrieKey prefix, int level,BTrie_mapper fn,  void *xa){
	
	int partial_key_len;//the length of the part of the key that is stored in the container.
	unsigned int key_val_len;//the length of the <key,val> is stored in the container.
	unsigned int i;
	BTrieKey key;
	BTrieValue* val;
	int l,h;
	int flag=0;

	partial_key_len=BTRIE_KEY_LENGTH-container_depth(bucket);
	key_val_len=partial_key_len+sizeof(BTrieValue);

	//copy the prefix to the key
	memcpy(key,prefix,level);
	//check if the key is present
	for(i=container_Overhead;i<container_tail(bucket);i+=key_val_len)
	{
		memcpy(key+level,bucket+i,partial_key_len);
		val=(BTrieValue*)(bucket+(i+partial_key_len));
		l=memcmp(key,lower,sizeof(BTrieKey));
		h=memcmp(upper,key,sizeof(BTrieKey));

		if(l>=0 && h>=0)
		{//if the key is in the range, apply the function
			(*fn)(key,val,xa);
		}
		else
			flag=1;
		//The key is out of the range, dont apply the function and signal this
	}
	return flag;
}

int BTrie_map0(BTrieNode node, BTrieKey lower, BTrieKey upper, BTrieKey prefix, int level,BTrie_mapper fn,  void *xa){
	int L,H;
	BTrieKey Prefix_High_Bound,Prefix_Low_Bound;
	int i;

	//0. If the expanse is more grain than the current level, proceed.
	if(lower[level]==upper[level]){
		prefix[level]=upper[level];//update the prefix

		if (node[lower[level]].type=='C')
			container_map(node[lower[level]].ptr,lower,upper,prefix,level+1,fn,xa);
		else
			BTrie_map0(node[lower[level]].ptr,lower,upper,prefix,level+1,fn,xa);
			
		return 0;
	}
	//1.find out the range that has to be travesred in this level/node
	//1.1 find the total range that the current node covers:[Prefix_Low_Bound,Prefix_High_Bound]
	memcpy(Prefix_High_Bound,prefix,sizeof(BTrieKey));
	memcpy(Prefix_Low_Bound,prefix,sizeof(BTrieKey));	
	memset(Prefix_Low_Bound+level,0,BTRIE_KEY_LENGTH-level);
	memset(Prefix_High_Bound+level,255,BTRIE_KEY_LENGTH-level);

	//1.2 find the lower(L) and upper(H) bounds for  traversing the current node
	if(memcmp(Prefix_Low_Bound,lower,sizeof(BTrieKey))>=0)
		L=0;// Prefix_Low_Bound>lower => traverse the whole expanse
	else
		L=lower[level];

	if(memcmp(upper,Prefix_High_Bound,sizeof(BTrieKey))>=0)
		H=255;//upper>Prefix_High_Bound => traverse the whole expanse
	else
		H=upper[level];
	
	for(i=L;i<=H;i++)
	{
		prefix[level]=i;//update the prefix
		if(node[i].type=='C')
			container_map(node[i].ptr,lower,upper,prefix,level+1,fn,xa);
		if(node[i].type=='T')
			BTrie_map0(node[i].ptr,lower,upper,prefix,level+1,fn,xa);
	}
	return 0;
}