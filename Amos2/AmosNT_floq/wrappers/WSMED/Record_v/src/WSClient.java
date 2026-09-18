import java.io.File;

import java.util.List;
import java.util.Iterator;

import java.io.ByteArrayOutputStream;

import java.security.PrivilegedActionException;

import java.util.Map;
import java.util.List;
import java.util.Iterator;
import java.util.*;

import java.lang.Object;
import javax.xml.namespace.QName;



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
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPBodyElement;
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
    public  static String targetNameSpace;

    
    

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
		//System.out.println(" calling webservice ");
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

		//if(isRPC)
		//{
			// Add namespace declarations to the envelope, usually only required for RPC/encoded
		envelope.addNamespaceDeclaration(XSI_NAMESPACE_PREFIX, XSI_NAMESPACE_URI);
		envelope.addNamespaceDeclaration(XSD_NAMESPACE_PREFIX, XSD_NAMESPACE_URI);
			//envelope.addNamespaceDeclaration("", tpl.getStringElem(4));
			//}
		if (!(isRPC))
		    envelope.addNamespaceDeclaration("", tpl.getStringElem(4)); 
			    
	
		// Get the SOAP header from the envelope
		SOAPHeader header = envelope.getHeader();

		// The client does not yet support SOAP headers
		header.detachNode();
		
		// Get the SOAP body from the envelope and populate it
		SOAPBody body = envelope.getBody();
		body.setEncodingStyle(tpl.getStringElem(3));
 
		// Create the default namespace for the SOAP body
		//body.addNamespaceDeclaration("", tpl.getStringElem(4));
	   
		// Add the service information
	       targetNameSpace = tpl.getStringElem(4);
	 
		
		Tuple  res = new Tuple(1);
		Scan s=null;
		Connection theConnection = new Connection("");
		res.setElem(0,tpl.getOidElem(7));
		
		s = theConnection.callFunction("Record.record_length->integer",res);
		res=s.getRow();
	
		if ((res.getIntElem(0))!=0)
		    {
			header=envelope.addHeader();
			createSoapHeader(envelope,header,tpl);
		    }
		
	 	
		 
		// Add the message contents to the SOAP body
		
		createSoapBody(envelope,body,tpl,isRPC);
		
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
		//msg.writeTo(System.out);
		//System.out.println();
		
		// Get ready for the invocation
		URLEndpoint endpoint = new URLEndpoint(tpl.getStringElem(5));
		
		// Make the call
		SOAPMessage response = connection.call(msg, endpoint);
		//System.out.println();
		//response.writeTo(System.out);
		
		// Close the connection, we are done with it
		connection.close();
		// Get the content of the SOAP response
		//Source responseContent = response.getSOAPPart().getContent();
	
		// Convert the SOAP response into a JDOM
		TransformerFactory tFact = TransformerFactory.newInstance();
		Transformer transformer = tFact.newTransformer();

		//JDOMResult jdomResult = new JDOMResult();
		//transformer.transform(responseContent, jdomResult);
	
		// Get the document created by the transform operation
		//Document responseDoc = jdomResult.getDocument();
		//XMLOutputter xmlWriter = new XMLOutputter();
		//System.out.println(" request "+xmlWriter.outputString(responseDoc));
	        //System.out.println(tpl.getStringElem(7));     		 
		//	retstr=XMLSupport.outputString(responseDoc,isRPC);
		Tuple restpl= new Tuple(2);
		restpl.setElem(0,tpl.getOidElem(9));
		restpl.setElem(1,tpl.getOidElem(11));
			
		if (isRPC)
		    {
			
			retstr.setElem(0,XMLSupport.rpc_webserviceResponse(response,restpl));
			//return XMLSupport.rpc_webserviceResponse(response,restpl);
			
		    }
		else
		    {
			
			retstr.setElem(0,XMLSupport.webserviceResponse(response,restpl));
			//return XMLSupport.webserviceResponse(response,restpl);
		    }
	    }
	catch(Throwable ex)
	    {
		//System.err.println("Error invoking operation:");
		//System.err.println(ex.getMessage());
		
		retstr.setElem(0,(Oid) null);
	    }
	return retstr;
    }
	  
    
    static void  createSoapHeader(SOAPEnvelope envelope,SOAPHeader header,Tuple input)
    {
	Tuple  res = new Tuple(1);
	Tuple  wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;

	try
	    {
		Connection theConnection = new Connection("");
		res.setElem(0,input.getOidElem(7));
		s = theConnection.callFunction("Record.all_value->Object",res);
		res=s.getRow();
		QName headerName= new QName(targetNameSpace,res.getStringElem(0),"tns");
		SOAPHeaderElement shElement = header.addHeaderElement(headerName);
		//SOAPHeaderElement shElement = header.addHeaderElement(envelope.createName(res.getStringElem(0),"tns",targetNameSpace));
		s.nextRow();
		res=s.getRow();
		type=(res.getOidElem(0)).getTypename();
			
		if (type.equalsIgnoreCase("Record"))
		    {
			
			res.setElem(0,res.getOidElem(0));
			s = theConnection.callFunction("Record.all_value->Object",res);
			while (!s.eos())
			    {
				res=s.getRow();
				wsdltpl.setElem(1,res.getStringElem(0));
				QName name= new QName(res.getStringElem(0));
				SOAPElement childshElement=shElement.addChildElement(name);
				//childshElement.addAttribute(envelope.createName("xsi:type"),XSD_NAMESPACE_PREFIX + ":" + "string");
				s.nextRow();
				res=s.getRow();
				type=(res.getOidElem(0)).getTypename();
				if (type.equalsIgnoreCase("Record"))
				    {
					Tuple inputtpl= new Tuple(1);
					inputtpl.setElem(0,input.getOidElem(10));
					createSoapElement(envelope,childshElement,inputtpl,res);
				    }
				else
				    {
					wsdltpl.setElem(0,input.getOidElem(10));
					wsdlscan = theConnection.callFunction("Record.Charstring.get_element->Record",wsdltpl);
					wsdltpl.setElem(1,"wsdltype");
					
					wsdltpl.setElem(0,(wsdlscan.getRow()).getOidElem(0));
					
					wsdlscan = theConnection.callFunction("record.charstring.get_ele_properties->charstring",wsdltpl);
						
					QName qn =new QName("xsi:type");
			
					childshElement.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":" +(wsdlscan.getRow()).getStringElem(0));
					if (type.equalsIgnoreCase("charstring"))
					    {
						
						//sbe.addTextNode(res.getStringElem(0))
						childshElement.addTextNode(res.getStringElem(0));
					    }
					else
					    if (type.equalsIgnoreCase("integer"))
						{
						    Integer ie=res.getIntElem(0);
						    //sbe.addTextNode(ie.toString());
						    childshElement.addTextNode(ie.toString());
						}
					    else
						if (type.equalsIgnoreCase("double"))
						    {
							Double db=res.getDoubleElem(0);
							//sbe.addTextNode(db.toString());
							childshElement.addTextNode(db.toString());
						    }
					    
				    }
			
			    }
		    }

		else
		    shElement.addTextNode(res.getStringElem(0));
	    }
	catch(Throwable ex)
	    {}
	
       
    }
    static void createSoapElement(SOAPEnvelope envelope, SOAPElement sh,Tuple input, Tuple tpl)
    {
	Tuple res = new Tuple(1);
	Tuple wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;
	
	try
	    {
		Connection theConnection = new Connection("");
		res.setElem(0,tpl.getOidElem(0));
		s = theConnection.callFunction("Record.all_value->Object",res);
		//System.out.println("test ");
		while (!s.eos())
		    {
			res=s.getRow();
			wsdltpl.setElem(1,res.getStringElem(0));
			QName name = new QName(res.getStringElem(0));
			SOAPElement childshElement=sh.addChildElement(name);
						
			s.nextRow();
			res=s.getRow();
			type=(res.getOidElem(0)).getTypename();
			if (type.equalsIgnoreCase("Record"))
			    {
				Tuple inputtpl= new Tuple(1);
				inputtpl.setElem(0,input.getOidElem(10));
				createSoapElement(envelope,childshElement,inputtpl,res);
			    }
			else
			    {	
					
				//System.out.println("test123 "+input.getElem(0));	
				wsdltpl.setElem(0,input.getOidElem(0));
			
				wsdlscan = theConnection.callFunction("Record.Charstring.get_element->Record",wsdltpl);
				wsdltpl.setElem(1,"wsdltype");
				
				wsdltpl.setElem(0,(wsdlscan.getRow()).getOidElem(0));
				
				wsdlscan = theConnection.callFunction("Record.Charstring.get_ele_properties->Charstring",wsdltpl);
			
				//System.out.println("testing   "+(wsdlscan.getRow()).getStringElem(0));
				QName attribute= new QName(XSI_NAMESPACE_PREFIX + ":" + "type");
				childshElement.addAttribute(attribute,XSD_NAMESPACE_PREFIX + ":" + (wsdlscan.getRow()).getStringElem(0));
				if (type.equalsIgnoreCase("charstring"))
				    {
					
					//sbe.addTextNode(res.getStringElem(0))
					childshElement.addTextNode(res.getStringElem(0));
				    }
				else
				    if (type.equalsIgnoreCase("integer"))
					{
					    Integer ie=res.getIntElem(0);
					    //sbe.addTextNode(ie.toString());
					    childshElement.addTextNode(ie.toString());
					}
				    else
					if (type.equalsIgnoreCase("double"))
					    {
						Double db=res.getDoubleElem(0);
						//sbe.addTextNode(db.toString());
						childshElement.addTextNode(db.toString());
					    }
			    }
			if (!s.eos())
			    s.nextRow();
		    }
	    }
	catch(Throwable ex)
	    {}
       
       
    }
    static void  createSoapBody(SOAPEnvelope envelope,SOAPBody body,Tuple input,Boolean isRPC)
    {
	Tuple  res = new Tuple(1);
	Tuple  wsdltpl = new Tuple(2);
	
	Scan s,wsdlscan;

	String type;
	SOAPBodyElement sbe=null;
	SOAPElement se=null;
	int nrec=0;

	try
	    {
		Connection theConnection = new Connection("");
		res.setElem(0,input.getOidElem(6));
		s = theConnection.callFunction("Record.record_length->integer",res);
		res=s.getRow();
		nrec=res.getIntElem(0);
		if (isRPC)
		    {
			
			QName bodyName = new QName(targetNameSpace,input.getStringElem(0),"tns");
			//QName bodyName = new QName(targetNameSpace,input.getStringElem(0));
			sbe = body.addBodyElement(bodyName);
			
		    }
	
		if (nrec!=0)
		    
		    {
			if (isRPC)
			    {
				res.setElem(0,input.getOidElem(6));
				//createSoapBodyElement(envelope,se,res);
				createSoapBodyElement(envelope,sbe,input,res);
			    }
			else
			    {
				//System.out.println("testing "+isRPC);
				s = theConnection.callFunction("Record.all_value->Object",input.getOidElem(6));
				while(!s.eos())
				    {
					res=s.getRow();
					wsdltpl.setElem(1,res.getStringElem(0));
					QName bodyName = new QName(targetNameSpace,res.getStringElem(0),"tns");
					sbe = body.addBodyElement(bodyName);
					s.nextRow();
					res=s.getRow();
					type=(res.getOidElem(0)).getTypename();
					if (type.equalsIgnoreCase("Record"))
					    {
						//createSoapBodyElement(envelope,sbe,res);
						createSoapBodyElement(envelope,sbe,input,res);
					    }
					else
					    {
						wsdltpl.setElem(0,input.getOidElem(8));
						wsdlscan = theConnection.callFunction("Record.Charstring.get_element->Record",wsdltpl);
						wsdltpl.setElem(1,"wsdltype");
						wsdltpl.setElem(0,(wsdlscan.getRow()).getOidElem(0));
						wsdlscan = theConnection.callFunction("Record.Charstring.get_ele_properties->Charstring",wsdltpl);
					
						QName qn =new QName("xsi:type");
						sbe.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":" + (wsdlscan.getRow()).getStringElem(0));
						if (type.equalsIgnoreCase("charstring"))
						    {
							
							//sbe.addTextNode(res.getStringElem(0))
							se.addTextNode(res.getStringElem(0));
						    }
						else
						    if (type.equalsIgnoreCase("integer"))
							{
							    Integer ie=res.getIntElem(0);
							    //sbe.addTextNode(ie.toString());
							    se.addTextNode(ie.toString());
							}
						    else
							if (type.equalsIgnoreCase("double"))
							    {
								Double db=res.getDoubleElem(0);
								//sbe.addTextNode(db.toString());
								se.addTextNode(db.toString());
							    }	
						
					    }
					
					if (!s.eos())
					    s.nextRow();
				    }
			    }
		    }
	    }
	catch(Throwable ex)
	    {}
    }
   
    static void createSoapBodyElement(SOAPEnvelope envelope,SOAPElement se,Tuple input)
    {
	Tuple res = new Tuple(1);
	Tuple wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;

	try
	    {
		Connection theConnection = new Connection("");
		res.setElem(0,input.getOidElem(0));
		s = theConnection.callFunction("Record.all_value->Object",res);
		//System.out.println("record testing1");	
		while (!s.eos())
		    {
			res=s.getRow();
			wsdltpl.setElem(1,res.getStringElem(0));
			//SOAPElement childshElement=se.addChildElement(envelope.createName(res.getStringElem(0),"ts",targetNameSpace));
			SOAPElement childshElement=se.addChildElement(res.getStringElem(0));
		
			s.nextRow();
			res=s.getRow();
			type=(res.getOidElem(0)).getTypename();
			if (type.equalsIgnoreCase("Record"))
			    createSoapElement(envelope,childshElement,input,res);
			else
			    {	
						
				wsdltpl.setElem(0,input.getOidElem(8));
				wsdlscan = theConnection.callFunction("Record.Charstring.get_element->Record",wsdltpl);
				wsdltpl.setElem(1,"wsdltype");
				wsdltpl.setElem(0,(wsdlscan.getRow()).getOidElem(0));
				wsdlscan = theConnection.callFunction("Record.Charstring.get_ele_properties->Charstring",wsdltpl);
				
				QName qn =new QName("xsi:type");
				childshElement.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":" + (wsdlscan.getRow()).getStringElem(0));
				
				if (type.equalsIgnoreCase("charstring"))
				    childshElement.addTextNode(res.getStringElem(0));
				else
				    if (type.equalsIgnoreCase("integer"))
					{
					    Integer ie=res.getIntElem(0);
					    childshElement.addTextNode(ie.toString());
					}
				    else
					if (type.equalsIgnoreCase("double"))
					    {
						Double db=res.getDoubleElem(0);
						childshElement.addTextNode(db.toString());
					    }
			    }
			if (!s.eos())
			    s.nextRow();
		    }
	    }
	catch(Throwable ex)
	    {}
       
       
    }
    static void createSoapBodyElement(SOAPEnvelope envelope,SOAPBodyElement sb,Tuple input,Tuple tpl)
    {
	Tuple res = new Tuple(1);
	Tuple wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;

	try
	    {
		Connection theConnection = new Connection("");
		res.setElem(0,tpl.getOidElem(0));
	
		s = theConnection.callFunction("Record.all_value->Object",res);
		while (!s.eos())
		    {
			res=s.getRow();
			wsdltpl.setElem(1,res.getStringElem(0));
			QName name= new QName(res.getStringElem(0));
			SOAPElement childshElement=sb.addChildElement(name);
						
			s.nextRow();
			res=s.getRow();
			type=(res.getOidElem(0)).getTypename();
			if (type.equalsIgnoreCase("Record"))
			    {
				//System.out.println("record testing >>>>>>");
				Tuple inputtpl= new Tuple(1);
				inputtpl.setElem(0,input.getOidElem(8));
				createSoapElement(envelope,childshElement,inputtpl,res);
			    }
			else
			    {	
							
				wsdltpl.setElem(0,input.getOidElem(8));
				wsdlscan = theConnection.callFunction("Record.Charstring.get_element->Record",wsdltpl);
				wsdltpl.setElem(1,"wsdltype");
				wsdltpl.setElem(0,(wsdlscan.getRow()).getOidElem(0));
				wsdlscan = theConnection.callFunction("Record.Charstring.get_ele_properties->Charstring",wsdltpl);
				
				QName qn =new QName("xsi:type");
				childshElement.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":"+(wsdlscan.getRow()).getStringElem(0));
			
				if (type.equalsIgnoreCase("charstring"))
				    childshElement.addTextNode(res.getStringElem(0));
				else
				    if (type.equalsIgnoreCase("integer"))
					{
					    Integer ie=res.getIntElem(0);
					    childshElement.addTextNode(ie.toString());
					}
				    else
					if (type.equalsIgnoreCase("double"))
					    {
						Double db=res.getDoubleElem(0);
						childshElement.addTextNode(db.toString());
					    }
			    }
			if (!s.eos())
			    s.nextRow();
		    }
	    }
	catch(Throwable ex)
	    {}
       
       
    }

  }
