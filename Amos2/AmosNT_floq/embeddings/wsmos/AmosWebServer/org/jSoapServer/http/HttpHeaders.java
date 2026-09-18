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
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/jSoapServer/http/HttpHeaders.java,v $
 * $Author: felu3873 $
 * $Date: 2007/01/29 10:15:08 $
 * $Revision: 1.1 $
 * ======================================================================= */

package org.jSoapServer.http;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HeaderGroup;
import org.apache.commons.httpclient.HttpParser;

public class HttpHeaders extends HeaderGroup {

    /*
     * Some standard HTTP Headers
     */
    public static final String ACCEPT_ENCODING = "Accept-Encoding";
    public static final String KEEP_ALIVE = "Keep-Alive";
    public static final String PROXY_CONNECTION = "Proxy-Connection";
    public static final String TRANSFER_ENCODING = "Transfer-Encoding";
    public static final String CONNECTION = "Connection";
    public static final String CONTENT_LENGTH = "Content-Length";
    public static final String CONTENT_TYPE = "Content-Type";
    public static final String CONTENT_ENCODING = "Content-Encoding";
    public static final String HOST = "Host";
    public static final String SERVER = "Server";
    public static final String DATE = "Date";
    public static final String ALLOW = "Allow";
    public static final String X_POWERED_BY = "X-Powered-By";
    public static final String RETRY_AFTER = "Retry-After";
    
    /*
     * Constants for transfer encoding
     */
    public static final String TRANSFER_ENCODING_IDENTITY = "identity";
    public static final String TRANSFER_ENCODING_CHUNKED = "chunked";    
    
    /* 
     * Constants for content encoding
     */
    public static final String HTTP_CONTENT_ENCODING_GZIP = "gzip";
    public static final String HTTP_CONTENT_ENCODING_X_GZIP = "x-gzip";
    public static final String HTTP_CONTENT_ENCODING_COMPRESS = "compress";
    public static final String HTTP_CONTENT_ENCODING_X_COMPRESS = "x-compress";
    public static final String HTTP_CONTENT_ENCODING_DEFLATE = "deflate";
    public static final String HTTP_CONTENT_ENCODING_X_DEFLATE = "x-deflate";   
    public static final String HTTP_CONTENT_ENCODING_IDENTITY = "identity";
    
    public HttpHeaders() {
        super();
    }
    
    public HttpHeaders(Header[] headers)  {
        super();
        this.setHeaders(headers);
    }    
    
    /**
     * Returns the header value that belongs to the given header name
     * @param name the name of the http header
     * @return the header value or <code>null</code> if the header is not available
     */
    public String getHeader(String name) {
        Header header = getCondensedHeader(name);
        return (header == null) ? null : header.getValue();
    }    
    
    /**
     * Removes the http header with the given name from the header block
     * @param name the name of the http header that should be removed
     */
    public void removeHeader(String name) {
        if (this.containsHeader(name)) {
            Header[] headers = this.getHeaders(name);
            for (int i=0; i<headers.length; i++) {
                this.removeHeader(headers[i]);
            }
        }
    }
    
    /**
     * Adds a new header to the header block
     * @param name the name of the new header
     * @param value the value of the new header
     */
    public void addHeader(String name, String value) {
        // TODO: maybe we should create a condensed header here
        Header header = new Header(name,value);
        this.addHeader(header);
    }    
    
    /**
     * Sets the value of an already existing http header.
     * This function is a combination of {@link #removeHeader(String)}
     * and {@link #addHeader(String, String)}
     * @param name the name of the http header
     * @param value the new value of the http header
     */
    public void setHeader(String name, String value) {
        removeHeader(name);
        addHeader(name, value);
    }    
    
    /**
     * Sets the value of the http connection header.
     * @param keepAlive <code>true</code> will set the header value to <code>keep-alive</code>, 
     * <code>false</code> will set the header value to <code>close</code>
     */
    public void setKeepAlive(boolean keepAlive) {
        this.setHeader(CONNECTION, keepAlive ? "keep-alive":"close");
    }
    
    public boolean keepAlive(HttpRequestLine reqLine) {
        
        // getting the http version that is used by the client
        String httpVersion = reqLine.getVer();
        String httpMethod  = reqLine.getMethodName();
        
        Header connectionHeader = this.getFirstHeader(CONNECTION);
        Header proxyConnection = this.getFirstHeader(PROXY_CONNECTION);
        Header contentLength = this.getFirstHeader(CONTENT_LENGTH);

        // managing keep-alive: in HTTP/0.9 and HTTP/1.0 every connection is closed
        // afterwards. In HTTP/1.1 (and above, in the future?) connections are
        // persistent by default, but closed with the "Connection: close"
        // property.
        boolean persistent = !(httpVersion.equals(HttpRequestLine.HTTP_0_9) || httpVersion.equals(HttpRequestLine.HTTP_1_0));
                
        if (connectionHeader != null) {
            if (connectionHeader.getValue().toLowerCase().indexOf("close") != -1) {
                persistent = false;
            }
        } 
        if (proxyConnection != null) {
            if (proxyConnection.getValue().toLowerCase().indexOf("close") != -1) {
                persistent = false;
            }
        }  
        
        // if the request does not contain a content-length we have to close the connection
        // independently of the value of the connection header
        
        if (persistent && httpMethod.equals(HttpRequestLine.HTTP_METHOD_POST) && contentLength == null) persistent = false;
        return persistent;
    }        
    
    public long getContentLength() {
        // if chunked transfer encoding is used return -1 
        if (this.containsHeader(TRANSFER_ENCODING)) {
            if (this.getHeader(TRANSFER_ENCODING).equals("chunked")) {
                return -1;
            }
        }
        
        long bodyLength = -1;
        try {
            Header[] contentLength = getHeaders(CONTENT_LENGTH);
            if (contentLength.length == 1) {
                bodyLength = Long.parseLong(contentLength[0].getValue()); 
            }    
        } catch (Exception e) {
            // we ignore this and return a length of -1
        }
        return bodyLength;
    }    
    
    /**
     * TODO: handling of <code>Accept-Encoding: *</code>
     * 
     * @param encodingName
     * @return
     */
    public boolean acceptEncoding(String encodingName) {                
        String contentEncoding = this.getHeader(HttpHeaders.ACCEPT_ENCODING);
        if (contentEncoding == null || contentEncoding.length() == 0) return false;
        contentEncoding = contentEncoding.toLowerCase();
        
        if (encodingName.startsWith("x-")) {
            return contentEncoding.indexOf(encodingName.toLowerCase()) != -1 ||
                   contentEncoding.substring(2).indexOf(encodingName.toLowerCase()) != -1;
        }
        return contentEncoding.indexOf(encodingName.toLowerCase()) != -1 ||
               ("x-" + contentEncoding).indexOf(encodingName.toLowerCase()) != -1;
    }
    
    public String getContentEncoding() {
        String contentEncoding = this.getHeader(HttpHeaders.CONTENT_ENCODING);
        if (contentEncoding == null || 
            contentEncoding.length() == 0 || 
            contentEncoding.equalsIgnoreCase(HTTP_CONTENT_ENCODING_IDENTITY)
        ) return null;
        
        if (contentEncoding.equals(HTTP_CONTENT_ENCODING_X_GZIP)) return HTTP_CONTENT_ENCODING_GZIP;
        else if (contentEncoding.equals(HTTP_CONTENT_ENCODING_X_COMPRESS)) return HTTP_CONTENT_ENCODING_COMPRESS;
        else if (contentEncoding.equals(HTTP_CONTENT_ENCODING_X_DEFLATE)) return HTTP_CONTENT_ENCODING_DEFLATE;
        return contentEncoding;
    }
    
    public String getTransferEncoding() {
        String transferEncoding = this.getHeader(HttpHeaders.TRANSFER_ENCODING);
        if ((transferEncoding != null) && (transferEncoding.equals(HttpHeaders.TRANSFER_ENCODING_IDENTITY))) return null;
        return transferEncoding;
    }
    
    public String getContentType() {
        String headerValue = getHeader(CONTENT_TYPE);
        if (headerValue == null) return null;
        
        int idx = headerValue.indexOf(";");
        return (idx != -1) ? headerValue.substring(0,idx) : headerValue;
    }    
    
    public String getHost() {
        return getHeader(HOST);
    }    
    
    public static HttpHeaders readFrom(InputStream in) throws IOException {
        Header[] header = HttpParser.parseHeaders(in,"US-ASCII");
        
        HttpHeaders headers = new HttpHeaders(header);        
        return headers;
    }    
    
    public String toString() {
        StringBuffer buf = new StringBuffer();
        
        Header[] headers = getAllHeaders();   
        for (int i = 0; i < headers.length; i++) {
            String s = headers[i].toExternalForm();
            buf.append(s);
        } 
        buf.append("\r\n");
        
        return buf.toString();
    }
    
    public byte[] getBytes() {
        return this.toString().getBytes();        
    }    
}
