/**
 * WebamosSoapBindingImpl.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.3 Oct 05, 2005 (05:23:37 EDT) WSDL2Java emitter.
 */

package wsamos;
import callin.*;
import java.util.*;

    
public class SWARD_WebamosSoapBindingImpl implements wsamos.Webamos{
    private Connection theConnection;
    private Boolean initialized=false;
    private String dbServer="WEB-AMOS";
    private java.util.Map opRegistry = new java.util.HashMap();
    
    public SWARD_WebamosSoapBindingImpl(){
	
      if(!initialized)
	{    
	String dmp= "C:\\AmosNT\\bin\\amos2.dmp";
	try {Connection.initializeAmos(dmp);  
	    this.theConnection = new Connection(dbServer); 
	    this.initRegistry();}
	catch (AmosException e){
	    this.theConnection=null;}
	initialized=true;
       }
    }
    
    private void initRegistry() throws AmosException{
    Scan theScan=theConnection.execute("select SWARD_operations_descr();");
    while (!theScan.eos()){
	Tuple row =theScan.getRow();
	String fnname= row.getStringElem(0);
	java.util.Vector args = row.getSeqElem(1).toVector();
	this.opRegistry.put(fnname,args);
	theScan.nextRow();
    }
}

    public java.lang.String sayHello(java.lang.String in0) throws java.rmi.RemoteException {
        return "Hello "+ in0;
    }

    public java.util.Vector executeQuery(java.lang.String query) throws java.rmi.RemoteException {
	java.util.Vector res= new java.util.Vector();
	try{
	Scan theScan=theConnection.execute(query);
	Tuple row;
	while (!theScan.eos()){
	    row=theScan.getRow();
	    res.add(row.toRemoteVector());
	    theScan.nextRow();
	}     
        return res;}
	catch (AmosException e){
	    throw new java.rmi.RemoteException("Exception in Amos Connection");
	}
    }



   /** Decode string representing OID to the object of Oid class*/
    
    public Oid toOid(String s) throws AmosException{
	int si,ei,num;
	si=s.indexOf("[OID ");
	ei=s.indexOf("]");
	if ((si == 0) && (ei== s.length()-1)){
	String s1= s.substring(si+5,ei);
	num= Integer.parseInt(s1);}
	else num= -1;
	if (num>=0)
	return (theConnection.getObjectNumbered(num));
	else throw new AmosException("No valid object number " +s);
    }
  
    public Tuple decodeToTuple(java.util.Vector v) throws AmosException{
	Tuple tpl = new Tuple(v.size());
	int j=0;
	for(java.util.Iterator i=v.iterator(); i.hasNext();j++){
	    Object el= i.next();
	    if (el instanceof java.util.Vector)
		tpl.setElem(j,decodeToTuple((java.util.Vector)el));
	    else if (el instanceof String) {
		try {
		    Oid oid=toOid((String) el);
		    tpl.setElem(j,oid);}
		catch (AmosException e){
		    tpl.setElem(j,el);
		}
	    }
	    else tpl.setElem(j,el);
	}
	return (tpl);
    }

 public java.util.Vector callFunction(java.lang.String in0, java.util.Vector in1) throws java.rmi.RemoteException {

	java.util.Vector res= new java.util.Vector();
	java.util.Vector qres= new java.util.Vector();
	java.util.Vector attr= new java.util.Vector();
	Scan theScan = null;
	Scan attrScan=null;
	if (theConnection==null)
	    throw new java.rmi.RemoteException("No Amos connection : ");
	if (this.opRegistry.containsKey(in0))
	try{
	    Tuple tpl = decodeToTuple(in1);
	    
	    theScan=theConnection.callFunction(in0,tpl);

	    Tuple row;
	    while (!theScan.eos()){
		row=theScan.getRow();
		qres.add(row.toRemoteVector());
		theScan.nextRow();
	    }    
	    Tuple argl= new Tuple(2);
	    argl.setElem(0,in0); 
	    argl.setElem(1,tpl);
	    attrScan= theConnection.callFunction("RES_DESCR",argl);
	    row=attrScan.getRow().getSeqElem(0);

	    res.add(qres);
	    res.add(row.toRemoteVector());
	    return res;}
	catch (AmosException e){
	    throw new java.rmi.RemoteException("Exception in Amos Connection : " + e.getMessage());
	}
	catch (Exception e){
	    throw new java.rmi.RemoteException("Exception");
	}
	else 
	    throw new java.rmi.RemoteException("Function " + in0 + " is not published");
	
     }


public java.util.Vector callFunction(java.lang.String in0, java.util.Vector in1, int stopAfter) throws java.rmi.RemoteException {

	java.util.Vector res= new java.util.Vector();
	java.util.Vector qres= new java.util.Vector();
	java.util.Vector attr= new java.util.Vector();
	Scan theScan = null;
	Scan attrScan=null;
	if (theConnection==null)
	    throw new java.rmi.RemoteException("No Amos connection : ");
	if (this.opRegistry.containsKey(in0))
	try{
	    Tuple tpl = decodeToTuple(in1);
	    
	    theScan=theConnection.callFunction(in0,tpl,stopAfter);

	    Tuple row;
	    while (!theScan.eos()){
		row=theScan.getRow();
		qres.add(row.toRemoteVector());
		theScan.nextRow();
	    }    
	    Tuple argl= new Tuple(2);
	    argl.setElem(0,in0); 
	    argl.setElem(1,tpl);
	    attrScan= theConnection.callFunction("RES_DESCR",argl);
	    row=attrScan.getRow().getSeqElem(0);

	    res.add(qres);
	    res.add(row.toRemoteVector());
	    return res;}
	catch (AmosException e){
	    throw new java.rmi.RemoteException("Exception in Amos Connection : " + e.getMessage());
	}
	catch (Exception e){
	    throw new java.rmi.RemoteException("Exception");
	}
	else 
	    throw new java.rmi.RemoteException("Function " + in0 + " is not published");
	
     }

}
