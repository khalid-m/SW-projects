package server;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Scanner;
import java.util.Vector;


import javax.xml.soap.MessageFactory;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;

import javax.xml.soap.SOAPHeader;
//import javax.xml.soap.SOAPHeaderElement;
import javax.xml.soap.SOAPMessage;

import org.w3c.dom.DOMException;

import callin.AmosException;
import callin.Connection;
import callin.Oid;

public class AmosServlet extends SAAJServlet implements constants{
	
    private ByteArrayOutputStream os = new ByteArrayOutputStream();
    private AmosII amos ;
	
    @Override
    protected SOAPMessage onMessage(SOAPMessage message) throws SOAPException, IOException, AmosException {
	if(DEBUG){
	   // Convert the message to string representation
	   // and log it.
	    Date date = new Date();
	    SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");		    
	    log("\n\n");
	    log("New Transition begin :"+sdf.format(date));
	    message.writeTo(os);		
	    log("Received the SOAP message:\n" + os.toString());           
	    os.reset();
	}

    	SOAPMessage reply = null;
    	SOAPBody reqBody = message.getSOAPPart().getEnvelope().getBody();
    	
	if(messageFactory == null){
	    messageFactory = MessageFactory.newInstance();	
	}
		
	reply = messageFactory.createMessage();
	SOAPEnvelope envelope = reply.getSOAPPart().getEnvelope();
	
	/** Handling the header of  reply SOAP message */
	SOAPHeader header = envelope.getHeader();
	header.detachNode();
		
	envelope.addNamespaceDeclaration(SOAPENV_PREFIX, SOAPENV_URI);
	envelope.addNamespaceDeclaration(XSD_PREFIX, XSD_URI);
	envelope.addNamespaceDeclaration(XSI_PREFIX, XSI_URI);
		
	SOAPBody body = envelope.getBody();
	body.addNamespaceDeclaration(TNS_PREFIX, TNS_URI);
    	
	/*This is document style and we set the signature of function is the immediate child*/
    	Iterator iterator = (Iterator) reqBody.getChildElements();
    	SOAPElement reqElement;
    	if(iterator.hasNext())
    	    reqElement = (SOAPElement) iterator.next();
    	else
    	    throw new SOAPException("This is an empty message.");
    	
    	String signature = reqElement.getLocalName();
    	if (signature.equals("sayHello")){
    	    handleSayHello(reqElement, body);
    	}
    	else{
             if ((signature.equalsIgnoreCase("tableinfo"))||(signature.equalsIgnoreCase("query"))||(signature.equalsIgnoreCase("authentication"))||(signature.equalsIgnoreCase("importwsdl"))){
		Iterator iterator1 = (Iterator) reqElement.getChildElements();
		if (iterator1.hasNext()){
		    SOAPElement bodyElement=(SOAPElement) iterator1.next();
		    DBname="P"+((bodyElement.getChildNodes()).item(0)).getTextContent();
                    System.out.println("DBName >> "+DBname);
		}
	    }
            System.out.println("DBName2 >> "+DBname);
    	    amos = new AmosII();    			
    	    amos.buildConnection(DBname);
    	    handleAmos(reqElement, body, signature);
    	    amos.close();
    	}
    	
    	if(DEBUG){
    	    reply.writeTo(os);    		
            log("Sending SOAP message:\n" + os.toString());
            Date date = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
            log("Whole transition finish at "+ sdf.format(date)+"\n");
            os.reset();
    	}
		
        // Return the received message to the caller.
        return reply;
	}

    public void handleSayHello(SOAPElement reqElement, SOAPBody body) throws SOAPException{
	Iterator I = reqElement.getChildElements();
	SOAPElement e = (SOAPElement) I.next();
	String name = e.getValue();	
	SOAPElement bodyElement = body.addChildElement("sayHello");
	bodyElement.addChildElement("sayHelloReturn").addTextNode("Hello " + name);
    }
    
    /**
     * Mapping a string to AmosII's type
     * @param  type name
     * @param  variable value
     * @return an Object in java
     * @throws AmosException 
     */   
    public Object decode2Amos(String type, String value) throws AmosException{
    
    	/** if this argument is Oid, search the DB in order to get the Object name. */
    	int si,ei,num;
    	si=value.indexOf("[OID ");
    	ei=value.indexOf("]");
    	if ((si == 0) && (ei== value.length()-1) ){ 	   
    	    String s1= value.substring(si+5,ei);
    	    num= Integer.parseInt(s1);
    	    Connection theConnection;
    	    theConnection = AmosII.getConnection();
					
    	    Oid oid = theConnection.getObjectNumbered(num);
    	    return oid;
    	}
   	
    	if(type.equalsIgnoreCase(XSD_PREFIX+":int")){
    	    return Integer.parseInt(value);    	    
    	}
    	if(type.equalsIgnoreCase(XSD_PREFIX+":float")){
    	    return Float.parseFloat(value);
    	}
    	if(type.equalsIgnoreCase(XSD_PREFIX+":double")){
    	    return Double.parseDouble(value);
    	}
    	if(type.equalsIgnoreCase(XSD_PREFIX+":string")){
    	    return value;
    	}
    	if(type.equalsIgnoreCase(XSD_PREFIX+":boolean")){
    	    return Boolean.parseBoolean(value);
    	}
    	
    	throw new AmosException("Can not parse the type: "+type+". It is value: "+value);
    }
    
    /**
     * Translate a collection type to an ArrayList.
     * @param The parent element of this vector.
     * @return  ArrayList
     * @throws AmosException 
     */
    public ArrayList parseVectorType(SOAPElement parent) throws AmosException{

    	ArrayList arrayList = new ArrayList();
    	Iterator iterator = parent.getChildElements();
    	for(int i=0;iterator.hasNext();i++){
    	    SOAPElement e = (SOAPElement)iterator.next();
    	    String value = e.getValue();
    	    String type = e.getAttribute("xsi:type");
    	    if(value!=null&&type!=null){    			
        	//if element is a comment, value is null.
        	    Object amosType;        	    
        	    amosType = decode2Amos(type, value);
               	    arrayList.add(amosType);
    	    }
    	    else{
    		log("Error: nested vector without type info. Treat them as String");
    		/*throw new AmosException("nested vector");*/
    		ArrayList childArray = parseVectorType(e);
    		if(!childArray.isEmpty())
    		    arrayList.add(childArray);
    	    }
    	}    	
    	return arrayList;
    }
    
    public void handleAmos(SOAPElement reqElement, SOAPBody body, String funName) throws AmosException, SOAPException{
	
    	ArrayList argsType = new ArrayList();
    	ArrayList argsValue = new ArrayList();
    	        
        /* int s = signature.lastIndexOf(_FS);
        String funName = signature.substring(0,s);
        int index = Integer.parseInt(signature.substring(s+_FS.length()));
        */
        
//        amos.getFunInfo(funName, index);
//        String args = amos.getArgsType();
        /*String funName= signature.substring(s+_FS.length());
        String args=signature.substring(0, s);
         */
//        Scanner scanner = new Scanner(args).useDelimiter(",");
    	log("funName:"+funName);    
    	Iterator iterator;
    	iterator = reqElement.getChildElements();
    	
    	/** parse the request message */
    	while(iterator.hasNext()){
    	    SOAPElement element = (SOAPElement) iterator.next();
    	    String xmlType = null;
    	    String value = null;
    	    Object amosValue =null;
    	    String amosType = null;
    	    value = element.getValue();
    	    xmlType = element.getAttribute(XSI_PREFIX+":type");
    	    if(value==null&&xmlType==null){  			
   		amosValue = parseVectorType(element);
   		amosType = "Vector";
    	    }
    	    else{ 		    		
    		if(value!=null){
    		    amosValue = decode2Amos(xmlType, value);
    		    if(amosValue instanceof callin.Oid){
    			callin.Oid oid= (callin.Oid) amosValue; 
    			amosType = oid.getTypename().toUpperCase();
    		    }
    		    else{
    			String type = amosValue.getClass().getName();
    			if(type.equalsIgnoreCase("java.lang.Integer"))
    			    amosType = "INTEGER";
    			else if(type.equalsIgnoreCase("java.lang.Double"))
    			    amosType = "REAL";
    			else if(type.equalsIgnoreCase("java.lang.String"))
    			    amosType = "CHARSTRING";
    			else if(type.equalsIgnoreCase("java.lang.Boolean"))
    			    amosType = "BOOLEAN";
    			else
    			    throw new AmosException("BAD TYPE");
    		    }
    		}  		    
    	    }
    	    if(amosValue!=null){
        	argsType.add(amosType);
            	argsValue.add(amosValue);
    	    }
    	}
    	
    	/** invoke AmosII function */    	
    	amos.execute(funName, argsType, argsValue);
    	Vector result = amos.getResult();
    	ArrayList resultTypes = amos.getResultType();
    	ArrayList<String> resultNames = amos.getResultName();
//    	log("Result: "+result.toString());
//    	log("ResultType: "+resultTypes.toString());
//    	log("ResultName: "+resultNames.toString());

    	/** construct the content of the response message body */
    	SOAPElement replyElement = body.addChildElement(funName+"Return");   	
    	replyElement.addNamespaceDeclaration("ns",APACHESOAP_URI);
    	SOAPElement results = replyElement.addChildElement("results");
    	
    	Enumeration enumeration = result.elements();
    	//if has null, return an empty
    /*if(!enumeration.hasMoreElements()){
    	    SOAPElement resultsElem = replyElement.addChildElement("row");
//    	    for(int i=0; i<resultNames.size(); i++){
//    		SOAPElement one = resultsElem.addChildElement((String)resultNames.get(i));    			
    	    }    		
    	}*/
    	 
    	while(enumeration.hasMoreElements()){
    	    SOAPElement rowElem = results.addChildElement("row");
    	    Vector row = (Vector) enumeration.nextElement();
    	   
    	    for(int i = 0; i< resultNames.size(); i++){
    		Object o = row.elementAt(i);
//    		String type = (String) resultTypes.get(i);
    		SOAPElement one = rowElem.addChildElement((String)resultNames.get(i));
    		if(o instanceof Vector){
    		    genVectorResult(one, (Vector) o);
    		}
    		else{
    		    one.addTextNode(o.toString());
    		    one.setAttribute(XSI_PREFIX+":type", decode2Xml(o));
    		}    				
    	    }
//    		vectorElement.addChildElement("element").addTextNode(row.toString());
    	}   	
    }
    
    public void genVectorResult(SOAPElement result, Vector v) throws SOAPException, DOMException, AmosException{
    	Enumeration e = v.elements();   
    	while(e.hasMoreElements()){
    	    Object o = e.nextElement();
    	    SOAPElement theElem= result.addChildElement("member");
    	    if(o instanceof Vector){		
		genVectorResult(theElem, (Vector)o);
    	    }
    	    else{
    		theElem.addTextNode(o.toString());
	        theElem.setAttribute(XSI_PREFIX+":type", decode2Xml(o));
    	    }
    	}
    }
    
    public String decode2Xml(Object o) throws AmosException{
	String tmp = o.getClass().getName();

	if(tmp.equalsIgnoreCase("java.lang.Integer"))
	    return XSD_PREFIX+":int";
	if(tmp.equalsIgnoreCase("java.util.Float"))
	    return XSD_PREFIX+":float";
	if(tmp.equalsIgnoreCase("java.lang.String"))
	    return XSD_PREFIX+":string";
	if(tmp.equalsIgnoreCase("callin.Oid"))
	    return XSD_PREFIX+":string";
	throw new AmosException("The type,"+tmp+" , can not map to XML type");
    }
}
