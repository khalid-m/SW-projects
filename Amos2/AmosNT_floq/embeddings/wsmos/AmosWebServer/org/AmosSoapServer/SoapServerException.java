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
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/AmosSoapServer/SoapServerException.java,v $
 * $Author: felu3873 $
 * $Date: 2007/01/29 10:12:59 $
 * $Revision: 1.1 $
 * ======================================================================= */

package org.AmosSoapServer;

/**
 * @author sabrinapainhaupt
 *
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class SoapServerException extends Exception
{
    public int httpStatusCode = 501;
    public String httpStatusText = "Internal Error";
    
	/**
	 * 
	 */
	public SoapServerException() {
		super();
	}

	/**
	 * @param errorMsg
	 */
	public SoapServerException(String errorMsg) {
		super(errorMsg);
	}
    
    public SoapServerException(String errorMsg,int httpStatusCode, String httpStatusText) {
        super(errorMsg);
        this.setHttpStatus(httpStatusCode, httpStatusText);
    }    

	/**
	 * @param errorMsg
	 * @param cause
	 */
	public SoapServerException(String errorMsg, Throwable cause) {
		super(errorMsg, cause);
	}

	/**
	 * @param cause
	 */
	public SoapServerException(Throwable cause) {
		super(cause);
	}
    
    /**
     * 
     * @param httpStatusCode
     * @param httpStatusText
     */
    public void setHttpStatus(int httpStatusCode, String httpStatusText) {
        this.httpStatusCode = httpStatusCode;
        this.httpStatusText = (httpStatusText != null)?httpStatusText:"Unknown Error";
        
    }

}
