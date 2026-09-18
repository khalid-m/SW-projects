import callin.*;
import callout.*;
import java.util.*;
import java.io.*;

public class wrapperFunctions
{
    static String inarg,outarg,select,from,where,cwo;
    static String servicename, wsdlu;
    static Connection theConnection;
    static boolean inputflag=true;
    static Tuple  tempouttpl=new Tuple(2);
   

 public static String create(String wsdluri) throws AmosException 
    {
		
	theConnection = new Connection(""); 
	Scan s,r;
	Tuple stpl= new Tuple(1);
	String function="";
	wsdlu=wsdluri;

	stpl.setElem(0,wsdluri);
	s = theConnection.callFunction("charstring.findservice->Service",stpl);
 
	stpl.setElem(0,(s.getRow()).getOidElem(0));
	r= theConnection.callFunction("service.port->Operation",stpl);
	
	stpl.setElem(0,(s.getRow()).getOidElem(0));	
	s = theConnection.callFunction("service.name->charstring",stpl);
	servicename=(s.getRow()).getStringElem(0);
	
	while(!r.eos())
	    {
	   cwo="cwo('"+wsdluri+"', '"+servicename+"', '";
	    stpl.setElem(0,(r.getRow()).getOidElem(0));
	    
	    function+=operation(stpl);
	    //System.out.println("testing1  "+function);
	    if (!r.eos())
		r.nextRow();
	    cwo+=")";
	    function+=select+"\n";
	    function+=from+"\n";
	    function+="where out="+cwo+" "+where+";\n \n";
	    
	    //System.out.println(cwo);
	    //System.out.println(select);
	    //System.out.println(from);
	    //System.out.println(where);
	    
	}
	String filename=wsdluri+servicename;
	filename=filename.replace(":","");
	filename=filename.replace(".","");
	filename=filename.replace("-","");
	filename =filename.replace("/","");
	//function+="load_amosql('"+filename+".amosql');";
	//System.out.println("test "+function);
	writeamosql(filename,function);
	return filename+".amosql";
	
    }
 public static String operation(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Scan s;
	String function="";
	String temp,tempsoapheader;
	boolean soaph;

	tempouttpl.setElem(0,otpl.getOidElem(0));
	stpl.setElem(0,otpl.getOidElem(0));
	s = theConnection.callFunction("operation.name->charstring",stpl);
	cwo+=(s.getRow()).getStringElem(0)+"', {";
	function="/**************  "+(s.getRow()).getStringElem(0)+"    ******************************/ \n \n";
	/*if (!is_soapheader(otpl))
	  function+="putsoaphvalue( "+otpl.getOidElem(0)+", "+"{}); \n \n ";*/
	function+="create function "+(s.getRow()).getStringElem(0)+" ( ";
	temp=inputelement(otpl);
	//soph=is_soapheader(otpl);
	//tempsoapheader=soapheaderelement(otpl);
	//System.out.println("testing5  "+temp);
	//System.out.println("testing>>>>>>>>>>>>>>>>>>>"+ (s.getRow()).getStringElem(0));
	if (temp.equalsIgnoreCase(""))
	    function+=")->< "+outputelement(otpl)+" > \n";
	    /*function+=tempsoapheader+")->< "+outputelement(otpl)+" > \n";*/
	else
	    function+=temp+" )->< "+outputelement(otpl)+" > \n";


	    /*if (tempsoapheader.equalsIgnoreCase(""))
		function+=temp+" )->< "+outputelement(otpl)+" > \n";
	    else
	    function+=temp+" ,"+tempsoapheader+")->< "+outputelement(otpl)+" > \n";*/
	
	return function;	
	
	
    }
public static String inputelement(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r,t;
	String function="";
	String tempstr;

	inputflag=true;
	stpl.setElem(0,otpl.getOidElem(0));
	
	s = theConnection.callFunction("Operation.input->vector-element",stpl);
	stpl.setElem(0,(s.getRow()).getOidElem(0));
	s= theConnection.callFunction("vector.vectorele->element",stpl);
	//System.out.println(" testing input ");
	while(!s.eos())
	    {
		//System.out.println(function);	
	
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		r= theConnection.callFunction("element.subelements->vector-element",stpl);
	
	
		if (!r.eos())
		    {
			
			stpl.setElem(0,(r.getRow()).getOidElem(0));
			r= theConnection.callFunction("vector.vectorele->element",stpl);	
			
			while(!r.eos())
			    {
				stpl.setElem(0,(r.getRow()).getOidElem(0));
				t= theConnection.callFunction("element.name->charstring",stpl);
				//System.out.println((t.getRow()).getStringElem(0));
				function+=subelement(r.getRow(),(t.getRow()).getStringElem(0))+" ";
				r.nextRow();
				if (!r.eos())
				    {
					function+=", ";
					cwo+=", ";
				    }
			    }
		    }
		else
		    {
			
			
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.wsmedtype->charstring",stpl);
			function+=(r.getRow()).getStringElem(0)+" ";
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.name->charstring",stpl);
			//System.out.println(" testing input inside "+(r.getRow()).getStringElem(0) );
			function+=(r.getRow()).getStringElem(0);
			cwo+=(r.getRow()).getStringElem(0);
		
			
		    }
		
		s.nextRow();
		if (!s.eos())
		    {
			function+=", ";
			cwo+=", ";
		    }
			
	    }
	cwo+="} ";
	
	return function;
    }
    public static String outputelement(Tuple otpl) throws AmosException 
    {	
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r,t;
	String function="";
	String tempstr="";
	inputflag=false;
	boolean single=true;
	from="";
	where="";
	select="";
	
	stpl.setElem(0,otpl.getOidElem(0));
	//System.out.println("testing5  "+function);
	t= theConnection.callFunction("Operation.output->vector-element",stpl);
	stpl.setElem(0,(t.getRow()).getOidElem(0));
	s= theConnection.callFunction("vector.vectorele->element",stpl);	
	int outindex=0;
	//System.out.println(" testing output ");
	
	if (!s.eos())
	    {
		select="as select ";
		from="from sequence out ";
		where=" ";
		stpl.setElem(0,(t.getRow()).getOidElem(0));
		t= theConnection.callFunction("vector-element.countvectorele->integer",stpl);
		if (((t.getRow()).getIntElem(0))==1)
		    outindex=-1;
	    }
	else
	    {
		function+="boolean";
		select="as select ";
		from="from sequence out ";
		where=" ";
	    }
	

	while(!s.eos())
	    {
			
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		r= theConnection.callFunction("element.subelements->vector-element",stpl);
		
		if (!r.eos())
		    {
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			t= theConnection.callFunction("element.name->charstring",stpl);
			tempstr=(t.getRow()).getStringElem(0);
						
			if (outindex==-1)
			    {
				from+=", record "+tempstr;
				where+=" and "+tempstr+" in out ";
			    }
			else
			    {
				from+=", record "+tempstr;
				where+=" and "+tempstr+"=out["+outindex+"] ";
			    }
			
			
			function+=subelement(s.getRow(),tempstr);
			outindex++;
			
		    }
		else
		    {
			
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.wsmedtype->charstring",stpl);
			function+=(r.getRow()).getStringElem(0)+" ";
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.name->charstring",stpl);
			tempstr=(r.getRow()).getStringElem(0);
			String tempout=(r.getRow()).getStringElem(0);
						
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			t= theConnection.callFunction("element.maxoccurs->charstring",stpl);
			
			if (((t.getRow()).getStringElem(0)).equalsIgnoreCase("-1"))
			    {
				from+=", record "+tempstr;
				where+=" and "+tempstr+" in out ";
			    }
			else
			    {
				from+=", record "+tempstr;
				where+=" and "+tempstr+"=out["+outindex+"]";
			    }
			outindex++;
			tempouttpl.setElem(1,tempout);
		
			function+=(r.getRow()).getStringElem(0)+"1";
			
			if (select.equalsIgnoreCase("as select "))
			    select+=(r.getRow()).getStringElem(0)+"['"+(r.getRow()).getStringElem(0)+"']";
			else
			    select+=", "+(r.getRow()).getStringElem(0)+"['"+(r.getRow()).getStringElem(0)+"']"; 
		    }
		
		s.nextRow();
		if (!s.eos())
		    {
			function+=", ";
			cwo+=", ";
		    }
		
		
	    }
	

	return function;
    }
    public static String soapheaderelement(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r;
	String function="";
	inputflag=true;
	stpl.setElem(0,otpl.getOidElem(0));
	
	s = theConnection.callFunction("Operation.soapheader->vector-element",stpl);
	//System.out.println("testing7  "+function);
	stpl.setElem(0,(s.getRow()).getOidElem(0));
	s= theConnection.callFunction("vector.vectorele->element",stpl);
	cwo+="{ ";
			
	while(!s.eos())
	    {
	
	
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		r= theConnection.callFunction("element.subelements->vector-element",stpl);

		if (!r.eos())
		    {
			
			stpl.setElem(0,(r.getRow()).getOidElem(0));
			r= theConnection.callFunction("vector.vectorele->element",stpl);	
				
	
			while(!r.eos())
			    {
				
				function+=subelement(r.getRow(),"")+" ";
				r.nextRow();
				if (!r.eos())
				    {
				    function+=", ";
				    cwo+=", ";
				    }
			    }
		    }
		else
		    {
			
			
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.wsmedtype->charstring",stpl);
			function+=(r.getRow()).getStringElem(0)+" ";
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.name->charstring",stpl);
			function+=(r.getRow()).getStringElem(0);
			cwo+=(r.getRow()).getStringElem(0);
			
		    }
		
		s.nextRow();
		if (!s.eos())
		    {
			function+=", ";
		
		    }
		
		    
		
	    }
	cwo+="}";
	//System.out.println("testing5  "+function);
	return function;
    }
    public static String subelement(Tuple otpl,String str) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r,t;
	String function="";
	String tempstr="";
	int outindex=0;
	

	stpl.setElem(0,otpl.getOidElem(0));
	r= theConnection.callFunction("element.subelements->vector-element",stpl);
	
	if (!r.eos())
	    {
		if (!inputflag)
		    {
			/* each element may contains set of sublements or  sequence of a single sub element or single sub element*/
			stpl.setElem(0,(r.getRow()).getOidElem(0));
			t= theConnection.callFunction("vector-element.countvectorele->integer",stpl);
			if (((t.getRow()).getIntElem(0))==1)
			    {	
				stpl.setElem(0,(r.getRow()).getOidElem(0));
				t= theConnection.callFunction("vector.vectorele->element",stpl);
				stpl.setElem(0,(t.getRow()).getOidElem(0));
			
				t= theConnection.callFunction("element.maxoccurs->charstring",stpl);
				stpl.setElem(0,otpl.getOidElem(0));
				s= theConnection.callFunction("element.name->charstring",stpl);
				tempstr=(s.getRow()).getStringElem(0);
			
				if (((t.getRow()).getStringElem(0)).equalsIgnoreCase("-1"))
				    {
					from+=", sequence "+str+tempstr+"1, record "+str+tempstr;
					where+=" and "+ str+tempstr+"1 = "+str+"['"+tempstr+"'] and "+ str+tempstr+" in "+str+tempstr+"1 ";
					//struct="record";
				    }
				else
				    {
					from+=", record "+str+tempstr;
					where+=" and "+ str+tempstr+"="+str+"['"+tempstr+"']" ;
					//struct="record";	

				    }
			    }
			else
			    {
				stpl.setElem(0,otpl.getOidElem(0));
				s= theConnection.callFunction("element.name->charstring",stpl);
				tempstr=(s.getRow()).getStringElem(0);
				from+=", record "+str+tempstr;
				where+=" and "+ str+tempstr+"="+str+"['"+tempstr+"']" ;
				//struct="record";
			    }
			
			
		    }	
		
		stpl.setElem(0,(r.getRow()).getOidElem(0));
		r= theConnection.callFunction("vector.vectorele->element",stpl);	
		
		while(!r.eos())
		    {
			
			function+=subelement(r.getRow(),str+tempstr);
			
			r.nextRow();
			if (!r.eos())
			    {
				function+=", ";
				if (inputflag)
				    cwo+=", ";	
			    }
		    }
	    }
	else
	    {
		stpl.setElem(0,otpl.getOidElem(0));
		r= theConnection.callFunction("element.wsmedtype->charstring",stpl);
		function+=(r.getRow()).getStringElem(0)+" ";
		stpl.setElem(0,otpl.getOidElem(0));
		r= theConnection.callFunction("element.name->charstring",stpl);
	
		
		if (inputflag)
		    {
			if (((r.getRow()).getStringElem(0)).equalsIgnoreCase(str))
			    {
				function+=(r.getRow()).getStringElem(0)+" ";
				cwo+=(r.getRow()).getStringElem(0);
			    }
			else
			    {
				function+=str+(r.getRow()).getStringElem(0)+" ";
				cwo+=str+(r.getRow()).getStringElem(0);
			    }
		    }
		else
		    {
			
			 function+=str+tempstr+(r.getRow()).getStringElem(0)+" ";
			if (select.equalsIgnoreCase("as select "))
			    select+=str+"['"+(r.getRow()).getStringElem(0)+"']";
			else
			    select+=", "+str+"['"+(r.getRow()).getStringElem(0)+"']"; 
			
			    
		    }
	    }
    
		
		
	
	
	
	
	return function;
    }
	
    public  void initiate(CallContext cxt, Tuple tpl) throws AmosException {
		
	try
	    { 
		//create(tpl.getStringElem(0));
		tpl.setElem(1,create(tpl.getStringElem(0)));
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	
       } 	

     public static boolean is_soapheader(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r;
	
	stpl.setElem(0,otpl.getOidElem(0));
	
	s = theConnection.callFunction("Operation.soapheader->vector-element",stpl);
	//System.out.println("testing7  "+function);
	stpl.setElem(0,(s.getRow()).getOidElem(0));
	s= theConnection.callFunction("vector.vectorele->element",stpl);
	if (!s.eos())
	    return true;
	else
	    return false;
    }
     private static void writeamosql(String filename,String ip)
    {
	FileOutputStream out; // declare a file output object
	PrintStream p; // declare a print stream object

	try
	    {
		// Create a new file output stream
		// connected to "myfile.txt"
		out = new FileOutputStream(filename +".amosql");
		
		// Connect print stream to the output stream
		p = new PrintStream( out );
		p.println (ip);
		p.close();
	    }
	catch (Exception e)
	    {
		System.err.println ("Error writing to file");
	    }
    }

}
