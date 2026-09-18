
/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: NT.H,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the naive trie implementation
 * ===========================================================================
 *
 ****************************************************************************/

#define MAXINT 4294967295

/////////////////////////////////////////
//Naive trie Data Structure defenitions//
/////////////////////////////////////////

typedef struct _TrieNode TrieNode;
typedef struct _Trie Trie;
typedef struct _Trie_Node_Element Trie_Node_Element;


struct _Trie_Node_Element{
       //key=0 element not used;key=MAXINT internal node;Otherwise "key"
       int key;
       //Consequently, we have the following for *next:
       //key=0 NULL pointer;key=MAXINT internal pointer;Otherwise data pointer
       void *next;// dual use: internal pointer and data pointer
       };

struct _TrieNode {
	unsigned int use_count;
	Trie_Node_Element items[256];
};

struct _Trie {//trie object just keeps the pointer to the root node
	TrieNode *root_node;
        int number_of_nodes;
};

//functions

//creates a naive trie and returns a pointer to it
Trie *naive_trie_new(void);

//Releases the memory allocated to naive trie node trn
//and recursivly, all it's child nodes
void naive_trie_free(TrieNode* trn);

//Breaks an integer i into 4 bytes
//returns the pointer to an array that contains the 4 bytes.
unsigned int *BreakInt(unsigned int i);

//looks up the trie tri for key ikey.
//returns a pointer to the value associated with ikey
int* naive_trie_lookup(Trie* tri, int ikey);

//removes ikey from trie tri
void naive_trie_remove(Trie* tri, int ikey);

//inserts iket into trie tri
//returns the pointer to the corresponding Trie_Node_Element
Trie_Node_Element* naive_trie_insert(Trie* tri, int ikey);

//searchj trie tri for next element of ikey
//returns Trie_Node_Element that has the key k1 such that
//k1 has a value greater than or equal to ikey
//this is used in traversing the trie in ascending order
Trie_Node_Element naive_trie_next(Trie *tri, int ikey);
