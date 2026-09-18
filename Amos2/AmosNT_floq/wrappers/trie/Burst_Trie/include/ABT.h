/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan B, UDBL
 * $RCSfile: ABT.h,v $
 * $Revision: 1.7 $ $Date: 2011/11/19 14:29:04 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Array Burst Trie data structure and interface definitions
 * ===========================================================================
 * $Log: ABT.h,v $
 * Revision 1.7  2011/11/19 14:29:04  sobso953
 * Macros for fast dispatching of common operations introduced.
 *
 * Revision 1.6  2011/11/16 18:30:50  sobso953
 * extra pointer redirection in nodes elliminated
 *
 * Revision 1.5  2011/11/16 15:36:58  sobso953
 * extra pointer redirection elliminated
 *
 * Revision 1.4  2011/11/16 13:59:39  sobso953
 * Stepwise container growth introduced
 *
 * Revision 1.3  2011/11/15 10:19:26  sobso953
 * linear container introduced:
 * The meta data about the container (i.e depth and tail_ptr) is stored in the beginning of the container array.
 *
 * Revision 1.2  2011/11/09 14:46:55  sobso953
 * Trie mapper added
 *
 * Revision 1.1  2011/11/04 10:16:59  sobso953
 * Burst trie interface definition file added
 *
 *
 ****************************************************************************/
/////////////////////////////////////////
//Burst Trie Data Structure Definitions//
/////////////////////////////////////////

//key specifications
#define BTRIE_KEY_LENGTH 5
typedef unsigned char BTrieKey[BTRIE_KEY_LENGTH];
typedef unsigned int BTrieValue; 


#define container_ultimate_size 512 //Overal size of the container in bytes. (recommended size: 512)
#define Growth_step_size 64//the realloc will increase the size of the container by this variable
#define container_Overhead (1+2*sizeof(unsigned int)) //1 byte depth + two integers(tail_ptr and size)


typedef int (*BTrie_mapper) (BTrieKey,BTrieValue*,void *);

typedef struct _BTrie BTrie;
typedef unsigned char* BTrieContainer;
typedef struct _BTriePointer BTriePointer;

struct _BTriePointer{
	char type;
	void* ptr;//"void*" because it might point to another BTrieNode, or a container
}
;

typedef BTriePointer*  BTrieNode;// Node is an array of BTriePointer(s)

struct _BTrie {
	//A burst trie root is always an internal node
	BTrieNode root_node;
};

//////////////////////////////////////////////////
//Macros for fast dispatching of common operations
//////////////////////////////////////////////////

#define container_depth(bucket) (  *(unsigned char*)( bucket )  )
#define container_tail(bucket)  (  *(unsigned int*) ( bucket+1 )  )
#define container_size(bucket)  (  *(unsigned int*) ( bucket+1+sizeof(unsigned int) )  )

/////////////////////////////////////////
//////Burst Trie interface functions/////
/////////////////////////////////////////

//creates a Burst trie and returns a pointer to it
BTrie *BTrie_new(void);

//Releases the memory allocated to a burst trie node
//and all it's child/container nodes recursivly 
void BTrie_free(BTrieNode trn);

//inserts <key,val> into burst trie tri
//returns the pointer to the corresponding value
BTrieValue* BTrie_insert(BTrie* tri, BTrieKey key,BTrieValue val);

//looks up the burst trie tri for key.
//returns the pointer to value associated with ikey
//returns NULL if value does not exist
BTrieValue* BTrie_lookup(BTrie* tri, BTrieKey key);

//removes key from the burst trie tri
void BTrie_remove(BTrie* tri, BTrieKey key);

// Applies fn on <key,value> pair in [lower,upper] range
// intermediate results can be stored in xa
int BTrie_map0(BTrieNode node, BTrieKey lower, BTrieKey upper, BTrieKey prefix, int level,BTrie_mapper fn,  void *xa);

//General mapper functions
int BTrieSumMapper(BTrieKey key,BTrieValue* val, void *xa);
int BTrieCountMapper(BTrieKey *bi, void *xa);
int BTrieAvgMapper(BTrieKey *bi, void *xa);

//General aggregate functions
int BTrieSum(BTrie* tri, BTrieKey low,BTrieKey high);
int BTrieCount(BTrie* tri, BTrieKey low,BTrieKey high);
double BTrieAvg(BTrie* tri, BTrieKey low,BTrieKey high);
