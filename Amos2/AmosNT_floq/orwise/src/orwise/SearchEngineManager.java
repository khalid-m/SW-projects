package orwise;

import callin.*;
import callout.*;
import java.util.Vector;
import java.util.HashMap;

/** Initializes and starts the wrapper wrappers (W_[SearchEngine]).
 * @author Simon Zürcher, University of Uppsala
 * @version ?
 */
class SearchEngineManager {
    private Connection theConnection;
    Vector propertiesVector;
    Vector seContainer;

    // Constructor
    SearchEngineManager() throws AmosException {
	try{
	    theConnection = new Connection("");
	    SearchEngine.setConnection(theConnection);
	}
	catch(AmosException e){
	    System.err.println(e);
	    throw e;
	}
    }

    /** The main function ('foreign function') which can be started from AMOS II.
     *  @param CallContext cxt
     *  @param Tuple tpl
     *  @return void
     *  @throws Callin.AmosException
     */
    void webSearch(CallContext cxt, Tuple tpl) throws AmosException {

	/*
	  -> the class 'SearchEngineManager' has never been created and instanciated in the Javacode
	  Amos creates an instance automaticaly when creating a new foreign function therefor we
	  are able to access the class SearchEngineManager('this').*/
	seContainer = new Vector();
	//the method arguments entered in AMOS II
	Tuple properties = new Tuple();
	//represents the Oid of a new Object of the Type defined by the wrapper
	Oid oidObject;
	propertiesVector = new Vector();
	SearchEngine specificSE = null;

	// get the method arguments from AMOS
	try{
	    properties = tpl.getSeqElem(0);
	}
	catch(AmosException e){
	    System.err.println("Exception while reading arguments from Amos: "+e);
	    return;
	}
	//put the properties into a vector
	propertiesVector = this.tupleToVector(properties);

	for (int u = 0; u < propertiesVector.size() - 1; u = u + 2){
	    // create the requested search engines which are in the properties vector...
	    String wrapper = (String)(propertiesVector.get(u));
	    try{
		specificSE = this.wrapperFactory(wrapper);
	    }
	    catch(ClassNotFoundException e){
		System.out.println("Error: " + e);
		throw new AmosException("ClassNotFoundException");
	    }
	    // the seContainer contains all called engines (used for a for-loop)
	    seContainer.addElement(specificSE);
	}

	for (int v = 0; v < seContainer.size(); v++){
	    // ...and start the wrapper
	    specificSE = (SearchEngine)(seContainer.elementAt(v));
	    try{
		specificSE = specificSE.callWrapper(propertiesVector);
	    }
	    catch(AmosException e){
		System.out.println(e);
		throw e;
	    }
	    int results = specificSE.count;
	    DebugSE.tracer.msg("Objects found: "+ results);
	    if (results > 0){
		for(int i = 0; i < results; i++){
		    //create a new object of type defined by the wrapper
		    try{
			oidObject = theConnection.createObject(specificSE.oidMyType);
		    }
		    catch(AmosException e){
			System.out.println("Error while creating Amos object: "+e);
			oidObject = null;
			return;
		    }
		    DebugSE.tracer.msg("adding Object #"+ i + ": " + oidObject +" *****");
		    // insert all the values into AMOS
		    specificSE.fillFunctions(oidObject, i);
		    // put the object into the query-queue
		    tpl.setElem(1,oidObject);
		    cxt.emit(tpl);
		} //inner for (iterate over found entries)
	    } //if
	} //outer for (iterate over search engines)
    } // method metaSearch

    /** The factory method for dynamic loading and instantiating of the wrapper-wrappers
     *  @param String searchEngine
     *  @return SearchEngine SE
     */
    private SearchEngine wrapperFactory(String searchEngine) throws ClassNotFoundException{
	String MyType;
	SearchEngine SE;
	Class seClass = null;
	SearchEngine seInstance;
	String loadThis = "orwise.W_" + searchEngine;

	try {
	    // Load class
	    seClass = Class.forName(loadThis);
	} catch (NoClassDefFoundError e) {
	    throw e;
	} catch(ClassNotFoundException e){
	    System.err.println("wrapper class could not be found, names of wrappers are case sensitive");
	    throw e;
	}

	try {
	    // Instantiate class
	    seInstance = (SearchEngine)seClass.newInstance();
	} catch(InstantiationException ie) {
	    ie.printStackTrace();
	    return null;
	} catch(IllegalAccessException iae) {
	    iae.printStackTrace();
	    return null;
	}
	return seInstance;
    }

    /** Puts the websearch arguments (Input-Tuple) into a Vector which looks like
     *  {String searchEngine, HashMap propertiesOfPrecedingSearchEngine, String searchEngine, HashMap propertiesOfPrecedingSearchEngine...}
     *  @param Tuple tpl
     *  @return Vector vec
     */

    Vector tupleToVector(Tuple tpl){
	Vector vec = new Vector();
	HashMap hm = new HashMap();
	String seString = "";
	String key = "";
	String value = "";
	int arity, aritySE;
	Tuple optionsSE;
	try{
	    arity = tpl.getArity();
	}
	catch(AmosException e){
	    System.err.println("Amos-Error in Orwis: "+e);
	    return null;
	}
	for (int p = 0; p < arity; p++){ // Iterate inside the top-level tpl over all SEs
	    try{
		optionsSE = tpl.getSeqElem(p);      // get the 2nd level vectors ({name,{key,value},{key,value}...}
		aritySE = optionsSE.getArity();
		seString = (optionsSE.getStringElem(0));  // extract the SE-String out of the input tuple
	    }
	    catch(AmosException e){
		System.out.println("Amos-Error in Orwis: "+e);
		return null;
	    }
	    hm = new HashMap();
	    try{
		for (int w = 1; w < (aritySE); w++){
		    if (optionsSE.getSeqElem(w) != null){
			Tuple temp = new Tuple();
			temp = optionsSE.getSeqElem(w);
			key = (String)(temp.getStringElem(0));
			value = (String)(temp.getStringElem(1));
			hm.put(key, value); // fill the Vector which contains all the property couples of a SE
		    }
		}
	    }
	    catch(AmosException e){
		System.out.println("Amos-Error (reading): "+e);
		return null;
	    }
	    vec.addElement(seString);
	    vec.addElement(hm);
	}
	return vec;
    }
}
