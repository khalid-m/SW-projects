/**
 * JsonWrapper uses Httpclient to request resource from certain url.
 * Then processes the requested resource which is in JSON format to
 * Amos Vector data type
 * @author Bo Yang
 */
import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;
import callout.CallContext;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.HttpClient;

import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.HttpURL;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class JsonWrapper
{

    private AuthScope authScope;
    private HttpURL url = null;
    private String baseUrl = null;
    private String username = null;
    private String password = null;
    private static ArrayList<HttpClientUrl> arraylist = 
	new ArrayList<HttpClientUrl>();
    //private HttpClient httpClient = new HttpClient();;
    private static PostMethod postMethod = null;

    /**
     * Extracts the host and post from the baseurl and constructs an
     * appropriate AuthScope for them for use with HttpClient
     */
    private AuthScope createAuthScope(String baseUrl) throws AmosException {
        AuthScope authscope = null;
        try 
	    {
		url = new HttpURL(baseUrl);
		authscope = new AuthScope(url.getHost(), url.getPort(), 
					  "realm");
	    } 
	catch (URIException ex) 
	    {
		Logger.getLogger(JsonWrapper.class.getName()).log(Level.SEVERE,
								  null, ex);
		throw new AmosException(ex.getMessage());
	    }
        return authscope;
    }

    /**
     * Process JSONObject to Amos Record
     */
    public Tuple processJson(CallContext cxt, JSONObject jsonobject, Tuple t)
	throws AmosException {
        JSONArray keys = jsonobject.names();
        for (int i = 0; i < keys.length(); i++) {
	    try 
		{ //put the key of JSONObject into Vector
		    t.setElem(i * 2, keys.getString(i));
		    //put the corresponding value of JSONObject into Vector
		    if (jsonobject.get(keys.getString(i)).getClass().getName().
			equals("org.json.JSONObject")) {
			Scan s;
			Tuple temp1 = new Tuple(1);
			JSONObject temp = 
			    jsonobject.getJSONObject(keys.
						     getString(i
							       ));
			if (temp.names()!=null) {
			    temp1.setElem(0, 
					  processJson(cxt, temp, 
						      new Tuple(temp.names().
								length() * 2
								)));
			    s = cxt.connection().
				callFunction("vector.make_record->Record", 
					     temp1);
			    t.setElem(i * 2 + 1, s.getRow().getOidElem(0));
			}
		    } 
		    else if (jsonobject.get(keys.getString(i)).
			     getClass().getName().equals("org.json.JSONArray"
							 )) {
			JSONArray temp = 
			    jsonobject.getJSONArray(keys.getString(i));
			t.setElem(i * 2 + 1, 
				  processArray(cxt, temp, 
					       new Tuple(temp.length())));
		    } 
		    else {
			t.setElem(i * 2 + 1, 
				  jsonobject.getString(keys.getString(i)));
		    }
		} 
	    catch (JSONException ex){
		Logger.getLogger(JsonWrapper.class.getName()).
		    log(Level.SEVERE, null, ex);
	    }
	}
        return t;
    }

    /**
     * Process JSONArray to Amos Vector
     */
    public Tuple processArray(CallContext cxt, JSONArray jsonarray, Tuple t)
      throws AmosException {
        for (int i = 0; i < jsonarray.length(); i++) {
            try {
                if (jsonarray.get(i).getClass().getName().
		    equals("org.json.JSONObject")) {
                    JSONObject temp = jsonarray.getJSONObject(i);
                    t.setElem(i, 
			      processJson(cxt, temp, 
					  new Tuple(temp.names().length() 
						    * 2)));
                } else if (jsonarray.get(i).getClass().getName().
			   equals("org.json.JSONArray")) {
                    JSONArray temp = jsonarray.getJSONArray(i);
                    t.setElem(i, processArray(cxt, temp, 
					      new Tuple(temp.length())));
                } else {
                    t.setElem(i, jsonarray.getString(i));
                }

            } catch (JSONException ex) {
                Logger.getLogger(JsonWrapper.class.getName()).
		    log(Level.SEVERE, null, ex);
            }
        }
        return t;
    }

    /**
     * Initialize the httpclient by setting credentials and creating 
     * Authorization Scope.
     * Then add the httpclient and url into an arraylist
     */
    public void initConn(final CallContext cxt, final Tuple tpl) 
	throws AmosException {

        Boolean find = false;
        this.baseUrl = tpl.getStringElem(0);
        this.username = tpl.getStringElem(1);

        this.password = tpl.getStringElem(2);
        int status;
        authScope = createAuthScope(baseUrl);
        HttpClient httpClient = new HttpClient();
        Credentials creds = 
	    new UsernamePasswordCredentials(username, password);
        httpClient.getHttpConnectionManager().getParams().setSoTimeout(60000);
        httpClient.getState().setCredentials(authScope, creds);
        httpClient.getParams().setAuthenticationPreemptive(true);

        GetMethod get = new GetMethod(baseUrl);
        get.setDoAuthentication(true);

        try {
            status = httpClient.executeMethod(get);
            if ((status != 200) && (status != 406)) {
                throw new AmosException(
					"Got status " + get.getStatusText());
            }

        } catch (IOException ex) {
            Logger.getLogger(JsonWrapper.class.getName()).
		log(Level.SEVERE, null, ex);
            throw new AmosException(ex.getMessage());
        } finally {

            get.releaseConnection();
        }

        if ((status == 200) || (status == 406)) {
            for (int i = 0; i < arraylist.size(); i++) {
                if ((arraylist.get(i) == null) && (!find)) {
                    arraylist.remove(i);
                    arraylist.add(i, new HttpClientUrl(httpClient, baseUrl));
                    find = true;
                    tpl.setElem(3, i);
                    cxt.emit(tpl);
                }
            }

            if (!find) {
                arraylist.add(new HttpClientUrl(httpClient, baseUrl));
                tpl.setElem(3, arraylist.size() - 1);
                cxt.emit(tpl);
            }
        }
    }

    /**
     * Send a name value pair to url and process the recieved data
     */
    public void jsonWrapper(final CallContext cxt, final Tuple tpl) 
	throws AmosException {
        Scan s;
        Tuple temptpl = new Tuple(1);
        Tuple temptpl2 = new Tuple(1);
        Collection<NameValuePair> namevaluepair
	    = new ArrayList<NameValuePair>();
        int snumber = tpl.getIntElem(0);

        if (arraylist.isEmpty()) {
            throw new AmosException("No connection initialized!");
        } else if ((snumber >= arraylist.size()) || 
		   (arraylist.get(snumber) == null)) {
            throw new 
		AmosException("Connection is not defined or has been released"
			      );
        } else {
            HttpClient httpclient = 
		arraylist.get(tpl.getIntElem(0)).httpClient;
            Oid oid = tpl.getOidElem(1);

            temptpl2.setElem(0, oid);
            s = cxt.connection().callFunction("Record.all_value->Object", 
					      temptpl2);
            while (!s.eos()) {
                Tuple row;
                String name;
                String value;

                row = s.getRow();
                name = row.getStringElem(0);
                s.nextRow();
                row = s.getRow();
                value = row.getStringElem(0);
                namevaluepair.add(new NameValuePair(name, value));
                s.nextRow();
            }

            try {
                postMethod = new PostMethod(arraylist.get(tpl.getIntElem(0)).
					    baseurl);
                postMethod.setRequestBody(namevaluepair.
					  toArray(new 
						  NameValuePair[namevaluepair.
								size()]));
                httpclient.executeMethod(postMethod);
                if (postMethod.getStatusCode() != HttpStatus.SC_OK) {

                    throw new AmosException(
					    "Got status "
					    + postMethod.getStatusText());
                }
                InputStream is = postMethod.getResponseBodyAsStream();

                if (is != null) {
                    JSONTokener jsonTokener = 
			new JSONTokener(
					new InputStreamReader(is, "UTF-8"));
                    String jsontype = jsonTokener.nextValue().getClass().
			getName();

                    if (jsontype.equals("org.json.JSONObject")) {
                        while (true) {
                            JSONObject jsonObject = 
				new JSONObject(jsonTokener);

                            temptpl.setElem(0, 
					    processJson(cxt, jsonObject, 
							new Tuple(jsonObject.
								  names().
								  length() * 2
								  )));
                            s = cxt.connection().
				callFunction("vector.make_record->Record",
					     temptpl);
                            tpl.setElem(2, s.getRow().getOidElem(0));
                            cxt.emit(tpl);
                        }
                    } else if (jsontype.equals("org.json.JSONArray")) {
                        while (true) {
                            JSONArray jsonarray = new JSONArray(jsonTokener);

                            tpl.setElem(2, 
					processArray(cxt, jsonarray,
						     new Tuple(jsonarray.
							       length())));
                            cxt.emit(tpl);
                        }
                    } else {
                        throw new AmosException("Data is not in JSON format ");
                    }
                }
            } catch (JSONException ex) {
                Logger.getLogger(JsonWrapper.class.getName()).
		    log(Level.SEVERE, null, ex);
                throw new AmosException(ex.getMessage());
            } catch (IOException ex) {
                Logger.getLogger(JsonWrapper.class.getName()).
		    log(Level.SEVERE, null, ex);
                throw new AmosException(ex.getMessage());
            } finally {
                // Abort the method, otherwise releaseConnection() will
                // attempt to finish reading the never-ending response.
                // These methods do not throw exceptions.             
                postMethod.abort();
                postMethod.releaseConnection();
            }
        }
    }

    /**
     *Abort the method and finish reading the never-ending response
     */
    public void logout(final CallContext cxt, final Tuple tpl) 
	throws AmosException {
        int snumber = tpl.getIntElem(0);
        if (arraylist.isEmpty()) {
            throw new AmosException("No connection initialized!");
        } else if ((snumber >= arraylist.size()) ||
		   (arraylist.get(snumber) == null)) {
            throw new 
		AmosException("Connection is not defined or has been released!"
			      );
        } else {
            if ((postMethod != null) && (!postMethod.isAborted())) {
                postMethod.abort();
                postMethod.releaseConnection();
            }
            arraylist.set(snumber, null);
            String str = "Connection " + snumber + " released!";
            tpl.setElem(1, str);
            cxt.emit(tpl);
        }
    }

    /**
     * Get the number of available connections
     */
    public void available(final CallContext cxt, final Tuple tpl)
	throws AmosException {
        if (arraylist.isEmpty()) {
            throw new AmosException("No connection available!");
        } else {
            Boolean find = false;
            for (int i = 0; i < arraylist.size(); i++) {
                if (arraylist.get(i) != null) {
                    find = true;
                    tpl.setElem(0, i);
                    cxt.emit(tpl);
                }
            }
            if (!find) {
                throw new AmosException("No connection available!");
            }
        }
    }

    public static void main(String argv[]) throws AmosException {
        Connection.initializeAmos(argv);
        Connection theConnection = new Connection("");
        theConnection.amosTopLoop("JavaAmos II"); // Enters the AmosQL top-loop

    }
}

class HttpClientUrl {

    public HttpClient httpClient = null;
    String baseurl;

    public HttpClientUrl(HttpClient httpclient, String Url) {
        this.httpClient = httpclient;
        this.baseurl = Url;
    }
}

