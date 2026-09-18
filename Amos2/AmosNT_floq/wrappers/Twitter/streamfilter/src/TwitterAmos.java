/**
 * author Bo Yang,2009
 */


import callin.*; // The Amos II callin interface
import callout.CallContext;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.JSONArray;
import org.json.JSONException;
//import org.json.JSONObject;
import org.json.JSONObject;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.User;

public class TwitterAmos { 
    
    public static boolean f=false;
    /*
     * Process JSONObject to Amos II Vector 
     */
    public Tuple processJson(JSONObject jsonobject, Tuple t) {
        JSONArray keys = jsonobject.names();
        for (int i = 0; i < keys.length(); i++) {
            try {
                //put the key of JSONObject into Vector
                t.setElem(i * 2, keys.getString(i));
                //put the corresponding value of JSONObject into Vector
                if (jsonobject.get(keys.getString(i)).getClass().getName().equals("org.json.JSONObject")) {
                    JSONObject temp = jsonobject.getJSONObject(keys.getString(i));
                    Tuple temp1 = processJson(temp, new Tuple(temp.names().length() * 2));
                    t.setElem(i * 2 + 1, temp1);
                } else {
                    t.setElem(i * 2 + 1, jsonobject.getString(keys.getString(i)));
                }
            } catch (AmosException ex) {
                Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
            } catch (JSONException ex) {
                Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return t;
    }

    public void jsonWrapper(final CallContext cxt, final Tuple tpl) throws AmosException {
        try {
            String url = tpl.getStringElem(0);
            String credentials = tpl.getStringElem(1) + ":" + tpl.getStringElem(2);
            Tuple v = tpl.getSeqElem(3);
            String type = v.getStringElem(0);
            String value = v.getStringElem(1);

            if (type.equals("track")) {
                Collection<String> param = new HashSet<String>();
                param.add(value);
                ConnTwitter ct = new ConnTwitter(new TwitterStreamProcessor(), url, credentials, param, type,0);
                ct.execute();
            }
            if (type.equals("friends")) {
                try {
                    ArrayList<String> followIds = new ArrayList<String>();
                    Twitter twitter = new Twitter();
                    List<User> users = twitter.getFriendsStatuses(tpl.getStringElem(1));
                    Iterator<User> followers = users.iterator();
                    for (int i = 0; i < users.size(); i++) {
                        if (followers.hasNext()) {
                            followIds.add(Integer.toString(followers.next().getId()));
                        }
                    }
                    ConnTwitter ct = new ConnTwitter(new TwitterStreamProcessor(), url, credentials, followIds, type,0);
                    ct.execute();
                } catch (TwitterException ex) {
                    Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            //wait for 1 second and process JSONObject in a queue
            Thread.sleep(1000);
            while (true) {
                if (!TwitterStreamProcessor.q.isEmpty()) {
                    JSONObject jsonobject = TwitterStreamProcessor.q.remove();
                    tpl.setElem(4, processJson(jsonobject, new Tuple(jsonobject.names().length() * 2)));
                    cxt.emit(tpl);
                }
                Thread.sleep(500);
            }
        } catch (InterruptedException ex) {
            Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void jsonWrapperCount(final CallContext cxt, final Tuple tpl) throws AmosException {
        try {
            String url = tpl.getStringElem(0);
            String credentials = tpl.getStringElem(1) + ":" + tpl.getStringElem(2);
            Tuple v = tpl.getSeqElem(3);
            String type = v.getStringElem(0);
            String value = v.getStringElem(1);
            int m=0;
            int count=tpl.getIntElem(4);

            if (type.equals("track")) {
                Collection<String> param = new HashSet<String>();
                param.add(value);
                ConnTwitter ct = new ConnTwitter(new TwitterStreamProcessor(), url, credentials, param, type,count);
                ct.execute();
            }
            if (type.equals("friends")) {
                try {
                    ArrayList<String> followIds = new ArrayList<String>();
                    Twitter twitter = new Twitter();
                    List<User> users = twitter.getFriendsStatuses(tpl.getStringElem(1));
                    Iterator<User> followers = users.iterator();
                    for (int i = 0; i < users.size(); i++) {
                        if (followers.hasNext()) {
                            followIds.add(Integer.toString(followers.next().getId()));
                        }
                    }
                    ConnTwitter ct = new ConnTwitter(new TwitterStreamProcessor(), url, credentials, followIds, type,count);
                    ct.execute();
                } catch (TwitterException ex) {
                    Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            //wait for 1 second and process JSONObject in a queue
            Thread.sleep(1000);
            while (m<count) {
                if (!TwitterStreamProcessor.q.isEmpty()) {
                    m++;
                    JSONObject jsonobject = TwitterStreamProcessor.q.remove();
                    tpl.setElem(5, processJson(jsonobject, new Tuple(jsonobject.names().length() * 2)));
                    cxt.emit(tpl);
                    
                }
                Thread.sleep(500);
            }
           
        } catch (InterruptedException ex) {
            Logger.getLogger(TwitterAmos.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static void main(String argv[]) throws AmosException {
        Connection.initializeAmos(argv);
        Connection theConnection = new Connection("");
        theConnection.amosTopLoop("JavaAmos II"); // Enters the AmosQL top-loop

    }
}
