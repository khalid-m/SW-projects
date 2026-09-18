 package server;

import java.io.ByteArrayOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Scanner;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.soap.Detail;
import javax.xml.soap.DetailEntry;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeader;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFactory;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Tuple;

/**
 * A servlet that can be used to host a SAAJ
 * service within a web container. This is based
 * on ReceivingServlet.java in the JWSDP tutorial
 * examples.
 */
public abstract class SAAJServlet extends HttpServlet implements constants{
    
    /**
     * The factory used to build messages
     */
    protected MessageFactory messageFactory;
    public String DBname;
    public String appPath;
    
    /**
     * Initialisation - create the MessageFactory
     * @throws AmosException 
     */
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
	log("");
        try {
            messageFactory = MessageFactory.newInstance();
        } catch (SOAPException e) {
            e.printStackTrace();
            throw new ServletException("Failed to create MessageFactory", e);
        }

      
        try {
            appPath = config.getServletContext().getRealPath("");
            Connection.initializeAmos(appPath+"\\WEB-INF\\dummy.dmp");
	} catch (AmosException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	    throw new ServletException("Can not initialize the database, "+appPath+"\\WEB-INF\\dummy.dmp", e);	    
	}
	DBname = getInitParameter("DBname");
	if(DBname == null)
	    DBname = "WSMOS";
    }
    
    /**
     * Handles a POST request from a client. The request is assumed
     * to contain a SOAP message with the HTTP binding.
     */
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
                            throws ServletException, IOException {
                                
        try {                            
            // Get all the HTTP headers and convert them to a MimeHeaders object
            MimeHeaders mimeHeaders = getMIMEHeaders(request);
            // Create a SOAPMessage from the content of the HTTP request
            SOAPMessage message = messageFactory.createMessage(mimeHeaders,
                                                request.getInputStream());
            
            // Let the subclass handle the message
            SOAPMessage reply = null;
            try{
            	reply = onMessage(message);
            }catch(SOAPException e){
//            	response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            	reply = createFaultMessage(e);
            	e.printStackTrace();
            }catch(IOException e1){
            	response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            	e1.printStackTrace();
            }catch(AmosException e2){
        	reply = createFaultMessage(e2);
        	e2.printStackTrace();
//            	String errMsg = e2.getMessage();
            	/*if(errMsg.contains("SC_BAD_REQUEST")){
            		response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            	}
            	else
            		response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            	e2.printStackTrace();
            	*/
            }catch(Exception e3){
		
		reply = createFaultMessage(e3);
		e3.printStackTrace();	
	    }
            	
            // If there is a reply, return it to the sender.
            if (reply != null) {
                // Set OK HTTP status, unless there is a fault.
                boolean hasFault = reply.getSOAPPart().getEnvelope().getBody().hasFault();
//                response.setStatus(hasFault ? HttpServletResponse.SC_INTERNAL_SERVER_ERROR :HttpServletResponse.SC_OK);
                response.setStatus(HttpServletResponse.SC_OK);
                // Force generation of the MIME headers
                if (reply.saveRequired()) {
                    reply.saveChanges();
                }
                
                // Copy the MIME headers to the HTTP response
                setHttpHeaders(reply.getMimeHeaders(), response);
                
                response.setContentType("text/xml");
                // Send the completed message
                OutputStream os = response.getOutputStream();
                reply.writeTo(os);
                os.flush();
            }                
        } catch (SOAPException ex) {
            throw new ServletException("SOAPException: " + ex);
        }       
    }
    
    protected SOAPMessage createFaultMessage(Exception e){
	log("create fault message");
	SOAPMessage reply = null;
	try {
	    reply = messageFactory.createMessage();	
	    SOAPEnvelope envelope = reply.getSOAPPart().getEnvelope();
	    /** Handling the header of  reply SOAP message */
	    SOAPHeader header = envelope.getHeader();
	    header.detachNode();
			
	    envelope.addNamespaceDeclaration(SOAPENV_PREFIX, SOAPENV_URI);
	    SOAPBody body = envelope.getBody();
	    SOAPFault fault = body.addFault();
	    fault.setFaultCode("SOAP-ENV:Server");	    
	    fault.setFaultString(e.getClass().getName());
	    Detail detail = fault.addDetail();
	    SOAPFactory soapFactory = SOAPFactory.newInstance();	    
	    Name detailName = soapFactory.createName("FaultDetail", TNS_PREFIX, TNS_URI);
	    DetailEntry detailEntry = detail.addDetailEntry(detailName);
	    detailEntry.addTextNode(e.getMessage());
	    
	    ByteArrayOutputStream os = new ByteArrayOutputStream();
    	    reply.writeTo(os);    		
            log("Sending SOAP message:\n" + os.toString());
	} catch (SOAPException e1) {
	    // TODO Auto-generated catch block
	    e1.printStackTrace();
	    return null;
	} catch (Exception e2){
	    e2.printStackTrace();
	    return null;
	}
    	log("reply = "+reply);
	return reply;
    }
    
    
    
    /**
     * Method implemented by subclasses to handle a received SOAP message.
     * @param message the received SOAP message.
     * @return the reply message, or <code>null</code> if there is
     * no reply to be sent.
     * @throws IOException 
     * @throws AmosException 
     */
    protected abstract SOAPMessage onMessage(SOAPMessage message) throws SOAPException, IOException, AmosException;
    
    /**
     * Creates a MIMEHeaders object from the HTTP headers
     * received with a SOAP message.
     */
    private MimeHeaders getMIMEHeaders(HttpServletRequest request) {
        MimeHeaders mimeHeaders = new MimeHeaders();
        Enumeration enum1 = request.getHeaderNames();
        while (enum1.hasMoreElements()) {
            String headerName = (String)enum1.nextElement();
            String headerValue = request.getHeader(headerName);
//            log("Receiving: HeaderName:"+headerName+"    ; HeaderValue:"+headerValue);
            StringTokenizer st = new StringTokenizer(headerValue, ",");
            while (st.hasMoreTokens()) {
                mimeHeaders.addHeader(headerName, st.nextToken().trim());
            }
        }
        return mimeHeaders;
    } 
    
    /**
     * Converts the MIMEHeaders for a SOAP message to 
     * HTTP headers in the response.
     */
    private void setHttpHeaders(MimeHeaders mimeHeaders, HttpServletResponse response) {
  
        Iterator iter = mimeHeaders.getAllHeaders();
        while (iter.hasNext()) {
          	log("setHttpHeaders  dsds");
            MimeHeader mimeHeader = (MimeHeader)iter.next();
            String headerName = mimeHeader.getName();
            String[] headerValues = mimeHeaders.getHeader(headerName);
            
            int count = headerValues.length;
            StringBuffer buffer = new StringBuffer();
            for (int i = 0; i < count; i++) {
                if (i != 0) {
                    buffer.append(',');
                }
                buffer.append(headerValues[i]);
            }
//            log("Sending: HeaderName:"+headerName+"    ; HeaderValue:"+buffer.toString());
            response.setHeader(headerName, buffer.toString());
        }        
    }
    
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
	char cbuf[] = new char[100];
	int intLength;
	StringBuffer sb = new StringBuffer();
	String filename=null;
	response.setContentType("text/html");
	PrintWriter out = response.getWriter();

	out.println("<HTML>");
	out.println("<HEAD><TITLE>Hello World</TITLE></HEAD>");
	out.println("<BODY>");
	out.println("<h1>Generate WSDL file</h1><br>");    
	String fns = request.getParameter("fns");
	log("fns:"+fns);
	if(fns==""||fns==null){
	    out.println("<BIG> Error: </BIG><br>");
	    out.println("<BIG> Please enter one function at least.</BIG><br>");
	    out.println("<a href=\"/wsmos/\">back</a>");
	    out.println("</BODY></HTML>");
	    return;
	}
	
	
	
	Vector<Oid> vector = new Vector<Oid>();
	Connection theConnection = null;
	AmosII amos = new AmosII();
	try{
	    theConnection = amos.buildConnection(DBname);
	}catch(AmosException ae){
	    out.println("Can not connect to database,"+DBname+".");
	    out.println("<a href=\"/wsmos/\">back</a>");
	    out.println("</BODY></HTML>");
	    return;
	}
	
	Scanner s = new Scanner(fns).useDelimiter(",");
	while(s.hasNext()){
	   String fn = s.next().trim();	   
	   try{
	       Oid oid= theConnection.callFunction("Functionnamed",new Tuple(fn)).getRow().getOidElem(0);
	       vector.add(oid);
	   }catch(AmosException ae){
	       out.println("Can not get the Function, " + fn + ", in database.");
//	       out.println("<a href=\"/wsmos/\">back</a>");
//	       out.println("</BODY></HTML>");
	   }	   
	}
	
	int arity = vector.size();
	Tuple fs = new Tuple(arity);
	try{
	    for(int i=0; i<arity;i++){
		fs.setElem(i, vector.get(i));
	    }
	    Tuple tpl = new Tuple(2);
	   
	    tpl.setElem(0, fs);
	    HttpSession hs = request.getSession();
	    filename =  hs.getId()+".wsdl";
	    tpl.setElem(1, appPath + "\\wsdl\\"+filename);
	    boolean b = theConnection.callFunction("generate_wsdl", tpl).getRow().getBooleanElem(0);
	    if(!b){
		out.println("Some Error occurs when generating WSDL file.");
		out.println("<a href=\"/wsmos/\">back</a>");
		out.println("</BODY></HTML>");
		return;
	    }
	}catch(AmosException e){
	    out.println("Some Error occurs when generating WSDL file.");
		out.println("<a href=\"/wsmos/\">back</a>");
		out.println("</BODY></HTML>");
		return;
	}
	
	FileReader reader = new FileReader(appPath + "\\wsdl\\"+filename);
	while((intLength=reader.read(cbuf))!=-1){
	   sb.append(cbuf, 0, intLength);
	}
	String body= sb.toString();
//	log("BODY = ["+body+"].");
	out.println("<br><textarea rows=\"25\" cols=\"80\" wrap =\"off\" style=\"overflow-x:auto;overflow-y:auto;background-color:99FFFF\">");
	out.println(body);
	out.println("</textarea>");
	out.println("<br>");
	InetAddress localHost = InetAddress.getLocalHost();
	String ip = localHost.getHostAddress();
	out.println("<a href=\"http://"+ip+":8080/wsmos/wsdl/"+filename+"\">open the wsdl file in a new window</a>");
	out.println("</BODY></HTML>");

    }
}
