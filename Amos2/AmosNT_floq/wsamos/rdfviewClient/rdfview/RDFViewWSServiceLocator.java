/**
 * RDFViewWSServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.3 Oct 05, 2005 (05:23:37 EDT) WSDL2Java emitter.
 */

package rdfview;

public class RDFViewWSServiceLocator extends org.apache.axis.client.Service implements rdfview.RDFViewWSService {

    public RDFViewWSServiceLocator() {
    }


    public RDFViewWSServiceLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    public RDFViewWSServiceLocator(java.lang.String wsdlLoc, javax.xml.namespace.QName sName) throws javax.xml.rpc.ServiceException {
        super(wsdlLoc, sName);
    }

    // Use to get a proxy class for RDFViewWS
    private java.lang.String RDFViewWS_address = "http://130.238.11.93:8080/axis/services/RDFViewWS";

    public java.lang.String getRDFViewWSAddress() {
        return RDFViewWS_address;
    }

    // The WSDD service name defaults to the port name.
    private java.lang.String RDFViewWSWSDDServiceName = "RDFViewWS";

    public java.lang.String getRDFViewWSWSDDServiceName() {
        return RDFViewWSWSDDServiceName;
    }

    public void setRDFViewWSWSDDServiceName(java.lang.String name) {
        RDFViewWSWSDDServiceName = name;
    }

    public rdfview.RDFViewWS getRDFViewWS() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(RDFViewWS_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getRDFViewWS(endpoint);
    }

    public rdfview.RDFViewWS getRDFViewWS(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            rdfview.RDFViewWSSoapBindingStub _stub = new rdfview.RDFViewWSSoapBindingStub(portAddress, this);
            _stub.setPortName(getRDFViewWSWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    public void setRDFViewWSEndpointAddress(java.lang.String address) {
        RDFViewWS_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (rdfview.RDFViewWS.class.isAssignableFrom(serviceEndpointInterface)) {
                rdfview.RDFViewWSSoapBindingStub _stub = new rdfview.RDFViewWSSoapBindingStub(new java.net.URL(RDFViewWS_address), this);
                _stub.setPortName(getRDFViewWSWSDDServiceName());
                return _stub;
            }
        }
        catch (java.lang.Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        java.lang.String inputPortName = portName.getLocalPart();
        if ("RDFViewWS".equals(inputPortName)) {
            return getRDFViewWS();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("urn:RDFViewWS", "RDFViewWSService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("urn:RDFViewWS", "RDFViewWS"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(java.lang.String portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        
if ("RDFViewWS".equals(portName)) {
            setRDFViewWSEndpointAddress(address);
        }
        else 
{ // Unknown Port Name
            throw new javax.xml.rpc.ServiceException(" Cannot set Endpoint Address for Unknown Port" + portName);
        }
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(javax.xml.namespace.QName portName, java.lang.String address) throws javax.xml.rpc.ServiceException {
        setEndpointAddress(portName.getLocalPart(), address);
    }

}
