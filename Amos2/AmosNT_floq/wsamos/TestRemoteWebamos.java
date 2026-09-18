package wsamos;
import java.util.*;

public class TestRemoteWebamos {

    public static void main (String[] args) throws Exception {
        WebamosService serv = new WebamosServiceLocator();
	java.net.URL url = new java.net.URL("http://130.238.12.248:8080/axis/services/Webamos");
	Webamos port = serv.getWebamos(url);
	String hl=port.sayHello("Milena");
	System.out.println(hl);
    }
}
