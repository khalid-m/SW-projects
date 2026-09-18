package bigtable.query;

import java.util.Vector;
import bigtable.query.failure.AppEngineFailure;
import bigtable.query.failure.CursorFailure;
import bigtable.query.failure.HttpStatusError;
import bigtable.query.failure.QuotaFailure;
import bigtable.query.valuestream.*;
import bigtable.schema.GAEDataStoreSchema;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import callin.AmosException;
import callin.Tuple;
import callin.Oid;
import callin.Connection;
import callin.Scan;
import bigtable.BigTableInterface;
import java.util.*;
import callout.*;


/**
 * Provides a resumable facility to run GQL queries on the App Engine
 */
public class QueryManager {	

    // Http request parameter names
    public static final String querystring = "gqlString";
    public static final String paramTable = "btTable";
    public static final String paramProjItem = "gqlProj";
    public static final String paramInsertVal = "v";
    public static final String gqlQueryStrings = "gqlQueryStrings";
    public static final String gqlJoinPros = "gqlJoinPros";
    public static final String logFlag = "logFlag";
    public static final String cursor = "cursor";
    public static final String resultChunkSize = "resultChunkSize";

    private String dsn;
    private static Connection conn;

    private String gqlstring;
    //the server logging
    private static String serverLogging = "off";
    public static String clientLogging = "off";
    public String cursorPosition="";
    public String queryResultStatus="more";
    public static int queryResultChunkSize=20000;

    //new added
    private Vector queryStrings;
    private Vector joinPros;
        
    private Tuple properties;

    private Tuple propertyVal;
    /* The corresponding entity */
    private String typename;

    private callout.CallContext cxt;
    private Tuple tpl;
        
    //bigtable url
    private String url;

    private static void initConn() throws AmosException{
	if(conn==null)
	    conn = new Connection("");
    }
	
    /**
       w	 * Gets a connection to Amos
       * @return the {@link Connection}
       * @throws AmosException
       */
    public static Connection getConnection() throws AmosException{
	initConn();
	return conn;
    }
	


    public static Scan callFunction(String functionname, Object[] params) throws AmosException{
	initConn();
	Tuple args = new Tuple(params.length);
	// set the params
	for (int i = 0; i < params.length; i++) {
	    args.setElem(i, params[i]);
	}
	return conn.callFunction(functionname,args);
    }

    public QueryManager() throws AmosException{
    }

    /* this constructor is for gql function */
    public QueryManager(String dsn, String querystring, callout.CallContext cxt, Tuple tpl) throws AmosException {
	initConn();
	this.url = conn.callFunction("CHARSTRING.BIGTABLEURL->CHARSTRING",dsn).getRow().getStringElem(0);	   
	this.gqlstring = querystring;
	this.cxt = cxt;
	this.tpl = tpl;
    }



    /* this constructor is for getBigTable and deleteBigTable function*/
    public QueryManager(String dsn, String tableName, Tuple keyVal, callout.CallContext cxt, Tuple tpl) throws AmosException {
	initConn();
	//String url; 
	String keyColumn;
	String keyValue = keyVal.getElem(0).toString();
	Tuple dsTableTuple = new Tuple(2);
	this.url = conn.callFunction("CHARSTRING.BIGTABLEURL->CHARSTRING",dsn).getRow().getStringElem(0);
	dsTableTuple.setElem(0, dsn);
	dsTableTuple.setElem(1,tableName);
	keyColumn = conn.callFunction("CHARSTRING.CHARSTRING.bigTableKeyAttribute->CHARSTRING",dsTableTuple).getRow().getStringElem(0);   
	this.gqlstring = "select * from ".concat(tableName).concat(" where ").concat(keyColumn).concat("=").concat("'").concat(keyValue).concat("'");
	this.cxt = cxt;
	this.tpl = tpl;

    }
    
    /* this constructor is for insertBigTable function */
    public QueryManager(String dsn, String typename, Tuple properties, Tuple propertyVal, callout.CallContext cxt, Tuple tpl) throws AmosException {
	initConn();
	this.url = conn.callFunction("CHARSTRING.BIGTABLEURL->CHARSTRING",dsn).getRow().getStringElem(0);
	this.dsn = dsn;
	this.typename = typename;
	this.properties = properties;
	this.propertyVal = propertyVal;
	this.cxt = cxt;
	this.tpl = tpl;
    }


    /* this constructor is for gqlNLJ, gqlSMJ, gqlHJ functions */
    public QueryManager(String dsn, Vector queryStrings, Vector joinPros, callout.CallContext cxt, Tuple tpl) throws AmosException {
	//  Tuple arg = new Tuple(1);  
	//   arg.setElem(0, dsn);
	initConn();
	//String url; 
	this.url = conn.callFunction("CHARSTRING.BIGTABLEURL->CHARSTRING",dsn).getRow().getStringElem(0);	   
	this.queryStrings = queryStrings;
	this.joinPros = joinPros;
	this.cxt = cxt;
	this.tpl = tpl;
  
    }


    /* The function is used to turn on or off the logging in client */
    public void setClientLog(CallContext cxt, Tuple tpl) throws AmosException{
	String indication = tpl.getStringElem(0);
	if(indication.equals("on")){
	    clientLogging = "on";}
	else if(indication.equals("off")){
	    clientLogging = "off";}
	else{
	    clientLogging = "unknown";}
}

    /* The function is used to turn on or off the logging in server */
    public void setServerLog(CallContext cxt, Tuple tpl) throws AmosException{
	String indication = tpl.getStringElem(0);
	if(indication.equals("on")){
	    serverLogging = "on";}
	else if(indication.equals("off")){
	    serverLogging = "off";}
	else{
	    serverLogging = "unknown";}
}

    /* Set returned query result size from server */
    public void setResultChunkSize(CallContext cxt, Tuple tpl) throws AmosException{
	int tempResultChunkSize = tpl.getIntElem(0);
	if(tempResultChunkSize <= 0){
	    throw new AmosException("Query result chunk size must be larger than 0!");}
	else{
	    queryResultChunkSize = tempResultChunkSize;}
    }
	
    /**
     * write gql query into http request in order to pass it to server
     */
    protected void writeQueryParams(HttpResponseStream requestStream) throws AmosException {
	    requestStream.addParameter(querystring, gqlstring);
	    requestStream.addParameter(logFlag, serverLogging);
	    requestStream.addParameter(cursor, this.cursorPosition);
	    requestStream.addParameter(resultChunkSize, Integer.toString(QueryManager.queryResultChunkSize));
	    //*System.out.println("here is writeQueryParams and cursor position is:" + this.getCursorPosition());
    }



    /**
     * method for gqlNLJ
     */
    protected void writeQueryParamsForSQ(HttpResponseStream requestStream) throws AmosException {
	requestStream.addParameter(gqlQueryStrings, queryStrings.toString());
	requestStream.addParameter(gqlJoinPros, joinPros.toString());
	requestStream.addParameter(logFlag, serverLogging);

	//System.out.println("here is writeQueryParamsForSQ:" + queryStrings.toString());
	//System.out.println("here is writeQueryParamsForSQ:" + joinPros.toString());
    }



    protected void writeInsertParams(HttpResponseStream requestStream) throws AmosException {
	//passing values from amos client to app engine server
	requestStream.addParameter(paramTable, typename);

        // add meta information: properties p[j]
	for (int i = 0; i < properties.getArity(); i++) {
	    if( !properties.getStringElem(i).isEmpty() )
		requestStream.addParameter(paramProjItem, properties.getStringElem(i));
	}

	// add attributes value information: properties p[j]
	for (int i = 0; i < propertyVal.getArity(); i++) {
	    requestStream.addParameter(paramInsertVal, propertyVal.getElem(i).toString());
	}
	requestStream.addParameter(logFlag, serverLogging);
    }
	

    public final HttpResponseStream openValueStream() throws AmosException{
		return openResumedValueStream(null,this);
	}
	
    /**
     * establish a channel to App engine datastore and get the server query response back  
     * http://www.java2s.com/Code/Java/Apache-Common/HttppostmethodExample.htm
     */
    public final HttpResponseStream openResumedValueStream(AppEngineFailure resumableFailure, QueryManager gqlQueryManager) throws AmosException {
	// the value stream
	//HttpResponseStream resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/GqlQuery");
	HttpResponseStream resultStream = new HttpResponseStream((url + "/GqlQuery"), gqlQueryManager);
	//System.out.println("url is " + url);
	//add parameter query string to PostMethod and send to bigwrapper server
	writeQueryParams(resultStream);
		
	try{
	    if(!resultStream.isAborted()){
		// open HttpResponseStream
		resultStream.openStreamReader(BigTableInterface.client, this, resumableFailure);
	    } 
	    return resultStream;
	}catch (HttpStatusError e) {			
	    // transfer 403 (forbidden) into a Quota Error to allow resumption / recovery 
	    if(e.getStatusCode() == 403 || e.getStatusCode() == 500 || e.getStatusCode() == 502) {
		// quota violation
		AppEngineFailure qError = new QuotaFailure(e.getMessage(),null,null,e.getPostParams(),e.getMethodPath());
		// recover and continue
		return openResumedValueStream(qError, this);
	    } else {
		throw e;
	    }
	}
    }


    public void runQuery(QueryManager gqlQueryManager) throws AmosException{
	runQuery(null, gqlQueryManager);
    }

	
    public void runQuery(AppEngineFailure error, QueryManager gqlQueryManager) throws AmosException{	
		
	HttpResponseStream res = (error == null)
	    ? openValueStream()
	    : openResumedValueStream(error, gqlQueryManager);
	//long startTime = System.currentTimeMillis();

		try {
	    emitResult(res);

	    }catch (AppEngineFailure e) {
	    // continue query after recovery
	    // runQuery(e);
	    	}
	//long endTime = System.currentTimeMillis();
	//System.out.println("Total elapsed time in emitting result is :"+ (endTime-startTime));

    }


    public void emitResult(HttpResponseStream resultStream) 
	throws AmosException, AppEngineFailure{
	Tuple resTuple = null;
	//int numOfReturnTuples = 0;
	//loop through response from server
	while(null != (resTuple = resultStream.next())){
	    //* System.out.println("i don't want to see this");
	    // avoid to emit empty lines
	    if(resTuple.getArity()>0) { 
		//System.out.println("tpl.getArity-1 is " + (tpl.getArity()-1));
		//System.out.println("tuple element is " + resTuple.getStringElem(0));
		tpl.setElem(tpl.getArity()-1,resTuple);
		cxt.emit(tpl);
		//numOfReturnTuples++;
	    }
	}
	//System.out.println("number of return tuples is " + numOfReturnTuples);
    }

    public void insertTuple() throws AmosException{
	insertTuple(null);
    }


    /* insert a tuple into app engine
     * @param error {@link AppEngineFailure} on resume
     * @throws AmosException
     */
    public void insertTuple(AppEngineFailure error) throws AmosException{	
		
	//HttpResponseStream resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/InsertTuple");
	HttpResponseStream resultStream = new HttpResponseStream(url + "/InsertTuple");
	writeInsertParams(resultStream);
	try {
	    resultStream.openStreamReader(BigTableInterface.client, null, null);
	    Tuple values = resultStream.next();
	    tpl.setElem(tpl.getArity()-1,values);
	    cxt.emit(tpl);			
	    }catch (AppEngineFailure e) {
	    }
    }


    public void deleteTuple() throws AmosException{
	deleteTuple(null);
    }


    /* delete a tuple in GAE data store
     * @param error {@link AppEngineFailure} on resume
     * @throws AmosException
     */
    public void deleteTuple(AppEngineFailure error) throws AmosException{	
	
	//HttpResponseStream  resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/DeleteQuery");
	HttpResponseStream resultStream = new HttpResponseStream(url + "/DeleteQuery");
	writeDeleteParams(resultStream);
	//System.out.println("here is deleteTuple function");
	try {
	    //System.out.println("here is deleteTuple function 0");
	    resultStream.openStreamReader(BigTableInterface.client, null, null);
	    //System.out.println("here is deleteTuple function 1");
	    Tuple values = resultStream.next();
	    //System.out.println("here is deleteTuple function 2");
	    tpl.setElem(tpl.getArity()-1,values);
	    //System.out.println("here is deleteTuple function 3");
	    cxt.emit(tpl);
	    
	    }catch (AppEngineFailure e) {
	    }
    }

    protected void writeDeleteParams(HttpResponseStream requestStream) throws AmosException {
	//passing values from amos client to app engine server
	requestStream.addParameter(querystring, gqlstring);
	requestStream.addParameter(logFlag, serverLogging);
    }

    /**
     * send queries and joinPros on the AppEngine's query interface and emits the result
     * @param error {@link AppEngineFailure} on resume
     * @throws AmosException
     */
    public void sendQuery() throws AmosException{	

	HttpResponseStream res = openResumedValueStreamForSQ(null);
						
					     
	try {
	    emitResult(res);
			
	    }catch (AppEngineFailure e) {		
	    // continue query after recovery
	    //runQuery(e);
	    }
    }


    public final HttpResponseStream openResumedValueStreamForSQ(AppEngineFailure resumableFailure) throws AmosException {
	// the value stream
	//HttpResponseStream resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/gqlNLJ");
	HttpResponseStream resultStream = new HttpResponseStream(url + "/gqlNLJ");
	writeQueryParamsForSQ(resultStream);

	try{
	    if(!resultStream.isAborted()){
		// open HttpValueStream
		resultStream.openStreamReader(BigTableInterface.client, this, resumableFailure);
	    }

	    return resultStream;
	}catch (HttpStatusError e) {

	    if(e.getStatusCode() == 403 || e.getStatusCode() == 500 || e.getStatusCode() == 502) {
		// fake quota violation
		AppEngineFailure qError = new QuotaFailure(e.getMessage(),null,null,e.getPostParams(),e.getMethodPath());
		return openResumedValueStream(qError, this);
	    } else {
		throw e;
	    }
	}
    }


    public void NLJNewQuery() throws AmosException{	
	//long startTime1 = System.currentTimeMillis();
	HttpResponseStream res = openResumedValueStreamForNLJNew(null);
	//long endTime1 = System.currentTimeMillis();				     
	//long startTime2 = System.currentTimeMillis();
	try {
	    emitResult(res);
			
	    }catch (AppEngineFailure e) {
			
	    // continue query after recovery
	    //runQuery(e);
	    }
	//long endTime2 = System.currentTimeMillis();
	//System.out.println("Time consumed in the network and generating query result :"+ (endTime1-startTime1));
	//System.out.println("Total elapsed time in emitting result is :"+ (endTime2-startTime2));
    }


    public final HttpResponseStream openResumedValueStreamForNLJNew(AppEngineFailure resumableFailure) throws AmosException {
	// the value stream
	HttpResponseStream resultStream = new HttpResponseStream(url + "/gqlNLJNew");
	writeQueryParamsForSQ(resultStream);
	try{
	    if(!resultStream.isAborted()){
		// open HttpValueStream
		resultStream.openStreamReader(BigTableInterface.client, this, resumableFailure);
	    }
	    return resultStream;
	}catch (HttpStatusError e) {			
	    // transfer 403 (forbidden) into a Quota Error to allow resumption / recovery 
	    if(e.getStatusCode() == 403 || e.getStatusCode() == 500 || e.getStatusCode() == 502) {
		// quota violation
		AppEngineFailure qError = new QuotaFailure(e.getMessage(),null,null,e.getPostParams(),e.getMethodPath());
		return openResumedValueStream(qError, this);
	    } else {
		throw e;
	    }
	}
    }


    /* for smj */
    /**
     * send queries and joinPros on the AppEngine's query interface and emits the result
     * @param error {@link AppEngineFailure} on resume
     * @throws AmosException
     */
    public void smjQuery() throws AmosException{	
	//long startTime1 = System.currentTimeMillis();
	HttpResponseStream res = openResumedValueStreamForSMJ(null);					//	long endTime1 = System.currentTimeMillis();
				     
	//long startTime2 = System.currentTimeMillis();
					     
	try {
	    emitResult(res);
			
	    }catch (AppEngineFailure e) {
	    // continue query after recovery
	    //runQuery(e);
	    }
	//long endTime2 = System.currentTimeMillis();
	//System.out.println("Time consume in the network and generating query result :"+ (endTime1-startTime1));    
	//System.out.println("Total elapsed time in emitting result is :"+ (endTime2-startTime2));
    }

    public final HttpResponseStream openResumedValueStreamForSMJ(AppEngineFailure resumableFailure) throws AmosException {
	// the value stream
	//HttpResponseStream resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/gqlSMJ");
	HttpResponseStream resultStream = new HttpResponseStream(url + "/gqlSMJ");
	writeQueryParamsForSQ(resultStream);

	try{
	    if(!resultStream.isAborted()){
		// open HttpValueStream
		resultStream.openStreamReader(BigTableInterface.client, this, resumableFailure);
	    }
	    return resultStream;
	}catch (HttpStatusError e) {			
	    // transfer 403 (forbidden) into a Quota Error to allow resumption / recovery 
	    if(e.getStatusCode() == 403 || e.getStatusCode() == 500 || e.getStatusCode() == 502) {
		// fake quota violation
		AppEngineFailure qError = new QuotaFailure(e.getMessage(),null,null,e.getPostParams(),e.getMethodPath());
		return openResumedValueStream(qError, this);
	    } else {
		throw e;
	    }
	}
    }


    /* for hash join */
    /**
     * send queries and joinPros on the AppEngine's query interface and emits the result
     * @param error {@link AppEngineFailure} on resume
     * @throws AmosException
     */
    public void hjQuery() throws AmosException{	
	//long startTime1 = System.currentTimeMillis();
	HttpResponseStream res = openResumedValueStreamForHJ(null);
	//long endTime1 = System.currentTimeMillis();
    
	//System.out.println("Time consume in the network and generating query result :"+ (endTime1-startTime1));
				     
	//long startTime2 = System.currentTimeMillis();
			     
	try {
	    emitResult(res);
			
	    }catch (AppEngineFailure e) {
			
	    // continue query after recovery
	    //runQuery(e);
	    }
	//long endTime2 = System.currentTimeMillis();
	//System.out.println("Time consume in the network and generating query result :"+ (endTime1-startTime1));    
	//System.out.println("Total elapsed time in emitting result is :"+ (endTime2-startTime2));
    }


    public final HttpResponseStream openResumedValueStreamForHJ(AppEngineFailure resumableFailure) throws AmosException {
	// the value stream
	//HttpResponseStream resultStream = new HttpResponseStream("http://oddse2010.appspot.com/simpleprotocol/gqlHJ");
	HttpResponseStream resultStream = new HttpResponseStream(url + "/gqlHJ");
	writeQueryParamsForSQ(resultStream);
	// and the query params if not yet send

	try{
	    if(!resultStream.isAborted()){
		// open HttpValueStream
		resultStream.openStreamReader(BigTableInterface.client, this, resumableFailure);
	    }
	    return resultStream;
	}catch (HttpStatusError e) {			
	    // transfer 403 (forbidden) into a Quota Error to allow resumption / recovery 
	    if(e.getStatusCode() == 403 || e.getStatusCode() == 500 || e.getStatusCode() == 502) {
		// fake quota violation
		AppEngineFailure qError = new QuotaFailure(e.getMessage(),null,null,e.getPostParams(),e.getMethodPath());
		return openResumedValueStream(qError, this);
	    } else {
		throw e;
	    }
	}
    }

    public String getCursorPosition(){
	return cursorPosition;}

    public void setCursorPosition(String cursorPosition){
	this.cursorPosition=cursorPosition;}

    public String getQueryResultStatus(){
	return queryResultStatus;}

    public void setqueryResultStatus(String queryResultStatus){
	this.queryResultStatus=queryResultStatus;}
}
