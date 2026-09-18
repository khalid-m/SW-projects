package bigtable.query.valuestream;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.Vector;
import java.lang.System;
import java.util.Arrays; 

import org.apache.commons.httpclient.*;
//import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.params.HttpMethodParams;

import bigtable.query.QueryManager;
import bigtable.query.failure.*;

import callin.AmosException;
import callin.Tuple;

/**
 * The class represents a PostMethod class from httpclient and 
 * iterates over the result of a http request.
 */
public class HttpResponseStream extends ValueStream{

    /**
     * Post method
     */
    private final PostMethod method;
    private int[] typeIndex;
    /**
     * list of types used for local conversions, needs to match matchTypes!
     */
    private static ArrayList<String> typeList = null;
    /**
     *  keep the last line for failures
     */
    private String lastLine = null;
	
    private static final String ERROR_PREFIX = "!ERROR!";


    private int affectedRows = 0;

    private QueryManager gqlQueryManager;
	
    /**
     * Constructs a new value stream
     */
    public HttpResponseStream(String resourcePath){
	// setting the separator
	super("\\|\\|");
	this.method = new PostMethod( resourcePath );
	if(typeList == null){
	    initializeTypeList();
	}
    }

    public HttpResponseStream(String resourcePath, QueryManager gqlQueryManager){
	// setting the separator
	super("\\|\\|");
	this.method = new PostMethod( resourcePath );
	this.gqlQueryManager = gqlQueryManager;
	if(typeList == null){
	    initializeTypeList();
	}
    }
	

    public void openStreamReader(HttpClient client, QueryManager queryObj, AppEngineFailure resumableFailure)throws AmosException{
	if(method.isAborted())
	    return;
	//**System.out.println("method is absorted: " + method.isAborted());

// Provide custom retry handler is necessary
    method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, 
    		new DefaultHttpMethodRetryHandler(3, false));


	try {
	    int statusCode = client.executeMethod(method);
	    //**System.out.println("client.executeMethod 1");
	    //**System.out.println("statusCode is " + statusCode);

if (statusCode != HttpStatus.SC_OK) {
        throw new AmosException("Unable to establish connection to "+method.getPath());
      }


//if( client.executeMethod( method ) != -1 ) {
//if( statusCode != -1 ) {
/*
			System.out.println("client.executeMethod 2");
		if(method.getStatusCode()!=200) {
		    System.out.println("client.executeMethod 3");
		    close();
 System.out.println("client.executeMethod 4");
		    throw new HttpStatusError(method);

		}
*/
		//System.out.println("here is the getResponseBodyAsString print out "+method.getResponseBodyAsString());
		//**System.out.println("client.executeMethod 5");
		// receive response and create LineNumberReader
		//System.out.println("here is openStreamReader 1");		
		lineReader = new LineNumberReader( new InputStreamReader(method.getResponseBodyAsStream(), method.getResponseCharSet()));
		//System.out.println("here is openStreamReader 2");
				
		//  } else {
		//	throw new AmosException("Unable to establish connection to "+method.getPath());
		//	    }
	} catch (HttpException e) {
	    throw new AmosException(e.getMessage());
	} catch (IOException e) {
	    throw new AmosException(e.getMessage());
	}
    }
	
    	
    public Tuple next(int arity) throws AmosException, AppEngineFailure {
	// return null if processing was aborted
	if(method.isAborted())
	    return null;
		
	String line;
	Tuple tuple = null;
	String cursorPos;
	int lineNumber;
	String[] values;

	try{
			
	    //* System.out.println("here is the beginning of next function in HttpResponseStream");
	    //if the line is not null
	    if((line = lineReader.readLine()) != null){				
		lineNumber = lineReader.getLineNumber();
		values = line.split(separator,line.length());
		//System.out.println("line number is " + lineNumber);
		//System.out.println("queryResultStatus is " + QueryManager.queryResultStatus);
		//System.out.println("line length "+ line.length());
		//System.out.println("line is "+ line);
		//System.out.println("values length is "+ values.length);
		//System.out.println("values[0] is "+ values[0]);
		//System.out.println(values[0].equals("success"));
		//System.out.println("values[1] is "+ values[1]);
		//*	System.out.println("here is the line number print out "+lineNumber);
		//*  System.out.println("here is the line content print out "+line);
		// avoid to process empty rows/lines, just return a tuple of arity 0 (not null!)
		if (line.isEmpty()) {
		    //System.out.println("line is empty");
		    return new Tuple(0);
		}
		// check for errors
		if ( line.startsWith(ERROR_PREFIX) ) {
		      System.out.println("line is in error ");
		    getAppEngineException(line);
		}
		// check for first line (schema) or query result row
		if ( lineNumber==1 ) {
		    //*System.out.println("here is the 1st line");
		    //Charstring||Charstring||Charstring
		    // first line contains type information, index type information
		    if(values[0].equals("success") || values[0].equals("fail") ){
			//System.out.println("here is the 1st line");			
tuple = new Tuple(1);
			tuple.setElem(0,values[0]); }
		    //there is no returned result
		    else if(values[values.length-1].equals("NoMore")){
			this.gqlQueryManager.setqueryResultStatus(values[values.length-1]);
		      tuple = new Tuple(0);
		    }
		    //there is returned result
		    else{
		    createTypeIndex( line.split(separator,line.length()), arity );

		    // skip type information here lastLine = line;
		    // continue with next line
		    tuple = next(arity);}
		    // System.out.println("2nd tuple is "+tuple);
		}
	        else if(doEmit()) {
		    // is result row, convert items
		    //print out CITY||||10000
		    //print out CITYNAME||Charstring||0
		    //  System.out.println("here starts to emit the result tuples");
		      //QueryManager.cursorPosition = tuple.getStringElem(0);
		      //System.out.println("here prints the cursor position"+cursorPosition);
		    //tuple  = matchTypes( line.split(separator,line.length()) );
		    //values = line.split(separator,line.length());
		    if(lineNumber==2){
			//*System.out.println("lineNumber is 2 and value[1]==0 "+lineNumber);
			//*System.out.println("cursor print out "+values[0]);
			if(values[1].equals("0")){
			    // set cursor information for the next request to server 
			      this.gqlQueryManager.setCursorPosition(values[0]);
			      //set signal information for client to determine whether it needs to send  
			      //the next request to server
			      this.gqlQueryManager.setqueryResultStatus(values[2]);
			      tuple = new Tuple(0);
			} else if(values[1].equals("1")){
			    	tuple  = matchTypes( values);
			} else {
			    tuple = new Tuple(0);
			}
		    }

		    if(lineNumber > 2){
			//*System.out.println("lineNumber is larger than 2 "+lineNumber);
			tuple  = matchTypes( values);}
		    //lastLine = line;
					
		    
		    //*  System.out.println("tuple detail " + tuple.getStringElem(0));
		    //*  System.out.println("tuple detail " + tuple.getStringElem(1));
		    //*  System.out.println("tuple detail " + tuple.getStringElem(2));
		    
//System.out.println("line.split(separator,line.length()) is "+line.split(separator,line.length()));
//System.out.println("tuple is "+ tuple);
					
		} else {
		    updateResumeState(line);
		    lastLine = line;
		    //*  System.out.println("here is the check point 3");
		    // just return empty tuple
		    return new Tuple(0);
		}
	    // count row
	    affectedRows++;
	    //* System.out.println("affectedRow is " + affectedRows);
	    // return values
	    //*  System.out.println("here is the end of big if statement");
	    return tuple;
				
	    } 
		      
	else if(!doEmit()){
	    // close and release connection
	    close();
	    //method.releaseConnection();
	    //* System.out.println("here is !doEmit");
	    // resume point never reached
	    throw new AmosException("Can't resume query, try to order by key column!");
	} 

		      
	else{
	    //**System.out.println("here is the first releaseConnection");
	    method.releaseConnection();
	    if (lineReader != null){
		try{
		    lineReader.close();}
		catch (Exception fe){}
	    }
	    lastLine = null;
	    //*  System.out.println("here is the last else in the if statement");
	    return null;
	}
		      
	}catch (IOException e) {
	    //**System.out.println("here is the second releaseConnection");
	    method.releaseConnection();
	    if (lineReader != null){
		try{
		    lineReader.close();}
		catch (Exception fe){}
	    }
	    lastLine = null;
	    //* System.out.println("here is the last else in the if statementIO Exception when receiving next line!");
	    return null;
	}
    }
    
	
    /**
     * Initializes the list of available types
     * Used as dictionary when creating the index
     */
    private static synchronized void initializeTypeList() {
	if(typeList!=null)
	    return;
	typeList = new ArrayList<String>();
	typeList.add("Charstring");	//0
	typeList.add("Integer");	//1
	typeList.add("Real");		//2
	typeList.add("Boolean");	//3
    }

    /**
     * Convert the retrieved array of Strings into a typed {@link Tuple}
     * @requestParameter values String representation of elements
     * @return typed result {@link Tuple}
     * @throws AmosException
     */
    private Tuple matchTypes(String[] values) throws AmosException {
	// check result size
	if(values.length!=schemaArity){
	    throw new AmosException("Inconsistent number of columns, expected row size is "+schemaArity+"!");
	}
	//System.out.println("here is the matchTypes print out "+Arrays.toString(values));
	// create empty Tuple and convert values (skip hidden key columns here)
	Tuple res = new Tuple( (queryArity>0)? queryArity : schemaArity );
	for(int i=0; i < res.getArity(); i++){
	    // set elements of tuple according to their type
	    switch (typeIndex[i]) {
	    case 0:	res.setElem(i,values[i]); break;
	    case 1: res.setElem(i, Integer.parseInt( values[i]) ); break;
	    case 2: res.setElem(i, Double.parseDouble( values[i]) ); break;
	    case 3: res.setElem(i, values[i].trim().equalsIgnoreCase("true") ); break;
	    default:
		throw new AmosException("Unknown Type in matchTypes!");
	    }
	}
	return res;
    }
	
    /** 
     * Translates an array of Strings into a type index, allowing faster
     * type matching when processing the result rows.
     * @requestParameter types Array of type names (Result schema)
     * [Charstring, Charstring, Charstring]
     * @requestParameter arity Expected number of values
     * @throws AmosException
     */
    private void createTypeIndex(String[] types, int arity) throws AmosException {
	// check against initial arity from query
	if( types.length < queryArity ){
	    throw new AmosException("Unexpected number of columns, query requires at least "+queryArity+"!");
	}
	if( arity > 0 && types.length != arity){
	    throw new AmosException("Unexpected number of columns, enforced to be "+arity+"!");
	}
	//System.out.println("here is the line.split(separator,line.length()) print out "+Arrays.toString(types));
	// reset vCount
	schemaArity = types.length;
	typeIndex = new int[schemaArity];
	for(int i=0;i<schemaArity;i++){
	    typeIndex[i] = -1;
	    for (int j = 0; j < typeList.size(); j++) {
		if( types[i].equalsIgnoreCase( typeList.get(j) ) ){
		    typeIndex[i] = j;
		    break;
		}
	    }
	    if(typeIndex[i]<0){
		throw new AmosException("Unknown Type "+types[i]+"!");
	    }
	}
    }

    /**
     * Tries to release the used http connection used
     * and closes the ValueStream. A closed stream can't
     * be used thereafter anymore.
     */
    private void close() {
	method.releaseConnection();
	try{
	    lineReader.close();
	}catch (Throwable e) {
	}
    }
    

    private String getMethodPath() {
	try {
	    String returnString = method.getURI().toString();
	    return returnString;
	} catch (URIException e) {
	    return null;
	}
    }
	
    /**
     * Throws the appropriate exception when receiving an error from the AppEngine
     * @requestParameter line AppEngine error string
     * @throws AppEngineFailure
     * @throws AmosException
     */
    private void getAppEngineException(String line) throws AppEngineFailure, AmosException {
	// remove error indicator
	String msg = line.substring(ERROR_PREFIX.length());
	
	// load resume point
	Tuple resumePointTuple = null;
	if(lastLine != null){
	    // create the resume point tuple from the last received line
	    String[] values = lastLine.split(separator,lastLine.length());
	    // full size!
	    queryArity = values.length;
	    resumePointTuple = matchTypes(values);
	}
		
	try{
	    // check and create appropriate exception
	    if ( msg.startsWith("Timeout Error") ){
		blameFailureState(TimeoutFailure.class, msg, resumePointTuple, lastLine);
	    } else if ( msg.startsWith("Cursor Error") ) {
		blameFailureState(CursorFailure.class, msg, resumePointTuple, lastLine);
	    } else if ( msg.startsWith("Quota Error") ) {
		blameFailureState(QuotaFailure.class, msg, resumePointTuple, lastLine);
	    } else if ( msg.startsWith("Unresumable Error") ) {
		throw new UnresumableRequest(msg);
	    } else if ( msg.startsWith("Index Error") ) {
		throw new IndexError(msg);
	    } else if ( msg.startsWith("Order Error") ) {
		throw new AppEngineBadRequest(msg);
	    } else {
		throw new AppEngineBadRequest(msg);
	    }
	} finally {
	    // close to release method on exceptions
	    //close();
	    method.releaseConnection();
	}
		
    }
	
    public boolean removeParameter(String paramName){
	return method.removeParameter(paramName);
    }
	
    public void addParameter(String paramName, String paramValue){
	method.addParameter(paramName, paramValue);
    }
	
    public void addParameter(NameValuePair param){
	method.addParameter(param);
    }
	
    public void addParameters(NameValuePair[] params){
	method.addParameters(params);
    }
	
    public NameValuePair[] getParameters(){
	return method.getParameters();
    }
	
    public boolean isAborted(){
	return method.isAborted();
    }
	
    public void abort(){
	method.abort();
    }
	
    public int getAffectedRows(){
	return affectedRows;
    }
	
    public void setAffectedRows(int rows){
	affectedRows = rows;
    }
	
    /**
     * This causes the stream to throw an appropriate initiated failure class
     * @requestParameter type The type of failure
     * @requestParameter msg A failure message
     * @requestParameter resumePoint A string representing a resumePoint
     * @throws AppEngineFailure
     * @throws AmosException
     */
    public void blameFailureState(Class<?> type, String msg) throws AppEngineFailure, AmosException{
	blameFailureState(type, msg, null, null);
    }

    /**
     * This causes the stream to throw an appropriate initiated failure class
     * @requestParameter type The type of failure
     * @requestParameter msg A failure message
     * @requestParameter resumePointTuple A {@link Tuple} representation of the resume point
     * @requestParameter resumePoint A string representing a resumePoint
     * @throws AppEngineFailure
     * @throws AmosException
     */
    protected void blameFailureState(Class<?> type, String msg, Tuple resumePointTuple, String resumePoint) throws AppEngineFailure, AmosException{
	// load post params
	NameValuePair[] postParams = null;
	if (method instanceof PostMethod) {
	    //postParams = ((PostMethod)method).getParameters();
	    postParams = method.getParameters();
	}

	// distinguish failure type
	if ( type == TimeoutFailure.class) {
	    throw new TimeoutFailure(msg, resumePoint, resumePointTuple, postParams);
	} else if ( type == CursorFailure.class ) {
	    throw  new CursorFailure(msg, postParams );
	} else if ( type == QuotaFailure.class ) {
	    throw  new QuotaFailure(msg, resumePoint, resumePointTuple, postParams, getMethodPath() );
	}
		
    }
}
