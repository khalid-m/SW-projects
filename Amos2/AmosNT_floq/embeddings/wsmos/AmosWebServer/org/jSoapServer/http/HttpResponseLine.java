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
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/jSoapServer/http/HttpResponseLine.java,v $
 * $Author: felu3873 $
 * $Date: 2007/01/29 10:15:08 $
 * $Revision: 1.1 $
 * ======================================================================= */

package org.jSoapServer.http;

public class HttpResponseLine {
    public static final int STATUS_503_Service_Unavailable = 503;
    
    private int statusCode;
    private String statusText;
    private String httpVersion;
    
    public HttpResponseLine(int statusCode, String statusText, String httpVersion) {        
        this.statusCode = statusCode;
        this.statusText = (statusText==null)?"":statusText;
        this.httpVersion = (httpVersion==null)?"HTTP/1.0":httpVersion;
    }
    
    
    public String toString() {
        StringBuffer buf = new StringBuffer();
        
            buf.append(this.httpVersion)
               .append(' ')
               .append(this.statusCode)
               .append(' ')
               .append(this.statusText)
               .append("\r\n");
        
        return buf.toString();
    }
    
    public byte[] getBytes() {
        return this.toString().getBytes();        
    }
}
