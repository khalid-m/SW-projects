/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: KDTreeIndex.java,v $
 * $Revision: 1.6 $ $Date: 2011/03/02 08:49:55 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Index manager based on KDTree
 * ===========================================================================
 * $Log: KDTreeIndex.java,v $
 * Revision 1.6  2011/03/02 08:49:55  thatr500
 * *** empty log message ***
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
    private  int idgen = 10;
    private  int dim = 1;

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
	    // Put it into our managed list.
	    m_lkdtrees.put(ID, m);
	}
	return m_lkdtrees.get(ID);
    }
    
    private double[] toArray(Tuple tpl) throws AmosException {
	if (dim != tpl.getArity()) {
	    dim = tpl.getArity();
	}
	double[] key = new double[dim];
	
	for (int i = 0; i < dim; i++){
	    key[i] = tpl.getDoubleElem(i);
	}
	return key;
    }
    /*-----------------------------------------------------------------
      MAKE simply returns an id     
     -----------------------------------------------------------------*/
    public void kdtree_make(CallContext cxt, Tuple tpl)throws AmosException{
	idgen += 1;
	tpl.setElem(0, idgen);
	cxt.emit(tpl);
    }

    /*-----------------------------------------------------------------
      PUT puts <key, val> into a KD-tree given its Id.
      The first PUT always constructs the KDTREE
     -----------------------------------------------------------------*/
    public void kdtree_put(CallContext cxt, Tuple tpl) 
	throws AmosException, KeySizeException, KeyDuplicateException {
	// Get the id 
	int id = tpl.getIntElem(0);
	double [] key  = toArray(tpl.getSeqElem(1));
	Oid val =  tpl.getOidElem(2);
	
	KDTree<Oid>  m = locateKdtree(id);
	
	if (m != null){
	   m.insert(key, val);
	}
	// Emit
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
	// Get the key
	double [] key  = toArray(tpl.getSeqElem(1));
	// Get the val
	Oid val = null;
	KDTree<Oid> m = locateKdtree(id);
	if (m != null){
	   val = m.search(key);
	   if (val != null) {
	       tpl.setElem(2, val);
	       cxt.emit(tpl);
	   }
	}
    }
    /*-----------------------------------------------------------------
      DELETE deletes (key,val) pair
     -----------------------------------------------------------------*/
    public void kdtree_delete(CallContext cxt, Tuple tpl)
	throws AmosException, KeyDuplicateException, KeySizeException,
	KeyMissingException{
	int id = tpl.getIntElem(0);
	double [] key  = toArray(tpl.getSeqElem(1));

	KDTree<Oid> m = locateKdtree(id);
	if (m != null){
	    m.delete(key);
	}
	cxt.emit(tpl);
    }

    /*-----------------------------------------------------------------
      KDDTree does not support iterating over all keys - Index Full Scan
     -----------------------------------------------------------------*/
    
    /*-----------------------------------------------------------------
      CLEAR flushes away entire KDTREE given its Id
     -----------------------------------------------------------------*/
    public void kdtree_clear(CallContext cxt, Tuple tpl)
	throws AmosException{
	int id = tpl.getIntElem(0);
	KDTree  m = locateKdtree(id);
	if (m != null){
	    m_lkdtrees.remove(m);
	}
	cxt.emit(tpl);
    }    
    
    /*-----------------------------------------------------------------
      Find KD-tree nodes whose keys are closer within a distance to key. 
     -----------------------------------------------------------------*/
    public void kdtreeProximitySearch(CallContext cxt, Tuple tpl)
	throws AmosException,
	KeySizeException,
	java.lang.IllegalArgumentException {
	
	int id = tpl.getIntElem(0);
	double [] key  = toArray(tpl.getSeqElem(1));
        double dist =  tpl.getDoubleElem(2);
	
	//System.out.println(id);
	
	KDTree<Oid>  m = locateKdtree(id);

	if (m != null && m.size() > 0){
	    //Find KD-tree nodes whose keys are nearest in dist. 
	    List<Oid> lnn =  m.nearestEuclidean(key, dist);
	    if (lnn != null && lnn.size() > 0) {		
		for(Oid val : lnn) {
		    tpl.setElem(3, val);
		    cxt.emit(tpl);
		}
	    }
	}
    }
}
