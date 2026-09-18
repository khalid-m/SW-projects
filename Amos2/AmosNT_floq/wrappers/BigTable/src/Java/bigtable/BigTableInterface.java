package bigtable;

import java.lang.String;
import bigtable.query.*;
import bigtable.query.failure.*;
import callin.*;
import callout.*;
import org.apache.commons.httpclient.*;
import java.util.Vector;
import java.util.*;

/**
 * The interface provides querying and updating facility to AppEngine datastore
 */
public class BigTableInterface {

    /* The HttpClient used for all connections */
    //public static final HttpClient client = new HttpClient(new MultiThreadedHttpConnectionManager());
public static final HttpClient client = new HttpClient();

    /* this function send gql query to app engine and emit the query result */ 
    public void gql(CallContext cxt, Tuple tpl) throws AmosException {
	// prepare Query if necessary
	//long startTime = System.currentTimeMillis();
	String dsn = tpl.getStringElem(0);

	String queryStr = (tpl.getArity()==4) 
	    ? prepareQuery( tpl.getStringElem(1), tpl.getSeqElem(2) )
	    : tpl.getStringElem(1);
	   
	QueryManager gqlQueryManager = new QueryManager(dsn, queryStr, cxt, tpl);
	gqlQueryManager.queryResultStatus = "more";
	gqlQueryManager.cursorPosition="";
	//*System.out.println("before while loop, query result status is: " + QueryManager.queryResultStatus);
	//The client keep sending the query recursively until the server send the stop message back to acknowledge
	//there is no further query result needs to return.
	while(gqlQueryManager.queryResultStatus.equals("more")){
	    if(QueryManager.clientLogging.equals("on")){
		System.out.println("query is " + queryStr);}
	    gqlQueryManager.runQuery(gqlQueryManager);
	    if(QueryManager.clientLogging.equals("on")){
		System.out.println("single from server is " + gqlQueryManager.queryResultStatus);}
	}
	//long endTime = System.currentTimeMillis();
	// System.out.println("Total elapsed time in execution of gql method is :"+ (endTime-startTime));
    }



    /* This function handles binary nested loop join of gql query */
    public void gqlNLJ(CallContext cxt, Tuple tpl) throws AmosException {
	//   System.out.println("come in gql method");
	// prepare Query if necessary
	String dsn = tpl.getStringElem(0);
	//System.out.printf("tpl length is %d:", tpl.getArity());	
									
	//Integer numOfQueries = tpl.getSeqElem(1).getArity();
	Tuple queryStringsTuple = tpl.getSeqElem(1);
	String queryString; 
	Vector<String> queryStrings = new Vector<String>();
	for(int i=0;i<queryStringsTuple.getArity();i++){
	    queryString = "\"" + queryStringsTuple.getStringElem(i) + "\"";
	    queryStrings.add(queryString);
	}
	//System.out.println("gql strings are:" + queryStrings);
		

	Tuple joinProTuple = tpl.getSeqElem(2);
	Vector<Vector> joinPro = new Vector<Vector>();
	for(int i=0;i<joinProTuple.getArity();i++){
	    Vector<Integer> innerVector = new Vector<Integer>();
	    for(int j=0;j<joinProTuple.getSeqElem(i).getArity();j++){
		innerVector.add(joinProTuple.getSeqElem(i).getIntElem(j));
	    }
	    joinPro.add(innerVector);
		    
	}
	//System.out.println("joinPros are:" + joinPro);

	QueryManager gqlQueryManager = new QueryManager(dsn, queryStrings, joinPro, cxt, tpl);

	gqlQueryManager.sendQuery();	
    }

    /* server NLJ 2 */
    public void gqlNLJNew(CallContext cxt, Tuple tpl) throws AmosException {
	//   System.out.println("come in gql method");
	// prepare Query if necessary
	//long startTime = System.currentTimeMillis();
	String dsn = tpl.getStringElem(0);
	//System.out.printf("tpl length is %d:", tpl.getArity());
							
	//Integer numOfQueries = tpl.getSeqElem(1).getArity();
	Tuple queryStringsTuple = tpl.getSeqElem(1);
	Vector<String> queryStrings = new Vector<String>();
	for(int i=0;i<queryStringsTuple.getArity();i++){
	    queryStrings.add("\"" + queryStringsTuple.getStringElem(i) + "\"");
	}
	//System.out.println("gql strings are:" + queryStrings);
		

	Tuple joinProTuple = tpl.getSeqElem(2);
	Vector<Vector> joinPro = new Vector<Vector>();
	for(int i=0;i<joinProTuple.getArity();i++){
	    Vector<Integer> innerVector = new Vector<Integer>();
	    for(int j=0;j<joinProTuple.getSeqElem(i).getArity();j++){
		innerVector.add(joinProTuple.getSeqElem(i).getIntElem(j));
	    }
	    joinPro.add(innerVector);
		    
	}
	//System.out.println("joinPros are:" + joinPro);

	QueryManager gqlQueryManager = new QueryManager(dsn, queryStrings, joinPro, cxt, tpl);
	
	gqlQueryManager.NLJNewQuery();

	//long endTime = System.currentTimeMillis();
	// System.out.println("Total elapsed time in execution of serverNLJNew method is :"+ (endTime-startTime));
    }


    /* server SMJ */
    public void gqlSMJ(CallContext cxt, Tuple tpl) throws AmosException {
	//   System.out.println("come in gql method");
	// prepare Query if necessary
	//long startTime = System.currentTimeMillis();
	String dsn = tpl.getStringElem(0);
	//System.out.printf("tpl length is %d:", tpl.getArity());
		
	//Integer numOfQueries = tpl.getSeqElem(1).getArity();
	Tuple queryStringsTuple = tpl.getSeqElem(1);
	Vector<String> queryStrings = new Vector<String>();
	for(int i=0;i<queryStringsTuple.getArity();i++){
	    queryStrings.add("\"" + queryStringsTuple.getStringElem(i) + "\"");
	}
	//System.out.println("gql strings are:" + queryStrings);
		

	Tuple joinProTuple = tpl.getSeqElem(2);
	Vector<Vector> joinPro = new Vector<Vector>();
	for(int i=0;i<joinProTuple.getArity();i++){
	    Vector<Integer> innerVector = new Vector<Integer>();
	    for(int j=0;j<joinProTuple.getSeqElem(i).getArity();j++){
		innerVector.add(joinProTuple.getSeqElem(i).getIntElem(j));
	    }
	    joinPro.add(innerVector);
		    
	}
	//System.out.println("joinPros are:" + joinPro);

	QueryManager gqlQueryManager = new QueryManager(dsn, queryStrings, joinPro, cxt, tpl);
	
	gqlQueryManager.smjQuery();

	//long endTime = System.currentTimeMillis();
	// System.out.println("Total elapsed time in execution of serverSMJ method is :"+ (endTime-startTime));
    }


    /* server HJ */
    public void gqlHJ(CallContext cxt, Tuple tpl) throws AmosException {
	//   System.out.println("come in gql method");
	// prepare Query if necessary
	//long startTime = System.currentTimeMillis();
	String dsn = tpl.getStringElem(0);
	//System.out.printf("tpl length is %d:", tpl.getArity());
		
	//Integer numOfQueries = tpl.getSeqElem(1).getArity();
	Tuple queryStringsTuple = tpl.getSeqElem(1);
	Vector<String> queryStrings = new Vector<String>();
	for(int i=0;i<queryStringsTuple.getArity();i++){
	    queryStrings.add("\"" + queryStringsTuple.getStringElem(i) + "\"");
	}
	//System.out.println("gql strings are:" + queryStrings);
		

	Tuple joinProTuple = tpl.getSeqElem(2);
	Vector<Vector> joinPro = new Vector<Vector>();
	for(int i=0;i<joinProTuple.getArity();i++){
	    Vector<Integer> innerVector = new Vector<Integer>();
	    for(int j=0;j<joinProTuple.getSeqElem(i).getArity();j++){
		innerVector.add(joinProTuple.getSeqElem(i).getIntElem(j));
	    }
	    joinPro.add(innerVector);
		    
	}
	//System.out.println("joinPros are:" + joinPro);

	QueryManager gqlQueryManager = new QueryManager(dsn, queryStrings, joinPro, cxt, tpl);

	gqlQueryManager.hjQuery();

	//long endTime = System.currentTimeMillis();
	// System.out.println("Total elapsed time in execution of serverHJ method is :"+ (endTime-startTime));	
    }


     
    // Interface to insert a new tuple into the Datastore	 
    public void insertBigTable(CallContext cxt, Tuple tpl) throws AmosException {
	// load all parameters from tpl
	String dsn = tpl.getStringElem(0);
	String table = tpl.getStringElem(1);
	Tuple properties = tpl.getSeqElem(2);
	Tuple propertyVal = tpl.getSeqElem(3);

	QueryManager gqlQueryManager = new QueryManager(dsn, table, properties, propertyVal, cxt, tpl);
	//gqlQueryManager.insertTuple();
	gqlQueryManager.insertTuple();
    }


    //get a tuple from google cloud data store
    public void getBigTable(CallContext cxt, Tuple tpl) throws AmosException {
	// get dsn
	String dsn = tpl.getStringElem(0);
	// get table name
	String tableName = tpl.getStringElem(1);
	// get key value
	Tuple keyVal = tpl.getSeqElem(2);

	QueryManager gqlQueryManager = new QueryManager(dsn, tableName, keyVal, cxt, tpl);

	gqlQueryManager.runQuery(gqlQueryManager);			
    }



    //delete a tuple from google cloud data store
    public void deleteBigTable(CallContext cxt, Tuple tpl) throws AmosException {
	// get dsn
	String dsn = tpl.getStringElem(0);
	// get table name
	String tableName = tpl.getStringElem(1);
	// get key value
	Tuple keyVal = tpl.getSeqElem(2);

	QueryManager gqlQueryManager = new QueryManager(dsn, tableName, keyVal, cxt, tpl);
	gqlQueryManager.deleteTuple();
			
    }


		
    /**
     * Prepares a query string from a tuple of parameters
     * Each occurence of %s is replaced with corresponding element of pTpl
     */
    private static String prepareQuery(String queryString, Tuple pTpl)  throws AmosException{
	//   System.out.println("come in prepareQuery method");
	Object[] qParams = new String[pTpl.getArity()];
	//	System.out.printf("query string is %s:" , queryString);
	//	System.out.printf("parameter length is %d:" , pTpl.getArity());
	// created String[] to be used with String.format
	for(int i=0;i<pTpl.getArity();i++){
	    if(pTpl.getElem(i) instanceof Number)
		qParams[i]=pTpl.getElem(i).toString();
			       
	    else
		qParams[i]="'"+pTpl.getElem(i).toString()+"'";
	    //	 System.out.printf("params[0] is %s:" , qParams[i]);
	}
	if(pTpl.getArity() > 0){
	    //	    System.out.printf("Not good");
	    queryString = queryString.replaceAll("\\?", "%s");}
	// Prepare the query statement
	return String.format(queryString, qParams);
    }

}
