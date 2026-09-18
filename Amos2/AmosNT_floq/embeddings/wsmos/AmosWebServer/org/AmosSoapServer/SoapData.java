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
 * $Source: /it/project/fo/udbl/CVSRoot/AmosNT/embeddings/wsmos/AmosWebServer/org/AmosSoapServer/SoapData.java,v $
 * $Author: felu3873 $
 * $Date: 2007/01/29 10:12:59 $
 * $Revision: 1.1 $
 * ======================================================================= */

package org.AmosSoapServer;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;

import org.apache.commons.pool.BasePoolableObjectFactory;
import org.apache.commons.pool.PoolableObjectFactory;
import org.jSoapServer.http.HttpHeaders;
import org.jSoapServer.http.HttpRequestLine;
import org.quickserver.net.server.ClientData;
import org.quickserver.util.pool.PoolableObject;

/**
 * @author Martin Thelian
 * @see org.quickserver.net.server.ClientData
 * @see org.quickserver.util.pool.PoolableObject
 */
public class SoapData implements ClientData, PoolableObject {
 
    
    /**
     * The http request line received by the client
     */
    public HttpRequestLine httpReqLine = null;   
    
    /**
     * The name of the soap service that should be invoked
     */
    public String serviceName = null;
    
    /**
     * A {@link HashMap} containing all http headers that were received
     * by the client
     * TODO: use case-insensitive comparator to avoid problems with incorrect 
     *       written headers
     */
    public HttpHeaders httpHeaders = null;
    
    /**
     * A {@link ByteArrayOutputStream} containing the received soap message
     */
    public ByteArrayOutputStream httpBody = new ByteArrayOutputStream();

    
    
    /**
     * The constructor of this class
     */
	public SoapData()
    {
        // Nothing special needed here ...
	}

	public void clean() {
        this.serviceName = null;
        this.httpHeaders = null;
        this.httpBody.reset();    
        this.httpReqLine = null;
	}

    /**
     * 
     * @return <code>true</code> if this object is poolable or 
     * <code>false</code> otherwise
     * 
     * @see org.quickserver.util.pool.PoolableObject#isPoolable()
     */
	public boolean isPoolable() 
    {
		return true;
	}

    /**
     * @return a {@link PoolableObjectFactory} which is needed to create new
     * {@link SoapData} Objects.
     * @see org.quickserver.util.pool.PoolableObject#getPoolableObjectFactory()
     */
	public PoolableObjectFactory getPoolableObjectFactory() {
		return  new BasePoolableObjectFactory() {
			public Object makeObject() { 
				return new SoapData();
			} 
			public void passivateObject(Object obj) {
				SoapData ed = (SoapData)obj;
				ed.clean();
			} 
			public void destroyObject(Object obj) {
				if(obj==null) return;
				passivateObject(obj);
				obj = null;
			}
			public boolean validateObject(Object obj) {
				if(obj==null) 
					return false;
                return true;
			}
		};
	}
}
