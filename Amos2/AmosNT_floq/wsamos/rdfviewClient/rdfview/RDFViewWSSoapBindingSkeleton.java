/**
 * RDFViewWSSoapBindingSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.3 Oct 05, 2005 (05:23:37 EDT) WSDL2Java emitter.
 */

package rdfview;

public class RDFViewWSSoapBindingSkeleton implements rdfview.RDFViewWS, org.apache.axis.wsdl.Skeleton {
    private rdfview.RDFViewWS impl;
    private static java.util.Map _myOperations = new java.util.Hashtable();
    private static java.util.Collection _myOperationsList = new java.util.ArrayList();

    /**
    * Returns List of OperationDesc objects with this name
    */
    public static java.util.List getOperationDescByName(java.lang.String methodName) {
        return (java.util.List)_myOperations.get(methodName);
    }

    /**
    * Returns Collection of OperationDescs
    */
    public static java.util.Collection getOperationDescs() {
        return _myOperationsList;
    }

    static {
        org.apache.axis.description.OperationDesc _oper;
        org.apache.axis.description.FaultDesc _fault;
        org.apache.axis.description.ParameterDesc [] _params;
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "in0"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://schemas.xmlsoap.org/soap/encoding/", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "in1"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://xml.apache.org/xml-soap", "Vector"), java.util.Vector.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "in2"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "int"), int.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("callFunction", _params, new javax.xml.namespace.QName("", "callFunctionReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://xml.apache.org/xml-soap", "Vector"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:RDFViewWS", "callFunction"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("callFunction") == null) {
            _myOperations.put("callFunction", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("callFunction")).add(_oper);
        _params = new org.apache.axis.description.ParameterDesc [] {
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "in0"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://schemas.xmlsoap.org/soap/encoding/", "string"), java.lang.String.class, false, false), 
            new org.apache.axis.description.ParameterDesc(new javax.xml.namespace.QName("", "in1"), org.apache.axis.description.ParameterDesc.IN, new javax.xml.namespace.QName("http://xml.apache.org/xml-soap", "Vector"), java.util.Vector.class, false, false), 
        };
        _oper = new org.apache.axis.description.OperationDesc("callFunction", _params, new javax.xml.namespace.QName("", "callFunctionReturn"));
        _oper.setReturnType(new javax.xml.namespace.QName("http://xml.apache.org/xml-soap", "Vector"));
        _oper.setElementQName(new javax.xml.namespace.QName("urn:RDFViewWS", "callFunction"));
        _oper.setSoapAction("");
        _myOperationsList.add(_oper);
        if (_myOperations.get("callFunction") == null) {
            _myOperations.put("callFunction", new java.util.ArrayList());
        }
        ((java.util.List)_myOperations.get("callFunction")).add(_oper);
    }

    public RDFViewWSSoapBindingSkeleton() {
        this.impl = new rdfview.RDFViewWSSoapBindingImpl();
    }

    public RDFViewWSSoapBindingSkeleton(rdfview.RDFViewWS impl) {
        this.impl = impl;
    }
    public java.util.Vector callFunction(java.lang.String in0, java.util.Vector in1, int in2) throws java.rmi.RemoteException
    {
        java.util.Vector ret = impl.callFunction(in0, in1, in2);
        return ret;
    }

    public java.util.Vector callFunction(java.lang.String in0, java.util.Vector in1) throws java.rmi.RemoteException
    {
        java.util.Vector ret = impl.callFunction(in0, in1);
        return ret;
    }

}
