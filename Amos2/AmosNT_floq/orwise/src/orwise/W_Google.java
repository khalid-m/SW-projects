package orwise;

import java.util.Vector;
import java.util.HashMap;
import java.lang.Math.*;
import callin.*;
import callout.*;

/** Wraps the W4F Wrapper for Google.
 * @author Simon Zürcher, University of Uppsala
 * @version ?
 */
class W_Google extends SearchEngine{

    SearchEngine specificSE;
    W4F_Google go;
    int results = 0;

    /** Standard Constructor
     */
    W_Google(){
	searchEngine = "Google";
	DebugSE.tracer.msg("W_Google created");
	// Defining the AMOS-Type which is used by the wrapper
	try{
	    oidMyType = theConnection.getType("DOCUMENT");
	}
	catch(AmosException e){
	    System.err.println(e);
	    return;
	}
    }

    /** Implementation of the abstract superclass method.
     * Starts the W4F wrapper after having read the properties from the Hashmap
     * @prarams Vector propertiesVector
     * @return SearchEngine
     */
    SearchEngine callWrapper(Vector propertiesVec) throws AmosException{
	HashMap argsHashMap = new HashMap();
	try{
	    argsHashMap = this.getHashMap(propertiesVec, searchEngine);
	}
	catch(AmosException e){
	    throw e;
	}

	String resultsStr = "";
	String query="";
	String language="";

	try{
	    super.exceptionCheckResults(argsHashMap, searchEngine);
	    super.exceptionCheckQuery(argsHashMap, searchEngine);
	}
	catch(AmosException e){
	    throw e;
	}

	int pages;
	int entriesPerPage;
	int resultsPair[] = new int[2];

	Integer integerResults = (Integer)argsHashMap.get("results");
	results = integerResults.intValue();

	query=(String)(argsHashMap.get("query"));
	language=(String)(argsHashMap.get("language"));

	resultsPair = calcPagesAndEntries(results);
	entriesPerPage=resultsPair[0];
	pages=resultsPair[1];

	//show properties
	super.showProperties(entriesPerPage, pages, query, searchEngine);
	DebugSE.tracer.msg("results: " + results);
	DebugSE.tracer.msg("language: " +language);

	try {
	    go = W4F_Google.searchRecursive(pages, entriesPerPage, query, language);
	}
	catch(Exception e){
	    System.out.println("W4F Exception: "+e);
	    go = null;
	}
	translateResults(go);
	return this;
    }

    /** Translates the W4F result (Arrays of Strings)
     * into other Objects and put them into Vectors
     * @params W4F_Google W4FResults
     * @return void
     */


    void translateResults(W4F_Google W4FResults){
	if (W4FResults.url != null){
	    count = W4FResults.url.length;
	    // if the wrapper returned more results then the user wanted, set the number of
	    // results to the number the user actually wanted
	    if (count > this.results){
		count = this.results;
	    }
	}
	else{
	    return;
	}
	for(int i=0;i<count;i++){
	    this.subject.addElement(W4FResults.subject[i]);
	    this.title.addElement(W4FResults.title[i]);
	    this.url.addElement(W4FResults.url[i]);
	}
    }

    /** writes the wrapper-specific data into an AMOS document
     * @params Oid oidDocument
     * @params int positionInVector
     * @return void
     */
    void fillFunctions(Oid oidDocument, int i)throws AmosException{
	//W4F_Google just provides the standard functions which will be inserted by the superclass method
	super.fillFunctions(oidDocument, i);
    }

    /** describes the rule which calculates entries per page and number
     * of pages when the user enters the number of total entries
     * @params int numberOfEntries
     * @return int[] pagesAndEntriesPerPage [0] = results per page [1] = pages
     */
    int[] calcPagesAndEntries(int results) {
	int pagesAndEntries[] = new int[2];
	if (results<100) {
	    pagesAndEntries[0]=results; pagesAndEntries[1]=1;
	}
	else {
	    float div = (results / 100) + 1;
	    pagesAndEntries[0]=100;
	    pagesAndEntries[1]=Math.round(div);
	}
	return pagesAndEntries;
    }
}
