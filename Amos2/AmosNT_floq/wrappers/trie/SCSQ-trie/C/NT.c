/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: NT.c,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Naive trie implementation (supports 4 byte integers)
 * ===========================================================================
 *
 ****************************************************************************/

#include <string.h>
#include "NT.H"
#include <stdlib.h>
#include <stdio.h>

//////////////////////
//Function defenitions
//////////////////////


Trie *naive_trie_new(void)
{
     //First create the Trie object
     Trie* new_trie=NULL;
     TrieNode *RootNode=NULL;//to maintain the top node

     new_trie = (Trie *) malloc(sizeof(Trie));
     new_trie->root_node = NULL;
     //create a node (the root points to this node)
     RootNode = (TrieNode *) malloc(sizeof(TrieNode));
     //initialize all keys/pointers in node to null
     memset(RootNode, 0, sizeof(TrieNode));
     new_trie->root_node = RootNode;
     new_trie->number_of_nodes=1;
     return new_trie;
}

//releases the memory allocated by a sub trie by recursively freeing its childs.
//to free the whole trie root node must be passed

int cnt_freed_nodes=0;
int cnt_freed_elem=0;

void naive_trie_free(TrieNode* trn){
	
	int i=0;

	cnt_freed_nodes++;//TBR:for debugging purposes
	
	if(trn->use_count==0){
		free(trn);
		return;
	}
	else{
		for (i=0;i<256;i++){//free all child objects
			/*
			if (trn->items[i].key!=0 && trn->items[i].key!=MAXINT){
				//this node element is a leaf, ie. it contains an element
				//free(trn->items[i].next);//free the cell that holds the key value.TBCInsert
				cnt_freed_elem++;//TBR:for debugging purposes
			}
			*/
			if(trn->items[i].key==MAXINT)
				//this items holds an internal node, recursively free that node.
				naive_trie_free(trn->items[i].next);
		}
		free(trn);//free the node itself.
		return;
	}
	printf("cnt_freed_nodes:%d\n",cnt_freed_nodes);
	return;
}

unsigned int *BreakInt(unsigned int i){

      //*****breaking an integer into its 4 bytes *****
      //MAX_unsigned_int=4294967295
      //printf("size of int is: %d\n",sizeof(int));
      unsigned int First=i; //keeps the lowest valued byte
      unsigned int Second=i;
      unsigned int Third=i;
      unsigned int Forth=i; //keeps the highest valued byte
	  unsigned int *result;
      First=First<<24;
      First=First>>24;
      //printf("1st byte %d\n", First);

      Second=Second<<16;
      Second=Second>>24;
      //printf("2nd byte %d\n", Second);

      Third=Third<<8;
      Third=Third>>24;
      //printf("3rd byte %d\n", Third);

      Forth=Forth>>24;
      //printf("4th byte %d\n", Forth);


      result=(unsigned int *) malloc(sizeof(unsigned int)*4);
      *(result+0)=Forth;
      *(result+1)=Third;
      *(result+2)=Second;
      *(result+3)=First;
      return result;
 }


int* naive_trie_lookup(Trie *trie, int ikey){

    TrieNode* node=NULL;
    unsigned int *key=NULL;
	int* value=NULL;
    unsigned int *p=NULL;//pointer to key array
    unsigned int c=0;//keeps the current byte of the key

    node=trie->root_node;
    //Break the key into its for bytes
    key=(unsigned int *)BreakInt(ikey);
    p = key;//initialize the key pointer
    c = *p;

    //jump over all internal nodes
    while((unsigned int)(node->items[c].key)==MAXINT){
        node=(TrieNode*) node->items[c].next;
        p++;
        c = *p;
    }

    //The leaf node is reached
    if (node->items[c].key==ikey)
        value=(int*) node->items[c].next;
    else
        value=NULL;

    free(key);

    return value;
}


void naive_trie_remove(Trie *trie, int ikey){
    TrieNode* node=NULL;
    unsigned int *key=NULL;
    unsigned int *p=NULL;//pointer to key array
    unsigned int c=0;//keeps the current byte of the key
	int i=0;
    //array of pointers to nodes in the path from root to leaf
    TrieNode* NodesOnPath[4]={NULL};
    int NodesOnPathCNT=0;//keeps the maximum number of nodes on path


    if (ikey==0 || ikey==MAXINT) return;
    node=trie->root_node;
    //Break the key into its for bytes
    key=(unsigned int *)BreakInt(ikey);
    p = key;//initialize the key pointer
    c = *p;
	i=0;
    NodesOnPathCNT=0;
    //jump over all internal nodes

    while((unsigned int)(node->items[c].key)==MAXINT){
        (node->use_count)--;
        //add this node to the path from root to leaf node
        //(in case key is not found, use_count decrement must be rolled back)
        NodesOnPath[NodesOnPathCNT]=node;
        NodesOnPathCNT++;

        node=(TrieNode*) node->items[c].next;
        p++;
        c = *p;
    }

    //The leaf node is reached
    if (node->items[c].key==ikey){//if the key exists, remove it
        node->items[c].key=0;//mark this element as free
		//free(node->items[c].next);//to avoid memory leak: free the int cell created @ insertion time.TBCInsert
		node->items[c].next=NULL;
        //decrease use count
        (node->use_count)--;
        //remove the node if it becomes empty
        // do not free the root node!
        if ((node->use_count)==0 && node!=trie->root_node)
            free(node);//remove the node if it becomes empty
        //Check the nodes on the path, if they are empty, free them
        for(i=0;i<NodesOnPathCNT;i++)// do not free the root node!
            if(NodesOnPath[i]->use_count==0 && NodesOnPath[i]!=trie->root_node)
                free(NodesOnPath[i]);
    }
    else//roleback the decrements of use_counts for the nodes on path
        for(i=0;i<NodesOnPathCNT;i++)
            (NodesOnPath[i]->use_count)++;

    free(key);

}

//returns a pointer to the (int*) type cell that can hold value for the given ikey.
Trie_Node_Element* naive_trie_insert(Trie* trie, int ikey){
	//Create the element to be inserted.
	Trie_Node_Element NewElement;
	//Break the key into its for bytes
	//keep an array of pointers to
	//nodes in the path from root to leaf
    TrieNode* NodesOnPath[4]={NULL};
	unsigned int *key=NULL;
	TrieNode *node=NULL;
	unsigned int *p=NULL;//pointer to key array
	unsigned int c=0;//keeps the current key byte
	int level=0;
	int i=0;
	int intConflictingKey=0;
    void* ConflictingValue=NULL;
	unsigned int *ConflictingKey=NULL;//this keeps the broken Conflicting Key
//	int* intptr;
	Trie_Node_Element* parent=NULL;

	NewElement.key=0;NewElement.next=NULL;

	if (ikey==0 || ikey==MAXINT || trie==NULL || trie->root_node==NULL) return NULL;

//	intptr=(int *) malloc(sizeof(int));
//	*intptr=value;
	NewElement.key=ikey;
	NewElement.next=NULL;//Initialize to NULL, is supposed to be set after calling naive_trie_insert

	key=(unsigned int *)BreakInt(ikey);
     /* Prevent insertion of NULL values */
//     if ((int*) value == NULL){
//         free(key);
//         return NULL;
//     }
     p = key;//initialize the key pointer
     node = trie->root_node;//setting node to point to the root node
     c = *p;
     level=0;
     NodesOnPath[level]=node;
     // traverse the trie as long as nodes are internal.
     while((unsigned int)(node->items[c].key)==MAXINT)
     {
         (node->use_count)++;

         node=(TrieNode*)node->items[c].next;
         p++;
         c = *p;
         level++;

         NodesOnPath[level]=node;

     }
//printf("Passed internal nodes\n");
     //The key already exists
     if (node->items[c].key==ikey)
     {//just update the key/value pair
         node->items[c]=NewElement;
         free(key);
         //Rolleback use_count increments done so far
         //decrese all use counts that are incremented by mistake
         for (i=0;i<level;i++){
             (NodesOnPath[i]->use_count)--;
         }
//printf("Case1: The key already exists\n");
         return &(node->items[c]);
     }
     //if the element is free, just use it and return
     if (node->items[c].key==0)
     {
         node->items[c]=NewElement;
         (node->use_count)++;
         free(key);
//printf("Case2: element was free\n");
         return &(node->items[c]);
     }
     
	 /*There is a conflict:
     this element is already occupied by another key that
     has the same prefix as the key being inserted
     */
     //Save the node element for re-insertion
     //ConflictingElement=(Trie_Node_Element *)(node->items[c]);
     intConflictingKey=node->items[c].key;
     ConflictingValue=node->items[c].next;
     ConflictingKey=(unsigned int *)BreakInt(intConflictingKey);
     //continue making nodes as long as there is conflict
     (node->use_count)++;
//printf("Conflict: passed initialization\n");
//level could be the source of problem
     while(ConflictingKey[level]==c)
     {
         //This node element becomes an internal pointer
         node->items[c].key=MAXINT;
//c could be the source of problem
         parent=&(node->items[c]);
         //create a new node
         node = (TrieNode *) malloc(sizeof(TrieNode));
		 if (node==NULL){
			 printf("Insertion into Trie %d failed in malloc!\n", trie);
			 return NULL;
		 }
         memset(node, 0, sizeof(TrieNode));
         (node->use_count)++;
         (node->use_count)++;//since two keys are in this subtrie, increment twice
//printf("Level: %d, c: %d\n",level,c);
         trie->number_of_nodes++;
         // Link previous node to the new node
         parent->next= node;
//++ could be the source of problem: maybe going out of bounds . . .
         p++;
         c = *p;
         level++;
 //printf("END - Level: %d, c: %d\n",level,c);
  
     }
//printf("Conflict: passed While loop\n");
     /*No more conflicts
     Insert both ConflictingElement and new key/value in this node
     */
     node->items[c]=NewElement;

     node->items[ConflictingKey[level]].key=intConflictingKey;
     node->items[ConflictingKey[level]].next=ConflictingValue;

     free(key);
     free(ConflictingKey);
     return &(node->items[c]);
}

//returns Trie_Node_Element e such that e.key is the smallest key that is greater than
//or equal to "key" argument. Usefull for range search.

Trie_Node_Element naive_trie_next(Trie *trie, int ikey){

	Trie_Node_Element result;
	TrieNode* node=NULL;
	unsigned int *key=NULL;
	unsigned int *p=NULL;//pointer to key array
	unsigned int c=0;//keeps the current byte of the key
	int level=0;
	int i=0,j=0,k=0,flag=0;

	result.key=0;
	result.next=NULL;
	key=(unsigned int *)BreakInt(ikey);

	for(k=0;k<5;k++){//maximum 4 backtracks are required.
                        //5 is chosen to be on safe side, lopp will break before
                        //k reaches 5 anyway.
		node=trie->root_node;
		//Break the key into its for bytes
		p = key;//initialize the key pointer
		c = *p;
		level=0;

		//jump over all internal nodes
		while((unsigned int)(node->items[c].key)==MAXINT){
			node=(TrieNode*) node->items[c].next;
			p++;
			c = *p;
			level++;
		}

		//The leaf node is reached 
		//loop trough same leaf node to find first key that is bigger than or equal to ikey
		//i.e looking for the fisrt key in the order.
		//Could be improved by using use_count of node
		for(i=c;i<256;i++)
			if (node->items[i].key!=0 && node->items[i].key>=ikey){
                            flag=1;//case1: a key found in the node
                            result.key=node->items[i].key;
                            result.next=node->items[i].next;
                            break;//key found no need for more search.
			}
                        else{
                            if((unsigned int)(node->items[i].key)==MAXINT){
                                flag=2;//case2: internal node must be followed
                                break;
                            }
                        }
                if(i==256)
                    flag=3;//case3: nothing found
		//take appropriate action base on flag

                if (flag==1)//next key is found in the same leaf node, break outer loop.
			break;
		else	//otherwise: no key is found in the leaf,
                        //start a new look up by setting key.
		{
                    if(flag==2){
                        *p=i;//to move to the next branch in backtracking.
                        for (j=level+1;j<4;j++)
                            *(key+j)=0;//set the rest of the key to zero to enable a through search
                    }
                    else if(flag==3){
                        if (level==0) break;//nothing found, exit
                        (*(p-1))++;//to move to the next branch in backtracking.
                        for (j=level;j<4;j++)
                            *(key+j)=0;//set the rest of the key to zero to enable a through search
                    }
		}
	}
    free(key);
    return result;
}

void NT_Test()
{

	Trie_Node_Element e;
	Trie * tr;
	Trie_Node_Element* ptmp;

	/////////////////////
	//testing nave trie
	/////////////////////

	tr=naive_trie_new();
    //inserting key/value pairs according to the 'original' test case.
    
    ptmp=naive_trie_insert(tr,16842752);
	ptmp->next=(void*)1100;//1
    ptmp=naive_trie_insert(tr,16908288);
	ptmp->next=(void*)1200;//2
    ptmp=naive_trie_insert(tr,33554944);
	ptmp->next=(void*)2020;//3
	//printf("ptmp: %d\n",*ptmp);
	//*ptmp=202020;
    ptmp=naive_trie_insert(tr,33554689);
	ptmp->next=(void*)2011;//4
    ptmp=naive_trie_insert(tr,50331904);
	ptmp->next=(void*)3010;//5
    ptmp=naive_trie_insert(tr,33619968);
	ptmp->next=(void*)2100;//6
    
	
	ptmp=naive_trie_insert(tr,193028287);
	ptmp->next=(void*)1234;//6

    e=naive_trie_next(tr,16908288);
    while (e.next!=NULL && e.key<=33619960){
        printf("e.key: %d e.next: %d\n",e.key,e.next);
        e=naive_trie_next(tr,e.key+1);
    }

	naive_trie_free(tr->root_node);

	printf("cnt_freed_nodes:%d cnt_freed_elem:%d\n",cnt_freed_nodes,cnt_freed_elem);

	return;
}
