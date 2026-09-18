package orwise;

import java.util.HashMap;
import java.util.Vector;
import callin.*;
import callout.*;

/** abstract superclass for implemented HTML-Wrappers.
 * @author Simon Zürcher, University of Uppsala
 * @version ?
 */
abstract class SearchEngine {

    //the Vectors contain arrays of Strings which represent the columns in the table
    protected Oid oidMyType;
    protected Vector url= new Vector();
    protected Vector title= new Vector();
    protected Vector subject=new Vector();
    protected String searchEngine;
    static Connection theConnection;
    protected Tuple arg1=new Tuple(1);
    protected Tuple res1=new Tuple(1);
    protected int count;

    SearchEngine() {}

    /** abstract method used by all subclass search engines
     * @params Vector propertiesVector
     * @return SearchEngine
     * @throws Callin.AmosException
     */
    abstract SearchEngine callWrapper(Vector propertiesVector) throws AmosException;

    String getURL(int i){
	return (String)this.url.elementAt(i);
    }

    String getTitle(int i){
	return (String)this.title.elementAt(i);
    }

    String getSubject(int i){
	return (String)this.subject.elementAt(i);
    }

    String getSearchEngine(){
	return this.searchEngine;
    }

    /** sets the Connection to AMOS II for the HTML-wrapper
     * @params Connection c
     * @return void
     * @throws Callin.AmosException
     */
    public static void setConnection(Connection c) throws AmosException {
	if (c != null) {
	    theConnection = c;
	}
	else {
	    System.err.println("Error while setting the Connection for SearchEngine");
	    throw new AmosException("Error while setting the Connection for SearchEngine");
	}
    }

    /** Fills an AMOS object "Document" with the data retrieved from the Internet
     * @params Oid oidDocument
     * @params int positionInVector
     * @return void
     * @throws Callin.AmosException
     */
    void fillFunctions(Oid oidObject, int i) throws AmosException{

	Oid fUrl, fTitle, fSubject, fSearchEngine;

	try{
	    fUrl = SearchEngine.theConnection.getFunction("DOCUMENT.URL->CHARSTRING");
	    fTitle = SearchEngine.theConnection.getFunction("DOCUMENT.TITLE->CHARSTRING");
	    fSubject = SearchEngine.theConnection.getFunction("DOCUMENT.SUBJECT->CHARSTRING");
	    fSearchEngine = SearchEngine.theConnection.getFunction("DOCUMENT.SEARCHENGINE->CHARSTRING");
	}
	catch(AmosException e){
	    System.err.println(e);
	    throw e;
	}

	try{
	    arg1.setElem(0, oidObject);
	    //writing the general data in the functions of the new object
	    //write Title

	    if (this.title.elementAt(i)==null){
		res1.setElem(0,"");
	    }
	    else{
		res1.setElem(0,this.getTitle(i));
	    }
	    theConnection.addFunction(fTitle,arg1,res1);

	    //write URL
	    if (this.url.elementAt(i)==null){
		res1.setElem(0,"");
	    }
	    else{
		res1.setElem(0,this.getURL(i));
	    }
	    theConnection.addFunction(fUrl,arg1,res1);

	    //write Subject
	    if (this.subject.elementAt(i)==null){
		res1.setElem(0,"");
	    }
	    else{
		res1.setElem(0,this.getSubject(i));
	    }
	    theConnection.addFunction(fSubject,arg1,res1);

	    //write SearchEngine
	    if (this.searchEngine==null){
		res1.setElem(0,"");
	    }
	    else{
		res1.setElem(0,this.searchEngine);
	    }
	    theConnection.addFunction(fSearchEngine,arg1,res1);
	} //try

	catch(AmosException e){
	    System.err.println(e);
	    throw e;
	}
    } // writeInformation

    /** Shows the common properties the user has entered for the started Search Engine
     * @params int entriesPerPage
     * @params int pages
     * @params String query
     * @params String searchEngine
     * @params int positionInVectors
     * @return void
     */
    // this method caused problems in AMOS II, when the 'String searchEngine' is the first method argument
    void showProperties(int entriesPerPage, int pages, String query, String searchEngine){
	DebugSE.tracer.msg("Search Engine: " + searchEngine);
	DebugSE.tracer.msg("Query: " + query);
	DebugSE.tracer.msg("Pages: " + pages);
	DebugSE.tracer.msg("Entries per page: " + entriesPerPage);
    }

    /*Checks, if a String can be converted to a Double
     */
    /** Checks, if a String can be converted to a Double and returns a Double if possible
     * @params String s
     * @return Double
     * @throws Callin.AmosException
     */
    Double dTest(String s) throws NumberFormatException{
	Double x=new Double(0.0);
	try{
	    x = new Double(s);
	}
	catch(NumberFormatException e){
	    throw e;
	}
	return x;
    }

    /** returns a Hashmap for a specific search engine
     *  @param Vector vec
     *  @param String thisSE
     *  @return HashMap hm
     *  @throws Callin.AmosException
     */
    HashMap getHashMap(Vector propertiesVec, String thisSE) throws AmosException{
	String seString;
	HashMap hm = new HashMap();
	for(int t = 0; t < propertiesVec.size(); t = t + 2){
	    seString = (String)(propertiesVec.elementAt(t));
	    if(seString.equalsIgnoreCase(thisSE)){
		hm = (HashMap)(propertiesVec.elementAt(t + 1));
		return hm;
	    }
	}
	throw new AmosException("HashMap not found for search engine " + thisSE);
    }

    /** changes the value of the key "results" in a Hashmap from a String to int.
     *  @param  Vector vec
     *  @param int hashmapNumber
     *  @return void
     *  @throws Callin.AmosException
     */
    private void changeResultsToInt(HashMap hm) throws AmosException{
	Integer integer = new Integer(0);
	String strResult = "";
	strResult = (String)(hm.get("results"));
	try{
	    hm.put("results", integer.valueOf(strResult));
	}
	catch (NumberFormatException e){
	    System.err.println("NumberFormatException: results can not be converted into Integer");
	    throw new AmosException ("NumberFormatException: results can not be converted into Integer");
	}
    }

    /** checks the argument "results" on possential errors
     *  @param  HashMap hm
     *  @param String currentSE
     *  @return void
     *  @throws Callin.AmosException
     */
    void exceptionCheckResults(HashMap hm, String currentSE) throws AmosException{
	Integer integerResults = new Integer(0);
	String results = (String)hm.get("results");
        if(results == null){
	    System.err.println("number of results in search engine " + currentSE + " is null");
	    throw new AmosException("number of results in search engine " + currentSE + " is null");
        }
        //change the String-Value "results" to Integer in all HashMaps
        try{
            this.changeResultsToInt(hm);
	}
	catch (AmosException e){
            System.out.println("Error: " + e);
            return;
	}
	integerResults = (Integer)hm.get("results");
	int intResults = integerResults.intValue();
	if(intResults < 1){
            System.err.println("results < 1 for " + currentSE);
            throw new AmosException("results < 1 for " + currentSE);
	}
    }

    /** checks if the argument "query" is null
     *  @param  HashMap hm
     *  @param String currentSE
     *  @return void
     *  @throws Callin.AmosException
     */
    void exceptionCheckQuery(HashMap hm, String currentSE) throws AmosException{
	String query = (String)hm.get("query");
	if(query == null){
	    System.err.println("empty query in search engine " + currentSE);
	    throw new AmosException("empty query in search engine " + currentSE);
	}
    }
}
