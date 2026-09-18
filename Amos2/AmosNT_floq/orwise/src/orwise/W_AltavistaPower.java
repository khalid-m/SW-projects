package orwise;

import java.util.Vector;
import java.util.HashMap;
import java.lang.Math.*;
import callin.*;
import callout.*;

class W_AltavistaPower extends SearchEngine {

    SearchEngine specificSE;
    W4F_AltavistaPower avpo;
    int results=0;
    HashMap argsHashMap = new HashMap();

    //Constructor
    W_AltavistaPower() {
	searchEngine = "AltavistaPower";
	DebugSE.tracer.msg("W_AltavistaPower created");
	// Defining the AMOS-Type which is used by the wrapper
	try {
	    oidMyType = theConnection.getType("DOCUMENT");
	}
	catch(AmosException e){
	    System.err.println(e);
	    return;
	}
    }

    SearchEngine callWrapper(Vector propertiesVec) throws AmosException{

	try {
	    argsHashMap = this.getHashMap(propertiesVec, searchEngine);
	} catch(AmosException e){
	    throw e;
	}
	String query = "";
	String language = "";
	// if the user doesn´t state a range of date, the system will set the following default range
	String startDate = "1/1/80";
	String endDate = "1/1/10";

	int resultsPair[] = new int[2];
	int pages;
	int entriesPerPage;
	try{
	    super.exceptionCheckResults(argsHashMap, searchEngine);
	    super.exceptionCheckQuery(argsHashMap, searchEngine);
	}
	catch(AmosException e){
	    throw e;
	}

	//AltavistaPowr doesn´t return any results if no language is entered
	if (argsHashMap.get("language")==null){
	    throw new AmosException("no language entered");
	}

	query = (String)(argsHashMap.get("query"));
	language = (String)(argsHashMap.get("language"));

	// overwriting the standard dates with optional start and enddate if they have been added in the query
	if ((String)(argsHashMap.get("startDate"))!= null){
	    startDate = (String)(argsHashMap.get("startDate"));
	}
	if ((String)(argsHashMap.get("endDate"))!= null){
	    endDate = (String)(argsHashMap.get("endDate"));
	}

	Integer integerResults = (Integer)argsHashMap.get("results");
	results = integerResults.intValue();

	// number of results requested by the user are translated to number of pages and entries per page
	resultsPair = calcPagesAndEntries(results);
	entriesPerPage=resultsPair[0];
	pages=resultsPair[1];

	//show properties
	super.showProperties(entriesPerPage, pages, query, searchEngine);
	DebugSE.tracer.msg("results: " + results);
	DebugSE.tracer.msg("language: " +language);
	DebugSE.tracer.msg("Start Date: " +startDate);
	DebugSE.tracer.msg("End Date: " +endDate);

	try {
	    //start the HTML-wrapper
	    avpo = W4F_AltavistaPower.searchRecursive(pages, entriesPerPage, query, language, startDate, endDate);
	}
	catch(Exception e){
	    System.out.println("W4F Exception: "+e);
	    throw new AmosException("W4F Exception catched");
	}

	//translate Strings to Objects and put them into a Vector
	translateResults(avpo);
	return this;
    }

    /*translates the wrapper-specific data into a SearchEngine-Object
     */
    void translateResults(W4F_AltavistaPower W4FResults){
	if (W4FResults.url != null){
	    count = W4FResults.url.length;
	    if (count > this.results){
		count = this.results;
	    }
	}
	for(int i=0;i<count;i++){
	    this.subject.addElement(W4FResults.subject[i]);
	    this.title.addElement(W4FResults.title[i]);
	    this.url.addElement(W4FResults.url[i]);
	}
    }

    /*Since there are no other properties supported than the ones in the superclass
      this method just calls the superclass method
    */
    void fillFunctions(Oid oidDocument, int i)throws AmosException{
	super.fillFunctions(oidDocument, i);
    }

    /*describes the rule which calculates entries per page and number of pages when the user enters just number
      of total entries*/
    int[] calcPagesAndEntries(int results){
	int pagesAndEntries[] = new int[2];
	if (results<50){
	    pagesAndEntries[0]=results; pagesAndEntries[1]=1;
	}
	else{
	    float div = (results / 50) + 1;
	    pagesAndEntries[0]=50;
	    pagesAndEntries[1]=Math.round(div);
	}
	return pagesAndEntries;
    }


}
