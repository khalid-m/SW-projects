package callin;
import java.lang.*;

/**
  * Class corresponding to the AMOS-datatype tuple.
  * Tuples are used when passing data from Java to AMOS2 and vice versa.
  *
  * @author Daniel Elin
  * @version 1.7 (Last modified 990419)
  */
public class Tuple {

  //
  // ===== Public interface ===================================================
  //

  /**
    * Constructor.
    * Uses the private method init().
    *
    * @see callin.Tuple#init
    */
  public Tuple() {
    this.init();
  }

  /**
   * Prefered constructor.
   * Creates a Tuple-object with specified arity.
   * Uses the private method init()
   *
   * @param arity The arity of the Tuple
   * @see callin.Tuple#init(int)
   */
  public Tuple(int arity) {
    this.init(arity);
  }

  /**
    * Constructor to create a Tuple with one single object.
    * Useful when calling functions.
    *
    * @param obj The object to be the first and only object in the created tuple.
    * @exception AmosException if the creation of the object fails.
    * @see callin.Tuple#setElem(Oid)
    */
  public Tuple(Oid obj) throws AmosException {
    this(1);
     try
    {
      this.setElem(0, obj);
    }
    catch(AmosException err)
    {
      System.out.println("Error in tuple-constructor: Tuple(Oid obj)");
    }
  }

  /**
    * Constructor to create a Tuple with one single string.
    * Useful when calling functions.
    *
    * @param str The string to be the first and only object in the created tuple.
    * @exception AmosException if the creation of the string fails.
    * @see callin.Tuple#setElem(String)
    */
  public Tuple(String str)
  {
    this(1);
    try
    {
      this.setElem(0, str);
    }
    catch(AmosException err)
    {
      System.out.println("Error in tuple-constructor: Tuple(String str)");
    }
  }

  /**
    * Destructor.
    * Javas equivalent of a C++ destructor. Called when the object is up for
    * garbage-collection.
    * Uses the private method destroy().
    *
    * @see callin.Tuple#destroy
    */
  protected void finalize() {
    this.destroy();
  }

  // ---------- Conversion ----------
  /**
    * Converts this Tuple to a java.util.Vector-object.
    * The elements of the Vector can themselves be Vectors (the case when the
    * Tuple contains other Tuples), Integers, Doubles, Strings or Oids.<br><br>
    * [] = Tuple, () = Vector, _ = Integer, Double, String or Oid.<br>
    * [] => ()<br>
    * [_] => (_)<br>
    * [_ _ _ ...] => (_ _ _ ...)<br>
    * [[_ _ _ ...] ...] => ((_ _ _ ...) ...)<br>
    * And so on recursivly...<br><br>
    *
    * NB. THIS METHOD CAN BE VERY INEFFICIENT (TIME AND SPACE) IF THE ARITY OF
    * THE TUPLE IS >>1!!!<br><br>
    *
    * IMPORTANT!!!<br>
    * UNDER NO CIRCUMSTANCES CAN THE METHODS clone() AND copyInto() BE
    * CALLED FOR THIS VECTOR OR ANY CONTAINING VECTORS IF THEY CONTAIN ANY
    * OBJECT OF TYPE OID!!! SUCH CALLS WILL RESULT IN AN AMOS CRASH WHEN THE
    * GARBAGE-COLLECTOR TRIES TO RECLAIM SPACE.
    *
    * @return A Vector containing the elements of this Tuple as dscribed above.
    * @exception AmosException if the vector couldn't be constructed.
    * @see java.lang.Integer
    * @see java.lang.Double
    * @see java.lang.String
    * @see callin.Oid
    * @see java.util.Vector
    */
  public java.util.Vector toVector() throws AmosException {
    java.util.Vector theVector = new java.util.Vector(0);
    int arity;
    if ((arity = this.getArity()) > 0) {
      for(int i = 0; i < arity; i++) {
        Object e = this.getElem(i);
        theVector.addElement((e instanceof Tuple) ? ((Tuple)e).toVector() : e);
      }
    }
    return (theVector);
  }

/**
    * Converts this Tuple to a java.util.Vector-object similarly to 
    * the above toVector, but objects of class Oid are encoded as 
    * strings '[OID id]'. 
    * Added for the purposes of remote clients of Amos2 as a web service.
    * 
    * @return A Vector containing the elements of this Tuple as dscribed above.
    * @exception AmosException if the vector couldn't be constructed.
      */
    public java.util.Vector toRemoteVector() throws AmosException {
    java.util.Vector theVector = new java.util.Vector(0);
    int arity;
    if ((arity = this.getArity()) > 0) {
      for(int i = 0; i < arity; i++) {
        Object e = this.getElem(i);
	if (e instanceof Tuple)
	    theVector.addElement(((Tuple)e).toVector()); 
	else if (e instanceof Oid){
	    String s= "[OID " + ((Oid) e).getID()+ "]";
	    theVector.addElement(s);}
	else theVector.addElement(e);
      }
    }
    return (theVector);
  }

  // ---------- Arity ----------
  /**
    * Returns the number of elements (width of) in this tuple.
    *
    * @return The arity.
    * @exception AmosException if the arity couldn't be determined.
    */
  public native int getArity() throws AmosException;

  /**
    * Sets the number of elements (width of) in this tuple.
    *
    * @param arity The arity.
    */
  public native void setArity(int arity);

  // ---------- Retrieving elements of this tuple ----------
  /**
    * Returns the element #pos of this tuple as a string.
    *
    * WARNING!!! STRINGS LONGER THAN 1024 BYTES WILL CAUSE A SEGFAULT!!!
    * This is not a bug in Amos but a limitation imposed by the native
    * implementation!
    *
    * @param pos The element to be returned.
    * @return A string.
    * @exception AmosException if the string couldn't be retrieved.
    */
  public native String getStringElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as an integer.
    *
    * @param pos The element to be returned.
    * @return An integer.
    * @exception AmosException if the integer couldn't be retrieved.
    */
  public native int getIntElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as a double.
    *
    * @param pos The element to be returned.
    * @return A double.
    * @exception AmosException if the double couldn't be retrieved.
    */
  public native double getDoubleElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as a byte buffer.
    *
    * @param pos The element to be returned.
    * @return A byte buffer.
    * @exception AmosException if the double couldn't be retrieved.
    */
  public native byte[] getBinaryElem(int pos) throws AmosException; //AA

  /**
    * Returns the element #pos of this tuple as a boolean.
    *
    * @param pos The element to be returned.
    * @return A double.
    * @exception AmosException if the boolean couldn't be retrieved.
    */
  public native boolean getBooleanElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as an Oid-object.
    *
    * @param pos The element to be returned.
    * @return An Oid.
    * @exception AmosException if the Oid-object couldn't be retrieved.
    */
  public native Oid getOidElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as a Tuple object.
    *
    * @param pos The element to be returned.
    * @return A Tuple.
    * @see callin.Tuple
    * @exception AmosException if the Tuple couldn't be retrieved.
    */
  public native Tuple getSeqElem(int pos) throws AmosException;

  /**
    * Returns the element #pos of this tuple as a java.lang.Object.
    * Amos integers corresponds to java.lang.Integer objects, reals to
    * java.lang.Double objects, strings to java.lang.Strings and Oids to
    * callin.Oid objects.
    *
    * @param pos The element to be returned.
    * @return A java.lang.Object as described above.
    * @see callin.Oid
    * @exception AmosException if the object couldn't be retrieved.
    */
  public native java.lang.Object getElem(int pos) throws AmosException;

  // ---------- Setting elements of this tuple ----------
  /**
    * Stores a string in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param str The string to be stored.
    * @exception AmosException if the string couldn't be stored.
    */
  public native void setElem(int pos, String str) throws AmosException;

  /**
    * Stores a byte buffer as string in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param str The string to be stored.
    * @exception AmosException if the string couldn't be stored.
    */
  public native void setElem(int pos, byte[] str, int len) 
                                                   throws AmosException;

/**
    * Stores a byte buffer as Binary in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param arr The byte buffer to be stored.
    * @param size The number of bytes to store.
    * @exception AmosException if the bytes couldn't be stored.
    */
  public native void setBinaryElem(int pos, byte[] arr, int size) 
      throws AmosException; //AA
  /**
    * Adds a string in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param str The string to be stored.
    * @exception AmosException if the string couldn't be stored.
    */
  public native void addElem(int pos, String str) throws AmosException;

  /**
    * Adds a byte buffer as string in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param str The string to be stored.
    * @exception AmosException if the string couldn't be stored.
    */
  public native void addElem(int pos, byte[] str, int len) 
                                                   throws AmosException;

  /**
    * Stores an integer in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param integer The integer to be stored.
    * @exception AmosException if the integer couldn't be stored.
    */
  public native void setElem(int pos, int integer) throws AmosException;

  /**
    * Stores a double in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param dbl The double to be stored.
    * @exception AmosException if the double couldn't be stored.
    */
  public native void setElem(int pos, double dbl) throws AmosException;

  /**
    * Stores a boolean in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param obj The Oid-object to be stored.
    * @see callin.Oid
    * @exception AmosException if the Oid-object couldn't be stored.
    */
  public native void setElem(int pos, boolean z) throws AmosException;

  /**
    * Stores an Oid-object in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param obj The Oid-object to be stored.
    * @see callin.Oid
    * @exception AmosException if the Oid-object couldn't be stored.
    */
  public native void setElem(int pos, Oid obj) throws AmosException;

   /**
    * Stores a sequence (Tuple-object) in element pos of this tuple.
    *
    * @param pos The element to be set.
    * @param obj The sequence to be stored.
    * @see callin.Tuple
    * @exception AmosException if the Tuple-object couldn't be stored.
    */
  public native void setElem(int pos, Tuple tpl) throws AmosException;

  /**
    * Stores a java.lang.Object in element pos of this tuple.
    * Amos integers corresponds to java.lang.Integer objects, reals to
    * java.lang.Double objects, strings to java.lang.Strings and Oids to
    * callin.Oid objects.
    *
    * @param pos The element to be set.
    * @param obj Thw java.lang.Object to be stored (as described above)
    * @exception AmosException if the Object couldn't be stored.
    */
  public native void setElem(int pos, java.lang.Object obj) throws AmosException;

  //
  // ===== Type testing =======================================================
  //

  /**
    * Is the element in position pos a string?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a string
    * @exception AmosException if the comparison fails.
    */
  public native boolean isString(int pos) throws AmosException;

  /**
    * Is the element in position pos an integer?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is an integer
    * @exception AmosException if the comparison fails.
    */
  public native boolean isInteger(int pos) throws AmosException;

  /**
    * Is the element in position pos a double?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a double
    * @exception AmosException if the comparison fails.
    */
  public native boolean isDouble(int pos) throws AmosException;

  /**
    * Is the element in position pos a binary?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a binary
    * @exception AmosException if the comparison fails.
    */
  public native boolean isBinary(int pos) throws AmosException; //AA

  /**
    * Is the element in position pos an object (OID)?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is an object (OID)
    * @exception AmosException if the comparison fails.
    */
  public native boolean isObject(int pos) throws AmosException;

  /**
    * Is the element in position pos a tuple?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a tuple
    * @exception AmosException if the comparison fails.
    */
  public native boolean isTuple(int pos) throws AmosException;

  /**
    * Is the element in position pos a legal Boolean (true,false,nil)?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a tuple
    * @exception AmosException if the comparison fails.
    */
    public boolean isBoolean(int pos) throws AmosException {
	Object e = this.getElem(pos);

        return e==null || 
               e.equals(new Boolean(true)) ||
               e.equals(new Boolean(false));
    }


  /**
    * Is the element in position pos null?
    *
    * @param pos The element to be tested
    * @return true if element in position pos is a tuple
    * @exception AmosException if the comparison fails.
    */
    public boolean isNull(int pos) throws AmosException {
	return this.getElem(pos)==null;
    }
   
  //
  // ===== Private interface ==================================================
  //

  /**
    * Holds the pointer-value of a variable declared with dcl_tuple().
    * In C, the type a_tuple is declared as:<br>
    * typedef struct ... *a_tuple;<br>
    * It is safe to save this pointer because once such a pointer is declared
    * it doesn't change value. Of course, this implementation relies on the
    * fact that sizeof(struct ... *) = 4.
    */
  private volatile int tuplePointer = 0;

  /**
    * Holds a pointer-value to the Connection this Scan belongs to.
    */
  private Connection theConnection;

  /**
    * Constructor. Used by the C-code.
    *
    * @param theTuple Initializes this.tuplePointer.
    * @param theConnection Initializes this.theConnection.
    * @see callin.Tuple#tuplePointer
    * @see callin.Tuple#theConnection
    */
  private Tuple(int theTuple, Connection theConnection) {
    this.theConnection = theConnection;
    this.tuplePointer = theTuple;
  }

  /**
    * Used by the constructor because constructors can't be native.
    * Does a dcl_tuple().
    */
  private native void init();

  /**
    * Used by the prefered constructor because constructors can't be native.
    * Constructs a tuple with the specified width.
    *
    * @param arity The width of the tuple to be constructed.
    */
  private native void init(int arity);

  /**
    * Used by the destructor because destructors cant be native.
    * Called when this object is about to be garbage-collected.
    * Does free_tuple().
    *
    * @see callin.Tuple#finalize
    */
  private native void destroy();

}



