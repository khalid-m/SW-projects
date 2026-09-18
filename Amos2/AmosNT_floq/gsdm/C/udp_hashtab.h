////////////////////////////////////////////////////////////////////////////////
// "Magic macros" to construct code for chained hash tables in compile time.
// by  Arsenij Vodjanov
//
// Macro names are prefixed with "MM_" to avoid name collisions with
// other things.
//
// The macros work only for structures that contain members *next, *prev and id.
// The created table is a module-global declaration.
//
// This code is only useful for the kind of objects whose identifying
// key is not a data-based hash-value.  These functions generate
// auto-incrementing unique IDs for objects.
////////////////////////////////////////////////////////////////////////////////
#ifndef HASHMAGIC__H_
#define HASHMAGIC__H_

#include <stdlib.h>
#include <string.h>

// "Hash function" (id->index) for a hashtable with specified size.
#define MM_HASH_INDEX( id, TABLE_SIZE ) ( (id) % TABLE_SIZE )


// Creates a function to allocate an unused ID number.
#define MM_FUNC_ALLOC_ID(PREFIX, TABLE_SIZE) \
static int PREFIX ## _alloc_id( ) { \
  if (PREFIX ## _next_id == PREFIX ## _id_list_size) { \
    if (PREFIX ## _id_list_size == PREFIX ## _id_list_maxsize) { \
      if (PREFIX ## _id_list_maxsize==0) \
        PREFIX ## _id_list_maxsize = TABLE_SIZE; \
      else \
        PREFIX ## _id_list_maxsize *= 2; \
      PREFIX ## _id_list = (int *) realloc( PREFIX ## _id_list, PREFIX ## _id_list_maxsize * sizeof(int) ); \
    } \
    PREFIX ## _id_list[ PREFIX ## _id_list_size++ ] = PREFIX ## _next_id; \
  } \
  return PREFIX ## _id_list[ PREFIX ## _next_id++ ]; \
}


// Creates a function to release an ID number that is no longer used.
#define MM_FUNC_RELEASE_ID(PREFIX) \
static void PREFIX ## _release_id( int id ) { \
  PREFIX ## _id_list[ -- PREFIX ## _next_id ] = id; \
}


// Creates a function to get a pointer to an element with the
// specified ID.  Returns NULL if ID is invalid or if no matching
// element is found.
#define MM_FUNC_FIND_ELEM(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static ELEMENT_TYPE * PREFIX ## _find_elem( int id ) { \
  ELEMENT_TYPE *elem; \
  if (id < 0) return NULL; \
  elem = PREFIX ## _htable [ MM_HASH_INDEX(id, TABLE_SIZE) ]; \
  while (elem != NULL) { \
    if (elem->id == id) \
      return elem; \
    elem = elem->next; \
  } \
  return NULL; \
}


// Creates a function to get a pointer to the next element in the
// table after the specified one. Returns NULL if there is no next
// element.
#define MM_FUNC_NEXT_ELEM(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static ELEMENT_TYPE * PREFIX ## _next_elem( ELEMENT_TYPE *elem ) { \
  int i; \
  ELEMENT_TYPE * next; \
  if (elem==NULL) return NULL; \
  next = elem->next; \
  if (next != NULL) return next; \
  i = MM_HASH_INDEX(elem->id, TABLE_SIZE); \
  while (++i < TABLE_SIZE) { \
    next = PREFIX ## _htable[ i ]; \
    if (next != NULL) return next; \
  } \
  return NULL; \
}



// Creates a function to get a pointer to an element with the
// specified ID.  Returns NULL if ID is invalid or if no matching
// element is found.
#define MM_FUNC_FIRST_ELEM(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static ELEMENT_TYPE * PREFIX ## _first_elem( ) { \
  int i = 0; \
  ELEMENT_TYPE *elem = NULL; \
  if (PREFIX ## _num_elements == 0) return NULL; \
  while (i < TABLE_SIZE && elem == NULL) { \
    elem = PREFIX ## _htable [ i++ ]; \
  } \
  return elem; \
}


// Creates a function to allocate memory for a new element, assign a
// new ID to it, insert it into the hash table and return pointer to
// the new element, or NULL if memory can't be allocated.
#define MM_FUNC_CREATE_ELEM(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static ELEMENT_TYPE * PREFIX ## _create_elem( ) { \
  ELEMENT_TYPE *elem, **bucket; \
  elem = (ELEMENT_TYPE *) malloc(sizeof(ELEMENT_TYPE)); \
  if (elem == NULL) return NULL; \
  memset(elem, 0, sizeof(ELEMENT_TYPE)); \
  if (PREFIX ## _num_elements==0) memset(PREFIX ## _htable, 0, sizeof(PREFIX ## _htable)); \
  elem->id = PREFIX ## _alloc_id(); \
  bucket = & PREFIX ## _htable[ MM_HASH_INDEX( elem->id, TABLE_SIZE ) ]; \
  elem->prev = NULL; \
  elem->next = *bucket; \
  if (*bucket!=NULL) (*bucket)->prev = elem; \
  *bucket = elem; \
  PREFIX ## _num_elements++; \
  return elem; \
}


// Creates a function to remove an element with the specified ID from
// the table and deallocate the memory.
#define MM_FUNC_DELETE_ELEM(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static void PREFIX ## _delete_elem( ELEMENT_TYPE *elem ) { \
  if (elem != NULL) { \
    ELEMENT_TYPE *p = elem->prev, *n = elem->next; \
    if (p != NULL) p->next = n; \
    if (n != NULL) n->prev = p; \
    if (PREFIX ## _htable[ MM_HASH_INDEX(elem->id, TABLE_SIZE) ] == elem) \
      PREFIX ## _htable[ MM_HASH_INDEX(elem->id, TABLE_SIZE) ] = n; \
    PREFIX ## _release_id( elem->id ); \
    PREFIX ## _num_elements--; \
    free( elem ); \
  } \
}



//
// Creates the code defining the hashtable and access functions.
//
// PREFIX - text prepended to all variable and function names
// ELEMENT_TYPE - name of structure containing at least: int id; ELEMENT_TYPE *next; ELEMENT_TYPE *prev;
// TABLE_SIZE - number of buckets to have in the hash table
//
#define MM_DEF_HASHTABLE(PREFIX, ELEMENT_TYPE, TABLE_SIZE) \
static ELEMENT_TYPE * PREFIX ## _htable[ TABLE_SIZE ]; \
static int  PREFIX ## _num_elements = 0; \
static int  PREFIX ## _next_id = 0; \
static int  PREFIX ## _id_list_size = 0; \
static int  PREFIX ## _id_list_maxsize = 0; \
static int *PREFIX ## _id_list = NULL; \
MM_FUNC_ALLOC_ID(PREFIX, TABLE_SIZE) \
MM_FUNC_RELEASE_ID(PREFIX) \
MM_FUNC_FIND_ELEM(PREFIX, ELEMENT_TYPE, (TABLE_SIZE)) \
MM_FUNC_FIRST_ELEM(PREFIX, ELEMENT_TYPE, (TABLE_SIZE)) \
MM_FUNC_NEXT_ELEM(PREFIX, ELEMENT_TYPE, (TABLE_SIZE)) \
MM_FUNC_CREATE_ELEM(PREFIX, ELEMENT_TYPE, (TABLE_SIZE)) \
MM_FUNC_DELETE_ELEM(PREFIX, ELEMENT_TYPE, (TABLE_SIZE))

//
// Example: variables and functions created with PREFIX=="test", ELEMENT_TYPE=="tpe" and TABLE_SIZE==10
//
// static tpe *test_htable[ 10 ];                   -- internal, the table itself
// static int test_num_elements = 0;                -- internal, current number of elements stored in the table
// static int test_next_id = 0;                     -- internal, next unused ID number
// static int test_id_list_size = 0;                -- internal, current number of IDs in the ID-array
// static int test_id_list_maxsize = 0;             -- internal, current storage capacity of the ID-array
// static int *test_id_list = NULL;                 -- internal, array of currently used IDs
//
// static int test_alloc_id( );                     -- internal, allocates a new ID number
// static void test_release_ID( int id );           -- internal, releases an ID number
//
// static tpe * test_find_elem( int id );           -- returns pointer to the element with given 'id'
// static tpe * test_first_elem( );                 -- returns pointer to the first element in the table
// static tpe * test_next_elem( tpe *elem );        -- returns pointer to the first successor to 'elem'
// static tpe * test_create_elem( );                -- creates a new element and returns a pointer to it
// static void test_delete_elem( tpe *elem );       -- deletes an element pointed to by 'elem'
//

#endif
