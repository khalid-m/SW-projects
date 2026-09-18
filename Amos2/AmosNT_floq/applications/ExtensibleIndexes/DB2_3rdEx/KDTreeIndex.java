/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: KDTreeIndex.java,v $
 * $Revision: 1.10 $ $Date: 2013/11/18 19:23:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Index manager based on KDTree
 * ===========================================================================
 * $Log: KDTreeIndex.java,v $
 * Revision 1.10  2013/11/18 19:23:20  thatr500
 * added mapping functions
 *
 * Revision 1.9  2011/03/03 09:54:55  thatr500
 * comments
 *
 * Revision 1.8  2011/02/27 15:26:23  thatr500
 * add comments
 *
 * Revision 1.7  2011/02/27 10:27:45  thatr500
 * *** empty log message ***
 *
 * Revision 1.6  2011/02/27 10:07:13  torer
 * Updated lab. Use term 'proximity search'
 *
 * Revision 1.5  2011/02/26 14:06:18  thatr500
 * no crash when KDTree is empty
 *
 * Revision 1.4  2011/02/25 18:51:21  thatr500
 * add stubs
 *
 * Revision 1.4  2011/02/25 02:48:57  thatr500
 * change to kdtreeSimilaritySearch
 *
 * Revision 1.3  2011/02/24 17:32:20  thatr500
 * *** empty log message ***
 *
 * Revision 1.2  2011/02/24 08:38:30  thatr500
 * remove KNN and add similarity search
 *
 * Revision 1.1  2011/02/22 21:58:42  thatr500
 * Unite all extensible indexes and their tests at one place.
 *
 * Revision 1.2  2011/02/22 00:00:19  thatr500
 * *** empty log message ***
 *
 * Revision 1.1  2011/02/15 02:23:28  thatr500
 * KDTree -another extension of index
 *
 *
 ****************************************************************************/
import edu.wlu.cs.levy.CG.*;

import java.util.List;
import java.util.Iterator;
import callin.*;
import callout.*;

import java.util.*;

public class KDTreeIndex {
    // A list of KD-tree(s) with unique id for each.
    private  static Hashtable<Integer, 	KDTree<Oid>> m_lkdtrees;

    // Id base number starts from 10
    private  static int idgen = 10;

    // Number of dimensions = 1.
    // It will be overwrite at the fisrt PUT
    private static int dim = -1;
    

    // Main entry
    public static void main(String argv[]) throws AmosException {
	// Initialize somethings if needed.
    }

    /**
       Default constructor.
    */
    public KDTreeIndex() {
	// Put initializations here
    }
    
    /*-----------------------------------------------------------------
      Find KD-tree given its identifier
     -----------------------------------------------------------------*/
    private KDTree<Oid> locateKdtree(int id) throws AmosException{
	if (id == 0){
	    return null;
	}
	// Initialize the list if needed.
	if (m_lkdtrees == null) {
	    m_lkdtrees = new Hashtable<Integer, KDTree<Oid>>();
 	} 
	Integer ID = new Integer(id);
	
	KDTree<Oid> m = m_lkdtrees.get(ID);

	// If there is no such KD-tree
	if (m == null) {
	    // Construct a new one
	    m = new KDTree<Oid>(dim); 
	    // Put it into our list.
	    m_lkdtrees.put(ID, m);
	}
	return m_lkdtrees.get(ID);
    }
    /*-----------------------------------------------------------------
      Extract Vector of Number stored in tpl to an array of double(s)
     -----------------------------------------------------------------*/
    private double[] toArray(Tuple tpl) throws AmosException {
	if (dim == -1) {
	    dim = tpl.getArity();
	}
	double[] key = new double[dim];
	
	for (int i = 0; i < dim; i++){
	    key[i] = tpl.getDoubleElem(i);
	}
	return key;
    }
    /*-----------------------------------------------------------------
      kdtree_make simply returns an id     
     -----------------------------------------------------------------*/
    public void kdtree_make(CallContext cxt, Tuple tpl)throws AmosException{
	// Increase idgen by 1
	idgen += 1;
	// Return the current value 
	tpl.setElem(0, idgen);
	cxt.emit(tpl);
    }

    /*-----------------------------------------------------------------
      kdtree_put puts <key, val> into a KD-tree given its Id.
      The first PUT always constructs the KD-tree
     -----------------------------------------------------------------*/
    public void kdtree_put(CallContext cxt, Tuple tpl) 
	throws AmosException, KeySizeException, KeyDuplicateException {
	// Get the id 
	int id = tpl.getIntElem(0);
	// Extract feature vector f as key
	double [] key  = toArray(tpl.getSeqElem(1));
	// Get Amos object to val type of Oid 
	Oid val =  tpl.getOidElem(2);
	
	// Get the KD-tree whose id = id	
	KDTree<Oid>  m = locateKdtree(id);
	if (m != null){
	    // Insert to KD-tree
	    m.insert(key, val);
	}
	// Emit the val back
	tpl.setElem(3, val);
	cxt.emit(tpl);
    }
    /*-----------------------------------------------------------------
      GET returns val associated with the given key
     -----------------------------------------------------------------*/
    public void kdtree_get(CallContext cxt, Tuple tpl)throws AmosException, 
	KeyDuplicateException, KeySizeException {
	// Get the id 
	int id = tpl.getIntElem(0);
	// Extract feature vector f as key
	double [] key  = toArray(tpl.getSeqElem(1));
	// Amos object 
	Oid val = null;
	// Get the KD-tree whose id = id	
	KDTree<Oid> m = locateKdtree(id);
	if (m != null){
	    // Search in KD-tree val associated with key
	    val = m.search(key);
	    if (val != null) {
		// Set the return val and emit
		tpl.setElem(2, val);		
		cxt.emit(tpl);
	    }
	}
    }
    /*-----------------------------------------------------------------
      kdtree_delete deletes (key,val) pair
     -----------------------------------------------------------------*/
    public void kdtree_delete(CallContext cxt, Tuple tpl)
	throws AmosException, KeyDuplicateException, KeySizeException,
	KeyMissingException{
	// Get the id 
	int id = tpl.getIntElem(0);
	// Extract feature vector f as key
	double [] key  = toArray(tpl.getSeqElem(1));

	// Get the KD-tree whose id = id
	KDTree<Oid> m = locateKdtree(id);
	if (m != null){
	    // Delete a node (key, val) 
	    m.delete(key);
	}
	cxt.emit(tpl);
    }

    /*-----------------------------------------------------------------
      KDDTree does not support iterating over all keys - Index Full Scan
     -----------------------------------------------------------------*/
    
    /*-----------------------------------------------------------------
      kdtree_clear flushes away entire KD-tree given its Id
     -----------------------------------------------------------------*/
    public void kdtree_clear(CallContext cxt, Tuple tpl)
	throws AmosException{
	// Get the id 
	int id = tpl.getIntElem(0);
	// Get the KD-tree whose id = id
	KDTree  m = locateKdtree(id);
	if (m != null){
	    // remove from the list.
	    m_lkdtrees.remove(m);
	}
	cxt.emit(tpl);
    }    
     public void kdtree_map(CallContext cxt, Tuple tpl) 
	throws AmosException, KeySizeException, KeyDuplicateException {
	//Get the id as Integer at position 0
	int id = tpl.getIntElem(0);
	
	// Make lower and upper
	double [] upper = new double [dim];
	double [] lower = new double [dim];

	for(int i = 0; i < dim; i ++) {
	    upper[i] = 99999999;
	    lower[i] = -99999999;
	}
	// Get the KD-tree whose id = id	
	KDTree<Oid>  m = locateKdtree(id);
	if (m != null){
	    List<Oid> lnn =  m.range(lower, upper);
	    if (lnn != null && lnn.size() > 0) {		
		for(Oid val : lnn) {		    
		    tpl.setElem(1, val);
		    cxt.emit(tpl);
		}

	    }	    
	}

    }

    /*-----------------------------------------------------------------
      Find KD-tree nodes whose keys are closer within a distance to key. 
     -----------------------------------------------------------------*/
    public void kdtreeProximitySearch(CallContext cxt, Tuple tpl)
	throws AmosException,
	KeySizeException,
	java.lang.IllegalArgumentException {
	// Get the id 
	int id = tpl.getIntElem(0);
	// Extract feature vector f as key
	double [] key  = toArray(tpl.getSeqElem(1));
	// Get the distance 
        double dist =  tpl.getDoubleElem(2);

	// Get the KD-tree whose id = id
	KDTree<Oid>  m = locateKdtree(id);
	
	if (m != null && m.size() > 0){
	    //Find KD-tree nodes whose keys are nearest in dist. 
	    List<Oid> lnn =  m.nearestEuclidean(key, dist);
	    if (lnn != null && lnn.size() > 0) {		
		// Loop through and emit the result
		for(Oid val : lnn) {		    
		    tpl.setElem(3, val);
		    cxt.emit(tpl);
		}
	    }
	}
    }
}
