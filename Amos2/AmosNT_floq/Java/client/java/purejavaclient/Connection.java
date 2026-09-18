package udbl.amos.purejavaclient;
import java.io.*;
import java.util.*;

public class Connection {
	public ReadPrint rp;
	public SocketToSCSQ scToSCSQ;
	public ServerPortFinder spf;
	//private static Connection theCallbackConnection=null;
	@SuppressWarnings("unchecked")
	private static Hashtable fnCache = new Hashtable();
    private volatile int connectionPointer;
    private static Connection thelocalConnection;
    //------------Constructor--------------------------------
    public Connection(){
	}
    public Connection(String serverAddress, String serverName) throws AmosException{
    	Scan sc = null;
    	int port=0;
    	this.rp = new ReadPrint();
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,35021);
    	try {
			sc=this.execute("all_amosinfo();");
		} catch (Exception e) {
			e.printStackTrace();
		}
    	spf= new ServerPortFinder(sc, serverName);
    	port= spf.portNumber;
    	sc.close();
    	this.scToSCSQ.closeSocketToSCSQ();
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,port);
//		this.scToSCSQ.WriteToSocket("(trace-packets t)");
//		this.scToSCSQ.SendToSocket();
    	
    }
    public Connection(String serverAddress, String serverName, String dbName) throws Exception{
    	Scan sc = null;
    	int port=0;
    	this.rp = new ReadPrint();
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,35021);
    	try {
			sc=this.execute("all_amosinfo();");
		} catch (Exception e) {
			e.printStackTrace();
		}
    	spf= new ServerPortFinder(sc, serverName);
    	port= spf.portNumber;
    	this.scToSCSQ.closeSocketToSCSQ();
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,port);
    	this.execute("'"+dbName+"'");
    }
    public Connection(String serverName) throws AmosException{
    	Scan sc = null;
    	int port=0;
    	this.rp = new ReadPrint();
    	String serverAddress = "localhost";
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,35021);
    	try {
			sc=this.execute("all_amosinfo();");
		} catch (Exception e) {
			e.printStackTrace();
		}
    	spf= new ServerPortFinder(sc, serverName);
    	port= spf.portNumber;
    	sc.close();
    	this.scToSCSQ.closeSocketToSCSQ();
    	this.scToSCSQ = new SocketToSCSQ(serverAddress,serverName,port);
//		this.scToSCSQ.WriteToSocket("(trace-packets t)");
//		this.scToSCSQ.SendToSocket();
    }
    public static Connection localConnection() throws AmosException, IOException {
		if(thelocalConnection==null) 
			thelocalConnection = new Connection("");
		return thelocalConnection;
    }
    public void init_conn(){
    	//this.rp = new ReadPrint();
    	
    }
    //------------Modified functions--------------------------------
    public void disconnect() throws AmosException, IOException{
    	this.scToSCSQ.closeSocketToSCSQ();
    	
    }
    public void init(String dbName) throws AmosException{
    	String osqlQuery;
    	osqlQuery="amosinfo('"+dbName+"');";
    	try {
			this.execute(osqlQuery);
		} catch (Exception e) {
			e.printStackTrace();
		}
    }
    public void initializeAmos(String imageName) throws AmosException{
    	this.init(imageName);
    }

    public Scan execute(String query, int stopAfter) throws AmosException{
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-query-scan-server ");
    	changedQuery=this.rp.print(this.rp.read("(\""+query+"\")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(")\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	scanId=Integer.parseInt(res);
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    public Scan executeCustom(String query, String options)	throws AmosException {
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-query-scan-server ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("(\""+query+"\")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(" (QUOTE ");
    	this.rp = new ReadPrint();
    	this.scToSCSQ.WriteToSocket(this.rp.print(this.rp.read(options)));
    	this.scToSCSQ.WriteToSocket("))");
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }

    public Scan execute(String query) throws AmosException {
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-query-scan-server \"");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("(\""+query+"\")"));
    	changedQuery=changedQuery.substring(2, changedQuery.length()-2);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket("\")\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    public void rollback() throws AmosException{
    	try {
			this.execute("rollback;");
		} catch (Exception e) {
			e.printStackTrace();
		}
    }
    public void commit() throws AmosException{
    	try {
			this.execute("commit;");
		} catch (Exception e) {
			e.printStackTrace();
		}
    }
    @SuppressWarnings("unchecked")
	public Oid getFunction(String fnName)  throws AmosException{
		String hashKey = fnName + connectionPointer;
		Oid tmpOid = (Oid)Connection.fnCache.get(hashKey);
		if (tmpOid == null) {
			tmpOid = this.getFunctionInternal(fnName);
			Connection.fnCache.put(hashKey, tmpOid);
	    }
		return tmpOid;
    }
    private Oid getFunctionInternal(String fnName) throws AmosException{
    	Tuple tp;
    	tp=new Tuple(1);
    	tp.setElem(0, fnName);
    	return (callFunction("functionnamed", tp).getRow().getOidElem(0));
    }
	@SuppressWarnings("unchecked")
	public  static void clearFunctionCache() {
		Connection.fnCache = new Hashtable();
    }
    public void getFunctionArgumentsAsString(Tuple arg) throws AmosException {
    	int i=0,arity=0;
    	Object tupleElem;
    	arity=arg.getArity();
    	String strElem="";
    	while(i<arity){
        	this.scToSCSQ.WriteToSocket(" ");
    		tupleElem= arg.getElem(i);
    		if (tupleElem instanceof String){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("(\""+tupleElem+"\")"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	this.scToSCSQ.WriteToSocket(strElem);
    		}
    		else if(tupleElem instanceof Oid){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("(#[OID " + (((Oid) tupleElem).oidtypeHandle) + "])"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	this.scToSCSQ.WriteToSocket(strElem);
    		}
    		else if(tupleElem instanceof Integer){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("("+tupleElem+")"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	this.scToSCSQ.WriteToSocket(strElem);
    		}
    		else if(tupleElem instanceof Double){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("("+tupleElem+")"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	this.scToSCSQ.WriteToSocket(strElem);
    		}
    		i++;
    	}
    }
    public Scan callFunction(Oid fnObject, Tuple fnArgs) throws AmosException{
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-function-scan-server (getfunctionnamed ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fnObject.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(") (list");
    	this.getFunctionArgumentsAsString(fnArgs);
    	this.scToSCSQ.WriteToSocket("))\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());

    }
    public  Scan callFunction(Oid fnObject, Tuple fnArgs, int stopAfter) throws AmosException {
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-function-scan-server (getfunctionnamed ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fnObject.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(") (list");
    	this.getFunctionArgumentsAsString(fnArgs);
    	this.scToSCSQ.WriteToSocket("))\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    public Scan callFunction(String fnName, Tuple fnArgs) throws AmosException {
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-function-scan-server (getfunctionnamed (QUOTE ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+ fnName+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(")) (list");
    	this.getFunctionArgumentsAsString(fnArgs);
    	this.scToSCSQ.WriteToSocket("))\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    public Scan callFunction(String fnName, Tuple fnArgs, int stopAfter) throws AmosException {
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-function-scan-server (getfunctionnamed (QUOTE ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+ fnName+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(")) (list");
    	this.getFunctionArgumentsAsString(fnArgs);
    	this.scToSCSQ.WriteToSocket("))\n");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    private String getString(Scan theScan) throws AmosException {
		if (theScan.eos()) 
			return null;
		Tuple result = theScan.getRow();
		if (result.getArity() == 0) 
			return null;
		return (result.getStringElem(0));
    }
    public Scan callFunctionCustom(Oid fnObject, Tuple fnArgs, String options) throws AmosException{
    	int scanId=0;
    	String changedQuery="";
    	this.scToSCSQ.WriteToSocket("(open-function-scan-server (getfunctionnamed ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fnObject.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(") (list");
    	this.getFunctionArgumentsAsString(fnArgs);
    	this.scToSCSQ.WriteToSocket(") (QUOTE ");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+options+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket("))");
    	this.scToSCSQ.SendToSocket();
    	String res="";
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    	scanId=Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	return scJava;
    	}
    	return (new Scan());
    }
    public Oid callOidFunction(String fname, Oid arg) throws AmosException {
    	return (callFunction(fname, arg).getRow().getOidElem(0));
    }
    public Tuple callTupleTupleFunction(String fname, Oid arg) throws AmosException {
    	return (callFunction(fname, arg).getRow().getSeqElem(0));
    }
    public String callStringFunction(String fname, Oid arg) throws AmosException {
		Scan theScan = callFunction(fname, arg);
		return getString(theScan);
    }
    public String callStringFunction(String fname) throws AmosException {
		Scan theScan = callFunction(fname);
		return getString(theScan);
    }
    public Scan callFunction(String name) throws AmosException {
    	return (callFunction(name, new Tuple(0)));
    }
    public Scan callFunction(String name, Oid arg) throws AmosException {
    	Tuple tp;
    	tp=new Tuple(1);
    	tp.setElem(0, arg);
    	return (callFunction(name, tp));
    }
    public Scan callFunction(String name, String arg) throws AmosException {
    	Tuple tp;
    	tp=new Tuple(1);
    	tp.setElem(0, arg);
    	return (callFunction(name, tp));
    }
    public Scan callFunction(Oid fn, Oid arg) throws AmosException {
    	Tuple tp;
    	tp=new Tuple(1);
    	tp.setElem(0, arg);
    	return (callFunction(fn, tp));
    }
    public Oid createObject(Oid type) throws AmosException {
		Scan sc=null;
		Tuple tp=null;
		sc=this.callFunction("createobject", type);
		tp=sc.getRow();
		Oid o=tp.getOidElem(0);
		o.theConnection=this;
		return o;
    }
    public Oid createObject(String typeName) throws AmosException {
    	return createObject(getType(typeName));
    }
    public Oid getType(String typeName) throws AmosException{
    	Scan s;
    	s=this.callFunction("typenamed", typeName);
    	Oid o = new Oid();
    	o= s.getRow().getOidElem(0);
    	o.theConnection=this;
    	return o;
    }
    public void deleteObject(Oid theObject) throws AmosException{
		this.callFunction("deleteobject", theObject);    	
    }
    public String createVectorFromTuple(Tuple arg) throws AmosException {
    	int i=0,arity=0;
    	Object tupleElem;
    	arity=arg.getArity();
    	String strElem="", createdVector="";
    	createdVector+="{";
    	while(i<arity){
    		tupleElem= arg.getElem(i);
    		if (tupleElem instanceof String){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("("+tupleElem+")"));
    	    	strElem = '\''+strElem.substring(1, strElem.length()-1)+'\'';
    	    	createdVector+=strElem;
    		}
    		else if(tupleElem instanceof Oid){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("(#[OID " + (((Oid) tupleElem).oidtypeHandle) + "])"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	createdVector+=strElem;
    		}
    		else if(tupleElem instanceof Integer){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("("+tupleElem+")"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	createdVector+=strElem;
    		}
    		else if(tupleElem instanceof Double){
    	    	this.rp = new ReadPrint();
    	    	strElem=this.rp.print(this.rp.read("("+tupleElem+")"));
    	    	strElem = strElem.substring(1, strElem.length()-1);
    	    	createdVector+=strElem;
    		}
    		if(i+1<arity)
    			createdVector+=",";
    		i++;
    	}
    	createdVector+="}";
    	return createdVector;
    }
    public void setFunction(Oid fn, Tuple argList, Tuple resList) throws AmosException{
    	String changedQuery="", query="";
    	query= "setfunction(functionnamed(name(";
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fn.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	query += changedQuery;
    	query += ")),";
    	query +=this.createVectorFromTuple(argList);
    	query +=",";
    	query +=this.createVectorFromTuple(resList);
    	query +=");";
    	this.execute(query);
    }
    public void setFunction(String fnName, Tuple argList, Tuple resList) throws AmosException{
    	setFunction(getFunction(fnName),argList, resList);
    }
    public void addFunction(Oid fn, Tuple argList, Tuple resList) throws AmosException{
    	String changedQuery="", query="";
    	query= "addfunction(functionnamed(name(";
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fn.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	query += changedQuery;
    	query += ")),";
    	query +=this.createVectorFromTuple(argList);
    	query +=",";
    	query +=this.createVectorFromTuple(resList);
    	query +=");";
    	this.execute(query);
    	//System.out.println(this.scToSCSQ.ReadFromSocket());
    }
    public void addFunction(String fnName, Tuple argList, Tuple resList) throws AmosException{
    	addFunction(getFunction(fnName),argList,resList);
    }
    public void remFunction(Oid fn, Tuple argList, Tuple resList) throws AmosException{
    	String changedQuery="", query="";
    	query= "remfunction(functionnamed(name(";
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ fn.oidtypeHandle+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	query += changedQuery;
    	query += ")),";
    	query +=this.createVectorFromTuple(argList);
    	query +=",";
    	query +=this.createVectorFromTuple(resList);
    	query +=");";
    	this.execute(query);
    }
    public void remFunction(String fnName, Tuple argList, Tuple resList) throws AmosException{
    	remFunction(getFunction(fnName),argList,resList);
    }
    /**
     * Retrieves the object with a specified ID-number.
     *
     * @param idno The ID-number of the object to be retrieved.
     * @return The object with ID-number idno.
     * @exception AmosException if the object doesn't exist.
     */
    public Oid getObjectNumbered(int idno) throws AmosException{
    	Tuple t = new Tuple();
    	int scanId=0;
    	String changedQuery="",res="";
    	this.scToSCSQ.WriteToSocket("(open-query-scan-server \"name(");
    	this.rp = new ReadPrint();
    	changedQuery=this.rp.print(this.rp.read("("+"#[OID "+ idno+"]"+")"));
    	changedQuery=changedQuery.substring(1, changedQuery.length()-1);
    	this.scToSCSQ.WriteToSocket(changedQuery);
    	this.scToSCSQ.WriteToSocket(");\")");
    	this.scToSCSQ.SendToSocket();
    	res = this.scToSCSQ.ReadFromSocket();
    	if (!isInteger(res)){
    		System.out.println(res);
    		return null;
    	}
    		
    	scanId= Integer.parseInt(res);
    	if(scanId>-1){
	    	Scan scJava = new Scan(scanId,this);
	    	t = scJava.getRow();
	    	t.theConnection = this;
	    	Oid o = new Oid();
	    	o.theConnection = this;
	    	o.name = t.getStringElem(0);
	    	return o;
    	}
    	return null;
    }

	public boolean isInteger( String input )  
    {  
       try  
       {  
          Integer.parseInt( input );  
          return true;  
       }  
       catch( Exception e)  
       {  
          return false;  
       }  
    }    /**
     * Prints the native a_errform variable on the console.
     */
    public void printErrForm(){
    	
    }

    //------------New added functions--------------------------------
	public static void main(String[] args) throws Exception {
		Connection jac= new Connection("localhost","a");
		jac.execute("create type ddduefds1;");
		
		//jac.Connect("130.238.11.181","49227");
		/*for(int i=0;i<5;i++){
			jac.this.cm.SendQuery("(list " + i +" "+(i+9)+" "+(i+89)+ ")");//"(+ 1 2);");
			jac.ReceiveQueryResult();
		}*/
		
	}
}