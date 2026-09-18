package bigtable.query.failure;

import org.apache.commons.httpclient.NameValuePair;
import callin.AmosException;

@SuppressWarnings("serial")
    public class CursorFailure extends AppEngineFailure {	
	/**
	 * Thrown if a cursor could not be loaded, probably due to the fact that
	 * it was not loaded yet. 
	 * @param message Details on the cursor failure
	 * @param postParams Cursor parameters
	 */
	public CursorFailure(String message, NameValuePair[] postParams) throws AmosException{
	    super(message, null, null, postParams);
		
	    // requires to load shared data immediatley
	    //	SharedRecoveryManager.getInstance().loadData(this);
	    // and reset recovery interval
	    //sharedRecovery.setRecoveryInterval(0); 
	}
    }

