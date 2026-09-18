import callin.*;
import callout.*;

import java.util.Map;
import java.util.List;
import java.util.Iterator;
import java.util.Collections;
import java.util.ArrayList;
import java.util.Enumeration;

import java.net.URL;

import javax.wsdl.Definition;
import javax.wsdl.Service;
import javax.wsdl.Binding;
import javax.wsdl.BindingOperation;
import javax.wsdl.Message;
import javax.wsdl.Part;
import javax.wsdl.Port;
import javax.wsdl.BindingInput;
import javax.wsdl.BindingOutput;
import javax.xml.namespace.QName;
import javax.xml.soap.SOAPElement;
import javax.wsdl.Operation;
import javax.wsdl.Input;
import javax.wsdl.Output;
import javax.wsdl.factory.WSDLFactory;
import javax.wsdl.xml.WSDLReader;
import javax.wsdl.extensions.ExtensibilityElement;
import javax.wsdl.extensions.UnknownExtensibilityElement;
import javax.wsdl.extensions.soap.SOAPAddress;
import javax.wsdl.extensions.soap.SOAPOperation;
import javax.wsdl.extensions.soap.SOAPBody;
import javax.wsdl.extensions.soap.SOAPBinding;
import javax.wsdl.extensions.soap.SOAPHeader;
import javax.wsdl.extensions.schema.*;
import javax.wsdl.*; 


import org.jdom.Element;
import org.jdom.Attribute;
import org.jdom.input.DOMBuilder;

import org.exolab.castor.xml.schema.Schema;
import org.exolab.castor.xml.schema.XMLType;
import org.exolab.castor.xml.schema.ElementDecl;
import org.exolab.castor.xml.schema.ComplexType;
import org.exolab.castor.xml.schema.Group;
import org.exolab.castor.xml.schema.Particle;
import org.exolab.castor.xml.schema.Structure;
import org.exolab.castor.xml.schema.SimpleTypesFactory;
import org.exolab.castor.xml.schema.SimpleType;
import org.exolab.castor.xml.schema.AttributeDecl;
import org.exolab.castor.*;
import java.util.*;
import java.io.*;

/**
 * A class that defines methods for building components to invoke a web service
 * by analyzing a WSDL document.
 */

public class populateSchema
{
    /** JWSDL Factory instance */
    static WSDLFactory wsdlFactory = null;

    /** Cator simple types factory */
    SimpleTypesFactory simpleTypesFactory = null;

    /** WSDL type schema */
    private Schema wsdlTypes = null;
   
    private static String wsdlString="";

    /** Targetnamespace */
    private String  tns = null;

    /** The default SOAP encoding to use. */
    public final String DEFAULT_SOAP_ENCODING_STYLE = "http://schemas.xmlsoap.org/soap/encoding/";

   
    public Definition wsdlDef=null;
    public String psch =""; 
    public int schemaindex=0,opindex=0,msgindex=0,parindex=0,parposition=0,elementindex=0;
    public String[] elearr=new String[3];
    Vector<String[]> elevec=new Vector<String[]>();
    
    public Hashtable<String,String[]> eleht;
    public Hashtable<String,Vector<String[]>> parht;
    public String[][] basictype = new String[46][2];
    String schemaname;
    String function,inarg,outarg,select,from,where,baseType;
    String tablestr;
    boolean any=false;
    static Connection theConnection;
    static  org.jdom.Element wsdlElement;  
    /**
     * Constructor
     */
    public populateSchema()
    {
	eleht=new Hashtable<String,String[]>();
	parht=new Hashtable<String,Vector<String[]>>();
	basictype[0][0]="anyURI";               basictype[0][1]= "CHARSTRING" ;
	basictype[1][0]= "base64Binary";        basictype[1][1]="CHARSTRING" ; 
	basictype[2][0]= "boolean";             basictype[2][1]="CHARSTRING" ;
	basictype[3][0]= "byte";                basictype[3][1]="INTEGER" ; 
	basictype[4][0]= "date";                basictype[4][1]="DATE" ;
	basictype[5][0]= "dateTime";            basictype[5][1]="CHARSTRING" ; 
	basictype[6][0]= "decimal";             basictype[6][1]="REAL" ;
	basictype[7][0]= "double";              basictype[7][1]="REAL" ; 
	basictype[8][0]= "duration";            basictype[8][1]="CHARSTRING" ;
	basictype[9][0]= "ENTITIES";            basictype[9][1]="CHARSTRING" ; 
	basictype[10][0]= "ENTITY";             basictype[10][1]="CHARSTRING" ;
	basictype[11][0]= "float";              basictype[11][1]="REAL" ; 
	basictype[12][0]= "gDay";               basictype[12][1]="CHARSTRING" ;
	basictype[13][0]= "gMonth";             basictype[13][1]="CHARSTRING" ; 
	basictype[14][0]= "gMonthDay";          basictype[14][1]="CHARSTRING" ;
	basictype[15][0]= "gYear";              basictype[15][1]="CHARSTRING" ; 
	basictype[16][0]= "gYearMonth";         basictype[16][1]="CHARSTRING" ;
	basictype[17][0]= "hexBinary";          basictype[17][1]="CHARSTRING" ; 
	basictype[18][0]= "ID";                 basictype[18][1]="XS_ID" ;
	basictype[19][0]= "IDREF";              basictype[19][1]="XML" ; 
	basictype[20][0]= "IDREFS";             basictype[20][1]="XML" ;
	basictype[21][0]= "int";                basictype[21][1]="INTEGER" ; 
	basictype[22][0]= "integer";            basictype[22][1]="REAL" ;
	basictype[23][0]= "language";           basictype[23][1]="CHARSTRING" ; 
	basictype[24][0]= "long";               basictype[24][1]="INTEGER" ;
	basictype[25][0]= "Name";               basictype[25][1]="CHARSTRING" ; 
	basictype[26][0]= "NCName";             basictype[26][1]="CHARSTRING" ;
	basictype[27][0]= "negativeInteger";    basictype[27][1]="REAL" ; 
	basictype[28][0]= "NMTOKEN";            basictype[28][1]="CHARSTRING" ;
	basictype[29][0]= "NMTOKENS";           basictype[29][1]="CHARSTRING" ; 
	basictype[30][0]= "nonNegativeInteger"; basictype[30][1]="REAL" ;
	basictype[31][0]= "nonPositiveInteger"; basictype[31][1]="REAL" ;
	basictype[32][0]= "normalizedString";   basictype[32][1]="CHARSTRING" ;
	basictype[33][0]= "NOTATION";           basictype[33][1]="CHARSTRING" ; 
	basictype[34][0]= "positiveInteger";    basictype[34][1]="REAL" ;
	basictype[35][0]= "QName";              basictype[35][1]="CHARSTRING" ; 
	basictype[36][0]= "short";              basictype[36][1]="INTEGER" ;
	basictype[37][0]= "string";             basictype[37][1]="CHARSTRING" ; 
	basictype[38][0]= "time";               basictype[38][1]="TIME" ;
	basictype[39][0]= "token";              basictype[39][1]="CHARSTRING" ; 
	basictype[40][0]= "unsignedByte";       basictype[40][1]="INTEGER" ;
	basictype[41][0]= "unsignedInt";        basictype[41][1]="INTEGER" ; 
	basictype[42][0]= "unsignedLong";       basictype[42][1]="INTEGER" ;
	basictype[43][0]= "unsignedShort";      basictype[43][1]="INTEGER" ; 
       	basictype[44][0]= "anyType";            basictype[44][1]="OBJECT" ;
	//basictype[45][0]= "VectorofanyType";    basictype[45][1]="Vector of OBJECT" ;
        tablestr="";
      
    }

   
    /*
    * @return A List of SoapComponent objects populated for each service defined
    *         in a WSDL document. A null is returned if the document can't be read.
    */
    public void  buildComponents(String wsdlURI,CallContext cxt) throws Exception
   { 
       Definition def= null;
       String oldWSDLURL=wsdlURI;
      // Create the WSDL Reader object
       
        try { 
	     WSDLFactory factory = WSDLFactory.newInstance();
	     simpleTypesFactory = new SimpleTypesFactory();

	     WSDLReader reader = factory.newWSDLReader(); 
	     
	     // Read the WSDL and get the top-level Definition object
             if (readWSDL(wsdlURI))
                     wsdlURI="wsdl/newWSDL.wsdl";
	     def = reader.readWSDL(wsdlURI);
	     wsdlDef=def;

           theConnection=cxt.connection();
	  } 
	catch (WSDLException e) 
	    { 
		e.printStackTrace(); 
	    } 
    
         
	psch+=" /****************************************************/\n";
	psch+="/* populate Wsdlschema */\n";
	psch+="/****************************************************/\n";

	 
         // Create a castor schema from the types element defined in WSDL
         // This method will return null if there are types defined in the WSDL

          wsdlTypes = createSchemaFromTypes(def);
	 
         // Get the services defined in the document
         Map services = def.getServices();
	

         if(services != null)
         {
            // Create a component for each service defined
            Iterator svcIter = services.values().iterator();
	   
            for(int i = 0; svcIter.hasNext(); i++){  
		opindex=0;
                elementindex=0;
             // Populate the new component from the WSDL Definition read
		    populateComponent((Service)svcIter.next(),oldWSDLURL);
                    
		    for(int j=0;j<opindex;j++)
			{
		        psch+="add port(:"+schemaname+(schemaindex-1)+") = "; 
			psch+=":"+schemaname+"op"+j+"; \n";
                        }
          	}
	   
	    // eleht.clear();
	    parht.clear();
	    writeamosql(psch);
	 }
     }

   /**
    * Creates a castor schema based on the types defined by a WSDL document
    *
    * @param   wsdlDefinition    The WSDL4J instance of a WSDL definition.
    *
    * @return  A castor schema is returned if the WSDL definition contains
    *          a types element. null is returned otherwise.
    */
   protected Schema createSchemaFromTypes(Definition wsdlDefinition)throws Exception
   {
       
     
       /* Get the  targetNamespace*/
       tns=wsdlDefinition.getTargetNamespace();
      
       // Get the schema element from the WSDL definition
       org.w3c.dom.Element schemaElement = null;
        
      if(wsdlDefinition.getTypes() != null)
      {
         
	  ExtensibilityElement schemaExtElem = findExtensibilityElement(wsdlDefinition.getTypes().getExtensibilityElements(), "schema");
		  
	 if(schemaExtElem != null && schemaExtElem instanceof javax.wsdl.extensions.schema.Schema)
         {
	    schemaElement = ((javax.wsdl.extensions.schema.Schema)schemaExtElem).getElement();
	   
	 }  
	   
      }

    if(schemaElement == null)
      {
        	
	  // No schema to read
	 System.err.println("Unable to find schema extensibility element in WSDL");
         return null;
      } 

      // Convert from DOM to JDOM
      DOMBuilder domBuilder = new DOMBuilder();
     
      org.jdom.Element jdomSchemaElement = domBuilder.build(schemaElement);

      wsdlElement= jdomSchemaElement;
     

      if(jdomSchemaElement == null)
      {
         System.err.println("Unable to read schema defined in WSDL");
         return null;
      }

 
      // Add namespaces from the WSDL
      Map namespaces = wsdlDefinition.getNamespaces();

      if(namespaces != null && !namespaces.isEmpty())
      {
         Iterator nsIter = namespaces.keySet().iterator();

         while(nsIter.hasNext())
         {
            String nsPrefix = (String)nsIter.next();
            String nsURI = (String)namespaces.get(nsPrefix);
	    

            if(nsPrefix != null && nsPrefix.length() > 0)
            {  
	       org.jdom.Namespace nsDecl = org.jdom.Namespace.getNamespace(nsPrefix, nsURI);
               jdomSchemaElement.addNamespaceDeclaration(nsDecl);
	       
            }
         }
      }

      // Make sure that the types element is not processed
      jdomSchemaElement.detach();

      // Convert it into a Castor schema instance
      Schema schema = null;

      try
      {
	  wsdlString=XMLSupport.outputString(jdomSchemaElement);
         schema = XMLSupport.convertElementToSchema(jdomSchemaElement);
      }

      catch(Exception e)
      {
	 
         System.err.println( e.getMessage());
      }

      // Return it
      return schema;
   }
 
   /**
    * Populates a ServiceInfo instance from the specified Service definiition
    *
    * @param   component      The component to populate
    * @param   service        The Service to populate from
    *
    * @return The populated component is returned representing the Service parameter
    */
    private void populateComponent(Service service,String wsdlURI)throws AmosException
    {
       boolean found=false;
      // Get the qualified service name information
      QName qName = service.getQName();

      // Get the service's namespace URI
      String namespaceuri = qName.getNamespaceURI();

      // Use the local part of the qualified name for the component's name
      String st=wsdlURI.replace(":","");
      st=st.replace(".","");
      st=st.replace("-","");
      schemaname = st.replace("/","")+qName.getLocalPart();
      psch+="create Service instances :"+schemaname+schemaindex+"; \n"+"set name(:"+schemaname+schemaindex+")='"+qName.getLocalPart()+"'; \n";
      psch+="set namespaceuri(:"+schemaname+schemaindex+")='"+namespaceuri+"'; \n";
       psch+="set wsdluri(:"+schemaname+schemaindex+")='"+wsdlURI+"'; \n";
      schemaindex+=1;

      // Set the name
          //component.setName(name);

      // Get the defined ports for this service
      Map ports = service.getPorts();

      // Use the Ports to create OperationInfos for all request/response messages defined
      Iterator portIter = ports.values().iterator();
     
      psch+="/****************************************************/\n /* populate Operaton, Elements */\n/****************************************************/\n";
      while(portIter.hasNext()&& !found)
      {
         // Get the next defined port
         Port port = (Port)portIter.next();

         // Get the Port's Binding
         Binding binding = port.getBinding();
	 //System.out.println("port");
         // Now we will create operations from the Binding information
	 buildOperations(binding,port);
       
      }
     
   }

   /**
    * Creates Info objects for each Binding Operation defined in a Port Binding
    *
    * @param binding The Binding that defines Binding Operations used to build info objects from
    *
    * @return A List of built and populated OperationInfos is returned for each Binding Operation
    */
    private void  buildOperations(Binding binding, Port port)
    {
            
	// Get the list of Binding Operations from the passed binding
	List operations = binding.getBindingOperations();
     
      
	if(operations != null && !operations.isEmpty())
	    {
		// Determine encoding
		ExtensibilityElement soapBindingElem = findExtensibilityElement(binding.getExtensibilityElements(), "binding");
		String style = "document"; // default
		
		// For each binding operation, create a new OperationInfo
		Iterator opIter = operations.iterator();
         
		if(soapBindingElem != null && soapBindingElem instanceof SOAPBinding)
		    {
			SOAPBinding soapBinding = (SOAPBinding)soapBindingElem;
			style = soapBinding.getStyle();
			// }
		
			while(opIter.hasNext())
			    {
				BindingOperation oper = (BindingOperation)opIter.next();
				Operation oper1 = oper.getOperation();
				//System.out.println(" Operation > "+ oper1.getName());
				function="create function "+oper1.getName()+"_"+schemaname+opindex+"(";
				psch+="create Operation instances :"+schemaname+"op"+opindex+"; \n";
				psch+="set name(:"+schemaname+"op"+opindex+")='"+oper1.getName()+"'; \n";
				psch+="set style(:"+schemaname+"op"+opindex+")='"+style+"'; \n";
				try
                                 {
                                   Tuple stpl= new Tuple(1);
			           Scan s;
                                   stpl.setElem(0, oper1.getName());
                                   s = theConnection.callFunction("charstring.tablename->charstring",stpl);
                                   
                                   String tempstr=(s.getRow()).getStringElem(0);
                                 
                                   if (tablestr.equals(""))
                                       tablestr=tempstr;
                                   else
				       {
				
                                        tempstr=findElements.checkDuptablename(tablestr,tempstr); 
                                        tablestr=tablestr+" , "+tempstr;
				       }
 
                                 
                                   psch+="set tablename(:"+schemaname+"op"+opindex+")='"+tempstr+"'; \n";
				  }
				catch(AmosException ex){
                                      System.out.println(ex.getMessage());
		                      ex.printStackTrace();
                                       }
				//psch+="set targetobjecturi(:"+schemaname+"op"+opindex+")='"+tns+"';\n";
				   
				// Find the SOAP target URL
				ExtensibilityElement addrElem = findExtensibilityElement(port.getExtensibilityElements(), "address");
			
				if(addrElem != null && addrElem instanceof SOAPAddress)
				    {
					// Set the SOAP target URL
					SOAPAddress soapAddr = (SOAPAddress)addrElem;
					psch+="set targeturl(:"+schemaname+"op"+opindex+")='"+soapAddr.getLocationURI()+"'; \n";
				    }
	     
				// We currently only support soap:operation bindings
				// filter out http:operations for now until we can dispatch them properly
				ExtensibilityElement operElem = findExtensibilityElement(oper.getExtensibilityElements(), "operation");
			
				if(operElem != null && operElem instanceof SOAPOperation )
				    {
					
					SOAPOperation soapOperation = (SOAPOperation)operElem;
					psch+="set soapactionuri(:"+schemaname+"op"+opindex+")='"+soapOperation.getSoapActionURI()+"'; \n";
					
					// Get the Binding Input
					BindingInput bindingInput = oper.getBindingInput();
					
					// Get the Binding Output
					BindingOutput bindingOutput = oper.getBindingOutput();
					
					// Get the SOAP Body 
					ExtensibilityElement bodyElem = findExtensibilityElement(bindingInput.getExtensibilityElements(), "body");
					
					String inmessage;
					
					if(bodyElem != null && bodyElem instanceof SOAPBody )
					    { 
						SOAPBody soapBody = (SOAPBody)bodyElem;
						
						// The SOAP Body contains the encoding styles
						List styles = soapBody.getEncodingStyles();
						String encodingStyle = null;
						
						if(styles != null)
						    {
							// Use the first in the list
							encodingStyle = styles.get(0).toString();
						    }
						
						if(encodingStyle == null)
						    {
							// An ecoding style was not found, give it a default
							encodingStyle = DEFAULT_SOAP_ENCODING_STYLE;
						    }
						psch+="set encodingstyle(:"+schemaname+"op"+opindex+")='"+encodingStyle+"'; \n";
						//psch+="set namespace(:"+schemaname+"op"+opindex+")='"+soapBody.getNamespaceURI()+"';\n";
					    }
						// Get the SOAP Header
					ExtensibilityElement headerElem = findExtensibilityElement(bindingInput.getExtensibilityElements(), "header");
					
										
					if(headerElem != null && headerElem instanceof SOAPHeader )
					    { 
						SOAPHeader soapHeader = (SOAPHeader)headerElem;
						
						// The SOAP Header contains the messages
						Message shMsg = findSoapHeader(wsdlDef,soapHeader.getMessage().getLocalPart());
						buildMessageText(shMsg,"authentication");
					        psch+="set authenticationstr(:"+schemaname+"op"+opindex+")='required'; \n";
						//psch+="set encodingstyle(:"+schemaname+"op"+opindex+")='"+encodingStyle+"';\n";
						//psch+="set namespace(:"+schemaname+"op"+opindex+")='"+soapBody.getNamespaceURI()+"';\n";
					    }
					else
					    {
					      psch+="set authenticationstr(:"+schemaname+"op"+opindex+")='none'; \n";
					      psch+="add authentication(:"+schemaname+"op"+opindex+")={}; \n";
					    }
					//	System.out.println("opeartions "+oper1.getName());	       
					// Populate it from the Binding Operation
					Input inDef = oper1.getInput();
					
					if(inDef != null)
					    {
						// Build input parameters
						Message inMsg = inDef.getMessage();
						
						if(inMsg != null)
						    { // Set the body of the operation's input message
							buildMessageText(inMsg,"input");
							inarg+=")->(";
						    }
					    }
					
					// Get the Operation's Output definition
					Output outDef = oper1.getOutput();
					
					if(outDef != null)
					    {
						// Build output parameters
						Message outMsg = outDef.getMessage();
						
						if(outMsg != null)
						    { // Set the body of the operation's output message
							buildMessageText(outMsg,"output");
							outarg+=") as ";
						    }
						
					    }
					
				    }
				opindex+=1;
				
			    }//while
			
		    }
		
	    }
	
	// return operationInfos;
    }

    


   /**
    * Builds and adds parameters to the supplied info object
    * given a SOAP Message definition (from WSDL)
    *
    * @param   operationInfo   The component to build message text for
    * @param   msg    The SOAP Message definition that has parts to defined parameters for
    */
    private void buildMessageText(Message msg, String msgtype) 
   {
       //System.out.println("message name > "+msg.getQName().getLocalPart());
       // Get the message parts
       List msgParts = msg.getOrderedParts(null);

       // Process each part
       Iterator iter = msgParts.iterator();
       int tempelementindex=elementindex;
       int startindex=elementindex;
       Group group=null;
       String partName=null;
       Iterator tempiter= msgParts.iterator();
       boolean haschild=true;
       String tpsch,elename,wsdltype, min,max,eleinstance;
       if (!(iter.hasNext()))
	   haschild=false;
          
       while(iter.hasNext())
	   {  	 
	        tpsch="";
		elename="";
		wsdltype="";
		min="";
		max="";
		eleinstance="";
	       // Get each part
	       Part  part = (Part)iter.next();
               
	       // Add content for each message part
	       partName = part.getName();
	        
	       
	      
	       if(partName != null)
		   { 
		       if (wsdlTypes!=null)
			   {
			      
			       // Determine if this message part's type is complex
			        XMLType xmlType = getXMLType(part);
			      
			       if(xmlType != null )
				   {
                                      				       
				       tpsch+="create Element instances :"+schemaname+"e"+tempelementindex+" ; \n";
				       if (part.getElementName()!=null)
					   {
					       tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+part.getElementName().getLocalPart()+"' ; \n";
					       elename="'"+part.getElementName().getLocalPart()+"'";
					   }
				       else					   
					   {
					       tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+partName+"' ; \n";
					       elename="'"+partName+"'";
					   }
					   
				          
								       
				       if (xmlType.getName()!=null)
					   {
					       
					       if (xmlType.isSimpleType()){
                                                   
						   tpsch+="set value(:"+schemaname+"e"+tempelementindex+")="+readEnuValue(wsdlElement,xmlType.getName())+"; \n";

						   tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+xmlType.getName()+"' ; \n";
						   wsdltype="'"+xmlType.getName()+"'";
						   SimpleType st= (SimpleType) xmlType;
						   if (!st.isBuiltInType()){
                                                      if ((xmlType.getBaseType()).getName()==null)
                                                       tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(baseType)+"';\n";				                                      else
						       tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype((xmlType.getBaseType()).getName())+"';\n";				
						   }	       
						   else
						       tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(xmlType.getName())+"';\n";
						   if (msgtype.equals("input"))
						       {
							   //inarg+=part.getElementName().getLocalPart()+" ");
						       }
					       }
					       else {
						   tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+xmlType.getName()+"' ; \n";
						   tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+""+"' ; \n";
						   wsdltype="'"+xmlType.getName()+"'";
					       }
					       
					   }
				       else
					   {
					       tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+""+"' ; \n";
					       tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+""+"' ; \n";
					       wsdltype="''";
					   }
				      	   
				       if (msgtype.equals("output"))
					   {
					      tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
					      tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'-1' "+"; \n"; 
                                              min="'1'";
					      max="'-1'";
					   }
				       else
					   {
					       tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
					       tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'1' "+"; \n"; 
					        min="'1'";
						max="'1'";
					   }
				       tempelementindex+=1;
				       eleinstance=findElements.pickupElements(psch,elename,wsdltype,min,max);
				      
				       if ( eleinstance.equals(""))
					   {
					       psch+=tpsch;
					       if  (xmlType.isComplexType())
						   {
						       buildComplexPart((ComplexType)xmlType,0,Integer.toString(tempelementindex-1)); 
					       
						       Enumeration particleEnum = ((ComplexType)xmlType).enumerate();
					       
						       while(particleEnum.hasMoreElements())
							   {  
							       Particle particle = (Particle)particleEnum.nextElement();  
							       if (particle instanceof Group)  
								   {  
								       group = (Group)particle;  
								       break;  
								   }  
							   }
						     
						       if (group!=null){
							   if(group.getParticleCount()>0){ 
							       /* tempelementindex+=group.getParticleCount(); */
							       psch+="add subelements(:"+schemaname+"e"+Integer.toString(tempelementindex-1)+")={"; 
							       for(int j=0;j<(group.getParticleCount()-1);j++)
								   psch+=":"+schemaname+"e"+Integer.toString(tempelementindex-1)+"_"+j+",";
							       psch+=":"+schemaname+"e"+Integer.toString(tempelementindex-1)+"_"+(group.getParticleCount()-1)+"}; \n";
							   }
                                                       }
						       else{/* for arryType elements*/
							   psch+="add subelements(:"+schemaname+"e"+Integer.toString(tempelementindex-1)+")={";
							   psch+=":"+schemaname+"e"+Integer.toString(tempelementindex-1)+"_"+0+"}; \n";
						       }    
                  
						   }
					   }
				       else
					   {
					       //System.out.println("eleinstance "+ eleinstance);
					       psch+="create Element instances :"+schemaname+"e"+(tempelementindex-1)+" ; \n";
					       psch+="set :"+schemaname+"e"+(tempelementindex-1)+ " = "+eleinstance+" ; \n";
					   }
				       	
					   
				       /*else
					   {
					       psch+="create Element instances :"+schemaname+"e"+tempelementindex+";\n";
					       if (part.getElementName()!=null)
						   psch+="set name(:"+schemaname+"e"+tempelementindex+")='"+part.getElementName().getLocalPart()+"';\n";
					       else 
						   psch+="set name(:"+schemaname+"e"+tempelementindex+")='"+partName+"';\n";
								       
					        if (xmlType.getName()!=null)
						    psch+="set mappedtype(:"+schemaname+"e"+tempelementindex+")='"+findbasictype(xmlType.getName())+"';\n";
						else
						    psch+="set mappedtype(:"+schemaname+"e"+tempelementindex+")='"+xmlType.getName()+"';\n";
					       			
					       tempelementindex+=1;
					       }*/
				 		 		
				   }
			        else
				    {
							
					tpsch+="create Element instances :"+schemaname+"e"+tempelementindex+" ;\n";
					if (part.getElementName()!=null)
					    {
						tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+part.getElementName().getLocalPart()+"' ;\n";
						elename="'"+part.getElementName().getLocalPart()+"'";
                                                tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+part.getElementName().getLocalPart()+"' ; \n";
					        tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(part.getElementName().getLocalPart())+"' ; \n";                                   wsdltype="'"+part.getElementName().getLocalPart()+"'";
					    }
					else
					    { 
						tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+partName+"' ; \n";
					     	elename="'"+partName+"'";
                                                if (part.getTypeName()!=null){
						    tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+part.getTypeName().getLocalPart()+"' ; \n";
						    tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(part.getTypeName().getLocalPart())+"'; \n";                        
						    wsdltype="'"+part.getTypeName().getLocalPart()+"'";
						}
					    }
					//System.out.println("part name "+partName);
				
				
					 if (msgtype.equals("output"))
					   {
					      tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
					      tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'-1' "+"; \n"; 
					      min="'1'";
                                              max="'-1'";
					   }
				       else
					   {
					       tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
					       tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'1' "+"; \n"; 
					       min="'1'";
					       max="'1'";
					   }
			    
					tempelementindex+=1; 
					eleinstance=findElements.pickupElements(psch,elename,wsdltype,min,max);
					if ( eleinstance.equals(""))
					    {
						psch+=tpsch;
					    }
					else
					    {
						//System.out.println("eleinstance "+ eleinstance);
						psch+="create Element instances :"+schemaname+"e"+(tempelementindex-1)+" ; \n";
						psch+="set :"+schemaname+"e"+(tempelementindex-1)+ " = "+eleinstance+"; \n";
					    }
				    }
			   }
		       else
			   {
			        
			       tpsch+="create Element instances :"+schemaname+"e"+tempelementindex+" ;\n";
			       if (part.getElementName()!=null)	   {
				       tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+part.getElementName().getLocalPart()+"' ; \n";
				       elename="'"+part.getElementName().getLocalPart()+"'";
                                       tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+part.getElementName().getLocalPart()+"' ; \n";
			               tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(part.getElementName().getLocalPart())+"' ; \n";
                                       wsdltype="'"+part.getElementName().getLocalPart()+"'"; 
				   }
			       else 
				   {
				       tpsch+="set name(:"+schemaname+"e"+tempelementindex+") = '"+partName+"' ; \n";
				       elename="'"+partName+"'";
				       if (part.getTypeName()!=null){
					   tpsch+="set wsdltype(:"+schemaname+"e"+tempelementindex+") = '"+part.getTypeName().getLocalPart()+"' ; \n";
					   tpsch+="set wsmedtype(:"+schemaname+"e"+tempelementindex+") = '"+findbasictype(part.getTypeName().getLocalPart())+"' ; \n";                                     
					   wsdltype="'"+part.getTypeName().getLocalPart()+"'";     
				       }
				   }
			
			      
			      
			       if (msgtype.equals("output"))
				   {
				       tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
				       tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'-1' "+"; \n"; 
				        min="'1'";
					max="'-1'";
				   }
			       else
				   {
				       tpsch+="set minoccurs(:"+schemaname+"e"+tempelementindex +") = "+"'1' "+"; \n"; 
				       tpsch+="set maxoccurs(:"+schemaname+"e"+tempelementindex+") = "+"'1' "+"; \n"; 
				        min="'1'";
					max="'1'";
				   }
			    	 
			       tempelementindex+=1;   
			       eleinstance=findElements.pickupElements(psch,elename,wsdltype,min,max);
			       if ( eleinstance.equals(""))
				   {
				       psch+=tpsch;
				   }
			       else
				   {
				       //System.out.println("eleinstance "+ eleinstance);
				       psch+="create Element instances :"+schemaname+"e"+(tempelementindex-1)+" ; \n";
				       psch+="set :"+schemaname+"e"+(tempelementindex-1)+ " = "+eleinstance+"; \n";
				   }
                                   
			   }
		       	     
		   }
	       	 
	   }
       if (haschild)
	   {
	       psch+="add "+ msgtype+"(:"+schemaname+"op"+opindex+")={";
	       for(int j=startindex;j<(tempelementindex-1);j++)
		   psch+=":"+schemaname+"e"+j+",";
	    psch+=":"+schemaname+"e"+Integer.toString(tempelementindex-1)+"}; \n";
	    /*psch+="add "+ msgtype+"(:"+schemaname+"op"+opindex+")=:"+schemaname+"e"+Integer.toString(tempelementindex-1)+";\n";*/
	    elementindex=tempelementindex;
	   }
       else
	    psch+="add "+ msgtype+"(:"+schemaname+"op"+opindex+")={}; \n";
             	  
   }
 
   /**
    * Populate a JDOM element using the complex XML type passed in
    *
    * @param   complexType  The complex XML type to build the element for
    * @param   partElem     The JDOM element to build content for
    */
   
    protected void  buildComplexPart(ComplexType complexType,int eindex,String prefixele){
	  
	// Find the group
	
	Group group = null;
	
	int particleIndex=0;
	String tpsch,elename,wsdltype, min,max,eleinstance;

	Enumeration particleEnum = complexType.enumerate();
	while(particleEnum.hasMoreElements())
	    {
		Particle particle = (Particle)particleEnum.nextElement();
		
		if (particle instanceof Group)
		    {
			group = (Group)particle;
			break;
		    }
		
	    }

        
	if (group != null) {
	
	    Enumeration groupEnum = group.enumerate();
	    while (groupEnum.hasMoreElements()){
			
		tpsch="";
		elename="";
		wsdltype="";
		min="";
		max="";
		eleinstance="";

		Structure item = (Structure)groupEnum.nextElement();
		  
		if (item.getStructureType() == Structure.ELEMENT){
		
		    ElementDecl elementDecl = (ElementDecl)item;
		    Element childElem = new Element(elementDecl.getName()); 
		   	
		    XMLType xmlType = elementDecl.getType();
		       			    
		    //xmlType=findType(wsdlElement,complexType.getName());
			

		    if ((xmlType != null) ){		
		
			tpsch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
			tpsch+="set name(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+elementDecl.getName()+"' ; \n";
					    
			elename="'"+elementDecl.getName()+"'";
			// System.out.println(" element "+ elementDecl.getName());

			if (xmlType.getName()!=null)
			    {
				tpsch+="set wsdltype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+xmlType.getName()+"' ; \n";
				/*tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+findbasictype(xmlType.getName())+"'; \n";*/
				wsdltype="'"+xmlType.getName()+"'";
				if(xmlType.isSimpleType())
				    {
					tpsch+="set value(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+")="+readEnuValue(wsdlElement,xmlType.getName())+"; \n";
					SimpleType st= (SimpleType) xmlType;
					if (!st.isBuiltInType()){
                                              
					    if ((xmlType.getBaseType()).getName()==null)						
						tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+findbasictype(baseType)+"' ; \n";
					    else                                             
						tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+findbasictype((xmlType.getBaseType()).getName())+"' ; \n";
					}
					else
					    tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+findbasictype(xmlType.getName())+"' ; \n"; 
				    }
				else
				    tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+findbasictype(xmlType.getName())+"'; \n";
			    }
			else
						
			    {
				tpsch+="set wsdltype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+""+"' ; \n";
				tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+""+"'; \n";
				wsdltype="''";
			    }

			tpsch+="set minoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+group.getParticle(particleIndex).getMinOccurs()+"' "+"; \n"; 
			tpsch+="set maxoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+group.getParticle(particleIndex).getMaxOccurs()+"' "+"; \n";				    
			min="'"+group.getParticle(particleIndex).getMinOccurs()+"'";
			max="'"+group.getParticle(particleIndex).getMaxOccurs()+"'";

			eleinstance=findElements.pickupElements(psch,elename,wsdltype,min,max);
			if ( eleinstance.equals(""))
			    { 
				psch+=tpsch;
				if(xmlType.isComplexType())
				    {
					   	
					buildComplexPart((ComplexType)xmlType,0,prefixele+"_"+Integer.toString(eindex));
					Enumeration particleEnum1 = ((ComplexType)xmlType).enumerate();
					Group group1 = null;
					while(particleEnum1.hasMoreElements())
					    {
						Particle particle1 = (Particle)particleEnum1.nextElement();
						if (particle1 instanceof Group)
						    {
							group1 = (Group)particle1;
							break;
						    }
					    }
					if (group1!=null && !any)
					    if(group1.getParticleCount()>0)
						{
						    psch+="add subelements(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+")={";
						    for(int j=0;j<(group1.getParticleCount()-1);j++)
							psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+j+",";
						    psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+(group1.getParticleCount()-1)+"}; \n";
                                                         
						}
					any=false;
				    }
			    }
			else
			    {
				//System.out.println("eleinstance "+ eleinstance);
                                       
				psch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
				psch+="set :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+ " = "+eleinstance+"; \n";
			    }
		     
						   
		    }
		    else{
			ComplexType cType=null;
			/* Type may defined in different target name space */
			if (xmlType == null) {	
                                         
				Enumeration groupEnum1 = wsdlTypes.getComplexTypes();
				while (groupEnum1.hasMoreElements()){
				    cType=(ComplexType)groupEnum1.nextElement();
				    if ((cType.getName()).equals(findTypeName(elementDecl.getName()))) break;
				}
				
			    }
			if ((cType != null) ){		
			     tpsch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
			    tpsch+="set name(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+elementDecl.getName()+"' ; \n";
					    
			    elename="'"+elementDecl.getName()+"'";
			    // System.out.println(" element "+ elementDecl.getName());

			    if (cType.getName()!=null){
				tpsch+="set wsdltype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+cType.getName()+"' ; \n";
				wsdltype="'"+cType.getName()+"'";
				tpsch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+""+"'; \n";
			    }
			    

			    tpsch+="set minoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+group.getParticle(particleIndex).getMinOccurs()+"' "+"; \n"; 
			    tpsch+="set maxoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+group.getParticle(particleIndex).getMaxOccurs()+"' "+"; \n";				    
			    min="'"+group.getParticle(particleIndex).getMinOccurs()+"'";
			    max="'"+group.getParticle(particleIndex).getMaxOccurs()+"'";

			    eleinstance=findElements.pickupElements(psch,elename,wsdltype,min,max);
			    if ( eleinstance.equals("")){ 
				psch+=tpsch;
				buildComplexPart(cType,0,prefixele+"_"+Integer.toString(eindex));
				Enumeration particleEnum1 = (cType).enumerate();
				Group group1 = null;
				while(particleEnum1.hasMoreElements()){
				    Particle particle1 = (Particle)particleEnum1.nextElement();
				    if (particle1 instanceof Group)
					{
					    group1 = (Group)particle1;
					    break;
					}
				}
				if (group1!=null && !any)
				    if(group1.getParticleCount()>0){
					psch+="add subelements(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+")={";
					for(int j=0;j<(group1.getParticleCount()-1);j++)
					    psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+j+",";
					psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+(group1.getParticleCount()-1)+"}; \n";
				    }
				any=false;
				
			    }
			    else{
				psch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
				psch+="set :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+ " = "+eleinstance+"; \n";
			    }
			    
			}
		    }
                 eindex+=1;
		 particleIndex+=1;
		}
		else 
		    if (item.getStructureType() == Structure.WILDCARD){
			any=true;
			psch+="set wsdltype(:"+schemaname+"e"+prefixele+") = '"+"string"+"' ; \n";
			psch+="set wsmedtype(:"+schemaname+"e"+prefixele+") = '"+"CHARSTRING"+"'; \n";
		    }
	    }//while
	}
        else{
            
            /* check arrayType attribute*/
            //System.out.println("array "+ complexType.getName());
	    Schema sch=complexType.getSchema();
	    String arrayElement="";
            if (complexType.getName()!=null)
		arrayElement= readJdom(wsdlElement,complexType.getName());

            String baseType=findbasictype(arrayElement);
            if (baseType.equals("")){
	
		eleinstance=findElements.pickupElements(psch,arrayElement,arrayElement,"0","1");
		if ( eleinstance.equals("")){ 
		    psch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
		    psch+="set name(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+arrayElement+"' ; \n";
                    psch+="set wsdltype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+arrayElement+"' ; \n";
                    psch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+""+"'; \n";
                    psch+="set minoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+0+"' "+"; \n"; 
		    psch+="set maxoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'-1'"+"; \n";		
		    buildComplexPart(sch.getComplexType(arrayElement),0,prefixele+"_"+Integer.toString(eindex));
		    Enumeration particleEnum1 = (sch.getComplexType(arrayElement)).enumerate();
		    Group group1 = null;
		    while(particleEnum1.hasMoreElements())
			{
			    Particle particle1 = (Particle)particleEnum1.nextElement();
			    if (particle1 instanceof Group)
				{
				    group1 = (Group)particle1;
				    break;
				}
			}
		    if (group1!=null)
			if(group1.getParticleCount()>0)
			    {
				psch+="add subelements(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+")={";
				for(int j=0;j<(group1.getParticleCount()-1);j++)
				    psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+j+",";
				psch+=":"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"_"+(group1.getParticleCount()-1)+"}; \n";
			    }
                }
		else{
		    psch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
		    psch+="set :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+ " = "+eleinstance+"; \n";
		}
		psch+="add subelements(:"+schemaname+"e"+prefixele+")={:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+"}; \n";;
		elementindex+=1;
	    }
	    else{
		//System.out.println("test "+baseType);
		psch+="create Element instances :"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+" ; \n";
		psch+="set name(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+complexType.getName()+"' ; \n";
		psch+="set wsdltype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+arrayElement+"' ; \n";
		psch+="set wsmedtype(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = '"+baseType+"'; \n";
		psch+="set minoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'"+0+"' "+"; \n"; 
		psch+="set maxoccurs(:"+schemaname+"e"+prefixele+"_"+Integer.toString(eindex)+") = "+"'-1'"+"; \n";	
	    }
	}
        
    }

   /**
    * Gets an XML Type from a SOAP Message Part read from WSDL
    *
    * @param   part     The SOAP Message part
    *
    * @return The corresponding XML Type is returned.
    *         null is returned if not found or if a simple type
    */
   
   protected XMLType getXMLType(Part part)
   {
       //System.out.println("messagetext>>22"); 
      if(wsdlTypes == null)
      {
         // No defined types, Nothing to do
         return null;
      }
     
      // Find the XML type
      XMLType xmlType = null;

      // First see if there is a defined element
      if(part.getElementName() != null)
      {
         // Get the element name
         String elemName = part.getElementName().getLocalPart();
	
         // Find the element declaration
         ElementDecl elemDecl = wsdlTypes.getElementDecl(elemName);

         if(elemDecl != null)
         {
            // From the element declaration get the XML type
            xmlType = elemDecl.getType();
	    
         }
	
      }
      else
	  {	  
	      if(part.getTypeName() != null)
		  {
		      // Get the element name
		      String partName = part.getTypeName().getLocalPart();
	 
		      xmlType = wsdlTypes.getType(partName);
		  }
	      
	  }
   
      return xmlType;
   }

   /**
    * Returns the desired ExtensibilityElement if found in the List
    *
    * @param   extensibilityElements   The list of extensibility elements to search
    * @param   elementType             The element type to find
    *
    * @return  Returns the first matching element of type found in the list
    */
   private static ExtensibilityElement findExtensibilityElement(List extensibilityElements, String elementType)
   {
      if(extensibilityElements != null)
      {
	 
	  Iterator iter = extensibilityElements.iterator();

         while(iter.hasNext())
         {
            ExtensibilityElement element = (ExtensibilityElement)iter.next();
            
            if(element.getElementType().getLocalPart().equalsIgnoreCase(elementType))
            {
	       // Found it
               return element;
            }
         }
      }

      return null;
   }
    private static void writeamosql(String ip)
    {
	FileOutputStream out; // declare a file output object
	PrintStream p; // declare a print stream object

	try
	    {
		// Create a new file output stream
		// connected to "myfile.txt"
		out = new FileOutputStream("src/amosql/populatewsdl.amosql");
		
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
    private String findbasictype(String checkstr)
    {
	
	String str="";
	for(int i=0;i<45;i++)
	    {	//System.out.println("findbasictype "+checkstr+ "  "+basictype[i][0]);
		if (checkstr.equals(basictype[i][0]))
		    {
			//System.out.println("findbasictype "+checkstr+ "  "+basictype[i][0]);
			str=basictype[i][1];
			break;
		    }
		
	    }
	return(str);
    }
    private Message findSoapHeader(Definition def,String sh)
    {
                                                     	Boolean found=false; 
	Message msg=null;
	Map messages = def.getMessages();
	Iterator msgIter = messages.values().iterator();
	 while (msgIter.hasNext()&& !found)
	     {
		 msg = (Message)msgIter.next();
		 if (sh.equals(msg.getQName().getLocalPart()))
		     found=true;
			     
	     }
	 return(msg); 
    }

    /*read JDOM representation of WSDL to find arrayType name decribed by attribue of Castor model*/

    private String  readJdom(org.jdom.Element current, String name){
     
	List children = current.getChildren();
	Iterator iterator = children.iterator();
	Element child=null;
        boolean found=false;
        if (!(iterator.hasNext()))
	    return "";

	while (iterator.hasNext()) {
	    child = (Element)iterator.next();
	    if (child.getAttributeValue("name").equals(name)) {
		found=true;
		break;
	    }
	}
       
	//System.out.println(name);
        while(!((child.getName()).equals("restriction"))){
             children=child.getChildren();
	    iterator = children.iterator(); 
	    if (!(iterator.hasNext())) 
		break;
	    else
		child = (Element)iterator.next();
	}
       
        if (!(iterator.hasNext()) && (!((child.getName()).equals("restriction"))))  return "";

         /* find the next level childern- attribute */
        children=child.getChildren();
        iterator = children.iterator(); 
        if (!(iterator.hasNext()))
	    return "";
        child = (Element)iterator.next();
        //System.out.println(child.getName()+ "   "+name);
	String elementName=child.getAttributeValue("arrayType");
        if (elementName.equals(""))
	    return "";
        elementName=elementName.replace("[","");
        elementName=elementName.replace("]","");
        
        //tokenizing elementName
        StringTokenizer stk = new StringTokenizer(elementName, ":");
	
	int len=stk.countTokens();
	
	if (len > 0){
	    //tokenizing the inputstr
	    while (stk.hasMoreTokens()){
		elementName=stk.nextToken();
	    }
	}
      
	return elementName;
    }		   
 
    /*read JDOM representation of WSDL to find enumeration value*/

    private String readEnuValue(org.jdom.Element current, String name){
        
	List children = current.getChildren();
	Iterator iterator = children.iterator();
	Element child=null;
        boolean found=false;
        if (!(iterator.hasNext()))
	    return "{}";
	while (iterator.hasNext()) {
	    child = (Element)iterator.next();
	    // System.out.println(child.getAttributeValue("name")+" >>>>>> "+name);
	    if (child.getAttributeValue("name").equalsIgnoreCase(name)){
		found=true;
                break;}
	}
       
        if (!found) return "{}";
       
        while(!((child.getName()).equals("restriction"))){
             children=child.getChildren();
	    iterator = children.iterator(); 
	    if (!(iterator.hasNext())) 
		break;
	    else
		child = (Element)iterator.next();
	}
       
        if (!(iterator.hasNext()) && (!((child.getName()).equals("restriction"))))  return "{}";
        baseType= child.getAttributeValue("base") ;

        StringTokenizer stk = new StringTokenizer(baseType, ":");
	int len=stk.countTokens();
	
	if (len > 0){
	    //tokenizing the inputstr
	    while (stk.hasMoreTokens()){
		baseType=stk.nextToken();
	    }
	}
   
        /* find the next level childern- enumeration*/
        children=child.getChildren();
        iterator = children.iterator();
       
        name="{";
	while (iterator.hasNext()) {
	    child = (Element)iterator.next();
	      
            if (name.equals("{"))
		name+="'"+child.getAttributeValue("value")+"'";
            else 
		name+=" , "+"'"+child.getAttributeValue("value")+"'";
	}
        name+="}";

	//System.out.println(name);
	return name;
    }	

   /*read JDOM representation of WSDL to  find type of an element which castor xmltype is null*/

    private XMLType findType(org.jdom.Element current, String name){

	List children = current.getChildren();
	Iterator iterator = children.iterator();
	Element child=null;
        boolean found=false;
        XMLType xmlType=null;
	
        
        if (!(iterator.hasNext()))
	    return xmlType;
	

	while (iterator.hasNext()){
	    child = (Element)iterator.next();
	    if (child.getAttributeValue("name").equals(name)) {
                
		found=true;
		break;
	    }
	}
       
	
        while(!((child.getName()).equals("element"))){
	    children=child.getChildren();
	    iterator = children.iterator(); 
	    if (!(iterator.hasNext())) 
		break;
	    else
		child = (Element)iterator.next();
	}
       
        if (!(iterator.hasNext()) && (!((child.getName()).equals("element"))))  return null;
	
        
        //System.out.println(child.getName()+ "   "+name);
	String elementName=child.getAttributeValue("type");
        if (elementName.equals(""))
	    return null;
        
        //tokenizing elementName
        StringTokenizer stk = new StringTokenizer(elementName, ":");
	
	int len=stk.countTokens();
	
	if (len > 0){
	    //tokenizing the inputstr
	    while (stk.hasMoreTokens()){
		elementName=stk.nextToken();
	    }
	}
	//System.out.println("test "+elementName);	
	// Find XMLType
	xmlType = wsdlTypes.getType(elementName);
	

	return xmlType;
    }
     /**
     * Check whether wsdl contains  import name spaces and multiple schema definition from the WSDL content as Castor throws an exception
     *
     * @param   wsdlURL 
     *
     * @return  rewrite of wsdl needed or not
     *    
     */

    private  static boolean readWSDL(String wsdlURL)throws Exception{
      Boolean reWrite=false;
	try{
	    URL wsdlU = new URL(wsdlURL);
	    BufferedReader in = new BufferedReader(new InputStreamReader(wsdlU.openStream()));

	    String inputLine;
            String wsdlStr="";
            

	    while ((inputLine = in.readLine()) != null){
	
                String tempLine=removeImport(inputLine);
		//System.out.println("<"+tempLine+">");
                //System.out.println(">"+inputLine+"<");
		if (((tempLine.trim()).length()!=(inputLine.trim()).length()) && !reWrite)
		    reWrite=true;
		wsdlStr+=tempLine;
	    }

	    in.close();
	    if (reWrite) writeWSDL(wsdlStr);
	    
	}
	catch(Exception e){
	    System.err.println( e.getMessage());
	}
        return reWrite;
     }
     /**
     * write a newWSDL.wsdl
     *
     * @param   ip new String representation of wsdl content.
     *
     * @return  
     *    
     */
     private static void writeWSDL(String ip)
    {
	FileOutputStream out; // declare a file output object
	PrintStream p; // declare a print stream object

	try
	    {
		// Create a new file output stream
		// connected to "myfile.txt"
		out = new FileOutputStream("wsdl/newWSDL.wsdl");
		
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
    /**
     * Remove import name spaces and multiple schema definition from the WSDL content as Castor throws an exception
     *
     * @param   wsdlcontent String representation of wsdl content.
     *
     * @return  cleaned wsdl content
     *    
     */
    public static String removeImport(String wsdlcontent){
	 
        int index=-1;
        boolean schema=false;
        boolean importns=false;
	
        while(wsdlcontent.indexOf("</xsd:schema>")!=wsdlcontent.lastIndexOf("</xsd:schema>")){
	    wsdlcontent=wsdlcontent.replaceFirst("</xsd:schema>","");
	    schema=true;
	}
         while(wsdlcontent.indexOf("</schema>")!=wsdlcontent.lastIndexOf("</schema>")){
	    wsdlcontent=wsdlcontent.replaceFirst("</schema>","");
	    schema=true;
	}

        if (schema) {
          StringTokenizer stk = new StringTokenizer(wsdlcontent, "<");
	  String rwsdl="";
	  int len=stk.countTokens();
          	wsdlcontent="";
		int count=0;
          if (len > 0){
	      boolean update=false;
	    while (stk.hasMoreTokens()){
		rwsdl=stk.nextToken();
                index=-1;
                if ((!((rwsdl.trim()).equalsIgnoreCase("</xsd:schema>")))||(!((rwsdl.trim()).equalsIgnoreCase("</schema>"))))
		    index=rwsdl.indexOf("schema ");
		
		if ((index < 0) && (!((rwsdl.trim()).equalsIgnoreCase(""))))
                            wsdlcontent+="<"+rwsdl;

                if (index > -1 && !update){
		    wsdlcontent+="<"+rwsdl;
                    update=true;
		}
	    }
         
	  }
	}
        
        if (wsdlcontent.indexOf("import")>0)
	    importns=true;
        
        if (!schema && !importns)
	    return wsdlcontent;
	/*
         if (!importns)
	    return wsdlcontent;
          */

        //tokenizing wsdlcontent
        StringTokenizer stk = new StringTokenizer(wsdlcontent, "<");
	String rwsdl="";
	int len=stk.countTokens();
        
	wsdlcontent="";
        
	if (len > 0){
	    //checking for import
	    while (stk.hasMoreTokens()){
		rwsdl=stk.nextToken();
		index=rwsdl.indexOf("import ");
                if ((index < 0) && (!((rwsdl.trim()).equalsIgnoreCase(""))))
		    wsdlcontent+="<"+rwsdl;
	    }
                
	}
    

	return wsdlcontent;
    }

  /**
     * Find the type Name of a given element when Castor throws an exceptio
     *
     * @param   elementName name of the element to find Type
     *
     * @return  Type name of elementName
     *    
     */
    public static String findTypeName(String elementName){
          
        
	StringTokenizer stk = new StringTokenizer(wsdlString, "<");
	String rwsdl="";
	int len=stk.countTokens();
          
	if (len > 0){
	      
	    while (stk.hasMoreTokens()){
		rwsdl=stk.nextToken();
		if (((rwsdl.trim()).indexOf("name=\""+elementName+"\"")) > -1)
		    break;
	    }
	}
          
	stk = new StringTokenizer(rwsdl.trim(), " ");
	rwsdl="";
	len=stk.countTokens();
	if (len > 0){
	      
	    while (stk.hasMoreTokens()){
		rwsdl=stk.nextToken();
		if (((rwsdl.trim()).indexOf("type=")) > -1)
		    break;
	    }
	}
	rwsdl=rwsdl.substring(rwsdl.indexOf("=")+1,rwsdl.length()-1);
        stk = new StringTokenizer(rwsdl.trim(), ":");

	len=stk.countTokens();
        if (len==0 ) return rwsdl;
	rwsdl="";
        rwsdl=stk.nextToken();
	if (len > 1) rwsdl=stk.nextToken();
	return rwsdl;
          
    }
}
