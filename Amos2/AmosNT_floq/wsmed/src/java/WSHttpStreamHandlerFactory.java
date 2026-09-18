import java.net.URLStreamHandlerFactory;
import java.net.URLStreamHandler;
public class WSHttpStreamHandlerFactory implements URLStreamHandlerFactory{
 public WSHttpStreamHandlerFactory() {
 }

 public URLStreamHandler createURLStreamHandler( String protocol ){
	
        return new WSHttpStreamHandler();

   }
}
