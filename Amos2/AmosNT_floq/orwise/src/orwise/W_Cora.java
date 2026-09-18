package orwise;

import callin.*;
import callout.*;
import java.util.Vector;
import java.util.HashMap;
import java.lang.Math.*;

class W_Cora extends SearchEngine {
    Vector relevance, authors, relatedDoc, bibTex, details;
    SearchEngine specificSE;
    W4F_Cora co;
    int results = 0;

    W_Cora() {
	relevance = new Vector();
	authors = new Vector();
	relatedDoc = new Vector();
	bibTex = new Vector();
	url = new Vector();           // = details
	searchEngine = "Cora";
	DebugSE.tracer.msg("W_Cora created");
	// Defining the AMOS-Type which is used by the wrapper
	try {
	    oidMyType = theConnection.getType("DOCUMENT");
	} catch(AmosException e){
	    System.out.println(e);
	    return;
	}
    }

    SearchEngine callWrapper(Vector propertiesVec) throws AmosException {
	HashMap argsHashMap = new HashMap();
	try {
	    argsHashMap = this.getHashMap(propertiesVec, searchEngine);
	} catch(AmosException e) {
	    throw e;
	}

	try {
	    super.exceptionCheckResults(argsHashMap, searchEngine);
	    super.exceptionCheckQuery(argsHashMap, searchEngine);
	} catch(AmosException e){
	    throw e;
	}

	int resultsPair[] = new int[2];
	int pages;
	int entriesPerPage;
	String query = "";
	String firstEntry = "";

	Integer integerResults = (Integer)argsHashMap.get("results");
	results = integerResults.intValue();
	query = (String)argsHashMap.get("query");
	firstEntry = (String)argsHashMap.get("firstEntry");

	resultsPair = this.calcPagesAndEntries(results);
	entriesPerPage=resultsPair[0];
	pages=resultsPair[1];

	super.showProperties(entriesPerPage, pages, query, searchEngine);
	DebugSE.tracer.msg("results: " + results);
	DebugSE.tracer.msg("first entry: " +firstEntry);

	try {
	    co = W4F_Cora.searchRecursive(pages, entriesPerPage, query, firstEntry);
	} catch(Exception e){
	    System.out.println("W4F Exception: "+e);
	    return null;
	}
	this.translateResults(co);
	return this;
    }

    void fillFunctions(Oid oidDocument, int i) throws AmosException {
	Oid fRelevance;
	Oid fAuthors;
	Oid fRelatedDoc;
	Oid fBibTex;

	try {
	    fRelevance = SearchEngine.theConnection.getFunction("DOCUMENT.RELEVANCE->REAL");
	    fAuthors = SearchEngine.theConnection.getFunction("DOCUMENT.AUTHORS->CHARSTRING");
	    fRelatedDoc = SearchEngine.theConnection.getFunction("DOCUMENT.RELATEDDOC->CHARSTRING");
	    fBibTex = SearchEngine.theConnection.getFunction("DOCUMENT.BIBTEX->CHARSTRING");
	} catch(AmosException e){
	    System.out.println(e);
	    return;
	}

	try {
	    arg1.setElem(0, oidDocument);

	    if (this.relevance.elementAt(i) == null) {
		res1.setElem(0,"");
	    } else {
		res1.setElem(0,this.relevance.elementAt(i));
	    }
	    theConnection.addFunction(fRelevance,arg1,res1);

	    if (this.authors.elementAt(i) == null){
		res1.setElem(0,"");
	    } else {
		res1.setElem(0,this.authors.elementAt(i));
	    }
	    theConnection.addFunction(fAuthors, arg1, res1);

	    if (this.relatedDoc.elementAt(i) == null){
		res1.setElem(0,"");
	    } else {
		res1.setElem(0,this.relatedDoc.elementAt(i));
	    }
	    theConnection.addFunction(fRelatedDoc,arg1,res1);

	    if (this.bibTex.elementAt(i) == null){
		res1.setElem(0,"");
	    } else {
		res1.setElem(0,this.bibTex.elementAt(i));
	    }
	    theConnection.addFunction(fBibTex,arg1,res1);
	} catch(AmosException e){
	    System.out.println("AMOS Error (writing)"+e);
	    return;
	}
	super.fillFunctions(oidDocument, i);
    }


    /*describes the rule which calculates entries per page and number of pages when the user enters just number
      of total entries*/
    int[] calcPagesAndEntries(int results) {
	int pagesAndEntries[] = new int[2];
	if (results<=50) {
	    pagesAndEntries[0]=results; pagesAndEntries[1]=1;
	}
	else {
	    float div = (results / 50) + 1;
	    pagesAndEntries[0]=50;
	    pagesAndEntries[1]=Math.round(div);
	}
	return pagesAndEntries;

    }

    /*this method puts the specific W4F results into a Vector of a general SearchEngine-Object
     */
    void translateResults(W4F_Cora W4FResults){
	if (W4FResults.relatedDoc != null){
	    count = W4FResults.relatedDoc.length;
	    if (count > this.results){
		count = this.results;
	    }
	}

	for (int i=0;i<count;i++){
	    this.subject.addElement(W4FResults.subject[i]);
	    this.title.addElement(W4FResults.title[i]);
	    this.authors.addElement(W4FResults.authors[i]);
	    this.relatedDoc.addElement(W4FResults.relatedDoc[i]);
	    this.bibTex.addElement(W4FResults.bibtex[i]);
	    this.url.addElement(W4FResults.url[i]);
	    this.relevance.addElement(W4FResults.relevance[i]);
	}
    }
}
