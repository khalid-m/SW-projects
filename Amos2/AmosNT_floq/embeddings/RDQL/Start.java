import java.io.BufferedReader;
import java.io.StringReader;
import callin.*;
import callout.*;

public class Start {
	//public static Rdql2Amos parser;
	public static String SourceNameSpace="";
	public static BufferedReader in=new BufferedReader(new StringReader(""));
	public static Rdql2Amos parser=new Rdql2Amos(in);
	
	public Start() {}

	public void sourcenamespace(CallContext cxt1, Tuple nm) throws Exception	{
    	
    	SourceNameSpace=nm.getStringElem(0);
    	System.out.println("Namespace is: "+SourceNameSpace);
  	   
	}

	public void rdql(CallContext cxt, Tuple tpl) throws Exception {
        	    	
	Scan tmpScan;
	Tuple t;

	// Pick up the argument
		String query = tpl.getStringElem(0);
		String parsedquery; 
		
		BufferedReader in=new BufferedReader(new StringReader(query));
		
	//Parse the argument
	parser.ReInit(in);		//ReInits 
        parser.CompilationUnit();	//starts the parsing
        parsedquery=parser.output(); 			
        System.out.println(parsedquery); //output of the AmosQL query. Not necessary if one don´t like it
	// Execute the query
	Connection tmpConnection = new Connection("");	
	try 
	    {
		tmpScan = tmpConnection.execute(parsedquery);

    // Return the result to Amos II
		while (!tmpScan.eos()) 
		    {
			t = tmpScan.getRow();
			tpl.setElem(1, t.getOidElem(0));
			cxt.emit(tpl);
			tmpScan.nextRow();
		    }
		}
		catch(AmosException e)
	    {
		throw(e);
	    }
    }
}
