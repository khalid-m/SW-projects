package bigtable.query.failure;

import org.apache.commons.httpclient.HttpMethodBase;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.methods.PostMethod;

public class HttpStatusError extends AppEngineBadRequest {

    private static final long serialVersionUID = 1L;
    private HttpMethodBase method = null;

    public HttpStatusError(HttpMethodBase method) {
	super( 	"Server returned status code " + method.getStatusCode() 
		+ " at " + method.getPath() );
	this.method = method;
    }

    public NameValuePair[] getPostParams() {
	if (method instanceof PostMethod) {
	    return ((PostMethod)method).getParameters();
	} else
	    return null;
    }

    public int getStatusCode() {
	return method.getStatusCode();
    }
	
    public String getMethodPath(){
	try {
	    return method.getURI().toString();
	} catch (URIException e) {
	    return null;
	}
    }
}
