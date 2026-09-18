import java.io.File;

import java.util.List;
import java.util.Iterator;

import java.io.ByteArrayOutputStream;

import java.security.PrivilegedActionException;

import java.util.Map;
import java.util.List;
import java.util.Iterator;
import java.util.*;


import javax.xml.soap.MessageFactory;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPHeaderElement;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.soap.MimeHeaders;

import javax.xml.messaging.URLEndpoint;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Attribute;
import org.jdom.transform.JDOMResult;
import org.jdom.transform.JDOMSource;
import org.jdom.output.XMLOutputter;
import org.jdom.input.DOMBuilder;
import callin.*;
import callout.*;

import java.util.*;
import java.io.*;

/* Uses the SAAJ library to consume a web service. */

public class WSClient
{
   /** The prefix to use for XML Schema instance namespace */
   public static final String XSI_NAMESPACE_PREFIX = "xsi";

   /** The URI for XML Schema instance namespace */
   public static final String XSI_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema-instance";

   /** The prefix to use for XML Schema namespace */
   public static final String XSD_NAMESPACE_PREFIX = "xsd";

   /** The URI for XML Schema namespace */
   public static final String XSD_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema";

   
    public static int  startpos;
    public static int globalindex=0;
    static  int inputindex=0;
    static  int eleindex;
    static  int eleveclen;
    static  int inptlen;

    
    

    /**
    * Constructor
    */
    public WSClient()
    {
    }

   /**
    * Invokes an operation using SAAJ
    *
    * @param operation The operation to invoke
    */
    public static Tuple invokeOperation(Tuple tpl) throws SOAPException,AmosException 
    { 
	Tuple retstr= new Tuple(1);
        
	eleindex=0;
	try
	    { 
	 	  
		// Determine if the operation style is RPC
		boolean isRPC =( tpl.getStringElem(2)).equals("rpc");

		// All connections are created by using a connection factory
		SOAPConnectionFactory conFactory = SOAPConnectionFactory.newInstance();
		
		// Now we can create a SOAPConnection object using the connection factory
		SOAPConnection connection = conFactory.createConnection();
	 
		// All SOAP messages are created by using a message factory
		MessageFactory msgFactory = MessageFactory.newInstance();

		// Now we can create the SOAP message object
		SOAPMessage msg = msgFactory.createMessage();

		// Get the SOAP part from the SOAP message object
		SOAPPart soapPart = msg.getSOAPPart();

		// The SOAP part object will automatically contain the SOAP envelope
		SOAPEnvelope envelope = soapPart.getEnvelope();

		if(isRPC)
		    {
			// Add namespace declarations to the envelope, usually only required for RPC/encoded
			envelope.addNamespaceDeclaration(XSI_NAMESPACE_PREFIX, XSI_NAMESPACE_URI);
			envelope.addNamespaceDeclaration(XSD_NAMESPACE_PREFIX, XSD_NAMESPACE_URI);
		    }
	
		// Get the SOAP header from the envelope
		SOAPHeader header = envelope.getHeader();

		// The client does not yet support SOAP headers
		header.detachNode();
		header=envelope.addHeader();
		SOAPHeaderElement shElement = header.addHeaderElement(envelope.createName("AuthenticationHeader","tns","http://skats.net/services/"));
		SOAPElement childshElement=shElement.addChildElement(envelope.createName("SessionID"));
		childshElement.addTextNode("5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q");
		shElement.addTextNode("5Dk7GEJdXC5Fe07t6wzk7iKrngadVXznLjVQT0gC0vsb2VNLushCXeiAhB2Ki0HuwiQY43c+1QpQOqTLLKX2Y8cRTCHDHO+Q");

		// Get the SOAP body from the envelope and populate it
		SOAPBody body = envelope.getBody();
 
		// Create the default namespace for the SOAP body
		body.addNamespaceDeclaration("", tpl.getStringElem(4));
	   
		// Add the service information
		String targetNameSpace = tpl.getStringElem(4);
	 
		if(targetNameSpace == null)
		    {
			// The target object URI should not be null
			targetNameSpace = "";
		    }
		
		
	 	
		
		// Add the message contents to the SOAP body
		
		Document doc = XMLSupport.readXML( XMLSupport.outputString(calldecode(tpl,isRPC)));
		
	
		//XMLOutputter xmlWriter = new XMLOutputter();
		//System.out.println(" request "+xmlWriter.outputString(doc));
		Name svcInfo=null;
		// Add the service information
		if (isRPC)
		    {
			svcInfo = envelope.createName(tpl.getStringElem(0), "", targetNameSpace);
		    }
		else
		    {
			svcInfo = envelope.createName((doc.getRootElement()).getName() ,"", targetNameSpace);
		    }
		
		// Name svcInfo = envelope.createName(operation.getTargetMethodName());
		SOAPElement svcElem = body.addChildElement(svcInfo);

		if(isRPC)
		    {
			// Set the encoding style of the service element
			svcElem.setEncodingStyle(tpl.getStringElem(3));
		    } 
		if(doc.hasRootElement())
		    {
	     		// Begin building content
			buildSoapElement_1(envelope, svcElem, doc.getRootElement(), isRPC);
		    }

		
		
		// Check for a SOAPAction
		String soapActionURI = tpl.getStringElem(1);
	 
		if(soapActionURI != null && soapActionURI.length() > 0)
		    {
			// Add the SOAPAction value as a MIME header
			MimeHeaders mimeHeaders = msg.getMimeHeaders();
			mimeHeaders.setHeader("SOAPAction", "\"" +soapActionURI+ "\"");
		    }

		// Save changes to the message we just populated
		msg.saveChanges();
		msg.writeTo(System.out);
	
		// Get ready for the invocation
		URLEndpoint endpoint = new URLEndpoint(tpl.getStringElem(5));
	
		// Make the call
		SOAPMessage response = connection.call(msg, endpoint);
		response.writeTo(System.out);
		ByteArrayOutputStream os= new ByteArrayOutputStream();
		response.writeTo(os);
	 
		// Close the connection, we are done with it
		connection.close();
			
		
		String xmlcontent=os.toString();
		xmlcontent=xmlcontent.replace("soap:","");
		xmlcontent=xmlcontent.replace("xmlns=","mlns=");
		createXML(xmlcontent);
		retstr=XQuerymodule.extractResult(tpl.getStringElem(7),"SOAPResponse.xml");
		//retstr=null;
	    }
	catch(Throwable ex)
	    {
		System.err.println("Error invoking operation:");
		System.err.println(ex.getMessage());
	    }
	return retstr;
    }
	  
   /**
    * Builds a hierarchy of SOAPElements given a complex value JDOM Element
    *
    * @param   envelope   The SOAP Envelope
    * @param   rootElem   The root SOAP Element to build content for
    * @param   jdomElem   A JDOM Element that represents a complex value
    * @param   isRPC      Pass true when building for RPC encoded messages
    *
    * @throws SOAPException
    */
     
   protected  static void buildSoapElement_1(SOAPEnvelope envelope, SOAPElement soapElem, Element jdomElem, boolean isRPC) throws SOAPException
    {
	// If the source node has text use its value
	String elemText = jdomElem.getText();
       
	if(elemText != null)
	    {
		if(isRPC == true)
		    {
			// Set the type attribute for this element
			String type = jdomElem.getAttributeValue("type");
			//	System.out.println("testing");
			if(type != null)
			    {
				//soapElem.addAttribute(envelope.createName(XSD_NAMESPACE_PREFIX+":type"), XSD_NAMESPACE_PREFIX + ":" + type);
				soapElem.addAttribute(envelope.createName("xsi" ), XSD_NAMESPACE_PREFIX + ":" + type); 
			    }
		    }
		
		// Add the element text value
		soapElem.addTextNode(elemText);
	  
	    }

	// If the source node has attributes add the attribute values
	List attrs = jdomElem.getAttributes();

	if(attrs != null)
	    {
		Iterator attrIter = attrs.iterator();
		while(attrIter.hasNext())
		    {
			// Get the attribute to add
			Attribute attr = (Attribute)attrIter.next();

			// Create a name for the attribute
			//Name attrName = envelope.createName(attr.getName(), attr.getNamespacePrefix(), attr.getNamespaceURI());
			Name attrName = envelope.createName(attr.getName());

			// Add the attribute and its value to the element
			soapElem.addAttribute(attrName, attr.getValue());
		    }
	    }
	
	// Build children
	List children = jdomElem.getChildren();
	
	SOAPElement soaprootElem=null;
	SOAPElement soapChildElem=null; 
	if(children != null)
	    {
		Iterator childIter = children.iterator();

		if ((jdomElem.getName()!="dummyroot")&& isRPC)
		  soaprootElem = soapElem.addChildElement(jdomElem.getName());
		else
		    soaprootElem=soapElem;
		   
			   		
		while(childIter.hasNext())
		    {
			Element jdomChildElem = (Element)childIter.next();
	     
			/*if (jdomElem.getName()=="dummyroot")
			    {
				System.out.println("testing wsmed ");
				SOAPElement soapChildElem = soapElem.addChildElement(jdomChildElem.getName());	
				buildSoapElement(envelope, soapChildElem, jdomChildElem, isRPC);
			    }
			else
			    {
			
				// Create a new SOAPElement as a child of the current one
				//SOAPElement soaprootElem = soapElem.addChildElement(jdomElem.getName());
				System.out.println(jdomChildElem.getName());
				SOAPElement soapChildElem = soaprootElem.addChildElement(jdomChildElem.getName());

				// Build it
				buildSoapElement(envelope, soapChildElem, jdomChildElem, isRPC);
				}*/
			if (jdomElem.getName()!="dummyroot")
			    {
				// Create a new SOAPElement as a child of the current one
				soapChildElem = soaprootElem.addChildElement(jdomChildElem.getName());
				// Build it
				//buildSoapElement_2(envelope, soapChildElem, jdomChildElem, isRPC);
			    }
			else
			    {
				soapChildElem = soapElem.addChildElement(jdomChildElem.getName());
				//buildSoapElement_2(envelope, soapChildElem, jdomChildElem, isRPC);
			    }
			buildSoapElement_2(envelope, soapChildElem, jdomChildElem, isRPC);
		    }
	    }
    }

  protected  static void buildSoapElement_2(SOAPEnvelope envelope, SOAPElement soapElem, Element jdomElem, boolean isRPC) throws SOAPException
    {
	// If the source node has text use its value
	String elemText = jdomElem.getText();
       
	if(elemText != null)
	    {
		if(isRPC == true)
		    {
			// Set the type attribute for this element
			String type = jdomElem.getAttributeValue("type");
			//	System.out.println("testing");
			if(type != null)
			    {
				//soapElem.addAttribute(envelope.createName(XSD_NAMESPACE_PREFIX+":type"), XSD_NAMESPACE_PREFIX + ":" + type);
				soapElem.addAttribute(envelope.createName("xsi" ), XSD_NAMESPACE_PREFIX + ":" + type); 
			    }
		    }
		
		// Add the element text value
		soapElem.addTextNode(elemText);
	  
	    }

	// If the source node has attributes add the attribute values
	List attrs = jdomElem.getAttributes();

	if(attrs != null)
	    {
		Iterator attrIter = attrs.iterator();
		while(attrIter.hasNext())
		    {
			// Get the attribute to add
			Attribute attr = (Attribute)attrIter.next();

			// Create a name for the attribute
			//Name attrName = envelope.createName(attr.getName(), attr.getNamespacePrefix(), attr.getNamespaceURI());
			Name attrName = envelope.createName(attr.getName());

			// Add the attribute and its value to the element
			soapElem.addAttribute(attrName, attr.getValue());
		    }
	    }
	

	// Build children
	List children = jdomElem.getChildren();
	Boolean dummy=false;
	SOAPElement soaprootElem=null;
	if(children != null)
	    {
		Iterator childIter = children.iterator();
			   		
		while(childIter.hasNext())
		    {
			Element jdomChildElem = (Element)childIter.next();
	     
			/*if (jdomElem.getName()!="dummyroot")
			    {
				// Create a new SOAPElement as a child of the current one
				SOAPElement soapChildElem = soapElem.addChildElement(jdomElem.getName());
				// Build it
				buildSoapElement(envelope, soapChildElem, jdomChildElem, isRPC);
			    }
			else
			    {
				buildSoapElement(envelope, soapElem, jdomChildElem, isRPC);
				}*/
			// Create a new SOAPElement as a child of the current one
				SOAPElement soapChildElem = soapElem.addChildElement(jdomChildElem.getName());
				// Build it
				buildSoapElement_2(envelope, soapChildElem, jdomChildElem, isRPC);
		    }
	    }
    }

   
    static Element  calldecode(Tuple tpl,boolean isRPC)
    {
	Element rootElem=null;
	try
	    {
			 
		if((tpl.getSeqElem(6)).getArity()>=2)
		    {
			if ((tpl.getSeqElem(6)).isTuple(1)&& (tpl.getSeqElem(6)).getArity()<3)
			    {
				rootElem=new Element((tpl.getSeqElem(6)).getStringElem(0));
				rootElem=decode(rootElem,(tpl.getSeqElem(6)).getSeqElem(1),isRPC); 
			
			    }
			else
			    {
				rootElem=new Element("dummyroot");
				rootElem=decode(rootElem,tpl.getSeqElem(6),isRPC); 
			    }
		    }
		else
		    {
			rootElem=new Element("dummyroot");	
		    }
	 

	    }
	catch(Throwable ex)
	    {}
	return rootElem;   
    }
 static Element decode(Element rootElem,Tuple input,boolean isRPC)
    {
	Element parElem=null;
	String type;
	Integer a=0;
		
	try
	    {
		while (a<input.getArity())
		    {
			parElem = new Element(input.getStringElem(a));
		
			a++;
			type=(input.getOidElem(a)).getTypename();
			if (type.equalsIgnoreCase("vector"))
			    parElem=decode(parElem, input.getSeqElem(a), isRPC);
			else
			    if (type.equalsIgnoreCase("charstring"))
				parElem.addContent(input.getStringElem(a));
			    else
				if (type.equalsIgnoreCase("integer"))
				    {
					Integer ie=input.getIntElem(a);
					parElem.addContent(ie.toString());
				    }
				else
				    if (type.equalsIgnoreCase("double"))
					{
					    Double db=input.getDoubleElem(a);
					    parElem.addContent(db.toString());
					}
				    else
					parElem.addContent((input.getOidElem(a)).toString()); 
			a++;
			rootElem.addContent(parElem);
		    }
	    }
	catch(Throwable ex)
	    {}
	return rootElem;
       
	}
     private static void createXML(String ip)
    {
	FileOutputStream out; // declare a file output object
	PrintStream p; // declare a print stream object

	try
	    {
		// Create a new file output stream
		// connected to "myfile.txt"
		out = new FileOutputStream("SOAPResponse.xml");
		
		// Connect print stream to the output stream
		p = new PrintStream( out );
		p.println (ip);
		p.close();
	    }
	catch (Exception e)
	    {
		System.err.println ("Error writing to file");
	    }
    }

  }
