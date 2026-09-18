import java.io.BufferedReader;
import java.io.StringReader;
import callin.*;
import callout.*;

public class Start {

 public static String SourceNameSpace="";
 public static BufferedReader in=new BufferedReader(new StringReader(""));
 public static Rdql2Amos parser=new Rdql2Amos(in);
    
    public Start() {}
    
	public void sourcenamespace(CallContext cxt1, Tuple nm) throws Exception	{
	    
	    SourceNameSpace=nm.getStringElem(0);
	    System.out.println("Namespace is: "+SourceNameSpace);
	    
	}

    public void parseRDQL(CallContext cxt, Tuple tpl) throws Exception {
        	    	
       	Tuple t;
	
	// Pick up the argument
	String query = tpl.getStringElem(0);
	String parsedquery; 
	
	BufferedReader in=new BufferedReader(new StringReader(query));
	
	//Parse the argument
	parser.ReInit(in);		//ReInits 
        parser.CompilationUnit();	//starts the parsing
        parsedquery=parser.output(); 			
	Connection tmpConnection = new Connection("");
	tpl.setElem(1,parsedquery);
     	cxt.emit(tpl);
    }

    
    public void RDQL(CallContext cxt, Tuple tpl) throws Exception {
        	    	
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

	// Execute the query
	Connection tmpConnection = new Connection("");	
	try 
	    {
		tmpScan = tmpConnection.execute(parsedquery);
		
		// Return the result to Amos II
		while (!tmpScan.eos()) 
		    {
			int arity;
			int j = 0;
			Tuple v;

			t = tmpScan.getRow();
			arity = t.getArity();
			v = new Tuple(arity);

			while (j < arity)
			    {
				v.setElem(j, t.getOidElem(j));
				j++;
			    }
			tpl.setElem(1,v);
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
