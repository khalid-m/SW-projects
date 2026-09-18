package bigtable.query.failure;

import org.apache.commons.httpclient.NameValuePair;

import callin.AmosException;
import callin.Tuple;

//import bigtable.query.ResumableQueryManager;
//import bigtable.query.optimizer.AdaptiveBlocker;

//ESCA-JAVA0087:
/**
 * Exception that indicates a quota violation while 
 * retrieving a query result. 
 * After a short interruption the query can be 
 * continued from a resume point.
 * @author Moritz
 */
@SuppressWarnings("serial")
    public class QuotaFailure extends AppEngineFailure {

	/**
	 * The resource URI
	 */
	private String resource;
	
	/**
	 * Exceeding the App Engines quota a {@link QuotaFailure} enables the application to wait shortly 
	 * for a certain resource and resume its query later on.
	 * @param msg the error message
	 * @param resumePoint the point where to resume (stores the last returned line)
	 * @param resumePointTuple the tuple representation of the resume point
	 * @param postParams the post parameters of this failed post request
	 * @param resource Resource identifier (URI)
	 */
	public QuotaFailure(String msg, String resumePoint, Tuple resumePointTuple, NameValuePair[] postParams, String resource)
	    throws AmosException{
	    super(msg, resumePoint, resumePointTuple, postParams);
	    this.resource = resource;
	}
    }
