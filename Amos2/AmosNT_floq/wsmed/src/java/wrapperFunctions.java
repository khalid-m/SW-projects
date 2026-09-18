import callin.*;
import callout.*;
import java.util.*;
import java.io.*;

public class wrapperFunctions {
    static String inarg,outarg,select,from,where,cwo;
    static String servicename, wsdlu,gstr;
    static Connection theConnection;
    static boolean inputflag=true;
    static Tuple  tempouttpl=new Tuple(2);
    static String inputpars="";
   

    public static String create(String wsdluri)  throws AmosException {
        	
	Scan s,r;
	Tuple stpl= new Tuple(1);
	String function="";
	String filename="";
	wsdlu=wsdluri;

	try{

	   
	    stpl.setElem(0,wsdluri);
        
	    s = theConnection.callFunction("charstring.findservice->Service",stpl);
	
	    stpl.setElem(0,(s.getRow()).getOidElem(0));
          
	    r= theConnection.callFunction("service.port->Operation",stpl);

	    //stpl.setElem(0,(s.getRow()).getOidElem(0));	
	    s = theConnection.callFunction("service.name->charstring",stpl);
	    servicename=(s.getRow()).getStringElem(0);
	
	    while(!r.eos())
		{
		    cwo="cwo('"+wsdluri+"', '"+servicename+"', '";
		    stpl.setElem(0,(r.getRow()).getOidElem(0));
	    
		    function+=operation(stpl);
		    /*To remove reserved word type */
		    if (function.indexOf(" type ")> -1)
			function=findElements.checkReservedKW(function);
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

	    filename=wsdluri+servicename;
	    filename=filename.replace("?","");
	    filename=filename.replace(":","");
	    filename=filename.replace(".","");
	    filename=filename.replace("-","");
	    filename =filename.replace("/","");
	    //function+="load_amosql('"+filename+".amosql');";
	    //System.out.println("test "+ function);

	    writeamosql(filename,function);
	}
	catch(Throwable ex)
	    {
	       
	    }
	
	return filename+".amosql";
	
    }
    public static String operation(Tuple otpl) throws AmosException {
	Tuple stpl= new Tuple(1);
	Scan s;
	String function="";
	String temp,tempsoapheader;
	boolean soaph;
	try {
	    tempouttpl.setElem(0,otpl.getOidElem(0));
	    stpl.setElem(0,otpl.getOidElem(0));
	    s = theConnection.callFunction("operation.name->charstring",stpl);
	    cwo+=(s.getRow()).getStringElem(0)+"', {";
	    function="/**************  "+(s.getRow()).getStringElem(0)+"    ******************************/ \n \n";
	    /*if (!is_soapheader(otpl))
	      function+="putsoaphvalue( "+otpl.getOidElem(0)+", "+"{}); \n \n ";*/
	    s = theConnection.callFunction("operation.tablename->charstring",stpl);
	    function+="create function sql:"+(s.getRow()).getStringElem(0)+" ( ";
	    // System.out.println("operation  "+(s.getRow()).getStringElem(0));

	    inputpars="";
	    temp=inputelement(otpl);
	    
	    inputpars=temp;
	  
	    if (temp.equalsIgnoreCase(""))
		function+=")->< "+outputelement(otpl)+" > \n";
	    /*function+=tempsoapheader+")->< "+outputelement(otpl)+" > \n";*/
	    else
		function+=temp+" )->< "+outputelement(otpl)+" > \n";


	    /*if (tempsoapheader.equalsIgnoreCase(""))
	      function+=temp+" )->< "+outputelement(otpl)+" > \n";
	      else
	      function+=temp+" ,"+tempsoapheader+")->< "+outputelement(otpl)+" > \n";*/
	
	}
	catch(Throwable ex)
	    {
	    }
	
	
	return function;	
	
	
    }
    public static String inputelement(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r,t;
	String function="";
	String tempstr;
	try
	    {
		inputflag=true;
		stpl.setElem(0,otpl.getOidElem(0));
	
		s = theConnection.callFunction("Operation.input->vector",stpl);
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		s= theConnection.callFunction("vector.vectorele->element",stpl);
		//System.out.println(" testing input ");
		while(!s.eos())
		    {
			//System.out.println(function);	
	
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.subelements->vector",stpl);
	

			if (!r.eos())
			    {
			
				stpl.setElem(0,(r.getRow()).getOidElem(0));
				r= theConnection.callFunction("vector.vectorele->element",stpl);	
			
				while(!r.eos())
				    {
					stpl.setElem(0,(s.getRow()).getOidElem(0));
					t= theConnection.callFunction("element.name->charstring",stpl);
					//System.out.println((t.getRow()).getStringElem(0));
				       
					function+=subelement(r.getRow(),(t.getRow()).getStringElem(0),function)+" ";
									
					r.nextRow();
					if (!r.eos()) {
					    function+=" , ";
					    cwo+=" , ";
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
			if (!s.eos()) {
			    function+=" , ";
			    cwo+=", ";
			}
			
		    }
		cwo+="} ";
	    }
	catch(Throwable ex)
	    {
	    }
	
	
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
	String strfun,strfun1;
	from="";
	where="";
	select="";
	try
	    {
		stpl.setElem(0,otpl.getOidElem(0));
		//System.out.println("testing5  "+function);
		t= theConnection.callFunction("Operation.output->vector",stpl);
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
			t= theConnection.callFunction("vector.countvectorele->integer",stpl);
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
			r= theConnection.callFunction("element.subelements->vector",stpl);
		
			if (!r.eos())
			    {
				stpl.setElem(0,(s.getRow()).getOidElem(0));
				t= theConnection.callFunction("element.name->charstring",stpl);
				tempstr=(t.getRow()).getStringElem(0)+"1";
				//System.out.println("tempstr  "+tempstr);		
				if (outindex==-1)
				    {
					from+=" , record "+tempstr;
					where+=" and "+tempstr+" in out ";
				    }
				else
				    {
					from+=" , record "+tempstr;
					where+=" and "+tempstr+"=out["+outindex+"] ";
				    }
			
			
				function+=subelement(s.getRow(),tempstr,inputpars+" "+function)+" ";
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
					from+=" , record "+tempstr;
					where+=" and "+tempstr+" in out ";
				    }
				else
				    {
					from+=" , record "+tempstr;
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
			if (!s.eos()) {
			    function+=" , ";
			    //cwo+=" , ";
			    	
			}
		
		
		    }
	    }
	catch(Throwable ex)
	    {
	    }
	
	return function;
    }
    public static String soapheaderelement(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r;
	String function="", strfun;
	try
	    {
		inputflag=true;
		stpl.setElem(0,otpl.getOidElem(0));
	
		s = theConnection.callFunction("Operation.soapheader->vector",stpl);
		//System.out.println("testing7  "+function);
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		s= theConnection.callFunction("vector.vectorele->element",stpl);
		cwo+="{ ";
			
		while(!s.eos())
		    {
	
	
			stpl.setElem(0,(s.getRow()).getOidElem(0));
			r= theConnection.callFunction("element.subelements->vector",stpl);

			if (!r.eos())
			    {
			
				stpl.setElem(0,(r.getRow()).getOidElem(0));
				r= theConnection.callFunction("vector.vectorele->element",stpl);	
				
	
				while(!r.eos())
				    {
					function+=subelement(r.getRow(),"",function)+" ";
					
					r.nextRow();
					if (!r.eos()) {
					    function+=" , ";
					    cwo+=" , ";
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
			if (!s.eos())  {
			    function+=" , ";
			}
		
		    
		
		    }
		cwo+="}";
		//System.out.println("testing5  "+function);
	    }
	catch(Throwable ex)
	    {
	    }
	
	return function;
    }
    public static String subelement(Tuple otpl,String str, String outparsofar) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl=new Tuple(1);
	Scan s,r,t;
	String function="",strfun;
	String tempstr="";
	int outindex=0;
	boolean maxoccurs=false;
        
	try
	    {
		stpl.setElem(0,otpl.getOidElem(0));
		r= theConnection.callFunction("element.subelements->vector",stpl);
	
		if (!r.eos())
		    {
			if (!inputflag)
			    {
				/* each element may contains set of sublements or  sequence of a single sub element or single sub element*/
				stpl.setElem(0,(r.getRow()).getOidElem(0));
				t= theConnection.callFunction("vector.countvectorele->integer",stpl);
				if (((t.getRow()).getIntElem(0))==1)
				    {	
					stpl.setElem(0,(r.getRow()).getOidElem(0));
					t= theConnection.callFunction("vector.vectorele->element",stpl);
					stpl.setElem(0,(t.getRow()).getOidElem(0));
					/*s= theConnection.callFunction("element.name->charstring",stpl);
					  strfun=(s.getRow()).getStringElem(0);*/
					rtpl.setElem(0,stpl.getOidElem(0));
					t= theConnection.callFunction("element.maxoccurs->charstring",stpl);
					stpl.setElem(0,otpl.getOidElem(0));
					s= theConnection.callFunction("element.name->charstring",stpl);
					tempstr=(s.getRow()).getStringElem(0);
				
				        
					strfun=findElements.checkDupname(from,str+"_"+tempstr);
                                         
					if (((t.getRow()).getStringElem(0)).equalsIgnoreCase("-1"))
					    {
					
						//System.out.println(" element "+ tempstr);
						if (Is_terminalelement(rtpl))
						    {
							
							from+=" , sequence "+strfun;
							where+=" and "+ strfun+ " = "+str+"['"+tempstr+"'] "; 							gstr=strfun;
						    }
						else
						    {
						
							from+=" , sequence "+strfun+"2 , record "+strfun;
							where+=" and "+ strfun+"2 = "+str+"['"+tempstr+"'] and "+ strfun+" in "+strfun+"2 ";
							gstr=strfun+"2";
						    }
						//struct="record";
					
					    }
					else
					    {
						from+=" , record "+strfun;
						where+=" and "+ strfun+"="+str+"['"+tempstr+"']" ;
						//struct="record";
						gstr=strfun;

					    }
				    }
				else
				    {
					stpl.setElem(0,otpl.getOidElem(0));
					s= theConnection.callFunction("element.name->charstring",stpl);
					tempstr=(s.getRow()).getStringElem(0);
					strfun=findElements.checkDupname(from,str+"_"+tempstr);
					from+=" , record "+strfun;
					where+=" and "+ strfun+"="+str+"['"+tempstr+"']" ;
					//struct="record";
					gstr=strfun;
				    }
			
			
			    }	
			else
			    {
				stpl.setElem(0,otpl.getOidElem(0));
				s= theConnection.callFunction("element.name->charstring",stpl);
				strfun=(s.getRow()).getStringElem(0);
				tempstr=strfun;
			    }
			    
		
			stpl.setElem(0,(r.getRow()).getOidElem(0));
			r= theConnection.callFunction("vector.vectorele->element",stpl);	
		
			//strfun=findElements.checkDupname(,str+"_"+tempstr);
		
			while(!r.eos())
			    {
				function+= subelement(r.getRow(),strfun,outparsofar+" "+function);
			
				r.nextRow();
				if (!r.eos())
				    {
					function+=" , ";
					if (inputflag) 
					    cwo+=" , ";
				    }
			    }
		    }
		else
		    {
			stpl.setElem(0,otpl.getOidElem(0));
			t= theConnection.callFunction("element.maxoccurs->charstring",stpl);
			if (((t.getRow()).getStringElem(0)).equalsIgnoreCase("-1"))
			    {
				maxoccurs=true;
				function+="vector of ";
			    }
		
		    
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
					strfun="";
					if ((!(outparsofar+function).equals("")))
					    strfun=findElements.checkDupname(outparsofar+" "+function,str+"_"+(r.getRow()).getStringElem(0))+" ";
					else
					    strfun=(r.getRow()).getStringElem(0);

					function+=strfun+" ";
					cwo+=strfun;
				    }
			    }
			else
			    {
			
				if ((!function.equals("")))
				    function+=findElements.checkDupname(inputpars+" "+outparsofar+function,(str+"_"+(r.getRow()).getStringElem(0)))+" ";
				
				//function+=srt+tempstr+(r.getRow()).getStringElem(0)+" ";
				if (select.equalsIgnoreCase("as select ")) {
					if (maxoccurs)
					    select+="Record2Vec("+gstr+" , '"+(r.getRow()).getStringElem(0)+"') ";
					else
					    select+=str+"['"+(r.getRow()).getStringElem(0)+"']";
				    }
				else
				    {	
					if (maxoccurs)
					    select+=", Record2Vec("+gstr+" , '"+(r.getRow()).getStringElem(0)+"') ";
					else
					    select+=", "+str+"['"+(r.getRow()).getStringElem(0)+"']"; 
				    }
			
			    
			    }
		    }
	    }	
	catch(Throwable ex)
	    {
	    }
	
	return function;
    }
    public static boolean  Is_terminalelement(Tuple otpl) throws AmosException 
    {
	Tuple stpl= new Tuple(1);
	Tuple rtpl= new Tuple(1);
	Scan r,s;
	boolean ter=false;
		
	try
	    { 
		stpl.setElem(0,otpl.getOidElem(0));
		s= theConnection.callFunction("element.name->charstring",stpl);
		//System.out.println(" element "+(s.getRow()).getStringElem(0));
		r= theConnection.callFunction("element.subelements->vector",stpl);
		if (r.eos())
		    ter=true;
		else
		    ter=false;
	    }
	catch(Throwable ex)
	    {}
	//System.out.println(ter);
	return ter;
    }
	
    public  void initiate(CallContext cxt, Tuple tpl) throws AmosException 
    {
		
	try
	    { 
		//create(tpl.getStringElem(0));
	
		theConnection = cxt.connection(); 
		tpl.setElem(1,create(tpl.getStringElem(0)));
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	
    } 	

    public static boolean is_soapheader(Tuple otpl) throws AmosException 
    {
	Scan s=null,r;
	try
	    {
		Tuple stpl= new Tuple(1);
		Tuple rtpl=new Tuple(1);
		
	
		stpl.setElem(0,otpl.getOidElem(0));
	
		s = theConnection.callFunction("Operation.soapheader->vector",stpl);
		//System.out.println("testing7  "+function);
		stpl.setElem(0,(s.getRow()).getOidElem(0));
		s= theConnection.callFunction("vector.vectorele->element",stpl);
		
	    }
	catch(Throwable ex)
	    {}
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
		//System.out.println("write");
		out = new FileOutputStream("src/amosql/"+filename +".amosql ");
		
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
