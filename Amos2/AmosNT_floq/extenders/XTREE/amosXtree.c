/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 thanh, UDBL . 
 * $RCSfile: amosXtree.c,v $
 * $Revision: 1.5 $ $Date: 2013/08/01 13:02:27 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II <--> Xtree
 * 
 * ===========================================================================
 * $Log: amosXtree.c,v $
 * Revision 1.5  2013/08/01 13:02:27  thatr500
 * Xtree is handled by mexima_generic_api
 *
 * Revision 1.4  2013/02/28 06:56:56  torer
 * OSX option
 *
 * Revision 1.3  2013/01/18 14:35:40  thatr500
 * - removed printf
 * - added commandline assignment3.cmd
 *
 * Revision 1.2  2013/01/09 15:01:45  thatr500
 * Index extension is self contained : defining a new index type
 *
 * Revision 1.1  2012/01/04 14:48:49  thatr500
 * add Xtree extender
 *
 * Revision 1.20  2011/05/02 06:19:27  thatr500
 * used a_load_extension instead of manually loading dynamic library
 *
 * Revision 1.19  2011/03/19 15:14:10  thatr500
 * separated Mexima and Xtree code
 *
 * Revision 1.18  2011/03/05 00:07:30  thatr500
 * better indentation
 *
 * Revision 1.17  2011/02/26 19:49:00  thatr500
 * rename function 'similarity' to 'distance'
 *
 * Revision 1.16  2011/02/26 18:25:56  thatr500
 * rename function similarity to distance
 *
 * Revision 1.15  2011/01/25 12:24:51  thatr500
 * supports EXINMA delivered as a DLL (Windows)
 *
 * Revision 1.14  2010/12/20 18:38:49  thatr500
 * fix deallocation problem
 *
 * Revision 1.13  2010/12/14 19:06:18  thatr500
 * adding a global flag to turn ON/OFF Exinma
 *
 * Revision 1.12  2010/12/07 16:41:51  thatr500
 * *** empty log message ***
 *
 * Revision 1.11  2010/12/01 19:20:01  thatr500
 * use EXSTMA to integerate Xtree
 *
 * Revision 1.10  2010/11/22 08:57:16  thatr500
 * compact all index files into one
 *
 * Revision 1.9  2010/11/06 12:35:25  thatr500
 * fix Segmentation fault with rollback
 *
 * Revision 1.8  2010/11/03 07:02:50  thatr500
 * *** empty log message ***
 *
 * Revision 1.7  2010/11/02 08:13:40  thatr500
 * deallocation of Xtree
 *
 * Revision 1.6  2010/10/27 18:46:31  torer
 * OS independent int to char* conversion
 *
 * Revision 1.5  2010/10/27 18:05:45  torer
 * Wrong call to itoa
 *
 * Revision 1.4  2010/10/27 15:50:48  thatr500
 * Fix: itoa does not exist in all Unix systems
 *
 * Revision 1.3  2010/08/23 14:32:22  thtr1663
 * *** empty log message ***
 *
 * Revision 1.2  2010/08/23 14:27:42  thtr1663
 * add xtree package
 *
 * Revision 1.1  2010/08/20 13:45:33  thtr1663
 * add xtree package
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
EXTERN oidtype appendfn(bindtype, oidtype, oidtype);
#include "xtreeconst.h"

/*-----------------------------------------------------
  Convert from key to list of floats
-----------------------------------------------------*/

/*Convert from key to list of floats */
float* getFeatures(oidtype key) {
  int size = 0, i;
  float* feature;
	
  // Get size of the array
  size = dr(key, arraycell)->size;
  
  feature = (float *) malloc(sizeof(float) * size);
		
  // Loop and build the feature
  for (i = 0; i < size ; i ++) {
    if (a_datatype(dr(key, arraycell)->cont[i]) == INTEGERTYPE) {
      feature[i] = 
	(float) dr((dr(key, arraycell)->cont[i]), integercell)->integer;
    }else if (a_datatype(dr(key, arraycell)->cont[i]) == REALTYPE) {
      feature[i] = (float) getreal(dr(key, arraycell)->cont[i]);
    } 
  }	
  return feature;
}

/*-----------------------------------------------------
  Traverse a tree and set free object handle to Amos II
-----------------------------------------------------*/
void free_object_handle(node_type *node, config_type fconfig) {
  int i, count;

  if (node == NULL || node->ptr == NULL){
    return;
  }

  count = fconfig.M * node->snodeSize - node->vacancy;
  for (i = 0; i < count; i++) {
    if (node->ptr[i] != NULL) {
      if (node->ptr[i]->attribute != LEAF){
	free_object_handle(node->ptr[i], fconfig);
      } else {
	a_free(node->ptr[i]->object);
      }
    }
  }
}


/*-----------------------------------------------------
  Save Xtree to file
  Input : Integer Xid 
  Charstring Filename 		
  Output : TRUE/ FALSE
  -----------------------------------------------------*/
void xtree_save(a_callcontext cxt, a_tuple t)
{
  char* filename;
  char buffer[80];	
  ListTree_type * tmp;
  FILE *fp;

  dcl_oid(oid_filename);	
  a_assign(oid_filename, a_getelem(t, 0, FALSE));

  // Type checking
  if (a_getelemtype(t, 0 , FALSE) == STRINGTYPE) {
     tmp = m_listTreeHead;
     if (tmp != NULL) {
      // Open file for appending to the end
      filename = getstring(oid_filename);
      if (filename != NULL) {	
	strcpy(buffer, filename);
	strcat(buffer, ".xtree");
	
	fp = fopen(buffer, "w+");
	if (fp) {
	  // Loop through and save
	  if (tmp != NULL && tmp->address != NULL) {
	    do {
	      o_xtree_save(fp, (node_type*)tmp->address, filename);
	      // Move to next tree
	      tmp = tmp->next;
	      fprintf(fp,"%d\n", (tmp == NULL)? 0 :1 );
	    }while(tmp != NULL);
	  }
	}
	// Close file
	fclose(fp);	
      }
    
      a_emit(cxt,t,FALSE);			
    }
  }
  free_oid(oid_filename);
  return;
}
/*-----------------------------------------------------
  Load Xtree to file
  Input : Charstring Filename 		
  Output : Xtree's Id if loading is successful
  -----------------------------------------------------*/
void xtree_load(a_callcontext cxt, a_tuple t)
{
  char* filename;
  char buffer[80];
  FILE *fp;
  int cont, id;
    
  dcl_oid(oid_filename);	
  a_assign(oid_filename, a_getelem(t, 0, FALSE));
    
  // Type checking
  if (a_datatype(oid_filename) == STRINGTYPE) {
  
    // Open file for reading
    filename = getstring(oid_filename);
    if (filename != NULL) {
      strcpy(buffer, filename);
      strcat(buffer, ".xtree");
      
      // file does  exist ?
      fp = fopen(buffer, "r");
      if(fp != NULL){
	// Load trees
	do {
	  id = o_xtree_load(fp, filename);
	
	  // Keep the maximum id
	  idgenerator = (idgenerator >= id)? idgenerator : id;
	
	  fscanf(fp, "%d\n", &cont);
	
	} while( feof(fp) == 0);      
	// Close file
	fclose(fp);
      }
    }
    a_emit(cxt,t,FALSE);
  }
  
  free_oid(oid_filename);
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

/* -----------------------------------------------------
   Find all points within a distance.
   THIS IS NOT SIMIMLARITY SEARCH.
 -----------------------------------------------------*/
void distance_search(a_callcontext cxt, a_tuple t, int returnDist) {
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

      indexID = getIndexIdonFunction(a_getintelem(t, 0, FALSE), 
				   a_getelem(t, 1, FALSE));
     
      root = getXtree(indexID);
      
      if (root != NULL) {
	(*root).id = indexID;
	getConfig((*root).id, &fconfig);
	distance = (float)a_getdoubleelem(t, 3, FALSE);
				
	NN = xtree_rectangle_search_tree(root, queryPoints, 
					 distance, fconfig);

	while (NN != NULL && NN->oid != UNDEFINED) {
	  a_setf(l, NN->object);

	  /*Mutiple index*/
	  if (listp(l)) {
	    while(listp(l) && hd(l)) {
	      a_setobjectelem(t, 4, hd(l), FALSE); 
	      if (returnDist == TRUE) {
		a_setdoubleelem(t, 5, NN->dist, FALSE);	    
	      }
	      a_emit(cxt,t,FALSE);    
	      a_setf(l, kdr(l));
	    }
	    
	    if (l != nil && listp(l)) {
	      a_setobjectelem(t, 4, hd(l), FALSE);
	      if (returnDist == TRUE) {
		a_setdoubleelem(t, 5, NN->dist, FALSE); 	    
	      }
	      a_emit(cxt,t,FALSE);
	    }
	  } else if (arrayp(l)){
	    /*Unique index*/
	    a_setobjectelem(t, 4, l, FALSE);
	    if (returnDist == TRUE) {
	      a_setdoubleelem(t, 5, NN->dist, FALSE); 	    
	    }
	    a_emit(cxt,t,FALSE);
	  }     
	  // Move to another NN
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

void xtree_distance_search(a_callcontext cxt, a_tuple t) {
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

  oid_iVector = a_getelem(t, 1, FALSE);
  	
  if (a_getelemtype(t, 0, FALSE) == INTEGERTYPE 
      && a_getelemtype(t, 1, FALSE) == ARRAYTYPE
      && (a_getelemtype(t, 2, FALSE) == REALTYPE
	  || a_getelemtype(t, 2, FALSE) == INTEGERTYPE)) {
    // Allocate data and copy values from oid_iVector to 
    // the array of real
    size = a_arraysize(oid_iVector);
    if (size < 0 ) {
      size = a_getelemsize(t, 1, FALSE);
      return;
    }
    a_newtuple(tpl_feature, size, FALSE);
    a_getseqelem(t, 1, tpl_feature, FALSE);
		
    i = a_getelemtype(tpl_feature, 0, FALSE) ;

    if (a_getelemtype(tpl_feature, 0, FALSE) == REALTYPE 
	|| a_getelemtype(tpl_feature, 0, FALSE) == INTEGERTYPE) {
      queryPoints = (float *) malloc(sizeof(float) * size);
			
      for(i = 0 ; i < size; i++) {
	queryPoints[i] = (float)a_getdoubleelem(tpl_feature, i, FALSE);
      }		      

      indexID = a_getintelem(t, 0, FALSE);
     
      root = getXtree(indexID);
      
      if (root != NULL) {
	(*root).id = indexID;
	getConfig((*root).id, &fconfig);
	distance = (float)a_getdoubleelem(t, 2, FALSE);
				
	NN = xtree_rectangle_search_tree(root, queryPoints, distance, fconfig);

	while (NN != NULL && NN->oid != UNDEFINED) {
	  a_setf(l, NN->object);
	
	  a_setobjectelem(t, 3, l, FALSE);
	  a_emit(cxt,t,FALSE);

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

/*-----------------------------------------------------------------------
  Similarity search 
  Input :  Integer Id of X-tree , 
  Vector of Number Feature vector,
  Distance

  Output : Bag of <Object , Double dist>
  -----------------------------------------------------------------------*/

void xtree_distance_search_fn(a_callcontext cxt, a_tuple t)
{
  distance_search(cxt, t, TRUE) ;
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
			
      indexID = getIndexIdonFunction(a_getintelem(t, 0, FALSE), 
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
	    a_setf(l, cons(NN->object, l));
	  }else { 
            oidtype p;
            for(p=NN->object;p!=nil;p=tl(p))
	      {
                a_setf(l, cons(hd(p), l));
              }
	    /*a_setf(l, appendfn(varstack, NN->object, l));*/
	  }
	  NN = NN->next;
	  } 
	i = 0;  
	while(listp(l) && i < k) {
	  a_setobjectelem(t, 4, hd(l), FALSE);
	  a_emit(cxt,t,FALSE);    	 
	  a_setf(l, kdr(l));
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
