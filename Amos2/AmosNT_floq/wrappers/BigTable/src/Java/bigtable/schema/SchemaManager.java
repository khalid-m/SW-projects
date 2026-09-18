package bigtable.schema;

import java.io.*;

import bigtable.BigTableInterface;
import bigtable.MetaDataSaver;
import bigtable.query.failure.AppEngineFailure;
import bigtable.query.valuestream.HttpResponseStream;

import callin.*;
import callout.*;

/**
 * This class maps google app engine data store (GAE data store) 
 * elements to Amos II elements by transforming entity schemas of
 * GAE datastore into corresponding Amos schema representations and vice versa 
 */
public class SchemaManager {
	// To hold the connection to AMOS
        //private static Connection theConnection;	
    private static GAEDataStoreSchema schema = new GAEDataStoreSchema();


    public SchemaManager() throws AmosException{
	// Create the connection
	//theConnection = new Connection("");
    }
	
    /**
     * import meta data from GAE data store into Amos stored functions
     */
    public void accessBigtable(CallContext cxt, Tuple tpl) throws AmosException{
	String dsn = tpl.getStringElem(0);
	String url = tpl.getStringElem(1);
	importDataStoreMeta(url, dsn);
	//for collecting attribute statistic
	//getColStatistic(url, dsn);
    }
	
    /**
     * Creates a GAE relation(table) on the given App Engine data store with specified url
     */
    public void createBigtable(CallContext cxt, Tuple tpl) throws AmosException {
	schema.loadFromTuple(tpl);
	schema.checkSchema();
	publishForeignType( schema );
	schema.resetSchema();
    }

	
    /**
     * Store meta data
     */
    private static void storeDataStoreMeta(String dsn) throws AmosException {
		
	System.out.println(String.format("%nProcessing type %s (%s)", schema.getTypename(), schema.getLocation()));

	schema.checkSchema();
	try {
	    // store Metadata
	    MetaDataSaver.storeMetadata(schema, dsn);

	} //catch (IOException e) {
	catch (AmosException e) {
	    // convert to AmosException
	    throw MetaDataSaver.toAmosExc(e);
	} finally {
	    // reset state
	    schema.resetSchema();
	}
    }

	
    /**
     * Loads entity schemas from the AppEngine using its getSchema interface
     * The schema information is used to create mapped types in Amos
     */ 
    private static void importDataStoreMeta(String uri, String dsn) throws AmosException{
		HttpResponseStream res = new HttpResponseStream(uri + "/getSchema");
		res.openStreamReader(BigTableInterface.client, null, null);
		Tuple values = null;

		//System.out.println("here is importDataStoreMeta function");
		try{
		    do{
			//System.out.println("here is a debug line");
			//System.out.println("here is a debug line " + res.next(3).getStringElem(0));
			//  System.out.println("here is a debug line " + res.next(3).getStringElem(1));
			//  System.out.println("here is a debug line " + res.next(3).getStringElem(2));
			    //if( null != (values = res.next(3)) ) {
			    if( null != (values = res.next(3)) ) {
			    // params: tableName, parentTable, number of tuples, e.g CITY||1||10000 and url
			    //*System.out.println("here is importDataStoreMeta " + values.getStringElem(0));
			    //*System.out.println("here is importDataStoreMeta " + values.getStringElem(1));
			    //*System.out.println("here is importDataStoreMeta " + values.getStringElem(2));
			    schema.setType(values.getStringElem(0), values.getStringElem(1),values.getStringElem(2), uri);
			} else {
			    break; 
			}
			//values is a tuple e.g POPULATION||Integer||None
			while( null != (values = res.next(3)) && values.getArity() > 0 ) {
			    // iterating over properties
			    schema.addProperty(
					       values.getStringElem(0), 
					       values.getStringElem(1), 
					       !values.getStringElem(2).contentEquals("None"));

			}
			storeDataStoreMeta(dsn);
		    } while( values != null);
		} catch (AppEngineFailure e) {
		    throw MetaDataSaver.toAmosExc(e);
		}
	    }
    

    /**
     * Publishes the current {@link ForeignTypeSchema} on the App Engine
     */
    private static void publishForeignType(GAEDataStoreSchema schema) throws AmosException{		
	HttpResponseStream valStream = new HttpResponseStream( schema.getLocation()+"/setSchema");
	schema.setRequestParams(valStream);
	try {
	    // send request and get streamed result
	    valStream.openStreamReader(BigTableInterface.client, null, null);
	    Tuple values = valStream.next();
	    while(valStream.next() != null){}
	    if ( !values.getBooleanElem(0) ) {
		throw new AmosException("App Engine returned false!");
	    }
	} catch (AppEngineFailure e) {
	    throw MetaDataSaver.toAmosExc( 	String.format(  
							      "Publishing schema failed at %s: %s ",
							      schema.getLocation(), e.getMessage() ),
						e.getStackTrace() );
	} catch (AmosException e) {
	    e.errstr = String.format(  "Publishing schema failed at %s: %s ",
				       schema.getLocation(), e.errstr );
	    throw e;
	}
    }



    /**
     * Loads entity schemas from the AppEngine using its getSchema interface
     * The schema information is used to create mapped types in Amos
     */
    private static void getColStatistic(String uri, String dsn) throws AmosException{
	HttpResponseStream res = new HttpResponseStream(uri + "/getStatistic");
	//res.openStream(BigTableInterface.client, null, null);
	res.openStreamReader(BigTableInterface.client, null, null);
	Tuple values = null;
	try{
	    do{		    
		if( null != (values = res.next(3)) ) {
		    // entity name
		    schema.setTypeForStat(values.getStringElem(0)); 
				
		} else {
		    break; 
		}

		while( null != (values = res.next(3))&& values.getArity() > 0) {			
		    schema.addPropertyStatVal(
					      values.getStringElem(0),
					      values.getStringElem(1),
					      values.getStringElem(2));				
		}

		//schema's infor is not enough
		MetaDataSaver.storeColStatData(schema, dsn);
	    } while( values != null);
	} catch (AppEngineFailure e) {
	    //TODOlater: enable resume for schema query
	    throw MetaDataSaver.toAmosExc(e);
	}
    }
}
