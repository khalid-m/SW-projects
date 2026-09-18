/*
 * author Bo Yang,2009
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.Queue;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

public class TwitterStreamProcessor {

    public static Queue<JSONObject> q = new LinkedList<JSONObject>();
    
    /*
     * process stream data and add JSONObjects into a queue
     */
   
    public void processTwitterStream(InputStream is)
            throws InterruptedException, IOException {

        JSONTokener jsonTokener = new JSONTokener(
                new InputStreamReader(is, "UTF-8"));

        while (true) {
            try {
                JSONObject jsonObject = new JSONObject(jsonTokener);
                //System.out.println(jsonObject.getString("text"));
                q.add(jsonObject);
            } catch (JSONException ex) {
                throw new IOException(
                        "Got JSONException: " + ex.getMessage());
            }
        }
    }
    
    public void processTwitterStream(InputStream is, int count)
            throws InterruptedException, IOException {
        
        int m = 0;
        JSONTokener jsonTokener = new JSONTokener(
                new InputStreamReader(is, "UTF-8"));

        while (true) {
            try {
                JSONObject jsonObject = new JSONObject(jsonTokener);
                //System.out.println(jsonObject.getString("text"));
                if (m<count)
                q.add(jsonObject);
                
            } catch (JSONException ex) {
                throw new IOException(
                        "Got JSONException: " + ex.getMessage());
            }
            m++;
        }
    }
    }
