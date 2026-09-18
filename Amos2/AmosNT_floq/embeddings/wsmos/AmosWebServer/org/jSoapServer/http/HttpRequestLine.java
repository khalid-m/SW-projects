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
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/jSoapServer/http/HttpRequestLine.java,v $
 * $Author: msabesan $
 * $Date: 2009/08/22 14:05:48 $
 * $Revision: 1.2 $
 * ======================================================================= */

package org.jSoapServer.http;

import java.io.IOException;
import java.io.InputStream;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.httpclient.HttpParser;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.util.ParameterParser;

public class HttpRequestLine {
    /* ============================================================
     * CONSTANT definitions
     * ============================================================ */
    private static final int HTTP_REQUEST_METHOD = 0;
    private static final int HTTP_REQUEST_URI = 1;    
    private static final int HTTP_REQUEST_VERSION = 2;    
    
    /*
     * Constants for http request methods
     */
    public static final String HTTP_METHOD_GET = "GET";
    public static final String HTTP_METHOD_HEAD = "HEAD";
    public static final String HTTP_METHOD_POST = "POST";
    
    /*
     * Constants for http protocol versions
     */
    public static final String HTTP_0_9 = "HTTP/0.9";
    public static final String HTTP_1_0 = "HTTP/1.0";
    public static final String HTTP_1_1 = "HTTP/1.1";    
    
    /*
     * Other object fields
     */
    private String reqMethod = null;
    private String reqUrl = null;
    private String reqVer = null;
    private List reqParams = null;
    private String reqPath = null;
    
    public HttpRequestLine(String reqMethod, String url, String httpVersion) {
        if (reqMethod == null) throw new NullPointerException();
        this.reqMethod = reqMethod;    
        if (url == null || url.length() == 0) url = "/";
        this.reqUrl = url;
        
        // parsing the request parameters using
        int pos = url.indexOf("?");
        if (pos != -1) {
            ParameterParser parser = new ParameterParser();
            this.reqParams = parser.parse(this.reqUrl.substring(pos+1), '&');
            this.reqPath = this.reqUrl.substring(0,pos);
        } else {
            this.reqPath = this.reqUrl;
        }
        
        if (httpVersion == null) httpVersion = "HTTP/1.0";
        this.reqVer = httpVersion;
    }    
    
    public String getMethodName() {
        return this.reqMethod;
    }
    
    public String getUrl() {
        return this.reqUrl;
    }
    
    public String getVer() {
        return this.reqVer;
    }    
    
    public String getPath() {
        return this.reqPath;
    }
    
    public List getParams() {
        return this.reqParams;
    }
    
    public boolean hasParam(String paramName) {
        if (this.reqParams == null) return false;
        if (paramName == null) return false;
        
        Iterator iter = this.reqParams.iterator();
        while (iter.hasNext()) {
            NameValuePair nextParam = (NameValuePair) iter.next();
            if (nextParam.getName().equals(paramName)) return true;
        }
        return false;
    }
    
    public String getParamValue(String paramName) {
        if (this.reqParams == null) return null;
        if (paramName == null) return null;
        
        Iterator iter = this.reqParams.iterator();
        while (iter.hasNext()) {
            NameValuePair nextParam = (NameValuePair) iter.next();
            if (nextParam.getName().equals(paramName)) return nextParam.getValue();
        }
        return null;        
    }
    
    public int getParamCount() {
        return (this.reqParams == null) ? 0 : this.reqParams.size();
    }
    
    public static HttpRequestLine readFrom(InputStream in) throws IOException {
        /* 
         * Splitting the http request line into
         * - http request method
         * - request uri
         * - http version
         */
        //TODO: support of URI containing spaces
        String command = HttpParser.readLine(in, "US-ASCII");
        String[] commandLineToken = command.split(" ");        
        if (commandLineToken.length != 3) {
            throw new HttpException("Bad Request",400,"Bad Request");
        } else if (!(
                    commandLineToken[HTTP_REQUEST_METHOD].equals(HTTP_METHOD_GET) ||
                    commandLineToken[HTTP_REQUEST_METHOD].equals(HTTP_METHOD_HEAD) ||
                    commandLineToken[HTTP_REQUEST_METHOD].equals(HTTP_METHOD_POST)
        )) {
            throw new HttpException("Bad Request",400,"Bad Request");
        }
        else if (!(
                commandLineToken[HTTP_REQUEST_VERSION].equals(HTTP_0_9) ||
                commandLineToken[HTTP_REQUEST_VERSION].equals(HTTP_1_0) || 
                commandLineToken[HTTP_REQUEST_VERSION].equals(HTTP_1_1)
        )) {
            throw new HttpException("Bad Request",400,"Bad Request");           
        }

        return new HttpRequestLine(
                commandLineToken[HTTP_REQUEST_METHOD],
                commandLineToken[HTTP_REQUEST_URI],
                commandLineToken[HTTP_REQUEST_VERSION]
        );        
    }    
}
