/*
 *  jSoapServer is a Java library implementing a multi-threaded
 *  soap server which can be easily integrated into java applications
 *  to provide a SOAP Interface for external programmers.
 *  
 *  Copyright (C) 2006 Martin Thelian
 *  
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *  
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *  
 *  For more information, please email thelian@users.sourceforge.net
 */

/* =======================================================================
 * Revision Control Information
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/AmosSoapServer/AmosSoapHandler.java,v $
 * $Author: msabesan $
 * $Date: 2009/09/03 09:57:31 $
 * $Revision: 1.6 $
 * ======================================================================= */

package org.AmosSoapServer;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PushbackInputStream;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.util.zip.InflaterInputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;



import javax.xml.soap.Detail;
import javax.xml.soap.DetailEntry;
import javax.xml.soap.MessageFactory;

import javax.xml.soap.MimeHeaders;
import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFactory;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPMessage;

import org.apache.axis.transport.http.ChunkedInputStream;

import org.apache.commons.httpclient.ContentLengthInputStream;
import org.apache.commons.httpclient.Header;
import org.jSoapServer.http.HttpHeaders;
import org.jSoapServer.http.HttpRequestLine;
import org.jSoapServer.http.HttpResponseLine;
import org.jSoapServer.utils.FileUtils;
import org.quickserver.net.server.ClientBinaryHandler;
import org.quickserver.net.server.ClientEventHandler;
import org.quickserver.net.server.ClientExtendedEventHandler;
import org.quickserver.net.server.ClientHandler;
import org.quickserver.net.server.DataMode;
import org.quickserver.net.server.DataType;

import callin.AmosException;

/**
 * 
 * <b>Hint:</b> If you are using jSoapServer without the xml configuration file,
 * ensure that you have registered this class using the following commands
 * 
 * <code>
 *  mySoapServer.setClientBinaryHandler("org.jSoapServer.SoapHandler");
 *  mySoapServer.setClientEventHandler("org.jSoapServer.SoapHandler");
 * </code>
 * 
 * @author Martin Thelian
 * @version 0.2.7
 */
public abstract class AmosSoapHandler implements ClientEventHandler, ClientBinaryHandler, ClientExtendedEventHandler,constants {
        
    /*
     * Constants for http headers
     */
    public static final String HTTP_HEADER_SOAPACTION = "soapaction";
    
    protected MessageFactory messageFactory;

    
    /* ============================================================
     * Other object fields
     * ============================================================ */    
    /**
     * The logger class that is used by the command handler 
     */
    protected static Logger logger = Logger.getLogger("AmosSoapServer.log");
    
    /**
     * The apache axis server engine that is used to process the received soap request messages
     * and to generate soap response messages that will be send back as execution results
     */
//    private AxisServer engine = null;
    
    protected PushbackInputStream inputStream = null;
    

    /**
     * @see ClientExtendedEventHandler#handleMaxAuthTry(ClientHandler)
     */
    public void handleMaxAuthTry(ClientHandler handler) throws IOException {
        // TODO Auto-generated method stub
        
    }

    /**
     * @see ClientExtendedEventHandler#handleMaxConnection(ClientHandler)
     * @since 0.2.8
     */
    public boolean handleMaxConnection(ClientHandler handler) throws IOException {
        // create the response line
        HttpResponseLine respLine = new HttpResponseLine(
                HttpResponseLine.STATUS_503_Service_Unavailable,
                "Service Unavailable",
                HttpRequestLine.HTTP_1_0
        );
        
        // create the response header
        String respBody = handler.getMaxConnectionMsg();        
        HttpHeaders respHeaders = getResponseHeaders(
                handler, 
                "text/plain; charset=UTF-8", 
                false, 
                null, 
                respBody.length()
        );
        
        // add the retry after header
        // retry it in 30 seconds
        respHeaders.addHeader(HttpHeaders.RETRY_AFTER, "30");
        
        // write out data
        OutputStream out = handler.getOutputStream();
        out.write(respLine.getBytes());
        out.write(respHeaders.getBytes());
        out.write(respBody.getBytes("UTF-8"));
        out.flush();
        
        // close the connection
        handler.closeConnection();
        
        return false;
    }


    /**
     * @see ClientExtendedEventHandler#handleTimeout(ClientHandler)
     */
    public void handleTimeout(ClientHandler handler) throws SocketException, IOException {
        // TODO Auto-generated method stub
        
    }       
    
    
    /**
     * @param handler
     * @throws SocketTimeoutException
     * @throws IOException
     * 
     * @see org.quickserver.net.server.ClientCommandHandler#gotConnected(org.quickserver.net.server.ClientHandler)
     */
    public void gotConnected(ClientHandler handler) throws SocketTimeoutException, IOException {
        assert (handler != null) : "Clienthandler object must not be null";
        
        handler.setDataMode(DataMode.BINARY, DataType.IN);
        handler.setDataMode(DataMode.BINARY, DataType.OUT);
        
        if (logger.isLoggable(Level.FINE))
            logger.fine("Connection opened : " + handler.getSocket().getInetAddress().getHostName());
    }
    
    
    /**
     * @param handler
     * @throws IOException
     * 
     * @see org.quickserver.net.server.ClientCommandHandler#lostConnection(org.quickserver.net.server.ClientHandler)
     */
    public void lostConnection(ClientHandler handler) throws IOException {
        assert (handler != null) : "Clienthandler object must not be null";
        
        if (logger.isLoggable(Level.FINE))
            logger.fine("Connection lost : " + handler.getSocket().getInetAddress().getHostName());
    }
    
    
    /**
     * @param handler
     * @throws IOException
     * 
     * @see org.quickserver.net.server.ClientCommandHandler#closingConnection(org.quickserver.net.server.ClientHandler)
     */
    public void closingConnection(ClientHandler handler) throws IOException {
        assert (handler != null) : "Clienthandler object must not be null";
        
        handler.sendSystemMsg("Connection closed: "+
                handler.getSocket().getInetAddress().getHostName(), Level.FINE);
    }
    
    /**
     * 
     * @param handler
     * @param httpContentType
     * @param keepAlive
     * @param httpContentEncoding
     * @param httpContentLength
     * @return
     * @since 0.2.8
     */
    protected HttpHeaders getResponseHeaders(
            ClientHandler handler,
            String httpContentType,
            boolean keepAlive,
            String httpContentEncoding,
            long httpContentLength
    ) {
        HttpHeaders headers = new HttpHeaders();
       
        headers.addHeader(HttpHeaders.SERVER, handler.getServer().getName()); 
        headers.addHeader(HttpHeaders.DATE,(new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", Locale.US)).format(new Date()));        
        headers.addHeader(HttpHeaders.CONNECTION,keepAlive?"keep-alive":"close");
        headers.addHeader(HttpHeaders.ALLOW,"GET, POST");
        headers.addHeader(HttpHeaders.X_POWERED_BY,"jSoapServer " + "version 0.1");
        headers.addHeader(HttpHeaders.CONTENT_TYPE,httpContentType);
        
        if (httpContentLength > 0) 
            headers.addHeader(HttpHeaders.CONTENT_LENGTH,Long.toString(httpContentLength));
        if (httpContentEncoding != null)
            headers.addHeader(HttpHeaders.CONTENT_ENCODING,httpContentEncoding);
        
        // TODO:
        
        return headers;
    }
    
    /**
     * @param handler
     * @param httpStatusCode
     * @param httpStatusText
     * @param httpContentType
     * @param httpBody
     * @param supportsGzip
     * @throws IOException
     */
    public void sendResponse(
            ClientHandler handler, 
            int httpStatusCode, 
            String httpStatusText,
            String httpContentType,
            byte[] httpBody) 
    throws IOException 
    {
        assert (handler != null) 		 : "Clienthandler object must not be null";
        assert (httpStatusCode > 100) 	 : "Invalid http status code";
        assert (httpStatusText  != null) : "Invalid http status text";
        assert (httpContentType != null) : "Invalid http content type";
        
        
        // getting a handler to the client data object
        SoapData data= (SoapData) handler.getClientData();
                   
        // determine if keep alive should be used
       
        boolean keepAliveEnabled = true;
        boolean keepAliveRequested = data.httpHeaders.keepAlive(data.httpReqLine);
        
        boolean connectionKeepAlive = keepAliveEnabled && keepAliveRequested;
        String contentEncoding = null;
        int contentLength = (httpBody == null)? 0:httpBody.length;
        byte[] contentBody = httpBody;
        
        // if we should use content encoding, we now have to encode the body yet
        String acceptEncoding = data.httpHeaders.getHeader(HttpHeaders.ACCEPT_ENCODING);
        if (acceptEncoding != null && httpBody != null) {               
            OutputStream compressedOut = null;            
            ByteArrayOutputStream byteArray = new ByteArrayOutputStream(contentLength);
            
            if (data.httpHeaders.acceptEncoding(HttpHeaders.HTTP_CONTENT_ENCODING_GZIP)) {
                compressedOut = new GZIPOutputStream(byteArray);
                contentEncoding = HttpHeaders.HTTP_CONTENT_ENCODING_GZIP;
            } else if (data.httpHeaders.acceptEncoding(HttpHeaders.HTTP_CONTENT_ENCODING_COMPRESS)) {
                compressedOut = new ZipOutputStream(byteArray);
                ((ZipOutputStream)compressedOut).putNextEntry(new ZipEntry("compressed output"));
                contentEncoding = HttpHeaders.HTTP_CONTENT_ENCODING_COMPRESS;                
            } else {
                acceptEncoding = null;
                compressedOut = byteArray;
            }

            compressedOut.write(httpBody);
            compressedOut.flush();
            compressedOut.close();

            // getting the new content length
            contentLength = byteArray.size();
            
            // getting the compressed body
            contentBody = byteArray.toByteArray();
        }
        
        // create the response line
        HttpResponseLine responseLine = new HttpResponseLine(
                httpStatusCode,
                httpStatusText,
                HttpRequestLine.HTTP_1_0
        );        
        
        // creating the response http headers
        HttpHeaders responseHeaders = getResponseHeaders(
                handler, 
                httpContentType, 
                connectionKeepAlive, 
                contentEncoding, 
                contentLength
        );
        
        // write out the data
        OutputStream out = handler.getOutputStream();
        out.write(responseLine.getBytes());
        out.write(responseHeaders.getBytes());
        out.write(contentBody);
        out.flush();        
        
        // close the connection if necessary
        if (!connectionKeepAlive) {
            handler.closeConnection();
        }    
    }
    
    /**
     * 
     * @param handler
     * @param command
     * @param data
     * @throws IOException
     * 
     * @since 0.25
     */
    protected void readHttpHeader(SoapData data) throws IOException  {
        
        // reading the http headers
        data.httpHeaders = HttpHeaders.readFrom(this.inputStream);   	
    }
    
    /**
     * 
     * @param handler
     * @param command
     * @param data
     * @return
     * @throws IOException 
     * @throws IOException
     * 
     * @since 0.25
     */
    protected void readHttpCommandLine(SoapData data) throws SoapServerException, IOException  {
                
        // reading the request line
        data.httpReqLine = HttpRequestLine.readFrom(this.inputStream);
        
        // getting the soap service name
        String reqPath = data.httpReqLine.getPath();
        if (reqPath.startsWith("/")) reqPath = reqPath.substring(1);
        data.serviceName = reqPath;
        
    }
    
    /**
     * @param handler
     * @param data
     * @since 0.2.5
     */
    protected void processHttpHeader(ClientHandler handler, SoapData data) {       
        try {   
            String keepAliveTimeoutStr = data.httpHeaders.getHeader(HttpHeaders.KEEP_ALIVE);
            if (keepAliveTimeoutStr != null) {
                try {
                    long keepAliveTimeout = Long.valueOf(keepAliveTimeoutStr).longValue();
                    handler.getSocket().setSoTimeout((int)keepAliveTimeout*1000);
                    return;
                } catch (NumberFormatException numEx) { 
                    /* timeout value could not be parsed */
                }
            }
            handler.getSocket().setSoTimeout(300*1000);
        } catch (SocketException e) {
            /* ignore this error */
        }
    }
    

    
    /**
     * @param data
     * @throws IOException
     * 
     * @since 0.2.5
     * @since 0.2.8 : support for transfer and content encoded request bodies
     */
    protected void readHttpBody(SoapData data) throws SoapServerException {
        if (data.httpReqLine.getMethodName().equals(HttpRequestLine.HTTP_METHOD_GET)) return;
        
        InputStream body = null;
        try {
            // getting the content length
            long contentLength = data.httpHeaders.getContentLength();
            
            /* =====================================================================
             * Handling of TRANSFER-ENCODING
             * ===================================================================== */
            String transferEncoding = data.httpHeaders.getTransferEncoding();
            
            if (transferEncoding != null) {
                // read the body using transfer encoding
                transferEncoding = transferEncoding.toLowerCase().trim();
                if (transferEncoding.equals(HttpHeaders.TRANSFER_ENCODING_CHUNKED)) {
                    body = new ChunkedInputStream(this.inputStream);
                } else {                    
                    logger.warning("Unsupported transfer-encoding: "+ transferEncoding);
                    throw new SoapServerException("Unsupported transfer-encoding: " + transferEncoding,501,"Unimplemented");
                }
            } else if (contentLength > 0) {
                // read exactly content length bytes
                body = new ContentLengthInputStream(this.inputStream, contentLength);
            } else {
                // read until EOF
                body = this.inputStream;
            }       
            
            /* =====================================================================
             * Handling of CONTENT-ENCODING
             * ===================================================================== */
            String contentEncoding = data.httpHeaders.getContentEncoding();
            if (contentEncoding != null) {
                if (contentEncoding.equals(HttpHeaders.HTTP_CONTENT_ENCODING_GZIP)) {
                    body = new GZIPInputStream(body);
                } else if (contentEncoding.equals(HttpHeaders.HTTP_CONTENT_ENCODING_COMPRESS)) {
                    ZipInputStream zipIn = new ZipInputStream(body);
                    long entrySize = zipIn.getNextEntry().getSize();
                    if (entrySize == -1) {
                        body = zipIn;
                    } else {
                        body = new ContentLengthInputStream(zipIn,entrySize);
                    }
                } else if (contentEncoding.equals(HttpHeaders.HTTP_CONTENT_ENCODING_DEFLATE)) {
                    body = new InflaterInputStream(body);                    
                } else {
                    throw new SoapServerException("Unsupported content encoding: " + contentEncoding,415,"Unsupported Media Type");
                }
            }
            
            /* =====================================================================
             * READ THE BODY
             * ===================================================================== */
            if (body != null) {
                FileUtils.copy(body, data.httpBody);                       
            }            
        } catch (IOException e) {
            throw new SoapServerException("Unable to read the request body",400,"Bad Request"); 
        }
    }
    
    public void handleBinary(ClientHandler handler, byte[] command) throws SocketTimeoutException, IOException{

        assert (handler != null) : "The commandhandler object must not be null";
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String currentDate = sdf.format(new Date());
        String newName = "./log/AmosSoapServer.log."+currentDate;
        String oldName = AmosSoapServer.getLogName();
        if(!newName.equals(oldName)){
            Handler handlers[] = logger.getHandlers();
            for(int i=0;i<handlers.length;i++)
        	logger.removeHandler(handlers[i]);
            
            boolean append = true;
            FileHandler txtLog = new FileHandler(newName,append);
            txtLog.setFormatter(new SimpleFormatter());
            logger.addHandler(txtLog);
        }
            

        
        try{
        this.inputStream = new PushbackInputStream(handler.getInputStream(),Math.max(512,command.length));
        this.inputStream.unread(command);

        // getting a handler to the client data object
        SoapData data= (SoapData) handler.getClientData();

        // reseting the data object
        data.clean();

        // reading the http request line send by the client
        readHttpCommandLine(data);

        // reading the http headers send by the client
        readHttpHeader(data);
//            processHttpHeader(handler,data);

        // reading the http body send by the client
        readHttpBody(data);
        
        // generating the soap message context
//            MessageContext msgContext = null;
        
        // generate the message context object
//            msgContext = this.generateMessageContext(handler,data);
        
        
        if (data.httpReqLine.getMethodName().equals(HttpRequestLine.HTTP_METHOD_GET)) {
    	 this.sendResponse(handler,400, "Internal Server Error", "text/plain; charset=UTF-8", "Do not support Get method".getBytes("UTF-8"));
             return;
        }
     
        /*
         * Generating a SOAP Request Message Object from the XML document
         * and store it into the message context
         */
        
        Iterator i = data.httpHeaders.getIterator();
        MimeHeaders mimeHeaders = new MimeHeaders();
        while(i.hasNext()){
    	Header header = (Header) i.next();
    	mimeHeaders.addHeader(header.getName(), header.getValue());
        }
        
        /*i = mimeHeaders.getAllHeaders();
        while(i.hasNext()){
    	MimeHeader header = (MimeHeader) i.next();
    	System.out.println("name="+header.getName()+", value="+header.getValue());
        }*/
        messageFactory = MessageFactory.newInstance();
        SOAPMessage message = messageFactory.createMessage(mimeHeaders,
    	    new ByteArrayInputStream(data.httpBody.toByteArray()));
        SOAPMessage reply = null;

	/* busy waiting until the lock released */
        while (AmosSoapServer.getLock()){
            Thread.currentThread().sleep(1000);
	    //System.out.println("waiting");
            }
        /* Set lock*/
        AmosSoapServer.setLock();       

        try{
	    //System.out.println("message>>");
        	reply = onMessage(message);
        }catch(Exception e){	
	    System.out.println("###########Exception#############");	
	reply = createFaultMessage(e);
	e.printStackTrace();	
        }

        if (reply != null) {
            if (reply.saveRequired()) {
                reply.saveChanges();
            }
            ByteArrayOutputStream theWriter = new ByteArrayOutputStream(); 
            reply.writeTo(theWriter);
	    /*release lock*/
	    AmosSoapServer.releaseLock();
            AmosSoapServer.releaseUser();   
            // send back the result
            this.sendResponse(handler, 200, "OK", "text/xml; charset=utf-8", theWriter.toByteArray());
           
            return;                              
        }
	/*release lock*/
        AmosSoapServer.releaseLock();
        AmosSoapServer.releaseUser();
        this.sendResponse(handler,500, "Internal Server Error", "text/plain; charset=UTF-8","Unable to invoke the service".getBytes("UTF-8"));
        return;
        }
        catch(Exception e){
            	/*release lock*/
               AmosSoapServer.releaseLock();
               AmosSoapServer.releaseUser();
            this.sendResponse(handler,500, "Internal Server Error", "text/plain; charset=UTF-8","Unable to invoke the service".getBytes("UTF-8"));
        }
    }
    
    protected abstract SOAPMessage onMessage(SOAPMessage message) throws SOAPException, IOException, AmosException;
    
    protected SOAPMessage createFaultMessage(Exception e){
//	log("create fault message");
	SOAPMessage reply = null;
	try {
	    reply = messageFactory.createMessage();	
	    javax.xml.soap.SOAPEnvelope envelope = reply.getSOAPPart().getEnvelope();
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
//            log("Sending SOAP message:\n" + os.toString());
	} catch (SOAPException e1) {
	    // TODO Auto-generated catch block
	    e1.printStackTrace();
	    return null;
	} catch (Exception e2){
	    e2.printStackTrace();
	    return null;
	}
//    	log("reply = "+reply);
	return reply;
    }
}
