package wsdlcreator;

import java.io.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Vector;

import javax.wsdl.Binding;
import javax.wsdl.BindingInput;
import javax.wsdl.BindingOperation;
import javax.wsdl.BindingOutput;
import javax.wsdl.Definition;
import javax.wsdl.Input;
import javax.wsdl.Message;
import javax.wsdl.Operation;
import javax.wsdl.Output;
import javax.wsdl.Part;
import javax.wsdl.Port;
import javax.wsdl.PortType;
import javax.wsdl.Service;
import javax.wsdl.Types;
import javax.wsdl.WSDLException;
import javax.wsdl.extensions.ExtensionRegistry;
import javax.wsdl.extensions.schema.Schema;
import javax.wsdl.extensions.soap.SOAPAddress;
import javax.wsdl.extensions.soap.SOAPBinding;
import javax.wsdl.extensions.soap.SOAPBody;
import javax.wsdl.extensions.soap.SOAPOperation;
import javax.wsdl.factory.WSDLFactory;
import javax.wsdl.xml.WSDLWriter;
import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;
import callout.CallContext;

public class WSDLGenerator implements server.constants{
	private Vector<FunStmt> Funstmts;
	private String Host;
	private String ServiceName;
       
	public WSDLGenerator() throws UnknownHostException{		
		this(ServletDefault, ServiceNameDefault);
	}
	
	public WSDLGenerator(String Servlet, String ServerName) throws UnknownHostException{
		Funstmts = new Vector<FunStmt>();
		String ip = "127.0.0.1";
		
		InetAddress localHost = InetAddress.getLocalHost();
		ip = localHost.getHostAddress();

	             
		this.Host = "http://"+ip+":"+port+Servlet;
		
//		System.out.println("Host:" + Host);
		this.ServiceName = ServerName;
	}

	public Vector<FunStmt> getFuns(){
		return Funstmts;
	}
	

	
	private  WSDLFactory wsdlFactory = null;
	private  Definition wsdlDef = null;    
	private  ExtensionRegistry extensionRegistry;
	private  Element typeSchema;
	private  Document doc;
	/*
	 * initilize the WSDL envelope
	 */
	public void init() throws WSDLException, ParserConfigurationException, DOMException, AmosException{
		wsdlFactory = WSDLFactory.newInstance();
		wsdlDef = wsdlFactory.newDefinition();

		wsdlDef.setQName(new QName(TNS_URI, this.ServiceName));
		wsdlDef.setTargetNamespace(TNS_URI);		
		wsdlDef.addNamespace("tns", TNS_URI);
//		wsdlDef.addNamespace(APACHESOAP_PREFIX, APACHESOAP_URI);
//		wsdlDef.addNamespace("impl", TNS_URI);
//		wsdlDef.addNamespace("intf", TNS_URI);
		wsdlDef.addNamespace(SOAPENV_PREFIX,SOAPENV_URI);
		wsdlDef.addNamespace(WSDL_PREFIX, WSDL_URI);
		wsdlDef.addNamespace(WSDLSOAP_PREFIX, WSDLSOAP_URI);
		wsdlDef.addNamespace(XSD_PREFIX, XSD_URI);		
		extensionRegistry = wsdlFactory.newPopulatedExtensionRegistry();
		
		//construct the TypeSchema section
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder dbuilder = null;
		
		dbuilder = dbf.newDocumentBuilder();
		
		doc = dbuilder.newDocument();
		
		String PREFIX = XSD_PREFIX+":";
		typeSchema = doc.createElement(PREFIX+"schema");
		typeSchema.setAttribute("targetNamespace", TNS_URI);
		typeSchema.setAttribute("xmlns", XSD_URI);

		/*
		 * typeSchema.appendChild(genComplexType("AnyType",PREFIX+"string", "1", "1"));
		 *	typeSchema.appendChild(genComplexType("OID",PREFIX+"string", "1", "1"));
		 *	typeSchema.appendChild(genComplexType("INTEGER",PREFIX+"long", "1", "1"));		
		 *	typeSchema.appendChild(genComplexType("BOOLEAN",PREFIX+"boolean", "1", "1"));
		 *	typeSchema.appendChild(genComplexType("REAL",PREFIX+"double", "1", "1"));
		 *	typeSchema.appendChild(genComplexType("CHARSTRING", PREFIX+"string", "1", "1"));
		 *	typeSchema.appendChild(genComplexType("TIME", PREFIX+"Time", "1", "1"));
		 */
		
		
		typeSchema.appendChild(genComplexType("VectorofanyType",PREFIX+"anyType", "1", "unbounded"));
		typeSchema.appendChild(genComplexType("VectorofOID",PREFIX+"string", "1", "unbounded"));
		typeSchema.appendChild(genComplexType("VectorofINTEGER",PREFIX+"int", "1", "unbounded"));
//		typeSchema.appendChild(genComplexType("VectorofBOOLEAN",PREFIX+"boolean", "1", "unbounded"));
		typeSchema.appendChild(genComplexType("VectorofREAL",PREFIX+"double", "1", "unbounded"));
		typeSchema.appendChild(genComplexType("VectorofCHARSTRING", PREFIX+"string", "1", "unbounded"));
//		typeSchema.appendChild(genComplexType("VectorofTIME", PREFIX+"Time", "1", "unbounded"));
		
//		Element e = genStructType();
//		Element e = genCollectionType();
	}

	/*
	 * judge whether it is a primitive type
	 */
	public boolean isPrimitiveType(String type){
		return type.equals("INTEGER")||type.equals("BOOLEAN")||type.equals("REAL")||type.equals("CHARSTRING")||type.equals("NUMBER");
	}
	
	/*
	 * judge whether it is a collection type
	 */
	public boolean isCollectionType(String type){
		return type.startsWith("VECTOR")||type.startsWith("BAG");
	}
	
	/*
	 * if it is a specified vector, get the type
	 */
	public String getVectorType(String type){
		String t="anyType";
		if(type.startsWith("VECTOR")){
			try{
				t = type.substring(10);
			}catch(Exception e){
				
			}
		}
		if(type.startsWith("BAG")){
			try{
				t = type.substring(7);
			}catch(Exception e){
				
			}
		}
		if(t.equals("anyType"))
		    return t;
		if(!isPrimitiveType(t))
			t="OID";
		return t;
	}
	
	public String decode2XML(String amosType) throws AmosException{
		
		if(amosType.equals("INTEGER"))
			return "int";
		if(amosType.equals("BOOLEAN"))
			return "boolean";
		if(amosType.equals("REAL"))
			return "double";
		if(amosType.equals("CHARSTRING"))
			return "string";
		if(amosType.equals("NUMBER"))
		    return "double";
		/*
		if(amosType.equals("TIME"))
			return "time";
			*/
		
		System.out.println("Error: The type, "+amosType+", can not map to JAVA.");
		throw new AmosException("Error: The type, "+amosType+", can not map to JAVA.");
	}
	
	/*
	 * Generate a Simple element. 
	 * If type has no prefix, mapping to standed xml type.  
	 */
	public Element genSimpleType(String name, String type) throws DOMException, AmosException{
		Element e = doc.createElement(XSD_PREFIX+":element");
		e.setAttribute("name", name);
		if(type.contains(":")){
			// already has the targetNameSpace Prefix
			e.setAttribute("type", type);
		}
		else{
			if(isPrimitiveType(type)){
				e.setAttribute("type", XSD_PREFIX+":"+decode2XML(type));
			}				
			else if(isCollectionType(type)){
				String t = getVectorType(type);
				e.setAttribute("type", TNS_PREFIX+":"+"Vectorof"+t);
			}
			else{
				/*It is an object in AmosII*/
				e.setAttribute("type", XSD_PREFIX+":"+"string");
			}
		}
		return e;
	}
	/*
	 * Generate a Complex Element
	 */
	public Element genComplexType(String name, String type,  String minOcc, String maxOcc) throws DOMException, AmosException{

		Element ct = doc.createElement(XSD_PREFIX +":complexType");
		ct.setAttribute("name", name);
		Element sq = doc.createElement(XSD_PREFIX+":sequence");
		Element element = doc.createElement(XSD_PREFIX+":element");
		if(type.contains(":")){
			element.setAttribute("type", type);
		}
		else{
			if(isPrimitiveType(type)){
				element.setAttribute("type", XSD_PREFIX+":"+decode2XML(type));
			}				
			else if(isCollectionType(type)){
				String t = getVectorType(type);
				element.setAttribute("type", TNS_PREFIX+":"+"Vectorof"+t);
			}
			else{
				element.setAttribute("type", XSD_PREFIX+":"+"string");
			}
		}
		element.setAttribute("name", "member");
		element.setAttribute("minOccurs", minOcc);
		element.setAttribute("maxOccurs", maxOcc);
		sq.appendChild(element);
		ct.appendChild(sq);
		return ct;
	}



      
	
	/*
	 * Adding the Response to Type Schema
	 * The stucture of the Response Type. In the following form:
	 *  <xsd:element name = "functionName + Response">
	 *     <xsd:complexType>
	 *        <xsd:sequence>
	 *            <xsd:element name="result" maxOccurs="unbounded" minOccur="0">
	 *               <xsd:complexType>
	 *                  <xsd:sequence>
	 *                     <xsd:element ...../xsd:element>
	 *                  </xsd:sequence>
	 *               </xsd:complexType>
	 *            </xsd:element>  
	 *        </xsd:sequence>
	 *     </xsd:complexType>    
	 *  </xsd:element>
	 */
        public void addResponseType(String name, List<String> varName, List<String> varType) throws DOMException, AmosException{
		String PREFIX = XSD_PREFIX+":";
//		Element e = doc.createElement(PREFIX + "element");
//		e.setAttribute("name", name);
		Element ct = doc.createElement(PREFIX +"complexType");
		ct.setAttribute("name", name);
		Element sq = doc.createElement(PREFIX+"sequence");
		
		Element e1 = doc.createElement(PREFIX + "element");
		e1.setAttribute("name", "row");
               	e1.setAttribute("minOccurs", "0");
		e1.setAttribute("maxOccurs", "unbounded");
		Element ct1 = doc.createElement(PREFIX +"complexType");
		Element sq1 = doc.createElement(PREFIX+"sequence");

		for( int i=0; i<varName.size();i++){
			String type = varType.get(i);
			Element el;
			el = genSimpleType(varName.get(i),varType.get(i));
			sq1.appendChild(el);
		}
		ct1.appendChild(sq1);
		e1.appendChild(ct1);
		
		sq.appendChild(e1);
		ct.appendChild(sq);
		typeSchema.appendChild(ct);
//		e.appendChild(ct);
//		typeSchema.appendChild(e);
	}
	public void addSimpleResponseType(String name, List<String> varName, List<String> varType) throws DOMException, AmosException {
	    String PREFIX = XSD_PREFIX+":";

	    Element ct = doc.createElement(PREFIX +"complexType");
	    ct.setAttribute("name", name);
	    Element sq = doc.createElement(PREFIX+"sequence");
			
	

	    for( int i=0; i<varName.size();i++){
		String type = varType.get(i);
		Element el;
		el = genSimpleType(varName.get(i),varType.get(i));
		sq.appendChild(el);
	    }
	    ct.appendChild(sq);
	
	    typeSchema.appendChild(ct);

	}
	
	
	/*
	 * Generate the stucture of the Request Type in Types section. In the following form:
	 *  <xsd:element name = "functionName">>
	 *     <xsd:complexType>
	 *        <xsd:sequence>
	 *           <xsd:element ....................>
	 *           ......................
	 *        </xsd:sequence>
	 *     </xsd:complexType>
	 *  </xsd:element>     
	 */

	public void addRequestType(String name, List<String> varName, List<String> varType) throws DOMException, AmosException{
		Element e = doc.createElement(XSD_PREFIX + ":element");		
		Element ct = doc.createElement(XSD_PREFIX +":complexType");
		Element sq = doc.createElement(XSD_PREFIX +":sequence");
		for( int i=0; i<varName.size();i++){
			String type = varType.get(i);

			Element el;

			el = genSimpleType(varName.get(i),varType.get(i));
			sq.appendChild(el);
		}		
		ct.appendChild(sq);
		e.appendChild(ct);
		e.setAttribute("name", name);
		typeSchema.appendChild(e);
	}
	
	/*
	 * Generate an Operation
	 * @param operation
	 * @param function name
	 * @param FunStmt
	 */
	public void genOperation(Operation operation, String funName, FunStmt fs) throws AmosException{
	    String index = String.valueOf(fs.getFunIndex());
	    if (index.equals("0")) {
		index="";
	    }
	    
	    /*construct the input section */
	    Message inMessage = wsdlDef.createMessage();
	    inMessage.setQName(new QName(TNS_URI, funName+"Request"+index));
	    List<String> varName = fs.getInNameList();
	    List<String> varType = fs.getInTypeList();
	    if(fs.getArity() != 0){							
		for(int i=0, size = varName.size(); i<size; i++){
		    Part inPart = wsdlDef.createPart();
		    
		    inPart.setName(varName.get(i));
		    String type = varType.get(i);
		    
		    if(isCollectionType(type)){
			String t = getVectorType(type);
			inPart.setTypeName(new QName(TNS_URI, "Vectorof"+t));
		    }
		    else if(isPrimitiveType(type)){
			inPart.setTypeName(new QName(XSD_URI, decode2XML(type)));
		    }
		    else{
			inPart.setTypeName(new QName(XSD_URI, "string"));
		    }
		    //		    inPart.setTypeName(new QName(TNS_URI, funName));
		    //		    inPart.setElementName(new QName(TNS_URI, funName));
		    inMessage.addPart(inPart);
		}
	    }		
	    inMessage.setUndefined(false);
	    wsdlDef.addMessage(inMessage);
	    Input input = wsdlDef.createInput();
	    input.setMessage(inMessage);
	    input.setName(funName+"Request"+index);
		
	    /*since we change to rpc/enc style, we not use it.*/
	    // adding the request type to the TypeSchema
	    //addRequestType(funName, fs.getInNameList(), fs.getInTypeList());
			
	    operation.setInput(input);
	    operation.setParameterOrdering(varName);
	    
	    
	    /* construct the output section*/
	    if(fs.getWidth()!=0){
		Message outMessage = wsdlDef.createMessage();
		outMessage.setQName(new QName(TNS_URI, funName+"Response"+index));
	
		if (fs.getResultFormat().equalsIgnoreCase("Bag")) {
		    Part outPart = wsdlDef.createPart();
		    outPart.setName("results");
		    // outPart.setElementName(new QName(TNS_URI, funName+"Response"));
		    outPart.setTypeName(new QName(TNS_URI, funName+index));
		    outMessage.addPart(outPart);
		    			
		    //adding the output type into the TypeSchema
		    addResponseType(funName+index, fs.getOutNameList(), fs.getOutTypeList());
		  }
		else {
		    varName = fs.getOutNameList();
		    varType = fs.getOutTypeList();
		    for(int i=0, size = varName.size(); i<size; i++){
			Part outPart = wsdlDef.createPart();
		
			outPart.setName(varName.get(i));
		
			String type = varType.get(i);
			if(isCollectionType(type)){
			    String t = getVectorType(type);
			    outPart.setTypeName(new QName(TNS_URI, "Vectorof"+t));
			}
			else if(isPrimitiveType(type)){
			    outPart.setTypeName(new QName(XSD_URI, decode2XML(type)));
			}
			else{
			    outPart.setTypeName(new QName(XSD_URI, "string"));
			}
			
			outMessage.addPart(outPart);
		    }
		    
		}
		outMessage.setUndefined(false);
		wsdlDef.addMessage(outMessage);
		Output output = wsdlDef.createOutput();
		output.setMessage(outMessage);
		output.setName(funName+"Response"+index);
		operation.setOutput(output);
		
	    }
		
	    operation.setName(funName);
	    operation.setUndefined(false);
	}
	
	/*
	 * Generate a wsdl file in memory
	 */
	public void genWSDL() throws ParserConfigurationException, WSDLException, AmosException{
		init();
		
		PortType portType = wsdlDef.createPortType();
		portType.setQName(new QName(TNS_URI, ServiceName+"PortType"));			
		
		// construct the bind section
		Binding bind = wsdlDef.createBinding();
		bind.setQName(new QName(TNS_URI,ServiceName+ "SoapBinding"));
		bind.setPortType(portType);
		bind.setUndefined(false);
		SOAPBinding soapBinding = (SOAPBinding) extensionRegistry.createExtension(Binding.class, new QName(WSDLSOAP_URI, "binding"));
		soapBinding.setTransportURI("http://schemas.xmlsoap.org/soap/http");
		soapBinding.setStyle("rpc");
		bind.addExtensibilityElement(soapBinding);
		
		Enumeration e = Funstmts.elements();
		while(e.hasMoreElements()){
		    FunStmt stmt = (FunStmt) e.nextElement();
		    String funName = stmt.getFunName();
		    String signature = null;
		   
		    /*generate the Operation section*/
		    Operation operation = wsdlDef.createOperation();
		    genOperation(operation, funName, stmt);
		    portType.addOperation(operation);
			
		    BindingOperation bindOp = wsdlDef.createBindingOperation();
		    bindOp.setName(funName);
		    ExtensionRegistry extensionRegistry = wsdlFactory.newPopulatedExtensionRegistry();											
		    /*soap:operation element in "binding"*/                                                                                                                    
		    SOAPOperation soapOperation = (SOAPOperation) extensionRegistry.createExtension(BindingOperation.class, new QName(WSDLSOAP_URI, "operation"));
		    /*soapOperation.setStyle("document");*/
		    soapOperation.setSoapActionURI("");
		    bindOp.addExtensibilityElement(soapOperation);
		    bindOp.setOperation(operation);
			
		    /*define the soap body, used in input and output soap
		     * Using doc/literal  binding
		     */
		    SOAPBody soapBody = (SOAPBody) extensionRegistry.createExtension(BindingInput.class, new QName(WSDLSOAP_URI, "body"));
		    soapBody.setUse("encoded");
		    soapBody.setNamespaceURI(TNS_URI);
		    ArrayList<String> al = new ArrayList<String>(1);
		    al.add(SOAPENV_URI);
		    soapBody.setEncodingStyles(al);
			
			
		    Input input = operation.getInput();
		    if(input!=null){
			BindingInput bindingInput = wsdlDef.createBindingInput();
			bindingInput.setName(input.getName());
			bindingInput.addExtensibilityElement(soapBody);
			bindOp.setBindingInput(bindingInput);
		    }

		    Output output = operation.getOutput();
		    if(output!=null){
			BindingOutput bindingOutput = wsdlDef.createBindingOutput();
			bindingOutput.setName(output.getName());
			bindingOutput.addExtensibilityElement(soapBody);
			bindOp.setBindingOutput(bindingOutput);
		    }		
		    bind.addBindingOperation(bindOp);
		}
		portType.setUndefined(false);
		wsdlDef.addPortType(portType);
		
		Port port = wsdlDef.createPort();
		port.setName(ServiceName+"Port");
		SOAPAddress soapAddress = (SOAPAddress) extensionRegistry.createExtension(Port.class, new QName(WSDLSOAP_URI, "address"));
		soapAddress.setLocationURI(Host);
		port.addExtensibilityElement(soapAddress);
		port.setBinding(bind);			
		wsdlDef.addBinding(bind);
		
		Service srv = wsdlDef.createService();
		srv.setQName(new QName(TNS_URI,ServiceName+"Service"));
		srv.addPort(port);
		wsdlDef.addService(srv);
		
		//adding the type section.
		Types types = wsdlDef.createTypes();
//		types.setDocumentationElement(schemaElement);
		Schema schema = (Schema) extensionRegistry.createExtension(Types.class, new QName(XSD_URI, "schema"));
		schema.setElement(typeSchema);
		types.addExtensibilityElement(schema);
		wsdlDef.setTypes(types);			
	}
	
	/*
	 * Write the wsdl to a file.
	 * @param function name
	 */
	public void writeWSDL(String fn) throws WSDLException, IOException{		
		WSDLWriter writer = wsdlFactory.newWSDLWriter();
		OutputStream sink;
		//System.out.println(fn);
		sink = new FileOutputStream(fn);
		writer.writeWSDL(wsdlDef, sink);
//		System.out.println("finish");
		sink.close();

	}
	
	
	/*
	 *  register the function into AMOSII's object funInfo.
	 *  funInfo : create type funInfo properties ( funName charstring, argsType charstring, argsName charstring, rettype charstring, retname charstring); 
	 */
	public void RegAmosII(String serverName) throws AmosException{		
		String dbServer="";
		Connection theConnection = null;	
	
		if (!serverName.equals("")){
			dbServer = serverName;
		}
		theConnection = new Connection(dbServer);
		
	
		Enumeration e = Funstmts.elements();
		while(e.hasMoreElements()){
			FunStmt fs = (FunStmt) e.nextElement();
			
			String funName = fs.getFunName();
			String argsTypes = fs.getInputTypes();
			String argsNames = fs.getInputNames();
			String fnReturnTypes = fs.getOutputTypes();
			String fnReturnNames = fs.getOutputNames();
			String  fnResultFormat=fs.getResultFormat();
			int index = fs.getFunIndex();
			/*
			System.out.println("fn:" + funName);
			System.out.println("argsTypes:" + argsTypes);
			System.out.println("argsNames:" + argsNames);
			System.out.println("fnReturnTypes:" + fnReturnTypes);
			System.out.println("fnReturnNames:" + fnReturnNames);
			*/
			Tuple tpl = new Tuple(6);
			tpl.setElem(0, funName);
			tpl.setElem(1, argsNames);
			tpl.setElem(2, argsTypes);	
			tpl.setElem(3, fnReturnNames);
			tpl.setElem(4, fnReturnTypes);
			tpl.setElem(5, fnResultFormat);
                        
			if(!theConnection.callFunction("FunInfo",tpl).getRow().getBooleanElem(0))
				throw new AmosException("some error occurs when creating an object of class FunInfo");				
		}
	
		String saveAs = DBName+".dmp"; 
//		System.out.println("save \""+saveAs+"\";");
		theConnection.execute("save \""+saveAs+"\";");
		theConnection.disconnect();	
	}
	
	public void generate_wsdl(CallContext cxt, Tuple tpl) throws AmosException, ParserConfigurationException, WSDLException, IOException {		
	    
	    int arity = tpl.getArity();
	    
	    if(arity !=3 && arity != 4)
		throw new AmosException("Bad arguments");
	    Funstmts = new Vector<FunStmt>();
	    //get the Vector of functions
	    //Tuple vf = new Tuple(tpl.getOidElem(0));
	    Tuple vf = tpl.getSeqElem(0);
	    //get the output file name
	    String fileName = tpl.getStringElem(1);	
	    	
	    if (arity ==4){
		ServiceName = tpl.getStringElem(2);
		Host = tpl.getStringElem(3);
	    }
	    else {
		ServiceName = tpl.getStringElem(2);	
	    }
	    
	    Connection theConnection = null;
	    theConnection = new Connection("");
	
	    
	    for(int i = 0; i<vf.getArity(); i++){
	
		Oid fun = vf.getOidElem(i);			
		Tuple t =  new Tuple(1);
		t.setElem(0, fun);
		//get the signature of function
		

		Scan theScan = theConnection.callFunction("resolvents",t);
		String signature = fun.getName();
		String funName = null;
	
		int seperator = signature.indexOf("->");
		if(seperator >0){
		    String tmp = signature.substring(0, seperator);
		    funName = tmp.substring(tmp.lastIndexOf(".")+1);
		}
		else{
		    funName = signature;
		}
	
		int index = getMaxIndex(funName);
	
		while(!theScan.eos()){ 
		    Oid theFun = theScan.getRow().getOidElem(0);
		    Tuple arg = new Tuple(1);
		    arg.setElem(0, theFun);
		    try {
			FunStmt fs = new FunStmt(theFun);
			if(fs.setIndex(index))
			    index++;
			Funstmts.add(fs);
		    }
		    catch(AmosException e){
			if(e.getMessage().contains("Empty scan")){
			    System.out.println(" The function ("+theFun.toAmosString()+") can not be exported");
			}
			else
			    throw e;				
		    }
		    theScan.nextRow();
		}
	    }
	    
	    if(Funstmts.isEmpty() == false){
		//		    try{
		genWSDL();
		RegAmosII("");
		writeWSDL(fileName);
		cxt.emit(tpl);
		//		    }catch(Exception e){
		//			throw new AmosException(e.getMessage());
		//		    }
	    }
	   
		
	}
	
	protected int getMaxIndex(String funname){
//	    System.out.println("funName: " + funname);
	    int index = -1;
	    int i = Funstmts.size();
	    for( int j = 0; j < i; j++){
		FunStmt fs = Funstmts.get(j);
//		System.out.println("\t funName in Vector: "+fs.getFunName());
		if((fs.getFunName().equalsIgnoreCase(funname))&& (index < fs.getFunIndex())){
		    index = fs.getFunIndex();
		}
	    }
	    if(index == -1)
		return 0;
	    else
		return index+1;
	}
	
	/*
	public static void main(String arg[]){
		WSDLGenerator fg = new WSDLGenerator();
		try {
			fg.FileReader("c:\\Project\\Test\\webamos.osql");
			fg.genWSDL();
			try {
//				 if it is not call-out, should initialize Amos
				Connection.initializeAmos("a.dmp");
				fg.RegAmosII("");
			} catch (AmosException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				System.exit(-1);
			}
			fg.writeWSDL("test.wsdl");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			System.exit(-1);
		}
	}*/
}
