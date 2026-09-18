/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Silvia Stefanova, UDBL
 * $RCSfile: TestSwatm.java,v $
 * $Revision: 1.5 $ $Date: 2008/04/24 14:22:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Client demonstration program for SWATM
 * =========================================================================
 *
 **************************************************************************/

package rdfview;
import java.util.*;
import java.io.*;

public class TestSwatm {

    public static void main (String[] args) throws Exception {

	Vector arg= new Vector();
	RDFScan res=null;
	Vector rest;
	Vector row;
	String lang="SPARQL";
	String peer="SWATM";

	BufferedReader myIn = new BufferedReader (new InputStreamReader(System.in));
	String cont;
	String re="";

	do {
	    cont="y";
	    System.out.println("");
	    String c = new String();
	    char cc;
	    System.out.print("Write your SPARQL query and do not forget that it has to finish with \'}\' :\n ");
	    try {
		    do 
		    {
			cc = (char)myIn.read();
			c = c + cc;
		    }
		    while ( cc != '}' );

	    }
	    catch (IOException io)
		{
		    System.out.println(io.getMessage());
		}
			
	    String query;		
	    query=c.substring(0, c.length());
	    System.out.println("------------------------------");
	    String tom =myIn.readLine();
	   
	    try {
		RDFViewer s = new RDFViewer("http://udbl2.it.uu.se:8080/axis/services/RDFViewWS", peer);    
		res = s.SPARQL(query);
			/**
			 * Iterate over the result(RDFScan) of the query.
			 */
		System.out.println("The result");	System.out.flush();
		while(res.eof() != true)
		    {
			row = res.next();
			System.out.println(row);		
		    }
			System.out.flush();
	    }
		
	       catch (Exception e) 
		   {
		       System.out.println(e.getMessage());
		   }
		
	  	System.out.println("");
		System.out.println("--*--*---*-----*-----*----*---");
		System.out.println("Would you like to restart SWATM? If yes, please type \'ok\'! If not, press \'Enter\'! ");
		System.out.flush();
		re=myIn.readLine();

		//The Topic Map stored as xtm that will be loaded in the restarted Swatm peer
		String xtm = "http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm";
	
		if( re.equalsIgnoreCase("ok"))
		{
		    try {
			RDFViewer s = new RDFViewer("http://udbl2.it.uu.se:8080/axis/services/RDFViewWS", peer);  
			System.out.println("Please wait until SWATM is reloading!");  	
			rest=s.RestartPeer(xtm);
			System.out.println("");
			System.out.println("The SWATM peer has been restarted and the new database loaded");
		    }
		     catch (Exception e) 
			 {
			     System.out.println(e.getMessage());
			 }

		}

		System.out.println("");
		System.out.print("Would you like to continue query, y or n :");
		System.out.flush();
		cont =myIn.readLine();
		System.out.println("");
	   
	   		   
	}
	while (!cont.equalsIgnoreCase("n"));



    }

}

