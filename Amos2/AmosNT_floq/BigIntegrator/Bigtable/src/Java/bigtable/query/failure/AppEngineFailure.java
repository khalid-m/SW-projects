package bigtable.query.failure;

import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;

import callin.AmosException;
import callin.Tuple;

public abstract class AppEngineFailure extends Exception{

    private static final long serialVersionUID = 1L;
    /**
     * input stream line from where to resume
     */
    public final String resumePoint;
    /**
     * last received tuple (has this to be set in the constructor?!)
     */
    public final Tuple resumePointTuple;
    /**
     * post params of {@link PostMethod} when failing
     */
    protected NameValuePair[] postParams;
    /**
     * shared recovery data
     */
    //protected SharedRecoveryData sharedRecovery;
	
    /**
     * A {@link AppEngineFailure} is the superclass for all resumable AppEngine failures
     * @param msg The error message
     * @param resumePoint The point where to resume
     * @param postParams The post parameters of this failed post request
     */
    protected AppEngineFailure(String msg, String resumePoint, Tuple resumePointTuple, NameValuePair[] postParams) throws AmosException{
	super(msg);
	this.resumePoint = resumePoint;
	this.resumePointTuple = resumePointTuple;
	this.postParams = postParams;
    }
	
    /**
     * Determines whether to evaluate resource usage
     * ({@link AbstractOptimizer#evaluateResourceUsage()}) for additional allocation. Generally 
     * no evaluation is needed after resumption. 
     * @return
     */
    public boolean doResourceEval(){
	return false;
    }
	
    /**
     * Removes all parameters that have been processed on resume
     * This is mainly used of {@link BulkLoadingManager} in order to distinguish
     * whether all parameters could be send in one query on resume.
     * @param untilIndex The first index to keep for later processing
     */
    public void removePostParams(int untilIndex){
	// check for valid indexes
	if (postParams == null || postParams.length<=untilIndex){
	    postParams = new NameValuePair[0];
	    return;
	}
	// adapt remaining values
	NameValuePair[] tmpParams = new NameValuePair[postParams.length-untilIndex];
	System.arraycopy(
			 postParams, untilIndex,
			 tmpParams, 0, postParams.length-untilIndex);
	postParams = tmpParams;
    }
	
    /**
     * Removes all post params from the failure 
     */
    public void removePostParams(){
	postParams = new NameValuePair[0];
    }
	
    /**
     * True if the {@link PostMethod} associated to the previously failed query
     * has more post parameters
     * @return
     */
    public boolean hasPostParams(){
	if(postParams == null)
	    return false;
	else
	    return (postParams.length > 0);
    }
	
    /**
     * Returns all parameters of the query that apparently failed
     * and let to this exception
     * @return Array of {@link NameValuePair}s (no copy!)
     */
    public NameValuePair[] getPostParams() {
	return postParams;
    }
}
