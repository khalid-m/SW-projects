/**
 * 
 */
package org.AmosSoapServer;

import javax.xml.soap.SOAPConstants;

/**
 * @author Luan Feng
 *
 */
public interface constants {
	public final static boolean DEBUG = true;
	public static final String _FS = "__";
	public static final String ServiceNameDefault = "WSMEDService";
    //public static final String DBName = "wsmos";
	public static final String DBName = "WebServiveGenerator";
	public static final String port = "8080";
    //public static final String ServletDefault = "/wsmos/service/AmosServlet";
	public static final String ServletDefault = "/WSMEDServlet";
	/** The prefix to use for SOAP-ENV namespace */
	public static final String SOAPENV_PREFIX = "SOAP-ENV";
	
	/** The URI for target namespace Schema*/
	public static final String SOAPENV_URI = SOAPConstants.URI_NS_SOAP_ENCODING;
	
	/** The prefix to use for target namespace */
	public static final String TNS_PREFIX = "tns";
	
	/** The URI for target namespace Schema*/
	public static final String TNS_URI = "urn:WSAmos";
	
    /** The prefix to use for XML Schema instance namespace */
    public static final String XSI_PREFIX = "xsi";

    /** The URI for XML Schema instance namespace */
    public static final String XSI_URI = "http://www.w3.org/2001/XMLSchema-instance";

    /** The prefix to use for XML Schema namespace */
    public static final String XSD_PREFIX = "xsd";

    /** The URI for XML Schema namespace */
    public static final String XSD_URI = "http://www.w3.org/2001/XMLSchema";
    
    public static final String APACHESOAP_PREFIX = "apatchsoap";
    public static final String APACHESOAP_URI = "http://xml.apache.org/xml-soap";
    
    public static final String WSDL_PREFIX = "wsdl";
    public static final String WSDL_URI = "http://schemas.xmlsoap.org/wsdl/" ;
    
    public static final String WSDLSOAP_PREFIX = "wsdlsoap";
    public static final String WSDLSOAP_URI = "http://schemas.xmlsoap.org/wsdl/soap/" ;
    
}
