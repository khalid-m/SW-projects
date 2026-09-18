/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, EDSLAB
 * $RCSfile: Connection.java,v $
 * $Revision: 1.55 $ $Date: 2014/01/05 14:59:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Java class representing Amos II connections
 * ===========================================================================
 * $Log: Connection.java,v $
 * Revision 1.55  2014/01/05 14:59:38  torer
 * Method initializeClient() now works for basic Amos
 *
 * Revision 1.54  2012/11/11 15:20:49  torer
 * Use amos2.dmp for client callin API
 *
 * Revision 1.53  2012/11/02 07:12:51  torer
 * The dispatch between command and query in client again temporarily
 *
 * Revision 1.51  2012/07/19 20:16:17  torer
 * Connection.initializeClient() now fully based on SCSQ, not Amos II
 *
 * Revision 1.50  2012/06/27 08:17:45  torer
 * Introduced Connection.initializeClient()
 *
 * Revision 1.49  2012/06/19 16:06:41  larme597
 * executeCustom and callFunctionCustom functions added.
 *
 * Revision 1.48  2012/06/14 08:51:50  torer
 * Revert to old lock method
 *
 * Revision 1.45  2012/03/13 15:52:48  torer
 * Secondary scans removed
 *
 * Revision 1.44  2008/12/20 16:23:47  torer
 * Removed 'synchronized' for native functions
 *
 * Revision 1.43  2008/12/14 16:47:08  torer
 * Interface to a_callback_connection
 *
 * Revision 1.42  2008/11/26 20:53:28  torer
 * Added debug printing
 *
 * Revision 1.41  2007/10/10 06:56:08  torer
 * The default .dmp file is now picked from the same folder as where the
 * used system DLL is located so that javaamos.bat works exactly as amos2.exe
 *
 * Revision 1.40  2007/10/08 20:13:58  torer
 * javaamos.bat now takes command line parameters same as amos2.exe
 * e.g. javaamos -o "print('Welcome to Amos II!');"
 *
 * Revision 1.37  2007/05/10 17:17:20  torer
 * Wrapped initializeAmos to load the DLL JavaAmos.dll
 *
 * Revision 1.35  2007/05/04 15:56:49  torer
 * Added possibility to specify different Java DLLs
 *
 * Revision 1.34  2006/03/30 14:37:10  torer
 * Removed unused variuants of method callFunction
 *
 ****************************************************************************/

package callin;

public class Connection
{
    static Boolean debug = false;
    /**
     * Loads the shared library containing the C-implementations of the
     * native methods.
     */
    public static void loadDLL(String dll)
    {   
        if(debug) System.out.println("Loading DLL");
        System.loadLibrary(dll);
        if(debug) System.out.println("DLL loaded");
    }

    //
    // ===== Public interface =================================================
    //

    private static Connection theCallbackConnection=null;
    public static Connection callbackConnection()
	throws AmosException
    {
        if(theCallbackConnection == null)
	    theCallbackConnection = new Connection("**callback**");
        return theCallbackConnection;
    }  

    /**
     * Static (class) method.
     * Initializes AMOS2 and rolls in the specified image.
     * NB: Can only be called once!
     *
     * @param imageName Path to the database-image.
     * @exception AmosException if the image couldn't be found.
     */
    public static void initializeAmos(String imageName)
        throws AmosException
    {
        Connection.loadDLL("JavaAmos");
        Connection.initializeAmos0(imageName);
    }
    private static native void initializeAmos0(String imageName) 
	throws AmosException;

    /**
     * Initialization of AMOS II from command line parameters.
     * NB: Can only be called once!
     *
     * @param argv The command line arguments <image-file> <osql-file>. The
     *             system ignores arguments after <osql-file>.
     * @param dll  The DLL of Amos core system used.
     * @exception AmosException if the image couldn't be found.
     */
    public static void initializeAmos(String argv[],String dll)
	throws AmosException
    {
        Connection.loadDLL(dll);
        Connection.loadAmos(dll,argv);
    }
    public static void initializeAmos(String argv[]) throws AmosException
    {
        Connection.loadDLL("JavaAmos");
        Connection.loadAmos("JavaAmos",argv);
    }
    public static void initializeClient() throws AmosException
    {
        initializeAmos("");
    }

    /**
     * Internal function to initialize amos after DLL loaded
     * NB: Can only be called once!
     *
     * @param argv The command line arguments <image-file> <osql-file>. The
     *             system ignores arguments after <osql-file>.
     * @exception AmosException if the image couldn't be found.
     */

    public static void loadAmos(String dll,String argv[]) throws AmosException
    {
	if(debug) System.out.println("Initializing amos...");
	Connection.amosInit(dll,argv);
	if(debug) System.out.println("amos initialized");
    }
    private static native void amosInit(String dll,String argv[]); 

    /**
     * Constructor.
     * Connects to an AMOS2 server with the specified name.
     * To connect to the local database specify "" as dbName.
     * Uses the private method init().
     *
     * @param dbName Name of the AMOS2 to connect to. "" means
     *               the local database.
     * @exception AmosException if the connection-attempt fails.
     * @see callin.Connection#init
     */
    public Connection(String dbName) throws AmosException
    {
	this.init(dbName);
    }

    /**
     * Constructor.
     * Connects to an AMOS2 server with the specified name managed by the
     * AMOS2 nameserver running on the IP host nameServerHost.
     * To connect to the local database specify "" as dbName.
     * Uses the private method init().
     *
     * @param dbName Name of the AMOS2 to connect to. "" means
     *               the local database.
     * @exception AmosException if the connection-attempt fails.
     * @see callin.Connection#init
     */
    public Connection(String dbName, String nameServerHost) 
	throws AmosException
    {
	Connection lc = localConnection();
    
	lc.execute("nameserverhost('"+nameServerHost+"');");
	this.init(dbName);
    }

    /**
     * Get the connection to the local database
     */

    private static Connection thelocalConnection;
    public static Connection localConnection() throws AmosException
    {
	if(thelocalConnection==null) thelocalConnection = new Connection("");
	return thelocalConnection;
    }

    /**
     * Destructor.
     * Uses the private method destroy().
     *
     * @see callin.Connection#destroy
     */
    protected void finalize()
    {
	this.destroy();
    }

    /**
     * Drops this connection.
     *
     * @exception AmosException if the disconnection fails.
     * @see callin.Connection#destroy
     */
    public native void disconnect() throws AmosException;

    /**
     * Initialize the Java interface. 
     * Binds all declared Java foreign-functions to their external predicates
     * and loads their corresponding classes.
     */
    public static native void initJava();

    // ---------- Embedded queries ----------
    /**
     * Executes AMOSQL statements in the embedded database.
     *
     * @param query The AMOSQL statement to be executed.
     * @return A scan.
     * @exception AmosException if the query fails.
     * @see callin.Scan
     */
    public  native Scan execute(String query) 
	throws AmosException;

    /**
     * Executes AMOSQL statements in the embedded database. Returns a Scan with
     * no more then the specified number of elements.
     *
     * @param query The AMOSQL statement to be executed.
     * @param stopAfter The maximum number of elements to be
     *                  returned in the Scan.
     * @return A scan.
     * @exception AmosException if the query fails.
     * @see callin.Scan
     */
    public  native Scan execute(String query, int stopAfter) 
	throws AmosException;

    /**
     * Creates a custom scan based on AMOSQL query.
     *
     * @param query The AMOSQL query.
     * @param options Specification string.
     * @return A scan.
     * @exception AmosException if the query fails.
     * @see callin.Scan
     */
    public  native Scan executeCustom(String query, String options)
	throws AmosException;

    // ---------- Top-loop ----------
    /**
     * Calls the interactive AMOSQL top-loop. The call returns if the AMOSQL
     * command exit; is executed. By contrast, the AMOSQL command quit;
     * terminates the program.
     *
     * @param prompt The string used as prompt.
     */
    public  native void amosTopLoop(String prompt);

    // ---------- Transaction control ----------
    /**
     * Commits a transaction.
     *
     * @exception AmosException if the commit-operation fails.
     */
    public  native void commit() throws AmosException;

    /**
     * Rollbacks (aborts) a transaction.
     *
     * @exception AmosException when the rollback of the database fails.
     */
    public  native void rollback() throws AmosException;

    // ---------- Fast-path ----------
    /**
     * Returns the function-object named fnName. The function objects are
     * cached so calling this function with the same argument twice (or more) 
     * results in using the cached value.
     *
     * @param fnName A function-name (ex. "charstring.typenamed->type")
     * @return A function-object.
     * @exception AmosException if the function named fnName doesn't exist.
     */
    public Oid getFunction(String fnName) throws AmosException
    {
	String hashKey = fnName + connectionPointer;
	Oid tmpOid = (Oid)Connection.fnCache.get(hashKey);

	if (tmpOid == null)
	    {
		tmpOid = this.getFunctionInternal(fnName);
		Connection.fnCache.put(hashKey, tmpOid);
	    }
	return tmpOid;
    }

    /**
     * Clears the cache of function objects.
     */
    public  static void clearFunctionCache()
    {
	Connection.fnCache = new java.util.Hashtable();
    }

    /**
     * Calls the function corresponding to the function-object fnObject
     * (obtained from Connection.getFunction()) with the arguments given in
     * the tuple fnArgs. The arity of the function is set with Tuple.setArity()
     * or Tuple.Tuple(int) and the argument-values is set with Tuple.setElem().
     * The result is a scan.
     *
     * @param fnObject The function-object to call.
     * @param fnArgs The arguments to the function.
     * @return A scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#getFunction
     * @see callin.Scan
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     * @see callin.Oid
     */
    public  native Scan callFunction(Oid fnObject, Tuple fnArgs)
	throws AmosException;

    /**
     * Calls the function corresponding to the function-object fnObject
     * (obtained from Connection.getFunction()) with the arguments given in
     * the tuple fnArgs. The arity of the function is set with Tuple.setArity()
     * or Tuple.Tuple(int) and the argument-values is set with Tuple.setElem().
     * The result is a scan with no more then stopAfter elements.
     *
     * @param fnObject The function-object to call.
     * @param fnArgs The arguments to the function.
     * @param stopAfter The maximum number of elements to be
     *                  returned in the Scan.
     * @return A scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#getFunction
     * @see callin.Scan
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     * @see callin.Oid
     */
    public  native Scan callFunction(Oid fnObject, Tuple fnArgs, 
				     int stopAfter)
	throws AmosException;

    /**
     * Calls the function fnName with the arguments given in the tuple fnArgs.
     * The arity of the function is set with Tuple.setArity() or
     * Tuple.Tuple(int) and the argument-values is set with Tuple.setElem().
     * The result is a scan.
     *
     * @param fnName The function-name to call.
     * @param fnArgs The arguments to the function.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     * @see callin.Scan
     */
    public Scan callFunction(String fnName, Tuple fnArgs) throws AmosException
    {
	return (callFunction(getFunction(fnName), fnArgs));
    }

    /**
     * Calls the function fnName with the arguments given in the tuple fnArgs.
     * The arity of the function is set with Tuple.setArity() or
     * Tuple.Tuple(int) and the argument-values is set with Tuple.setElem().
     * The result is a scan with no more then stopAfter elements.
     *
     * @param fnName The function-name to call.
     * @param fnArgs The arguments to the function.
     * @param stopAfter The maximum number of elements to be
     *                  returned in the Scan.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     * @see callin.Scan
     */
    public Scan callFunction(String fnName, Tuple fnArgs, int stopAfter)
	throws AmosException
    {
	return (callFunction(getFunction(fnName), fnArgs, stopAfter));
    }

    /**
     * Calls the function corresponding to the function-object fnObject
     * (obtained from Connection.getFunction()) with the arguments given in
     * the tuple fnArgs. The arity of the function is set with Tuple.setArity()
     * or Tuple.Tuple(int) and the argument-values is set with Tuple.setElem().
     * The result is a scan.
     *
     * @param fnObject The function-object to call.
     * @param fnArgs The arguments to the function.
     * @param options Specification string.
     * @return A scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#getFunction
     * @see callin.Scan
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     * @see callin.Oid
     */
    public  native Scan callFunctionCustom(Oid fnObject, Tuple fnArgs, 
                                           String options)
	throws AmosException;

    public Scan callFunctionCustom(String fnName, Tuple fnArgs, 
				   String options)
	throws AmosException
    {
	return (callFunctionCustom(getFunction(fnName), fnArgs, options));
    }


    /**
     * Convenience variation of callFunction
     *
     * @param fname The name of the function to be called.
     * @param arg The Oid argument to the function.
     * @return An Oid.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Oid callOidFunction(String fname, Oid arg) throws AmosException
    {
	return (callFunction(fname, arg).getRow().getOidElem(0));
    }

    /**
     * Convenience variation of callFunction
     *
     * @param fname The name of the function to be called.
     * @param arg The Oid argument to the function.
     * @return A Tuple.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Tuple callTupleTupleFunction(String fname, Oid arg) 
	throws AmosException
    {
	return (callFunction(fname, arg).getRow().getSeqElem(0));
    }

    /**
     * Convenience variation of callFunction
     *
     * @param fname The name of the function to be called.
     * @param arg The Oid argument to the function.
     * @return A String.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public String callStringFunction(String fname, Oid arg) 
	throws AmosException
    {
	Scan theScan = callFunction(fname, arg);
	return getString(theScan);
    }

    /**
     * Convenience variation of callFunction
     *
     * @param fname The name of the no-argument function to be called.
     * @return A String.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public String callStringFunction(String fname) throws AmosException
    {
	Scan theScan = callFunction(fname);
	return getString(theScan);
    }

    /**
     * Convenience variation of callFunction
     *
     * @param name The name of the no-argument function to be called.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Scan callFunction(String name) throws AmosException
    {
	return (callFunction(name, new Tuple(0)));
    }

    /**
     * Convenience variation of callFunction
     *
     * @param name The name of the function to be called.
     * @param arg The Oid argument to the function.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Scan callFunction(String name, Oid arg) throws AmosException
    {
	return (callFunction(name, new Tuple(arg)));
    }

    /**
     * Convenience variation of callFunction
     *
     * @param name The name of the function to be called.
     * @param arg The String argument to the function.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Scan callFunction(String name, String arg) throws AmosException
    {
	return (callFunction(name, new Tuple(arg)));
    }

    /**
     * Convenience variation of callFunction
     *
     * @param fn The function-object to call.
     * @param arg The Oid argument to the called function.
     * @return A Scan.
     * @exception AmosException if the function-call fails.
     * @see callin.Connection#callFunction(callin.Oid, callin.Tuple)
     */
    public Scan callFunction(Oid fn, Oid arg) throws AmosException
    {
	return (callFunction(fn, new Tuple(arg)));
    }

    // ---------- Create objects ----------
    /**
     * Creates an object of the type corresponding to the type-object type.
     * Created objects are removed with Oid.deleteObject() or
     * Connection.deleteObject().
     *
     * @param type The type of the object to be created.
     * @return An oid.
     * @exception AmosException if the object couldn't be created.
     * @see callin.Connection#deleteObject
     * @see callin.Oid#delete
     */
    public native Oid createObject(Oid type) throws AmosException;

    /**
     * Creates an object of the type corresponding to the named type.
     * Created objects are removed with Oid.deleteObject() or
     * Connection.deleteObject().
     *
     * @param typeName The name of the type of the object to be created.
     * @return An oid.
     * @exception AmosException if the object couldn't be created.
     * @see callin.Connection#deleteObject
     * @see callin.Oid#delete
     */
    public Oid createObject(String typeName) throws AmosException
    {
	return createObject(getType(typeName));
    }

    /**
     * Returns the type-object with the name typeName.
     *
     * @param typeName A type-name.
     * @return An oid.
     * @exception AmosException if the type doesn't exist.
     */
    public native Oid getType(String typeName) 
	throws AmosException;

    // ---------- Delete objects ----------
    /**
     * Deletes an object from the database.
     *
     * @param theObject The object to be deleted.
     * @exception AmosException if the object couldn't be deleted.
     * @see callin.Oid#delete
     */
    public native void deleteObject(Oid theObject) 
	throws AmosException;

    // ---------- Stored functions ----------
    /**
     * Assigns a new value to a single valued AMOS function.
     * The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the assigned function.
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the function couldn't be assigned.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public native void setFunction(Oid fn, Tuple argList, 
				   Tuple resList) 
	throws AmosException;

    /**
     * Assigns a new value to a single valued AMOS function.
     * The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the assigned function.
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the function couldn't be assigned.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public void setFunction(String fnName, Tuple argList, Tuple resList) 
	throws AmosException
    {
	setFunction(getFunction(fnName),argList, resList);
    }

    /**
     * Adds a new tuple to the values of a bag valued AMOS function.
     * The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the affected function.
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the function-value couldn't be added.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public native void addFunction(Oid fn, Tuple argList, 
				   Tuple resList) 
	throws AmosException;

    /**
     * Adds a new tuple to the values of a bag valued AMOS function.
     * The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the affected function.
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the function-value couldn't be added.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public void addFunction(String fnName, Tuple argList, Tuple resList) 
	throws AmosException
    {
	addFunction(getFunction(fnName),argList,resList);
    }

    /**
     * Removes a result tuple from a bag of result tuples for a given argument
     * tuple. The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the affected function.
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the tuple couldn't be removed.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public native void remFunction(Oid fn, Tuple argList, 
				   Tuple resList) 
        throws AmosException;

    /**
     * Removes a result tuple from a bag of result tuples for a given argument
     * tuple. The arity of the functions argument and result is set with
     * Tuple.setArity() or Tuple.Tuple(int). The values of the argument(s)
     * and the result(s) is assigned with Tuple.setElem().
     *
     * @param fn The function-object corresponding to the affected function
     * @param argList The arguments to the function.
     * @param resList The result of the function.
     * @exception AmosException if the tuple couldn't be removed.
     * @see callin.Oid
     * @see callin.Tuple
     * @see callin.Tuple#setArity
     * @see callin.Tuple#setElem
     */
    public void remFunction(String fnName, Tuple argList, Tuple resList) 
	throws AmosException
    {
	remFunction(getFunction(fnName),argList,resList);
    }

    // ---------- Object retrieval ----------
    /**
     * Retrieves the object with a specified ID-number.
     *
     * @param idno The ID-number of the object to be retrieved.
     * @return The object with ID-number idno.
     * @exception AmosException if the object doesn't exist.
     */
    public native Oid getObjectNumbered(int idno) 
	throws AmosException;

    // ---------- Error reporting ----------
    /**
     * Prints the native a_errform variable on the console.
     */
    public native void printErrForm();

    //
    // ===== Private interface ===============================================
    //

    /**
     * Holds the pointer-value of a variable declared with dcl_connection().
     * In C, the type a_connection is declared as:<br>
     * typedef struct ... *a_connection;<br>
     * It is safe to save this pointer because once such a pointer is declared
     * it doesn't change value. Of course, this implementation relies on the
     * fact that sizeof(struct ... *) = 4.
     */
    private volatile int connectionPointer;

    /**
     * This static hashtable is used for caching the function objects returned
     * by getFunctionInternal(). The hashtable uses closed hashing with a 
     * table-size of 101 and a loadfactor of 75%.
     * The hashtable can be cleared with the static method
     * Connection.clearFunctionCache()
     *
     * @see java.util.Hashtable
     * @see callin.Connection#clearFunctionCache
     */

    private static java.util.Hashtable fnCache = new java.util.Hashtable();
    /**
     * Used by the constructor because constructors can't be native.
     * Does a dcl_connection() and saves the a_connection value in
     * this.connectionPointer. Initializes and connects to an embedded
     * AMOS2 with the specified name. Sets up the error trap.
     *
     * @param dbName Name of the AMOS2 peer to connect to.
     *                  "" means the local database.
     * @exception AmosException if the connection-attempt fails.
     * @see callin.Connection#connectionPointer
     */

    private native void init(String dbName)
	throws AmosException;
    /**
     * Used by the destructor because destructors can't be native.
     * Called when this object is about to be garbage-collected.
     * Does free_connection().
     *
     * @see callin.Connection#finalize
     */

    private native void destroy();
    /**
     * Returns the function-object named fnName.
     * Used by Connection.callFunction(String) and Connection.getFunction().
     *
     * @param fnName A function-name (ex. "charstring.typenamed->type")
     * @return A function-object.
     * @exception AmosException if the function doesn't exist.
     * @see callin.Connection#callFunction(String)
     * @see callin.Connection#getFunction
     */
    private native Oid getFunctionInternal(String fnName) 
	throws AmosException;
    /**
     * Internal function. Used by callStringFunction(...).
     * Returns a String or null from a Scan.
     *
     * @param theScan The Scan from witch the String is to be returned.
     * @return A String or null if the Scan didn't contain a String.
     * @exception AmosException if the String couldn't be returned for some
     *                          reason.
     * @see callin.Connection#callStringFunction(java.lang.String, callin.Oid)
     * @see callin.Connection#callStringFunction(java.lang.String)
     */
    private String getString(Scan theScan) throws AmosException
    {
	if (theScan.eos()) return null;
	Tuple result = theScan.getRow();
	if (result.getArity() == 0) return null;
	return (result.getStringElem(0));
    }
}
