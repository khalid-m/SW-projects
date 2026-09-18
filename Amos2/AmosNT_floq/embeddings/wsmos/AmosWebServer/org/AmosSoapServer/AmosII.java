package org.AmosSoapServer;

import java.util.ArrayList;
import java.util.Scanner;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;

public class AmosII implements constants{
    private String functionName;
    private String argsType;
    private ArrayList<String> argsTypeList;
    private ArrayList argsValue;
    //	private int stopAfter;
	
    private String fullName;
    private ArrayList resultType;
    private ArrayList<String> resultName;
    private Vector result;
    private static Connection theConnection;
    private boolean isInitialized = false;
    private String resultFormat=""; //if resultformat can be a bag or vector
	
    protected static Logger logger = Logger.getLogger("AmosSoapServer.log");
	
    public AmosII(){
	isInitialized = false;
    }
	
    public Vector getResult(){
	return result;
    }
    public String getResultFormat(){
	return resultFormat;
    }
	
    public ArrayList getResultType(){
	return resultType;
    }
	
    public ArrayList getResultName(){
	return resultName;
    }
	
    public String getFunctionName(){
	return functionName;
    }
	
    public ArrayList getArgsValue(){
	return argsValue;
    }
	
    public String getArgsType(){
	return argsType;
    }
	
    public void setFunctionName(String fn){
	functionName = fn;
    }
	
    public void setArgsValue(ArrayList argsValue){
	this.argsValue = argsValue;
    }
	
    public void setArgsType(String argsType){
	this.argsType = argsType;
    }
	
    public static Connection getConnection(){
	return theConnection;
    }
	
    public static Connection buildConnection(String dbName, String nameServerHost) throws AmosException{
	if(theConnection==null){
	    theConnection = new Connection(dbName, nameServerHost);
	}
	return theConnection;
    }
	
    /*public  Connection buildConnection(String dbName) throws AmosException{
	if(theConnection==null){
	    theConnection = new Connection(dbName);
	}
   
	return theConnection;
	}*/
    
     

    public  Connection buildConnection(String dbName) throws AmosException{
        String olddbName=AmosSoapServer.getConnectedDBName();
	
        if(theConnection==null){
	    AmosSoapServer.setConnectedDBName(dbName);
	    theConnection = new Connection(dbName);
            return theConnection;
	}
        
        if (!(olddbName.equalsIgnoreCase(dbName))){
	    theConnection.disconnect();
             AmosSoapServer.setConnectedDBName(dbName);
	    theConnection = new Connection(dbName);
            return theConnection;
	}
	return theConnection;
    }
    /*public void startAmosII(String  imageFile, String serverName) throws AmosException {
      System.out.println("Start Amos. IsInitialized: "+isInitialized);
      if(isInitialized){
      theConnection = new Connection("");
      System.out.println("new the Connection");
      return;
      }
					
      String dbServer;
      String dbLocation;
      if (!serverName.equals("")){
      dbServer = serverName;
      }
      else{
      dbServer = "";
      }
      if ( !imageFile.equals("") ){
      dbLocation = imageFile; 
      }
      else{
      dbLocation = "C:\\Dev\\workspace\\myapps\\WEB-INF\\wsamos.dmp";
      }
		
      Connection.initializeAmos(dbLocation);
		
      isInitialized = true;
		
      theConnection = new Connection("");
		
      }*/
	
    public static String arrayList2Str(ArrayList al, char separator){
	if (al.isEmpty())
	    return "";
	StringBuffer bf = new StringBuffer();
	int num = al.size();
	for(int i=0; i< num-1; i++){
	    bf.append(al.get(i)).append(separator);
	}
	bf.append(al.get(num-1));
	return bf.toString();
    }
	
    public static ArrayList str2ArrayList(String str, char separator){
	if (str==null)
	    return new ArrayList();
	int b=0,e;
	ArrayList al = new ArrayList();
	for(e=0;e<str.length();e++){
	    if(str.charAt(e) == separator){
		al.add(str.substring(b, e));
		b=e+1;
	    }				
	}
	al.add(str.substring(b, e));
	return al;
    }
	
    private Oid toOid(String s) throws AmosException{
    	int si,ei,num;
    	si=s.indexOf("[OID ");
    	ei=s.indexOf("]");
    	if ((si == 0) && (ei== s.length()-1)){
	    String s1= s.substring(si+5,ei);
	    num= Integer.parseInt(s1);
	    return theConnection.getObjectNumbered(num);
    	}
    	else 
	    throw new AmosException("No valid object number " +s);
    }
    
    
    private Tuple decodeToTuple(ArrayList list) throws AmosException{
	Tuple tpl = new Tuple(list.size());
	int j=0;
	for(java.util.Iterator i=list.iterator(); i.hasNext();j++){
	    Object el= i.next();
	    if (el instanceof java.util.ArrayList)
		tpl.setElem(j,decodeToTuple((ArrayList)el));
	    else if (el instanceof String) {
		try {
		    Oid oid=toOid((String) el);
		    tpl.setElem(j,oid);}
		catch (AmosException e){
		    tpl.setElem(j,el);
		}
	    }
	    else 
		tpl.setElem(j,el);
	}
	return (tpl);
    }
	
    public void getFunInfo(String funName, int index) throws AmosException{
	this.functionName = funName;
	Tuple tpl= new Tuple(2);
	String resultAtt = null;
	String resName = null;
	    
	tpl.setElem(0, funName);
	tpl.setElem(1, index);
	try{
	    Scan theScanner = theConnection.callFunction("getFunInfo", tpl);
	    Tuple row = theScanner.getRow();
	    resultAtt = row.getStringElem(0);
	    resName = row.getStringElem(1);
	    argsType = row.getStringElem(2);
	    
	}catch(AmosException e){
	    if(e.getMessage().contains("Empty"))
		throw new AmosException("BAD_REQUEST. <FunctionName:"+ functionName+", Index: "+index+">, does not exist.");
	    else
		throw e;
	}
	//	    argsName = row.getStringElem(3);
	    
	if(argsType.equals(""))
	    fullName = functionName+"->"+resultAtt;
	else
	    fullName = argsType+"."+functionName+"->"+resultAtt;
	resultType = str2ArrayList(resultAtt, '.');
	resultName = str2ArrayList(resName, '.');
    }
	

	
    public boolean compareType(String superTypes, String subTypes) throws AmosException{
	//	    System.out.println("superTypes:"+superTypes+"    subTypes:"+subTypes);
	if(superTypes==null&&subTypes==null)
	    return true;
	else if(superTypes==null && subTypes!=null)
	    return false;
	else if(superTypes!=null && subTypes==null)
	    return false;
	   
	int idx1 = superTypes.indexOf(".");
	int idx2 = subTypes.indexOf(".");
	String superType,subType, superTypeRest, subTypeRest;
	if(idx1==-1){
	    superType = superTypes;
	    superTypeRest = null;
	}
	else{
	    superType = superTypes.substring(0, idx1).trim();
	    superTypeRest = superTypes.substring(idx1+1).trim();
	}
	if(idx2==-1){
	    subType = subTypes;
	    subTypeRest = null;
	}
	else{
	    subType = subTypes.substring(0, idx2).trim();
	    subTypeRest = subTypes.substring(idx2+1).trim();
	}
	    
	if(superType.startsWith("VECTOR")&&subType.startsWith("VECTOR"))
	    return true;
	    
	Tuple tpl = new Tuple(2);
	//System.out.println("superType = "+superType+" ; subType ="+subType);
	tpl.setElem(0, superType);
	tpl.setElem(1, subType);
	if(theConnection.callFunction("isSubType", tpl).getRow().getBooleanElem(0))
	    return compareType(superTypeRest,subTypeRest);
	else
	    return false;
    }
	
    public void execute(String funName, ArrayList argsTypeList, ArrayList argsValue) throws AmosException{
	this.execute(funName, argsTypeList, argsValue, 0);
    }
	
    public void execute(String funName, ArrayList argsTypeList, ArrayList argsValue, int stopAfter) throws AmosException{
		
	this.functionName = funName;
	this.argsTypeList = argsTypeList;
	this.argsType = arrayList2Str(this.argsTypeList, '.');
	this.argsValue = argsValue;
	//		this.stopAfter = stopAfter;	

	Scan theScanner = null;
	
	Tuple arg = new Tuple(2);
	arg.setElem(1, argsType);
	arg.setElem(0, functionName);
	String resultAtt = null;
	String resName = null;
	//		System.out.println("FunctionName ="+ functionName+ "arg = "+argsType);
	if (logger.isLoggable(Level.FINE))
	    logger.fine("FunctionName ="+ functionName+ "arg = "+argsType);
		
	try{
	    theScanner = theConnection.callFunction("CHARSTRING.CHARSTRING.GetFunInfo->CHARSTRING.CHARSTRING.CHARSTRING", arg);
	    
	    Tuple row = theScanner.getRow();
	    resultAtt = row.getStringElem(0);
	    resName = row.getStringElem(1);
	    resultFormat = row.getStringElem(2);
	}catch(AmosException e){
	    try{
		boolean notMatch = true;
		theScanner = theConnection.callFunction("GetFunInfo", new Tuple(functionName));
		while(!theScanner.eos()){
		   
		    Tuple row = theScanner.getRow();
		    String superTypes = row.getStringElem(2);
		    if(compareType(superTypes, argsType)){
			resultAtt = row.getStringElem(0);
			resName = row.getStringElem(1);
			argsType = superTypes;
			notMatch = false;
			break;
		    }		    		
		}
		if(notMatch){
		    throw new AmosException("BAD_REQUEST. Function,"+argsType+"."+ functionName+" does not exist."); 
		}
	    }catch(AmosException ae){
		throw new AmosException("BAD_REQUEST. Function,"+argsType+"."+ functionName+" does not exist."); 
	    }
	}
	if(argsType.equals(""))
	    fullName =functionName+"->"+resultAtt;
	else
	    fullName = argsType+"."+functionName+"->"+resultAtt;
	resultType = str2ArrayList(resultAtt, '.');
	resultName = str2ArrayList(resName, '.');
		
	result = new Vector();
	int arity = argsValue.size();
	Tuple args;
	if(arity == 0)
	    args = new Tuple();
	else{
	    args = new Tuple(arity);
	    args = decodeToTuple(argsValue);
	}

	/*for(int i = 0; i<arity; i++)
	  args.setElem(i, argsValue.get(i));
	*/
	theScanner = null;
	Tuple row = null;
	if (logger.isLoggable(Level.FINE)){
	    logger.fine("fullName : "+fullName);
	    logger.fine("funName: "+funName);
	    logger.fine("Arguments: "+ args.toVector());
	}
	/*System.out.println("fullName : "+fullName);
	 System.out.println("funName: "+funName);
	 System.out.println("Arguments: "+ args.toVector());*/
	
	try{
	    if(stopAfter==0)
		theScanner = theConnection.callFunction(fullName, args);
	    else
		theScanner = theConnection.callFunction(fullName, args, stopAfter);
	    while(!theScanner.eos()){
		row = theScanner.getRow();
		result.add(row.toRemoteVector());
		theScanner.nextRow();
	    }
	}catch(AmosException e){
	    String errMsg= e.getMessage();
	    if(errMsg.contains("Empty")){
		System.out.println("Empty Scan");
	    }
	    else{
		throw e;
	    }
				
	}
	if (logger.isLoggable(Level.FINE))
	    logger.fine("Result: "+result.toString());
    }
	
    public void close() throws AmosException{
	if(isInitialized)
	    theConnection.disconnect();
    }
		
    /*
      public static void main(String args[]){
      ArrayList values = new ArrayList();
      ArrayList types = new ArrayList();
      String fn = "getname";
      types.add("charstring");
      values.add("123");
      AmosII af  = new AmosII();
      try {
      af.startAmosII("", "");
      af.execute(fn, types, values);
      System.out.println(af.getResult());
      System.out.println("Result Type:" + af.getResultType());
      } catch (Exception e) {
      // TODO Auto-generated catch block
      try {
      af.close();
      } catch (AmosException e1) {
      // TODO Auto-generated catch block
      e1.printStackTrace();
      }
      e.printStackTrace();
      }	
      try {
      af.close();
      } catch (AmosException e) {
      // TODO Auto-generated catch block
      e.printStackTrace();
      }
      }
    */
}
