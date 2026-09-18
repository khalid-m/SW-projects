import javax.xml.soap.*;
import callin.*;
import callout.*;
import java.io.*;
import java.net.*;
import org.w3c.dom.*;
import java.lang.*;

public class CheloniaConnector {

    public boolean logXML = true;
    public int waitGranularity = 500; //in milliseconds
    public int waitLimit = 30; //times the granularity
    public int bufferSize = 64; //read buffer size in bytes
        
    public URL query(String dbname, String query, Boolean update) 
	throws SOAPException, MalformedURLException, IOException {

	URL endpoint = new URL("http://130.238.17.165:60000/Bartender");
	
	// All connections are created by using a connection factory
	SOAPConnectionFactory conFactory = SOAPConnectionFactory.newInstance();
	         
	// Now we can create a SOAPConnection object using the connection factory
	SOAPConnection connection = conFactory.createConnection();
	
	// Now we can create the SOAP message object
	MessageFactory msgFactory = MessageFactory.newInstance();
	SOAPMessage msg = msgFactory.createMessage();
	
	// Get the SOAP part from the SOAP message object
	SOAPPart soapPart = msg.getSOAPPart();
	
	// The SOAP part object will automatically contain the SOAP envelope
	SOAPEnvelope envelope = soapPart.getEnvelope();

	// Get the SOAP header from the envelope
	SOAPHeader header = envelope.getHeader();
	
	// The client does not yet support SOAP headers
	header.detachNode();
		
	// Get the SOAP body from the envelope and populate it
	SOAPBody body = envelope.getBody();

	String barUri = "http://www.nordugrid.org/schemas/bartender";
	SOAPFactory soapFactory = SOAPFactory.newInstance();
	SOAPBodyElement be;
	SOAPElement re;
	if (update) {
	    be = body.addBodyElement(soapFactory.createName("updateDatabase","bar",barUri));
	    re = be.addChildElement(soapFactory.createName("updateDatabaseRequestList","bar",barUri)).
		addChildElement(soapFactory.createName("updateDatabaseRequestElement","bar",barUri));
	    re.addChildElement(soapFactory.createName("requestID","bar",barUri)).addTextNode("statement");
	}
	else {
	    be = body.addBodyElement(soapFactory.createName("queryDatabase","bar",barUri));
	    re = be.addChildElement(soapFactory.createName("queryDatabaseRequestList","bar",barUri)).
		 addChildElement(soapFactory.createName("queryDatabaseRequestElement","bar",barUri));
	}

	re.addChildElement(soapFactory.createName("requestID","bar",barUri)).addTextNode("0");
	re.addChildElement(soapFactory.createName("dbName","bar",barUri)).addTextNode(dbname);
	re.addChildElement(soapFactory.createName("query","bar",barUri)).addTextNode(query);
	re.addChildElement(soapFactory.createName("protocol","bar",barUri)).addTextNode("http");

	// Save changes to the message we just populated
	msg.saveChanges();

	if (logXML) { //log request into file
	    FileOutputStream fos1 = new FileOutputStream("request.xml");
	    msg.writeTo(fos1);
	    fos1.close();
	}

	// Send the request and get the response
	SOAPMessage response = connection.call(msg, endpoint);

	if (logXML) { //log response into file
	    FileOutputStream fos2 = new FileOutputStream("response.xml");
	    response.writeTo(fos2);
	    fos2.close();
	}
	
	// Close the connection
	connection.close();
	
	// Extract the output file URL from the response
	if (update) return null;
	else return new URL(response.getSOAPBody().extractContentAsDocument().
			    getElementsByTagName("bar:TURL").item(0).getTextContent());
    }

    public void queryToURL(CallContext cxt, Tuple tpl) 
	throws AmosException, InterruptedException, SOAPException, MalformedURLException, IOException {
	URL qres = query(tpl.getStringElem(0), tpl.getStringElem(1), false);
	tpl.setElem(2,qres.toString());
	cxt.emit(tpl);
    }

    public void update(CallContext cxt, Tuple tpl) 
	throws AmosException, InterruptedException, SOAPException, MalformedURLException, IOException {
	query(tpl.getStringElem(0), tpl.getStringElem(1), true);
    }
}
	

	

	
    
