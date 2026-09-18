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
import org.jdom.output.XMLOutputter;

import callin.*;
import callout.*;
/**
 * Web Services sample client. Uses the SAAJ library to consume a web service.
 *
 */

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
    static  int eleindex=0;
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
        //Vector<Object> retstr=new Vector<Object>();
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

		// Get the SOAP body from the envelope and populate it
		SOAPBody body = envelope.getBody();
 
		// Create the default namespace for the SOAP body
		body.addNamespaceDeclaration("", tpl.getStringElem(5));
	   
		// Add the service information
		String targetObjectURI = tpl.getStringElem(4);
	 
		if(targetObjectURI == null)
		    {
			// The target object URI should not be null
			targetObjectURI = "";
		    }
		
		// Add the service information
		Name svcInfo = envelope.createName(tpl.getStringElem(0), "", targetObjectURI);
		
		// Name svcInfo = envelope.createName(operation.getTargetMethodName());
		SOAPElement svcElem = body.addChildElement(svcInfo);

		if(isRPC)
		    {
			// Set the encoding style of the service element
			svcElem.setEncodingStyle(tpl.getStringElem(3));
		    } 
	 
		Element rootElem = new Element(tpl.getStringElem(0));

		// Add the message contents to the SOAP body
		Document doc = XMLSupport.readXML( XMLSupport.outputString(calldecode(rootElem,tpl,isRPC)));
		//Document doc = XMLSupport.readXML( XMLSupport.outputString(calldecode(rootElem,input,arg,isRPC)));
		//XMLOutputter xmlWriter = new XMLOutputter();
		//System.out.println(" Test "+xmlWriter.outputString(doc));
		if(doc.hasRootElement())
		    {
	     		// Begin building content
			buildSoapElement(envelope, svcElem, doc.getRootElement(), isRPC);
		    }
		// XMLOutputter xmlWriter = new XMLOutputter();
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
	
		// Get ready for the invocation
		URLEndpoint endpoint = new URLEndpoint(tpl.getStringElem(6));
	
		// Make the call
		SOAPMessage response = connection.call(msg, endpoint);
	 
		// Close the connection, we are done with it
		connection.close();

		// Get the content of the SOAP response
		Source responseContent = response.getSOAPPart().getContent();
	
		// Convert the SOAP response into a JDOM
		TransformerFactory tFact = TransformerFactory.newInstance();
		Transformer transformer = tFact.newTransformer();

		JDOMResult jdomResult = new JDOMResult();
		transformer.transform(responseContent, jdomResult);
	
		// Get the document created by the transform operation
		Document responseDoc = jdomResult.getDocument();
		//XMLOutputter xmlWriter = new XMLOutputter();
		//System.out.println(" Test "+xmlWriter.outputString(responseDoc));
		//System.out.println(XMLSupport.outputString(responseDoc));

		//System.out.println(XMLSupport.outputString(responseDoc));
		retstr=XMLSupport.outputString(responseDoc);
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
   protected  static void buildSoapElement(SOAPEnvelope envelope, SOAPElement soapElem, Element jdomElem, boolean isRPC) throws SOAPException
    {
	// If the source node has text use its value
	String elemText = jdomElem.getText();
       
	if(elemText != null)
	    {
		if(isRPC == true)
		    {
			// Set the type attribute for this element
			String type = jdomElem.getAttributeValue("type");
			
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
			Name attrName = envelope.createName(attr.getName(), attr.getNamespacePrefix(), attr.getNamespaceURI());

			// Add the attribute and its value to the element
			soapElem.addAttribute(attrName, attr.getValue());
		    }
	    }

	// Build children
	List children = jdomElem.getChildren();
 
	if(children != null)
	    {
		Iterator childIter = children.iterator();
		while(childIter.hasNext())
		    {
			Element jdomChildElem = (Element)childIter.next();
	     
			// Create a new SOAPElement as a child of the current one
			SOAPElement soapChildElem = soapElem.addChildElement(jdomChildElem.getName());

			// Build it
			buildSoapElement(envelope, soapChildElem, jdomChildElem, isRPC);
		    }
	    }
    }

  
    static Element  calldecode(Element rootElem,Tuple tpl,boolean isRPC)
    {
	try
	    {
		Tuple input = new Tuple(((Tuple)tpl.getSeqElem(7)).getArity());
		Tuple arg   = new Tuple(((Tuple)tpl.getSeqElem(8)).getArity());
           
		for (int i=0;i<((Tuple)tpl.getSeqElem(7)).getArity();i++)
		     if (((Tuple)tpl.getSeqElem(7)).isTuple(i))
			    input.setElem(i,((Tuple)tpl.getSeqElem(7)).getSeqElem(i));
		       else
			if (((Tuple)tpl.getSeqElem(7)).isString(i))
			    input.setElem(i,((Tuple)tpl.getSeqElem(7)).getStringElem(i));
					 
		    
	        for (int j=0;j<((Tuple)tpl.getSeqElem(8)).getArity();j++)
		    if (((Tuple)tpl.getSeqElem(8)).isTuple(j))
				arg.setElem(j,((Tuple)tpl.getSeqElem(8)).getSeqElem(j));
		     else
			 arg.setElem(j,((Tuple)tpl.getSeqElem(8)).getStringElem(j));
		        
	 
		rootElem=decode(rootElem,input,arg,isRPC);
		eleindex=0;
		inputindex=0;
	    }
	catch(Throwable ex)
	    {}
	return(rootElem);   
    }

    static Element decode(Element rootElem,Tuple input,Tuple arg,boolean isRPC)
    {
	Element parElem=rootElem;
	int tempinputindex;
	try
	    {
		while (inputindex<input.getArity())
		    {
			if (input.isTuple(inputindex))
			    {
				parElem = new Element(arg.getStringElem(eleindex));
				eleindex++;
				tempinputindex=inputindex;
				inputindex=0;
				decode(parElem,((Tuple)input.getSeqElem(tempinputindex)),arg,isRPC);
				inputindex=tempinputindex+1;
			    }
			else
			    if (input.isString(inputindex))
				{
				    parElem = new Element(arg.getStringElem(eleindex));
				    eleindex++;
				    parElem.addContent(input.getStringElem(inputindex));
				    inputindex++;
				}
					
			rootElem.addContent(parElem);
		    }
	    }
	catch(Throwable ex)
	    {}
	return rootElem;
	
    }
  }
