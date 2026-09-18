/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 thanh, UDBL . 
 * $RCSfile: amosXtree.c,v $
 * $Revision: 1.26 $ $Date: 2010/08/14 20:05:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II <--> Xtree
 * 
 * ===========================================================================
 * $Log: amosXtree.c,v $
 * Revision 1.26  2010/08/14 20:05:05  thtr1663
 * add xtree_dropper to deallocate xtree. It should be called when drop_index
 * command is executed.
 *
 * Revision 1.25  2010/06/22 05:48:14  thtr1663
 * rewriter.lsp
 *
 * Revision 1.24  2010/06/19 06:17:32  thtr1663
 * fix bug : configuration not found
 *
 * Revision 1.23  2010/06/14 05:52:55  thtr1663
 * modify xtree_similarity_search_fn
 *
 * Revision 1.22  2010/06/07 19:22:47  thtr1663
 * create Xtree dynamically (not reading dim from config file)
 *
 * Revision 1.21  2010/06/07 08:20:08  thtr1663
 * rewrite function updateListTree
 *
 * Revision 1.20  2010/06/04 14:18:34  thtr1663
 * Fix KNN search on multiple Xtree index
 *
 *
 * 
 ****************************************************************************/

#include "amosXtree.h"

/*Return connection to Amos*/
a_connection getConnection() {
  return xtreeConn;	
}

/*Update list of tree. Each entry contains pair value 
  <ID, memory address> together with a pointer to the next
  entry in the list
*/
void updateListTree(int id, node_type* address, config_type fconfig) {
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
      return;
    }
  } 
 
  // Make sure a new entry is linked the existing list.
  if (prev == NULL) {
    m_listTreeHead = pos;
    pos->next = NULL;
  } else if (prev->next == NULL) {
    prev->next = pos;
    pos->next = NULL;
  }

  // Update the information
  pos->id = id;
  pos->address = address;
  pos->config.dim = fconfig.dim;
  pos->config.M = fconfig.M;
  pos->config.m = fconfig.m;
  pos->config.no_histogram = fconfig.no_histogram;
  pos->config.reinsert_p = fconfig.reinsert_p;
  pos->config.counter = fconfig.counter;  

}


/*Gets memory address of a tree given its ID*/
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
  /*There is no tree whose ID = id in the main memory*/
  return NULL;
}

/*Gets configuration of a tree given its ID*/
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

/*
 Traverse a tree and set free object handle to Amos II
*/
void free_object_handle(node_type *node, config_type fconfig) {
  int i, count;
  count = fconfig.M * node->snodeSize - node->vacancy;
  for (i = 0; i < count; i++) {
    if (node->ptr[i]->attribute != LEAF) {
      free_object_handle(node->ptr[i], fconfig);
    } else {
      a_free(node->ptr[i]->object);
    }
  }
}

/*Remove Xtree
 It is part of deallocation of an Xtree*/
void clearUpXtree(int id) {
  ListTree_type * pos, * prev;
  config_type fConfig;
  
  pos = m_listTreeHead;
  prev = m_listTreeHead;
  while (pos != NULL){	
    if (pos->id == id) {

      // take it out of the list
      prev->next = pos->next;
      pos->next = NULL;
      
      // Since Xtree holds references to Amos, therefore
      // it is important to free these references (object
      // handles) before deallocatin of Xtree is taken place
      getConfig(id, &fConfig);
      free_object_handle((node_type *)pos->address, fConfig);
     
      // free Xtree
      free(pos->address);

      // free Xtree header
      free(pos); // an entry pointing to to-be-deleted Xtree
      printf("\n Doneeeeeeeeee \n");
      break;
    } 
    prev = pos;
    pos = pos->next;
  }  
}

/*----------------------------------------------------------------------------
  Implementation of AmosXtree's functions
  ---------------------------------------------------------------------------*/
/*-----------------------------------------------------
  Make a new Xtree
  Input : No parameter is given. 
  We might be able to add a description of Xtree
  Output : An integer representing a new Xtree
  -----------------------------------------------------*/
void xtree_make(a_callcontext cxt, a_tuple t)
{
  node_type *root;
  int indexID;
	
  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
  myprintf("[C] Xtree_make... \n");

  // Just point to NULL
  root = NULL;	
	
  indexID = a_getintelem(t, 0, FALSE);
  myprintf("indexID is %d \n", indexID);
  // Update the list of tree.
  updateListTree(indexID, root, master_config);

  myprintf("[C] Xtree's id %d reference %d\n", indexID, root);
	
  a_setintelem(t,0, indexID, FALSE);
  a_emit(cxt,t,FALSE);
	
  return;
}

/*-----------------------------------------------------
  Put a pair <key, value> into Xtree 
  Input : Integer Xid 
  Vector of Real f as key/ feature vector
  Object o as value
  Output : Boolean result. TRUE if OK. Otherwise FALSE
  -----------------------------------------------------*/
void xtree_put(a_callcontext cxt, a_tuple t)
{
  // Input Integer xtId, Vector of Real f, Object o
  // Output Boolean
  int size, i;
  float *data;
  int indexID;
  node_type *root;
  config_type fconfig;
	
  dcl_tuple(tpl_feature);
  // Initialize a handle to nil
  dcl_oid(oid_obj);
	
  // Assigning handle to location
  a_setf(oid_obj, a_getelem(t, 2, FALSE));
 
  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
  // Type checking
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 1, FALSE) == ARRAYTYPE) {    
		
    // Allocate data and copy values to the array of real
    size = a_getelemsize(t, 1, FALSE);
    data = (float *) malloc(sizeof(float) * size);
		
    a_getseqelem(t, 1, tpl_feature, FALSE);
		
    for(i = 0 ; i < size; i++) {
      data[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
    }
    
    free_tuple(tpl_feature);
		
    // Insert a new node into Xtree	
    indexID = a_getintelem(t, 0, FALSE);
    getConfig(indexID, &fconfig);

    root = getXtree(indexID);

    // This is the first put. Actually allocate memory space for Xtree
    if (root == NULL && fconfig.counter == 0) {
      fconfig.dim = size;
      root = o_xtree_make(fconfig);
      // Update 
      (*root).id = indexID;
    }

    // Dothe configuration and the input length of key agree ?
    if (size != fconfig.dim) {
      free_oid(oid_obj);
      a_error(DIM_DISAGREE ,mkinteger(fconfig.dim), FALSE);
    }
	  
    if (o_xtree_put(root, data, oid_obj, fconfig, MANUAL_INDEX)){	
      // increase the counter
      fconfig.counter++;
      updateListTree((*root).id,  root, fconfig);
    }    
  } 
  a_emit(cxt,t,FALSE);
  free_oid(oid_obj);
  return;
}
/*-----------------------------------------------------
  Delete  <key, value> from Xtree 
  Input : Integer Xid 
  Vector of Real f as key/ feature vector
  Object o as value
  Output : Boolean result. TRUE if OK. Otherwise FALSE
  -----------------------------------------------------*/
void xtree_delete(a_callcontext cxt, a_tuple t)
{
  // Input Integer xtId, Vector of Real f, Object o
  // Output Boolean
  int size, i;
  float *data;
  int indexID;

  node_type *root;
  config_type fconfig;
	
  dcl_tuple(tpl_feature);
  // Initialize a handle to nil
  dcl_oid(oid_obj);
	
  // Assigning handle to location
  a_setf(oid_obj, a_getelem(t, 2, FALSE));
  a_setf(oid_obj, cons(oid_obj, nil));
	
  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
  // Type checking
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 1, FALSE) == ARRAYTYPE ) {    
		
    // Allocate data and copy values to an array of real
    size = a_getelemsize(t, 1, FALSE);
    data = (float *) malloc(sizeof(float) * size);		
    a_getseqelem(t, 1, tpl_feature, FALSE);
		
    for(i = 0 ; i < size; i++) {
      data[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
    }
    
    free_tuple(tpl_feature);

    // Take Xtree identifier
    indexID = a_getintelem(t, 0, FALSE);

    // Find Xtee somewhere in memory
    root = getXtree(indexID);

    if (root != NULL) {
      getConfig((*root).id, &fconfig);
  
      if (size != fconfig.dim) {
        free_oid(oid_obj);
        a_error(DIM_DISAGREE ,mkinteger(fconfig.dim), FALSE);
      }	  

      if (o_xtree_delete(root, data, oid_obj, fconfig)){	
	// increase the counter
	fconfig.counter--;
	updateListTree((*root).id,  root, fconfig);
      }
    } 
  } 
  a_emit(cxt,t,FALSE);
  free_oid(oid_obj);
  return;
}

/*-----------------------------------------------------
  Get a value(s) out of Xtree 
  Input : Integer Xid 
  Vector of Real f as key : feature vector		
  Output : Bag of Object o as value(s)  
  -----------------------------------------------------*/
void xtree_get(a_callcontext cxt, a_tuple t)
{
  int size;
  int i;
  float *queryPoints;
  node_type *root;
  NN_type *tmp;
  config_type fconfig;
	
  dcl_tuple(tpl_feature);
  dcloid(ls_objects);
	
  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
 
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 1, FALSE) == ARRAYTYPE
      && (a_getelemtype(t, 2, FALSE) == REALTYPE
	  || a_getelemtype(t, 2, FALSE) == INTEGERTYPE)) {

    // Allocate data and copy values to the array of real
   
    size = a_getelemsize(t, 1, FALSE);
    a_getseqelem(t, 1, tpl_feature, FALSE);

    if (a_getelemtype(tpl_feature, 0, FALSE) == REALTYPE
	|| a_getelemtype(tpl_feature, 0, FALSE) == INTEGERTYPE) {
      queryPoints = (float *) malloc(sizeof(float) * size);
			
      for(i = 0 ; i < size; i++) {
	queryPoints[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
      }			

      root = getXtree(a_getintelem(t, 0, FALSE));
      if (root != NULL) {
	getConfig((*root).id, &fconfig);

	tmp = o_xtree_get(root, queryPoints, fconfig);
	if (tmp != NULL && tmp->oid != UNDEFINED) {
	  a_setf(ls_objects, tmp->pointer->object);
	  while(listp(ls_objects)) {
	    a_setobjectelem(t, 2, hd(ls_objects), FALSE);
	    a_emit(cxt,t,FALSE);    
	    a_setf(ls_objects, kdr(ls_objects));
	  }

	  if (ls_objects != nil){
	    a_setobjectelem(t, 2, ls_objects, FALSE);
	    a_emit(cxt,t,FALSE);
	  }	  	
	}		
      }			
    }		
  }
  free_oid(ls_objects);
  free(queryPoints);
  free_tuple(tpl_feature);
  return;

}
/*-----------------------------------------------------
  Save Xtree to file
  Input : Integer Xid 
  Charstring Filename 		
  Output : TRUE/ FALSE
  -----------------------------------------------------*/
void xtree_save(a_callcontext cxt, a_tuple t)
{
  //oidtype oid_xtId, oid_filename; 
  node_type *root;
  char* filename;	
	
  dcl_oid(oid_filename);
	
  oid_filename = a_getelem(t, 1, FALSE);
	
  // Type checking
  if (a_getelemtype(t, 0 , FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 1 , FALSE) == STRINGTYPE) {
		
    // Find Xtree in memory
    root = getXtree(a_getintelem(t, 0, FALSE));
    if (root != NULL) {
      (*root).id = a_getintelem(t, 0, FALSE);			
      filename = getstring(oid_filename);
			
      o_xtree_save(root, filename);
      a_emit(cxt,t,FALSE);			
    }
  }
  /*free_oid(oid_xtId);
    free_oid(oid_filename);*/
  return;
}
/*-----------------------------------------------------
  Load Xtree to file
  Input : Charstring Filename 		
  Output : Xtree's Id if loading is successful
  -----------------------------------------------------*/
void xtree_load(a_callcontext cxt, a_tuple t)
{
  node_type *root;
  char* filename;
	
  dcl_oid(oid_filename);
	
  oid_filename = a_getelem(t, 0, FALSE);
  // Type checking
  if (a_datatype(oid_filename) == STRINGTYPE) {
    filename = getstring(oid_filename);	
    root = o_xtree_load(filename);		
    a_setintelem(t,1, (int)((*root).id), FALSE);
    a_emit(cxt,t,FALSE);
  }
  /*free_oid(oid_filename);*/
  return;
}


/*-----------------------------------------------------
  Clear Xtree
  Input : Identifier of Xtree 		
  Output: void
  The fuction clears up memory occupied. An index file
  is also deleted. Name of the index file is formed by
  concatinating the global variable _image_file with
  the given ID of the index tree.

  Index file = image file + ID + ".xt"
  
  -----------------------------------------------------*/
void xtree_remove(a_callcontext cxt, a_tuple t)
{
  oidtype imgfile;
  char* filename;
  int xtID;
  char tmp[80];
  char buffer[80];

  printf(" \n xtree_remove BEGIN \n");
  
  // Extract identifer of to-be-removed Xtree
  xtID = a_getintelem(t, 0, FALSE);
 
 // Clear up memory occupied by Xtree 
  clearUpXtree(a_getintelem(t, 0, FALSE));

  // Get the global image file
  if(globval(mksymbol("_IMAGE-FILE_")) != nil) {
    a_let(imgfile, globval(mksymbol("_IMAGE-FILE_")));
    filename = getstring(imgfile);

    // Build a index filename with the given ID
    // - Remove dmp extension
    // - Concatinate the filename (without dmp extension)
    //   with xtID
    // - An index file has .xt as its extension
    strcpy(tmp, filename);
    filename = strtok(tmp, "." );
    if(filename != NULL ) {
      strcpy(buffer, filename);
      strcat(buffer, itoa(xtID, tmp, 10));
      strcat(buffer, ".xt");      
    }

    // Remove the index file. It returns zero if
    // the deletion is successfull.
    // Non-zero is returned if file does not exists
    // or other errors.
    remove(buffer);
  }
  return;
}


/*-----------------------------------------------------
  Define a foreign function (e.g. in C or Java) to extract a
  feature vector for each image. E.g. color spectrum, face
  features, etc. (feature extraction)
  Input :  Image fileanme on disk 		
  Output : Vector of Float representing for the color 
  histogram of the given image
  -----------------------------------------------------*/
void colorHistogramExtractor(a_callcontext cxt, a_tuple t)
{
  char sout[1000];
  char delims[] = ",";
  char *subStr = NULL;
  char *filename = NULL;
  int i = 0;
	
  dcl_oid(oid_filename);	
  dcl_tuple(res);
	
  /*Get image filename*/
  oid_filename = a_getelem(t, 0, FALSE);
  filename = getstring(oid_filename);
	
  /*Call a real implementation of ColorHistogramExtractor in Java*/
  memset(&sout, 0, 1000);			
  rc = cjProxyExecString(JAVA_METHOD_EXTRACT, &cjFacadeProxy,filename, sout);	
  CHECK_RC(rc);
	
  /*Extract the result from a string and add to the result tuple*/
  a_newtuple(res, 20,FALSE);
	
  subStr = strtok( sout, delims );
  while( subStr != NULL ) {
    a_setdoubleelem(res, i, atof(subStr) , FALSE);
    i++;
    myprintf( "result is \"%s\"\n", subStr );
    subStr = strtok( NULL, delims );
  }
	
  a_setseqelem(t,1,res,FALSE); /* Set result to vector res */
  a_emit(cxt,t,FALSE);
	
	
  /*free_oid(oid_iVector);
    free_tuple(res);*/
  return;
}

/*Shows pictures*/
void show_pictures_fn(a_callcontext cxt, a_tuple t)
{
  char sout[1000];
  char delims[] = ",";
  char *subStr = NULL;
  char *params = NULL;
  int i = 0;
	
  dcl_oid(oid_params);	
  dcl_tuple(res);
	
  /*Get the parameters*/
  oid_params = a_getelem(t, 0, FALSE);
  params = getstring(oid_params);
	
  myprintf("params %s \n", params);
  /*Call a Java function to display pictures*/
  memset(&sout, 0, 1000);			
  rc = cjProxyExecString(JAVA_METHOD_DISPLAY, &cjFacadeProxy,params, sout);	
  CHECK_RC(rc);
	
  a_emit(cxt,t,FALSE);
	
  /*free_oid(oid_iVector);
    free_tuple(res);*/
  return;
}

/* Compute index identifier from given Position of index 
 * on functionName
*/
int getXtreeIdenfifier(int pos, oidtype indexedFunction) {
  
  dcl_scan(s); 
  dcl_tuple(result);  /* To hold results from Amos function calls */
  dcl_tuple(arg);
  dcl_oid(fun);
  int indexID;
	
  // Get the function 
  a_setf(fun,
	 a_getfunction(a_callback_connection, 
		      "INTEGER.FUNCTION.GET_INDEX_IDENTIFIER->INTEGER",FALSE));

  // Initialize arguments
  a_newtuple(arg, 2, FALSE);
  a_setintelem(arg, 0, pos, FALSE);
  a_setobjectelem(arg, 1, indexedFunction, FALSE);

  // Callin Amos2 
  a_callfunction(a_callback_connection,s,fun,arg,FALSE); /* Call the function */
  // Get result
  a_getrow(s, result, FALSE);
  // Get ID from the result
  indexID = a_getintelem(result, 0, FALSE);
  myprintf("\n Index is %d \n", indexID);
  free_tuple(result);
  free_scan(s);
  free_tuple(arg);
  free_oid(fun);
  return indexID;
}


void xtree_similarity_search(a_callcontext cxt, a_tuple t, int returnDist) {
  int size;
  int i, indexID;
  float *queryPoints;
  float  distance;
  node_type *root;
  NN_type *NN;
  config_type fconfig;
  oidtype l = nil;
  
  dcl_oid(oid_iVector);
  dcl_tuple(tpl_feature);

  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
  oid_iVector = a_getelem(t, 2, FALSE);
  	
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 2, FALSE) == ARRAYTYPE
      && (a_getelemtype(t, 3, FALSE) == REALTYPE
	  || a_getelemtype(t, 3, FALSE) == INTEGERTYPE)) {
    // Allocate data and copy values from oid_iVector to 
    // the array of real
    size = a_arraysize(oid_iVector);
    if (size < 0 ) {
      size = a_getelemsize(t, 2, FALSE);
      return;
    }
    a_newtuple(tpl_feature, size, FALSE);
    a_getseqelem(t, 2, tpl_feature, FALSE);
		
    i = a_getelemtype(tpl_feature, 0, FALSE) ;

    if (a_getelemtype(tpl_feature, 0, FALSE) == REALTYPE 
	|| a_getelemtype(tpl_feature, 0, FALSE) == INTEGERTYPE) {
      queryPoints = (float *) malloc(sizeof(float) * size);
      
      for(i = 0 ; i < size; i++) {
	queryPoints[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
      }	      
		
      indexID = getXtreeIdenfifier(a_getintelem(t, 0, FALSE), 
				   a_getelem(t, 1, FALSE));
     
      root = getXtree(indexID);
      
      if (root != NULL) {
	(*root).id = indexID;
	getConfig((*root).id, &fconfig);
	distance = (float)a_getdoubleelem(t, 3, FALSE);
				
	NN = xtree_rectangle_search_tree(root, queryPoints, distance, fconfig);

	while (NN != NULL && NN->oid != UNDEFINED) {
	  a_setf(l, NN->object);
	  while(listp(l)) {
	    a_setobjectelem(t, 4, hd(l), FALSE); 
	    //a_print(hd(l));
	    if (returnDist == TRUE) {
	      a_setdoubleelem(t, 5, NN->dist, FALSE);	    
	    }
	    a_emit(cxt,t,FALSE);
	    a_setf(l, kdr(l));
	  }
	  if (l != nil){
	    a_setobjectelem(t, 4, l, FALSE);
	    //a_print(l);
	    if (returnDist == TRUE) {
	      a_setdoubleelem(t, 5, NN->dist, FALSE); 	    
	    }	   
	    a_emit(cxt,t,FALSE);
	  }
	  NN = NN->next;
	}
      }
    }
  }
  /*free(NN);
    free(queryPoints);
    free_tuple(tpl_feature);
    free_tuple(t);*/
  return;
}

/*-----------------------------------------------------
  Similarity search 
  Input :  Integer Id of X-tree , 
  Vector of Number Feature vector,
  Real  distance = difference

  Output : Bag of Objects 
  -----------------------------------------------------*/
void xtree_similarity_search_fn(a_callcontext cxt, a_tuple t)
{
  xtree_similarity_search(cxt, t, FALSE);
}

/*-----------------------------------------------------------------------
  Similarity search 
  Input :  Integer Id of X-tree , 
  Vector of Number Feature vector,
  Distance

  Output : Bag of <Object , Double dist>
  -----------------------------------------------------------------------*/

void xtree_similarity_search_objdist_fn(a_callcontext cxt, a_tuple t)
{
  xtree_similarity_search(cxt, t, TRUE) ;
}


/*-----------------------------------------------------------------------
  KNN search 
  Input :  Integer Id of X-tree , 
  Vector of Number Feature vector,
  Integer number of neighbors

  Output : Bag of Objects (oidtype) 
  -----------------------------------------------------------------------*/
void xtree_knn_search_fn(a_callcontext cxt, a_tuple t)
{
  int size;
  int i, indexID;
  float *queryPoints;
  int  k;
  node_type *root;
  NN_type *NN;
  config_type fconfig;
	
  dcl_oid(oid_iVector);
  dcl_tuple(tpl_feature);
  oidtype l = nil;
	
  myprintf("Calling %s\n",a_extpredname(cxt));
  myprintf("Parameter: %s\n",a_extpredparam(cxt));
	
  oid_iVector = a_getelem(t, 2, FALSE);
 
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 2, FALSE) == ARRAYTYPE
      && a_getelemtype(t, 3, FALSE) == INTEGERTYPE) {
		
    size = a_getelemsize(t, 2, FALSE); 
    if (size < 0 ) {			
      return;
    }
		
    a_newtuple(tpl_feature, size, FALSE);
    a_getseqelem(t, 2, tpl_feature, FALSE);
		
		
    i = a_getelemtype(tpl_feature, 0, FALSE) ;
    //if (a_getelemtype(tpl_feature, 0, FALSE) == REALTYPE) 
    {
      queryPoints = (float *) malloc(sizeof(float) * size);
			
      for(i = 0 ; i < size; i++) {
	queryPoints[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
      }

      indexID = getXtreeIdenfifier(a_getintelem(t, 0, FALSE), 
				   a_getelem(t, 1, FALSE));
      root = getXtree(indexID);
      if (root != NULL) {
	(*root).id = indexID;
	getConfig((*root).id, &fconfig);
				
	k = a_getintelem(t, 3, FALSE);
				
	NN = k_NN_search(root, queryPoints, k, fconfig);
	/*Since Xtree is now able to store multiple index.
	  Therefore, it happens that k_NN_search returns more than
	  k objects. The following code tries to return exact k
	  nearest object*/
	while (NN != NULL && NN->oid != UNDEFINED){
	  if (!listp(NN->object)) {
	    a_setf(l, appendfn(varstack, cons(NN->object, nil), l));
	  }else {
	    a_setf(l, appendfn(varstack, NN->object, l));
	  }
	  NN = NN->next;
     	}
	i = 0;  
	while(listp(l) && i < k) {
	  a_setobjectelem(t, 4, hd(l), FALSE);
	  a_emit(cxt,t,FALSE);    	  a_setf(l, kdr(l));
	  i++;
	}
	if (l != nil && i < k){
	  a_setobjectelem(t, 4, l, FALSE);
	  a_emit(cxt,t,FALSE);
	}
      }
    }
  }
  free_oid(l);
  free(NN);
  /* free(queryPoints);
     free_oid(oid_iVector);
     free_tuple(tpl_feature);
     free_tuple(t);*/
  return;
}

/*-----------------------------------------------------------------------
  End of AmosXtree implementation
  -----------------------------------------------------------------------*/
/*-----------------------------------------------------------------------
  Binding method
  ------------------------------------------------------------------------*/
/*------------------------------------------------------------------------
  Binding C functions with Amos symbolic objects
  Input  : Void		
  Output : Void
  -------------------------------------------------------------------------*/
void register_X_functions() {
  a_extfunction("xtree_make",xtree_make);
  a_setpredparam("xtree_make","create a new Xtree");
	  a_extfunction("xtree_put",xtree_put);
  a_setpredparam("xtree_put","put a pair object/value into Xtree");
	
  a_extfunction("xtree_save",xtree_save);
  a_setpredparam("xtree_save","save Xtree");
	
  a_extfunction("xtree_load",xtree_load);
  a_setpredparam("xtree_load","load Xtree");

  a_extfunction("xtree_get",xtree_get);
  a_setpredparam("xtree_get","get Xtree");

  a_extfunction("xtree_delete",xtree_delete);
  a_setpredparam("xtree_delete","delete Xtree");

  a_extfunction("xtree_remove", xtree_remove);
  a_setpredparam("xtree_remove","clear Xtree");

  a_extfunction("colorHistogramExtractor",  colorHistogramExtractor);
  a_setpredparam("colorHistogramExtractor", 
		 "extract a feature vector for each image");
	
  a_extfunction("xtree_similarity_search_fn", xtree_similarity_search_fn);
  a_setpredparam("xtree_similarity_search_fn",
		 "find node(s) that closes in a distance to the given node");

  a_extfunction("xtree_similarity_search_objdist_fn", xtree_similarity_search_objdist_fn);
  a_setpredparam("xtree_similarity_search_objdist_fn",
		 "find node(s) that closes in a distance to the given node");

  
  a_extfunction("xtree_knn_search_fn", xtree_knn_search_fn);
  a_setpredparam("xtree_knn_search_fn","find node(s) as KNN to the given node");
  
  a_extfunction("show_pictures_fn",  show_pictures_fn);
  a_setpredparam("show_pictures_fn","show pictures");
	}


/*-----------------------------------------------------
  Main function
  Input  : Command line arguments		
  Output : Void
  -----------------------------------------------------*/
main(int argc,char **argv)
{
  //dcl_connection(xtreeConn); /* To hold connection to Amos */

  char *javaArgs[] = {"-Djava.class.path=.","-Xms256m", "-Xmx512m", };
  
  // Initialize error message
  DIM_DISAGREE = 
    a_register_error("Feature vector dimensionality different from configuration");

  DELETED_NODE_FOUND = 
    a_register_error("Critical error happened since DELETED NODE was found");
  
  
  xtreeConn = a_init_connection();
  myprintf("Init configuration... \n");
  initialize(&master_config);

  init_amos(argc,argv); /* Initialize embedded Amos.
			   Notice that database image file must be specified */

  /* Binding C implementations of Amos's foregin functions */
  register_X_functions();

  /*Introduce to system a new kind of index ; Xtree index*/  register_xtree_index();

  /* Init and create Java VM*/
  memset(&jvm, 0, sizeof(cjJVM_t));
  memset(&cjFacadeClass, 0, sizeof(cjClass_t));
  memset(&cjFacadeProxy, 0, sizeof(cjObject_t));


  jvm.argc = 3;
  jvm.argv = javaArgs;
  rc = cjJVMConnect(&jvm);
  CHECK_RC(rc);

  rc = cjProxyClassCreate(&cjFacadeClass, "imgproc/CJFacade", &jvm);
  CHECK_RC(rc);

  cjFacadeProxy.clazz = &cjFacadeClass;
  rc = cjProxyCreate(&cjFacadeProxy);
  CHECK_RC(rc);

  /* The loading of init scripts on the command line is delayed until 
     first call to a_connect. The init script will now be able to use the 
     above bindings.
  */
  a_connect(xtreeConn,"",FALSE); /* Connect to embedded Amos and load init 
                                    script if specified */

  //free_connection(xtreeConn);
  amos_toploop("Amos");
  free_connection(xtreeConn);
  /*
   * Shut down Java VM
   */
  rc = cjFreeObject((cjFacadeProxy.clazz)->jvm, cjFacadeProxy.object);
  CHECK_RC(rc);

  rc = cjClassDestroy(&cjFacadeClass);
  CHECK_RC(rc);

  rc = cjJVMDisconnect(&jvm);
  CHECK_RC(rc);
  return 0;
}
