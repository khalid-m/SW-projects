import java.net.URLStreamHandler;
import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.io.*;


public class WSHttpStreamHandler extends URLStreamHandler{
  
    protected URLConnection openConnection(URL url) throws IOException{
	//HttpURLConnection conn = new HttpURLConnection(url, null);
	HttpURLConnection conn=null;
	try{
         url=new URL(url.toString());
	 conn = (HttpURLConnection)url.openConnection();
		
	conn.setConnectTimeout(10*1000);
	conn.setReadTimeout(50*1000);
	}
        catch(java.net.MalformedURLException ex)
		 {
	          System.out.println("¤¤¤¤¤¤¤¤¤¤ "+ex.getMessage());
		  ex.printStackTrace();
		  }
	return conn;
	
    }
}
