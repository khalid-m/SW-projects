#include "amosXtree.h" 
#define  UNDEFINED_ID -1;
/*
-----------------------------------------------------
  Update list of X-trees. 
  Each entry contains  
  <ID, memory address, next_entry>   
-----------------------------------------------------
*/
int updateListTree(int id, node_type* address, config_type fconfig) {
  ListTree_type * pos, * prev;
  pos = m_listTreeHead;
  prev = m_listTreeHead;

  while (pos != NULL){	
    if (pos->id == id) {
      break;
    } 
    prev = pos;
    pos = pos->next;
  }
 
  // Allocate a new entry if either list is empty or no such tree exists
  if(pos == NULL ) { 
    if ((pos = (ListTree_type *) malloc(sizeof(ListTree_type))) == NULL) {
      return  UNDEFINED_ID;
    } else {
      // Generate a new id
      if (id == -1) {
		id = idgenerator = idgenerator + 1;
      }
    }
  } 
  
  // Link it to the existing list.
  if (prev == NULL) {
    m_listTreeHead = pos;
    pos->next = NULL;
  } else if (prev->next == NULL) {
    prev->next = pos;
    pos->next = NULL;
  }

  // Use the default configuration. 
  pos->id = id;
  pos->address = address;
  pos->config.dim = fconfig.dim;
  pos->config.M = fconfig.M;
  pos->config.m = fconfig.m;
  pos->config.no_histogram = fconfig.no_histogram;
  pos->config.reinsert_p = fconfig.reinsert_p;
  pos->config.counter = fconfig.counter;  

  return id;
}

/*-----------------------------------------------------
  Return a Xtree given an ID.
-----------------------------------------------------*/
node_type* getXtree(int id) {
  ListTree_type * tmp;
  tmp = m_listTreeHead;
  if (tmp != NULL) {
    do {
      if (tmp->id == id) {
	/*Found*/
	return tmp->address;
      }
      tmp = tmp->next;
    }while(tmp != NULL);
  }
  /*There is no Xtree whose ID = id in the main memory*/
  return NULL;
}
/*-----------------------------------------------------
  Return a Xtree Descriptor given an ID.
-----------------------------------------------------*/
ListTree_type* getXtDescriptor(int id) {
  ListTree_type * tmp;
  tmp = m_listTreeHead;
  if (tmp != NULL) {
    do {
      if (tmp->id == id) {
		/*Found*/
		return tmp;
      }
      tmp = tmp->next;
    }while(tmp != NULL);
  }
  /*There is no Xtree whose ID = id in the main memory*/
  return NULL;
}
/*-----------------------------------------------------
  Get a Xtree's configuration given its ID
-----------------------------------------------------*/
void getConfig(int id, config_type *fconfig) {
  ListTree_type * tmp;
  int found = FALSE;

  tmp = m_listTreeHead;
  if (tmp != NULL) {
    do {
      if (tmp->id == id) {
	/*Found*/
	fconfig->dim = tmp->config.dim;
	fconfig->M = tmp->config.M;
	fconfig->m = tmp->config.m;
	fconfig->no_histogram = tmp->config.no_histogram;
	fconfig->reinsert_p = tmp->config.reinsert_p;
	fconfig->counter = tmp->config.counter;
	found = TRUE;
	break;
      }
      tmp = tmp->next;
    }while(tmp != NULL);
  }

  // If not found, return the default configuration
  if (!found) {
    fconfig->dim = UNDEFINED;
    fconfig->M = master_config.M;
    fconfig->m = master_config.m;
    fconfig->no_histogram = master_config.no_histogram;
    fconfig->reinsert_p = master_config.reinsert_p;
    fconfig->counter = 0;	
  }
}
int getIndexIdonFunction(int pos, oidtype indexedFunction) {
  dcl_scan(s); 
  dcl_tuple(result);  /* To hold results from Amos function calls */
  dcl_tuple(arg);
  dcl_oid(fun);
  int indexID;
	
  // Get the function 
  a_setf(fun,
	 a_getfunction(a_callback_connection,		      
		       "INTEGER.FUNCTION.GET_INDEX_IDENTIFIER->INTEGER",
		       FALSE));

  // Initialize arguments
  a_newtuple(arg, 2, FALSE);
  a_setintelem(arg, 0, pos, FALSE);
  a_setobjectelem(arg, 1, indexedFunction, FALSE);

  // Callin Amos2 
  a_callfunction(a_callback_connection,s,fun,arg,FALSE); 
  
  // Get result
  a_getrow(s, result, FALSE);
  
  // Get ID from the result
  indexID = a_getintelem(result, 0, FALSE);

  free_tuple(result);
  free_scan(s);
  free_tuple(arg);
  free_oid(fun);
  return indexID;
}