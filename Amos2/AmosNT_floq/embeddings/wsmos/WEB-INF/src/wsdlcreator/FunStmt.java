package wsdlcreator;

import java.util.ArrayList;
import java.util.Scanner;
import java.util.StringTokenizer;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;

public class FunStmt {
    private String FunName;
    static int outIndex=0;
   

    private ArrayList<String> inType;
    private ArrayList<String> inName;
    private ArrayList<String> outType;
    private ArrayList<String> outName;
    private  int funIndex;
    private String  resultFormat=""; // result format of a function can be a bag or vector 
	
    
    /*
     * Generate all information of one function from database using metadata.
     */
    public FunStmt(Oid fun) throws AmosException {
	inType = new ArrayList<String>();
	inName = new ArrayList<String>();
	outType = new ArrayList<String>();
	outName = new ArrayList<String>();
	resultFormat="";
	
	Connection theConnection = null;

	Scan theScan = null;
	theConnection = new Connection("");
        theScan = theConnection.callFunction("signature",new Tuple(fun));
	String sigStr = theScan.getRow().getStringElem(0);
        
	int seperator = sigStr.indexOf("->");
	if(seperator >0){
	    String tmpStr = sigStr.substring(seperator+2,seperator+5);
	    if ((tmpStr.equalsIgnoreCase("BAG"))||(tmpStr.equalsIgnoreCase("VEC"))){
		resultFormat=tmpStr;
	    }
	}
	
	int start=sigStr.indexOf("(");
	int end=sigStr.indexOf(")");
	FunName = sigStr.substring(0,start);
	String argStr=	sigStr.substring(start+1,end);
	
	StringTokenizer st = new StringTokenizer(argStr,",");
	theScan = theConnection.callFunction("arguments",new Tuple(fun));
	Tuple args = theScan.getRow().getSeqElem(0);
	int i=0;
	while(st.hasMoreElements()){
	    inType.add(st.nextToken().trim());
	    Tuple theArg = args.getSeqElem(i);
            inName.add(theArg.getStringElem(1).replace("_",""));
	    i++;
	}
	start=sigStr.indexOf("->");
	end=sigStr.length();
        argStr=	sigStr.substring(start+2,end);
	
	start=argStr.indexOf("<");
	String outStr="";
        theScan = theConnection.callFunction("results",new Tuple(fun));
	if ((start > 0)&& (!argStr.substring(0,start).equalsIgnoreCase("VECTOR of "))){
	    outStr=argStr.substring(0,start);
	    argStr=argStr.substring(start+1,argStr.length());
             args = theScan.getRow();
	}
	else {
	   
	    args = theScan.getRow().getSeqElem(0);
	}
        String name="";
	if (!argStr.startsWith("VECTOR of")) {
	    	st = new StringTokenizer(argStr,",");
		i=0;
		
		int tokens=st.countTokens();
		while(st.hasMoreElements()) {
		    String tStr=st.nextToken().trim();
		    tStr=tStr.replace("<","");
		    tStr=tStr.replace(">","");
		    	
		    if (tokens==1) {
			start=tStr.indexOf("BAG of");
			if (start==0) {
			    tStr=tStr.substring(start+6,tStr.length());
			}
		    }   
	   	   
		    outType.add(tStr.trim());
		    if (outStr.equalsIgnoreCase("VECTOR of ")) {
			name="OUT"+outIndex;
			outIndex=outIndex+1;
		    }
		    else {
			Tuple theArg;
			if (outStr.equalsIgnoreCase("BAG of ")) {
			     name ="OF";
                           }
			else {
			    theArg = args.getSeqElem(i);
			    name = theArg.getStringElem(1);
			    i++;
			}
			
		
		
			
			name=name.replace("_","");
			if (name.equalsIgnoreCase("OF")){
			    name="OUT"+outIndex;
			    outIndex=outIndex+1;
			}	
		    }
		    
		    outName.add(name);
		}
	    }
	    else {
		outType.add(argStr.trim());
		name="OUT"+outIndex;
		outIndex=outIndex+1;
		outName.add(name);	    
	    }
	
	Connection.clearFunctionCache();
    }

    /* To get the result format*/
    public String getResultFormat(){
	return resultFormat;
    }
   
    /*
     * 
     */
    public int getFunIndex(){
	return funIndex;
    }
	
    /*
     * 
     */
    public boolean setIndex(int index){
	//	    System.out.println("function:"+FunName);
	//	    System.out.println("Exist?:"+isNewOverload+", index:"+index+", inDB:"+funIndex);
	funIndex = index;
	return true;
    }

    
    /*
     * 
     * @return the arity of function.
     */
    public int getArity(){
	return inName.size();
    }
	
    /*
     * @returns the width of function.
     */
    public int getWidth(){
	return outName.size();
    }
	
	
    /*
     * @return name of arguments
     */
    public ArrayList getInNameList(){
	return inName;
    }
    /*
     * @return names of results
     */
    public ArrayList getOutNameList(){
	return outName;
    }
    /*
     * @return type of arguments
     */
    public ArrayList getInTypeList(){
	return inType;
    }
    /*
     * @return types of results
     */
    public ArrayList getOutTypeList(){
	return outType;
    }
	
    /*
     * combine the names and the types of arguments to a String 
     * return a String. It is in the form, "varibaleType variableName,varibaleType variableName, ..."
     */
    public String getInput(){
	String input ="";
	int i;
	if(inType.size()==0)
	    return "";
	for(i=0; i< inType.size()-1; i++){
	    input = input+inType.get(i)+" "+ inName.get(i)+",";
	}
	return input+inType.get(i)+" "+ inName.get(i);
    }
    /*
     * combine the names and the types of results to a String 
     * return a String. It is in the form, "varibaleType variableName,varibaleType variableName, ..."
     */
    public String getOutput(){
	String output ="";
	int i;
	if(outType.size()==0)
	    return "";
	for(i=0; i< outType.size()-1; i++){
	    output = output+outType.get(i)+" "+ outName.get(i)+",";
	}
	return output+outType.get(i)+" "+ outName.get(i);
    }
	
    /*
     * return all names of arguments
     */
    public String getInputNames(){
	String input ="";
	int i;
	if(inName.size()==0)
	    return "";
	for(i=0; i< inName.size()-1; i++){
	    input = input+inName.get(i)+".";
	}
	return input+inName.get(i);
    }
	
    /*
     * return all names of results
     */
    public String getOutputNames(){
	String output ="";
	int i;
	if(outName.size() == 0)
	    return "";
	for(i=0; i< outName.size()-1; i++){
	    output = output+outName.get(i)+".";
	}
	return output+outName.get(i);
    }
	
    /*
     * return types of arguments
     */
    public String getInputTypes(){
	String input ="";
	int i;
	if(inType.size() == 0)
	    return "";
	for(i=0; i< inType.size()-1; i++){
	    input = input+inType.get(i)+".";
	}
	return input+inType.get(i);
    }
	
    /*
     * return types of results
     */
    public String getOutputTypes(){
	String output ="";
	int i;
	if(outType.size()==0)
	    return "";
	for(i=0; i< outType.size()-1; i++){
	    output = output+outType.get(i)+".";
	}
	return output+outType.get(i);
    }
	
    /* 
     * @return function name
     */
    public String getFunName(){
	return FunName;
    }
	
    /*
     * judge whether this statement is a "create function" statement
     */
    public static boolean isCreateFun(String stmt){
	return stmt.startsWith("create function");
    }
	
   	
    public String toString(){
	String str = null;
	str = FunName;
	str = str + "(" + getInput() + ") -> ";
	str = str + getOutput();
	return str;
    }
    
}
