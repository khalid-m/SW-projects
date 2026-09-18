/*****************************************************************************
 * *** DEMONTRATION ON HOW TO INTRODUCE A NEW INDEXING STRUCTURETO AMOS II ***
 * 
 * In this demontration a standard hash table available in Java is introduced
 * to AMOS II. This is done through implementing a set of foreign functions in
 * Java, namely make, put, get, delete, mapper and clear.
 *
 * In order to run a full demo, after compiling this file, you need to start
 * JavaAmos and make corresponding foreign function defenitions in Amos.
 ****************************************************************************/

import java.util.*;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;

import callin.*;
import callout.*;
public class ExinmaDemo {

    // A list of hash tables(s) with unique id for each.
    private  static  Hashtable<Integer, Hashtable<Integer, Oid>> m_lhashes;

    // Id base, starts from 0
    private  int idgen = 0;

    // Main entry
    public static void main(String argv[]) throws AmosException {

    }

    /**
       Default constructor.
    */
    public ExinmaDemo() {
	// Put initializations here
    }
    
    /*-----------------------------------------------------------------
      Find Hash table given its identifier
      Note that the first PUT always constructs the MYMAP
     -----------------------------------------------------------------*/
    private Hashtable<Integer, Oid> locateMyMap(int id) {
	// Initialize the list if needed.
	if (m_lhashes == null) {
	    m_lhashes = new Hashtable<Integer, Hashtable<Integer, Oid>>();
 	} 

	Integer key = new Integer(id);	
	Hashtable<Integer, Oid> m = m_lhashes.get(key);

	// If there is no such MYMAP
	if (m == null) {
	    // Construct a new one
	    m = new Hashtable<Integer, Oid>(); 
	    // Put it into our managed list.
	    m_lhashes.put(key, m);
	}
	return m;
    }
    /*-----------------------------------------------------------------
      MAKE simply returns an id     
     -----------------------------------------------------------------*/
    public void mymap_make(CallContext cxt, Tuple tpl)throws AmosException{
	tpl.setElem(0, idgen);
	idgen += 1;
	System.out.println("mymap_make");
	cxt.emit(tpl);
    }

    /*-----------------------------------------------------------------
      PUT puts <key, val> into a Hash table given its Id.
     -----------------------------------------------------------------*/
    public void mymap_put(CallContext cxt, Tuple tpl)throws AmosException{
	// Get the id 
	int id = tpl.getIntElem(0);
	int keyOid = tpl.getIntElem(1);
	Oid val =  tpl.getOidElem(2);
	Integer key = new Integer(keyOid);
	
	Hashtable<Integer, Oid>  m = locateMyMap(id);

	if (m != null){
	    m.put(key, val);
	}
	// Emit
	tpl.setElem(3, val);
	cxt.emit(tpl);
    }
    /*-----------------------------------------------------------------
      GET returns val associated with the given key
     -----------------------------------------------------------------*/
    public void mymap_get(CallContext cxt, Tuple tpl)throws AmosException{
	// Get the id 
	int id = tpl.getIntElem(0);
	int keyOid = tpl.getIntElem(1);
	Oid val = null;
	Integer key = new Integer(keyOid);
	Hashtable<Integer, Oid> m = locateMyMap(id);
	if (m != null){
	   val = m.get(key);
	   if (val != null) {
	       tpl.setElem(2, val);
	   }
	}
	cxt.emit(tpl);
    }
    /*-----------------------------------------------------------------
      DELETE deletes (key,val) pair
     -----------------------------------------------------------------*/
    public void mymap_delete(CallContext cxt, Tuple tpl)throws AmosException{
	int id = tpl.getIntElem(0);
	int keyOid = tpl.getIntElem(1);
	Integer key = new Integer(keyOid);

	Hashtable<Integer, Oid> m = locateMyMap(id);
	if (m != null){
	    m.remove(key);
	}
	cxt.emit(tpl);
    }
    /*-----------------------------------------------------------------
      MAPPER iterates through a Hash table and returns (key, val)
     -----------------------------------------------------------------*/
    public void mymap_mapper(CallContext cxt, Tuple tpl)throws AmosException{
	int id = tpl.getIntElem(0);
	Integer key;
	Oid val;
	Tuple res = new Tuple(2);
	/*Do the iteration and emit the result*/
	Hashtable m = locateMyMap(id);
	if (m != null){
	    Enumeration keys = m.keys();
	    while (keys.hasMoreElements()){
		key = (Integer)keys.nextElement();
		val = (Oid)m.get(key);
		res.setElem(0, val);
		res.setElem(1, key);
		tpl.setElem(1, res);
		cxt.emit(tpl);	
	    } 
	}
	return;
    }
    /*-----------------------------------------------------------------
      CLEAR flushes away entire MYMAP given its Id
     -----------------------------------------------------------------*/
    public void mymap_clear(CallContext cxt, Tuple tpl)throws AmosException{
	int id = tpl.getIntElem(0);

	Hashtable m = locateMyMap(id);
	if (m != null){
	    m_lhashes.remove(m);
	}

	cxt.emit(tpl);
    }    
}
