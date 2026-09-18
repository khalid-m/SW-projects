/**
 *  @author  Manivasakan Sabesan
 */
import java.io.File;

import java.util.List;
import java.util.Iterator;

import java.io.ByteArrayOutputStream;
import java.util.Iterator;
import java.lang.Object;
import javax.xml.namespace.QName;
import javax.xml.soap.*;
import javax.xml.messaging.URLEndpoint;
import callin.*;
import callout.*;
import java.io.*;
import java.net.URLStreamHandler;
import java.net.URLStreamHandlerFactory;
import java.net.URL;
import java.net.URLConnection;


/**
 *  Uses the SAAJ library to consume a web service. 
*/

public class WSClient {
    /** The prefix to use for XML Schema instance namespace */
    static final String XSI_NAMESPACE_PREFIX = "xsi";

    /** The URI for XML Schema instance namespace */
    static final String XSI_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema-instance";

    /** The prefix to use for XML Schema namespace */
    static final String XSD_NAMESPACE_PREFIX = "xsd";

    /** The URI for XML Schema namespace */
    static final String XSD_NAMESPACE_URI = "http://www.w3.org/2001/XMLSchema";
    
       
    static int  startpos;
    static int globalindex=0;
    static  int inputindex=0;
    static int cwo=0;
    static  int eleindex;
    static int eleveclen;
    static int inptlen;
    static  int inputeleindex=0;
    static String targetNameSpace;
    static String[] basictype=new String[45];
    SOAPMessage resultmsg=null;
    boolean     received=false;
    static double wsexet=0.0;
    private int timeoutcount=0;
    private int timeoutcount_server=0;

    /**
     * Constructor
     */
    public WSClient() {
	basictype[0]="anyURI";               
	basictype[1]= "base64Binary"; 
	basictype[2]= "boolean";            
	basictype[3]= "byte";                
	basictype[4]= "date";                
	basictype[5]= "dateTime";           
	basictype[6]= "decimal";            
	basictype[7]= "double";              
	basictype[8]= "duration";            
	basictype[9]= "ENTITIES";             
	basictype[10]= "ENTITY";            
	basictype[11]= "float";             
	basictype[12]= "gDay";               
	basictype[13]= "gMonth";             
	basictype[14]= "gMonthDay";          
	basictype[15]= "gYear";             
	basictype[16]= "gYearMonth";        
	basictype[17]= "hexBinary";         
	basictype[18]= "ID";                
	basictype[19]= "IDREF";              
	basictype[20]= "IDREFS";            
	basictype[21]= "int";                 
	basictype[22]= "integer";           
	basictype[23]= "language";          
	basictype[24]= "long";               
	basictype[25]= "Name";               
	basictype[26]= "NCName";            
	basictype[27]= "negativeInteger";    
	basictype[28]= "NMTOKEN";           
	basictype[29]= "NMTOKENS";           
	basictype[30]= "nonNegativeInteger"; 
	basictype[31]= "nonPositiveInteger";
	basictype[32]= "normalizedString";   
	basictype[33]= "NOTATION";           
	basictype[34]= "positiveInteger";   
	basictype[35]= "QName";             
	basictype[36]= "short";             
	basictype[37]= "string";             
	basictype[38]= "time";               
	basictype[39]= "token";             
	basictype[40]= "unsignedByte";      
	basictype[41]= "unsignedInt";         
	basictype[42]= "unsignedLong";      
	basictype[43]= "unsignedShort";      
       	basictype[44]= "anyType";
    }
    
   

    /**
     * Invokes an operation using SAAJ
     *
     * @param operation The operation to invoke
     */
    Tuple invokeOperation(CallContext cxt, Tuple tpl)throws AmosException, SOAPException, java.net.MalformedURLException { 
	Tuple retstr= new Tuple(1);
	Tuple dummy= new Tuple(1);
        
	eleindex=0;
	inputeleindex=0;
	String namespace;
	Tuple temptpl=null;
	
	wsexet=0.0;
	try { 
	    boolean isRPC =( tpl.getStringElem(2)).equals("rpc");
		
	    System.out.println("Calling webservice operation "+ tpl.getStringElem(0));
		
	    namespace=tpl.getStringElem(5);
	    
	    URL endpoint = null;
	    WSHttpStreamHandlerFactory fact = new WSHttpStreamHandlerFactory();
            
	    String protocol = namespace.substring(0, namespace.indexOf(":"));
           
	    WSHttpStreamHandler handler = (WSHttpStreamHandler)fact.createURLStreamHandler(protocol);
	    endpoint = new URL((URL)null, namespace, handler);
	
	    // All connections are created by using a connection factory
	    SOAPConnectionFactory conFactory = SOAPConnectionFactory.newInstance();
	         
	    // Now we can create a SOAPConnection object using the connection factory
	    SOAPConnection connection = conFactory.createConnection();
	 	
	    // All SOAP messages are created by using a message factory
	
	
	    // Now we can create the SOAP message object
	    MessageFactory msgFactory = MessageFactory.newInstance();
	    SOAPMessage msg = msgFactory.createMessage();

	    // Get the SOAP part from the SOAP message object
	    SOAPPart soapPart = msg.getSOAPPart();

	    // The SOAP part object will automatically contain the SOAP envelope
	    SOAPEnvelope envelope = soapPart.getEnvelope();

		
	    // Add namespace declarations to the envelope, usually only required for RPC/encoded
	    envelope.addNamespaceDeclaration(XSI_NAMESPACE_PREFIX, XSI_NAMESPACE_URI);
	    envelope.addNamespaceDeclaration(XSD_NAMESPACE_PREFIX, XSD_NAMESPACE_URI);
		
	    if (!(isRPC))
		envelope.addNamespaceDeclaration("", tpl.getStringElem(4)); 
			    
	
	    // Get the SOAP header from the envelope
	    SOAPHeader header = envelope.getHeader();

	    // The client does not yet support SOAP headers
	    header.detachNode();
		
	    // Get the SOAP body from the envelope and populate it
	    SOAPBody body = envelope.getBody();
                 
	    body.setEncodingStyle(tpl.getStringElem(3));
                
	    // Add the service information
	    targetNameSpace = tpl.getStringElem(4);
	
		
	    Tuple  res = new Tuple(1);
	    Scan s=null;
	    res.setElem(0,tpl.getOidElem(7));
	
	    s = cxt.connection().callFunction("Record.record_length->integer",res);
	    res=s.getRow();
	        	
	    if ((res.getIntElem(0))!=0)	{
		header=envelope.addHeader();
		createSoapHeader(envelope,header,tpl,cxt);
		inputeleindex=0;
	    }
			 
	    // Add the message contents to the SOAP body
		
	    createSoapBody(envelope,body,tpl,isRPC,cxt);
			
	    // Check for a SOAPAction
	    String soapActionURI = tpl.getStringElem(1);
		    
	    if(soapActionURI != null) {
		// Add the SOAPAction value as a MIME header
		MimeHeaders mimeHeaders = msg.getMimeHeaders();
		mimeHeaders.setHeader("SOAPAction", "\"" +soapActionURI+ "\"");
	    }
	              
	    // Save changes to the message we just populated
	
	    msg.saveChanges();
                 
	    //msg.writeTo(System.out);
	   
	    // Make the call
		  	
	    SOAPMessage response = callWebService(connection,msg,endpoint,cxt,tpl.getIntElem(12), tpl.getIntElem(13));
	    //response.writeTo(System.out);
	
	    /* throws a new amos exception for soapfault */
	    
	    if (XMLSupport.findSOAPFault(response)) {
		//throw new SOAPException(XMLSupport.getFaultstring()+">>>>>>"+XMLSupport.getFaultdetail());
		timeoutcount_server++;
		/* Try Again if sever returns a soap fault regarding timeout */
		if ((timeoutcount_server==1)&& ((XMLSupport.getFaultstring()).indexOf(" Timeout expired") > -1)) {
		   
		    return invokeOperation(cxt, tpl);
		}
                else {
		    throw new AmosException(XMLSupport.getFaultstring()+">>>>>>"+XMLSupport.getFaultdetail());
		}
                    
	    }
	
	
	
	    if (response!= null){
		Tuple restpl= new Tuple(2);
		restpl.setElem(0,tpl.getOidElem(9));
		restpl.setElem(1,tpl.getOidElem(11));
		
		       
		if (isRPC)
		    dummy=XMLSupport.rpc_webserviceResponse(response,restpl,cxt);
		else
		    dummy=XMLSupport.webserviceResponse(response,restpl,cxt);

		inputeleindex=0;
                       
		if (dummy==null){
		    temptpl=new Tuple(0);
		    retstr.setElem(0,temptpl);
		}
		else
		    retstr.setElem(0,dummy);
			   
	    }
	    else {
		System.out.println("web service failed");
		temptpl=new Tuple(0);
		retstr.setElem(0,temptpl);
	
	    }			    
	}
	/*catch(IOException ex)
	  {
	  System.err.println("Error invoking operation: "+ tpl.getStringElem(0));
	  System.out.println(ex.getMessage());
	  ex.printStackTrace();
	  //dummy.setElem(0,(Oid)null);
	  //retstr.setElem(0,dummy);
	  }*/
        catch(SOAPException ex){
	    System.err.println("Error invoking operation:>> "+ tpl.getStringElem(0));
	    System.out.println(ex.getMessage());
	    ex.printStackTrace();
	    if (((ex.getMessage()).toString()).indexOf("Message Send Failed Due to Timeout of Web Service") > -1){ 
		throw new AmosException("Message Send Failed Due to Timeout of Web Service");
	    }

	    throw new AmosException(XMLSupport.getFaultstring()+">>>>>>"+XMLSupport.getFaultdetail());
	    //dummy.setElem(0,(Oid)null);
	    //retstr.setElem(0,dummy);
	}
	/*catch(AmosException ex)
	  {
	  System.err.println("Error invoking operation: "+ tpl.getStringElem(0));
	  System.out.println(ex.getMessage());
	  ex.printStackTrace();
	  throw new AmosException(ex.getMessage());
	  //dummy.setElem(0,(Oid)null);
	  //retstr.setElem(0,dummy);
		
	  }*/
	
	
	return retstr;
    }
    
  

    SOAPMessage callWebService(SOAPConnection conn, SOAPMessage msg, URL  np, CallContext cxt, int coid, int level) throws AmosException,SOAPException  {
	SOAPMessage smsg=null;
	Oid bg= null;
	SOAPConnection iconn=conn;
	SOAPMessage imsg=msg;
	URL  inp=np;
	CallContext icxt= cxt;
       
	try {
	    bg = cxt.getBG();
	                
	    cxt.enterBG(bg);
	    System.out.println(level+ " >>  "+ coid);
	    long startTime = System.currentTimeMillis();
	    smsg=conn.call(msg,np);
	    //smsg=conn.call(msg,endpoint);
	    long stopTime = System.currentTimeMillis(); 
	    System.out.println(level+"  <<  "+ coid);
	    cxt.leaveBG(bg);
               
	    wsexet = (stopTime - startTime)/1000.0;
		
	
	}
      	catch(Throwable ex) {
            cxt.leaveBG(bg);
	    timeoutcount++;
            
	    if (timeoutcount==1) {
		return callWebService(iconn, imsg, inp, icxt, coid, level);
	    }
	    else {
		throw new AmosException("Message Send Failed Due to Timeout of Web Service");
	    }
	    
	}
        
       	return smsg;
    }
    
    double getTime() { 
	return wsexet;
    }
    
    
    void  createSoapHeader(SOAPEnvelope envelope,SOAPHeader header,Tuple input, CallContext cxt)throws AmosException {
	Tuple  res = new Tuple(1);
	Tuple  wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;
        
	try  {
	    
	    res.setElem(0,input.getOidElem(7));
	    s = cxt.connection().callFunction("Record.all_value->Object",res);
	    res=s.getRow();
	    QName headerName= new QName(targetNameSpace,res.getStringElem(0),"tns");
	    SOAPHeaderElement shElement = header.addHeaderElement(headerName);
	    
	    s.nextRow();
	    res=s.getRow();
	    type=(res.getOidElem(0)).getTypename();
	    inputeleindex=inputeleindex+2;	
	    if (type.equalsIgnoreCase("Record")) {
			
		res.setElem(0,res.getOidElem(0));
		s = cxt.connection().callFunction("Record.all_value->Object",res);
		while (!s.eos()){
		    res=s.getRow();
			
		    QName name= new QName(res.getStringElem(0));
		    SOAPElement childshElement=shElement.addChildElement(name);
		   
		    String elename=res.getStringElem(0);
		    s.nextRow();
		    res=s.getRow();
		    type=(res.getOidElem(0)).getTypename();
		    if (type.equalsIgnoreCase("Record")){
			Tuple inputtpl= new Tuple(1);
			inputtpl.setElem(0,input.getOidElem(10));
			
			inputeleindex=inputeleindex+2;
			createSoapElement(envelope,childshElement,inputtpl,res,cxt);
		    }
		    else {
					
		
			wsdltpl.setElem(0,input.getOidElem(10));
			wsdltpl.setElem(1, elename);
			wsdlscan = cxt.connection().callFunction("Record.Charstring.get_wsdltype->Charstring",wsdltpl);	
                                         
			QName qn =new QName("xsi:type");
		
			if ((findbasictype((wsdlscan.getRow()).getStringElem(0))).equalsIgnoreCase(""))
			    childshElement.addAttribute(qn,"tns"+ ":" +(wsdlscan.getRow()).getStringElem(0));
			else
			    childshElement.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":" +(wsdlscan.getRow()).getStringElem(0));

			if (type.equalsIgnoreCase("charstring")) {
						
			    
			    childshElement.addTextNode(res.getStringElem(0));
			}
			else
			    if (type.equalsIgnoreCase("integer")) {
				Integer ie=res.getIntElem(0);
				childshElement.addTextNode(ie.toString());
			    }
			    else
				if (type.equalsIgnoreCase("real")) {
				    Double db=res.getDoubleElem(0);
				    childshElement.addTextNode(db.toString());
				}
					
					    
		    }
		    if (!s.eos()) {
			s.nextRow();
		    }
			
		}
	    }

	    else
		shElement.addTextNode(res.getStringElem(0));
	}
	catch(Throwable ex)
	    {
		System.out.println(ex);
	    }
	
       
    }
    void createSoapElement(SOAPEnvelope envelope, SOAPElement sh,Tuple input, Tuple tpl, CallContext cxt) throws AmosException  {
	Tuple res = new Tuple(1);
	Tuple wsdltpl = new Tuple(2);

	Scan s,wsdlscan;

	String type;
	
	try {
	    
	    res.setElem(0,tpl.getOidElem(0));
	    s = cxt.connection().callFunction("Record.all_value->Object",res);
	    
	    while (!s.eos()) {
		res=s.getRow();
		
		QName name = new QName(res.getStringElem(0));
		SOAPElement childshElement=sh.addChildElement(name);
		String elename=res.getStringElem(0);		
		s.nextRow();
		res=s.getRow();
		type=(res.getOidElem(0)).getTypename();
		if (type.equalsIgnoreCase("Record")) {	
                                
		    Tuple inputtpl= new Tuple(1);
		    inputtpl.setElem(0,input.getOidElem(0));
		    inputeleindex=inputeleindex+2;
		    createSoapElement(envelope,childshElement,inputtpl,res,cxt);
		}
		else {	
		    wsdltpl.setElem(0,input.getOidElem(0));
		    wsdltpl.setElem(1, elename);
		    wsdlscan = cxt.connection().callFunction("Record.Charstring.get_wsdltype->Charstring",wsdltpl);
		    
		    inputeleindex=inputeleindex+2;
		    
		    QName attribute= new QName(XSI_NAMESPACE_PREFIX + ":" + "type");
		    if ((findbasictype((wsdlscan.getRow()).getStringElem(0))).equalsIgnoreCase(""))
			childshElement.addAttribute(attribute,"tns"+ ":" +(wsdlscan.getRow()).getStringElem(0));
		    else
			childshElement.addAttribute(attribute,XSD_NAMESPACE_PREFIX + ":" +(wsdlscan.getRow()).getStringElem(0));
			
		    if (type.equalsIgnoreCase("charstring")) {
			childshElement.addTextNode(res.getStringElem(0));
		    }
		    else
			if (type.equalsIgnoreCase("integer")) {
			    Integer ie=res.getIntElem(0);
			    childshElement.addTextNode(ie.toString());
			}
			else
			    if (type.equalsIgnoreCase("real")){
				Double db=res.getDoubleElem(0);
				childshElement.addTextNode(db.toString());
			    }
		}
		if (!s.eos()){
		    s.nextRow();
		}
	    }
	}
	catch(Throwable ex) {
	    System.out.println(ex);
	}
       
       
    }
    void  createSoapBody(SOAPEnvelope envelope,SOAPBody body,Tuple input,Boolean isRPC, CallContext cxt)throws AmosException {
	Tuple  res = new Tuple(1);
	Tuple  wsdltpl = new Tuple(2);
	
	Scan s,wsdlscan;

	String type;
	SOAPBodyElement sbe=null;
	SOAPElement se=null;
	int nrec=0;

	try  { 
	    res.setElem(0,input.getOidElem(6));
	    s = cxt.connection().callFunction("Record.record_length->integer",res);
	    res=s.getRow();
	    nrec=res.getIntElem(0);
	    if (isRPC){
		QName bodyName = new QName(targetNameSpace,input.getStringElem(0),"tns");
		
		sbe = body.addBodyElement(bodyName);
			
	    }
	
	    if (nrec!=0) {
			
		if (isRPC) {
		    res.setElem(0,input.getOidElem(6));
		    createSoapBodyElement(envelope,sbe,input,res,cxt);
		}
		else {
		    s = cxt.connection().callFunction("Record.all_value->Object",input.getOidElem(6));
		    while(!s.eos()) {
			res=s.getRow();
					
			QName bodyName = new QName(targetNameSpace,res.getStringElem(0),"tns");
			String elename=res.getStringElem(0);
			sbe = body.addBodyElement(bodyName);
			s.nextRow();
			res=s.getRow();
			type=(res.getOidElem(0)).getTypename();
			if (type.equalsIgnoreCase("Record")) {
			    createSoapBodyElement(envelope,sbe,input,res,cxt);
			}
			else {
			    wsdltpl.setElem(1,elename);
			    wsdltpl.setElem(0,input.getOidElem(0));
			    wsdlscan = cxt.connection().callFunction("Record.Charstring.get_wsdltype->Charstring",wsdltpl);
			    
			    QName qn =new QName("xsi:type");
			    if ((findbasictype((wsdlscan.getRow()).getStringElem(0))).equalsIgnoreCase(""))
				sbe.addAttribute(qn,"tns"+ ":" +(wsdlscan.getRow()).getStringElem(0));
			    else
				sbe.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":" +(wsdlscan.getRow()).getStringElem(0));
	
			    
			    if (type.equalsIgnoreCase("charstring")) {
				se.addTextNode(res.getStringElem(0));
			    }
			    else
				if (type.equalsIgnoreCase("integer")) {
				    Integer ie=res.getIntElem(0);
				    se.addTextNode(ie.toString());
				}
				else
				    if (type.equalsIgnoreCase("real")) {
					Double db=res.getDoubleElem(0);
					se.addTextNode(db.toString());
				    }	
						
			}
					
			if (!s.eos()) {
			    s.nextRow();
			}
		    }
		}
	    }
	}
	catch(Throwable ex) {
	    System.out.println(ex);
	}
    }
   
   
    void createSoapBodyElement(SOAPEnvelope envelope,SOAPBodyElement sb,Tuple input,Tuple tpl, CallContext cxt)throws AmosException {
	Tuple res = new Tuple(1);
	Tuple wsdltpl = new Tuple(2);
	Scan s,wsdlscan;

	String type;

	try {
	    res.setElem(0,tpl.getOidElem(0));
	
	    s = cxt.connection().callFunction("Record.all_value->Object",res);
	    while (!s.eos()) {
		res=s.getRow();
		
		QName name= new QName(res.getStringElem(0));
		SOAPElement childshElement=sb.addChildElement(name);
		
		String elename=res.getStringElem(0);		
		s.nextRow();
		res=s.getRow();
		type=(res.getOidElem(0)).getTypename();
		if (type.equalsIgnoreCase("Record")) {
			
		    Tuple inputtpl= new Tuple(1);
		    inputtpl.setElem(0,input.getOidElem(8));
                               
		    inputeleindex=inputeleindex+2;
		    createSoapElement(envelope,childshElement,inputtpl,res,cxt);
		}
		else {	
		    	
		    wsdltpl.setElem(0,input.getOidElem(8));
		    wsdltpl.setElem(1,elename);
		    wsdlscan = cxt.connection().callFunction("Record.Charstring.get_wsdltype->Charstring",wsdltpl);
		    
		    QName qn =new QName("xsi:type");
		    if ((findbasictype((wsdlscan.getRow()).getStringElem(0))).equalsIgnoreCase(""))
			childshElement.addAttribute(qn,"tns"+ ":" +(wsdlscan.getRow()).getStringElem(0));
		    else
			childshElement.addAttribute(qn,XSD_NAMESPACE_PREFIX + ":"+(wsdlscan.getRow()).getStringElem(0));
			
		    if (type.equalsIgnoreCase("charstring"))
			childshElement.addTextNode(res.getStringElem(0));
		    else
			if (type.equalsIgnoreCase("integer")) {
			    Integer ie=res.getIntElem(0);
			    childshElement.addTextNode(ie.toString());
			}
			else
			    if (type.equalsIgnoreCase("real")) {
				Double db=res.getDoubleElem(0);
				childshElement.addTextNode(db.toString());
			    }
		}
		if (!s.eos()) {
		    s.nextRow();
		}
		inputeleindex=inputeleindex+2;
	    }
	}
	catch(Throwable ex)
	    {
		System.out.println(ex);
	    }
       
       

    }
 
    String findbasictype(String checkstr) {
	String str="";
	for(int i=0;i<44;i++) {	
	    if (checkstr.equals(basictype[i])) {
		str=basictype[i];
		break;
	    }
		
	}
	return(str);
    }
    
    Tuple dummyRecord(CallContext cxt) throws AmosException {
	Tuple rtpl=new Tuple(2);
	Tuple typetpl=new Tuple(1);
	Scan s;
	try  {
		
	    rtpl.setElem(0,"dummy");
	    rtpl.setElem(1,0);
	
	    s=cxt.connection().callFunction("Object.Object.concat_obj->vector",rtpl);
	    typetpl.setElem(0,(s.getRow()).getOidElem(0));
	    s = cxt.connection().callFunction("vector.make_record->Record",typetpl);
	    typetpl.setElem(0,(s.getRow()).getOidElem(0));
	}
	catch(Throwable ex){
	    System.out.println(ex);
	}
	return typetpl;
    }

   
    SOAPMessage getMessage() {
	return resultmsg;
    }
    void setMessage(SOAPMessage msg) {
	resultmsg=msg;
    }
    boolean getReceived() {

	return received;
    }
    void setReceived(boolean rec) {
	received=rec;
    }

}


