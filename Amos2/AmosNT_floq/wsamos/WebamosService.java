/**
 * WebamosService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.3 Oct 05, 2005 (05:23:37 EDT) WSDL2Java emitter.
 */

package wsamos;

public interface WebamosService extends javax.xml.rpc.Service {
    public java.lang.String getWebamosAddress();

    public wsamos.Webamos getWebamos() throws javax.xml.rpc.ServiceException;

    public wsamos.Webamos getWebamos(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
