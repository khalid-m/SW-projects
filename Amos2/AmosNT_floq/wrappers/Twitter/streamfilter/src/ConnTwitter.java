/*
 *author Bo Yang,2009 
 */ 


import java.io.IOException;
import java.io.InputStream;
import java.io.InterruptedIOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.httpclient.DefaultHttpMethodRetryHandler;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.HttpURL;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.params.HttpMethodParams;


public class ConnTwitter {
  private static Logger logger =
        Logger.getLogger(ConnTwitter.class.getName());
    
    private final String baseUrl;
    private final int maxFollowIdsPerCredentials=200;
    private final int maxTrackKeywordsPerCredentials=10;
    private final Collection<UsernamePasswordCredentials> credentials;
    private Collection<String> finalFollowIds;
    private Collection<String> finalTrackKeywords;
    private final TwitterStreamProcessor twitterStreamProcessor;
    Collection<String> param = new HashSet<String>();
    Collection<String> credential = new HashSet<String>();
    private int count;
    
    private final AuthScope authScope;
    
    private FilterParameterFetcher filterParameterFetcher =
            new FilterParameterFetcher() {
                public Collection<String> getFollowIds() {
                    return finalFollowIds;
                }

                public Collection<String> getTrackKeywords() {
                    return finalTrackKeywords;
                }
            };
    
    
   private Collection<UsernamePasswordCredentials> createCredentials(
        Collection<String> logins) {
        ArrayList<UsernamePasswordCredentials> result =
            new ArrayList<UsernamePasswordCredentials>();
        for (String login : logins) {
            result.add(new UsernamePasswordCredentials(login));
        }
        return result;
    }
   /**
     * Extracts the host and post from the baseurl and constructs an
     * appropriate AuthScope for them for use with HttpClient.
     */
    private AuthScope createAuthScope(String baseUrl) throws URIException {
        HttpURL url = new HttpURL(baseUrl);
        return new AuthScope(url.getHost(), url.getPort());
    }
    
    /**
     * Constructs a TwitterClient.
     *
     * @param twitterStreamProcessor processes the twitter stream
     * @param url url for statues/filter method 
     * @param credentials credentials to connect with, in the form
     *   "username:password".  
     * @param parameter the keywords or user ids
     * @param n the type of the parameter
     * 
     */
        
    public ConnTwitter(TwitterStreamProcessor twitterStreamProcessor,String url,
           String credentials, Collection<String> parameter,String n,int count){
       this.twitterStreamProcessor=twitterStreamProcessor;
       credential.add(credentials);
       this.credentials=createCredentials(credential);
       this.baseUrl=url;
       this.count=count;
       
       if (n.equals("track")){
          this.finalTrackKeywords=parameter;
       }else if (n.equals("friends"))
           this.finalFollowIds=parameter;
       try {
            authScope = createAuthScope(baseUrl);
            
        }
        catch (URIException ex) {
            throw new IllegalArgumentException("Invalid url: " + baseUrl, ex);
        }
    }
   
   public void execute() {
            processForATime();
   }
   
   /**
     * Divides the given collection of items into collections of at
     * most maxPerSet.  If items is empty, an empty collection will be
     * returned.  If items is null, a collection with a single null
     * element will be returned.
     */
   private Collection<HashSet<String>> createSets(
        Collection<String> items, int maxPerSet)
    {
        Collection<HashSet<String>> sets = new ArrayList<HashSet<String>>();

        if (items == null) {
            sets.add(null);
            return sets;
        }

        HashSet<String> set = null;
        for (String item : items) {
            if (set == null) {
                set = new HashSet<String>();
                sets.add(set);
            }
            set.add(item);
            if (set.size() >= maxPerSet) {
                set = null;
            }
        }

        return sets;
    }
   
   public void processForATime() {
   
        Collection<String> followIds =
            filterParameterFetcher.getFollowIds();
        Collection<HashSet<String>> followIdSets =
            createSets(followIds, maxFollowIdsPerCredentials);

        Collection<String> trackKeywords =
            filterParameterFetcher.getTrackKeywords();
        Collection<HashSet<String>> trackKeywordSets =
            createSets(trackKeywords, maxTrackKeywordsPerCredentials);

        Iterator<UsernamePasswordCredentials> credentialsIterator =
            credentials.iterator();

        for (HashSet<String> ids : followIdSets) {
            for (Collection<String> keywords : trackKeywordSets) {
                if (credentialsIterator.hasNext()) {
                    UsernamePasswordCredentials upc =
                        credentialsIterator.next();
                   Thread t = new Thread(new TwitterProcessor(upc, ids, keywords),
                        "Twitter download as " + upc);
                    t.start();                    
                }else {
                    logger.warning(
                        "Out of credentials, ignoring some ids/keywords.");
                }
            }
        }
    }
   
   
   private class TwitterProcessor implements Runnable{
        // The backoff behavior is from the spec.
        private final BackOff tcpBackOff = new BackOff(true, 250, 16000);
        private final BackOff httpBackOff = new BackOff(10000, 240000);

        private final UsernamePasswordCredentials credentials;
        private final HashSet<String> ids;
        private final Collection<String> keywords;

        public TwitterProcessor  (
            UsernamePasswordCredentials credentials, HashSet<String> ids,
            Collection<String> keywords)
        {
            this.credentials = credentials;
            this.ids = ids;
            this.keywords = keywords;
        }
        public void run() {
            //logger.info("Begin " + Thread.currentThread().getName());
            try {
                while (true) {
                    if (Thread.interrupted()) {
                        return;
                    }
                    try {
                        
                        connectAndProcess();
                    }
                    catch (InterruptedException ex) {
                        // Don't let this be handled as a generic Exception.
                        return;
                    }
                    catch (InterruptedIOException ex) {
                        return;
                    }
                    catch (HttpException ex) {
                        logger.log(Level.WARNING,
                            credentials + ": Error fetching from " + baseUrl,
                            ex);
                        httpBackOff.backOff();
                    }
                    catch (IOException ex) {
                        logger.log(Level.WARNING,
                            credentials + ": Error fetching from " + baseUrl,
                            ex);
                        tcpBackOff.backOff();
                    }
                    catch (Exception ex) {
                        // This could be a NumberFormatException or
                        // something.  Open a new connection to
                        // resync.
                        logger.log(Level.WARNING,
                            credentials + ": Error fetching from " + baseUrl,
                            ex);
                    }
                }
            }
            catch (InterruptedException ex) {
                return;
            }
            finally {
                logger.info("End " + Thread.currentThread().getName());
            }
        }
        /**
         * Connects to twitter and handles tweets until it gets an
         * exception or is interrupted.
         */
        public void connectAndProcess()
            throws HttpException, InterruptedException, IOException {
            HttpClient httpClient = new HttpClient();

            // HttpClient has no way to set SO_KEEPALIVE on our
            // socket, and even if it did the TCP keepalive interval
            // may be too long, so we need to set a timeout at this
            // level.  Twitter will send periodic newlines for
            // keepalive if there is no traffic, but they don't say
            // how often.  Looking at the stream, it's every 30
            // seconds, so we use a read timeout of twice that.

            httpClient.getHttpConnectionManager().getParams()
                .setSoTimeout(60000);

            // Don't retry, we want to handle the backoff ourselves.
            
            httpClient.getParams().setParameter(
                HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler(0, false));
            
            httpClient.getState().setCredentials(authScope, credentials);
            httpClient.getParams().setAuthenticationPreemptive(true);

            PostMethod postMethod = new PostMethod(baseUrl);
            postMethod.setRequestBody(makeRequestBody());
            logger.info("Connecting to twitter...");
            //logger.info(credentials + ": Connecting to " + baseUrl);
            httpClient.executeMethod(postMethod);
            
            try {
                if (postMethod.getStatusCode() != HttpStatus.SC_OK) {
                    throw new HttpException(
                        "Got status " + postMethod.getStatusCode());
                }
                
                InputStream is = postMethod.getResponseBodyAsStream();
                logger.info("Twitter connected!");
                // We've got a successful connection.
                resetBackOff();
                if ((is!=null)&&(count==0)){
                    twitterStreamProcessor.processTwitterStream(is);
                }else if ((is!=null)&&(count>0)){
                   twitterStreamProcessor.processTwitterStream(is,count);
                }
                
            } finally {
                // Abort the method, otherwise releaseConnection() will
                // attempt to finish reading the never-ending response.
                // These methods do not throw exceptions.                
                postMethod.abort();
                postMethod.releaseConnection();
            }
            
        }

        private NameValuePair[] makeRequestBody() {
            Collection<NameValuePair> params = new ArrayList<NameValuePair>();
            if (ids != null) {
                params.add(createNameValuePair("follow", ids));
            }
            if (keywords != null) {
                //HashSet<String> items=new HashSet<String>();
                params.add(createNameValuePair("track", keywords));
                //params.add(createNameValuePair("track", items));
            }
            return params.toArray(new NameValuePair[params.size()]);
        }

        private NameValuePair createNameValuePair(
            String name, Collection<String> items)
        {
            StringBuilder sb = new StringBuilder();
            boolean needComma = false;
            for (String item : items) {
                if (needComma) {
                    sb.append(',');
                }
                needComma = true;
                sb.append(item);
            }
            return new NameValuePair(name, sb.toString());
        }

        private void resetBackOff() {
            tcpBackOff.reset();
            httpBackOff.reset();
        }
    }
   
    /*
    * Handles backing off for an initial time, doubling until a cap
    * is reached.
    */
   private static class BackOff {
        private final boolean noInitialBackoff;
        private final long initialMillis;
        private final long capMillis;
        private long backOffMillis;

        /**
         * @param noInitialBackoff true if the initial backoff should be zero
         * @param initialMillis the initial amount of time to back off, after
         *   an optional zero-length initial backoff
         * @param capMillis upper limit to the back off time
         */
        public BackOff(
            boolean noInitialBackoff, long initialMillis, long capMillis) {
            this.noInitialBackoff = noInitialBackoff;
            this.initialMillis = initialMillis;
            this.capMillis = capMillis;
            reset();
        }

        public BackOff(long initialMillis, long capMillis) {
            this(false, initialMillis, capMillis);
        }

        public void reset() {
            if (noInitialBackoff) {
                backOffMillis = 0;
            }
            else{
                backOffMillis = initialMillis;
            }
        }

        public void backOff() throws InterruptedException {
            if (backOffMillis == 0) {
                backOffMillis = initialMillis;
            }
            else {
                Thread.sleep(backOffMillis);
                backOffMillis *= 2;
                if (backOffMillis > capMillis) {
                    backOffMillis = capMillis;
                }
            }
        }
    }
}
