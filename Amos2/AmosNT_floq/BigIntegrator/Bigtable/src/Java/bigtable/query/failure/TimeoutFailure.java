package bigtable.query.failure;

//import bigtable.query.ResumableQueryManager;
import org.apache.commons.httpclient.NameValuePair;

import callin.AmosException;
import callin.Tuple;

/**
 * Exception that indicates an interruption while 
 * retrieving a query result. The query can be 
 * continued from a resume point.
 *
 */
@SuppressWarnings("serial")
    public class TimeoutFailure extends AppEngineFailure{
	/**
	 * For sequential queries a timeout can signals more data. Recovery
	 * should be avoided in such cases
	 */
	private final boolean isResumeSignal;
	private final static String resumeSignalIdentifier = "Timeout Error:More data is available";
	/**
	 * A {@link TimeoutFailure} that enables the application to resume the query from the row received last
	 * @param msg The error message
	 * @param resumePoint The point where to resume
	 * @param postParams The post parameters of this failed post request
	 */
	public TimeoutFailure(String msg, String resumePoint, Tuple resumePointTuple,  NameValuePair[] postParams) 
	    throws AmosException{
	    super(msg, resumePoint, resumePointTuple, postParams);
	    // check for resume signal
	    isResumeSignal = (msg.startsWith(resumeSignalIdentifier));
	    // adapt timing parameters here if necessary
	    // sharedRecovery.minOptimizeInterval = 
	    // sharedRecovery.minRecoveryInterval =
	}
	
	public boolean doResourceEval(){
	    return isResumeSignal;
	}
    }
